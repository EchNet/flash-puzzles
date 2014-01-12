package net.ech.sudoku.solver
{
    import flash.utils.Timer;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;

    /**
     * Class TechniqueManager is responsible for ..
     */
    public class TechniqueManager extends EventDispatcher
    {
        private static var TECHNIQUES_PER_TICK:int = 5;

        public var stumped:Boolean = false;
        public var solved:Boolean = false;

        private var grid:SolutionModel;
        private var techniques:Array;
        private var going:Boolean = false;
        private var techIndex:int = -1;
        private var timer:Timer;
        private var found:Boolean = false;

        /**
         * Constructor.
         */
        public function TechniqueManager(grid:SolutionModel)
        {
            this.grid = grid;

            // Build the techniques table.
            techniques = new Array();
            techniques.push(new Exclusion(grid, true, false, false));
            techniques.push(new Exclusion(grid, false, true, false));
            techniques.push(new Exclusion(grid, false, false, true));
            techniques.push(new Slicer(grid, 1));
            techniques.push(new Slicer(grid, 2));
            techniques.push(new Slicer(grid, 3));
            techniques.push(new Slicer(grid, 4));
            techniques.push(new Slicer(grid, 5));
            techniques.push(new Slicer(grid, 6));
            techniques.push(new Slicer(grid, 7));
            techniques.push(new Slicer(grid, 8));
            techniques.push(new Slicer(grid, 9));
            techniques.push(new Exclusion(grid, true, true, false));
            techniques.push(new Exclusion(grid, true, false, true));
            techniques.push(new Exclusion(grid, false, true, true));
            techniques.push(new Exclusion(grid, true, true, true));
        }

        [Bindable("advance")]
        /**
         * Return true if this TechniqueManager is working.
         */
        public function get working():Boolean
        {
            return techIndex >= 0;
        }

        [Bindable("advance")]
        /**
         * Return the relative level of the current technique.  While this
         * TechniqueManager is not working, is zero.
         */
        public function get currentLevel():int
        {
            var level:int;

            if (techIndex >= 0)
            {
                level = getCurrentTechnique().level;
            }

            return level;
        }

        /**
         * Find something.
         */
        public function step():void
        {
            going = false;
            start();
        }

        /**
         * Keep finding something until solved or stumped.
         */
        public function go():void
        {
            going = true;
            start();
        }

        private function start():void
        {
            stumped = false;
            solved = false;

            resetIndex();

            if (timer == null)
            {
                timer = new Timer (100);
                timer.addEventListener(TimerEvent.TIMER, tick);
            }
            timer.start();
            tick();
        }

        /**
         * Stop the solution in progress.
         */
        public function stop():void
        {
            going = false;
            clearIndex();
            timer.stop();
        }

        private function resetIndex():void
        {
            techIndex = 0;
            dispatchEvent(new Event("advance"));
            found = false;
        }

        private function clearIndex():void
        {
            dispatchEvent(new Event("advance"));
            techIndex = -1;
        }

        private function tick(event:TimerEvent = null):void
        {
            if (boardIsSolved())
            {
                solved = true;
                stop();
            }

            for (var tcount:int = 0; tcount < TECHNIQUES_PER_TICK; ++tcount)
            {
                var tech:Technique = getCurrentTechnique();
                if (tech.find())
                {
                    if (!going)
                    {
                        stop();
                        break;
                    }
                }

                techIndex += 1;
                if (techIndex >= techniques.length)
                {
                    if (!found)
                    {
                        stumped = true;
                        stop();
                        break;
                    }
                    resetIndex();
                }
                else
                {
                    dispatchEvent(new Event("advance"));
                }
            }
        }

        private function boardIsSolved():Boolean
        {
            return new EmptyCellCounter(grid).count() == 0;
        }

        private function getCurrentTechnique():Technique
        {
            var tech:Technique = null;

            if (techIndex >= 0)
            {
                tech = Technique(techniques[techIndex]);
            }

            return tech;
        }
    }
}
