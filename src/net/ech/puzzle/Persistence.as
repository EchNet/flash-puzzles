/*
 * Author: James Echmalian, ech@ech.net
 *
 * The author makes no representations or warranties about the
 * suitability of the software, either express or implied, including
 * but not limited to the implied warranties of merchantability,
 * fitness for a particular purpose, or non-infringement. 
 */

package net.ech.puzzle
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.SharedObject;
    import mx.core.IMXMLObject;

    /**
     * Like a bridge to local SharedObject.
     * This class is designed to be instantiated as an MXML element.
     */
    public class Persistence
        extends EventDispatcher
        implements IMXMLObject
    {
        private var _so:SharedObject;

        /**
         * A unique name for this persistent object.  Used as the key to
         * the local SharedObject that persists the data.
         */
        public static const KEY:String = "net.ech.puzzle";

        /**
         * True if persistent storage is available.
         */
        public function get available():Boolean
        {
            return _so != null && _so.data != null;
        }

        /**
         * Get last saved state.
         */
        public function get xml():XML
        {
            return _so.data.xml;
        }

        /**
         * Implement IMXMLObject interface.
         * Initialize this object from persistent state.
         */
        public function initialized(document:Object, id:String):void
        {
            _so = SharedObject.getLocal(KEY);
        }

        /**
         * Save the latest application state.
         */
        public function save(xml:XML):void
        {
            _so.data.xml = xml;
            _so.flush();
        }

        /**
         * Clear the application state.
         */
        public function clear():void
        {
            save(null);
        }
    }
}
