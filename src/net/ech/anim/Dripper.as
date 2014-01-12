package net.ech.anim
{
    import flash.display.Shape;
    import flash.events.*;
    import flash.utils.getTimer;
    import mx.core.UIComponent;
    import mx.utils.ColorUtil;

    public class Dripper extends PaintDripZone
    {
        private var _w:int;
        private var _h:int;
        private var _dripTime:int = -1;

        private var colors:Array = [ 0xff8888, 0xffff44, 0xffdd55, 0x88ff88,
                                     0x8888ff, 0x44ffff, 0xff44ff ] 

        public function Dripper()
        {
            addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        }

        private function handleEnterFrame(event:Event):void
        {
            if (_dripTime < 0 || getTimer() >= _dripTime)
            {
                drip();
                setNextDripTime();
            }
        }

        public function setBounds(w:int, h:int):void
        {
            _w = w;
            _h = h;
        }

        private function drip():void
        {
            var x:int = (0.2 + (0.6 * Math.random())) * _w;
            var y:int = (0.2 + (0.6 * Math.random())) * _h;
            var color:uint = colors[int(Math.random() * colors.length)];
            dripAt(x, y, color);
        }

        private function setNextDripTime():void
        {
            _dripTime = getTimer() + 500 + (Math.random() * 500);
        }
    }
}
