

./lcftrans.exe -u ../../

Get-ChildItem ./* -Include ('*.po') | Foreach-Object {
	Set-Content -Path $_.Name -Encoding UTF8 -Value (Get-Content -Path $_.Name -Encoding UTF8 | Select-String -Pattern '^#.*' -NotMatch)
}