
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

$ev_codes = @{
	'10860' = 0 #SetEventLocation
	'10870' = 0 #SwapEventLocation
	'10870 ' = 1 #SwapEventLocation (param 2)
	'11210' = 1 #ShowAnimation
	'11320' = 0 #FlashEvent
	'11330' = 0 #SetMoveRoute
	'12330' = 1 #CallEvent
}

Get-ChildItem ./* -Include ('*.emu') | Foreach-Object {
    $mapFile = $_.Name
	Write-Host "Reading $($mapFile)..."
	 
	$xml = [xml](Get-Content -Path $mapFile -Encoding UTF8)

	$node = $xml.LMU.Map.Events.Event | where {$null -ne $_} | where {$_.name.Equals('MapInit')}

	if ($node -ne $null) {
		$firstNode = $xml.LMU.Map.Events.Event[0]
		$autorunNode = $xml.LMU.Map.Events.Event | where {$null -ne $_} | where {$_.name.Equals('MapChangeTrigger')}
		
		$rearrangeIds = $false
		
		if ($autorunNode -eq $null) {
			Write-Host "Creating AutoRunNode ..."
			$rearrangeIds = $true
			
			$autorunNode = $xml.ImportNode(([xml]$strMapChangeTrigger).Event, $true)
			$autorunNode.id = "0001"
			$xml.LMU.Map.Events.InsertBefore($autorunNode, $firstNode)
			
		} elseif ($firstNode -ne $autorunNode) {
			Write-Host "Moving AutoRunNode to ID 0001 ..."
			$rearrangeIds = $true
			
			$xml.LMU.Map.Events.InsertBefore($autorunNode, $firstNode)
			$autorunNode.id = "0001"
		}
		
		if ($rearrangeIds -eq $true) {
			
			Write-Host "Re-arranging Event IDs ..."
			
			$all_commands = $xml.LMU.Map.Events.Event.pages.EventPage.event_commands.EventCommand
			
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