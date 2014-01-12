package net.ech.sudoku.solver
{
    /**
     * This technique visits each empty cell and asks what numbers could
     * fit there, excluding any number that already appears in the same
     * group.  If there is only one possibility, it is the answer.
     */
    public class Exclusion extends Technique
    {
        private var found:Boolean;
        private var considerSquares:Boolean;
        private var considerRows:Boolean;
        private var considerColumns:Boolean;
        private var scratch:Array;

        public function Exclusion(grid:SolutionModel, considerSquares:Boolean,
                                  considerRows:Boolean, considerColumns:Boolean)
        {
            super(grid);
            this.considerSquares = considerSquares;
            this.considerRows = considerRows;
            this.considerColumns = considerColumns;
            scratch = new Array(10);

            level = 0;
            if (considerSquares) level += 1;
            if (considerRows) level += 1;
            if (considerColumns) level += 1;
        }

        override public function find():Boolean
        {
            found = false;
            walkCells();
            return found;
        }

        override protected function visitCell(cell:CellModel):void
        {
            if (!found)
            {
                if (cell.number == 0)
                {
                    clearScratch();
                    if (considerRows)
                    {
                        populateScratch(cell.row);
                    }
                    if (considerColumns)
                    {
                        populateScratch(cell.column);
                    }
                    if (considerSquares)
                    {
                        populateScratch(cell.square);
                    }
                    var n:int = findJustOne();
                    if (n != 0)
                    {
                        cell.number = n;
                        cell.annotation = "Only " + n + " can fit here.";
                        found = true;
                    }
                }
            }
        }

        private function clearScratch():void
        {
            for (var i:int = 0; i < scratch.length; ++i)
            {
                scratch[i] = null;
            }
        }

        private function populateScratch(group:GroupModel):void
        {
            for (var i:int = 0; i < group.cells.length; ++i)
            {
                var cell:CellModel = CellModel(group.cells[i]);
                if (cell.number != 0)
                {
                    scratch[cell.number] = "!";
                }
            }
        }

        private function findJustOne():int
        {
            var n:int = 0;
            for (var i:int = 1; i < scratch.length; ++i)
            {
                if (scratch[i] == undefined)
                {
                    if (n == 0)
                    {
                        n = i;
                    }
                    else
                    {
                        return 0;
                    }
                }
            }
            return n;
        }
    }
}
