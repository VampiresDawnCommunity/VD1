
./lcf2xml.exe Map0003.lmu

$contents = [System.IO.File]::ReadAllText("Map0003.emu")
$versionString = [RegEx]::Match($contents, "<parameters>0 562 562 0 0 ([0-9]*) 0</parameters>").Groups[1].Value

$newBuild = [int]$versionString + 1
Write-Host ("Current Build: " + $newBuild)

$contents = $contents.Replace("<parameters>0 562 562 0 0 " + $versionString + " 0</parameters>", "<parameters>0 562 562 0 0 " + $newBuild + " 0</parameters>")
$contents = $contents.Replace("<parameters>0 2225 2225 0</parameters>", "<parameters>0 2225 2225 1</parameters>")
[System.IO.File]::WriteAllText("Map0003.emu", $contents)

./lcf2xml.exe "Map0003.emu"

./lcf2xml.exe "RPG_RT.ldb"
$contents = [System.IO.File]::ReadAllText("RPG_RT.edb")
$contents = $contents.Replace("<parameters>0 562 562 0 0 " + $versionString + " 0</parameters>", "<parameters>0 562 562 0 0 " + $newBuild + " 0</parameters>")
$contents = $contents.Replace("_use_rpg2k_battle_system>F</", "_use_rpg2k_battle_system>T</")
$contents = $contents.Replace("_battle_use_rpg2ke_strings>F</", "_battle_use_rpg2ke_strings>T</")
$contents = $contents.Replace("_use_rpg2k_battle_commands>F</", "_use_rpg2k_battle_commands>T</")
$contents = $contents.Replace("<encounter></encounter>", "<encounter>%S erscheint !</encounter>")
$contents = $contents.Replace("<escape_success></escape_success>", "<escape_success>Ihr flieht in Schande ...</escape_success>")
[System.IO.File]::WriteAllText("RPG_RT.edb", $contents)
./lcf2xml.exe "RPG_RT.edb"

rm *.emu

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

((Get-Content -path RPG_RT.edb -Raw) -replace "<string>NEWLINE</string>","<string>`n</string>") | Set-Content -Path RPG_RT_.edb

./lcf2xml.exe RPG_RT_.edb

rm RPG_RT.edb
rm RPG_RT_.edb

if (test-path lcf2xml.exe) {
  remove-item lcf2xml.exe
}
if (test-path RPG_RT.edb) {
  remove-item RPG_RT.edb
}
if (test-path RPG_RT.emt) {
  remove-item RPG_RT.emt
}
if (test-path easyrpg_log.txt) {
  remove-item easyrpg_log.txt
}
cp dev/CE_Release.png CharSet/CE_Debug.png
cp dev/CE_Loot01_release.png CharSet/CE_Loot01.png
cp dev/CE_Loot02_release.png CharSet/CE_Loot02.png

python -m mkdocs build -f dev/vdce-docs/mkdocs.yml -d ../../_Documentation/

mkdir build
cp -R _Extras build/
cp -R _Documentation build/
cp -R Backdrop build/
cp -R Battle build/
cp -R CharSet build/
cp -R ChipSet build/
cp -R FaceSet build/
cp -R Font build/
cp -R GameOver build/
cp -R Language build/
cp -R Monster build/
cp -R Music build/
cp -R Panorama build/
cp -R Picture build/
cp -R Sound build/
cp -R SoundFont build/
cp -R System build/
cp -R Text build/
cp -R Title build/
cp *.lmu build/
cp RPG_RT_.ldb build/RPG_RT.ldb
cp RPG_RT.lmt build/
cp RPG_RT.ini build/
cp EasyRPG.ini build/
cp Player.exe build/
cp easyrpg.soundfont build/
rm -r build/Music/mp3/

rm RPG_RT_.ldb

#cp debug.bat build/

mv build "Vampires Dawn - Community Edition"
Compress-Archive -Path "Vampires Dawn - Community Edition" -DestinationPath "Vampires Dawn - Community Edition (Build $($newBuild)).zip"

rm "Vampires Dawn - Community Edition" -r -fo