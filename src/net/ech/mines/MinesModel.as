/**
 */

package net.ech.mines
{
    import flash.events.EventDispatcher;
    import net.ech.events.VEvent;
    import net.ech.util.Grid;

    /**
     * @inheritDoc
     */
    [Event(name="stateChange", type="net.ech.events.VEvent")]

    /**
     * Puzzle state, including the visible model, hidden properties, and
     * configuration parameters.  This is the sum of the persistent state
     * of the puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class MinesModel
        extends EventDispatcher
        implements IMinesModel
    {
        private var _rows:int;
        private var _columns:int;
        private var _nmines:int;
        private var _options:MinesOptions;
        private var _state:int;
        private var _flagCount:int;
        private var _elapsedSeconds:int;
        private var _grid:Grid;

        /**
         * Constructor.
         */
        public function MinesModel(config:MinesConfig)
        {
            _rows = config.rows;
            _columns = config.columns;
            _nmines = config.nmines;
            _options = new MinesOptions;
            validate();
            doReset();
        }

        /**
         * Create a new puzzle of the same configuration.  Throw out prior
         * state.
         */
        public function restart():void
        {
            doReset();
            dispatchPropertyChange("*");
        }

        //==============================================================
        // IMinesModel interface
        //==============================================================

        /**
         * @inheritDoc
         */
        public function get rows():int 
        {
            return _rows;
        }

        /**
         * @inheritDoc
         */
        public function get columns():int
        {
            return _columns;
        }

        /**
         * @inheritDoc
         */
        public function get nmines():int
        {
            return _nmines;
        }

        /**
         * @inheritDoc
         */
        public function get options():MinesOptions
        {
            return _options;
        }

        /**
         * @inheritDoc
         */
        public function get state():int
        {
            return _state;
        }

        /**
         * @inheritDoc
         */
        public function get elapsedSeconds():int
        {
            return _elapsedSeconds;
        }

        /**
         * @inheritDoc
         */
        public function get flagCount():int
        {
            return _flagCount;
        }

        /**
         * @inheritDoc
         */
        public function getTagAt(row:int, column:int):int
        {
            return _grid.getCellAt(row, column).tag;
        }

        //==============================================================
        // Serialization interface
        //==============================================================

        /**
         *
         */
        public function serialize():XML
        {
            var gridString:String = "";

            for (var row:int = 0; row < _rows; ++row)
            {
                for (var column:int = 0; column < _columns; ++column)
                {
                    var cell:Object = _grid.getCellAt(row, column);
                    if (gridString.length > 0) gridString += ",";
                    if (cell.mined) gridString += "*";
                    gridString += cell.tag;
                }
            }

            return <mines>
                    <rows>{_rows}</rows>
                    <columns>{_columns}</columns>
                    <nmines>{_nmines}</nmines>
                    <state>{_state}</state>
                    <elapsedSeconds>{_elapsedSeconds}</elapsedSeconds>
                    <grid>{gridString}</grid>
                </mines>;
        }

        /**
         *
         */
        public function deserialize(xml:XML):void
        {
            _rows = int(xml.rows.toString());
            _columns = int(xml.columns.toString());
            _nmines = int(xml.nmines.toString());
            _state = int(xml.state.toString());
            _flagCount = 0;
            _elapsedSeconds = int(xml.elapsedSeconds.toString());
            _grid = new Grid(_rows, _columns);

            var flagCount:int = 0;
            var cellStrings:Array = xml.grid.toString().split(",");

            for (var row:int = 0; row < _rows; ++row)
            {
                for (var column:int = 0; column < _columns; ++column)
                {
                    var str:String = String(cellStrings.shift());
                    var cell:Object = newCell();
                    if (str.charAt(0) == "*")
                    {
                        cell.mined = true;
                        str = str.substring(1);
                    }
                    cell.tag = int(str);
                    _grid.setCellAt(row, column, cell);

                    if (cell.tag == Tags.FLAG)
                    {
                        ++_flagCount;
                    }
                }
            }
        }

        //==============================================================
        // Internal interface, including properties and methods that
        // are off limits to the view.
        //==============================================================

        /**
         * @inheritDoc
         */
        internal function setOptions(options:MinesOptions):void
        {
            _options = options;
            // No change event dispatched.
        }

        /**
         * @private
         */
        internal function setState(state:int):void
        {
            if (state != _state)
            {
                _state = state;
                dispatchPropertyChange("state");
            }
        }

        /**
         * @private
         */
        internal function setElapsedSeconds(elapsedSeconds:int):void
        {
            if (elapsedSeconds != _elapsedSeconds)
            {
                _elapsedSeconds = elapsedSeconds;
                dispatchPropertyChange("elapsedSeconds");
            }
        }

        /**
         * @private
         */
        internal function setFlagCount(flagCount:int):void
        {
            if (flagCount != _flagCount)
            {
                _flagCount = flagCount;
                dispatchPropertyChange("flagCount");
            }
        }

        /**
         * Access the grid.
         */
        internal function getGrid():Grid
        {
            return _grid;
        }

        /**
         * Set the tag at the given position.
         * @param row  the row index
         * @param column the column index
         * @param tag the new tag value
         */
        internal function setTagAt(row:int, column:int, tag:int):void
        {
            var cell:Object = _grid.getCellAt(row, column);
            if (cell.tag != tag)
            {
                cell.tag = tag;
                dispatchPropertyChange("cell", row, column);
            }
        }

        /**
         * @private
         */
        private function validate():void
        {
            // Validate size of puzzle.
            var product:Number = rows * columns;
            var ncells:int = product;
            if (product != ncells || ncells < 4)
            {
                throw new Error("bad config: rows=" + rows +
                                " columns=" + columns);
            }

            // Validate number of mines with respect to size of puzzle.
            if (nmines >= ncells || nmines < 1)
            {
                throw new Error("bad config: nmines=" + nmines);
            }
        }

        /**
         * @private
         */
        private function doReset():void
        {
            _state = States.READY;
            _elapsedSeconds = 0;
            _flagCount = 0;
            _grid = new Grid(_rows, _columns, newCell);
        }

        /**
         * @private
         */
        private function newCell():Object
        {
            return { mined: false, tag: Tags.NULL };
        }

        /**
         * @private
         */
        private function dispatchPropertyChange(property:String, row:int = 0, column:int = 0):void
        {
            dispatchEvent(VEvent.create("stateChange", { property: property, row: row, column: column }));
        }
    }
}
