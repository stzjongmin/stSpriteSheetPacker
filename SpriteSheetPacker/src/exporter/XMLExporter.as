package exporter
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	import spriteSheet.SpriteInfo;
	import spriteSheet.SpriteSheetInfo;
	
	import utils.Resources;
	

	public class XMLExporter
	{		
		// XML NODE NAME
		private const XML_ROOT_NODE:String = "sprite_sheet";
		private const XML_SHEET_IMAGE_NODE:String = "sprite_sheet_image";
		
		private const XML_NODE:String = "sprite";
		private const XML_NODE_NAME:String = "name";
		private const XML_NODE_X:String = "x";
		private const XML_NODE_Y:String = "y";
		private const XML_NODE_WIDTH:String = "width";
		private const XML_NODE_HEIGHT:String = "height";
		private const XML_NODE_PATH:String = "path";
		
		private var _rootNode:XML;
		
		/**
		 * XML 파일로 스프라이트 정보들을 추출합니다. 
		 * @param spriteSheetInfo 스프라이트 시트 정보 객체
		 */
		public function Export(spriteSheetInfo:SpriteSheetInfo):void
		{			
			// XML 데이터를 생성
			_rootNode = MakeXMLNode(spriteSheetInfo);
					
			// 파일에 XML 관련 데이터를 씀		
			var destString:String;
			if( Capabilities.os.toLowerCase().indexOf("win") >= 0 )
			{
				destString = File.applicationDirectory.resolvePath(Resources.EXPORT_XML_FILE_PATH).nativePath;
			}
			else
			{
				destString = File.applicationStorageDirectory.resolvePath(Resources.EXPORT_XML_FILE_PATH).nativePath;
			}
			
			var destFile:File = new File( destString	);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(destFile, FileMode.WRITE);
						
			fileStream.writeUTFBytes(_rootNode.toXMLString());
			fileStream.close();
			
			// 사용한 자원 해제
			fileStream = null;
			destFile = null;
			
			ClearAllNode(_rootNode);
		}
		
		/**
		 * XML을 만들기 위해 사용한 자원 해제 
		 * @param node XML 의 루트 노드
		 */
		private function ClearAllNode(node:XML):void
		{
			for(var i:uint=0; i<node.children().length(); ++i)
			{
				ClearAllNode(node.children()[i]);
			}
			node = null;
		}
		
		/**
		 * 스프라이트 이미지들에 대한 정보로 XML 데이터를 구성합니다. 
		 * @param spriteSheetInfo 스프라이트 시트 정보
		 * @return 구성한 XML Root 노드
		 * 
		 */
		private function MakeXMLNode(spriteSheetInfo:SpriteSheetInfo):XML
		{
			// 루트 노드 생성
			var rootNode:XML = XML(GetXMLNodeString(XML_ROOT_NODE, ""));
			
			// 스프라이트 시트 이미지 정보 추가
			var sheetImageNode:XML = XML(GetXMLNodeString(XML_SHEET_IMAGE_NODE, ""));
			sheetImageNode.appendChild(XML(GetXMLNodeString(XML_NODE_PATH, Resources.EXPORT_PNG_FILE_PATH)));
			sheetImageNode.appendChild(XML(GetXMLNodeString(XML_NODE_WIDTH, spriteSheetInfo.width.toString() )));
			sheetImageNode.appendChild(XML(GetXMLNodeString(XML_NODE_HEIGHT, spriteSheetInfo.height.toString() )));
			rootNode.appendChild(sheetImageNode);
			
			// 각각의 스프라이트 정보 추가
			var spriteInfoVec:Vector.<SpriteInfo> = spriteSheetInfo.spritesVec;
			for(var i:uint = 0; i<spriteInfoVec.length; ++i)
			{
				var spriteNode:XML = XML(GetXMLNodeString( XML_NODE, ""));
				
				spriteNode.appendChild(XML(GetXMLNodeString( XML_NODE_NAME, spriteInfoVec[i].imageInfo.fileName )));
				spriteNode.appendChild(XML(GetXMLNodeString( XML_NODE_PATH, spriteInfoVec[i].imageInfo.filePath )));
				
				spriteNode.appendChild(XML(GetXMLNodeString( XML_NODE_X, spriteInfoVec[i].x.toString( ) )));
				spriteNode.appendChild(XML(GetXMLNodeString( XML_NODE_Y, spriteInfoVec[i].y.toString( ) )));
				spriteNode.appendChild(XML(GetXMLNodeString( XML_NODE_WIDTH, (spriteInfoVec[i].width / spriteSheetInfo.width).toString( ) )));
				spriteNode.appendChild(XML(GetXMLNodeString( XML_NODE_HEIGHT, (spriteInfoVec[i].height / spriteSheetInfo.height).toString( ) )));
				
				rootNode.appendChild(spriteNode);
			}
			
			return rootNode;
		}
		
		/**
		 * 노드 이름과 값으로 XML String 을 생성 
		 * @param nodeName 생성할 노드의 이름
		 * @param value 생성할 노드의 값
		 * @return 생성한 XML String
		 */
		private function GetXMLNodeString(nodeName:String, value:String):String
		{
			return "<" + nodeName + ">" + value + "</" + nodeName + ">";
		}
			
	}
}