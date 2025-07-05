

./lcftrans.exe -u ../../

Get-ChildItem ./* -Include ('*.po') | Foreach-Object {
	if ($_.Name.startswith("Map")) {
		$content = Get-Content -Path $_.Name -Encoding UTF8 -Raw |% {$_-replace 'msgctxt "actors.name"\r\nmsgid "[^"]*"\r\nmsgstr ""\r\n\r\n', '###'}
		$content = $content.trim()
		Set-Content -Path $_.Name -Encoding UTF8 -Value $content
	}
	Set-Content -Path $_.Name -Encoding UTF8 -Value (Get-Content -Path $_.Name -Encoding UTF8 | Select-String -Pattern '^#.*' -NotMatch)
	
	$count = (get-content -Path $_.Name | select-string -pattern "msgstr").length
	if ($count -eq 1) {
		rm $_.Name
	}
}