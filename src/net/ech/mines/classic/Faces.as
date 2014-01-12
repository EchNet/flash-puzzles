/**
 */

package net.ech.mines.classic
{
    /**
     * Enumeration of states of the smiley face shown at the top of the view.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Faces
    {
        /**
         * Waiting for user input.
         */
        public static const HAPPY:uint = 0;

        /**
         * User is about to uncover a cell.
         */
        public static const SCARED:uint = 1;

        /**
         * Player lost.
         */
        public static const DEAD:uint = 2;

        /**
         * Player won.
         */
        public static const COOL:uint = 3;

        /**
         * Number of different faces.
         */
        public static const NVALUES:uint = 4;
    }
}
