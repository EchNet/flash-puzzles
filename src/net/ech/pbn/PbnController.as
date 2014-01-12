/**
 *
 */

package net.ech.pbn
{
    import flash.events.Event;
    import net.ech.puzzle.States;
    import net.ech.events.VEvent;

    /**
     * Application controller.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class PbnController
    {
        private var _model:PbnModel;

        /**
         * The model.  Caller must set this before starting application.
         */
        public function set model(model:PbnModel):void
        {
            _model = model;
        }

        /**
         * What to do when the user clicks the "clear" button.
         */
        public function clear():void
        {
            _model.forEachCell(function(cell:int, row:int, column:int):void
            {
                _model.setCellAt(row, column, CellValues.NEUTRAL);
            });

            _model.setStatus(States.CLEAR);
            _model.dispatchStateChange({});
        }

        /**
         * Change the state of the selection.
         * @param selection   object having the following properties:
         *                    row, column
         *                    altColor
         *                    altWeight
         */
        public function select(selection:Object):void
        {
            if (_model != null)
            {
                var stateChange:Boolean = false;

                if (_model.status == States.CLEAR)
                {
                    _model.setStatus(States.WORKING);
                    stateChange = true;
                }

                if (_model.status == States.WORKING)
                {
                    var row:int = selection.selectedCell.row;
                    var column:int = selection.selectedCell.column;
                    var altColor:Boolean = selection.altColor;
                    var altWeight:Boolean = selection.altWeight;

                    var oldValue:int = _model.getCellAt(row, column);
                    var newValue:int = oldValue;

                    if (selection.dragStartCell)
                    {
                        newValue = _model.getCellAt(selection.dragStartCell.row,
                                                    selection.dragStartCell.column);
                    }
                    else
                    {
                        newValue = altColor ? (altWeight ? CellValues.SEMI_WHITE : CellValues.WHITE)
                                            : (altWeight ? CellValues.SEMI_BLACK : CellValues.BLACK);
                        if (newValue == oldValue)
                        {
                            newValue = CellValues.NEUTRAL;
                        }
                    }

                    var valueChange:Boolean = false;

                    if (newValue != oldValue)
                    {
                        _model.setCellAt(row, column, newValue);
                        valueChange = true;

                        if (checkWin()) 
                        {
                            stateChange = true;
                            showWin();
                        }
                    }

                    if (stateChange || valueChange)
                    {
                        var changeData:Object = {};
                        if (!stateChange)
                        {
                            changeData.cell = {
                                value: newValue,
                                row: row,
                                column: column
                            };
                        }
                        _model.dispatchStateChange(changeData);
                    }
                }
            }
        }

        /**
         * Has the user solved the puzzle?
         */
        private function checkWin():Boolean
        {
            // All rows/columns must conform to input specs.

            for (var pass:int = 0; pass < 2; ++pass)
            {
                var isRow:Boolean = pass == 0;
                var inputs:Array = isRow ? _model.rowInputs : _model.columnInputs;

                for (var i:int = 0; i < inputs.length; ++i)
                {
                    if (!asRepresented(isRow, i, inputs[i]))
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        private function asRepresented(isRow:Boolean, index:int, input:Array):Boolean
        {
            var blackCount:int = -1;
            var inputIndex:int = 0;
            var result:Array = [];

            function isBlack(value:int):Boolean
            {
                switch (value)
                {
                case CellValues.BLACK:
                case CellValues.SEMI_BLACK:
                    return true;
                default:
                    // Gray is considered white for this purpose.
                    return false;
                }
            }

            function takeBlack():Boolean
            {
                if (blackCount < 0)
                {
                    if (inputIndex == input.length)
                        return false;
                    blackCount = 1;
                }
                else
                {
                    blackCount += 1;
                }

                return true;
            }

            function takeWhite():Boolean
            {
                if (blackCount > 0)
                {
                    if (blackCount != input[inputIndex])
                        return false;
                    blackCount = -1;
                    ++inputIndex;
                }

                return true;
            }

            _model.forEachInRank(isRow, index, function(cell:int, ... ignored):void
            {
                if (isBlack(cell))
                {
                    takeBlack();
                }
                else
                {
                    takeWhite();
                }
            });
            takeWhite();

            return inputIndex == input.length;
        }

        private function showWin():void
        {
            _model.setStatus(States.SOLVED);
            _model.forEachCell(function(cell:int, row:int, column:int):void
            {
                switch (cell)
                {
                case CellValues.NEUTRAL:
                case CellValues.SEMI_WHITE:
                    _model.setCellAt(row, column, CellValues.WHITE);
                    break;
                case CellValues.SEMI_BLACK:
                    _model.setCellAt(row, column, CellValues.BLACK);
                    break;
                }
            });
        }
    }
}
