/**
 */

package net.ech.util
{
    /**
     * A cheap integer data compressor.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Base64
    {
        private var _radix:int;
        private var _valuesPerDigit:int;

        private static const DIGITS:String = "0123456789" +
            "abcdefghijklmnopqrstuvwxyz" +
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
            "-+";

        private static const CHAR_TO_VALUE:Object = (function():Object
        {
            var charToValue:Object = {};

            for (var i:int = 0; i < DIGITS.length; ++i)
            {
                var c:String = DIGITS.charAt(i);
                charToValue[c] = i;
            }

            return charToValue;
        })();

        /**
         * Constructor.
         */
        public function Base64(radix:int)
        {
            _radix = radix;
            _valuesPerDigit = Math.log(DIGITS.length) / Math.log(radix);
        }

        /**
         * Encoder.
         */
        public function encode(input:Array):String
        {
            var buf:String = "";
            var transit:int = 0;
            var inTransit:int = 0;

            for each (var v:int in input)
            {
                insert(v);
                if (inTransit == _valuesPerDigit)
                {
                    flush();
                }
            }

            if (inTransit > 0)
            {
                while (inTransit < _valuesPerDigit)
                {
                    insert(0);
                }
                flush();
            }

            function insert(v:int):void
            {
                transit *= _radix; 
                transit += v;
                ++inTransit;
            }

            function flush():void
            {
                buf += DIGITS.charAt(transit);
                transit = 0;
                inTransit = 0;
            }

            return buf;
        }

        /**
         * Decoder.
         */
        public function decode(input:String):Array
        {
            var buf:Array = [];
            var tmp:Array = new Array(_valuesPerDigit);

            for (var i:int = 0; i < input.length; ++i)
            {
                var c:String = input.charAt(i);
                var v:int = CHAR_TO_VALUE[c];

                for (var j:int = _valuesPerDigit; --j >= 0; )
                {
                    tmp[j]  = v % _radix;
                    v /= _radix;
                }

                for each (var w:int in tmp)
                {
                    buf.push(w);
                }
            }

            return buf;
        }
    }
}
