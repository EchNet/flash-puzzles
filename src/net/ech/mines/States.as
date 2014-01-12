/**
 */

package net.ech.mines
{
    /**
     * Enumeration of general game control states.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class States
    {
        /**
         * Waiting for game to start.
         */
        public static const READY:int = 0;

        /**
         * Game in progress.
         */
        public static const RUNNING:int = 1;

        /**
         * Player lost.
         */
        public static const LOST:int = 2;

        /**
         * Player won.
         */
        public static const WON:int = 3;

        /**
         * Number of values.
         */
        public static const NVALS:int = 4;
    }
}
