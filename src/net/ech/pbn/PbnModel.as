/**
 */

package net.ech.pbn
{
    import net.ech.puzzle.PuzzleModel;
    import net.ech.util.Base64;
    import net.ech.util.Grid;

    /**
     * Puzzle state, including the visible model, hidden properties, and
     * configuration parameters.  This is the sum of the persistent state
     * of the puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class PbnModel
        extends PuzzleModel
    {
        private var _config:PbnConfig;
        private var _grid:Grid;
        private var _encoder:Base64;

        /**
         * Constructor.
         */
        public function PbnModel(xml:XML)
        {
            super(xml);
        }

        /**
         * @private
         */
        override protected function configure(xml:XMLList):void
        {
            _config = new PbnConfig(xml[0]);
            _grid = new Grid(_config.rows, _config.columns, 0);
            _encoder = new Base64(CellValues.NVALS);
        }
        
        /**
         * @private
         */
        override protected function restoreState(xml:XMLList):void
        {
            super.restoreState(xml);
            _grid.source = _encoder.decode(xml.grid);
        }

        /**
         * Serialize.
         */
        override protected function serializeState():XML
        {
            var xml:XML = super.serializeState();
            var gridData:String = _encoder.encode(_grid.source);
            xml.grid += <grid>{gridData}</grid>;
            return xml;
        }

        /**
         * Number of rows.
         */
        public function get rows():int
        {
            return _grid.rows;
        }

        /**
         * Number of columns.
         */
        public function get columns():int
        {
            return _grid.columns;
        }

        /**
         * The row inputs.
         * @return an array of arrays of strings
         */
        public function get rowInputs():Array
        {
            return _config.rowInputs;
        }

        /**
         * The column inputs.
         * @return an array of arrays of strings
         */
        public function get columnInputs():Array
        {
            return _config.columnInputs;
        }

        /**
         * The title of the picture.
         */
        public function get title():String
        {
            return _config.title;
        }

        /**
         * Get a cell value.
         */
        public function getCellAt(row:int, column:int):int
        {
            return _grid.getCellAt(row, column) as int;
        }

        /**
         * Visit each cell in a row or column.
         */
        public function forEachInRank(isRow:Boolean, index:int, func:Function):void
        {
            forEach(isRow ? index : 0,
                    isRow ? (index + 1) : rows,
                    isRow ? 0 : index,
                    isRow ? columns : (index + 1),
                    func);
        }

        /**
         * Visit each cell.
         */
        public function forEachCell(func:Function):void
        {
            forEach(0, rows, 0, columns, func);
        }

        private function forEach(lowRow:int, highRow:int,
                                 lowColumn:int, highColumn:int,
                                 func:Function):void
        {
            for (var row:int = lowRow; row < highRow; ++row)
            {
                for (var column:int = lowColumn; column < highColumn; ++column)
                {
                    func(_grid.getCellAt(row, column) as int, row, column);
                }
            }
        }

        //==============================================================
        // Internal interface, including properties and methods that
        // are off limits to the view.
        //==============================================================

        /**
         * @private
         */
        internal function setCellAt(row:int, column:int, cell:int):void
        {
            _grid.setCellAt(row, column, cell);
        }
    }
}
