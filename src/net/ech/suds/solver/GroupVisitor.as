package net.ech.sudoku.solver
{
    public class GroupVisitor
    {
        public var grid:SolutionModel;

        public function GroupVisitor(grid:SolutionModel)
        {
            this.grid = grid;
        }

        public function traverse():void
        {
            traverseDimension(grid.rows);
            traverseDimension(grid.columns);
            traverseDimension(grid.squares);
        }

        private function traverseDimension(groups:Array):void
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
