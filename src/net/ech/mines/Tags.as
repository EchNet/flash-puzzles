/**
 */

package net.ech.mines
{
    /**
     * Enumeration of tag values, each of which identifies a unique visual
     * state of a cell in the grid.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Tags
    {
        /**
         * Covered, no tag.
         */
        public static const NULL:int = 0;

        /**
         * Covered, flagged.
         */
        public static const FLAG:int = 1;

        /**
         * Covered, marked '?'.
         */
        public static const QUES:int = 2;

        /**
         * Exposed, mined.
         */
        public static const BOOM:int = 3;

        /**
         * Auto-exposed, mined.
         */
        public static const MINE:int = 4;

        /**
         * Auto-exposed, wrongly flagged.
         */
        public static const OOPS:int = 5;

        /**
         * Exposed, no adjacent mines.
         */
        public static const ZERO:int = 6;

        /**
         * Exposed, 1 adjacent mine.
         */
        public static const ONE:int  = 7;

        /**
         * Exposed, 2 adjacent mines.
         */
        public static const TWO:int  = 8; 

        /**
         * Exposed, 3 adjacent mines.
         */
        public static const THREE:int = 9;

        /**
         * Exposed, 4 adjacent mines.
         */
        public static const FOUR:int = 10;

        /**
         * Exposed, 5 adjacent mines.
         */
        public static const FIVE:int = 11;

        /**
         * Exposed, 6 adjacent mines.
         */
        public static const SIX:int  = 12;

        /**
         * Exposed, 7 adjacent mines.
         */
        public static const SEVEN:int = 13;

        /**
         * Exposed, 8 adjacent mines.
         */
        public static const EIGHT:int = 14;

        /**
         * Number of tags.
         */
        public static const NVALUES:int = 15;

        /**
         * Some tags indicate an exposed cell, some do not.
         * @param tag value
         * @return true if the tag value indicates and exposed cell
         */
        public static function isExposed(tag:int):Boolean
        {
            return tag >= BOOM;
        }
    }
}
