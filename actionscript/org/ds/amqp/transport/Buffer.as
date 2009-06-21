/**
---------------------------------------------------------------------------

Copyright (c) 2009 Dan Simpson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

---------------------------------------------------------------------------
**/

package org.ds.amqp.transport
{
	import flash.utils.ByteArray;
	
	import org.ds.amqp.datastructures.FieldTable;
	import org.ds.amqp.datastructures.Long;
	import org.ds.amqp.protocol.Stream;
	
	public class Buffer extends ByteArray
	{

		public function Buffer()
		{
			super();
		}

		//Todo: Convert long to date
		public function readTimestamp():Date {
			var date:Date = new Date();
			var long:Long = readLong();
            date.setTime(long.lower);
            return date;
		}
		
		//Todo: Convert date to long
		public function writeTimestamp(data:Date):void {
			writeLong(new Long(0,data.getTime() * 1000));
		}
		
		public function readTable():FieldTable {
			var table:FieldTable = new FieldTable();
			table.read(this);
			return table;
		}
		
		public function writeTable(table:FieldTable):void {
			

			
			if (table == null) {
                writeUnsignedInt(0);
			} else {
				var b:Buffer = new Buffer();
				table.write(b);
				writeBytes(b);
			   	//table.write(this);
			}
		}
		
		public function writeUnsignedByte(data:uint):void {
			writeByte(data);
		}
		
		public function writeUnsignedShort(data:uint):void {
			writeShort(data);
		}
		
		
		
		//do something with String here
		public function readLong():Long {
			return new Long(readUnsignedInt(),readUnsignedInt());
		}
		
		//do something with String here....
		public function writeLong(data:Long):void {
			writeUnsignedInt(data.upper);
			writeUnsignedInt(data.lower);
		}
		
		//TODO: Make sure order is correct
		public function readShortString():String {
            return readUTFBytes(readUnsignedByte());
		}
		
		public function writeShortString(data:String):void {
			writeUnsignedByte(data.length);
			writeUTFBytes(data);
		}
		
		public function readLongString():String {
			return readUTFBytes(readUnsignedInt());
		}
		
		public function writeLongString(data:String):void {
			writeUnsignedInt(data.length);
			writeUTFBytes(data);
		}
	}
}