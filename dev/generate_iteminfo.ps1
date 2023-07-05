
./lcf2xml.exe RPG_RT.ldb
$xml = [xml](Get-Content -Path RPG_RT.edb -Encoding UTF8)
$node = $xml.LDB.Database.commonevents.CommonEvent | where {$_.id -eq '0012'}
$commands = $node.event_commands
$node.RemoveChild($commands)

$commands = $xml.CreateElement("event_commands")

$newNode = [xml]"<EventCommand><code>10210</code><indent>0</indent><string></string><parameters>0 2228 2228 1</parameters></EventCommand>"
$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		
foreach ($itemNode in $xml.LDB.Database.items.ChildNodes) {

	$id = $itemNode.id.trimstart("0")
	$name = $itemNode.name.trim(" ")
	
	if ($name.length -gt 0 ) {
	
		$newNode = [xml]"<EventCommand><code>12010</code><indent>0</indent><string></string><parameters>1 857 0 $($id) 0 0</parameters></EventCommand>"
		$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
	
		if ($name.startswith("$")) {
			$name = $name.substring(2).trim(" ")
			
			$newNode = [xml]"<EventCommand><code>10210</code><indent>1</indent><string></string><parameters>0 2228 2228 0</parameters></EventCommand>"
			$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		}
		$newNode = [xml]"<EventCommand><code>10610</code><indent>1</indent><string>$($name)</string><parameters>23</parameters></EventCommand>"
		$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		
		$newNode = [xml]"<EventCommand><code>12120</code><indent>1</indent><string></string><parameters>1</parameters></EventCommand>"
		$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		
		$newNode = [xml]"<EventCommand><code>10</code><indent>1</indent><string></string><parameters></parameters></EventCommand>"
		$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		
		$newNode = [xml]"<EventCommand><code>22011</code><indent>0</indent><string></string><parameters></parameters></EventCommand>"
		$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		
		Write-Host "$($id) : $($name)"
	}
}

$newNode = [xml]"<EventCommand><code>10210</code><indent>0</indent><string></string><parameters>0 2228 2228 0</parameters></EventCommand>"
$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))
		
$newNode = [xml]"<EventCommand><code>10610</code><indent>0</indent><string>Nichts</string><parameters>23</parameters></EventCommand>"
$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))

$newNode = [xml]"<EventCommand><code>12110</code><indent>0</indent><string></string><parameters>1</parameters></EventCommand>"
$commands.AppendChild($xml.ImportNode($newNode.EventCommand, $true))

$node.AppendChild($commands)
remove-item RPG_RT.edb

$utf8 = [System.Text.UTF8Encoding]::new($false)
$settings = new-object System.Xml.XmlWriterSettings
$settings.CloseOutput = $true
$settings.Indent = $true
$settings.Encoding = $utf8
$writer = [System.Xml.XmlWriter]::Create("RPG_RT.edb", $settings)

$xml.Save($writer)
$writer.Close()

./lcf2xml.exe RPG_RT.edb
./lcf2xml.exe RPG_RT.ldb