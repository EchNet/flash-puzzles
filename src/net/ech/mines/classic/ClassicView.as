/**
 */

package net.ech.mines.classic
{
    import flash.display.*;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import net.ech.mines.*;
    import net.ech.util.Grid;
    import net.ech.viva.events.Listeners;
    import net.ech.viva.events.VEvent;

    /**
     * A Minesweeper view, responsible for rendering and user gesture
     * handling.  Simulates the "classic" Windows version of Minesweeper.
     *
     * Difference: only the grid portion is sensitive to mouse down events.
     * In the classic version, a click gesture may be initiated in the outer
     * frame.
     *
     * Implementation: the display is a Bitmap.  Display updates are rendered
     * into the backing bitmap data.  Since Bitmaps do not dispatch mouse
     * events, mouse-sensitive regions of the display are covered by 
     * transparent Sprites parented by the MinesView Sprite.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class ClassicView
        extends MinesView
    {
        private var _renderer:ClassicRenderer;
        private var _gridOverlay:Sprite;
        private var _restartButtonOverlay:Sprite;
        private var _model:IMinesModel;
        private var _layout:Layout = new Layout(0, 0);
        private var _visualState:VisualState;

        // Gesture state is a dictionary of display items affected by
        // the mouse.  Index:
        // .restartPressed     true if restart button pressed
        // .cellPressed        array if any cell is pressed
        // .cellPressed[N]     true if cell #N is pressed
        //
        private var _gesture:Object = {};

        /**
         * Constructor.
         */
        public function ClassicView()
        {
            _renderer = new ClassicRenderer;
            addChild(_renderer);

            _gridOverlay = createOverlay(<MouseTracker>
                <function id={MinesCommands.EXPOSE} alt="false" ctrl="false"/>
                <function id={MinesCommands.CLEAR_AROUND} alt="true"/>
                <function id={MinesCommands.FLAG} ctrl="true" onDown="true"/>
            </MouseTracker>);

            _gridOverlay.addEventListener(MouseTracker.FCLICK, handleGridEvent);
            _gridOverlay.addEventListener(MouseTracker.FHOVER, handleGridEvent);

            _restartButtonOverlay = createOverlay(<MouseTracker>
                <function id={MinesCommands.RESTART}/>
            </MouseTracker>);

            addEventListener(MouseTracker.FCLICK, handleClick);
            addEventListener(MouseTracker.FHOVER, handleHover);
        }

        [Bindable("resize")]
        /**
         * My preferred width.
         */
        override public function get preferredWidth():int
        {
            return _layout.width;
        }

        [Bindable("resize")]
        /**
         * My preferred height.
         */
        override public function get preferredHeight():int
        {
            return _layout.height;
        }

        /**
         * My model.
         */
        public function get model():IMinesModel
        {
            return _model;
        }

        /**
         * @private
         */
        public function set model(model:IMinesModel):void
        {
            const eventMap:Object = { "stateChange": handleModelChange };
            Listeners.remove(model, eventMap);
            _model = model;
            if (_model != null)
            {
                initializeView();
            }
            Listeners.add(model, eventMap);
        }

        /**
         * @private
         */
        private function createOverlay(mouseTrackXml:XML):Sprite
        {
            var overlay:Sprite = new Sprite;
            new MouseTracker(mouseTrackXml).view = overlay;
            addChild(overlay);
            return overlay;
        }

        /**
         * @private
         */
        private function reshapeOverlay(overlay:Sprite, rect:Rectangle):void
        {
            overlay.x = rect.x;
            overlay.y = rect.y;
            overlay.graphics.clear();
            overlay.graphics.beginFill(0xffffff, 0.0);
            overlay.graphics.drawRect(0, 0, rect.width, rect.height);
            overlay.graphics.endFill();
        }

        /**
         * Bring the view up to date with the new model.
         */
        private function initializeView():void
        {
            // Clear any gesture in progress.
            _gesture = {};

            // Grab current size.
            var formerWidth:int = preferredWidth;
            var formerHeight:int = preferredHeight;

            // Instantiate new visual state and layout.
            _visualState = new VisualState(model.rows, model.columns);
            _layout = new Layout(model.rows, model.columns);

            // Bring visual state up to date with model.
            updateAll(false);

            // Plug both into the existing renderer, triggering full repaint.
            _renderer.layout = _layout;
            _renderer.visualState = _visualState;    // may resize bitmap.

            if (preferredWidth != formerWidth ||
                preferredHeight != formerHeight)
            {
                // Reshape the click zones.
                reshapeOverlay(_restartButtonOverlay, _layout.restartButtonRect);
                reshapeOverlay(_gridOverlay, _layout.gridRect);

                // Dispatch resize event.
                dispatchEvent(new Event("resize"));
            }
        }

        /**
         * What to do when the model changes.
         */
        private function handleModelChange(event:VEvent):void
        {
            switch (event.data.property)
            {
            case "*":
                updateAll(true);
                break;
            case "elapsedSeconds":
                updateTimer();
                break;
            case "flagCount":
                updateCounter();
                break;
            case "state":
                updateFace();
                break;
            case "cell":
                updateCell(event.data.row, event.data.column);
                break;
            }
        }

        /**
         * Annotate grid-related events with the relevant grid coordinates.
         */
        private function handleGridEvent(event:VEvent):void
        {
            var mouseEvent:MouseEvent = event.data.mouseEvent;
            event.data.row = int(mouseEvent.localY / Layout.CELL_HEIGHT);
            event.data.column = int(mouseEvent.localX / Layout.CELL_WIDTH);
        }

        /**
         * What to do when the mouse hovers over an active region.
         */
        private function handleHover(event:VEvent):void
        {
            if (model != null)
            {
                var oldGesture:Object = _gesture;
                _gesture = {};

                switch (event.data.latentFunc)
                {
                case MinesCommands.RESTART:
                    _gesture.restartPressed = true;
                    break;
                case MinesCommands.EXPOSE:
                    showExposeHover(event.data.row, event.data.column);
                    break;
                case MinesCommands.CLEAR_AROUND:
                    showClearAroundHover(event.data.row, event.data.column);
                    break;
                }

                updateGesture(oldGesture);
                updateGesture(_gesture);
            }
        }

        private function showExposeHover(row:int, column:int):void
        {
            switch (_model.getTagAt(row, column))
            {
            case Tags.NULL:
            case Tags.QUES:
                _gesture.cellPressed = {};
                _gesture.cellPressed[cellPressedIndex(row, column)] = true;
            }
        }

        private function showClearAroundHover(row:int, column:int):void
        {
            var tgtTag:int = _model.getTagAt(row, column);
            if (tgtTag > Tags.ZERO)
            {
                var grid:Grid = _visualState.grid;
                var nAdjMines:int = tgtTag - Tags.ZERO;
                var nAdjFlags:int = 0;

                grid.visitAdjacent(row, column, function(r:int, c:int, value:Object):void
                {
                    switch (_model.getTagAt(r, c))
                    {
                    case Tags.FLAG:
                        ++nAdjFlags;
                    }
                });

                if (nAdjFlags != nAdjMines)
                    return;

                _gesture.cellPressed = {};

                grid.visitAdjacent(row, column, function(r:int, c:int, value:Object):void
                {
                    switch (_model.getTagAt(r, c))
                    {
                    case Tags.NULL:
                    case Tags.QUES:
                        _gesture.cellPressed[cellPressedIndex(r, c)] = true;
                    }
                });
            }
        }

        /**
         * @private
         */
        private function updateGesture(gesture:Object):void
        {
            if (gesture.restartPressed || gesture.cellPressed)
            {
                updateFace();
            }

            if (gesture.cellPressed)
            {
                for (var cellIndex:String in gesture.cellPressed)
                {
                    var coords:Object = _visualState.grid.indexToCoordinates(int(cellIndex));
                    updateCell(coords.row, coords.column);
                }
            }
        }

        /**
         * @private
         */
        private function handleClick(event:VEvent):void
        {
            if (model != null)
            {
                dispatchEvent(VEvent.create(event.data.func, event.data));
            }
        }

        /**
         * @private
         */
        private function updateAll(clearGrid:Boolean):void
        {
            updateTimer();
            updateCounter();
            updateFace();

            if (clearGrid)
            {
                _visualState.clearGrid();
            }
            else
            {
                for (var row:int = 0; row < _model.rows; ++row)
                {
                    for (var column:int = 0; column < _model.columns; ++column)
                    {
                        updateCell(row, column);
                    }
                }
            }
        }

        private function updateTimer():void
        {
            _visualState.timer = _model.elapsedSeconds;
        }

        private function updateCounter():void
        {
            _visualState.counter = _model.nmines - _model.flagCount;
        }

        /**
         * Update the value of _visualState.face
         */
        private function updateFace():void
        {
            var iconIndex:uint = Faces.HAPPY;
            var pressed:Boolean = _gesture.restartPressed;

            if (_gesture.cellPressed)
            {
                iconIndex = Faces.SCARED;
            }
            else
            {
                switch (_model.state)
                {
                case States.LOST:
                    iconIndex = Faces.DEAD;
                    break;
                case States.WON:
                    iconIndex = Faces.COOL;
                    break;
                }
            }

            _visualState.face = ButtonState.value(iconIndex, pressed);
        }

        /**
         * Update the value of _visualState.face
         */
        private function updateCell(row:int, column:int):void
        {
            _visualState.grid.setCellAt(row, column,
                ButtonState.value(_model.getTagAt(row, column),
                                  isCellPressed(row, column)));
        }

        private function isCellPressed(row:int, column:int):Boolean
        {
            return _gesture.cellPressed && _gesture.cellPressed[cellPressedIndex(row, column)];
        }

        private function cellPressedIndex(row:int, column:int):String
        {
            return "" + _visualState.grid.coordinatesToIndex(row, column);
        }
    }
}
