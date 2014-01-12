/**
 *
 */

package net.ech.fence
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;

    /**
     * Static images used in Fences
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Icons
    {
        private static const DIGIT_WIDTH:int = 10;
        private static const DIGIT_HEIGHT:int = 10;

        private static const COLORS:Object = {
            "a": 0x00000000, // transparent
            "b": 0xff000000 + Colors.BLACK, 
            "c": 0xff000000 + Colors.WHITE,
            "d": 0xff000000 + Colors.RED, 
            "e": 0xff000000 + Colors.DARK_RED,
            "f": 0xff000000 + Colors.YELLOW,
            "g": 0xff000000 + Colors.DARK_GREEN,
            "h": 0xff000000 + Colors.BLUE,
            "i": 0xff000000 + Colors.DARK_BLUE,
            "j": 0xff000000 + Colors.BROWN,
            "k": 0xff000000 + Colors.DARK_CYAN
        };

        private static const GRAYS:Object = {
            "a": 0x00000000, // transparent
            "b": 0xff000000 + Colors.NEUTRAL, 
            "c": 0xff000000 + Colors.NEUTRAL,
            "d": 0xff000000 + Colors.NEUTRAL, 
            "e": 0xff000000 + Colors.NEUTRAL,
            "f": 0xff000000 + Colors.NEUTRAL,
            "g": 0xff000000 + Colors.NEUTRAL,
            "h": 0xff000000 + Colors.NEUTRAL,
            "i": 0xff000000 + Colors.NEUTRAL,
            "j": 0xff000000 + Colors.NEUTRAL,
            "k": 0xff000000 + Colors.NEUTRAL
        };

        private static const DIGIT_SOURCES:Array = [

            "abbbbbbbba" +
            "bbbbbbbbbb" +
            "bbbaaaabbb" +
            "bbbaaaabbb" +
            "bbbaaaabbb" +
            "bbbaaaabbb" +
            "bbbaaaabbb" +
            "bbbaaaabbb" +
            "bbbbbbbbbb" +
            "abbbbbbbba",

            "aaaaahhaaa" +
            "aaaahhhaaa" +
            "aaahhhhaaa" +
            "aahhhhhaaa" +
            "aaaahhhaaa" +
            "aaaahhhaaa" +
            "aaaahhhaaa" +
            "aaaahhhaaa" +
            "aahhhhhhha" +
            "aahhhhhhh",

            "agggggggga" +
            "gggggggggg" +
            "gggaaaaggg" +
            "aaaaaaaggg" +
            "aaaaagggga" +
            "aaagggggaa" +
            "agggggaaaa" +
            "ggggaaaaaa" +
            "gggggggggg" +
            "gggggggggg",

            "adddddddda" +
            "dddddddddd" +
            "aaaaaaaddd" +
            "aaaaaaaddd" +
            "aaadddddda" +
            "aaadddddda" +
            "aaaaaaaddd" +
            "aaaaaaaddd" +
            "dddddddddd" +
            "adddddddd"
        ];

        private var _digitIcons:Array = [];
        private var _grayDigitIcons:Array = [];

        /**
         * Constructor.
         */
        public function Icons()
        {
            _digitIcons = createDigitIcons(COLORS);
            _grayDigitIcons = createDigitIcons(GRAYS);
        }

        private function createDigitIcons(colorMap:Object):Array
        {
            var array:Array = [];

            for each (var src:String in DIGIT_SOURCES)
            {
                array.push(createIcon(src, DIGIT_WIDTH, DIGIT_HEIGHT, colorMap));
            }

            return array;
        }

        private function createIcon(src:String, width:int, height:int, colorMap:Object):Bitmap
        {
            var bitmapData:BitmapData = new BitmapData(width, height, true, 0);

            for (var i:int = 0; i < src.length; ++i)
            {
                var x:int = i % width;
                var y:int = i / width;
                bitmapData.setPixel32(x, y, colorMap[src.charAt(i)]);
            }

            var bitmap:Bitmap = new Bitmap(bitmapData);
            bitmap.smoothing = false;
            bitmap.pixelSnapping = PixelSnapping.NEVER;
            return bitmap;
        }

        /**
         * Get the image that corresponds to a digit.
         */
        public function get digitIcons():Array
        {
            return _digitIcons;
        }

        /**
         * Get the image that corresponds to a digit (gray version).
         */
        public function get grayDigitIcons():Array
        {
            return _grayDigitIcons;
        }
    }
}
