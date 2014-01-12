/**
 */

package net.ech.mines
{
    import flash.display.*;
    import flash.events.Event;
    import net.ech.events.VEvent;

    [Event(name="flag", type="net.ech.events.VEvent")]
    [Event(name="expose", type="net.ech.events.VEvent")]
    [Event(name="clearAround", type="net.ech.events.VEvent")]
    [Event(name="restart", type="net.ech.events.VEvent")]

    /**
     * Base class for a Minesweeper view, responsible for rendering and
     * user gesture handling. 
     *
     * @author James Echmalian, ech@ech.net
     */
    public class MinesView
        extends Sprite
    {
        [Bindable("resize")]
        /**
         * My preferred width.
         */
        public function get preferredWidth():int
        {
            return 0;
        }

        [Bindable("resize")]
        /**
         * My preferred height.
         */
        public function get preferredHeight():int
        {
            return 0;
        }
    }
}
