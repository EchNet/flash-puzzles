/** */

package net.ech.fence
{
    /**
     * Static description of a Fences puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class FencesConfig
    {
        private var _xml:XML = <config/>;

        /**
         * Load from XML.
         */
        public function FencesConfig(xml:XML)
        {
            _xml = xml.copy();
        }

        /**
         * Create XML.
         */
        public function serialize():XML
        {
            return _xml.copy();
        }

        /**
         * Clone this.
         */
        public function copy():FencesConfig
        {
            return new FencesConfig(_xml);
        }

        /**
         * Number of rows.
         */
        public function get rows():int
        {
            return _xml.row.length();
        }

        /**
         * Number of columns.
         */
        public function get columns():int
        {
            var columns:int = 0;

            for each (var rowXML:XML in _xml.row)
            {
                columns = Math.max(columns, rowXML.toString().split(",").length);
            }

            return columns;
        }

        /**
         * Get an array of nodes.  Each item in the array is a generic
         * object having the following properties:
         * <li>row:int(0..rows-1)</li>
         * <li>column:int(0..columns-1)</li>
         * <li>number:int(1..8)</li>
         *
         * Modifying the array or its contents has no effect on this template.
         */
        public function get nodes():Array
        {
            var array:Array = [];

            var row:int = 0;

            for each (var rowXML:XML in _xml.row)
            {
                var nodes:Array = rowXML.toString().split(",");
                for (var column:int = 0; column < nodes.length; ++column)
                {
                    var val:String = nodes[column].replace(/ /g, "");
                    if (val != "")
                    {
                        var number:int = int(val)
                        array.push({ row: row, column: column, number: number });
                    }
                }
                ++row;
            }

            return array;
        }
    }
}
