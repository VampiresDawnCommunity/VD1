
Write-Host "Converting LMU to EMU..."
dev/l2e.ps1

$utf8 = [System.Text.UTF8Encoding]::new($false)
$settings = new-object System.Xml.XmlWriterSettings
$settings.CloseOutput = $true
$settings.Indent = $true
$settings.Encoding = $utf8

$emtFile = "RPG_RT.emt"

$templatePatchXml=@"
<LuciferPatch>
  <MapPatches>
    <dummy dummy="" />
  </MapPatches>
  <MapEvents>
    <dummy dummy="" />
  </MapEvents>
  <DatabasePatches>
    <dummy dummy="" />
  </DatabasePatches>
  <Database>
    <CommonEvents>
	  <dummy dummy="" />
    </CommonEvents>
    <Switches>
      <dummy dummy="" />
    </Switches>
    <Variables>
      <dummy dummy="" />
    </Variables>
  </Database>
  <Maps>
    <dummy dummy="" />
  </Maps>
</LuciferPatch>
"@

$templateMapEventPatchInsert=@"
<MapEventPatch guid="">
  <map_id>0</map_id>
  <event_id>0</event_id>
  <event_page>0</event_page>
  <indent>0</indent>
  <event_commands>
    <dummy dummy="" />
  </event_commands>
</MapEventPatch>
"@

$templateCommonEventPatchInsert=@"
<CommonEventPatch guid="">
  <commonevent_id>0</commonevent_id>
  <indent>0</indent>
  <event_commands>
    <dummy dummy="" />
  </event_commands>
</CommonEventPatch>
"@

$templateMapEvent=@"
<MapEvent>
  <map_id>0</map_id>
  <event_id>0</event_id>
  <event_name>0</event_name>
</MapEvent>
"@

$templateCommonEvent=@"
<CommonEvent>
  <commonevent_id>0</commonevent_id>
  <event_name>0</event_name>
  <event_commands>
    <dummy dummy="" />
  </event_commands>
</CommonEvent>
"@

$templateMap=@"
<MapInfo>
  <name>0</name>
  <map_id>0</map_id>
</MapInfo>
"@

$templateEmptyEventPage=@"
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
	<switch_a_id>2236</switch_a_id>
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
  <character_name>CE_Debug</character_name>
  <character_index>2</character_index>
  <character_direction>3</character_direction>
  <character_pattern>1</character_pattern>
  <translucent>F</translucent>
  <move_type>0</move_type>
  <move_frequency>3</move_frequency>
  <trigger>0</trigger>
  <layer>0</layer>
  <overlap_forbidden>F</overlap_forbidden>
  <animation_type>3</animation_type>
  <move_speed>3</move_speed>
  <move_route>
   <MoveRoute>
	<move_commands></move_commands>
	<repeat>T</repeat>
	<skippable>F</skippable>
   </MoveRoute>
  </move_route>
  <event_commands></event_commands>
 </EventPage>
"@

$templateEmptyMap=@"
<LMU>
 <Map>
  <chipset_id>1</chipset_id>
  <width>20</width>
  <height>15</height>
  <scroll_type>0</scroll_type>
  <parallax_flag>T</parallax_flag>
  <parallax_name>Blocked</parallax_name>
  <parallax_loop_x>F</parallax_loop_x>
  <parallax_loop_y>F</parallax_loop_y>
  <parallax_auto_loop_x>F</parallax_auto_loop_x>
  <parallax_sx>0</parallax_sx>
  <parallax_auto_loop_y>F</parallax_auto_loop_y>
  <parallax_sy>0</parallax_sy>
  <generator_flag>F</generator_flag>
  <generator_mode>0</generator_mode>
  <top_level>F</top_level>
  <generator_tiles>0</generator_tiles>
  <generator_width>4</generator_width>
  <generator_height>1</generator_height>
  <generator_surround>T</generator_surround>
  <generator_upper_wall>T</generator_upper_wall>
  <generator_floor_b>T</generator_floor_b>
  <generator_floor_c>T</generator_floor_c>
  <generator_extra_b>T</generator_extra_b>
  <generator_extra_c>T</generator_extra_c>
  <generator_x></generator_x>
  <generator_y></generator_y>
  <generator_tile_ids></generator_tile_ids>
  <lower_layer>5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143 5143</lower_layer>
  <upper_layer>10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000</upper_layer>
  <events></events>
  <save_count_2k3e>0</save_count_2k3e>
  <save_count>4</save_count>
 </Map>
</LMU>
"@

$xmlMapTree = [xml](Get-Content -Path $emtFile -Encoding UTF8)

$patchXml = [xml]$templatePatchXml

$patchFileName = "patches.xml"

