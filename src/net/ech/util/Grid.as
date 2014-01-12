/**
 */

package net.ech.util
{
    import mx.collections.ArrayCollection;

    /**
     * A generic two-dimensional array class, based on ArrayCollection.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Grid
        extends ArrayCollection
    {
        private var _columns:int;

        /**
         * Constructor.
         */
        public function Grid(rows:uint, columns:uint, init:Object = null)
        {
            super(new Array(rows * columns));
            _columns = columns;

            if (init != null)
            {
                for (var i:int = 0; i < length; ++i)
                {
                    this[i] = (init is Function) ? init() : init;
                }
            }
        }

        /**
         * The number of rows.
         */
        public function get rows():uint
        {
            return length / _columns;
        }

        /**
         * The number of columns.
         */
        public function get columns():uint
        {
            return _columns;
        }

        /**
         * Get the value of the indexed cell.
         * @param row   the row index
         * @param column the column index
         */
        public function getCellAt(row:uint, column:uint):Object
        {
            return this[coordinatesToIndex(row, column)];
        }

        /**
         * Set the value of the indexed cell.
         * @param row   the row index
         * @param column the column index
         */
        public function setCellAt(row:uint, column:uint, value:Object):void
        {
            setItemAt(value, coordinatesToIndex(row, column));
        }

        /**
         * Get the array index that corresponds to the specified (row, column)
         * coordinates.
         */
        public function coordinatesToIndex(row:uint, column:uint):uint
        {
            return (row * _columns) + column;
        }

        /**
         * Get the (row, column) pair that corresponds to the specified 
         * array index.
         */
        public function indexToCoordinates(index:uint):Object
        {
            return {
                row: uint(index / _columns),
                column: uint(index % _columns)
            };
        }

        /**
         * Visit all cells.
         * @param func   Function having signature:
         *               <code>
         *                   function(row:int, column:int, value:Object):void
         *               </code>
         */
        public function visitAll(func:Function):void
        {
            var ix:int = 0;
            for (var row:int = 0; row < rows; ++row)
            {
                for (var column:int = 0; column < columns; ++column)
                {
                    func(row, column, this[ix++]);
                }
            }
        }

        /**
         * Visit each cell adjacent to the indexed one.
         * @param row   the row index
         * @param column the column index
         * @param func   Function having signature:
         *               <code>
         *                   function(row:int, column:int, value:Object):void
         *               </code>
         */
        public function visitAdjacent(row:int, column:int, func:Function):void
        {
            var lowRow:int = row - 1;
            if (lowRow < 0) lowRow = 0;
            var hiRow:int = row + 1;
            if (hiRow >= rows) hiRow = rows - 1;

            var lowCol:int = column - 1;
            if (lowCol < 0) lowCol = 0;
            var hiCol:int = column + 1;
            if (hiCol >= columns) hiCol = columns - 1;

            var nAdjFlags:int = 0;
            for (var r:int = lowRow; r <= hiRow; ++r)
            {
                for (var c:int = lowCol; c <= hiCol; ++c)
                {
                    if (r != row || c != column)
                    {
                        func(r, c, this[coordinatesToIndex(r, c)]);
                    }
                }
            }
        }
    }
}
