package net.ech.sudoku.solver
{
    /**
     * A Technique attempts to solve a puzzle one way.
     */
    public class Technique extends Visitor
    {
        public var level:int;

        /**
         * Constructor.
         */
        public function Technique(grid:SolutionModel)
        {
            super(grid);
        }

        /**
         * Abstract method.
         */
        public function find():Boolean
        {
            return false;
        }
    }
}
