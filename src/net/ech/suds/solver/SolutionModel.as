
package net.ech.sudoku.solver
{
    import flash.events.EventDispatcher;

    /**
     *
     */
    public class SolutionModel extends EventDispatcher
    {
        public static var CELLS_PER_GROUP:int = 9;
        public static var CELL_COUNT:int = CELLS_PER_GROUP * CELLS_PER_GROUP;

        [Bindable]
        public var rows:Array;

        [Bindable]
        public var columns:Array;

        [Bindable]
        public var squares:Array;

        public function SolutionModel()
        {
            rows = newDimension("row");
            columns = newDimension("column");
            squares = newDimension("square");

            for (var r:int = 0; r < CELLS_PER_GROUP; ++r)
            {
                for (var c:int = 0; c < CELLS_PER_GROUP; ++c)
                {
                    var cell:CellModel = new CellModel();

                    cell.row = rows[r];
                    rows[r].cells.push(cell);

                    cell.column = columns[c];
                    columns[c].cells.push(cell);

                    var s:int = (Math.floor(r / 3) * 3) + Math.floor(c / 3);
                    cell.square = squares[s];
                    squares[s].cells.push(cell);
                }
            }

            checkDimension(rows);
            checkDimension(columns);
            checkDimension(squares);
        }

        private function checkDimension(dim:Array):void
        {
            for (var i:int = 0; i < CELLS_PER_GROUP; ++i)
            {
                if (dim[i].cells.length != CELLS_PER_GROUP)
                {
                    throw new Error ("checkDimension: " + dim[i].name + i);
                }
            }
        }

        private function newDimension(type:String):Array
        {
            var dimension:Array = new Array(CELLS_PER_GROUP);

            for (var i:int = 0; i < CELLS_PER_GROUP; ++i)
            {
                var group:GroupModel = new GroupModel();
                group.type = type;
                group.ordinal = i;
                group.grid = this;
                dimension[i] = group;
            }

            return dimension;
        }
    }
}
