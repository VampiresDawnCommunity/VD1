
Write-Host "Converting LMU to EMU..."
dev/l2e.ps1

$utf8 = [System.Text.UTF8Encoding]::new($false)
$settings = new-object System.Xml.XmlWriterSettings
$settings.CloseOutput = $true
$settings.Indent = $true
$settings.Encoding = $utf8
	
$strMapChangeTrigger=@"
   <Event id="0000">
    <name>MapChangeTrigger</name>
    <x>0</x>
    <y>0</y>
    <pages>
     <EventPage id="0001">
      <condition>
       <EventPageCondition>
        <flags>
         <EventPageCondition_Flags>
          <switch_a>T</switch_a>
          <switch_b>F</switch_b>
          <variable>F</variable>
          <item>F</item>
          <actor>F</actor>
          <timer>F</timer>
          <timer2>F</timer2>
         </EventPageCondition_Flags>
        </flags>
        <switch_a_id>2121</switch_a_id>
        <switch_b_id>1</switch_b_id>
        <variable_id>1</variable_id>
        <variable_value>0</variable_value>
        <item_id>1</item_id>
        <actor_id>1</actor_id>
        <timer_sec>0</timer_sec>
        <timer2_sec>0</timer2_sec>
        <compare_operator>1</compare_operator>
       </EventPageCondition>
      </condition>
      <character_name>ER_Debug</character_name>
      <character_index>7</character_index>
      <character_direction>0</character_direction>
      <character_pattern>1</character_pattern>
      <translucent>F</translucent>
      <move_type>0</move_type>
      <move_frequency>3</move_frequency>
      <trigger>3</trigger>
      <layer>0</layer>
      <overlap_forbidden>F</overlap_forbidden>
      <animation_type>4</animation_type>
      <move_speed>3</move_speed>
      <move_route>
       <MoveRoute>
        <move_commands></move_commands>
        <repeat>T</repeat>
        <skippable>F</skippable>
       </MoveRoute>
      </move_route>
      <event_commands>
       <EventCommand>
        <code>12330</code>
        <indent>0</indent>
        <string></string>
        <parameters>0 3 0</parameters>
       </EventCommand>
       <EventCommand>
        <code>12320</code>
        <indent>0</indent>
        <string></string>
        <parameters></parameters>
       </EventCommand>
      </event_commands>
     </EventPage>
    </pages>
   </Event>
"@
$strTroopVar = @"
<EventCommand>
<code>10220</code>
<indent>0</indent>
<string></string>
<parameters></parameters>
</EventCommand>
"@

$ev_codes = @{
	'10860' = 0 #SetEventLocation
	'10870' = 0 #SwapEventLocation
	'10870 ' = 1 #SwapEventLocation (param 2)
	'11210' = 1 #ShowAnimation
	'11320' = 0 #FlashEvent
	'11330' = 0 #SetMoveRoute
	'12330' = 1 #CallEvent
}

$troopVarIdStart = 721
$troopVarIdEnd = 750

$xmlMapTree = [xml](Get-Content -Path "RPG_RT.emt" -Encoding UTF8)

