/**
 *
 */

package net.ech.fence
{
    import flash.events.Event;
    import net.ech.puzzle.States;
    import net.ech.events.VEvent;

    /**
     * Controller for a Fences puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class FencesController
    {
        private var _model:FencesModel;

        /**
         * The model.  Caller must set this before starting application.
         */
        public function set model(model:FencesModel):void
        {
            _model = model;
        }

        /**
         * What to do when the user clicks the "clear" button.
         */
        public function clear():void
        {
            _model.removeAllFences();
            _model.setStatus(States.CLEAR);
            _model.breadcrumbs = null;
            _model.dispatchStateChange({ clear: true });
        }

        /**
         * Toggle the segment state at the given location.
         */
        public function select(segment:Segment):void
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
                    var going:Boolean = _model.hasFence(segment);
                    if (!going)
                    {
                        for each (var adj:Cell in _model.getAdjacentCells(segment))
                        {
                            if (adj.full) return;
                        }
                    }

                    if (going)
                    {
                        _model.removeFence(segment);
                    }
                    else
                    {
                        _model.addFence(segment);
                    }

                    if (_model.fenceCount == 0)
                    {
                        _model.setStatus(States.CLEAR);
                    }

                    var breadcrumbs:Array = checkWin();
                    if (breadcrumbs != null)
                    {
                        _model.setStatus(States.SOLVED);
                        _model.breadcrumbs = breadcrumbs;
                        stateChanged = true;
                    }

                    var changeData:Object = {};
                    if (!stateChanged)
                    {
                        changeData.segment = segment;
                    }

                    _model.dispatchStateChange(changeData);
                }
            }
        }

        /**
         * Has the user solved the puzzle?
         */
        private function checkWin():Array
        {
            // All numbered cells must be satisfied...
            return _model.eachCell(function(cell:Cell):Boolean
                                   {
                                       return cell.satisfied;
                                   }) 
            // ... and there must be a single, continuous loop of fences.
                   ? slitherlink(findAnyFencedSegment())
                   : null;
        }

        /**
         * Find any fenced segment.
         */
        private function findAnyFencedSegment():Segment
        {
            for each (var dir:String in [ "north", "south", "east", "west" ])
            {
                var cell:Cell = _model.anyCell(function (cell:Cell):Boolean
                {
                    return cell[dir];
                });

                if (cell != null)
                {
                    var row:int = cell.row;
                    var column:int = cell.column;
                    var horizontal:Boolean = dir == "north" || dir == "south";
                    if (dir == "south") ++row;
                    if (dir == "east") ++column;
                    return new Segment(row, column, horizontal);
                }
            }

            // Should not be reached.
            return null;
        }

        private static const NORTH:int = 0;
        private static const EAST:int = 1;
        private static const SOUTH:int = 2;
        private static const WEST:int = 3;

        /**
         * Row and column give the position of a POINT in the grid.
         * Dir is the direction we were moving in when we arrived here.
         * @return the list of points if successful, null otherwise
         */
        private function slitherlink(link:Segment):Array
        {
            // Create a lookup table for fence segments.
            var links:Object = {};

            // Leave breadcrumbs.
            var breadcrumbs:Array = [];

            // Maintain a sense of direction.
            var dir:int = link.horizontal ? WEST : NORTH;

            while (link != null)
            {
                // Record the current link.
                var key:String = link.toString();
                if (links[key] != null)
                {
                    break;  // If we return to a previously visited link, done.
                }
                links[key] = link;

                // Resolve segment and direction to current corner.
                var row:int = link.row;
                if (dir == SOUTH) row += 1;
                var column:int = link.column;
                if (dir == EAST) column += 1;

                breadcrumbs.push({ row: row, column: column });

                // Look for another link connecting to that corner.
                link = null;

                // Try all directions except back the way we came.
                var notDir:int = (dir + 2) % 4;

                for (var tryDir:int = 0; tryDir < 4; ++tryDir)
                {
                    if (tryDir == notDir) continue;

                    switch (tryDir)
                    {
                    case NORTH:
                        if (row == 0) continue;
                        break;
                    case SOUTH:
                        if (row == _model.rows) continue;
                        break;
                    case WEST:
                        if (column == 0) continue;
                        break;
                    case EAST:
                        if (column == _model.columns) continue;
                        break;
                    }

                    // Determine the properties of the segment at that location.
                    var horiz:Boolean = (tryDir & 1) != 0;
                    var r:int = (tryDir == NORTH) ? (row - 1) : row;
                    var c:int = (tryDir == WEST ) ? (column - 1) : column;

                    // Look up the segment.
                    var tryLink:Segment = new Segment(r, c, horiz);
                    if (_model.hasFence(tryLink))
                    {
                        if (link != null)
                        {
                            return null;   // more than one way to go.
                        }
                        link = tryLink;
                        dir = tryDir;
                    }
                }
            }

            // There must be one all-enclusive loop.
            return breadcrumbs.length == _model.fenceCount ? breadcrumbs : null;
        }
    }
}
