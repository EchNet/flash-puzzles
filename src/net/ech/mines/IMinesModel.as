/**
 */

package net.ech.mines
{
    import flash.events.IEventDispatcher;

    /**
     * Event dispatched to inform the listener of a change to one of the
     * following properties:
     * <li>state</li>
     * <li>elapsedSeconds</li>
     * <li>flagCount</li>
     * <li>cell</li>
     * In all cases, <code>event.data.property</code> identifies
     * the property that has changed.  In the case of <code>cell</code>, 
     * <code>event.data.row</code> and <code>event.data.column</code>
     * identify the changing cell.
     */
    [Event(name="stateChange", type="net.ech.events.VEvent")]

    /**
     * Visible application state of a Minesweeper puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public interface IMinesModel
        extends IEventDispatcher
    {
        /**
         * Number of rows.  Configuration constant.
         */
        function get rows():int;

        /**
         * Number of columns.  Configuration constant.
         */
        function get columns():int;

        /**
         * Number of mines.  Configuration constant.
         */
        function get nmines():int;

        /**
         * User options.  May change during play.
         */
        function get options():MinesOptions;

        /**
         * General puzzle state indicator.
         *
         * @see net.ech.mines.States
         */
        function get state():int;

        /**
         * Number of seconds elapsed since start of play.
         */
        function get elapsedSeconds():int;

        /**
         * Number of flags placed.
         */
        function get flagCount():int;

        /**
         * Get a value that describes the specified grid cell. 
         */
        function getTagAt(row:int, column:int):int;
    }
}
