/**
 *
 */

package net.ech.mines.classic
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.PixelSnapping;

    /**
     * Static images used by Mines.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Icons
    {
        private static const TAG_WIDTH:int = 15;
        private static const FACE_WIDTH:int = 17;
        private static const DIGIT_WIDTH:int = 11;
        private static const DIGIT_HEIGHT:int = 21;

        private static const COLORS:Object = {
            "a": Colors.TRANSPARENT,
            "b": Colors.BLACK, 
            "c": Colors.WHITE,
            "d": Colors.RED, 
            "e": Colors.DARK_RED,
            "f": Colors.YELLOW,
            "g": Colors.DARK_GREEN,
            "h": Colors.BLUE,
            "i": Colors.DARK_BLUE,
            "j": Colors.BROWN,
            "k": Colors.DARK_CYAN
        };

        private static const TAG_SOURCES:Array = [
            "",                     // NULL

            "aaaaaaaaaaaaaaa" +     // FLAG
            "aaaaaaddaaaaaaa" +
            "aaaaddddaaaaaaa" +
            "aaadddddaaaaaaa" +
            "aaaaddddaaaaaaa" +
            "aaaaaaddaaaaaaa" +
            "aaaaaaabaaaaaaa" +
            "aaaaaaabaaaaaaa" +
            "aaaaabbbbaaaaaa" +
            "aaabbbbbbbbaaaa" +
            "aaabbbbbbbb",

            "aaaaaaaaaaaaaaa" +     // QUES
            "aaaaabbbbaaaaaa" +
            "aaaabbaabbaaaaa" +
            "aaaabbaabbaaaaa" +
            "aaaaaaaabbaaaaa" +
            "aaaaaaabbaaaaaa" +
            "aaaaaabbaaaaaaa" +
            "aaaaaabbaaaaaaa" +
            "aaaaaaaaaaaaaaa" +
            "aaaaaabbaaaaaaa" +
            "aaaaaabb",

            "aaaaaaabaaaaaaa" +     // BOOM
            "aaaaaaabaaaaaaa" +
            "aaababbbbbabaaa" +
            "aaaabbbbbbbaaaa" +
            "aaabbccbbbbbaaa" +
            "aaabbccbbbbbaaa" +
            "abbbbbbbbbbbbba" +
            "aaabbbbbbbbbaaa" +
            "aaabbbbbbbbbaaa" +
            "aaaabbbbbbbaaaa" +
            "aaababbbbbabaaa" +
            "aaaaaaabaaaaaaa" +
            "aaaaaaab",

            "aaaaaaabaaaaaaa" +     // MINE
            "aaaaaaabaaaaaaa" +
            "aaababbbbbabaaa" +
            "aaaabbbbbbbaaaa" +
            "aaabbccbbbbbaaa" +
            "aaabbccbbbbbaaa" +
            "abbbbbbbbbbbbba" +
            "aaabbbbbbbbbaaa" +
            "aaabbbbbbbbbaaa" +
            "aaaabbbbbbbaaaa" +
            "aaababbbbbabaaa" +
            "aaaaaaabaaaaaaa" +
            "aaaaaaab",

            "aaaaaaabaaaaaaa" +     // OOPS
            "addaaaabaaaadda" +
            "aaddabbbbbaddaa" +
            "aaaddbbbbbddaaa" +
            "aaabddcbbddbaaa" +
            "aaabbddbddbbaaa" +
            "abbbbbdddbbbbba" +
            "aaabbbdddbbbaaa" +
            "aaabbddbddbbaaa" +
            "aaaaddbbbddaaaa" +
            "aaaddbbbbbddaaa" +
            "aaddaaabaaaddaa" +
            "addaaaabaaaadda" +
            "ddaaaaaaaaaaadd",

            "",                     // ZERO

            "aaaaaaaaaaaaaaa" +
            "aaaaaaahhaaaaaa" +
            "aaaaaahhhaaaaaa" +
            "aaaaahhhhaaaaaa" +
            "aaaahhhhhaaaaaa" +
            "aaaaaahhhaaaaaa" +
            "aaaaaahhhaaaaaa" +
            "aaaaaahhhaaaaaa" +
            "aaaaaahhhaaaaaa" +
            "aaaahhhhhhhaaaa" +
            "aaaahhhhhhh",

            "aaaaaaaaaaaaaaa" +
            "aaaggggggggaaaa" +
            "aaggggggggggaaa" +
            "aagggaaaagggaaa" +
            "aaaaaaaaagggaaa" +
            "aaaaaaaggggaaaa" +
            "aaaaagggggaaaaa" +
            "aaagggggaaaaaaa" +
            "aaggggaaaaaaaaa" +
            "aaggggggggggaaa" +
            "aagggggggggg",

            "aaaaaaaaaaaaaaa" +
            "aadddddddddaaaa" +
            "aaddddddddddaaa" +
            "aaaaaaaaadddaaa" +
            "aaaaaaaaadddaaa" +
            "aaaaaddddddaaaa" +
            "aaaaaddddddaaaa" +
            "aaaaaaaaadddaaa" +
            "aaaaaaaaadddaaa" +
            "aaddddddddddaaa" +
            "aaddddddddd",

            "aaaaaaaaaaaaaaa" +
            "aaaaiiiaiiiaaaa" +
            "aaaaiiiaiiiaaaa" +
            "aaaiiiaaiiiaaaa" +
            "aaaiiiaaiiiaaaa" +
            "aaiiiiiiiiiiaaa" +
            "aaiiiiiiiiiiaaa" +
            "aaaaaaaaiiiaaaa" +
            "aaaaaaaaiiiaaaa" +
            "aaaaaaaaiiiaaaa" +
            "aaaaaaaaiii",

            "aaaaaaaaaaaaaaa" +
            "aaeeeeeeeeeeaaa" +
            "aaeeeeeeeeeeaaa" +
            "aaeeeaaaaaaaaaa" +
            "aaeeeaaaaaaaaaa" +
            "aaeeeeeeeeeaaaa" +
            "aaeeeeeeeeeeaaa" +
            "aaaaaaaaaeeeaaa" +
            "aaaaaaaaaeeeaaa" +
            "aaeeeeeeeeeeaaa" +
            "aaeeeeeeeee",

            "aaaaaaaaaaaaaaa" +
            "aaakkkkkkkkaaaa" +
            "aakkkkkkkkkaaaa" +
            "aakkkaaaaaaaaaa" +
            "aakkkaaaaaaaaaa" +
            "aakkkkkkkkkaaaa" +
            "aakkkkkkkkkkaaa" +
            "aakkkaaaakkkaaa" +
            "aakkkaaaakkkaaa" +
            "aakkkkkkkkkkaaa" +
            "aaakkkkkkkk",

            "aaaaaaaaaaaaaaa" + 
            "aabbbbbbbbbbaaa" + 
            "aabbbbbbbbbbaaa" + 
            "aaaaaaaaabbbaaa" + 
            "aaaaaaaaabbbaaa" + 
            "aaaaaaaabbbaaaa" + 
            "aaaaaaaabbbaaaa" + 
            "aaaaaaabbbaaaaa" + 
            "aaaaaaabbbaaaaa" + 
            "aaaaaabbbaaaaaa" + 
            "aaaaaabbb",

            "aaaaaaaaaaaaaaa" +
            "aaajjjjjjjjaaaa" +
            "aajjjjjjjjjjaaa" +
            "aajjjaaaajjjaaa" +
            "aajjjaaaajjjaaa" +
            "aaajjjjjjjjaaaa" +
            "aaajjjjjjjjaaaa" +
            "aajjjaaaajjjaaa" +
            "aajjjaaaajjjaaa" +
            "aajjjjjjjjjjaaa" +
            "aaajjjjjjjj"
        ];

        private static const FACE_SOURCES:Array = [
            "aaaaaabbbbbaaaaaa" +
            "aaaabbfffffbbaaaa" +
            "aaabfffffffffbaaa" +
            "aabafffffffffabaa" +
            "abafffffffffffaba" +
            "abaffbbfffbbffaba" +
            "bffffbbfffbbffffb" +
            "bfffffffffffffffb" +
            "bfffffffffffffffb" +
            "bfffffffffffffffb" +
            "bfffbfffffffbfffb" +
            "abaffbfffffbffaba" +
            "abafffbbbbbfffaba" +
            "aabafffffffffabaa" +
            "aaabfffffffffbaaa" +
            "aaaabbfffffbbaaaa" +
            "aaaaaabbbbbaaaaaa",

            "aaaaaabbbbbaaaaaa" +
            "aaaabbfffffbbaaaa" +
            "aaabfffffffffbaaa" +
            "aabafffffffffabaa" +
            "abafjbjfffjbjfaba" +
            "abafbbbfffbbbfaba" +
            "bfffjbjfffjbjfffb" +
            "bfffffffffffffffb" +
            "bfffffffffffffffb" +
            "bffffffbbbffffffb" +
            "bfffffbbfbbfffffb" +
            "abafffbfffbfffaba" +
            "abafffbbfbbfffaba" +
            "aabafffbbbfffabaa" +
            "aaabfffffffffbaaa" +
            "aaaabbfffffbbaaaa" +
            "aaaaaabbbbbaaaaaa",

            "aaaaaabbbbbaaaaaa" +
            "aaaabbfffffbbaaaa" +
            "aaabfffffffffbaaa" +
            "aabafffffffffabaa" +
            "abafbfbfffbfbfaba" +
            "abaffbfffffbffaba" +
            "bfffbfbfffbfbfffb" +
            "bfffffffffffffffb" +
            "bfffffffffffffffb" +
            "bfffffffffffffffb" +
            "bfffffbbbbbfffffb" +
            "abaffbfffffbffaba" +
            "abafbfffffffbfaba" +
            "aabafffffffffabaa" +
            "aaabfffffffffbaaa" +
            "aaaabbfffffbbaaaa" +
            "aaaaaabbbbbaaaaaa",

            "aaaaaabbbbbaaaaaa" +
            "aaaabbfffffbbaaaa" +
            "aaabfffffffffbaaa" +
            "aabafffffffffabaa" +
            "abafffffffffffaba" +
            "abafbbbbbbbbbfaba" +
            "bffbbbbbfbbbbbffb" +
            "bfbfbbbbfbbbbfbfb" +
            "bbffjbbfffbbjffbb" +
            "bfffffffffffffffb" +
            "bfffffffffffffffb" +
            "abaffbfffffbffaba" +
            "abafffbbbbbfffaba" +
            "aabafffffffffabaa" +
            "aaabfffffffffbaaa" +
            "aaaabbfffffbbaaaa" +
            "aaaaaabbbbbaaaaaa"
        ];

        //
        // Map each each pixel of the seven segment display to 
        // the segment it belongs to:
        //
        //      1
        //     2 3
        //      4
        //     5 6
        //      7
        //
        // (zero means that the pixel does not belong to a segment)
        //
        private static const SEVEN_SEG_TEMPLATE:String =
            "01111111110" +
            "20111111103" +
            "22011111033" +
            "22200000333" +
            "22200000333" +
            "22200000333" +
            "22200000333" +
            "22200000333" +
            "22000000033" +
            "20444444403" +
            "04444444440" +
            "50444444406" +
            "55000000066" +
            "55500000666" +
            "55500000666" +
            "55500000666" +
            "55500000666" +
            "55500000666" +
            "55077777066" +
            "50777777706" +
            "07777777770"
        ;

        //
        // Map each digit to its set of lit-up segments.
        // 
        // The 11th element is the minus sign.
        //
        private static const SEVEN_SEG_PATTERNS:Array = [
            0x77, 0x12, 0x5d, 0x5b, 0x3a,
            0x6b, 0x6f, 0x52, 0x7f, 0x7b,
            0x08 
        ];

        /**
         * Waiting for user input.
         */
        public static const HAPPY:int = 0;

        /**
         * User is about to uncover a cell.
         */
        public static const SCARED:int = 1;

        /**
         * Player lost.
         */
        public static const DEAD:int = 2;

        /**
         * Player won.
         */
        public static const COOL:int = 3;

        /**
         * How many faces there are.
         */
        public static const NVALUES:int = 4;

        private var _tagIcons:Array = [];
        private var _faceIcons:Array = [];
        private var _digitIcons:Array = [];

        /**
         * Constructor.
         */
        public function Icons()
        {
            _tagIcons = createIcons(TAG_SOURCES, TAG_WIDTH);
            _faceIcons = createIcons(FACE_SOURCES, FACE_WIDTH);
            _digitIcons = createDigitIcons();
        }

        private function createIcons(sources:Array, width:int):Array
        {
            var array:Array = [];

            for each (var src:String in sources)
            {
                array.push(createIcon(src, width, width));
            }

            return array;
        }

        private function createDigitIcons():Array
        {
            var asciiZero:int = '0'.charCodeAt(0);

            var array:Array = [];

            for each (var pattern:int in SEVEN_SEG_PATTERNS)
            {
                var src:String = "";
                for (var i:int = 0; i < SEVEN_SEG_TEMPLATE.length; ++i)
                {
                    var tval:int = SEVEN_SEG_TEMPLATE.charCodeAt(i) - asciiZero;
                    var pixel:String = "b";     // black
                    if (tval != 0)
                    {
                        var mask:int = 1 << (7 - tval);
                        if ((pattern & mask) != 0)
                            pixel = "d";      // light red
                        else if (i % 2 == 0)
                            pixel = "e";      // dark red
                    }
                    
                    src += pixel;
                }

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
         * The icons that correspond to tag values.
         * @see net.ech.mines.MinesTags
         */
        public function get tagIcons():Array
        {
            return _tagIcons;
        }

        /**
         * The icons that correspond to face values.
         * @see net.ech.mines.Faces
         */
        public function get faceIcons():Array
        {
            return _faceIcons;
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
