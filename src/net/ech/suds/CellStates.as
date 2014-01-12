package net.ech.sudoku
{
    /**
     * Enumeration of the various sudoku cell states.  Cell state
     * determines appearance and behavior.
     */
    public class CellStates
    {
        /**
         * This cell is empty or in initial, "don't care" state.
         */
        public static const NEUTRAL:String = "neutral";

        /**
         * This cell displays a number that is part of the puzzle, not
         * part of the solution.
         */
        public static const GIVEN:String = "given"

        /**
         * This cell is empty or shows a number that is part of the working
         * solution.
         */
        public static const WORKING:String = "working";

        /**
         * This cell is currently accepting user input.  It may or
         * may not have focus.
         */
        public static const INPUT:String = "input";
    }
}
