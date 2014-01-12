
package net.ech.sudoku
{
    import flash.events.EventDispatcher;
    import mx.collections.ArrayCollection;

    /**
     * Sudoku display model.
     */
    public class SudokuModel extends EventDispatcher
    {
        [Bindable]
        /**
         * This is an array of 81 CellModels, representing the grid of
         * cells in row major order.
         */
        public var cells:ArrayCollection;

        [Bindable]
        /**
         * A status string to display.
         */
        public var state:String;

        /**
         * Constructor.
         */
        public function SudokuModel()
        {
            cells = new ArrayCollection ();

            for (var i:int = 0; i < SudokuRules.N_CELLS; ++i)
            {
                cells.addItem (new CellModel());
            }
        }

        /**
         * Put all cells into input state.
         */
        public function enableAllInputs():void
        {
            for (var i:int = 0; i < cells.length; ++i)
            {
                var cell:CellModel = cells[i];
                cell.number = cell.input;
                cell.state = CellStates.INPUT;
            }
        }

        /**
         * Get the current input values in the form that the PuzzleService
         * expects.
         */
        public function getInputs():Array
        {
            var inputs:Array = new Array();

            for (var i:int = 0; i < cells.length; ++i)
            {
                inputs.push(cells[i].input);
            }

            return inputs;
        }

        /**
         * Clear all cell inputs.
         */
        public function clearInputs():void
        {
            for (var i:int = 0; i < cells.length; ++i)
            {
                cells[i].input = CellModel.EMPTY_INPUT;
            }
        }
    }
}
