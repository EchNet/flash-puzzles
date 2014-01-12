package net.ech.sudoku
{
    import flash.net.SharedObject;

    /**
     * A PuzzleService maintains puzzle state and provides very simple
     * application state persistence, based on SharedObject.
     */
    public class PuzzleService
    {
        public static const VERSION:String = "1.0";

        private var _model:PuzzleModel;
        private var _so:SharedObject;

        /**
         * Some name for this application.  Is the key to the local
         * SharedObject.
         */
        public var applicationName:String;

        /**
         * Get the read-only puzzle state.
         */
        public function get puzzleState():IPuzzleState
        {
            return _model;
        }

        /**
         * Initialize the model from persistent storage.
         */
        public function initialize():void
        {
            _model = new PuzzleModel();
            _so = SharedObject.getLocal(applicationName);

            if (_so.data == null)
            {
                throw new Error("no SharedObject?");
            }

            var version:String = _so.data.version;
            if (version == VERSION)
            {
                _model.restoreState(_so.data.state);
            }
        }

        /**
         * Replace the puzzle with a blank one.
         */
        public function clearPuzzle():void
        {
            _model.clear();
            save();
        }

        /**
         * Restore the original given state of this puzzle, discarding
         * all work in progress.
         */
        public function revertPuzzle():void
        {
            _model.revert();
            save();
        }

        /**
         * Commit a new starting puzzle to this document.  This
         * has the side effect of discarding any work in progress.
         * @param input an Array of Strings, representing cell values in
         *              row-major order.  An empty String value represents
         *              an empty cell.
         * @throw Error if input is null, wrong size, or contains illegal
         *              value
         */
        public function resetPuzzle(input:Array):void
        {
            _model.reset(input);
            save();
        }

        /**
         * Write the current model out to persistent storage.
         */
        private function save():void
        {
            _so.data.version = VERSION;
            _so.data.state = _model.getState();
            _so.flush();
        }
    }
}
