package net.ech.anim
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.utils.getTimer;
    import mx.core.UIComponent;
    import mx.utils.ColorUtil;

    public class DripComponent extends UIComponent
    {
        private var _shape:Shape;
        private var _dripSprite:Dripper;
        private var _backgroundColor:uint = 0xffffff;

        private var colors:Array = [ 0xff8888, 0xffff44, 0xffdd55, 0x88ff88,
                                     0x8888ff, 0x44ffff, 0xff44ff ] 
        private var cx:int = 0;

        public function DripComponent()
        {
            addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
            {
                dripAt(e.localX, e.localY, colors[cx]);
                cx = (cx + 1) % colors.length;
            });
        }

        public function get backgroundColor():uint
        {
            return _backgroundColor;
        }

        public function set backgroundColor(backgroundColor:uint):void
        {
            if (backgroundColor != _backgroundColor)
            {
                _backgroundColor = backgroundColor;
                invalidateDisplayList();
            }
        }

        public function clear():void
        {
            _dripSprite.clear();
        }

        public function dripAt(x:int, y:int, color:Number):void
        {
            _dripSprite.dripAt(x, y, color);
        }

        override protected function createChildren():void
        {
            super.createChildren();
            _shape = new Shape;
            addChild(_shape);
            _dripSprite = new Dripper;
            addChild(_dripSprite);
        }

        override protected function updateDisplayList(uw:Number, uh:Number):void
        {
            super.updateDisplayList(uw, uh);

            _shape.graphics.clear();
            _shape.graphics.beginFill(_backgroundColor, 1.0);
            _shape.graphics.drawRect(0, 0, uw, uh);
            _shape.graphics.endFill();

            _dripSprite.setBounds(uw, uh);
        }
    }
}
