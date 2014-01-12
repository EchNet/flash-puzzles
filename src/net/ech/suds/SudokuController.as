package net.ech.sudoku
{
    import flash.events.EventDispatcher;
    import mx.controls.Alert;
    import net.ech.ui.DialogBuilder;

    /**
     * The Sudoku Trainer application control module.
     */
    public class SudokuController extends EventDispatcher
    {
        /**
         * A reference to the display model.  Must be supplied by caller.
         */
        public var model:SudokuModel;

        /**
         * A reference to the PuzzleService.  Must be supplied by caller.
         */
        public var puzzleService:PuzzleService;

        /**
         * A reference to the current DialogBuilder.  Null if no
         * dialog is showing.
         */
        private var _dialogBuilder:DialogBuilder;

        /**
         * Start up the application.
         */
        public function initialize():void
        {
            // Load the working puzzle synchronously.
            puzzleService.initialize();

            // Show the working puzzle.
            presentPuzzle();

            showStartupHint();
        }

        /**
         * Process a loaded puzzle coming in from the puzzle loader.
         */
        public function loadPuzzle(puzzleStr:String):void
        {
            confirm (isSolutionInProgress(),
                     "Accept a new puzzle?",
                     "If you accept this new puzzle, the puzzle you have been working on will be discarded.  Ts that OK?",
                     "Yes, start the new puzzle",
                     "No, cancel that",
                     function ():void
                     {
                        acceptLoadedPuzzle(puzzleStr);
                     });
        }

        /**
         * Process a user request to switch the application into puzzle
         * entry mode.
         */
        public function initiatePuzzleEntry():void
        {
            if (model.state != SudokuState.ENTRY)
            {
                // Show that the UI is in full entry mode.
                model.state = SudokuState.ENTRY;
                model.enableAllInputs();
            }
        }

        /**
         * Process a request to modify a cell value.
         */
        public function changeValue(value:String, cell:CellModel):void
        {
            if (model.state == SudokuState.ENTRY)
            {
                switch (value)
                {
                case '1': case '2': case '3': case '4': case '5':
                case '6': case '7': case '8': case '9':
                    cell.input = value;
                    break;
                case ' ': case '':
                    cell.input = CellModel.EMPTY_INPUT;
                    break;
                }
            }
        }

        /**
         * Process a request to reset the puzzle to the input configuration.
         */
        public function completePuzzleEntry():void
        {
            // Get the current input values in the form that the
            // PuzzleService expects.
            //
            applyInputsIfValid(model.getInputs());
        }

        /**
         * Process a request to cancel puzzle entry mode and restore the
         * previously displayed state.
         */
        public function cancelPuzzleEntry():void
        {
            model.state = SudokuState.WORKING;
            presentPuzzle();
        }

        private function showStartupHint():void
        {
            if (puzzleService.puzzleState.empty)
            {
                _dialogBuilder = new DialogBuilder ();
                _dialogBuilder.title = "Welcome to Sudoku Trainer";
                _dialogBuilder.text = "To start a puzzle, choose \"Load Puzzle\" or \"Key In New Puzzle\" from the File menu.  To read about Sudoku Trainer first, choose one of the Help menu options.",
                _dialogBuilder.addOption ("OK", dismissDialog);
                _dialogBuilder.show();
            }
        }

        /**
         * Take new puzzle data.
         */
        private function acceptLoadedPuzzle(puzzleStr:String):void
        {
            var inputs:Array = new Array();
            for (var i:int = 0; i < puzzleStr.length; ++i)
            {
                inputs.push (puzzleStr.charAt(i));
            }

            applyInputsIfValid(inputs);
        }

        /**
         * Return true if the user has done any work on the current
         * puzzle.
         */
        private function isSolutionInProgress():Boolean
        {
            for (var r:int = 0; r < SudokuRules.N_ROWS; ++r)
            {
                for (var c:int = 0; c < SudokuRules.N_COLUMNS; ++c)
                {
                    var number:String = puzzleService.puzzleState.getNumber(r, c);
                    var given:Boolean = puzzleService.puzzleState.getGiven(r, c);
                    if (number != " " && !given)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        private function confirm(gateCondition:Boolean,
                                 title:String,
                                 text:String,
                                 yesLabel:String,
                                 noLabel:String,
                                 func:Function):void
        {
            if (gateCondition)
            {
                dismissDialog();

                _dialogBuilder = new DialogBuilder ();
                _dialogBuilder.title = title;
                _dialogBuilder.text = text;
                _dialogBuilder.addOption (yesLabel, function ():void {
                    _dialogBuilder.dialog.callLater (func);
                    dismissDialog();
                });

                _dialogBuilder.addOption (noLabel, dismissDialog);

                _dialogBuilder.show();
            }
            else
            {
                func();
            }
        }

        private function dismissDialog():void
        {
            if (_dialogBuilder != null)
            {
                _dialogBuilder.dismiss();
                _dialogBuilder = null;
            }
        }

        /**
         * Validate current inputs.  If not valid, display the error(s).
         * If valid, start up the puzzle.
         */
        private function applyInputsIfValid(inputs:Array):void
        {
            // TODO: input validation.

            puzzleService.resetPuzzle(inputs);
            model.state = SudokuState.WORKING;
            presentPuzzle();
            //model.clearInputs();
        }

        /**
         * Modify the display state to reflect the current puzzle as
         * known by the PuzzleService.  This has the side effect of
         * discarding all cell annotations.
         */
        private function presentPuzzle():void
        {
            var anyGiven:Boolean = false;

            for (var i:int = 0; i < SudokuRules.N_CELLS; ++i)
            {
                var r:int = i / SudokuRules.N_COLUMNS;
                var c:int = i % SudokuRules.N_COLUMNS;

                var number:String = puzzleService.puzzleState.getNumber(r, c);
                var given:Boolean = puzzleService.puzzleState.getGiven(r, c);

                var cell:CellModel = model.cells[i];
                cell.number = number;
                cell.state = given ? CellStates.GIVEN : CellStates.WORKING;
                cell.annotation = null;

                anyGiven = anyGiven || given;
            }

            model.state = anyGiven ? SudokuState.WORKING : SudokuState.DEAD;
        }
    }
}
