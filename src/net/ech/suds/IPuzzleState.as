
package net.ech.sudoku
{
    /**
     * IPuzzleState provides read-only access to the core state of a
     * working puzzle.
     */
    public interface IPuzzleState
    {
        /**
         * Return true if there is no puzzle.
         */
        function get empty():Boolean;

        /**
         * Get the character that appears in the indexed cell.
         * @return a value in " 123456789"
         */
        function getNumber(rowIndex:int, columnIndex:int):String;

        /**
         * Tell whether the number that appears in the indexed cell is
         * part of the puzzle or part of the working solution.
         * @return true if the number is part of the puzzle, false if
         * there is no number in the indexed cell or if the number is
         * part of the working solution.
         */
        function getGiven(rowIndex:int, columnIndex:int):Boolean;
    }
}
