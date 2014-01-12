/*
 *  VEvent.as
 *
 *  Author: James Echmalian, ech@ech.net
 *
 *  The author makes no representations or warranties about the
 *  suitability of the software, either express or implied, including
 *  but not limited to the implied warranties of merchantability,
 *  fitness for a particular purpose, or non-infringement. 
 */
package net.ech.events
{
    import flash.events.Event;

    /**
     * A general event type.
     */
    public class VEvent 
        extends Event
    {
        /**
         * Details about this event.
         */
        public var data:Object;

        /**
         * Factory method.  Sets the "bubbles" and "cancelable" properties
         * to true.
         * @param type A type string for this event.
         * @param data An optional payload for this event.
         */
        public static function create(type:String, data:Object):VEvent
        {
            return new VEvent(type, true, true, data);
        }

        /**
         * Constructor.
         * @param type A type string for this event.
         * @param bubbles
         * @param cancelable
         * @param data An optional payload for this event.
         */
        public function VEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:Object = null)
        {
            super(type, bubbles, cancelable);
            this.data = data;
        }

        /**
         * @inheritDoc
         */
        override public function clone():Event
        {
            return new VEvent(type, bubbles, cancelable, data);
        }
    }
}
