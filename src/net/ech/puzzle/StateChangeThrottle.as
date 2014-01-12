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
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    import net.ech.events.Listeners;
    import net.ech.events.VEvent;

    [Event(name="stateChange", type="net.ech.events.VEvent")]

    /** 
     * Stem the flow of state change events from a model by imposing
     * a "one per X milliseconds" limit.
     */
    public class StateChangeThrottle extends EventDispatcher
    {
        private var _model:PuzzleModel;
        private var _pendingEvent:VEvent;
        private var _lastPushTime:uint;
        private var _timer:Timer;

        /**
         * Minimum period between two stateChange events.
         */
        public var stillPeriod:int;

        /**
         * The origin of stateChange events.
         */
        public function get model():PuzzleModel
        {
            return _model;
        }

        public function set model(model:PuzzleModel):void
        {
            Listeners.remove(_model, { "stateChange": handleStateChange });
            _model = model;
            Listeners.add(_model, { "stateChange": handleStateChange });
        }

        private function handleStateChange(event:VEvent):void
        {
            _pendingEvent = event;

            if ((getTimer() - _lastPushTime) >= stillPeriod)
            {
                pushPendingEvent();
                stopTimer();
            }
            else
            {
                startTimer();
            }
        }
        
        private function handleTimer(event:TimerEvent):void
        {
            pushPendingEvent();
            _timer = null;
        }

        private function startTimer():void
        {
            if (_timer == null)
            {
                _timer = new Timer(stillPeriod, 1);
                _timer.addEventListener(TimerEvent.TIMER, handleTimer);
                _timer.start();
            }
        }

        private function stopTimer():void
        {
            if (_timer != null)
            {
                _timer.stop();
                _timer = null;
            }
        }

        private function pushPendingEvent():void
        {
            dispatchEvent(_pendingEvent);
            _lastPushTime = getTimer();
            _pendingEvent = null;
        }
    }
}