Get-ChildItem ./* -Include ('*.emu') | Foreach-Object {
    $mapFile = $_.Name
	Write-Host "Reading $($mapFile)..."
	 
	$xml = [xml](Get-Content -Path $mapFile -Encoding UTF8)

	$mapInitNode = $xml.LMU.Map.Events.Event | where {$null -ne $_} | where {$_.name.Equals('MapInit')}

	# Only target game maps that have an event with the name "MapInit"
	if ($mapInitNode -ne $null) {
		$firstNode = $xml.LMU.Map.Events.Event[0]
		$autorunNode = $xml.LMU.Map.Events.Event | where {$null -ne $_} | where {$_.name.Equals('MapChangeTrigger')}
		
		$changed = $false
		$rearrangeIds = $false
		
		# If no Autorun event "MapChangeTrigger" has been found, then create it
		# "MapChangeTrigger" should always be event id 0001 to ensure that it is called before any other Autorun event 
		if ($autorunNode -eq $null) {
			Write-Host "Creating AutoRunNode ..."
			$rearrangeIds = $true
			
			$autorunNode = $xml.ImportNode(([xml]$strMapChangeTrigger).Event, $true)
			$autorunNode.id = "0001"
			$xml.LMU.Map.Events.InsertBefore($autorunNode, $firstNode)
			
			$changed = $true
		}
		# If a "MapChangeTrigger" event has been found, but it isn't id 0001, then move it
		elseif ($firstNode -ne $autorunNode) {
			Write-Host "Moving AutoRunNode to ID 0001 ..."
			$rearrangeIds = $true
			
			$xml.LMU.Map.Events.InsertBefore($autorunNode, $firstNode)
			$autorunNode.id = "0001"
			
			$changed = $true
		}
			
		$all_commands = $xml.LMU.Map.Events.Event.pages.EventPage.event_commands.EventCommand
		
		# After creating or moving the "MapChangeTrigger" event, all the event code on the map needs to be traversed:
		#  -> All event_ids are recalculated and any commands that reference an event on the map need to be adjusted with the new ids.
		if ($rearrangeIds -eq $true) {
			
			Write-Host "Re-arranging Event IDs ..."
			
			for ($i=$xml.LMU.Map.Events.Event.Count; $i -ge 2; $i--) {
				$ev = $xml.LMU.Map.Events.Event[$i-1]
				$oldId = [int]$ev.id
				$newId = $i
				
				if ($oldId -ne $newId) {
					$oldName = 'EV' + $ev.id
					$ev.id = $newId.tostring().trimstart("0").ToString().PadLeft(4, "0")
					if ($ev.name -eq $oldName) {
						$ev.name = 'EV' + $ev.id
					}
					
					foreach ($ev_code in $ev_codes.GetEnumerator()) {
						$cmds = $all_commands | where {$_.code.Equals($ev_code.Name.Trim()) }
						
						foreach ($cmd in $cmds) {
							$params = $cmd.parameters.Split(' ')
							
							if ($cmd.code -eq '12330') {
								if ($params[0] -ne '1') {
									continue
								}
							}
							
							# TODO: These two commands also can target Map Events but seemingly aren't used anywhere:
							# 12010 (Conditional Branch)
							# 10220 (Control Variables)
							
							if ($params[$ev_code.Value] -eq $oldId.ToString()) {
								Write-Host "Replace cmd: $($ev_code.Name.Trim())[$($ev_code.Value)]: $($oldId) -> $($newId)"
								$params[$ev_code.Value] = $newId.ToString()
							}
							$cmd.parameters = [string]::Join(' ', $params)							
						}
					}
				}
			}
		}
		
		# Automatically replace all "WaitForAllMovement" commands with a CE call
		# that implements a safer way to achieve this behavior.
		$cmds = $all_commands | where {$_.code.Equals('11340') }		
		foreach ($cmd in $cmds) {
			Write-Host "Replace WaitForAllMovement with CE 'SafeWaitForAllMovement'"
			$cmd.code = '12330'
			$cmd.parameters = '0 27 0'
			
			$changed = $true
		}
		
		# Automatically rearrange any defined "Troop slot" events for the Overworld Enemy encounter feature
		$troopNodes = $xml.LMU.Map.Events.Event | where {$null -ne $_} | where {$_.name.StartsWith('Troop-')}

		if ($troopNodes.length -gt 0) {
			$currTroopId = 1
			$troopVarId = $troopVarIdStart
			$troopCommonEventId = 420
			
			$char_index = 0
			$char_direction = 0
			$char_pattern = 0
			
			if ($troopNodes.length -gt 30) {
				Write-Error "> $($mapFile): More than maximum of 30 troop slots defined on this map !!!!"
			} else {
				Write-Host "> $($mapFile): $($troopNodes.length) Troops Slots"
				
				foreach ($node in $troopNodes) {
					$troopNo = $node.name.substring(6).trimstart("0")
					$newName = "Troop-" + $currTroopId.ToString().PadLeft(2, '0')
					
					if ($node.name -ne $newName) {				
						$changed = $true
					}
					
					$node.name = $newName
					
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
			}
		}
		# End troop adjustment code
		
		
		#Generate troop encounter assignments for MapInit event		
		$mapId = $mapFile.Replace('Map', '').Replace('.emu', '')
		$mapInfo = $xmlMapTree.LMT.TreeMap.maps.MapInfo | where {$_.id.Equals($mapId)}
		if ($mapInfo -ne $null) {
			$encounters = $mapInfo.encounters.Encounter
			
			if ($encounters.length -gt 0) {			
				$evCommands = $mapInitNode.pages.EventPage[0].event_commands
				$cmds = $evCommands.EventCommand | where {$_.code -eq '10220'} | where {[int]$_.parameters.Split(' ')[1] -ge $troopVarIdStart} | where {[int]$_.parameters.Split(' ')[1] -le $troopVarIdEnd}
				$troopVarIndex = 0
				$troopVarIndent = '0'
				
				if ($cmds.Count -gt 0) {
					$troopVarIndex = $evCommands.EventCommand.IndexOf($cmds[0])
					$troopVarIndent = $cmds[0].indent
				}
				
				$recreateTroopTypeCode = $false
				
				
				if ($encounters.Count -ne $cmds.Count) {
					$recreateTroopTypeCode = $true
					Write-Host "> MapInfo $($mapId): $($encounters.Count) Encounters"
					Write-Host "> File $($mapFile): $($cmds.Count) Encounters"
				} else {
					for ($i=0; $i -lt $encounters.Count; $i++) {
						$troopId = $cmds[$i].parameters.Split(' ')[5]
						if ($encounters[$i].troop_id -ne $troopId) {
							$recreateTroopTypeCode = $true
							
							Write-Host "> $($encounters[$i].troop_id) != $($varId)"
						}
					}
				}
				
				if ($recreateTroopTypeCode) {
					$changed = $true
				
					foreach ($cmd in $cmds) {
						$evCommands.RemoveChild($cmd)
					}
					
					$troopVarId = $troopVarIdStart
					$insertBeforeNode = $evCommands.EventCommand[$troopVarIndex]
					$insertAfterNode = $null
					
					foreach ($encounter in $encounters) {
						Write-Host "> $($mapFile): Troop $($troopVarId) -> $($encounter.troop_id)"
						
						$newNode = $xml.ImportNode(([xml]$strTroopVar).EventCommand, $true)
						$newNode.parameters = "0 $($troopVarId) $($troopVarId) 0 0 $($encounter.troop_id) 0"
						$newNode.indent = $troopVarIndent
						
						if ($insertAfterNode -eq $null) {
							$evCommands.InsertBefore($newNode, $insertBeforeNode)
						} else {
							$evCommands.InsertAfter($newNode, $insertAfterNode)
						}
						$insertAfterNode = $newNode
						
						$troopVarId++
					}
				}
			}
		} else {
			Write-Error "Map$($mapId) not found in LMT!"
		}
		#End Troop encounter assignments
		
		if ($changed -eq $true) {
			remove-item $mapFile
				
			$writer = [System.Xml.XmlWriter]::Create($mapFile, $settings)
			Write-Host "> $($mapFile): Writing file..."

			$xml.Save($writer)
			$writer.Close()
				
			./lcf2xml.exe $mapFile
		}
	}
 }
 
Write-Host "Converting LMU to EMU..."
dev/l2e.ps1