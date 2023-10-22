
./lcf2xml.exe Map0003.lmu

$contents = [System.IO.File]::ReadAllText("Map0003.emu")
$versionString = [RegEx]::Match($contents, "<parameters>0 562 562 0 0 ([0-9]*) 0</parameters>").Groups[1].Value

$newBuild = [int]$versionString + 1
Write-Host ("Current Build: " + $newBuild)

$contents = $contents.Replace("<parameters>0 562 562 0 0 " + $versionString + " 0</parameters>", "<parameters>0 562 562 0 0 " + $newBuild + " 0</parameters>")
$contents = $contents.Replace("<parameters>0 2225 2225 0</parameters>", "<parameters>0 2225 2225 1</parameters>")
[System.IO.File]::WriteAllText("Map0003.emu", $contents)

./lcf2xml.exe "Map0003.emu"

rm *.emu
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
cp -R System build/
cp -R Title build/
cp *.lmu build/
cp RPG_RT.ldb build/
cp RPG_RT.lmt build/
cp RPG_RT.ini build/
cp EasyRPG.ini build/
cp Player.exe build/
cp RPG_RT.exe build/
cp "_Start with English translation.bat" build/

cp debug.bat build/
cp debug_en.bat build/

mv build "Vampires Dawn - Community Edition"
Compress-Archive -Path "Vampires Dawn - Community Edition" -DestinationPath "Vampires Dawn - Community Edition (Build $($newBuild)).zip"

rm "Vampires Dawn - Community Edition" -r -fo