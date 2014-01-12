
package net.ech.ui
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import mx.containers.*;
    import mx.controls.*;
    import mx.core.*;
    import mx.managers.PopUpManager;

    /**
     * DialogBuilder provides the caller with a means of creating a 
     * modal message box or confirmation dialog box.
     *
     * DialogBuilder follows the Builder pattern, more or less.
     */
    public class DialogBuilder extends EventDispatcher
    {
        /**
         * Desired title.
         */
        public var title:String;

        /**
         * Desired message body.
         */
        public var text:String;

        /**
         * Desired width.
         */
        public var width:int;

        /**
         * Desired height.
         */
        public var height:int;

        /**
         * Default parent.  Default is Application.application.
         */
        public var parent:DisplayObject;

        /**
         * The dialog.  Valid only following a build.
         */
        public var dialog:UIComponent;

        private var _options:Array;

        /**
         * Constructor.
         */
        public function DialogBuilder()
        {
            _options = new Array();
            parent = DisplayObject(Application.application);
        }

        /**
         * Add an option.  If no options specified, you get one dismissal
         * button labeled "OK".
         */
        public function addOption(label:String, func:Function):void
        {
            _options.push ({ label: label, func: func });
        }

        /**
         * Build the dialog.
         */
        public function build():UIComponent
        {
            if (dialog == null)
            {
                dialog = makePanel();
            }

            return dialog;
        }

        private function makePanel():Panel
        {
            var panel:TitleWindow = new TitleWindow();
            panel.title = title;
            panel.showCloseButton = true;
            panel.addEventListener ("close", handleClose);
            panel.styleName = "messageBox";
            panel.setStyle("verticalGap", 10);

            var textDisplay:Text = new Text();
            textDisplay.text = text;
            panel.addChild(textDisplay);

            var buttonBox:Box = new Box();
            buttonBox.percentWidth = 100;
            buttonBox.setStyle("horizontalAlign", "center");
            panel.addChild(buttonBox);

            var buttonTile:Tile = new Tile();
            buttonTile.direction = TileDirection.HORIZONTAL;
            buttonTile.setStyle("paddingTop", 5);
            buttonTile.setStyle("paddingBottom", 5);
            buttonBox.addChild(buttonTile);

            if (_options.length > 0)
            {
                for each (var option:Object in _options)
                {
                    addButton(option.label, option.func, buttonTile);
                }
            }
            else
            {
                addButton("OK", handleClose, buttonTile);
            }

            if (width != 0)
            {
                panel.width = width;
            }
            if (height != 0)
            {
                panel.height = height;
            }

            return panel;
        }

        private function addButton(label:String, func:Function,
                                   parent:Container):void
        {
            var button:Button = new Button();
            button.label = label;
            button.addEventListener(MouseEvent.CLICK, func);
            parent.addChild(button);
        }

        /**
         * Show the dialog through the PopUpManager.
         */
        public function show():UIComponent
        {
            build();
            dialog.visible = true;
            PopUpManager.addPopUp(dialog, parent, true);
            PopUpManager.centerPopUp(dialog);
            return dialog;
        }

        /**
         * Dismiss the dialog immediately, but don't unfreeze the display
         * until the given function completes.
         */
        public function dismissAfterCall(func:Function):void
        {
            if (dialog != null)
            {
                dialog.visible = false;
                dialog.callLater (func);
                dialog.callLater (dismiss);
            }
        }

        /**
         * Dismiss the shown dialog.
         */
        public function dismiss():void
        {
            if (dialog != null)
            {
                PopUpManager.removePopUp(dialog);
            }
        }

        private function handleClose(event:Event):void
        {
            dismiss();
        }
    }
}
