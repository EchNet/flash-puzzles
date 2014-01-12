package net.ech.anim
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.utils.getTimer;
    import mx.core.UIComponent;
    import mx.utils.ColorUtil;

    public class PaintDripZone extends Sprite
    {
        private static const INITIAL_RADIUS:Number = 3;    // pixels
        private static const DEFAULT_PERIOD:Number = 4000; // millis
        private static const DEFAULT_SPEED:Number = 0.08;  // pixels per milli

        private var rippleQueue:Array = new Array();

        public var period:Number = DEFAULT_PERIOD;
        public var speed:Number = DEFAULT_SPEED;

        public function PaintDripZone()
        {
            addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        }

        public function clear():void
        {
            while (rippleQueue.length > 0)
            {
                var obj:Object = rippleQueue.shift();
                removeChild(obj.shape);
            }
        }

        public function dripAt(x:int, y:int, color:Number):void
        {
            var shape:Shape = new Shape();
            shape.x = x;
            shape.y = y;
            addChild(shape);

            rippleQueue.push({
                startTime: getTimer(),
                shape: shape,
                color: color
            });
        }

        private function handleEnterFrame(event:Event):void
        {
            var obj:Object;

            // Ripple.
            for each (obj in rippleQueue)
            {
                var elapsed:Number = getTimer() - obj.startTime;
                var progress:Number = elapsed / period;

                // TODO: make the color converge on the background color.
                // For now, assume white.
                var color:uint = ColorUtil.adjustBrightness2(obj.color, -75 + (progress * 175));
                var radius:Number = INITIAL_RADIUS + (elapsed * speed);

                obj.shape.graphics.clear();
                obj.shape.graphics.beginFill(color, 0.8);
                obj.shape.graphics.drawCircle(0, 0, radius);
                obj.shape.graphics.endFill();
            }

            // Prune.
            while (rippleQueue.length > 0 &&
                    (getTimer() - rippleQueue[0].startTime) > period)
            {
                obj = rippleQueue.shift();
                removeChild(obj.shape);
            }
        }
    }
}
