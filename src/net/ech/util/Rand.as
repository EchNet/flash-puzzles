/**
 */

package net.ech.util
{
    /**
     * Randomizer utilities.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class Rand
    {
        public static function shuffle(array:Array, lo:Number = NaN, hi:Number = NaN):void
        {
            if (isNaN(lo)) lo = 0;
            if (isNaN(hi)) hi = array.length;

            for (var i:int = lo; i < hi - 1; ++i)
            {
                var sel:int = i + int(Math.random() * (array.length - i));
                var tmp:* = array[i];
                array[i] = array[sel];
                array[sel] = tmp;
            }
        }
    }
}
