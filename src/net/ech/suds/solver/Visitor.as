package net.ech.sudoku.solver
{
    public class Visitor
    {
        public var grid:SolutionModel;

        public function Visitor(grid:SolutionModel)
        {
            this.grid = grid;
        }

        public function walkCells():void
        {
            for (var i:int = 0; i < grid.rows.length; ++i)
            {
                var group:GroupModel = GroupModel(grid.rows[i]);
                walkCellsInGroup(group);
            }
        }

        private function walkCellsInGroup(group:GroupModel):void
        {
            for (var i:int = 0; i < group.cells.length; ++i)
            {
                var cell:CellModel = CellModel(group.cells[i]);
                visitCell(cell);
            }
        }

        protected function visitCell(cell:CellModel):void
        {
        }

        public function walkGroups():void
        {
            walkGroupsInDimension(grid.squares);
            walkGroupsInDimension(grid.rows);
            walkGroupsInDimension(grid.columns);
        }

        private function walkGroupsInDimension(groups:Array):void
        {
            for (var i:int = 0; i < groups.length; ++i)
            {
                var group:GroupModel = GroupModel(groups[i]);
                visitGroup(group);
            }
        }

        protected function visitGroup(group:GroupModel):void
        {
        }
    }
}
