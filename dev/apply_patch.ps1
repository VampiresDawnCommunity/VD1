
Write-Output "Converting LMU to EMU..."
dev/l2e.ps1

$utf8 = [System.Text.UTF8Encoding]::new($false)
$settings = new-object System.Xml.XmlWriterSettings
$settings.CloseOutput = $true
$settings.Indent = $true
$settings.Encoding = $utf8

$edbFile = "RPG_RT.edb"
$emtFile = "RPG_RT.emt"

$patchFile = "_patch/patches.xml"


$patchXml = [xml](Get-Content -Path $patchFile -Encoding UTF8)

foreach ($mapEventPatch in $patchXml.LuciferPatch.MapPatches.MapEventPatch) {
	$mapFile = "Map$($mapEventPatch.map_id).emu"
	
	$mapXml = [xml](Get-Content -Path $mapFile -Encoding UTF8)
	$event = $mapXml.LMU.Map.Events.Event | where {$_.id -eq $mapEventPatch.event_id }
	$eventPage = $event.pages.EventPage | where {$_.id -eq $mapEventPatch.event_page }
	
	$patchComment = $eventPage.event_commands.EventCommand | where {$_.code -eq '12410'} | where {$_.string.StartsWith("PATCH: $($mapEventPatch.guid)")}
	
	if ($patchComment -eq $null) {
		Write-Output "Map $($mapFile): Patch comment $($mapEventPatch.guid) not found !"
	} else {
		$indent_correction = [int]($patchComment.indent) - [int]($mapEventPatch.event_commands.EventCommand[0].indent)
		
		$startNode = $patchComment.Clone()
		$startNode.string = "BEGIN_PATCH: $($mapEventPatch.guid)"
		$eventPage.event_commands.InsertBefore($mapXml.ImportNode($startNode, $true), $patchComment)
		
		for ($i = 0; $i -lt $mapEventPatch.event_commands.EventCommand.Count; $i++) {
			$clonedNode = $mapEventPatch.event_commands.EventCommand[$i].Clone()
			$clonedNode.indent = ([int]($clonedNode.indent) + $indent_correction).tostring()
			$eventPage.event_commands.InsertBefore($mapXml.ImportNode($clonedNode, $true), $patchComment)
		}
		
		$patchComment.string = "END_PATCH: $($mapEventPatch.guid)"
		
		remove-item $mapFile
		$writer = [System.Xml.XmlWriter]::Create($mapFile, $settings)
		Write-Output "Writing map $($mapFile)..."
		$mapXml.Save($writer)
		$writer.Close()
		./lcf2xml.exe $mapFile
	}
}

foreach ($mapEvent in $patchXml.LuciferPatch.MapEvents.MapEvent) {
	$mapFile = "Map$($mapEvent.map_id).emu"
	
	$mapXml = [xml](Get-Content -Path $mapFile -Encoding UTF8)
	$event = $mapXml.LMU.Map.Events.Event | where {$_.id -eq $mapEvent.event_id }
	
	
	if ($event -eq $null) {
		Write-Output "Map $($mapFile): EV $($mapEvent.event_id) not found !"
	} else {
		$newEventNode = $mapXml.ImportNode($mapEvent.Event, $true)
		
		if ($newEventNode.x -ne $event.x) {
			Write-Output "Map $($mapFile): EV $($mapEvent.event_id) position differs !"
		} elseif ($newEventNode.y -ne $event.y) {
			Write-Output "Map $($mapFile): EV $($mapEvent.event_id) position differs !"
		} else {		
			$mapXml.LMU.Map.Events.ReplaceChild($newEventNode, $event)
			
			remove-item $mapFile
			$writer = [System.Xml.XmlWriter]::Create($mapFile, $settings)
			Write-Output "Writing map $($mapFile)..."
			$mapXml.Save($writer)
			$writer.Close()
			./lcf2xml.exe $mapFile
		}
	}
}

$xmlEDB = [xml](Get-Content -Path $edbFile -Encoding UTF8)

foreach ($commonEventPatch in $patchXml.LuciferPatch.DatabasePatches.CommonEventPatch) {
	$commonEvent = $xmlEDB.LDB.Database.commonevents.CommonEvent | where {$_.id -eq $commonEventPatch.commonevent_id }
		
	$patchComment = $commonEvent.event_commands.EventCommand | where {$_.code -eq '12410'} | where {$_.string.StartsWith("PATCH: $($commonEventPatch.guid)")}
	
	if ($patchComment -eq $null) {
		Write-Output "EDB CE $($commonEventPatch.commonevent_id): Patch comment $($commonEventPatch.guid) not found !"
	} else {		
		$indent_correction = [int]($patchComment.indent) - [int]($commonEventPatch.event_commands.EventCommand[0].indent)
		
		$startNode = $patchComment.Clone()
		$startNode.string = "BEGIN_PATCH: $($commonEventPatch.guid)"
		$commonEvent.event_commands.InsertBefore($xmlEDB.ImportNode($startNode, $true), $patchComment)
		
		for ($i = 0; $i -lt $commonEventPatch.event_commands.EventCommand.Count; $i++) {
			$clonedNode = $commonEventPatch.event_commands.EventCommand[$i].Clone()
			$clonedNode.indent = ([int]($clonedNode.indent) + $indent_correction).tostring()
			$commonEvent.event_commands.InsertBefore($xmlEDB.ImportNode($clonedNode, $true), $patchComment)
		}
		
		$patchComment.string = "END_PATCH: $($commonEventPatch.guid)"
	}
}

