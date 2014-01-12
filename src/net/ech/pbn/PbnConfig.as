
package net.ech.pbn
{
    /**
     * Static description of a Paint By Numbers puzzle.
     *
     * @author James Echmalian, ech@ech.net
     */
    public class PbnConfig
    {
        private var _xml:XML;

        /**
         * Load from XML.
         */
        public function PbnConfig(xml:XML)
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
        public function copy():PbnConfig
        {
            return new PbnConfig(_xml);
        }

        /**
         * Get the number of rows.
         */
        public function get rows():int
        {
            return _xml.row.length();
        }

        /**
         * Get the number of columns.
         */
        public function get columns():int
        {
            return _xml.column.length();
        }

        /**
         * Get the row inputs.
         */
        public function get rowInputs():Array
        {
            return parseInputs(_xml.row);
        }

        /**
         * Get the column inputs.
         */
        public function get columnInputs():Array
        {
            return parseInputs(_xml.column);
        }

        /**
         * Get the title.
         */
        public function get title():String
        {
            return _xml.title.toString();
        }

        /**
         * @throws Error if the config doesn't stack up
         */
        public function validate():void
        {
            if (rows < 1)
            {
                throw new Error("invalid row count: " + rows);
            }

            if (columns < 1)
            {
                throw new Error("invalid column count: " + columns);
            }

            var rowSum:int = validateAndSum(rowInputs, "row", columns);
            var columnSum:int = validateAndSum(columnInputs, "column", rows);

            if (rowSum != columnSum)
            {
                throw new Error("row sum and column sum don't match (" + rowSum + " != " + columnSum + ")");
            }
        }

        private function parseInputs(inputList:XMLList):Array
        {
            var result:Array = [];

            for each (var inputXML:XML in inputList)
            {
                var values:Array = inputXML.toString().split(",");
                for (var i:int = 0; i < values.length; ++i)
                {
                    values[i] = int(values[i]);
                }
                result.push(values);
            }

            return result;
        }

        private function validateAndSum(inputs:Array, designation:String, max:int):int
        {
            var total:int = 0;

            inputs.forEach(function(element:Array, index:int, ... ignored):void
            {
                var subDesig:String = designation + " #" + index;
                var subtotal:int = 0;

                element.forEach(function(value:int, ... ign2):void
                {
                    if (value < 1)
                    {
                        throw new Error(subDesig + ": invalid value (" + value + ")");
                    }
                    subtotal += value;
                });

                if (subtotal < 1)
                {
                    throw new Error(subDesig + ": not enough input");
                }

                if (subtotal + element.length - 1 > max)
                {
                    throw new Error(subDesig + ": input exceeds available space");
                }

                total += subtotal;
            });

            return total;
        }
    }
}
