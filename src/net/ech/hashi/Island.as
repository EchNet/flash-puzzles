/**
 *
 */

package net.ech.hashi
{
    /**
     * Description of a connection between two islands.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Island
    {
        private var _row:int;
        private var _column:int;
        private var _number:int;

        public function Island(row:int, column:int, number:int = 0)
        {
            this._row = row;
            this._column = column;
            this._number = number;
        }

        public function get row():int
        {
            return _row;
        }

        public function get column():int
        {
            return _column;
        }

        public function get number():int
        {
            return _number;
        }

        public var north:int = 0;
        public var south:int = 0;
        public var east:int = 0;
        public var west:int = 0;
        public var mark:Boolean;

        public function get totalBridges():int
        {
            return north + south + east + west;
        }

        public function get full():Boolean
        {
            return totalBridges == number;
        }

        public function toString():String
        {
            return "[" + row + "," + column + "]";
        }
    }
}
