/**
 */

package net.ech.puzzle
{
    /**
     * Enumeration of general game control states.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class States
    {
        /**
         * The puzzle is in its original state.
         */
        public static const CLEAR:int = 0;

        /**
         * There is work in progress.
         */
        public static const WORKING:int = 1;

        /**
         * Puzzle is solved.
         */
        public static const SOLVED:int = 2;
    }
}
