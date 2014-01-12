package net.ech.sudoku.solver
{
    /**
     * Slicing is the technique of looking at a number and examining each group
     * to find a single cell in the group that number could occupy.
     */
    public class SliceMarker extends Visitor
    {
        private var number:int;

        public function SliceMarker(grid:SolutionModel, number:int)
        {
            super(grid);
            this.number = number;
        }

        public function mark():void
        {
            walkCells();
        }

        override protected function visitCell(cell:CellModel):void
        {
            // If the number appears in this cell, mark every cell in the
            // same group.
            if (cell.number == number)
            {
                markGroup(cell.row);
                markGroup(cell.column);
                markGroup(cell.square);
            }
        }

        private function markGroup(group:GroupModel):void
        {
            for (var i:int = 0; i < group.cells.length; ++i)
            {
                group.cells[i].stuff = "";
            }
        }
    }
}
