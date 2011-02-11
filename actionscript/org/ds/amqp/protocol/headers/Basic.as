/**
---------------------------------------------------------------------------

Copyright (c) 2009 Dan Simpson

Auto-Generated @ Wed Aug 26 19:21:28 -0700 2009.  Do not edit this file, extend it you must.

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


/*
Documentation

  The Basic class provides methods that support an industry-standard
  messaging model.
 namegrammarcontent
    basic               = C:QOS S:QOS-OK
                        / C:CONSUME S:CONSUME-OK
                        / C:CANCEL S:CANCEL-OK
                        / C:PUBLISH content
                        / S:RETURN content
                        / S:DELIVER content
                        / C:GET ( S:GET-OK content / S:GET-EMPTY )
                        / C:ACK
                        / C:REJECT
 nameruletestamq_basic_08content
  The server SHOULD respect the persistent property of basic messages
  and SHOULD make a best-effort to hold persistent basic messages on a
  reliable storage mechanism.
 nameruletestamq_basic_09content
  The server MUST NOT discard a persistent basic message in case of a
  queue overflow. The server MAY use the Channel.Flow method to slow
  or stop a basic message publisher when necessary.
 nameruletestamq_basic_10content
  The server MAY overflow non-persistent basic messages to persistent
  storage and MAY discard or dead-letter non-persistent basic messages
  on a priority basis if the queue size exceeds some configured limit.
 nameruletestamq_basic_11content
  The server MUST implement at least 2 priority levels for basic
  messages, where priorities 0-4 and 5-9 are treated as two distinct
  levels. The server MAY implement up to 10 priority levels.
 nameruletestamq_basic_12content
  The server MUST deliver messages of the same priority in order
  irrespective of their individual persistence.
 nameruletestamq_basic_13content
  The server MUST support both automatic and explicit acknowledgements
  on Basic content.

*/
package org.ds.amqp.protocol.headers
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import org.ds.amqp.datastructures.*;
	import org.ds.amqp.transport.Buffer;
	import org.ds.amqp.protocol.Header;
	
	public dynamic class Basic extends Header
	{

		//
		public var contentType             :String;

		//
		public var contentEncoding         :String;

		//
		public var headers                 :FieldTable;

		//
		public var deliveryMode            :uint = 1;

		//
		public var priority                :uint;

		//
		public var correlationId           :String;

		//
		public var replyTo                 :String;

		//
		public var expiration              :String;

		//
		public var messageId               :String;

		//
		public var timestamp               :Date;

		//
		public var type                    :String;

		//
		public var userId                  :String;

		//
		public var appId                   :String;

		//
		public var clusterId               :String;


		public function Basic() {
			_classId  = 60;
		}

		public override function writeProperties(buf:Buffer):void {

			buf.writeShortString(this.contentType);
			buf.writeShortString(this.contentEncoding);
			buf.writeTable(this.headers);
			buf.writeOctet(this.deliveryMode);
			buf.writeOctet(this.priority);
			buf.writeShortString(this.correlationId);
			buf.writeShortString(this.replyTo);
			buf.writeShortString(this.expiration);
			buf.writeShortString(this.messageId);
			buf.writeTimestamp(this.timestamp);
			buf.writeShortString(this.type);
			buf.writeShortString(this.userId);
			buf.writeShortString(this.appId);
			buf.writeShortString(this.clusterId);
		}

		public override function readProperties(buf:Buffer):void {

			this.contentType      = buf.readShortString();
			this.contentEncoding  = buf.readShortString();
			this.headers          = buf.readTable();
			this.deliveryMode     = buf.readOctet();
			this.priority         = buf.readOctet();
			this.correlationId    = buf.readShortString();
			this.replyTo          = buf.readShortString();
			this.expiration       = buf.readShortString();
			this.messageId        = buf.readShortString();
			this.timestamp        = buf.readTimestamp();
			this.type             = buf.readShortString();
			this.userId           = buf.readShortString();
			this.appId            = buf.readShortString();
			this.clusterId        = buf.readShortString();
		}
		
		public override function print():void {
			printObj("BasicHeader", this);
		}
	}
}