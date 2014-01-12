package net.ech.sudoku
{
    import flash.events.EventDispatcher;

    /**
     * Display state of a Sudoku cell.
     */
    public class CellModel extends EventDispatcher
    {
        public static const EMPTY_INPUT:String = "";

        [Bindable]
        /**
         * The value to display in this cell.
         */
        public var number:String = " ";

        [Bindable]
        /**
         * The cell state, per {@link net.ech.sudoku.CellStates}.
         */
        public var state:String = CellStates.NEUTRAL;

        [Bindable]
        /**
         * Any message about this cell the solver wishes to display to the user.
         */
        public var annotation:String;

        [Bindable]
        /**
         * Each cell also functions as an input field. 
         * Here is a place to store input text.
         */
        public var input:String = EMPTY_INPUT;
    }
}
