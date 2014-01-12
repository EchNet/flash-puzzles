/**
 */

package net.ech.mines.classic
{
    import flash.display.DisplayObject;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import net.ech.viva.events.Listeners;
    import net.ech.viva.events.VEvent;

    /**
     * A configurable mouse tracker.
     *
     * TODO: ignore mouse events bubbling up from child display object having
     * mouse tracker attached.  Listen for preceding fclick/fhover?
     */
    public class MouseTracker
    {
        private static const EXEMPLAR:XML = 
            <MouseTracker>
                <function id="" alt="" ctrl="" shift="" onDown="" />
            </MouseTracker>;

        /**
         *
         */
        public static const FCLICK:String = "fclick";

        /**
         *
         */
        public static const FHOVER:String = "fhover";

        /**
         *
         */
        public static const DEFAULT_CONFIG:XML = <MouseTracker>
            <function id="click"/>
        </MouseTracker>;

        private var _config:XML = DEFAULT_CONFIG;
        private var _view:DisplayObject;
        private var _x:int = -1;
        private var _y:int = -1;
        private var _alt:Boolean = false;
        private var _ctrl:Boolean = false;
        private var _shift:Boolean = false;
        private var _hot:Boolean = false;

        /**
         * @throws Error if config invalid
         */
        public static function validateConfig(config:XML):void
        {
            doValidateConfig(config, EXEMPLAR);
        }

        private static function doValidateConfig(input:XML,
                                                 exemplar:XML):void
        {
            if (input.localName() != exemplar.localName())
            {
                throw new Error("bad element name: " + input.name());
            }

            for each (var child:XML in input.children())
            {
                switch (child.nodeKind())
                {
                case "element":
                    if (exemplar.elements().length() > 0)
                    {
                        var childExemplarXmlList:XMLList = exemplar.elements(child.localName());
                        var childExemplarXml:XML = childExemplarXmlList.length() > 0 ? childExemplarXmlList[0] : <foo/>;
                        doValidateConfig(child, childExemplarXml);
                        continue;
                    }
                    break;

                case "attribute":
                    if (exemplar.attributes().length() > 0)
                    {
                        if (exemplar.attribute(child.name()).length() == 0)
                        {
                            throw new Error("unrecognized attribute: " + child.name());
                        }
                        continue;
                    }
                    break;
                }

                throw new Error(input.name() + " may not have " + child.nodeKind());
            }
        }

        /**
         * Constructor.
         */
        public function MouseTracker(config:XML = null)
        {
            if (config != null)
            {
                this.config = config;
            }
        }

        /**
         *
         * <pre>
         *  &lt;MouseTracker&gt;
         *      &lt;function id="1" alt="false" ctrl="false"/&gt;
         *      &lt;function id="2" alt="true"/&gt;
         *      &lt;function id="3" ctrl="true" onDown="true"/&gt;
         *  &lt;/MouseTracker&gt;
         * </pre>
         */
        public function set config(config:XML):void
        {
            validateConfig(config);
            _config = config;
        }

        public function set view(view:DisplayObject):void
        {
            Listeners.remove(_view, eventMap);
            _view = view;
            Listeners.add(_view, eventMap);
        }

        private function get eventMap():Object
        {
            return {
                "mouseDown": handleMouseDown,
                "mouseUp": handleMouseUp,
                "mouseOver": handleMouseMove,
                "mouseOut": handleMouseOut,
                "mouseMove": handleMouseMove,
                "keyDown": handleKey,
                "keyUp": handleKey
            };
        }

        private function handleMouseDown(event:MouseEvent):void
        {
            updateMouseState(event);

            var func:String = getCurrentFunc(true);
            if (func != null)
            {
                dispatchClick(func, event);
            }

            _hot = func == null;

            // Prevent my parent (if any) from getting hot!
            event.stopPropagation();

            dispatchHover(event);
        }

        private function handleMouseUp(event:MouseEvent):void
        {
            updateMouseState(event);

            if (isDrag())
            {
                var func:String = getCurrentFunc(false);
                if (func != null)
                {
                    dispatchClick(func, event);
                }
            }

            _hot = false;
            dispatchHover(event);
        }

        private function handleMouseMove(event:MouseEvent):void
        {
            updateMouseState(event);

            if (!event.buttonDown)
            {
                _hot = false;
            }

            if (isDrag())
            {
                dispatchHover(event);
            }
        }

        private function handleMouseOut(event:MouseEvent):void
        {
            updateMouseState(event);
            dispatchHover(event);
        }

        private function handleKey(event:KeyboardEvent):void
        {
            updateKeyState(event);

            if (isDrag())
            {
                dispatchHover();
            }
        }

        private function dispatchClick(func:String, event:MouseEvent):void
        {
            dispatchEvent(FCLICK, { func: func,
                                    mouseEvent: event });
        }

        private function dispatchHover(event:MouseEvent = null):void
        {
            var latentFunc:String = isDrag() ? getCurrentFunc(false) : null;
            dispatchEvent(FHOVER, { mouseEvent: event,
                                    latentFunc: latentFunc });
        }

        private function dispatchEvent(type:String, data:Object):void
        {
            _view.dispatchEvent(VEvent.create(type, data));
        }

        private function updateMouseState(event:MouseEvent):void
        {
            if (event.type == MouseEvent.MOUSE_OUT)
            {
                // Not interested in the point of departure.
                _x = -1;
                _y = -1;
            }
            else
            {
                _x = event.localX;
                _y = event.localY;
            }
            _alt = event.altKey;
            _ctrl = event.ctrlKey;
            _shift = event.shiftKey;
        }

        private function updateKeyState(event:KeyboardEvent):void
        {
            _alt = event.altKey;
            _ctrl = event.ctrlKey;
            _shift = event.shiftKey;
        }

        private function isMouseInside():Boolean
        {
            return _x >= 0 && _x < _view.width &&
                   _y >= 0 && _y < _view.height;
        }

        private function isDrag():Boolean
        {
            return isMouseInside() && _hot;
        }

        private function getCurrentFunc(onDown:Boolean = false):String
        {
            var matches:Array = [];

            for each (var funcXml:XML in _config.elements())
            {
                if (onDown == boolAttr(funcXml, "onDown") &&
                    keyStateMatch(funcXml))
                {
                    matches.push(funcXml);
                }
            }

            if (matches.length == 1)
            {
                return matches[0].@id;
            }

            return null;
        }

        private function keyStateMatch(funcXml:XML):Boolean
        {
            return (funcXml.@alt.length() == 0 ||
                       _alt == boolAttr(funcXml, "alt")) &&
                   (funcXml.@ctrl.length() == 0 ||
                        _ctrl == boolAttr(funcXml, "ctrl")) &&
                   (funcXml.@shift.length() == 0 ||
                        _shift == boolAttr(funcXml, "shift"));
        }

        private function boolAttr(xml:XML, name:String, dflt:Boolean = false):Boolean
        {
            switch (xml.attribute(name).toString())
            {
            case "true":
                return true;
            case "false":
                return false;
            }
            return dflt;
        }
    }
}
