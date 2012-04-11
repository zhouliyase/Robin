package com.etm.utils
{
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.MD5;
	import com.adobe.crypto.SHA1;
	import com.etm.core.Config;
	import com.etm.utils.objectencoder.ObjectEncoder;
	
	import flash.utils.ByteArray;

	public class Util
	{
		private static var uniqueId:Number=101;

		public static function get messageId():Number
		{
			if(uniqueId==Number.MAX_VALUE)
				uniqueId=101;
			return uniqueId++;
		}
		/**
		 *生成验证头 
		 * @param params 请求参数
		 * @param token 请求token
		 * @return 请求头
		 * 
		 */		
		public static function generateHeader(params:Object, token:String=""):String
		{
			var headerString:String="";
			var timeStamp:int=int(Config.systemTime / 1000);
			var oauth:Object=
				{oauth_version: Config.getConfig(Config.AUTH_VERSION_CFG), oauth_signature_method: Config.getConfig(Config.AUTH_METHOD_CFG),
					 oauth_consumer_key: Config.getConfig(Config.CONSUMER_KEY_CFG), oauth_timestamp: timeStamp.toString(), oauth_nonce: Math.random().toString(), oauth_token: token};
			var temp:Array=[];
			var key:String="";
			for (key in oauth)
			{
				temp.push({key: key, value: oauth[key]});
			}
			temp.sortOn("key");
			var authString:String="";
			for each (var param:Object in temp)
			{
				authString+=param["key"] + "=" + param["value"] + "&";
			}
			authString=authString.substr(0, authString.length - 1);
			var paramString:String="";
			if (params)
			{
				paramString=new ObjectEncoder(params, ObjectEncoder.JSON, true).JsonString;
			}
			var base:String=encodeURIComponent(authString);
			if (paramString)
				base+=('&' + encodeURIComponent(paramString));
//			Debug.info("Authorization Base String:" + base);
			var signature:String=HMAC.hashToBase64(Config.getConfig(Config.SECRET_KEY_CFG), base, SHA1);
			oauth.oauth_signature=signature;
			headerString=JSON.stringify(oauth);
			return headerString;
		}

		
		public static function compressTextData(data:String):ByteArray
		{
			var bytes:ByteArray=new ByteArray();
			bytes.writeUTFBytes(data);
			bytes.compress();
			return bytes;
		}

		public static function unCompressData(data:ByteArray, isText:Boolean=true):*
		{
			data.uncompress();
			data.position=0;
			if (isText)
				return data.readUTFBytes(data.length);
			else
				return data;
		}

		public function Util()
		{
		}
	}
}
