
Write-Host "Converting LMU to EMU..."
dev/l2e.ps1

$utf8 = [System.Text.UTF8Encoding]::new($false)
$settings = new-object System.Xml.XmlWriterSettings
$settings.CloseOutput = $true
$settings.Indent = $true
$settings.Encoding = $utf8

Get-ChildItem ./* -Include ('*.emu') | Foreach-Object {
    $mapFile = $_.Name
	Write-Host "Reading $($mapFile)..."
	 
	$xml = [xml](Get-Content -Path $mapFile -Encoding UTF8)

	$nodes = $xml.LMU.Map.Events.Event | where {$null -ne $_} | where {$_.name.StartsWith('Troop-')}

	if ($nodes.length -gt 0) {
		$currTroopId = 1
		$troopVarId = 721
		$troopCommonEventId = 420
		
		$char_index = 0
		$char_direction = 0
		$char_pattern = 0
		
		if ($nodes.length -gt 30) {
			Write-Host "> $($mapFile): More than maximum of 30 troop slots defined on this map !!!!"
		} else {
			Write-Host "> $($mapFile): $($nodes.length) Troops"
			foreach ($node in $nodes) {
				$troopNo = $node.name.substring(6).trimstart("0")
				$newName = "Troop-" + $currTroopId.ToString().PadLeft(2, '0')
				$node.name = $newName
				#Write-Host "$($troopNo) ->  $($newName), $($troopVarId), $($variable_id)"
				
				foreach ($page in $node.pages.EventPage) {
					$cond = $page.condition.EventPageCondition
					if ($cond.switch_a_id -eq 2080) {
						$page.event_commands.EventCommand.parameters = "0 " + $troopCommonEventId + " 0"
					}
					if ($cond.switch_a_id -eq 2076) {
						$cond.variable_id = ""+$troopVarId
					}
					$page.character_index = ""+$char_index
					$page.character_direction = ""+$char_direction
					$page.character_pattern = ""+$char_pattern
				}
				
				$currTroopId++
				$troopVarId++
				$troopCommonEventId++
				
				$char_pattern++
				if ($char_pattern -eq 3) {
					$char_pattern = 0
					$char_index++
					
					if ($char_index -eq 3) {
						$char_index = 0
						$char_direction++
					}
				}
			}
			
			remove-item $mapFile
			
			$writer = [System.Xml.XmlWriter]::Create($mapFile, $settings)
			Write-Host "> $($mapFile): Writing file..."

			$xml.Save($writer)
			$writer.Close()
			
			./lcf2xml.exe $mapFile
		}
	}
 }
 
dev/l2e.ps1

Write-Host "Converting EMU back to LMU..."