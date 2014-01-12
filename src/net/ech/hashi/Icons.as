/**
 *
 */

package net.ech.hashi
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;

    /**
     * Static images used in Hashi
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

        private static const DIGIT_SOURCES:Array = [

            "aaaabbbaaa" +     // zero - not used
            "aaabaaabaa" +
            "aabaaaaaba" +
            "abaaaaaaab" +
            "baaaaaaaaa" +
            "baaaaaaaaa" +
            "baaaaaaaaa" +
            "abaaaaaaab" +
            "aabaaaaaba" +
            "aaabbbaaaa",

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
            "adddddddd",

            "aaiiiaiiia" +
            "aaiiiaiiia" +
            "aiiiaaiiia" +
            "aiiiaaiiia" +
            "iiiiiiiiii" +
            "iiiiiiiiii" +
            "aaaaaaiiia" +
            "aaaaaaiiia" +
            "aaaaaaiiia" +
            "aaaaaaiii",

            "eeeeeeeeee" +
            "eeeeeeeeee" +
            "eeeaaaaaaa" +
            "eeeaaaaaaa" +
            "eeeeeeeeea" +
            "eeeeeeeeee" +
            "aaaaaaaeee" +
            "aaaaaaaeee" +
            "eeeeeeeeee" +
            "eeeeeeeee",

            "akkkkkkkka" +
            "kkkkkkkkka" +
            "kkkaaaaaaa" +
            "kkkaaaaaaa" +
            "kkkkkkkkka" +
            "kkkkkkkkkk" +
            "kkkaaaakkk" +
            "kkkaaaakkk" +
            "kkkkkkkkkk" +
            "akkkkkkkk",

            "bbbbbbbbbb" + 
            "bbbbbbbbbb" + 
            "aaaaaaabbb" + 
            "aaaaaaabbb" + 
            "aaaaaabbba" + 
            "aaaaaabbba" + 
            "aaaaabbbaa" + 
            "aaaaabbbaa" + 
            "aaaabbbaaa" + 
            "aaaabbb",

            "ajjjjjjjja" +
            "jjjjjjjjjj" +
            "jjjaaaajjj" +
            "jjjaaaajjj" +
            "ajjjjjjjja" +
            "ajjjjjjjja" +
            "jjjaaaajjj" +
            "jjjaaaajjj" +
            "jjjjjjjjjj" +
            "ajjjjjjjj"
        ];

        private var _digitIcons:Array = [];

        /**
         * Constructor.
         */
        public function Icons()
        {
            _digitIcons = createDigitIcons();
        }

        private function createDigitIcons():Array
        {
            var array:Array = [];

            for each (var src:String in DIGIT_SOURCES)
            {
                array.push(createIcon(src, DIGIT_WIDTH, DIGIT_HEIGHT));
            }

            return array;
        }

        private function createIcon(src:String, width:int, height:int):Bitmap
        {
            var bitmapData:BitmapData = new BitmapData(width, height, true, 0);

            for (var i:int = 0; i < src.length; ++i)
            {
                var x:int = i % width;
                var y:int = i / width;
                bitmapData.setPixel32(x, y, COLORS[src.charAt(i)]);
            }

            var bitmap:Bitmap = new Bitmap(bitmapData);
            bitmap.smoothing = false;
            bitmap.pixelSnapping = PixelSnapping.NEVER;
            return bitmap;
        }

        /**
         * Get the image that corresponds to a digit.
         * The first ten elements are the icons for the digits 0..9.
         * The eleventh element [10] is the minus sign.
         */
        public function get digitIcons():Array
        {
            return _digitIcons;
        }
    }
}
