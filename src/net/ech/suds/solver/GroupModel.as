package net.ech.sudoku.solver
{
    /**
     * Description of a Sudoku row, column or cell: its position in the grid
     * and the cells it contains.
     */
    public class GroupModel
    {
        [Bindable]
        /**
         * "row", "column" or "square"
         */
        public var type:String;

        [Bindable]
        /**
         * The ordinal position of this row, column or square.
         */
        public var ordinal:int;

        [Bindable]
        /**
         * The cells this group contains.
         */
        public var cells:Array;

        [Bindable]
        /**
         * Reference back to the containing grid.
         */
        public var grid:SolutionModel;

        /**
         * Constructor.
         */
        public function GroupModel()
        {
            cells = new Array();
        }
    }
}
