package net.ech.sudoku.solver
{
    /**
     * Slicing is the technique of looking at a number and examining each group
     * to find a single cell in the group that number could occupy.
     */
    public class Slicer extends Technique
    {
        private var number:int;
        private var found:Boolean;

        public function Slicer(grid:SolutionModel, number:int)
        {
            super(grid);
            this.number = number;
            level = 2;
        }

        override public function find():Boolean
        {
            found = false;

            // Clear any prior work hanging off of cells.
            //
            //new CellClearer(grid, CellClearer.LAST_STEP).clear();

            // For each cell having the specified number, mark others
            // in the same group.
            //
            new SliceMarker(grid, number).mark();

            // Look for groups having only one available cell.
            //
            walkGroups();

            return found;
        }

        override protected function visitGroup(group:GroupModel):void
        {
            if (!found)
            {
                var unmarkedCell:CellModel;
                var unmarkedCount:int = 0;

                // Look for exactly one unmarked cell in this group.
                for (var i:int = 0; i < group.cells.length; ++i)
                {
                    var cell:CellModel = group.cells[i];
                    if (cell.number == 0 && cell.stuff == null)
                    {
                        unmarkedCell = cell;
                        ++unmarkedCount;
                    }
                }

                if (unmarkedCount == 1)
                {
                    unmarkedCell.number = number;
                    unmarkedCell.annotation = number + " fits nowhere else within this " + group.type + ".";
                    found = true;
                }
            }
        }
    }
}
