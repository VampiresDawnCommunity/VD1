
./lcf2xml.exe Map0003.lmu

$introMap = ".\Map0003.emu"
$contents = [System.IO.File]::ReadAllText($introMap)
$versionString = [RegEx]::Match($contents, "<parameters>0 562 562 0 0 ([0-9]*) 0</parameters>").Groups[1].Value

$newBuild = [int]$versionString + 1
Write-Host ("Current Build: " + $newBuild)

$contents = $contents.Replace("<parameters>0 562 562 0 0 " + $versionString + " 0</parameters>", "<parameters>0 562 562 0 0 " + $newBuild + " 0</parameters>")
[System.IO.File]::WriteAllText($introMap, $contents)

./lcf2xml.exe Map0003.emu

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
cp dev/ER_Release.png CharSet/ER_Debug.png

mkdir build
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
cp "_Start with English translation.bat" build/

mv build "Vampires Dawn - Community Edition"
Compress-Archive -Path "Vampires Dawn - Community Edition" -DestinationPath "Vampires Dawn - Community Edition (Build $($newBuild)).zip"

rm "Vampires Dawn - Community Edition" -r -fo