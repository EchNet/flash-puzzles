/**
 *
 */

package net.ech.mines
{
    /**
     * Properties of a Minesweeper puzzle that may be changed while the
     * user interaction is in progress.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class MinesOptions
    {
        [Bindable]
        /**
         * Name of selected view.  Null indicates default.
         */
        public var viewName:String;

        [Bindable]
        /**
         * Whether the question mark tag is usable.
         */
        public var marksQ:Boolean = true;

        /**
         *
         */
        public function copy():MinesOptions
        {
            var theCopy:MinesOptions = new MinesOptions;
            theCopy.viewName = viewName;
            theCopy.marksQ = marksQ;
            return theCopy;
        }
    }
}
