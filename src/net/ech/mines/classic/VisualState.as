/**
 */

package net.ech.mines.classic
{
    import flash.events.EventDispatcher;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import net.ech.mines.*;
    import net.ech.util.Grid;
    import net.ech.viva.events.Listeners;
    import net.ech.viva.events.VEvent;

    /**
     * Event dispatched when a property of this object, including a grid
     * cell, changes in value.
     */
    [Event("stateChange")]

    /**
     * Classic Minesweeper view state.  
     *
     * @author James Echmalian, ech@ech.net
     */
    public class VisualState
        extends EventDispatcher
    {
        private var _rows:uint;
        private var _columns:uint;
        private var _face:uint = 0;
        private var _timer:int = 0;
        private var _counter:int = 0;
        private var _grid:Grid;

        /**
         * Constructor.
         */
        public function VisualState(rows:uint, columns:uint)
        {
            _rows = rows;
            _columns = columns;
            createGrid();
        }

        /**
         * Value describing the face button.  See class ButtonState.
         */
        public function get face():uint
        {
            return _face;
        }

        /**
         * @private
         */
        public function set face(face:uint):void
        {
            if (face != _face)
            {
                _face = face;
                dispatchStateChange("face");
            }
        }

        /**
         * Number of seconds elapsed since start of play.
         */
        public function get timer():int
        {
            return _timer;
        }

        /**
         * @private
         */
        public function set timer(timer:int):void
        {
            if (timer != _timer)
            {
                _timer = timer;
                dispatchStateChange("timer");
            }
        }

        /**
         * Number of mines left to flag, supposing all current flags are
         * placed correctly.
         */
        public function get counter():int
        {
            return _counter;
        }

        /**
         * @private
         */
        public function set counter(counter:int):void
        {
            if (counter != _counter)
            {
                _counter = counter;
                dispatchStateChange("counter");
            }
        }

        /**
         * The grid.  Cell type is "ButtonState" (uint).
         */
        public function get grid():Grid
        {
            return _grid;
        }

        /**
         * Clear the grid for the start of a new puzzle.
         */
        public function clearGrid():void
        {
            createGrid();
            dispatchStateChange("grid");
        }

        /**
         * @private
         */
        private function createGrid():void
        {
            _grid = new Grid(_rows, _columns, 0);
            Listeners.add(_grid, { collectionChange: handleCollectionChange });
        }

        /**
         * @private
         */
        private function handleCollectionChange(event:CollectionEvent):void
        {
            switch (event.kind)
            {
            case CollectionEventKind.REPLACE:
                var coords:Object = _grid.indexToCoordinates(event.location);
                dispatchStateChange("cell", coords.row, coords.column);
                break;
            }
        }

        /**
         * @private
         */
        private function dispatchStateChange(property:String,
                                             row:uint = undefined,
                                             column:uint = undefined):void
        {
            dispatchEvent(VEvent.create("stateChange", {
                            property: property,
                            row: row,
                            column: column }));
        }
    }
}