foreach ($commonEvent in $patchXml.LuciferPatch.Database.CommonEvents.CommonEvent) {
	$commonEventEDB = $xmlEDB.LDB.Database.commonevents.CommonEvent | where {$_.id -eq $commonEvent.commonevent_id }
	
	$commonEventEDB.name = $commonEvent.event_name
	
	for ($i = 0; $i -lt $commonEvent.event_commands.EventCommand.Count; $i++) {
		$cmd = $commonEvent.event_commands.EventCommand[$i]
		$commonEventEDB['event_commands'].AppendChild($xmlEDB.ImportNode($cmd.Clone(), $true))
	}
}

foreach ($switch in $patchXml.LuciferPatch.Database.Switches.Switch) {
	$switchEDB = $xmlEDB.LDB.Database.switches.Switch | where {$_.id -eq $switch.id }
	
	$switchEDB.name = $switch.name
}

foreach ($variable in $patchXml.LuciferPatch.Database.Variables.Variable) {
	$variableEDB = $xmlEDB.LDB.Database.variables.Variable | where {$_.id -eq $variable.id }
	
	$variableEDB.name = $variable.name
}

foreach ($replacementNode in $patchXml.LuciferPatch.Database.Skills.Skill) {
	$existingNode = $xmlEDB.LDB.Database.Skills.Skill | where {$_.id -eq $replacementNode.id }
	
	$newNode = $xmlEDB.ImportNode($replacementNode, $true)
	$xmlEDB.LDB.Database.Skills.ReplaceChild($newNode, $existingNode)
}

foreach ($replacementNode in $patchXml.LuciferPatch.Database.Items.Item) {
	$existingNode = $xmlEDB.LDB.Database.Items.Item | where {$_.id -eq $replacementNode.id }
	
	$newNode = $xmlEDB.ImportNode($replacementNode, $true)
	$xmlEDB.LDB.Database.Items.ReplaceChild($newNode, $existingNode)
}

foreach ($replacementNode in $patchXml.LuciferPatch.Database.Enemies.Enemy) {
	$existingNode = $xmlEDB.LDB.Database.Enemies.Enemy | where {$_.id -eq $replacementNode.id }
	
	$newNode = $xmlEDB.ImportNode($replacementNode, $true)
	$xmlEDB.LDB.Database.Enemies.ReplaceChild($newNode, $existingNode)
}

foreach ($replacementNode in $patchXml.LuciferPatch.Database.Troops.Troop) {
	$existingNode = $xmlEDB.LDB.Database.Troops.Troop | where {$_.id -eq $replacementNode.id }
	
	$newNode = $xmlEDB.ImportNode($replacementNode, $true)
	$xmlEDB.LDB.Database.Troops.ReplaceChild($newNode, $existingNode)
}

remove-item $edbFile
$writer = [System.Xml.XmlWriter]::Create($edbFile, $settings)
Write-Output "Writing EDB $($edbFile)..."
$xmlEDB.Save($writer)
$writer.Close()
./lcf2xml.exe $edbFile

$xmlEMT = [xml](Get-Content -Path $emtFile -Encoding UTF8)

foreach ($mapInfo in $patchXml.LuciferPatch.Maps.MapInfo) {
	$mapFile = "Map$($mapInfo.map_id).emu"
	
	$mapInfoEMT = $xmlEMT.LMT.TreeMap.maps.MapInfo | where { $_.id -eq $mapInfo.map_id}
	$mapInfoEMT.name = $mapInfo.name
	
	$xml = [xml]'<LMU><dummy dummy="" /></LMU>'
	$xml.LMU.AppendChild($xml.ImportNode($mapInfo.LMU.Map.Clone(), $true))
	
	$xml.LMU.RemoveChild($xml.LMU.dummy)
	
	remove-item $mapFile
	$writer = [System.Xml.XmlWriter]::Create($mapFile, $settings)
	Write-Output "Replacing map $($mapFile)..."
	$xml.Save($writer)
	$writer.Close()	
	./lcf2xml.exe $mapFile
}

remove-item $emtFile
$writer = [System.Xml.XmlWriter]::Create($emtFile, $settings)
Write-Output "Writing MapTreee $($emtFile)..."
$xmlEMT.Save($writer)
$writer.Close()
./lcf2xml.exe $emtFile

Write-Output "Converting LMU to EMU..."
dev/l2e.ps1