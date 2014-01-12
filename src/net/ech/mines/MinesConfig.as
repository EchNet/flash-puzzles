/** */

package net.ech.mines
{
    /**
     * Configurable properties of a Minesweeper puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class MinesConfig
    {
        [Bindable]
        /**
         * Number of rows.
         */
        public var rows:int;

        [Bindable]
        /**
         * Number of columns.
         */
        public var columns:int;

        [Bindable]
        /**
         * Number of buried mines.
         */
        public var nmines:int;

        /**
         * Constructor.
         */
        public function MinesConfig (rows:int = 8, columns:int = 8, nmines:int = 1)
        {
            this.rows = rows;
            this.columns = columns;
            this.nmines = nmines;
        }
    }
}
