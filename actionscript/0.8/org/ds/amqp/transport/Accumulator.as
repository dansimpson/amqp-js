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