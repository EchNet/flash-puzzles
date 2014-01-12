/**
 */

package net.ech.pbn
{
    import flash.display.*;
    import flash.text.*;
    import mx.core.UIComponent;

    /**
     * Custom label component for rendering digits.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class NumbLabel
        extends UIComponent
    {
        private var _value:int;
        private var _textField:TextField;

        /**
         * 
         */
        public function set value(value:int):void
        {
            if (value != _value)
            {
                _value = value;
                invalidateProperties();
            }
        }

        override protected function createChildren():void
        {
            var tf:TextField = new TextField;

            var textFormat:TextFormat = new TextFormat;
            textFormat.align= "center";
            textFormat.bold = false;
            textFormat.font = "Courier";
            textFormat.italic = false;
            textFormat.size = 9;
            tf.setTextFormat(textFormat);

            addChild(tf);
            _textField = tf;
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            _textField.text = String(_value);

            _textField.scaleX = computeScale(_textField.textWidth, width);
            _textField.scaleY = computeScale(_textField.textHeight, height);
            _textField.x = center(_textField.textWidth, width, _textField.scaleX);
            _textField.y = center(_textField.textHeight, height, _textField.scaleY);
        }

        private static function computeScale(actualSize:Number, maxSize:Number):Number
        {
            return actualSize > maxSize ? (maxSize / actualSize) : 1.0;
        }

        private static function center(actualSize:Number, maxSize:Number, scale:Number):Number
        {
            return (maxSize - (actualSize * scale)) / 2;
        }
    }
}
