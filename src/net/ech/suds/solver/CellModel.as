package net.ech.sudoku.solver
{
    /**
     * Display state of a Sudoku cell.
     */
    public class CellModel
    {
        [Bindable]
        /**
         * Reference to the row of which this cell is a member.
         */
        public var row:GroupModel;

        [Bindable]
        /**
         * Reference to the column of which this cell is a member.
         */
        public var column:GroupModel;

        [Bindable]
        /**
         * Reference to the square of which this cell is a member.
         */
        public var square:GroupModel;

        [Bindable]
        /**
         * The number this cell contains.  If cell is empty, this is zero.
         * Otherwise, valid values are in [1..9].
         */
        public var number:int;

        [Bindable]
        /**
         * True if the number is defined and is part of the puzzle, not part
         * of the solution.
         */
        public var given:Boolean;

        [Bindable]
        /**
         * Any message about this cell the solver wishes to display to the user.
         */
        public var annotation:String;

        [Bindable]
        /**
         * Amorphous blob for the solver to use.
         */
        public var stuff:Object;

        [Bindable]
        /**
         * Place to store input text, for puzzle entry.
         */
        public var input:String;

        /**
         * Constructor.
         */
        public function CellModel()
        {
            clear();
        }

        /**
         * Clear the number and all information related to solution.
         */
        public function clear():void
        {
            number = undefined;
            given = false;
            clearLastStep();
        }

        /**
         * Clear all information related to solution.  If the number is not
         * part of the puzzle, this includes the number.
         */
        public function clearSolution():void
        {
            if (!given)
            {
                number = undefined;
            }
            clearLastStep();
        }

        /**
         * Clear all information related to the last solution step.
         */
        public function clearLastStep():void
        {
            annotation = undefined;
            stuff = undefined;
        }
    }
}
