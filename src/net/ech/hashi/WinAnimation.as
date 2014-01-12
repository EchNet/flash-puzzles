/**
 */

package net.ech.hashi
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import net.ech.util.Rand;

    /**
     * Hashi view, responsible for rendering and user gesture handling. 
     *
     * @author James Echmalian, ech@ech.net
     */
    public class WinAnimation
    {
        private var _timer:Timer;
        private var _islands:Array;
        private var _queue:Array = [];
        private var _paintFunc:Function;

        public function WinAnimation(islands:Array, paintFunc:Function)
        {
            _timer = new Timer(200);
            _timer.addEventListener(TimerEvent.TIMER, handleWinTimer);
            _timer.start();

            _islands = islands;
            Rand.shuffle(_islands);

            _paintFunc = paintFunc;
        }

        public function stop():void
        {
            _timer.stop();
        }

        private static const QMAX:int = 5;

        private function handleWinTimer(event:TimerEvent):void
        {
            var qmax:int = Math.min(QMAX, _islands.length);
            var qlen:int = _queue.length;
            var middle:int = 0;
            if (qlen == qmax)
            {
                paintIsland(_queue[0], Colors.FULL_ISLAND);
                ++middle;
            }

            for (var i:int = middle; i < qlen; ++i)
            {
                paintIsland(_queue[i], Colors.HALF_LIT_ISLAND);
            }

            var next:int =
                qlen == 0 ? 0 : ((_queue[qlen - 1] + 1) % _islands.length);

            paintIsland(next, Colors.LIT_ISLAND);

            if (qlen == qmax)
            {
                for (i = 0; i < qmax + 1; ++i)
                {
                    _queue[i] = _queue[i + 1];
                }
                _queue[qmax - 1] = next;
            }
            else
            {
                _queue.push(next);
            }
        }

        private function paintIsland(index:int, color:uint):void
        {
            _paintFunc(_islands[index], color);
        }
    }
}
