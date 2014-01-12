package
{
    import mx.core.UIComponent;
    import net.ech.events.*;
    import net.ech.sudoku.*;

    public class SudsAppController
    {
        private var internalController:SudokuController;
        private var externalBridge:ExternalInvocationBridge;
        private var internalLink:InvocationAdapter;
        private var outgoingLink:ExternalInvocationAdapter;
        private var incomingLink:InvocationAdapter;

        public function SudsAppController()
        {
            internalController = new SudokuController();
            externalBridge = new ExternalInvocationBridge();

            internalLink = new InvocationAdapter();
            internalLink.handler = internalController;

            outgoingLink = new ExternalInvocationAdapter();
            outgoingLink.bridge = externalBridge;

            incomingLink = new InvocationAdapter();
            incomingLink.dispatcher = externalBridge;
            incomingLink.handler = internalController;
            incomingLink.unhandledInvocationIsError = true;
        }

        public function initialize():void
        {
            internalController.initialize();
            externalBridge.initialize();
        }

        public function set model(value:SudokuModel):void
        {
            internalController.model = value;
        }

        public function set application(value:UIComponent):void
        {
            outgoingLink.dispatcher = value;
        }

        public function set view(value:UIComponent):void
        {
            internalLink.dispatcher = value;
        }

        public function set puzzleService(value:PuzzleService):void
        {
            internalController.puzzleService = value;
        }
    }
}
