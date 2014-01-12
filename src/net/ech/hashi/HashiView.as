/**
 */

package net.ech.hashi
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
     * Hashi view, responsible for rendering and user gesture handling. 
     *
     * @author James Echmalian, ech@ech.net
     */
    public class HashiView
        extends Sprite
    {
        // Layout
        private static const OUTER_MARGIN:int = 6;
        private static const INNER_GAP:int = 9;
        private static const CELL_SIZE:int = 20;

        // Layers, back to front.
        private static const BACKGROUND:String = "background";
        private static const HIGHLIGHT:String = "highlight";
        private static const BRIDGE:String = "bridge";
        private static const ISLAND:String = "island";

        private var _model:HashiModel;
        private var _helper:HashiHelper;
        private var _preferredWidth:int = 0;
        private var _preferredHeight:int = 0;
        private var _icons:Icons = new Icons;
        private var _activeBridge:Bridge;
        private var _layers:Object = {}
        private var _winAnimation:WinAnimation;

        public function HashiView()
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
            addLayer(HIGHLIGHT, [ new BlurFilter(8, 8, 2) ]);
            addLayer(BRIDGE);
            addLayer(ISLAND);
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
        public function set model(model:HashiModel):void
        {
            const eventMap:Object = { "stateChange": handleModelChange };
            Listeners.remove(model, eventMap);
            _model = model;
            _helper = new HashiHelper(model);
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

            if (_model != null)
            {
                drawAllIslands();
                drawAllBridges();
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
                    size += (units * CELL_SIZE) + ((units - 1) * INNER_GAP);
                }
            }

            return size;
        }

        private function handleMouseDown(event:MouseEvent):void
        {
            if (_activeBridge != null)
            {
                dispatchEvent(VEvent.create("select", _activeBridge));
            }
        }

        private function handleMouseMove(event:MouseEvent):void
        {
            updateActiveBridge(findActiveBridge(event));
        }

        private function handleMouseOut(event:MouseEvent):void
        {
            updateActiveBridge(null);
        }

        private function handleModelChange(event:VEvent):void
        {
            if (event.data.clear)
            {
                clearLayer(BRIDGE);
                drawAllIslands();
            }
            else if (event.data.bridge)
            {
                var bridge:Bridge = Bridge(event.data.bridge);
                drawBridge(bridge);
                for each (var island:Island in bridge.islands)
                {
                    drawIsland(island);
                }
            }
            else
            {
                drawAllBridges();
                drawAllIslands();
            }

            updateWinAnimation();
        }

        private function drawBackground():void
        {
            var graphics:Graphics = _layers[BACKGROUND].sprite.graphics;
            graphics.beginFill(Colors.BACKGROUND);
            graphics.drawRect(0, 0, _preferredWidth, _preferredHeight);
            graphics.endFill();
        }

        private function drawAllIslands():void
        {
            _model.forEachIsland(function(island:Island):void
            {
                drawIsland(island);
            });
        }

        private function drawIsland(island:Island):void
        {
            var sprite:Sprite = objectToSprite(ISLAND, island, function(spr:Sprite):void
            {
                spr.x = getRankEdge(island.column);
                spr.y = getRankEdge(island.row);

                var digit:Bitmap = new Bitmap(_icons.digitIcons[island.number].bitmapData);
                digit.x = ((CELL_SIZE - digit.width) / 2);
                digit.y = ((CELL_SIZE - digit.height) / 2);
                spr.addChild(digit);
            });
            paintIsland(sprite, island.full ? Colors.FULL_ISLAND : Colors.WHITE);
        }

        private function paintIsland(sprite:Sprite, color:uint):void
        {
            sprite.graphics.clear();
            sprite.graphics.lineStyle(0.5, Colors.NEUTRAL);
            sprite.graphics.beginFill(color, 1);
            sprite.graphics.drawEllipse(0, 0, CELL_SIZE, CELL_SIZE);
            sprite.graphics.endFill();
        }

        private function drawAllBridges():void
        {
            _model.forEachIsland(function(island:Island):void
            {
                for each (var dir:String in [ "east", "south" ])
                {
                    if (island[dir] > 0)
                    {
                        var partner:Island = _helper.findPartner(island, dir);
                        drawBridge(new Bridge(island, partner));
                    }
                }
            });
        }

        private function drawBridge(bridge:Bridge):void
        {
            var sprite:Sprite = objectToSprite(BRIDGE, bridge);
            var graphics:Graphics = sprite.graphics;
            graphics.clear();

            var lc:int = getRankCenter(bridge.lowColumn);
            var lr:int = getRankCenter(bridge.lowRow);
            var hc:int = getRankCenter(bridge.highColumn);
            var hr:int = getRankCenter(bridge.highRow);

            switch (bridge.count)
            {
            case 1:
                graphics.lineStyle(2, 0);
                graphics.moveTo(lc, lr);
                graphics.lineTo(hc, hr);
                break;
            case 2:
                graphics.lineStyle(1, 0);
                if (bridge.horizontal)
                {
                    graphics.moveTo(lc, lr - 1.5);
                    graphics.lineTo(hc, lr - 1.5);
                    graphics.moveTo(lc, lr + 1.5);
                    graphics.lineTo(hc, lr + 1.5);
                }
                else
                {
                    graphics.moveTo(lc - 1.5, lr);
                    graphics.lineTo(lc - 1.5, hr);
                    graphics.moveTo(lc + 1.5, lr);
                    graphics.lineTo(lc + 1.5, hr);
                }
            }
        }

        private function updateActiveBridge(newActiveBridge:Bridge):void
        {
            var graphics:Graphics = _layers[HIGHLIGHT].sprite.graphics;

            if (_activeBridge != null &&
                !_activeBridge.equals(newActiveBridge))
            {
                graphics.clear();
            }

            if (newActiveBridge != null &&
                !newActiveBridge.equals(_activeBridge))
            {
                var bridge:Bridge = newActiveBridge;
                graphics.lineStyle(3, 0, 0.5);
                graphics.moveTo(getRankCenter(bridge.lowColumn), getRankCenter(bridge.lowRow));
                graphics.lineTo(getRankCenter(bridge.highColumn), getRankCenter(bridge.highRow));
            }

            _activeBridge = newActiveBridge;
        }

        private function findActiveBridge(event:MouseEvent):Bridge
        {
            if (_model == null || _model.solved) return null;

            var scaledRow:Number = getScaled(event.localY, rows);
            var scaledColumn:Number = getScaled(event.localX, columns);
            if (scaledRow < 0 || scaledColumn < 0)
            {
                return null;    // out of bounds
            }

            var withinRow:Boolean = withinRank(scaledRow);
            var withinColumn:Boolean = withinRank(scaledColumn);

            var nearestRow:int = Math.round(scaledRow);
            var nearestColumn:int = Math.round(scaledColumn);

            if (withinRow && withinColumn &&
                _model.getIslandAt(nearestRow, nearestColumn))
            {
                return null;     // inside island
            }

            var horizBridge:Bridge = null;
            var vertBridge:Bridge = null;

            if (withinRow)
            {
                horizBridge = _helper.findActiveBridge(nearestRow, true, scaledColumn);
            }

            if (withinColumn)
            {
                vertBridge = _helper.findActiveBridge(nearestColumn, false, scaledRow);
            }

            if (horizBridge != null && vertBridge != null)
            {
                return null;   // indeterminate intersection
            }

            return horizBridge != null ? horizBridge : vertBridge;
        }

        private function getScaled(offset:Number, max:int):Number
        {
            offset -= OUTER_MARGIN;
            offset -= CELL_SIZE / 2;

            var scaled:Number = offset / (CELL_SIZE + INNER_GAP);

            if (scaled > max) scaled = -1;

            return scaled;
        }

        private function withinRank(scaledOffset:Number):Boolean
        {
            var thresh:Number = (Number(CELL_SIZE) * Math.sqrt(0.125)) / (CELL_SIZE + INNER_GAP);
            scaledOffset -= Math.round(scaledOffset);
            return scaledOffset > -thresh && scaledOffset < thresh;
        }

        private function getRankEdge(index:int):int
        {
            return OUTER_MARGIN + (index * (CELL_SIZE + INNER_GAP));
        }

        private function getRankCenter(index:int):int
        {
            return getRankEdge(index) + (CELL_SIZE / 2);
        }

        private function objectToSprite(layerName:String, obj:Object,
                                        initFunc:Function = null):Sprite
        {
            var key:String = obj.toString();
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

        private function updateWinAnimation():void
        {
            if (_model != null && _model.solved)
            {
                if (_winAnimation == null)
                {
                    function repaintOneIsland(island:Island, color:uint):void
                    {
                        paintIsland(_layers[ISLAND].map[island.toString()], color);
                    }

                    _winAnimation = new WinAnimation(_model.getIslands(),
                                                     repaintOneIsland);
                }
            }
            else
            {
                if (_winAnimation != null)
                {
                    _winAnimation.stop();
                    _winAnimation = null;
                }
            }
        }
    }
}
