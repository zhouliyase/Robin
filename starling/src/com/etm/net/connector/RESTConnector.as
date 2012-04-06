package com.etm.net.connector
{
	import com.etm.core.Config;
	import com.etm.core.Etm;
	import com.etm.utils.Debug;
	import com.etm.utils.Util;
	import com.etm.utils.objectencoder.ObjectEncoder;

	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	/**
	 * REST连接器，用于创建REST连接
	 */
	public class RESTConnector extends Connector
	{

		/**
		 * 新建一个REST请求
		 * @param url: 请求地址
		 * @param command_name:  请求的接口名称，多级结构使用.号分割
		 * @param params: key-value形式定义的服务请求参数
		 * */
		public function RESTConnector(command_name:String, command_args:Object, gateway:String, retryCount:int=0)
		{
			_serverAdress=gateway;
			_method="http";
			_request=new URLRequest(_serverAdress);
			super(command_name, command_args, retryCount);
			attachHeader();
		}

		private var _urlLoader:URLLoader;
		private var _request:URLRequest;

		protected function addLoaderEventListeners(target:IEventDispatcher):void
		{
			target.addEventListener(Event.COMPLETE, onCompleteHandler);
			target.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			target.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandler);
		}

		private function attachHeader():void
		{
			_request.requestHeaders.push(new URLRequestHeader("Authorization", Util.generateHeader(_commandArgs, Config.getConfig(Config.SESSION_ID))));
		}

		override protected function clear():void
		{
			removeLoaderEventListeners(_urlLoader);
			super.clear();
		}

		override protected function doExecute():void
		{
			_urlLoader=new URLLoader();
			_urlLoader.dataFormat=URLLoaderDataFormat.BINARY;
			addLoaderEventListeners(_urlLoader);
			_request.method=URLRequestMethod.POST;
			createParams(_request);
			_urlLoader.load(_request);
			super.doExecute();
			Debug.info("Send REST request {0} to {1}", this, _commandArgs, destination);
		}

		/**
		 *   @private
		 */
		protected function onCompleteHandler(evt:Event):void
		{
			var result:ByteArray;
			try
			{
				result=_urlLoader.data as ByteArray;
				_data=result.readObject();
				Debug.info("Get REST response {0} from {1}", this, result, destination);
				if (_data.code == 200)
				{
					notifyComplete(this);
				}
				else
				{
					notifyError(this);
				}
			}
			catch (e:Error)
			{
				notifyError(this);
			}
		}


		/**
		 *   @private
		 */
		protected function onErrorHandler(evt:ErrorEvent):void
		{
			Debug.error("Get REST error {0} from {1}", this, evt.text, destination);
			notifyError(this);
		}

		/**
		 *   @private
		 */
		protected function onProgressHandler(evt:ProgressEvent):void
		{
			this._completeNum=evt.bytesLoaded;
			this._totalNum=evt.bytesTotal;
			notifyProgress(this);
		}

		protected function removeLoaderEventListeners(target:IEventDispatcher):void
		{
			target.removeEventListener(Event.COMPLETE, onCompleteHandler);
			target.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			target.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorHandler);
		}

		private function createParams(request:URLRequest):void
		{
			try
			{
				var cdata:ByteArray=new ByteArray();
				cdata.writeObject(_commandArgs);
				request.contentType="application/octet-stream";
				request.data=cdata;
			}
			catch (e:Error)
			{
				throw new Error("Can't parse parameters for the request.");
			}
		}
	}
}
