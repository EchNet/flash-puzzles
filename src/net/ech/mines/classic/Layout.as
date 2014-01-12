/**
 */

package net.ech.mines.classic
{
    import flash.geom.Rectangle;

    /**
     * Encapsulation of layout logic for classic Minesweeper view.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Layout
    {
        private static const GRID_BORDER_WIDTH:int = 3;
        private static const GRID_BORDER_HEIGHT:int = 3;
        private static const PANEL_BORDER_WIDTH:int = 9;
        private static const PANEL_BORDER_HEIGHT:int = 9;
        private static const PANEL_DIVIDER_HEIGHT:int = 6;
        private static const TOP_PANEL_HEIGHT:int = 37;
        private static const COUNT_BOX_WIDTH:int = 39;
        private static const READOUT_TB_MARGIN:int = 6;
        private static const READOUT_LR_MARGIN:int = 8;

        public static const RESTART_BUTTON_SIDE:int = 26;

        public static const CELL_WIDTH:int = 16;
        public static const CELL_HEIGHT:int = 16;

        private var _width:int;
        private var _height:int;
        private var _topPanelRect:Rectangle;
        private var _gridPanelRect:Rectangle;
        private var _gridRect:Rectangle;
        private var _restartButtonRect:Rectangle;
        private var _counterRect:Rectangle;
        private var _timerRect:Rectangle;

        /**
         * Constructor.
         * @param rows     number of rows in puzzle
         * @param columns  number of columns in puzzle
         */
        public function Layout(rows:int = 0, columns:int = 0)
        {
            _gridPanelRect = computeGridPanelRect (rows, columns);
            _topPanelRect = computeTopPanelRect (columns);
            _gridRect = computeGridRect (rows, columns);
            _restartButtonRect = computeRestartButtonRect (columns);
            _counterRect = computeCounterRect ();
            _timerRect = computeTimerRect (columns);

            _width = _gridPanelRect.width + (2 * PANEL_BORDER_WIDTH);
            _height = _gridPanelRect.height +
                      _topPanelRect.height + PANEL_DIVIDER_HEIGHT +
                      (2 * PANEL_BORDER_HEIGHT);
        }

        /**
         * Total width.
         */
        public function get width():int
        {
            return _width;
        }

        /**
         * Total height.
         */
        public function get height():int
        {
            return _height;
        }

        /**
         * Shape of the container for the restart button and readouts.
         */
        public function get topPanelRect():Rectangle
        {
            return _topPanelRect;
        }

        /**
         * Shape of the container for the grid.
         */
        public function get gridPanelRect():Rectangle
        {
            return _gridPanelRect;
        }

        /**
         * Shape of the grid.
         */
        public function get gridRect():Rectangle
        {
            return _gridRect;
        }

        /**
         * Shape of the restart button.
         */
        public function get restartButtonRect():Rectangle
        {
            return _restartButtonRect;
        }

        /**
         * Shape of the counter readout.
         */
        public function get counterRect():Rectangle
        {
            return _counterRect;
        }

        /**
         * Shape of the timer readout.
         */
        public function get timerRect():Rectangle
        {
            return _timerRect;
        }

        /**
         * Shape of a grid cell.
         */
        public function getCellRectAt(row:int, column:int):Rectangle
        {
            var rect:Rectangle = computeGridRect(1, 1);
            rect.x += column * CELL_WIDTH;
            rect.y += row * CELL_HEIGHT;
            return rect;
        }

        /**
         *
         */
        private function computeTopPanelRect (columns:int):Rectangle
        {
            var rect:Rectangle = new Rectangle;
            rect.x = PANEL_BORDER_WIDTH;
            rect.y = PANEL_BORDER_HEIGHT;
            rect.width = computeInnerWidth (columns);
            rect.height = TOP_PANEL_HEIGHT;
            return rect;
        }

        /**
         *
         */
        private function computeGridPanelRect(rows:int, columns:int):Rectangle
        {
            var rect:Rectangle = computeGridRect(rows, columns);
            rect.x -= GRID_BORDER_WIDTH;
            rect.y -= GRID_BORDER_HEIGHT;
            rect.width += 2 * GRID_BORDER_WIDTH;
            rect.height += 2 * GRID_BORDER_HEIGHT;
            return rect;
        }

        /**
         *
         */
        private function computeGridRect (rows:int, columns:int):Rectangle
        {
            var rect:Rectangle = new Rectangle;
            rect.x = PANEL_BORDER_WIDTH + GRID_BORDER_WIDTH;
            rect.y = TOP_PANEL_HEIGHT + PANEL_BORDER_HEIGHT + 
                     PANEL_DIVIDER_HEIGHT + GRID_BORDER_HEIGHT;
            rect.width = columns * CELL_WIDTH;
            rect.height = rows * CELL_HEIGHT;
            return rect;
        }

        /**
         *
         */
        private function computeRestartButtonRect(columns:int):Rectangle
        {
            var x:int = PANEL_BORDER_WIDTH + ((computeInnerWidth(columns) - RESTART_BUTTON_SIDE) / 2);
            var y:int = PANEL_BORDER_HEIGHT + ((TOP_PANEL_HEIGHT - RESTART_BUTTON_SIDE) / 2);
            return new Rectangle (x, y, RESTART_BUTTON_SIDE, RESTART_BUTTON_SIDE);
        }

        /**
         *
         */
        private function computeCounterRect ():Rectangle
        {
            var rect:Rectangle = new Rectangle;
            rect.x = PANEL_BORDER_WIDTH + READOUT_LR_MARGIN; 
            rect.y = PANEL_BORDER_HEIGHT + READOUT_TB_MARGIN;
            rect.width = COUNT_BOX_WIDTH;
            rect.height = TOP_PANEL_HEIGHT - 2 * READOUT_TB_MARGIN;
            return rect;
        }

        private function computeTimerRect(columns:int):Rectangle
        {
            var rect:Rectangle = new Rectangle;
            rect.x = PANEL_BORDER_WIDTH + computeInnerWidth(columns) -
                     READOUT_LR_MARGIN - COUNT_BOX_WIDTH;
            rect.y = PANEL_BORDER_HEIGHT + READOUT_TB_MARGIN;
            rect.width = COUNT_BOX_WIDTH;
            rect.height = TOP_PANEL_HEIGHT - 2 * READOUT_TB_MARGIN;
            return rect;
        }

        /**
         * 
         */
        private function computeInnerWidth(columns:int):int
        {
            return (columns * CELL_WIDTH) + (2 * GRID_BORDER_WIDTH);
        }
    }
}
