/**
 */

package net.ech.hashi
{
    import flash.events.EventDispatcher;
    import net.ech.util.Grid;
    import net.ech.puzzle.PuzzleModel;
    import net.ech.puzzle.States;

    /**
     * Puzzle state, including the visible model, hidden properties, and
     * configuration parameters.  This is the sum of the persistent state
     * of the puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class HashiModel
        extends PuzzleModel
    {
        private var _grid:Grid;

        /**
         * Constructor.
         */
        public function HashiModel(xml:XML)
        {
            super(xml);
        }

        /**
         * @private
         */
        override protected function configure(xml:XMLList):void
        {
            var config:HashiConfig = new HashiConfig(xml[0]);
            _grid = new Grid(config.rows, config.columns);

            for each (var node:Object in config.nodes)
            {
                var row:int = node.row;
                var column:int = node.column;
                var number:int = node.number;

                _grid.setCellAt(row, column, new Island(row, column, number));
            }
        }

        /**
         * @private
         */
        override protected function restoreState(xml:XMLList):void
        {
            super.restoreState(xml);

            var helper:HashiHelper = new HashiHelper(this);

            for each (var bridgeXml:XML in xml.bridge)
            {
                var bridgeInfo:Array = bridgeXml.toString().split(",");
                var row:int = int(bridgeInfo[0]);
                var column:int = int(bridgeInfo[1]);
                var dir:String = bridgeInfo[2];
                var n:int = int(bridgeInfo[3]);
                var island1:Island = getIslandAt(row, column);
                var island2:Island = helper.findPartner(island1, dir);
                var bridge:Bridge = new Bridge(island1, island2);
                bridge.add();
                if (n == 2) bridge.add();
            }
        }

        /**
         * Create an XML representation of this model.
         */
        override protected function serializeState():XML
        {
            var xml:XML = super.serializeState();

            forEachIsland(function(island:Island):void
            {
                for each (var dir:String in [ "east", "south" ])
                {
                    if (island[dir] > 0)
                    {
                        var bridge:String =
                            island.row + "," + island.column + "," +
                            dir + "," + island[dir];
                        xml.bridge += <bridge>{bridge}</bridge>;
                    }
                }
            });

            return xml;
        }

        public function get rows():int
        {
            return _grid.rows;
        }


        public function get columns():int
        {
            return _grid.columns;
        }

        /**
         * Get a cell as an Island.
         */
        public function getIslandAt(row:int, column:int):Island
        {
            return _grid.getCellAt(row, column) as Island;
        }

        /**
         * Get all islands as an array. 
         */
        public function getIslands():Array
        {
            var islands:Array = [];
            forEachIsland(function(island:Island):void
            {
                islands.push(island);
            });
            return islands;
        }

        /**
         * Visit each island.
         */
        public function forEachIsland(func:Function):void
        {
            anyIsland(function(island:Island):Boolean
            {
                func(island);
                return false;
            });
        }

        /**
         * Return true if the given function evaluates true for each island.
         */
        public function eachIsland(func:Function):Boolean
        {
            return !anyIsland(function(island:Island):Boolean
            {
                return !func(island);
            });
        }

        /**
         * If the given function evaluates true for any island, return
         * the first island.  Otherwise, return false.
         */
        public function anyIsland(func:Function):Island
        {
            for (var row:int = 0; row < _grid.rows; ++row)
            {
                for (var column:int = 0; column < _grid.columns; ++column)
                {
                    var island:Island = _grid.getCellAt(row, column) as Island;
                    if (island != null)
                    {
                        if (func(island))
                        {
                            return island;
                        }
                    }
                }
            }

            return null;
        }
    }
}
