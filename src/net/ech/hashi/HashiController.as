/**
 *
 */

package net.ech.hashi
{
    import flash.events.Event;
    import net.ech.puzzle.States;

    /**
     * Application controller for Hashiweeper puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class HashiController
    {
        private var _model:HashiModel;
        private var _helper:HashiHelper;
        private var _startTime:uint = 0;

        /**
         * The model.  Caller must set this before starting application.
         */
        public function set model(model:HashiModel):void
        {
            _model = model;
            _helper = new HashiHelper(_model);
        }

        /**
         * What to do when the user clicks the "clear" button.
         */
        public function clear():void
        {
            _model.forEachIsland(function(island:Island):void
            {
                island.north = 0;
                island.south = 0;
                island.east = 0;
                island.west = 0;
            });

            _model.setStatus(States.CLEAR);
            _model.dispatchStateChange({ clear: true });
        }

        /**
         * Rotate the bridge state at the indexed location.
         * If a bridge may be placed there, place one.  If the maximum 
         * number of bridges has been placed, remove all.  
         */
        public function select(bridge:Bridge):void
        {
            if (_model != null)
            {
                var stateChanged:Boolean = false;

                if (_model.status == States.CLEAR)
                {
                    _model.setStatus(States.WORKING);
                    stateChanged = true;
                }

                if (_model.status == States.WORKING)
                {
                    if (bridge.count < _helper.getMaxBridgeCount(bridge))
                    {
                        bridge.add();
                        if (checkWin()) 
                        {
                            _model.setStatus(States.SOLVED);
                            stateChanged = true;
                        }
                    }
                    else
                    {
                        bridge.clear();
                    }

                    var changeData:Object = {};

                    if (!stateChanged)
                    {
                        changeData.bridge = bridge;
                    }

                    _model.dispatchStateChange(changeData);
                }
            }
        }

        /**
         * Has the user solved the puzzle?
         */
        private function checkWin():Boolean
        {
            // All islands must be full.
            if (!_model.eachIsland(function(island:Island):Boolean
                                   {
                                       return island.full;
                                   }))
            {
                return false;
            }

            // Clear marks.
            _model.forEachIsland(function(island:Island):void
            {
                island.mark = false;
            });

            // Mark islands that can be reached from the first one found.
            function markIslands(island:Island):void
            {
                if (island != null && !island.mark)
                {
                    island.mark = true;

                    for each (var dir:String in [ "north", "south", "east", "west" ])
                    {
                        if (island[dir] > 0)
                        {
                            markIslands(_helper.findPartner(island, dir));
                        }
                    }
                }
            }
            markIslands(_model.anyIsland(function(island:Island):Boolean 
                                         {
                                             return true;
                                         }));

            // All islands must be marked.
            if (!_model.eachIsland(function(island:Island):Boolean
                                   {
                                       return island.mark;
                                   }))
            {
                return false;
            }

            return true;
        }
    }
}
