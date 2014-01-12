/**
 *
 */

package net.ech.mines.classic
{
    import flash.events.EventDispatcher;

    /**
     * Static methods that manage the state of a simple button, represented
     * by a single uint value.  It is unfortunately not possible to extend
     * class uint.
     *
     * The advantage to representing state this way is to simplify 
     * change events.
     */
    public class ButtonState
        extends EventDispatcher
    {
        /**
         * Form a new value.
         */
        public static function value(iconIndex:uint, pressed:Boolean = false):uint
        {
            return (iconIndex << 1) | (pressed ? 1 : 0);
        }

        /**
         * Which one of the button's icons to show.
         */
        public static function getIconIndex(state:uint):uint
        {
            return state >> 1;
        }

        /**
         * Which one of the button's icons to show.
         */
        public static function setIconIndex(state:uint, iconIndex:uint):uint
        {
            return value(iconIndex, isPressed(state));
        }

        /**
         * Whether the button is being pressed.
         */
        public static function isPressed(state:uint):Boolean
        {
            return (state & 01) != 0;
        }

        /**
         * Whether the button is being pressed.
         */
        public static function setPressed(state:uint, pressed:Boolean):uint
        {
            return value(getIconIndex(state), pressed);
        }
    }
}
