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
	
	public class Buffer extends ByteArray
	{
		//this allows us to deal with consecutive bits
		//amqp consolodates consecutive bits into bytes
		protected var accumulator	:Accumulator;
		
		//header properties differ from arguments in
		//method frames.  The inclusion of a property
		//is determined by a bit's value in a flags short
		protected var flags:* = {
			enabled	: false,
			value	: 0,
			count	: 0,
			position: 0,
			current	: function():int {
				return 15 - this.count;
			}
		};
		

		public function Buffer()
		{
			super();
			accumulator = new Accumulator(this);
		}
		
		public function flush():void {
			accumulator.flush();
			if(flags.enabled) {
				position = flags.position;
				writeShort(flags.value);
			}
			position = 0;
		}

		//headers may or may not write a value to the stream
		protected function shouldWrite(val:Object):Boolean {
			
			if(flags.enabled) {
				if (val != null) {
	                flags.value |= (1 << flags.current());
	                flags.count++;
	                return true;
	            } else {
	                flags.count++;
	                return false;
	            }
			}
			
			return true;
		}
		
		protected function shouldRead():Boolean {
			
			if(flags.enabled) {				
	            var bit:int = flags.current();
	            flags.count++;
	            return (flags.value & (1 << bit)) != 0;
			}
			
			return true;
		}
				
		public function writeFlag():void {
			writeBits();
			flags.enabled  = true;
			flags.position = position;
			writeShort(0);
		}
		
		public function readFlag():void {
			flags.enabled  = true;
			flags.value = readUnsignedShort();
		}


		public function writeBit(data:Boolean):void {
			accumulator.writeBit(data);
		}

		public function writeBits():void {
			accumulator.flush();
		}

		public function clearBits():void {
			accumulator.reset();
		}
				
		public function readBit():Boolean {
			if(!shouldRead()) {
				return false;
			}
			return accumulator.readBit();
		}
		
		//Todo: Convert long to date
		public function readTimestamp():Date {
			if(!shouldRead()) {
				return null;
			}
			clearBits();
			var date:Date = new Date();
			var upper:uint = readUnsignedInt();
			var lower:uint = readUnsignedInt();
            date.setTime(lower);
            return date;
		}
		
		//Todo: Convert date to long
		public function writeTimestamp(data:Date):void {
			writeBits();
			if(shouldWrite(data)) {
				writeUnsignedInt(0);
				writeUnsignedInt(data.getTime() * 1000);
			}
		}
		
		public function readTable():FieldTable {
			if(!shouldRead()) {
				return null;
			}
			clearBits();
			var fe:Boolean = flags.enabled;
			flags.enabled = false;
			var table:FieldTable = new FieldTable();
			table.read(this);
			flags.enabled = fe;
			return table;
		}
		
		public function writeTable(data:FieldTable):void {
			writeBits();
			
			if(shouldWrite(data)) {
				if (data == null || data.length == 0) {
	                writeUnsignedInt(0);
				} else {
				   	data.write(this);
				}
			}
		}
		
		public function writeOctet(data:uint):void {
			writeBits();
			if(shouldWrite(data)) {
				writeByte(data);
			}
		}
		
		public function readOctet():uint {
			if(!shouldRead()) {
				return 0;
			}
			clearBits();
			return readUnsignedByte(); 
		}	
		
		public function writeShortInt(data:uint):void {
			writeBits();
			if(shouldWrite(data)) {
				writeShort(data);
			}
		}
		
		public function readShortInt():uint {
			if(!shouldRead()) {
				return 0;
			}
			clearBits();
			return readUnsignedShort();
		}		
		
		public function writeLongInt(data:uint):void {
			writeBits();
			if(shouldWrite(data)) {
				writeUnsignedInt(data);
			}
		}
		
		public function readLongInt():uint {
			if(!shouldRead()) {
				return 0;
			}
			clearBits();
			return readUnsignedInt();
		}			
		
		//do something with String here
		public function readLongLong():Long {
			if(!shouldRead()) {
				return null;
			}
			clearBits();
			return new Long(readUnsignedInt(),readUnsignedInt());
		}
		
		//do something with String here....
		public function writeLongLong(data:Long):void {
			writeBits();
			if(shouldWrite(data)) {
				writeUnsignedInt(data.upper);
				writeUnsignedInt(data.lower);
			}
		}
		
		//TODO: Make sure order is correct
		public function readShortString():String {
			if(!shouldRead()) {
				return null;
			}
			clearBits();
            return readUTFBytes(readUnsignedByte());
		}
		
		public function writeShortString(data:String):void {
			writeBits();
			if(shouldWrite(data)) {
				writeByte(data.length);
				writeUTFBytes(data);
			}
		}
		
		public function readString():String {
			if(!shouldRead()) {
				return null;
			}
			clearBits();
            return readUTFBytes(readUnsignedByte());
		}
		
		public function writeString(data:String):void {
			writeBits();
			if(shouldWrite(data)) {
				writeUnsignedInt(data.length);
				writeUTFBytes(data);
			}
		}

		public function readLongString():String {		
			if(!shouldRead()) {
				return null;
			}
			clearBits();
			return readUTFBytes(readUnsignedInt());
		}
		
		public function writeLongString(data:String):void {
			writeBits();
			if(shouldWrite(data)) {
				writeUnsignedInt(data.length);
				writeUTFBytes(data);
			}
		}
		
		/*public function readLongString():LongString {		
			return new LongString(this, readUnsignedInt());
		}
		
		public function writeLongString(data:LongString):void {
			writeUnsignedInt(data.length);
			writeBytes(data, 0, data.length);
		}*/
	}
}