function asdf {
	param ($patchXml, $targetNode, $evCommands, $patchComments, $mapId, $eventId, $eventPage, $commonEventId)
			
	foreach ($comment in $patchComments) {
		if ($comment.string.StartsWith('BEGIN_') -ne $true) {
			continue
		}
		$guid = $comment.string.Replace('BEGIN_PATCH:', '').Trim()
		$indexStart = $evCommands.EventCommand.IndexOf($comment)
		$indexEnd = -1
		for ($i = $indexStart; $i -lt $evCommands.EventCommand.Count; $i++) {
			$cmd = $evCommands.EventCommand[$i]
			
			if ($cmd.code -eq '12410') {
				if ($cmd.string.StartsWith('END_PATCH:')) {
					$guid2 = $cmd.string.Replace('END_PATCH:', '').Trim()
					if ($guid -eq $guid2) {
						$indexEnd = $i
						break
					}
				}
			}
		}
		
		if ($indexEnd -eq -1) {
			Write-Error "  $($guid) : $($indexStart) -> No END_PATCH stmt found!"
		} else {
			Write-Host "  $($guid) : $($indexStart) - $($indexEnd)"
			
			if ($mapId -ne '') {				
				$patchNode = ([xml]$templateMapEventPatchInsert).MapEventPatch
				$patchNode.map_id = $mapId
				$patchNode.event_id = $eventId
				$patchNode.event_page = $eventPage
			} else {
				$patchNode = ([xml]$templateCommonEventPatchInsert).CommonEventPatch
				$patchNode.commonevent_id = $commonEventId
			}
			$patchNode.guid = $guid
			$patchNode.indent = $comment.indent
			
			$patchNode = $patchXml.ImportNode($patchNode, $true)
			$targetNode.AppendChild($patchNode)
			
			$cmdsToRemove = [System.Collections.ArrayList]::new()
			$cmdsToRemove.Add($evCommands.EventCommand[$indexStart])
			for ($i = $indexStart + 1; $i -lt $indexEnd; $i++) {
				$cmd = $evCommands.EventCommand[$i]
				$patchNode.event_commands.AppendChild($patchXml.ImportNode($cmd.Clone(), $true))
				
				$cmdsToRemove.Add($cmd)
			}
			$evCommands.EventCommand[$indexEnd].string = "PATCH: $($guid)"
			
			foreach ($cmd in $cmdsToRemove) {
				$evCommands.RemoveChild($cmd)
			}
		}
	}
			
	$patchNode.event_commands.RemoveChild($patchNode.event_commands.dummy)
}
	
