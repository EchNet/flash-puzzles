/**
 */

package net.ech.fence
{
    import flash.events.EventDispatcher;
    import net.ech.puzzle.PuzzleModel;
    import net.ech.puzzle.States;
    import net.ech.util.Grid;

    /**
     * Puzzle state, including the visible model, hidden properties, and
     * configuration parameters.  This is the sum of the persistent state
     * of the puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class FencesModel
        extends PuzzleModel
    {
        private var _grid:Grid;
        private var _fenceCount:int = 0;

        /**
         * Constructor.
         */
        public function FencesModel(xml:XML)
        {
            super(xml);
        }

        /**
         * @private
         */
        override protected function configure(xml:XMLList):void
        {
            var config:FencesConfig = new FencesConfig(xml[0]);
            _grid = new Grid(config.rows, config.columns);

            _grid.visitAll(function (row:int, column:int, ... ignored):void
            {
                _grid.setCellAt(row, column, new Cell(row, column));
            })

            for each (var node:Object in config.nodes)
            {
                var row:int = node.row;
                var column:int = node.column;
                var number:int = node.number;

                _grid.getCellAt(row, column).number =  number;
            }
        }

        /**
         * @private
         */
        override protected function restoreState(xml:XMLList):void
        {
            super.restoreState(xml);

            for each (var fenceXml:XML in xml.fence)
            {
                var info:Array = fenceXml.toString().split(",");
                var horizontal:Boolean = info[2] == "-";
                var row:int = int(info[0]);
                var column:int = int(info[1]);
                addFence(new Segment(row, column, horizontal));
            }

            for each (var solutionXML:XML in xml.solution)
            {
                breadcrumbs = [];
                for each (var pt:String in solutionXML.toString().split(";"))
                {
                    info = pt.split(",");
                    breadcrumbs.push({
                        row: int(info[0]), column: int(info[1])
                    });
                }
            }
        }

        /**
         * Serialize as XML.
         */
        override protected function serializeState():XML
        {
            var xml:XML = super.serializeState();

            forEachCell(function(cell:Cell):void
            {
                if (cell.row == 0 && cell.north)
                {
                    recordFence(cell.row, cell.column, true);
                }
                if (cell.south)
                {
                    recordFence(cell.row + 1, cell.column, true);
                }
                if (cell.column == 0 && cell.west)
                {
                    recordFence(cell.row, cell.column, false);
                }
                if (cell.east)
                {
                    recordFence(cell.row, cell.column + 1, false);
                }
            });

            if (breadcrumbs != null)
            {
                var buf:String = "";
                for each (var pt:Object in breadcrumbs)
                {
                    if (buf.length > 0) buf += ";";
                    buf += pt.row + "," + pt.column;
                }
                xml.solution += <solution>{buf}</solution>;
            }

            return xml;

            function recordFence(row:int, column:int, horizontal:Boolean):void
            {
                var buf:String = row + "," + column + "," +
                                 (horizontal ? '-' : '|');
                xml.fence += <fence>{buf}</fence>;
            }
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
         * The current number of fences.
         */
        public function get fenceCount():int
        {
            return _fenceCount;
        }

        /**
         * The solution.
         */
        public var breadcrumbs:Array;

        /**
         * Get a cell.
         */
        public function getCellAt(row:int, column:int):Cell
        {
            return _grid.getCellAt(row, column) as Cell;
        }

        /**
         * Visit each cell.
         */
        public function forEachCell(func:Function):void
        {
            anyCell(function(cell:Cell):Boolean
            {
                func(cell);
                return false;
            });
        }

        /**
         * Return true if the given function evaluates true for each cell.
         */
        public function eachCell(func:Function):Boolean
        {
            return !anyCell(function(cell:Cell):Boolean
            {
                return !func(cell);
            });
        }

        /**
         * If the given function evaluates true for any cell, return
         * the first cell.  Otherwise, return false.
         */
        public function anyCell(func:Function):Cell
        {
            for (var row:int = 0; row < _grid.rows; ++row)
            {
                for (var column:int = 0; column < _grid.columns; ++column)
                {
                    var cell:Cell = _grid.getCellAt(row, column) as Cell;
                    if (cell != null)
                    {
                        if (func(cell))
                        {
                            return cell;
                        }
                    }
                }
            }

            return null;
        }

        /**
         * Look for fence.
         */
        public function hasFence(segment:Segment):Boolean
        {
            var adjacent:Object = getAdjacentCells(segment);
            for (var dir:String in adjacent)
            {
                return adjacent[dir][dir];
            }
            return false;  // not reached.
        }

        /**
         * Add a fence.
         */
        public function addFence(segment:Segment):void
        {
            tallyAdjacent(segment, true);
            ++_fenceCount;
        }

        /**
         * Remove a segment.
         */
        public function removeFence(segment:Segment):void
        {
            tallyAdjacent(segment, false);
            --_fenceCount;
        }

        /**
         * Remove all fences.
         */
        public function removeAllFences():void
        {
            forEachCell(function(cell:Cell):void
            {
                cell.north = false;
                cell.south = false;
                cell.east = false;
                cell.west = false;
            });
            _fenceCount = 0;
        }

        /**
         * Get the cells, if any, that "care" about the given segment -
         * i.e., that refer to it as "north", "south", "east" or "west".
         * @return an associative array: values are cells, their keys are
         *        the names of the properties that refer to the segment
         */
        public function getAdjacentCells(segment:Segment):Object
        {
            var result:Object = {}

            if (segment.horizontal)
            {
                if (segment.row > 0)
                {
                    result.south = getCellAt(segment.row - 1, segment.column);
                }

                if (segment.row < rows)
                {
                    result.north = getCellAt(segment.row, segment.column);
                }
            }
            else
            {
                if (segment.column > 0)
                {
                    result.east = getCellAt(segment.row, segment.column - 1);
                }

                if (segment.column < columns)
                {
                    result.west = getCellAt(segment.row, segment.column);
                }
            }

            return result;
        }

        private function tallyAdjacent(segment:Segment, on:Boolean):void
        {
            var adjacent:Object = getAdjacentCells(segment);
            for (var dir:String in adjacent)
            {
                adjacent[dir][dir] = on;
            }
        }
    }
}
