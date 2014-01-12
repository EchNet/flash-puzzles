package net.ech.sudoku.solver
{
    public class EmptyCellCounter extends Visitor
    {
        private var theCount:int;

        public function EmptyCellCounter(grid:SolutionModel)
        {
            super(grid);
        }

        public function count():int
        {
            theCount = 0;
            walkCells();
            return theCount;
        }

        override protected function visitCell(cell:CellModel):void
        {
            if (cell.number == 0)
            {
                ++theCount;
            }
        }
    }
}
