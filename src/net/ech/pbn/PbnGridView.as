/**
 */

package net.ech.pbn
{
    import flash.display.*;
    import flash.geom.Matrix;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.*;
    import net.ech.events.Listeners;
    import net.ech.events.VEvent;

    [Event(name="select", type="net.ech.events.VEvent")]
    [Event(name="resize", type="flash.events.Event")]

    /**
     * The Paint By Numbers grid (not including the number labels and other
     * outside controls).
     *
     * @author James Echmalian, ech@ech.net
     */
    public class PbnGridView
        extends Sprite
    {
        // Layout
        public static const OUTER_MARGIN:int = 1;
        public static const CELL_SIZE:int = 14;

        // Layers, back to front.
        private static const BACKGROUND:String = "background";
        private static const BITMAP:String = "bitmap";
        private static const BUFFS:String = "buffs"
        private static const LATTICE:String = "lattice";
        private static const HIGHLIGHT:String = "highlight";

        private var _model:PbnModel;
        private var _preferredWidth:int = 0;
        private var _preferredHeight:int = 0;
        private var _activeCell:Object;
        private var _layers:Object = {}
        private var _dragStartCell:Object;

        public function PbnGridView()
        {
            Listeners.add(this, {
                "mouseDown": handleMouseDown,
                "mouseUp": handleMouseUp,
                "mouseOver": handleMouseMove,
                "mouseOut": handleMouseOut,
                "mouseMove": handleMouseMove
            });

            function addLayer(name:String, filters:Array = null):void
            {
                var sprite:Sprite = new Sprite;
                sprite.filters = filters;
                _layers[name] =  { sprite: sprite, map: {} };
                addChild(sprite);
            }

            addLayer(BACKGROUND);
            addLayer(BITMAP);
            addLayer(BUFFS);
            addLayer(LATTICE);
            addLayer(HIGHLIGHT, [ new BlurFilter(2, 2, 2) ]);
        }

        [Bindable("resize")]
        /**
         * My preferred width.
         */
        public function get preferredWidth():int
        {
            return _preferredWidth;
        }

        [Bindable("resize")]
        /**
         * My preferred height.
         */
        public function get preferredHeight():int
        {
            return _preferredHeight;
        }

        public function get rows():int
        {
            return _model == null ? 0 : _model.rows;
        }

        public function get columns():int
        {
            return _model == null ? 0 : _model.columns;
        }

        /**
         * 
         */
        public function set model(model:PbnModel):void
        {
            const eventMap:Object = { "stateChange": handleModelChange };
            Listeners.remove(model, eventMap);
            _model = model;
            Listeners.add(model, eventMap);

            for (var layerName:String in _layers)
            {
                clearLayer(layerName);
            }

            var oldWidth:int = _preferredWidth;
            var oldHeight:int = _preferredHeight;

            _preferredWidth = calcPreferredSize("columns");
            _preferredHeight = calcPreferredSize("rows");

            drawBackground();
            createBitmap();

            if (_model != null)
            {
                drawAllCells();
                drawLattice();
            }

            if (_preferredWidth != oldWidth || _preferredHeight != oldHeight)
            {
                // Dispatch resize event.
                dispatchEvent(new Event("resize"));
            }

            updateWinAnimation();
        }

        private function calcPreferredSize(propName:String):int
        {
            var size:int = (OUTER_MARGIN * 2);

            if (_model != null)
            {
                var units:int = _model[propName];

                if (units > 0)
                {
                    size += (units * CELL_SIZE);
                }
            }

            return size;
        }

        private function handleMouseDown(event:MouseEvent):void
        {
            if (_activeCell != null)
            {
                paintActiveCell(null);
                touchActiveCell(event);
                _dragStartCell = _activeCell;
            }
        }

        private function handleMouseUp(event:MouseEvent):void
        {
            _dragStartCell = null;
            updateActiveCell(findActiveCell(event));
        }

        private function handleMouseMove(event:MouseEvent):void
        {
            if (event.buttonDown)
            {
                if (_dragStartCell)
                {
                    var newActiveCell:Object = findActiveCell(event);
                    var isNew:Boolean = !sameCell(newActiveCell, _activeCell);
                    _activeCell = newActiveCell;
                    if (isNew && _activeCell != null)
                    {
                        touchActiveCell(event);
                    }
                }
                else
                {
                    updateActiveCell(null);
                }
            }
            else
            {
                if (_dragStartCell)
                {
                    // Unexpected...
                    handleMouseUp(event);
                }
                else 
                {
                    updateActiveCell(findActiveCell(event));
                }
            }
        }

        private function handleMouseOut(event:MouseEvent):void
        {
            updateActiveCell(null);
        }

        private function touchActiveCell(event:MouseEvent):void
        {
            dispatchEvent(VEvent.create("select", {
                selectedCell: _activeCell,
                altColor: event.ctrlKey,
                altWeight: event.shiftKey,
                dragStartCell: _dragStartCell
            }));
        }

        private function handleModelChange(event:VEvent):void
        {
            if (event.data.clear)
            {
                drawAllCells();
            }
            else if (event.data.cell)
            {
                drawCell(event.data.cell.value,
                         event.data.cell.row,
                         event.data.cell.column);
            }
            else
            {
                drawAllCells();
            }

            updateWinAnimation();
        }

        private function drawBackground():void
        {
            var graphics:Graphics = _layers[BACKGROUND].sprite.graphics;
            graphics.beginFill(0xdddddd);
            graphics.drawRect(0, 0, _preferredWidth, _preferredHeight);
            graphics.endFill();
        }

        private function createBitmap():void
        {
            var bitmapData:BitmapData =
                new BitmapData(_model.columns, _model.rows, true, 0);
            var bitmap:Bitmap = new Bitmap(bitmapData);
            bitmap.width = _model.columns * CELL_SIZE;
            bitmap.height = _model.rows * CELL_SIZE;
            bitmap.x = OUTER_MARGIN;
            bitmap.y = OUTER_MARGIN;
            _layers[BITMAP].sprite.addChild(bitmap);
        }

        private function drawLattice():void
        {
            var graphics:Graphics = _layers[LATTICE].sprite.graphics;

            graphics.lineStyle(2);
            graphics.drawRect(0, 0, _preferredWidth, _preferredHeight);

            var sprite:Sprite = new Sprite;
            _layers[LATTICE].sprite.addChild(sprite);
            graphics = sprite.graphics;

            for (var row:int = 1; row < _model.rows; ++row)
            {
                graphics.lineStyle((row % 5) == 0 ? 1.5 : 0, 0x666666);
                graphics.moveTo(0, getRankEdge(row));
                graphics.lineTo(getRankEdge(_model.columns), getRankEdge(row));
            }

            for (var column:int = 1; column < _model.columns; ++column)
            {
                graphics.lineStyle((column % 5) == 0 ? 1.5 : 0, 0x666666);
                graphics.moveTo(getRankEdge(column), 0)
                graphics.lineTo(getRankEdge(column), getRankEdge(_model.rows));
            }
        }

        private function drawAllCells():void
        {
            _model.forEachCell(function(value:int, row:int, column:int):void
            {
                drawCell(value, row, column);
            });
        }

        private function drawCell(value:int, row:int, column:int):void
        {
            var dot:Boolean = false;
            var color:uint = 0x0;

            switch (value)
            {
            case CellValues.NEUTRAL:
                break;
            case CellValues.SEMI_BLACK:
                color = 0xff000000;
                dot = true;
                break;
            case CellValues.BLACK:
                color = 0xff000000;
                break;
            case CellValues.SEMI_WHITE:
                color = 0xffffffff;
                dot = true;
                break;
            case CellValues.WHITE:
                color = 0xffffffff;
                break;
            }

            _layers[BITMAP].sprite.getChildAt(0).bitmapData.setPixel32(column, row, dot ? 0 : color);

            var sprite:Sprite = objectToSprite(BUFFS, row + "," + column, dot);
            if (sprite != null)
            {
                sprite.graphics.clear();
                if (dot)
                {
                    sprite.graphics.beginFill(color & 0xffffff);
                    sprite.graphics.lineStyle();
                    sprite.graphics.drawEllipse(
                        getRankEdge(column) + CELL_SIZE / 4,
                        getRankEdge(row) + (CELL_SIZE / 4),
                        CELL_SIZE / 2, CELL_SIZE / 2);
                    sprite.graphics.endFill();
                }
            }
        }

        private function findActiveCell(event:MouseEvent):Object
        {
            if (_model != null && !_model.solved)
            {
                var x:int = event.localX;
                var y:int = event.localY;
                var n:int = CELL_SIZE;

                var column:int = (x - OUTER_MARGIN) / n;
                var row:int = (y - OUTER_MARGIN) / n;

                if (row >= 0 && row < _model.rows &&
                    column >= 0 && column < _model.columns)
                {
                    return { row: row, column: column };
                }
            }

            return null;
        }

        private function updateActiveCell(newActiveCell:Object):void
        {
            paintActiveCell(newActiveCell);
            _activeCell = newActiveCell;
        }

        private function paintActiveCell(newActiveCell:Object):void
        {
            var graphics:Graphics = _layers[HIGHLIGHT].sprite.graphics;

            if (_activeCell != null && !sameCell(newActiveCell, _activeCell))
            {
                graphics.clear();
            }

            if (newActiveCell != null && !sameCell(newActiveCell, _activeCell))
            {
                graphics.lineStyle(2.2, 0xf8f8ff);
                graphics.drawRect(getRankEdge(newActiveCell.column),
                                  getRankEdge(newActiveCell.row),
                                  CELL_SIZE, CELL_SIZE);
            }
        }

        private static function sameCell(cell1:Object, cell2:Object):Boolean
        {
            return (cell1 == null) ? (cell2 == null)
                                   : (cell2 != null &&
                                      cell1.row == cell2.row &&
                                      cell1.column == cell2.column);
        }

        private function getRankEdge(index:int):int
        {
            return OUTER_MARGIN + (index * CELL_SIZE);
        }

        private function objectToSprite(layerName:String, obj:Object,
                                        create:Boolean = false):Sprite
        {
            var key:String = String(obj);
            var layer:Object = _layers[layerName];
            var sprite:Sprite = layer.map[key] as Sprite;
            if (sprite == null && create)
            {
                sprite = new Sprite;
                layer.sprite.addChild(sprite);
                layer.map[key] = sprite;
            }
            return sprite;
        }

        private function clearLayer(layerName:String):void
        {
            var layer:Object = _layers[layerName];

            layer.sprite.graphics.clear();

            while (layer.sprite.numChildren > 0)
            {
                layer.sprite.removeChildAt(0);
            }

            layer.map = {};
        }

        private function updateWinAnimation():void
        {
            var win:Boolean = _model != null && _model.solved;

            _layers[LATTICE].sprite.getChildAt(0).visible = !win;
        }
    }
}
