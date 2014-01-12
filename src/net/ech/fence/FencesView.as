/**
 */

package net.ech.fence
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
     * Fences view, responsible for rendering and user gesture handling. 
     *
     * @author James Echmalian, ech@ech.net
     */
    public class FencesView
        extends Sprite
    {
        // Layout
        private static const OUTER_MARGIN:int = 5;
        private static const FENCE_GAP:int = 1;
        private static const CELL_SIZE:int = 20;

        // Layers, back to front.
        private static const BACKGROUND:String = "background";
        private static const YARD:String = "yard";
        private static const HIGHLIGHT:String = "highlight";
        private static const FENCE:String = "fence";
        private static const FOREGROUND:String = "foreground";
        private static const HIT:String = "hit";

        private var _model:FencesModel;
        private var _preferredWidth:int = 0;
        private var _preferredHeight:int = 0;
        private var _icons:Icons = new Icons;
        private var _activeSegment:Segment;
        private var _layers:Object = {}

        public function FencesView()
        {
            Listeners.add(this, {
                "mouseDown": handleMouseDown,
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
            addLayer(YARD);
            addLayer(HIGHLIGHT, [ new BlurFilter(4, 4, 2) ]);
            addLayer(FENCE);
            addLayer(FOREGROUND);
            addLayer(HIT);
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
        public function set model(model:FencesModel):void
        {
            const eventMap:Object = { "stateChange": handleModelChange };
            Listeners.remove(model, eventMap);
            _model = model;
            Listeners.add(model, eventMap);

            var oldWidth:int = _preferredWidth;
            var oldHeight:int = _preferredHeight;

            width = _preferredWidth = calcPreferredSize("columns");
            height = _preferredHeight = calcPreferredSize("rows");

            redrawAll();

            if (_preferredWidth != oldWidth || _preferredHeight != oldHeight)
            {
                // Dispatch resize event.
                dispatchEvent(new Event("resize"));
            }
        }

        private function calcPreferredSize(propName:String):int
        {
            var size:int = (OUTER_MARGIN * 2);

            if (_model != null)
            {
                var units:int = _model[propName];

                size += (units * CELL_SIZE) + ((units + 1) * FENCE_GAP);
            }

            return size;
        }

        private function handleMouseDown(event:MouseEvent):void
        {
            if (_activeSegment != null)
            {
                dispatchEvent(VEvent.create("select", _activeSegment));
            }
        }

        private function handleMouseMove(event:MouseEvent):void
        {
            updateActiveSegment(findActiveSegment(event));
        }

        private function handleMouseOut(event:MouseEvent):void
        {
            updateActiveSegment(null);
        }

        private function handleModelChange(event:VEvent):void
        {
            if (event.data.clear)
            {
                clearLayer(FENCE);
                clearLayer(YARD);
                drawBackground();
                drawAllNumbers();
            }
            else if (event.data.segment)
            {
                updateSegment(event.data.segment);
            }
            else
            {
                // Solved?
                drawYard();
                drawAllSegments();
                drawAllNumbers();
            }
        }

        private function redrawAll():void
        {
            for (var layerName:String in _layers)
            {
                clearLayer(layerName);
            }

            drawBackground();
            drawHit();

            if (_model != null)
            {
                drawYard();
                drawTicks();
                drawAllNumbers();
                drawAllSegments();
            }
        }

        private function drawBackground():void
        {
            var graphics:Graphics = _layers[BACKGROUND].sprite.graphics;
            graphics.clear();
            graphics.beginFill(Colors.BACKGROUND);
            graphics.drawRect(0, 0, _preferredWidth, _preferredHeight);
            graphics.endFill();
        }

        private function drawYard():void
        {
            var graphics:Graphics = _layers[YARD].sprite.graphics;
            graphics.clear();

            if (_model.solved)
            {
                graphics.beginFill(Colors.ROYAL);

                var startRow:int = _model.breadcrumbs[0].row;
                var startColumn:int = _model.breadcrumbs[0].column;
                graphics.moveTo(getRankOuterEdge(startColumn),
                                getRankOuterEdge(startRow));

                for (var i:int = 1; i < _model.breadcrumbs.length; ++i)
                {
                    var row:int = _model.breadcrumbs[i].row;
                    var column:int = _model.breadcrumbs[i].column;
                    graphics.lineTo(getRankOuterEdge(column),
                                    getRankOuterEdge(row));
                }

                graphics.lineTo(getRankOuterEdge(startColumn),
                                getRankOuterEdge(startRow));

                graphics.endFill();
            }
        }

        private function drawHit():void
        {
            var graphics:Graphics = _layers[HIT].sprite.graphics;
            graphics.beginFill(0, 0);
            graphics.drawRect(0, 0, _preferredWidth, _preferredHeight);
            graphics.endFill();
        }

        private function drawTicks():void
        {
            var graphics:Graphics = _layers[FOREGROUND].sprite.graphics;
            graphics.beginFill(Colors.BLACK);

            for (var row:int = 0; row <= _model.rows; ++row)
            {
                for (var column:int = 0; column <= _model.columns; ++column)
                {
                    graphics.drawRect(getRankEdge(column) - FENCE_GAP - 1,
                                      getRankEdge(row) - FENCE_GAP - 1, 3, 3);
                }
            }

            graphics.endFill();
        }

        /**
         * @private
         */
        private function drawAllNumbers():void
        {
            _model.forEachCell(drawNumber);
        }

        /**
         * @private
         */
        private function drawNumber(cell:Cell):void
        {
            if (cell.number >= 0)
            {
                var sprite:Sprite = objectToSprite(FOREGROUND, cell, function(spr:Sprite):void
                {
                    spr.x = getRankEdge(cell.column);
                    spr.y = getRankEdge(cell.row);
                });

                while (sprite.numChildren > 0)
                {
                    sprite.removeChildAt(0);
                }

                var digitSources:Array = cell.full ? _icons.grayDigitIcons : _icons.digitIcons;
                var digit:Bitmap = new Bitmap(digitSources[cell.number].bitmapData);
                digit.x = (CELL_SIZE - digit.width) / 2;
                digit.y = (CELL_SIZE - digit.height) / 2;
                sprite.addChild(digit);
            }
        }

        private function updateSegment(segment:Segment):void
        {
            if (segment.horizontal)
            {
                drawFencesInRow(segment.row);
            }
            else
            {
                drawFencesInColumn(segment.column);
            }

            for each (var cell:Cell in _model.getAdjacentCells(segment))
            {
                drawNumber(cell);
            }
        }

        private function drawAllSegments():void
        {
            for (var row:int = 0; row <= _model.rows; ++row)
            {
                drawFencesInRow(row);
            }

            for (var column:int = 0; column <= _model.columns; ++column)
            {
                drawFencesInColumn(column);
            }
        }

        private function drawFencesInRow(row:int):void
        {
            var graphics:Graphics = openFenceGraphics("r" + row);

            for (var column:int = 0; column < _model.columns; ++column)
            {
                if (_model.hasFence(new Segment(row, column, true)))
                {
                    doDrawSegment(row, column, true, graphics);
                }
            }
        }

        private function drawFencesInColumn(column:int):void
        {
            var graphics:Graphics = openFenceGraphics("c" + column);

            for (var row:int = 0; row < _model.rows; ++row)
            {
                if (_model.hasFence(new Segment(row, column, false)))
                {
                    doDrawSegment(row, column, false, graphics);
                }
            }
        }

        private function openFenceGraphics(key:String):Graphics
        {
            var sprite:Sprite = objectToSprite(FENCE, key);
            var graphics:Graphics = sprite.graphics;
            graphics.clear();
            graphics.lineStyle(1, 0);
            return graphics;
        }

        private function updateActiveSegment(newActiveSegment:Segment):void
        {
            var graphics:Graphics = _layers[HIGHLIGHT].sprite.graphics;

            if (_activeSegment != null &&
                !_activeSegment.equals(newActiveSegment))
            {
                graphics.clear();
            }

            if (newActiveSegment != null &&
                !newActiveSegment.equals(_activeSegment))
            {
                graphics.lineStyle(3, 0, 0.5);
                doDrawSegment(newActiveSegment.row, newActiveSegment.column,
                              newActiveSegment.horizontal, graphics);
            }

            _activeSegment = newActiveSegment;
        }

        private function doDrawSegment(row:int, column:int,
                                       horizontal:Boolean,
                                       graphics:Graphics):void
        {
            var x:int = getRankOuterEdge(column);
            var y:int = getRankOuterEdge(row);

            graphics.moveTo(x, y);

            if (horizontal)
            {
                x += CELL_SIZE + FENCE_GAP;
            }
            else
            {
                y += CELL_SIZE + FENCE_GAP;
            }

            graphics.lineTo(x, y);
        }

        private function findActiveSegment(event:MouseEvent):Segment
        {
            if (_model != null && !_model.solved)
            {
                var x:int = event.localX - OUTER_MARGIN;
                var y:int = event.localY - OUTER_MARGIN;
                var n:int = CELL_SIZE + FENCE_GAP;
                var vertOffset:Number = Math.min(y % n, n - (y % n));
                var horizOffset:Number = Math.min(x % n, n - (x % n));

                if (Math.min(vertOffset, horizOffset) <= (CELL_SIZE / 3.0) &&
                    Math.abs(vertOffset - horizOffset) > (CELL_SIZE / 6.0))
                {
                    var horizontal:Boolean = vertOffset < horizOffset;
                    var column:int;
                    var row:int;

                    if (horizontal)
                    {
                        column = (x + FENCE_GAP/2.0) / n;
                        row = (y + n/2.0) / n;
                    }
                    else
                    {
                        column = (x + n/2.0) / n;
                        row = (y + FENCE_GAP/2.0) / n;
                    }

                    return new Segment(row, column, horizontal);
                }
            }

            return null;
        }

        private function getRankEdge(index:int):int
        {
            return OUTER_MARGIN + FENCE_GAP + 
                   (index * (CELL_SIZE + FENCE_GAP));
        }

        private function getRankOuterEdge(index:int):Number
        {
            return Number(getRankEdge(index)) - (Number(FENCE_GAP) / 2);
        }

        private function objectToSprite(layerName:String, obj:Object,
                                        initFunc:Function = null):Sprite
        {
            var key:String = String(obj);
            var layer:Object = _layers[layerName];
            var sprite:Sprite = layer.map[key] as Sprite;
            if (sprite == null)
            {
                sprite = new Sprite;
                if (initFunc != null) initFunc(sprite);
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
    }
}
