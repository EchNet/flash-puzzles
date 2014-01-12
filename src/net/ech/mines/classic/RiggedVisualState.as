/**
 */

package net.ech.mines.classic
{
    import net.ech.mines.*;

    /**
     * A VisualState rigged for testing.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class RiggedVisualState
        extends VisualState
    {
        /**
         * Constructor.
         */
        public function RiggedVisualState(rows:uint = 8, columns:uint = 8)
        {
            super(rows, columns);
        }

        /**
         * Step the face button forward through all of its states.
         */
        public function rotateFace():void
        {
            face = rotateButton(face, Faces.NVALUES);
        }

        /**
         * Step the specified cell forward through all of its states.
         */
        public function rotateCell(row:int, column:int):void
        {
            var value:uint = uint(grid.getCellAt(row, column));
            value = rotateButton(value, Tags.NVALUES);
            grid.setCellAt(row, column, value);
        }

        /**
         * @private
         */
        private function rotateButton(value:uint, maxIconIndex:uint):uint
        {
            var iconIndex:uint = ButtonState.getIconIndex(value) + 1;
            if (iconIndex >= maxIconIndex)
            {
                iconIndex = 0;
                value = ButtonState.setPressed(value, !ButtonState.isPressed(value));
            }
            return ButtonState.setIconIndex(value, iconIndex);
        }
    }
}
