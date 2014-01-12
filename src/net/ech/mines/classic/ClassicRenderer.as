/**
 */

package net.ech.mines.classic
{
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import net.ech.mines.*;
    import net.ech.viva.events.Listeners;
    import net.ech.viva.events.VEvent;

    /**
     * A Minesweeper view, simulating the "classic" Windows 3.1 version of
     * Minesweeper.  This class is responsible only for rendering.  Gestures
     * are handled by ClassicView.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class ClassicRenderer
        extends Bitmap
    {
        private var _visualState:VisualState;
        private var _layout:Layout;
        private var _fresh:Boolean;

        // TODO: make the icons customizable.
        private var _icons:Icons = new Icons;

        // Having these "scratch pad" objects around reduces the number of temp
        // objects created per display update.  Love that single threadedness.
        //
        private const staticRect:Rectangle = new Rectangle;
        private const staticMatrix:Matrix = new Matrix;

        /**
         * Constructor.
         */
        public function ClassicRenderer()
        {
            super(new BitmapData(1, 1));
            pixelSnapping = PixelSnapping.NEVER;
            smoothing = false;
        }

        /**
         * What to render.
         */
        public function set visualState(visualState:VisualState):void
        {
            var eventMap:Object = { stateChange: handleStateChange };
            Listeners.remove(_visualState, eventMap);
            _visualState = visualState;
            renderCompletely();
            Listeners.add(_visualState, eventMap);
        }

        /**
         * Where to render it.
         */
        public function set layout(layout:Layout):void
        {
            _layout = layout;
            bitmapData = new BitmapData(_layout.width, _layout.height,
                                        false, Colors.GRAY);
            _fresh = true;
        }

        private function handleStateChange(event:VEvent):void
        {
            switch (event.data.property)
            {
            case "grid":
                renderCompletely();
                break;
            case "face":
                renderRestartButton();
                break;
            case "counter":
                renderCounter();
                break;
            case "timer":
                renderTimer();
                break;
            case "cell":
                renderCell(event.data.row, event.data.column);
                break;
            }
        }

        /**
         * Like the name says...
         */
        private function renderCompletely():void
        {
            renderBorders();
            renderRestartButton();
            renderCounter();
            renderTimer();

            for (var row:int = 0; row < _visualState.grid.rows; ++row)
            {
                for (var column:int = 0; column < _visualState.grid.columns; ++column)
                {
                    renderCell(row, column);
                }
            }

            _fresh = false;
        }

        /**
         * Render the counter display.
         */
        private function renderCounter():void
        {
            renderSevenSeg(_layout.counterRect, _visualState.counter);
        }

        /**
         * Render the timer display.
         */
        private function renderTimer():void
        {
            renderSevenSeg(_layout.timerRect, _visualState.timer);
        }

        /**
         * Render a grid cell.
         */
        private function renderCell(row:int, column:int):void
        {
            var cell:uint = uint(_visualState.grid.getCellAt(row, column));
            var iconIndex:int = ButtonState.getIconIndex(cell);
            var rect:Rectangle = _layout.getCellRectAt(row, column);

            // Render pressed cells as uncovered.
            if (Tags.isExposed(iconIndex) || ButtonState.isPressed(cell))
            {
                drawSeg(rect.x, rect.y, rect.width, true, Colors.DARK_GRAY);
                drawSeg(rect.x, rect.y, rect.height, false, Colors.DARK_GRAY);
                fillRect(rect.x + 1, rect.y + 1,
                         rect.width - 2, rect.height - 2,
                         iconIndex == Tags.BOOM ? Colors.RED : Colors.LIGHT_GRAY);
            }
            else
            {
                draw3DRect(rect, true, 2);
                if (!_fresh)
                {
                    fillRect(rect.x + 2, rect.y + 2,
                             rect.width - 4, rect.height - 4, Colors.GRAY);
                }
            }

            drawBitmap(_icons.tagIcons[iconIndex], rect.x + 1, rect.y + 2);
        }

        private function renderBorders():void
        {
            draw3DRect(new Rectangle(0, 0, _layout.width, _layout.height),
                      true, 3);
            draw3DRect(_layout.topPanelRect, false, 2);
            draw3DRect(_layout.gridPanelRect, false, 3);
            draw3DRect(_layout.counterRect, false, 1);
            draw3DRect(_layout.timerRect, false, 1);
        }

        private function renderRestartButton():void
        {
            var rect:Rectangle = _layout.restartButtonRect;
            var x:int = rect.x;
            var y:int = rect.y;
            var width:int = rect.width;
            var height:int = rect.height;

            fillRect(x, y, width - 1, height - 1, Colors.GRAY);

            var pressed:Boolean = ButtonState.isPressed(_visualState.face);
            if (pressed)
            {
                drawSeg(x + 1, y + 1, width - 2, true, Colors.DARK_GRAY);
                drawSeg(x + 1, y + 1, height - 2, false, Colors.DARK_GRAY);
            }
            else
            {
                // Draw inner 3D effect
                staticRect.x = x + 1;
                staticRect.y = y + 1;
                staticRect.width = width - 2;
                staticRect.height = height - 2;
                draw3DRect (staticRect, true, 2);
            }

            // Put a dark border on it.
            drawSeg(x, y, width - 1, true, Colors.DARK_GRAY);
            drawSeg(x, y, height - 1, false, Colors.DARK_GRAY);
            drawSeg(x + 1, y + height - 1, width - 2, true, Colors.DARK_GRAY);
            drawSeg(x + width - 1, y + 1, height - 2, false, Colors.DARK_GRAY);

            var imageOff:int = pressed ? 6 : 5;
            var iconIndex:int = ButtonState.getIconIndex(_visualState.face);

            drawBitmap(_icons.faceIcons[iconIndex], x + imageOff, y + imageOff);
        }

        private function renderSevenSeg(rect:Rectangle, value:int):void
        {
            fillRect(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2,
                     Colors.BLACK);

            var digitWidth:int = (rect.width - 2 - 3) / 3 + 1;

            var v:int = Math.abs(value);
            for (var i:int = 3; --i >= 0; )
            {
                var digVal:int = (i == 0 && value < 0) ? 10 : (v % 10);
                drawBitmap(_icons.digitIcons[digVal],
                           rect.x + 2 + (i * digitWidth), rect.y + 2);
                v /= 10;
            }
        }

        private function draw3DRect(rect:Rectangle, raised:Boolean,
                                    thickness:int):void
        {
            var x:int = rect.x;
            var y:int = rect.y;
            var width:int = rect.width;
            var height:int = rect.height;

            while (--thickness >= 0)
            {
                // Draw top, left sides.
                //
                var color:uint = raised ? Colors.LIGHT_GRAY : Colors.DARK_GRAY;
                drawSeg(x, y, width, true, color);
                drawSeg(x, y, height, false, color);

                // Draw bottom, right sides.
                color = raised ? Colors.DARK_GRAY : Colors.LIGHT_GRAY;
                drawSeg(x, y + height - 1, width, true, color);
                drawSeg(x + width - 1, y, height, false, color);

                ++x;
                ++y;
                width -= 2;
                height -= 2;
            }
        }

        private function fillRect(x:int, y:int, width:int, height:int,
                                  color:uint):void
        {
            staticRect.x = x;
            staticRect.y = y;
            staticRect.width = width;
            staticRect.height = height;
            bitmapData.fillRect(staticRect, color);
        }

        private function drawSeg(x:int, y:int, length:int,
                                 horiz:Boolean, color:uint):void
        {
            var dx:int = horiz ? 1 : 0;
            var dy:int = horiz ? 0 : 1;

            while (length-- > 0)
            {
                bitmapData.setPixel32(x, y, color);
                x += dx;
                y += dy;
            }
        }

        private function drawBitmap(bitmap:Bitmap, x:int, y:int):void
        {
            staticMatrix.identity();
            staticMatrix.translate(x, y);
            bitmapData.draw (bitmap, staticMatrix);
        }
    }
}
