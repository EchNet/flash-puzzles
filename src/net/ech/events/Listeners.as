/*
 * $Id$
 *
 * The author makes no representations or warranties about the
 * suitability of the software, either express or implied, including
 * but not limited to the implied warranties of merchantability,
 * fitness for a particular purpose, or non-infringement. 
 */
package net.ech.events
{
    import flash.events.IEventDispatcher;

    /**
     * Support the typical add/remove listeners on a property pattern.
     *
     * Do not instantiate this class.
     */
    public class Listeners 
    {
        /**
         * Add all of the listeners in the listenerMap to the dispatcher.
         * TODO: That made no sense.  Try again.
         */
        public static function add(dispatcher:Object, listenerMap:Object):void
        {
            if (dispatcher is IEventDispatcher)
            {
                for (var etype:String in listenerMap)
                {
                    if (listenerMap[etype] is Function)
                    {
                        IEventDispatcher(dispatcher).addEventListener(etype, listenerMap[etype] as Function);
                    }
                }
            }
        }

        /**
         * Remove all of the listeners in the listenerMap from the dispatcher.
         * TODO: That made no sense.  Try again.
         */
        public static function remove(dispatcher:Object, listenerMap:Object):void
        {
            if (dispatcher is IEventDispatcher)
            {
                for (var etype:String in listenerMap)
                {
                    if (listenerMap[etype] is Function)
                    {
                        IEventDispatcher(dispatcher).removeEventListener(etype, listenerMap[etype] as Function);
                    }
                }
            }
        }
    }
}
