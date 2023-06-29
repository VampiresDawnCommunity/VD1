Get-ChildItem ./* -Include ('*.lmu', '*.ldb', '*.lmt') | Foreach-Object {
     .\lcf2xml.exe $_.Name
 }