package net.ech.sudoku
{
    public class SudokuMethod
    {
        // Puzzle state commands
        public static const INITIATE_PUZZLE_LOAD:String = "initiatePuzzleLoad";
        public static const LOAD_PUZZLE:String = "loadPuzzle";
        public static const INITIATE_PUZZLE_ENTRY:String = "initiatePuzzleEntry";
        public static const COMPLETE_PUZZLE_ENTRY:String = "completePuzzleEntry";
        public static const CANCEL_PUZZLE_ENTRY:String = "cancelPuzzleEntry";

        // Input commands.
        public static const SELECT_CELL:String = "selectCell";
        public static const MODIFY_CELL:String = "modifyCell";

        // Hint commands.
        public static const FIND_NEXT_MOVE:String = "findNextMove";
        public static const EXPLAIN_NEXT_MOVE:String = "explainNextMove";

        // Informational commands.
        public static const ABOUT_SOFTWARE:String = "aboutSoftware";
        public static const ABOUT_SUDOKU:String = "aboutSudoku";
        public static const INSTRUCTIONS:String = "instructions";
    }
}

