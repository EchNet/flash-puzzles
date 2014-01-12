/**
 */

package net.ech.fence
{
    /**
     * A connection between two corners.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Segment
    {
        private var _horizontal:Boolean;
        private var _row:int;
        private var _column:int;

        public var marked:Boolean;
        
        public function Segment(row:int, column:int, horizontal:Boolean)
        {
            _row = row;
            _column = column;
            _horizontal = horizontal;
        }

        public function get horizontal():Boolean
        {
            return _horizontal;
        }

        public function get vertical():Boolean
        {
            return !_horizontal;
        }

        public function get row():int
        {
            return _row;
        }

        public function get column():int
        {
            return _column;
        }

        public function equals(that:Segment):Boolean
        {
            if (that == null) return false;
            return this.horizontal == that.horizontal &&
                   this.row == that.row &&
                   this.column == that.column;
        }

        public function toString():String
        {
            return "[" + _row + (horizontal ? "-" : "|") + _column + "]";
        }
    }
}
