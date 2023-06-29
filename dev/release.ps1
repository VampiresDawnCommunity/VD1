
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