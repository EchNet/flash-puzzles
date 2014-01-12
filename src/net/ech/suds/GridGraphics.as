package 
{
    import flash.display.Graphics;
    import flash.display.Sprite;

    public class GridGraphics
    {
        public static const CELL_SIZE:int = 40;

        public static function draw(sprite:Sprite):void
        {
            drawCells(sprite);
            drawBoxes(sprite);
        }

        private static function drawCells(sprite:Sprite):void
        {
            sprite.graphics.lineStyle(1.5, 0xcccccc);

            for (var x:int = 0; x < sprite.width; x += CELL_SIZE)
            {
                for (var y:int = 0; y < sprite.width; y += CELL_SIZE)
                {
                    sprite.graphics.drawRect(x, y, CELL_SIZE, CELL_SIZE);
                }
            }
        }

        private static function drawBoxes(sprite:Sprite):void
        {
            sprite.graphics.lineStyle(1.25, 0x000000);

            for (var x:int = 0; x < sprite.width; x += CELL_SIZE * 3)
            {
                for (var y:int = 0; y < sprite.width; y += CELL_SIZE * 3)
                {
                    sprite.graphics.drawRect(x, y, CELL_SIZE * 3, CELL_SIZE * 3);
                }
            }
        }
    }
}

