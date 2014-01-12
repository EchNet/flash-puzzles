package net.ech.pbn
{
    /**
     * MicroSolver's job is to determine whether there are any solid 
     * conclusions to be made by considering a single set of inputs and
     * a working row or column.
     */
    public class MicroSolver
    {
        private var input:Array;
        private var scratch:Array;

        private static const MARKED_WHITE:int = 0x40;
        private static const MARKED_BLACK:int = 0x80;
        private static const MARKED_BOTH:int = 0xc0;

        public function MicroSolver(input:Array)
        {
            this.input = input;
            this.scratch = new Array(input.length);
        }

        public function solve():Boolean
        {
            scratchIt (0, 0, scratch.length, false);
            return removeScratches();
        }

        /**
         * Scratch out all possible combinations, starting with the 
         * nth input segment, and considering only the scratch zone 
         * between sStart and sEnd.
         */
        private function scratchIt (n:int, sStart:int, sEnd:int,
                                    dryRun:Boolean):Boolean
        {
            if (n >= input.length)
            {
                return true;
            }

            // Figure the amount of wiggle room we have.

            var scratchLen:int = sEnd - sStart;
            var minInputLen:int = computeMinimumInputLength(n);
            var wiggleRoom:int = scratchLen - minInputLen;

            // Stop right away if the input can't fit in the given
            // space.  This happens only if the input is bad.

            if (wiggleRoom < 0)
            {
                return false;
            }

            // Next case to consider: not enough input to make any 
            // conclusion.  Rather than discovering this by trying every
            // possible combination, we can take some short cuts.

            var state:int = scanZone(sStart, sEnd);
            switch (state)
            {
            case 2:
                // Already completely scratched out.  Quick exit.
                return true;
            case 1:
            case 3:
                // Devoid of marks.
                if (wiggleRoom > computeLongestSegment(n))
                {
                    // No conclusions can be made.
                    if (!dryRun)
                    {
                        scratchAmbig(sStart, sEnd);
                    }
                    return true;
                }
            }

            // Must resort to recursion.  Scratch out each workable position
            // of the first segment under consideration.
            //
            // Note: this is somewhat brutish, lots of room to improve.

            var blen:int = inputN(n);
            var scratched:Boolean = false;
            var lastOne:Boolean = n == input.length - 1;

            for (var wlen:int = 0; wlen <= wiggleRoom; ++wlen)
            {
                if ((n % 2) == 0)
                {
                    // Working from the left.
                    if (canScratchWhite(sStart, wlen) &&
                        canScratchBlack(sStart + wlen, blen))
                    {
                        var wStart:int = sStart + wlen + blen;

                        if ((lastOne && canScratchWhite(wStart, sEnd - wStart))
                            ||
                            (!lastOne && 
                             canScratchWhite(wStart, 1) &&
                             scratchIt (n + 1, wStart + 1, sEnd, true)))
                        {
                            if (dryRun) return true;

                            scratchWhite (sStart, wlen);
                            scratchBlack (sStart + wlen, blen);

                            if (lastOne)
                            {
                                scratchWhite(wStart, sEnd - wStart);
                            }
                            else
                            {
                                scratchWhite (sStart + wlen + blen, 1);
                                scratchIt (n + 1, wStart + 1, sEnd, false);
                            }

                            scratched = true;
                        }
                    }
                }
                else
                {
                    var wEnd:int = sEnd - wlen - blen;

                    // Working from the right.
                    if (canScratchWhite(sEnd - wlen, wlen) &&
                        canScratchBlack(wEnd, blen))
                    {
                        if ((lastOne && canScratchWhite(sStart, wEnd - sStart)
                            ||
                            (!lastOne && 
                             canScratchWhite(wEnd - 1, 1) &&
                             scratchIt (n + 1, sStart, wEnd - 1, true))))
                        {
                            if (dryRun) return true;

                            scratchWhite (sEnd - wlen, wlen);
                            scratchBlack (sEnd - wlen - blen, blen);

                            if (lastOne)
                            {
                                scratchWhite (sStart, wEnd - sStart);
                            }
                            else
                            {
                                scratchWhite (sEnd - wlen - blen - 1, 1);
                                scratchIt (n + 1, sStart, sEnd - wlen - blen - 1, false);
                            }

                            scratched = true;
                        }
                    }
                }
            }

            return scratched;
        }

        /**
         * Return the total minimum length of the input segments considered
         * at recursion level n, including minimal white separation.
         */
        private function computeMinimumInputLength(n:int):int
        {
            var len:int = 0;

            for (var i:int = n; i < input.length; ++i)
            {
                if (len > 0) len += 1;
                len += inputN(i);
            }

            return len;
        }

        /**
         * Return the length of the longest input segment considered at
         * recursion level n.
         */
        private function computeLongestSegment(n:int):int
        {
            var longest:int = 0;

            for (var i:int = n; i < input.length; ++i)
            {
                var len:int = inputN(i);
                if (len > longest) longest = len;
            }

            return longest;
        }

        /**
         * Return the index of the input segment corresponding to n.
         */
        private function inputN(n:int):int
        {
            var index:int = 
                (n % 2) == 0 ? (n / 2) : (input.length - ((n + 1) / 2));

            return input[index];
        }

        /**
         * Once scratch is filled with either previously marked colors or 
         * decided ambiguity, there's nothing more to do.
         * This tactic is intended to reduce excessive crunching.
         *
         * Possible return values:
         *   0:  input length zero
         *   1:  entirely undecided
         *   2:  entirely ambiguous
         *   3:  partially undecided, partially ambiguous
         *   4:  entirely colored in
         *   5:  partially colored in, partly undecided
         *   6:  partially colored in, partially ambiguous
         *   7:  a complete mess
         */
        private function scanZone(sStart:int, sEnd:int):int
        {
            var result:int = 0;

            for (var i:int = sStart; i < sEnd && result != 7; ++i)
            {
                switch (scratch[i])
                {
                case PbnModel.WHITE:  // unambiguously white
                case PbnModel.BLACK:  // unambiguously black
                    result |= 4;
                    break;
                case MARKED_BOTH:     // decidedly ambiguous.
                    result |= 2;
                    break;
                default:
                    result |= 1;
                }
            }

            return result;
        }

        private function scratchAmbig(sStart:int, sEnd:int):void
        {
            for (var i:int = sStart; i < sEnd; ++i)
            {
                scratch[i] = MARKED_BOTH;
            }
        }

        private function canScratchWhite(start:int, length:int):Boolean
        {
            for (var i:int = 0; i < length; ++i)
            {
                switch (scratch[start + i])
                {
                case PbnModel.BLACK:
                    return false;
                }
            }
            return true;
        }

        private function canScratchBlack(start:int, length:int):Boolean
        {
            for (var i:int = 0; i < length; ++i)
            {
                switch (scratch[start + i])
                {
                case PbnModel.WHITE:
                    return false;
                }
            }
            return true;
        }

        private function scratchUnit(scratchStart:int, wlen:int, blen:int):void
        {
            scratchWhite(scratchStart, wlen);
            scratchBlack(scratchStart + wlen, blen);

            if (scratchStart + wlen + blen < scratch.length) 
            {
                scratchWhite(scratchStart + wlen + blen, 1);
            }
        }

        private function scratchWhite(start:int, length:int):void
        {
            for (var i:int = 0; i < length; ++i)
            {
                switch (scratch[start + i])
                {
                case PbnModel.UNKNOWN:
                case MARKED_BLACK:
                    scratch[start + i] |= MARKED_WHITE;
                }
            }
        }

        private function scratchBlack(start:int, length:int):void
        {
            for (var i:int = 0; i < length; ++i)
            {
                switch (scratch[start + i])
                {
                case PbnModel.UNKNOWN:
                case MARKED_WHITE:
                    scratch[start + i] |= MARKED_BLACK;
                }
            }
        }

        private function removeScratches():Boolean
        {
            var changed:Boolean = false;

            for (var i:int = 0; i < scratch.length; ++i)
            {
                switch (scratch[i])
                {
                case MARKED_WHITE:
                    scratch[i] = PbnModel.WHITE;
                    changed = true;
                    break;
                case MARKED_BLACK:
                    scratch[i] = PbnModel.BLACK;
                    changed = true;
                    break;
                case MARKED_BOTH:
                    scratch[i] = PbnModel.UNKNOWN;
                    break;
                }
            }

            return changed;
        }
    }
}
