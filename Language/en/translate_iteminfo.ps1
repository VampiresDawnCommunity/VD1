
./lcftrans.exe -u ../../
	
$htable = @{}
$match = 0
$currKey = ''
foreach($line in Get-Content RPG_RT.ldb.po -Encoding UTF8) {
    if ($line -eq 'msgctxt "items.name"') {
		$match = 1
    }
	elseif ($match -eq 1) {
		$match = 2
		$currKey = $line.substring(6).trim('"')		
		if ($currKey.startswith("$")) {
			$currKey = $currKey.substring(2).trim(" ")
		}
	}
	elseif ($match -eq 2) {
		$match = 0
		$currTrans = $line.substring(7).trim('"')		
		if ($currTrans.startswith("$")) {
			$currTrans = $currTrans.substring(2).trim(" ")
		}
		$htable.Add($currKey, $currTrans)
		$currKey = ''
	}
	else {
		$match = 0
	}
}

$match = 0
foreach($line in Get-Content RPG_RT.ldb.common.po -Encoding UTF8) {
	$pushline = $true
	
    if ($line.startswith('#. ID 12, Line')) {
		$match = 1
    }
	elseif ($match -eq 1) {
		if ($line -eq '#. ChangeHeroName (Actor 23)') {		
			$match = 2
		}
	}
	elseif ($match -eq 2) {
		if ($line -eq 'msgctxt "actors.name"') {
			$match = 3
		}
    }
	elseif ($match -eq 3) {
		$currKey = $line.substring(6).trim('"')
		$match = 4
	}
	elseif ($match -eq 4) {
		$match = 0
		$pushline = $false
		$str = 'msgstr "' + $htable[$currKey] + '"'
		$str | Out-File -FilePath RPG_RT.ldb.common.po.tmp -Encoding UTF8 -Append
		
		$currKey = ''
	}
	else {
		$match = 0
	}
	
	if($pushline -eq $true) {
		$line | Out-File -FilePath RPG_RT.ldb.common.po.tmp -Encoding UTF8 -Append
	}
}

remove-item RPG_RT.ldb.common.po
move-item -Path RPG_RT.ldb.common.po.tmp -Destination RPG_RT.ldb.common.po

./update.ps1