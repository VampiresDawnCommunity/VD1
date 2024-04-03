
$utf8 = [System.Text.UTF8Encoding]::new($false)

$ev_codes = @{
	'10860' = 0 #SetEventLocation
	'10870' = 0 #SwapEventLocation
	'10870 ' = 1 #SwapEventLocation (param 2)
	'11210' = 1 #ShowAnimation
	'11320' = 0 #FlashEvent
	'11330' = 0 #SetMoveRoute
	'12330' = 1 #CallEvent
}

$ev_codes_texts = @{
	'10110' = 'ShowMessage'
	'20110' = 'ShowMessage2'
	#'10140' = 'ShowChoices'
}

$xml = [xml](Get-Content -Path RPG_RT.edb -Encoding UTF8)
$all_commonevents = $xml.LDB.Database.commonevents.CommonEvent

foreach ($commonevent in $all_commonevents) {
	$faceset_active = $false
	$all_commands = $commonevent.event_commands.EventCommand
			
	foreach ($cmd in $all_commands) {
		
		if ($cmd.code -eq 10130)
		{
			if ($cmd.string -eq '') {
				$faceset_active = $false
			}
			else {
				$faceset_active = $true
			}
		}
		if ($cmd.code -eq 12330) {			
			$params = $cmd.parameters.Split(' ')
			$ce = [int]$params[1]
			if ($ce -ge 329) {
				if ($ce -le 334) {
					$faceset_active = $true
				}
			}
		}
		
		foreach ($ev_code in $ev_codes_texts.GetEnumerator()) {
			if ($cmd.code -eq $ev_code.Name) {
				$str = $cmd.string.Trim()
				$str = $str	-replace '\\[vV]\[[0-9]*\]', '0000'
				$str = $str -replace '\\[a-zA-Z]\[[0-9]*\]', ''
				$str = $str	-replace '\\&[a-zA-Z]*;', ''
				$str = $str	-replace '\\\.', ''
				$str = $str	-replace '\\\|', ''
				$str = $str	-replace '\\\^', ''
				
				if ($faceset_active -eq $true) {
					$overflow = 38
				}
				else {
					$overflow = 50
				}
				if ($str.Length -gt $overflow) {
					Write-Output "Text Overflow at EDB CE$($commonevent.id):"
					Write-Output " ($($str.Length)): $($cmd.string)"
				}
			}
		}
	}
}

Get-ChildItem ./* -Include ('*.emu') | Foreach-Object {
    $mapFile = $_.Name
	 
	$xml = [xml](Get-Content -Path $mapFile -Encoding UTF8)
	
	$all_events = $xml.LMU.Map.Events.Event
	
	foreach ($ev in $all_events) {
	
		$all_eventpages = $ev.pages.EventPage
		
		foreach ($evPage in $all_eventpages) {
			$faceset_active = $false
			$all_commands = $evPage.event_commands.EventCommand
					
			foreach ($cmd in $all_commands) {
				
				if ($cmd.code -eq 10130)
				{
					if ($cmd.string -eq '') {
						$faceset_active = $false
					}
					else {
						$faceset_active = $true
					}
				}
				if ($cmd.code -eq 12330) {			
					$params = $cmd.parameters.Split(' ')
					$ce = [int]$params[1]
					if ($ce -ge 329) {
						if ($ce -le 334) {
							$faceset_active = $true
						}
					}
				}
				
				foreach ($ev_code in $ev_codes_texts.GetEnumerator()) {
					if ($cmd.code -eq $ev_code.Name) {
						$str = $cmd.string.Trim()
						$str = $str	-replace '\\[vV]\[[0-9]*\]', '0000'
						$str = $str -replace '\\[a-zA-Z]\[[0-9]*\]', ''
						$str = $str	-replace '\\&[a-zA-Z]*;', ''
						$str = $str	-replace '\\\.', ''
						$str = $str	-replace '\\\|', ''
						$str = $str	-replace '\\\^', ''
						
						if ($faceset_active -eq $true) {
							$overflow = 38
						}
						else {
							$overflow = 50
						}
						if ($str.Length -gt $overflow) {
							Write-Output "Text Overflow at $($mapFile) ($($ev.x)-$($ev.y)) EV$($ev.id)-$($evPage.id):"
							Write-Output " ($($str.Length)): $($cmd.string)"
						}
					}
				}
			}
		}
	}
 }