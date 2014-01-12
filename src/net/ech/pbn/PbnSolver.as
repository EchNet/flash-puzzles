package
{
    import flash.events.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import mx.core.Container;
    import mx.core.Application;
    import mx.managers.PopUpManager;

    public class PbnSolver
    {
        private var _controller:PbnController;

        // Rotating solver state:
        public var solvingColumns:Boolean;
        public var solvingIndex:int;

        // For memory efficiency:
        private var _microSolver:MicroSolver;
        private var _rowScratch:Array;
        private var _columnScratch:Array;

        public function PbnSolver(controller:PbnController)
        {
            _controller = controller;
        }

        public function init():void
        {
            solvingColumns = false;
            solvingIndex = -1;
            advance();

            _microSolver = new MicroSolver();
            _rowScratch = new Array(_controller.model.rowLength);
            _columnScratch = new Array(_controller.model.columnLength);
        }

        public function solveNext():void
        {
            var model:PbnModel = _controller.model;

            if (solvingColumns)
            {
                _microSolver.input = model.columnInputs[solvingIndex];
                _microSolver.scratch = model.copyColumn(solvingIndex, _columnScratch);
            }
            else
            {
                _microSolver.input = model.rowInputs[solvingIndex];
                _microSolver.scratch = model.copyRow(solvingIndex, _rowScratch);
            }

            _microSolver.solve();

            if (solvingColumns)
            {
                model.applyColumn(solvingIndex, _microSolver.scratch);
                _controller.view.refreshColumn(solvingIndex);
            }
            else
            {
                model.applyRow(solvingIndex, _microSolver.scratch);
                _controller.view.refreshRow(solvingIndex);
            }

            advance();
        }

        /**
         * Move to the next solving position.  If there is no next solving
         * position (i.e., the puzzle is already solved or unsolvable), 
         * mark the model so.
         */
        private function advance():void
        {
            var model:PbnModel = _controller.model;

            model.checkFinished();

            if (model.state != PbnModel.FINISHED_STATE)
            {
                if (solvingIndex == -1)
                {
                    solvingIndex = 0;
                }
                else
                {
                    bump();
                }

                var advanced:Boolean = false;
                var startSolvingColumns:Boolean = solvingColumns;
                var startSolvingIndex:int = solvingIndex;

                // Find a dirty row/column to work on.
                while (!dirtyHere())
                {
                    bump();

                    if (solvingIndex == startSolvingIndex &&
                        solvingColumns == startSolvingColumns)
                    {
                        // Went all the way around without finding a place to
                        // work.
                        model.state = PbnModel.HOPELESS_STATE;
                        break;
                    }
                }
            }

            if (model.state != PbnModel.WORKING_STATE)
            {
                // Hide the dot.
                solvingIndex = -1;
            }
        }

        private function dirtyHere():Boolean
        {
            var model:PbnModel = _controller.model;
            var dirtyArray:Array =
                solvingColumns ? model.columnDirty : model.rowDirty;
            return dirtyArray[solvingIndex];
        }

        private function bump():void
        {
            var model:PbnModel = _controller.model;
            var indexLimit:int =
                solvingColumns ? model.columnCount : model.rowCount;

            ++solvingIndex;
            if (solvingIndex >= indexLimit)
            {
                solvingIndex = 0;
                solvingColumns = !solvingColumns;
            }
        }
    }
}
