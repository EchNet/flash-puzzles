/**
 *
 */

package net.ech.fence
{
    /**
     * Description of a cell in a fences puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Cell
    {
        private var _row:int;
        private var _column:int;

        public function Cell(row:int, column:int)
        {
            this._row = row;
            this._column = column;
        }

        public function get row():int
        {
            return _row;
        }

        public function get column():int
        {
            return _column;
        }

        /** 
         * The number showing in the cell, or -1 if no number is showing.
         */
        public var number:int = -1;

        public var north:Boolean = false;
        public var south:Boolean = false;
        public var east:Boolean = false;
        public var west:Boolean = false;

        public function get totalSegments():int
        {
            return (north ? 1 : 0) + (south ? 1 : 0) +
                   (east ? 1 : 0) + (west ? 1 : 0);
        }

        public function get satisfied():Boolean
        {
            return number < 0 || totalSegments == number;
        }

        public function get full():Boolean
        {
            return number >= 0 && totalSegments == number;
        }

        /**
         * Format as string (for sake of key into graphics layer lookup)
         */
        public function toString():String
        {
            return "[ " + row + "," + column + "]";
        }
    }
}
