/**
 */

package net.ech.hashi
{
    import flash.events.EventDispatcher;
    import net.ech.util.Grid;

    /**
     * Where the complicated logic lives.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class HashiHelper
    {
        public var model:HashiModel;

        /**
         * Constructor.
         */
        public function HashiHelper(model:HashiModel)
        {
            this.model = model;
        }

        /**
         *
         */
        public function findActiveBridge(rank:int, horizontal:Boolean,
                                         scaledOffset:Number):Bridge
        {
            var bridge:Bridge = findBridge(rank, horizontal, scaledOffset);
            return ((bridge == null) || (getMaxBridgeCount(bridge) == 0))
                    ? null : bridge;
        }

        /**
         *
         */
        public function findBridge(rank:int, horizontal:Boolean,
                                   scaledOffset:Number):Bridge
        {
            function getIsland(index:int):Island
            {
                return model.getIslandAt(horizontal ? rank : index,
                                         horizontal ? index : rank);
            }

            var island1:Island = null;
            var island2:Island = null;

            for (var low:int = Math.floor(scaledOffset); low >= 0; --low)
            {
                island1 = getIsland(low);
                if (island1 != null) break;
            }

            var max:int = model[horizontal ? "rows" : "columns"];

            for (var high:int = Math.floor(scaledOffset + 1); high < max; ++high)
            {
                island2 = getIsland(high);
                if (island2 != null) break;
            }

            if (island1 == null || island2 == null) return null;

            return new Bridge(island1, island2);
        }

        /**
         * Determine the greatest number of bridges that may be permitted in
         * the specified location, given the current puzzle state.  Take
         * into account bridges already attached to one of the endpoints, and
         * the presence of intervening bridges.
         * @return a value in [0..2]
         * @throw Error if bridge is invalid
         */
        public function getMaxBridgeCount(bridge:Bridge):int
        {
            var interveningBridge:Boolean = false;

            forEachBetween(bridge, function(row:int, column:int):void
            {
                var iBridge:Bridge =
                        findBridge(bridge.horizontal ? column : row,
                                   !bridge.horizontal, 
                                   bridge.horizontal ? row : column);
                if (iBridge != null && iBridge.count > 0)
                {
                    interveningBridge = true;
                }
            });

            if (interveningBridge) return 0;

            var currentCount:int = bridge.count;
            var islands:Array = bridge.islands;
            var remaining1:int = islands[0].number - islands[0].totalBridges + currentCount;
            var remaining2:int = islands[1].number - islands[1].totalBridges + currentCount;

            return Math.min(2, Math.min(remaining1, remaining2));
        }

        /**
         *
         */
        public function findPartner(island:Island, direction:String):Island
        {
            var ix:Island = null;
            var row:int;
            var column:int;

            switch (direction)
            {
            case "east":
                for (column = island.column + 1; column < model.columns; ++column)
                {
                    ix = model.getIslandAt(island.row, column);
                    if (ix != null) break;
                }
                break;

            case "west":
                for (column = island.column - 1; column >= 0; --column)
                {
                    ix = model.getIslandAt(island.row, column);
                    if (ix != null) break;
                }
                break;

            case "north":
                for (row = island.row - 1; row >= 0; --row)
                {
                    ix = model.getIslandAt(row, island.column);
                    if (ix != null) break;
                }
                break;

            case "south":
                for (row = island.row + 1; row < model.rows; ++row)
                {
                    ix = model.getIslandAt(row, island.column);
                    if (ix != null) break;
                }
                break;
            }

            return ix;
        }

        private function validate(bridge:Bridge):void
        {
            // Sanity - check for intervening islands.
            forEachBetween(bridge, function(row:int, column:int):void
            {
                var island:Island = model.getIslandAt(row, column);
                if (island != null)
                {
                    throw new Error(island + " breaks bridge " + bridge);
                }
            });
        }

        private function forEachBetween(bridge:Bridge, func:Function):void
        {
            if (bridge.horizontal)
            {
                for (var column:int = bridge.lowColumn + 1; 
                     column < bridge.highColumn; ++column)
                {
                    func(bridge.lowRow, column);
                }
            }
            else
            {
                for (var row:int = bridge.lowRow + 1; 
                     row < bridge.highRow; ++row)
                {
                    func(row, bridge.lowColumn);
                }
            }
        }
    }
}
