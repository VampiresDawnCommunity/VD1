Get-ChildItem ./* -Include ('*.emu', '*.edb', '*.emt') | Foreach-Object {
     .\lcf2xml.exe $_.Name
 }