Get-ChildItem ./* -Include ('*.emu') | Foreach-Object {
    $file = $_.Name
	$mapId = $file.Replace('Map', '').Replace('.emu', '')
	 
	$xml = [xml](Get-Content -Path $file -Encoding UTF8)
	$changed = $false
	
	$mapEventsToReplace = [System.Collections.ArrayList]::new()
	
	foreach ($event in $xml.LMU.Map.Events.Event) {
		
		if ($event.name.StartsWith('$')) {
			if ($event.name.EndsWith('$')) {
				$mapEventsToReplace.Add($event)
				
				$eventNode = ([xml]$templateMapEvent).MapEvent
				$eventNode.event_name = $event.name
				$eventNode.event_id = $event.id
				$eventNode.map_id = $mapId
				
				$eventNode = $patchXml.ImportNode($eventNode, $true)
				$patchXml.LuciferPatch.MapEvents.AppendChild($eventNode)
				$eventNode.AppendChild($patchXml.ImportNode($event.Clone(), $true))				
				
				$changed = $true
				continue
			}
		}
		
		foreach ($eventPage in $event.pages.EventPage) {
		
			$evCommands = $eventPage.event_commands
			$patchComments = $evCommands.EventCommand | where {$_.code -eq '12410'} | where {$_.string.Contains('_PATCH:')}
			
			if ($patchComments.Count -gt 0) {
				Write-Host "$($file) - $($event.name)[$($eventPage.id)]: "
				asdf $patchXml $patchXml.LuciferPatch.MapPatches $evCommands $patchComments $mapId $event.id $eventPage.id -1
				$changed = $true
			}			
		}
	}
	
	foreach ($event in $mapEventsToReplace) {
		$event.name = '!!!!!!!!!!!!!!!!!!!!'
		$pagesNode = $event.pages
		$pagesNode.RemoveAll()
		
		$dummyPage = ([xml]$templateEmptyEventPage).EventPage
		$dummyPage = $xml.ImportNode($dummyPage, $true)
		$pagesNode.AppendChild($dummyPage)
	}
			
	#$changed = $false
	if ($changed -eq $true) {
		remove-item $file
			
		$writer = [System.Xml.XmlWriter]::Create($file, $settings)
		Write-Host "> $($file): Writing file..."

		$xml.Save($writer)
		$writer.Close()
			
		./lcf2xml.exe $file
	}
}

###
$file = "RPG_RT.edb"
$xml = [xml](Get-Content -Path $file -Encoding UTF8)

foreach ($event in $xml.LDB.Database.commonevents.CommonEvent) {
	
	if ($event.name.StartsWith('$')) {
		if ($event.name.EndsWith('$')) {
			
			$eventNode = ([xml]$templateCommonEvent).CommonEvent
			$eventNode.event_name = $event.name
			$eventNode.commonevent_id = $event.id
			
			$eventNode = $patchXml.ImportNode($eventNode, $true)
			$patchXml.LuciferPatch.Database.CommonEvents.AppendChild($eventNode)
			$eventNode.AppendChild($patchXml.ImportNode($event.Clone(), $true))
			
			for ($i = 0; $i -lt $event.event_commands.EventCommand.Count; $i++) {
				$cmd = $event.event_commands.EventCommand[$i]
				$eventNode.event_commands.AppendChild($patchXml.ImportNode($cmd.Clone(), $true))
			}
			$eventNode.event_commands.RemoveChild($eventNode.event_commands.dummy)
			
			$event.event_commands.RemoveAll()
			$event.name = '!!!!!!!!!!!!!!!!!!!!'
			
			$changed = $true
			continue
		}
	}
	
	$evCommands = $event.event_commands
	$patchComments = $evCommands.EventCommand | where {$_.code -eq '12410'} | where {$_.string.Contains('_PATCH:')}
	
	if ($patchComments.Count -gt 0) {
		Write-Host "$($file) - $($event.name): "
		asdf $patchXml $patchXml.LuciferPatch.DatabasePatches $evCommands $patchComments '' '' '' $event.id
		$changed = $true
	}			
}

$switches = $xml.LDB.Database.switches.Switch | where { [int]($_.id.TrimStart('0')) -gt 1201 } | where { [int]($_.id.TrimStart('0')) -le 1300 }

foreach ($switch in $switches) {		
	$newNode = $patchXml.ImportNode($switch.Clone(), $true)
	$patchXml.LuciferPatch.Database.Switches.AppendChild($newNode)
	$switch.name = '!!!!!!!!!!!!!!!!!!!!'
}

$variables = $xml.LDB.Database.variables.Variable | where { [int]($_.id.TrimStart('0')) -gt 441 } | where { [int]($_.id.TrimStart('0')) -le 480 }

foreach ($variable in $variables) {		
	$newNode = $patchXml.ImportNode($variable.Clone(), $true)
	$patchXml.LuciferPatch.Database.Variables.AppendChild($newNode)
	$variable.name = '!!!!!!!!!!!!!!!!!!!!'
}

remove-item $file
	
$writer = [System.Xml.XmlWriter]::Create($file, $settings)
Write-Host "> $($file): Writing file..."

$xml.Save($writer)
$writer.Close()
	
./lcf2xml.exe $file
	
###
	
foreach ($mapInfo in $xmlMapTree.LMT.TreeMap.maps.MapInfo) {
	$mapFileName = "Map$($mapInfo.id).emu"
	
	if ($mapInfo.name.StartsWith('$')) {
	
		$xmlMap = [xml](Get-Content -Path $mapFileName -Encoding UTF8)
		
		$mapNode = ([xml]$templateMap).MapInfo
		$mapNode.name = $mapInfo.name
		$mapNode.map_id = $mapInfo.id
		
		$mapInfo.name = '!!!!!!!!!!!!!!!!!!!!!!'
		
		$mapNode = $patchXml.ImportNode($mapNode, $true)
		$patchXml.LuciferPatch.Maps.AppendChild($mapNode)	
		$mapNode.AppendChild($patchXml.ImportNode($xmlMap.LMU.Clone(), $true))
		
		remove-item $mapFileName
		
		$xmlEmptyMap = [xml]$templateEmptyMap
		$writer = [System.Xml.XmlWriter]::Create($mapFileName, $settings)
		Write-Host "Replacing map $($mapFileName)..."

		$xmlEmptyMap.Save($writer)
		$writer.Close()
		
		./lcf2xml.exe $mapFileName
	}
}

remove-item $emtFile

$writer = [System.Xml.XmlWriter]::Create($emtFile, $settings)
Write-Host "Writing MapTree..."
$xmlMapTree.Save($writer)
$writer.Close()

./lcf2xml.exe $emtFile
	
$patchXml.LuciferPatch.MapPatches.RemoveChild($patchXml.LuciferPatch.MapPatches.dummy)
$patchXml.LuciferPatch.DatabasePatches.RemoveChild($patchXml.LuciferPatch.DatabasePatches.dummy)
$patchXml.LuciferPatch.MapEvents.RemoveChild($patchXml.LuciferPatch.MapEvents.dummy)
$patchXml.LuciferPatch.Maps.RemoveChild($patchXml.LuciferPatch.Maps.dummy)
$patchXml.LuciferPatch.Database.CommonEvents.RemoveChild($patchXml.LuciferPatch.Database.CommonEvents.dummy)
$patchXml.LuciferPatch.Database.Switches.RemoveChild($patchXml.LuciferPatch.Database.Switches.dummy)
$patchXml.LuciferPatch.Database.Variables.RemoveChild($patchXml.LuciferPatch.Database.Variables.dummy)
 
if (test-path $patchFileName) {
	remove-item $patchFileName
}
$writer = [System.Xml.XmlWriter]::Create($patchFileName, $settings)
Write-Host "Writing patch file..."
$patchXml.Save($writer)
$writer.Close()
 
Write-Host "Converting LMU to EMU..."
dev/l2e.ps1