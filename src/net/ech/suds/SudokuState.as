package net.ech.sudoku
{
    /**
     * Enumeration of application states for Sudoku Trainer.
     */
    public class SudokuState
    {
        /**
         * No current puzzle.  The user can either load a puzzle or
         * key one in.
         */
        public static const DEAD:String = "";

        /**
         * The user is keying in a puzzle.
         */
        public static const ENTRY:String = "input mode";

        /**
         * A puzzle is loading.
         */
        public static const LOADING:String = "loading";

        /**
         * The user is working on a puzzle.
         */
        public static const WORKING:String = "solving";
    }
}

