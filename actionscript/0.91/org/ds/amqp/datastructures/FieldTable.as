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

package org.ds.amqp.datastructures
{
	import flash.utils.ByteArray;
	
	import org.ds.logging.Logger;
	import org.ds.amqp.transport.Buffer;

	public dynamic class FieldTable extends Object
	{
		public function FieldTable()
		{
			super();
		}
		
		
		public function retrieve(key:String):* {
			return this[key];
		}
		
		public function store(key:String, val:*):void {
			this[key] = val;
		}
		
		public function storeIf(key:String, val:*):void {
			if(!contains(key)) {
				this[key] = val;
			}
		}
		
		public function contains(key:String):Boolean {
			return this[key] != null;
		}
		 
		public function reset():void {
        	for (var key:String in this) {
                this[key] = null;
                delete this[key];
            }
        }
        
		
		
		public function read(b:Buffer):void {
			
			var length:uint = b.readUnsignedInt();

            if(length == 0) {
            	return;
            }
            
            var start:uint = b.position;
            
            while(b.position < (start + length)) {
                
	            var name:String = b.readShortString();
	            var type:uint 	= b.readUnsignedByte();
	            var data:*		= null;
	            
	            switch(type) {
	                case 83 : //Data
	                    data = b.readLongString();
	                    break;
	                case 73: //Int
	                    data = b.readUnsignedInt();
	                    break;
	                case 84: //Time:
	                    data = b.readTimestamp();
	                    break;
	                case 70: //Field Table:
	                    data = b.readTable();
	                    break;
	                default:
	                    //error
	                    break;
	            }

				storeIf(name, data);
            }

		}
		
		
		public function write(b:Buffer):void {
			
			b.writeUnsignedInt(length);
	       
			for (var key:String in this) {

	            b.writeShortString(key);
	           
            	var o:* = retrieve(key);
            	
            	switch(Object(o).constructor) {
            		case String:
           				b.writeByte(83);
            			b.writeString(o);
            			break;
            		case LongString:
           				b.writeByte(83);
            			b.writeLongString(o);
            			break;
            		case int:
           				b.writeByte(73);
            			b.writeShort(o);
            			break;
            		case Date:
           				b.writeByte(84);
            			b.writeTimestamp(o);
            			break;
            		case FieldTable:
            		    b.writeByte(70);
            			b.writeTable(o);
            			break;
            		default:
            			Logger.log("Invalid Type for FieldTable");
            			break;
            	}
            }
		}
		
		public function get length():uint {
			
			var len:uint = 0;
			var o:Object;
			
            for (var key:String in this) {
            	len += key.length + 1 + 1; //1 byte for size, 1 byte for type
            	o = this[key];
            	
            	switch(Object(o).constructor) {
            		case String:
            			len += (o as String).length + 4;
						break;
            		case LongString:
            			len += (o as LongString).length + 4;
						break;
            		case int:
            			len += 4;
            			break;
            		case Date:
            			len += 8;
            			break;
            		case FieldTable:
            			len += (o as FieldTable).length + 4; //4 for length
            			break;
            		default:
            			Logger.log("Invalid Type for FieldTable");
            			break;
            	}
            }
            
            return len;
		}
		

		public function toByteArray():ByteArray {
			var buf:Buffer = new Buffer();
			write(buf);
			buf.position = 0;
			return buf;
		}
		

	}
}