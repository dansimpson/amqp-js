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
	
	//this class helps us store contigous bit values to
	//write as a single byte value
	//it starts with the least signifigant bit for each
	//byte block
	public class Accumulator
	{
		private var bits		:uint 		= 0;
		private var bytes		:ByteArray	= null;
		private var mask		:uint		= 1;
		
		public function Accumulator(bytes:ByteArray)
		{
			this.bytes = bytes;
		}

		public function flush():void {
			if(isDirty) {
				bytes.writeByte(bits);
				reset();
			}
		}
		
		public function get isDirty():Boolean {
			return mask > 1;
		}
		
		//write bit (if true) and shift mask
		public function writeBit(bit:Boolean):void {

			if(mask > 128) {
				flush();
			}
            
            if(bit) {
            	bits |= mask;
            }
            
            mask <<= 1;
		}

		//read a bit from the accumlator and shift mask
		public function readBit():Boolean {
			
			if(mask > 128 || mask == 1) {
				loadByte();
			}
			
			var bit:Boolean = (bits & mask) != 0;
			mask <<= 1;
			
			return bit;
		}
		
		public function reset():void {
			bits = 0;
			mask = 1;
		}
		
		public function loadByte():void {
			bits = bytes.readUnsignedByte();
			mask = 1;
		}

	}
}