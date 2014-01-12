package net.ech.sudoku.solver
{
    public class BoardValidator extends Visitor
    {
        private static var MIN_TO_START:int = 12;

        public var errors:Array;

        private var numberCount:int;

        public function BoardValidator(grid:SolutionModel)
        {
            super(grid);
            errors = new Array();
        }

        public function validate():Boolean
        {
            errors = new Array();
            numberCount = 0;

            // No number may appear twice within any group.
            walkGroups();

            // All numbers are in valid range.
            walkCells();

            // Number of filled cells is greater than the minimum.
            if (numberCount < MIN_TO_START)
            {
                validationError("There are not enough numbers supplied to solve.");
            }

            return errors.length == 0;
        }

        /**
         * Validate that no dupes appear in each group.
         */
        override protected function visitGroup(group:GroupModel):void
        {
            var counts:Array = [ null, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];

            var i:int;
            for (i = 0; i < group.cells.length; ++i)
            {
                var number:int = CellModel(group.cells[i]).number;
                if (number != 0)
                {
                    counts[number] += 1;
                }
            }

            for (i = 1; i < 9; ++i)
            {
                if (counts[i] > 1)
                {
                    validationError("The number " + i + " appears more than once in the same " + group.type + ".");
                }
            }
        }

        /**
         * Validate that each number is in valid range, and count them up.
         */
        override protected function visitCell(cell:CellModel):void
        {
            if (cell.number != 0)
            {
                var n:int = cell.number as int;
                if (isNaN(n) || n < 1 || n > 9)
                {
                    validationError(cell.number + " is not a valid number.");
                }

                ++numberCount;
            }
        }

        private function validationError(msg:String):void
        {
            errors.addItem(msg);
        }
    }
}
