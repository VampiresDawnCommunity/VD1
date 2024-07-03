./lcf2xml.exe "RPG_RT.ldb"
$xmlEDB = [xml](Get-Content -Path "RPG_RT.edb" -Encoding UTF8)
$xmlItems = [xml](Get-Content -Path "items.xml" -Encoding UTF8)

foreach ($item in $xmlItems.items.Item) {
	$itemEDB = $xmlEDB.LDB.Database.items.Item | where {$_.id -eq $item.id }
	$itemEDB.easyrpg_order = $item.easyrpg_order
	$itemEDB.easyrpg_category = $item.easyrpg_category
}
rm RPG_RT.edb

$utf8 = [System.Text.UTF8Encoding]::new($false)
$settings = new-object System.Xml.XmlWriterSettings
$settings.CloseOutput = $true
$settings.Indent = $true
$settings.Encoding = $utf8

$writer = [System.Xml.XmlWriter]::Create("RPG_RT.edb", $settings)
$xmlEDB.Save($writer)
$writer.Close()