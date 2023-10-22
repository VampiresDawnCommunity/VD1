cp dev/lcf2xml.exe .
cp dev/CE_Debug.png CharSet/CE_Debug.png
cp dev/CE_Loot01_debug.png CharSet/CE_Loot01.png
cp dev/CE_Loot02_debug.png CharSet/CE_Loot02.png

./lcf2xml.exe Map0003.lmu

$contents = [System.IO.File]::ReadAllText("Map0003.emu")

$contents = $contents.Replace("<parameters>0 2225 2225 1</parameters>", "<parameters>0 2225 2225 0</parameters>")
[System.IO.File]::WriteAllText("Map0003.emu", $contents)

./lcf2xml.exe Map0003.emu