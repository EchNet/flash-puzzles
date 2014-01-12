
package net.ech.sudoku
{
    /**
     * PuzzleModel is the Sudoku document model.  It holds the persistent
     * state of a working puzzle.
     */
    public class PuzzleModel implements IPuzzleState
    {
        /**
         * This String represents the initial state of the puzzle.
         * Each character of this String represents a cell of the puzzle,
         * in row-major order.  Valid character values are 1..9, to represent
         * a number, or space, to represent an empty cell. 
         */
        private var given:String;

        /**
         * This String represents work on the puzzle in progress.
         * The encoding is the same as for the "given" String.
         */
        private var working:String;

        /**
         * Constructor.
         */
        public function PuzzleModel()
        {
            clear();
        }

        /**
         * Return true if this model is completely empty, indicating
         * that no saved model has been restored to it.
         */
        public function get empty():Boolean
        {
            return given == null;
        }

        /**
         * Get this document in raw form for persistence.
         */
        public function getState():Object
        {
            return given + working;
        }

        /**
         * Restore a saved document.
         */
        public function restoreState(state:Object):void
        {
            given = String(state).substr(0, SudokuRules.N_CELLS);
            working = String(state).substr(SudokuRules.N_CELLS, SudokuRules.N_CELLS);
        }

        /**
         * Replace the puzzle with a completely empty one.
         */
        public function clear():void
        {
            given = "";
            for (var i:int = 0; i < SudokuRules.N_CELLS; ++i)
            {
                given += " ";
            }
            revert();
        }

        /**
         * Restore the original given state of this puzzle, discarding
         * all work in progress.
         */
        public function revert():void
        {
            // Working state gets a copy of the starting puzzle.
            working = new String(given);
        }

        /**
         * Commit a new starting puzzle to this document.  This
         * has the side effect of discarding any work in progress.
         * @param input an Array of Strings, representing cell values in
         *              row-major order.  An empty String value represents
         *              an empty cell.
         * @throw Error if input is null, wrong size, or contains illegal
         *              value
         */
        public function reset(input:Array):void
        {
            given = "";
            for (var i:int = 0; i < SudokuRules.N_CELLS; ++i)
            {
                var str:String = input[i];
                if (str.length == 1 && "123456789".indexOf(str) >= 0)
                {
                    given += str;
                }
                else
                {
                    given += " ";
                }
            }
            revert();
        }

        /**
         * Get the character that appears in the indexed cell.
         * @return a value in " 123456789"
         */
        public function getNumber(rowIndex:int, columnIndex:int):String
        {
            return working.charAt(rowColumnToIndex(rowIndex, columnIndex));
        }

        /**
         * Tell whether the number that appears in the indexed cell is
         * part of the puzzle or part of the working solution.
         * @return true if the number is part of the puzzle, false if
         * there is no number in the indexed cell or if the number is
         * part of the working solution.
         */
        public function getGiven(rowIndex:int, columnIndex:int):Boolean
        {
            return given.charAt(rowColumnToIndex(rowIndex, columnIndex)) != ' ';
        }

        private function rowColumnToIndex(rowIndex:int, columnIndex:int):int
        {
            SudokuRules.assertValidRowIndex(rowIndex);
            SudokuRules.assertValidColumnIndex(columnIndex);

            return (rowIndex * SudokuRules.N_CELLS_PER_GROUP) + columnIndex;
        }
    }
}
