/**
 *
 */

package net.ech.mines
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    import net.ech.util.Grid;

    /**
     * Application controller for Minesweeper puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class MinesController
    {
        private var _model:MinesModel;
        private var _startTime:uint = 0;
        private var _timer:Timer;

        /**
         * The model.  Caller must set this before starting application.
         */
        public function set model(model:MinesModel):void
        {
            _model = model;
        }

        /**
         * User has edited the puzzle options.  Apply the changes.
         */
        public function applyOptions(options:MinesOptions):void
        {
            _model.setOptions(options.copy());
            // No side effects, currently.
        }

        /**
         * What to do when the user clicks the "restart" button.
         */
        public function restart():void
        {
            if (_model.state != States.READY)
            {
                _model.restart();
            }
        }

        /**
         * Rotate the tag at the indexed location.
         */
        public function rotateTag(row:int, column:int):void
        {
            switch (_model.state)
            {
            case States.READY:
            case States.RUNNING:
                var tag:int = _model.getTagAt(row, column);

                switch (tag)
                {
                case Tags.NULL:
                    tag = Tags.FLAG;
                    _model.setFlagCount(_model.flagCount + 1);
                    break;
                case Tags.FLAG:
                    tag = _model.options.marksQ ? Tags.QUES : Tags.NULL;
                    _model.setFlagCount(_model.flagCount - 1);
                    break;
                case Tags.QUES:
                    tag = Tags.NULL;
                    break;
                }

                _model.setTagAt(row, column, tag);
                break;
            }
        }

        /**
         * Expose the cell at the indexed location.
         */
        public function expose(row:int, column:int):void
        {
            var grid:Grid = _model.getGrid();

            if (_model.state == States.READY)
            {
                // Lay mines, one at a time.
                var nUnminedCells:int = _model.rows * _model.columns;
                for (var i:int = 0; i < _model.nmines; ++i)
                {
                    layOneMine (nUnminedCells);
                    --nUnminedCells;
                }

                startTimer();

                // Don't allow the first exposed cell to be mined.
                if (grid.getCellAt(row, column).mined)
                {
                    // Move that mine somewhere else.
                    layOneMine(nUnminedCells);
                    grid.getCellAt(row, column).mined = false;
                }
            }

            if (_model.state == States.RUNNING)
            {
                switch (grid.getCellAt(row, column).tag)
                {
                case Tags.NULL:
                case Tags.QUES:
                    if (grid.getCellAt(row, column).mined)
                    {
                        _model.setTagAt(row, column, Tags.BOOM);
                        showLoss();
                    }
                    else
                    {
                        rippleExpose(row, column);
                        checkWin();
                    }
                }
            }
        }

        /**
         * Clear all the untagged cells around the given location.
         */
        public function clearAround(row:int, column:int):void
        {
            var grid:Grid = _model.getGrid();
            var tag:int = grid.getCellAt(row, column).tag;
            if (tag <= Tags.ZERO)
                return;

            var nAdjMines:int = tag - Tags.ZERO;
            var nAdjFlags:int = 0;

            grid.visitAdjacent(row, column, function(r:int, c:int, value:Object):void
            {
                if (value.tag == Tags.FLAG)
                {
                    ++nAdjFlags;
                }
            });

            if (nAdjFlags != nAdjMines)
                return;

            var lost:Boolean = false;

            grid.visitAdjacent(row, column, function(r:int, c:int, value:Object):void
            {
                switch (value.tag)
                {
                case Tags.NULL:
                case Tags.QUES:
                    if (value.mined)
                    {
                        _model.setTagAt(r, c, Tags.BOOM);
                        lost = true;
                    }
                    else
                    {
                        rippleExpose(r, c);
                    }
                }
            });

            if (lost)
            {
                showLoss ();
            }
            else 
            {
                checkWin ();
            }
        }

        /**
         * @private
         */
        private function startTimer():void
        {
            _startTime = getTimer();
            _model.setState(States.RUNNING);
            _model.setElapsedSeconds(1);  // start with one second on the clock!
            _timer = new Timer(500);
            _timer.addEventListener(TimerEvent.TIMER, handleTimer);
            _timer.start();
        }

        /**
         * @private
         */
        private function stopTimer():void
        {
            if (_timer != null)
            {
                _timer.stop();
                _timer = null;
            }
        }

        /**
         * What to do periodically.
         */
        private function handleTimer(event:Event):void
        {
            if (_model != null && _model.state == States.RUNNING)
            {
                _model.setElapsedSeconds(int((getTimer() - _startTime) / 1000) + 1);
            }
            else
            {
                stopTimer();
            }
        }

        /**
         * Create a new set of tags, initially clear.
         */
        private function makeClearTags(rows:int, columns:int):Array
        {
            var array:Array = new Array(rows * columns);

            for (var i:int = rows * columns; --i >= 0; )
            {
                array[i] = Tags.NULL;
            }

            return array;
        }

        /**
         * Create a new minefield, initially clear.
         */
        private function makeClearMines(rows:int, columns:int):Array
        {
            var array:Array = new Array(rows * columns);

            for (var i:int = rows * columns; --i >= 0; )
            {
                array[i] = false;
            }

            return array;
        }

        /**
         * Lay a mine somewhere.  Number of unmined cells is provided so
         * that a recount is unnecessary.
         */
        private function layOneMine(nUnminedCells:int):void
        {
            var grid:Grid = _model.getGrid();

            // Randomly select from among available cells.
            var pos:int = int(Math.random() * nUnminedCells);

            //
            // Go find that cell and mine it.
            //
            grid.visitAll(function(r:int, c:int, value:Object):void
            {
                if (!value.mined)
                {
                    if (pos-- == 0)
                    {
                        value.mined = true; 
                    }
                }
            });
        }

        /**
         * Expose the indicated cell, and if the cell has no adjacent mines,
         * all of the adjacent cells as well.  Recursively.
         */
        private function rippleExpose(row:int, column:int):void
        {
            var nAdjMines:int = countAdjacentMines(row, column);
            _model.setTagAt (row, column, Tags.ZERO + nAdjMines);

            if (nAdjMines == 0)
            {
                _model.getGrid().visitAdjacent(row, column, function(r:int, c:int, value:Object):void
                {
                    switch (value.tag)
                    {
                    case Tags.NULL:
                    case Tags.QUES:
                        rippleExpose (r, c);
                        break;
                    }
                });
            }
        }

        /**
         * Self-explanatory.
         */
        private function countAdjacentMines (row:int, column:int):int
        {
            var count:int = 0;

            _model.getGrid().visitAdjacent(row, column, function(r:int, c:int, value:Object):void
            {
                if (value.mined) ++count;
            });

            return count;
        }

        /**
         * Has the user solved the puzzle?
         */
        private function checkWin():void
        {
            var exposedCount:int = countExposedCells();
            var unminedCount:int = (_model.rows * _model.columns) - _model.nmines;
            if (exposedCount == unminedCount)
            {
                showWin();
            }
        }

        /**
         * Respond visually to the user hitting a mine.
         */
        private function showLoss():void
        {
            _model.setState(States.LOST);
            exposeAllMines();
            stopTimer();
        }

        /**
         * Respond visually to win condition.
         */
        private function showWin():void
        {
            _model.setState(States.WON);
            _model.setFlagCount(_model.nmines);
            flagAllCovered();
            stopTimer();
        }

        /**
         * Count the number of exposed cells.
         */
        private function countExposedCells():int
        {
            var exposedCount:int = 0;

            _model.getGrid().visitAll(function(r:int, c:int, value:Object):void
            {
                if (Tags.isExposed(value.tag))
                {
                    ++exposedCount;
                }
            });


            return exposedCount;
        }

        /**
         * Expose all mines.
         */
        private function exposeAllMines():void
        {
            _model.getGrid().visitAll(function(r:int, c:int, value:Object):void
            {
                if (value.tag != Tags.BOOM)
                {
                    var isMined:Boolean = value.mined;
                    var isFlagged:Boolean = value.tag == Tags.FLAG;

                    if (isMined != isFlagged)
                    {
                        _model.setTagAt(r, c, isMined ? Tags.MINE : Tags.OOPS);
                    }
                }
            });
        }

        /**
         * Flag all covered cells.
         */
        private function flagAllCovered():void
        {
            _model.getGrid().visitAll(function(r:int, c:int, value:Object):void
            {
                switch (value.tag)
                {
                case Tags.NULL:
                case Tags.QUES:
                    _model.setTagAt(r, c, Tags.FLAG);
                    break;
                }
            });
        }
    }
}
