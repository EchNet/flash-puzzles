
package net.ech.sudoku
{
    /**
     * Constants intrinsic to Sudoku.
     * Do not instantiate.
     */
    public class SudokuRules
    {
        public static const N_CELLS:int = 81;
        public static const N_CELLS_PER_GROUP:int = 9;
        public static const N_GROUPS_PER_TYPE:int = 9;
        public static const N_ROWS:int = 9;
        public static const N_COLUMNS:int = 9;
        public static const N_BOXES:int = 9;

        public static function assertValidRowIndex(rowIndex:int):void
        {
            assertValidGroupIndex(rowIndex, "row");
        }

        public static function assertValidColumnIndex(columnIndex:int):void
        {
            assertValidGroupIndex(columnIndex, "column");
        }

        public static function assertValidBoxIndex(boxIndex:int):void
        {
            assertValidGroupIndex(boxIndex, "box");
        }

        private static function assertValidGroupIndex(value:int,
                                                      groupTypeName:String):void
        {
            if (value < 0 || value >= N_GROUPS_PER_TYPE)
            {
                throw new Error("invalid " + groupTypeName + " index: " + value);
            }
        }
    }
}
