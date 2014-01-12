/**
 */

package net.ech.hashi
{
    /**
     * A connection between two islands.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Bridge
    {
        private var _island0:Island;
        private var _island1:Island;
        private var _location:Bridge;

        public function Bridge(island0:Island, island1:Island)
        {
            if (island0.row > island1.row || island0.column > island1.column)
            {
                var temp:Island = island0;
                island0 = island1;
                island1 = temp;
            }

            _island0 = island0;
            _island1 = island1;

            if (horizontal == vertical)
            {
                throw new Error("Illegal bridge: " + this);
            }
        }

        public function get horizontal():Boolean
        {
            return _island0.row == _island1.row;
        }

        public function get vertical():Boolean
        {
            return _island0.column == _island1.column;
        }

        public function get lowRow():int
        {
            return _island0.row;
        }

        public function get highRow():int
        {
            return _island1.row;
        }

        public function get lowColumn():int
        {
            return _island0.column;
        }

        public function get highColumn():int
        {
            return _island1.column;
        }

        public function get islands():Array
        {
            return [ _island0, _island1 ];
        }

        /**
         * @return an integer in [0..2].
         */
        public function get count():int
        {
            return horizontal ? _island0.east : _island0.south;
        }

        /**
         * Add another bridge here.
         */
        public function add():void
        {
            _island0[horizontal ? "east" : "south"] += 1;
            _island1[horizontal ? "west" : "north"] += 1;
        }

        /**
         * Clear this bridge.
         */
        public function clear():void
        {
            _island0[horizontal ? "east" : "south"] = 0;
            _island1[horizontal ? "west" : "north"] = 0;
        }

        public function equals(that:Bridge):Boolean
        {
            if (that == null) return false;
            return this.lowRow == that.lowRow &&
                   this.highRow == that.highRow &&
                   this.lowColumn == that.lowColumn &&
                   this.highColumn == that.highColumn;
        }

        public function toString():String
        {
            return "[" + _island0 + "-" + _island1 + "]";
        }
    }
}
