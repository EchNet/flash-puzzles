/**
 */

package net.ech.puzzle
{
    import flash.events.EventDispatcher;
    import net.ech.util.Grid;
    import net.ech.events.VEvent;

    /**
     * Event dispatched when anything in the model changes.
     * Details may be available - see subclass doc for info.
     */
    [Event(name="stateChange", type="net.ech.events.VEvent")]

    /**
     * Base class for puzzle models.  Provides hooks for uniform controls
     * and persistence.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class PuzzleModel
        extends EventDispatcher
    {
        private var _xml:XML;
        private var _status:int = States.CLEAR;

        /**
         * Constructor.
         * @param xml  state XML.
         */
        public function PuzzleModel(xml:XML)
        {
            configure(xml.config);

            if (xml.state.length() > 0)
            {
                restoreState(xml.state);
            }

            // Squirrel away the configuration for serialize()
            _xml = xml.copy();
            while (_xml.state.length() > 0)
            {
                delete _xml.state[0];
            }
        }

        [Bindable("stateChange")]
        /**
         * @see net.ech.puzzle.States
         */
        public function get status():int
        {
            return _status;
        }

        [Bindable("stateChange")]
        /**
         * Shorthand for status == States.SOLVED
         */
        public function get solved():Boolean
        {
            return _status == States.SOLVED;
        }

        /**
         * Serialize as XML for persistence.
         */
        public function serialize():XML
        {
            var xml:XML = _xml.copy();
            if (_status != States.CLEAR)
            {
                xml.state += serializeState();
            }
            return xml;
        }

        /**
         * Set the value of the status.  For use only by a puzzle
         * controller.  Must be accompanied by a call to dispatchStateChange.
         */
        public function setStatus(status:int):void
        {
            _status = status;
        }

        /**
         * A method the controller may use to signal a set of changes
         * to the model.  Details of the change are encoded in the data
         * object in a form that is agreed upon by the controller and view.
         */
        public function dispatchStateChange(data:Object):void
        {
            dispatchEvent(VEvent.create("stateChange", data));
        }

        /**
         * Subclasses must implement their own configuration.
         */
        protected function configure(xml:XMLList):void
        {
        }

        /**
         * Subclasses must implement their own state restoration.
         * And call super.
         */
        protected function restoreState(xml:XMLList):void
        {
            _status = int(xml.status);
        }

        /**
         * Subclasses that rely on the default serialize() implementation
         * need only to implement the serialization of puzzle-specific state.
         * @return a <state> element
         */
        protected function serializeState():XML
        {
            return <state><status>{_status}</status></state>;
        }
    }
}
