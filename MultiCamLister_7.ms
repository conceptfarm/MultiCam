macroScript MultiCamLister
category:"ilya_s Scripts"
tooltip:"MCL"
buttontext:"MCL"
Icon:#("Lights",7)
(
	global vrayMCLister, vrayMCListerYOffset
	
	struct VRayLightListerStruct 
	(
		LightInspectorSetup,
		LightInspectorFloater,
		LightInspectorListRollout,
		maxLightsRC, 
		CreateLightRollout,
		GetStartEndKeys,
		UIControlList, 
		DeleteCallback, 
		disableUIElements,
		LLUndoStr, 
		count, 
		lbcount, 
		lightIndex, 
		totalLightCount, 
		getLightProp,
		getModifierProp,
		setLightProp, 
		setModifierProp,
		enableRefreshBtn, 
		VRayCamerasList,	
		yOffset, 
		LineOffset,
		reloadRollout,
		getSubmitterAttributeModifier
	)

	if vrayMCLister == undefined or debug == true do vrayMCLister = VRayLightListerStruct()

	-- Strings for Localization

	vrayMCLister.LLUndoStr = "MCLister"

	local dialogUp = false
	local multiCamRepo = @"C:\temp\Repo\"
	--local multiCamRepo = @"X:\00-000_ScriptTest\scripts\MultiCamRepo\"
	
	-- End Strings
	
	--X positions for grouped rollout elements
	local layersX = 360
	local sunpointsX = 545
	local framesX = 170
	local resolutionX = 760
	local hdriX = 950

	-- Positioning to help localization

	vrayMCListerYOffset = 0
	vrayMCLister.yOffset = vrayMCListerYOffset
	vrayMCLister.LineOffset = 0

	-- Useful Functions
	fn subtractFromArray myArray mySub =
	(
		tmpArray = #()
		for i in myArray do append tmpArray i
		for i in mySub do

		(
			itemNo = finditem tmpArray i
			local newArray = #()
			if itemNo != 0 do
			(
				for j in 1 to (itemNo-1) do append newArray tmpArray[j]
				for j in (itemNo+1) to tmpArray.count do append newArray tmpArray[j]
				tmpArray = newArray
			)
		)
		tmpArray
	)

	fn compareFN v1 v2 =
	(
		if (v1.name as name) < (v2.name as name) then -1
		else if (v1.name as name) > (v2.name as name) then 1
		else 0
	)

	fn SortNodeArrayByNameAscendingOrder myArray =
	(
		qsort myArray compareFN
		myArray
	)

	fn SortNodeArrayByName myArray =
	(
		qsort myArray (fn myname v1 v2 = (if v1.name < v2.name then 0 else 1))
		myArray
	)


	fn copyArray array1 = for i in array1 collect i

	fn wrapString inString =
	(
		local string1In = "\\"
		local string1Out = "\\\\"
		local string2In = "\""
		local string2Out = "\\\""
		local temp_text_string = substituteString inString string1In string1Out
		temp_text_string = substituteString temp_text_string string2In string2Out
		temp_text_string = string2In + temp_text_string + string2In
		temp_text_string -- return value
	)
	
	--global reloadRollout
	
	fn getSubmitterAttributeModifier obj =
	(
		print ("classof obj is " + (classof obj) as string)
		print ("Find modifier is " + (findItem modifier.classes submitterattributes) as string)
		try (SubmitterAttributes())catch(print "no submitter attribute loaded")
		result = for m in obj.modifiers where (classof m == SubmitterAttributes) collect m
		return result
	)
	vrayMCLister.getSubmitterAttributeModifier = getSubmitterAttributeModifier
	
	fn reloadRollout = 
	(
		--RELOAD FN--
		vrayMCLister.LightInspectorSetup.btnReload.visible = false
		try(RemoveRollout vrayMCLister.LightInspectorListRollout vrayMCLister.LightInspectorFloater) catch()
		
		--arrayLightsAndHelpers = vrayLightsAndHelpersAsArray()
		arrayLightsAndHelpers = cameras
		vrayMCLister.LightInspectorListRollout = vrayMCLister.CreateLightRollout arrayLightsAndHelpers
		
		if vrayMCLister.LightInspectorListRollout != undefined then
		(
			addRollout vrayMCLister.LightInspectorListRollout vrayMCLister.LightInspectorFloater
		)
		
		vrayMCLister.maxLightsRC = undefined
		gc camera:true
		vrayMCLister.LightInspectorSetup.btnReload.visible = true
		--RELOAD FN--
		
		vrayMCLister.LightInspectorSetup.btnReload.checked = false
	)
	vrayMCLister.reloadRollout = reloadRollout
	
	fn GetStartEndKeys obj = with undo off
	(
		if (superclassof obj == camera) then
		(
			result = #()
			mapkeys obj (fn CollectKeys t k = (append k t; t)) (keys=#()) #allkeys
			--resultCam =  #(amin keys, amax keys)
			--print resultCam
			if obj.target != undefined then
			(
				mapkeys obj.target (fn CollectKeys t k = (append k t; t)) (keys2=#()) #allkeys
				--result = join keys keys2
				result =  #(amin (join keys keys2) , amax (join keys keys2))
			)
			else result =  #(amin keys, amax keys)
			if result[1] == undefined or result[2] == undefined then return undefined
			else return result
		)
		else return undefined
	)
	vrayMCLister.GetStartEndKeys = GetStartEndKeys
	
	fn disableUIElements array1 = for i in array1 do execute ("maxLightsRollout." + i as string + ".enabled = false")
	vrayMCLister.disableUIElements = disableUIElements

	fn enableRefreshBtn lightobj =
	(
		if (vrayMCLister.GetLightProp lightObj #useGlobalShadowSettings) == true do
		(
			vrayMCLister.LightInspectorSetup.BtnReload.Checked = true
		)
	)
	vrayMCLister.enableRefreshBtn = enableRefreshBtn

	fn getLightProp obj prop =
	(
		if (isProperty obj prop) and not (isProperty obj #delegate) then
			getProperty obj prop
		else 
			if isProperty obj #delegate then 
				if isProperty obj.delegate prop then
					getProperty obj.delegate prop
				else undefined
			else undefined
	)
	vrayMCLister.getLightProp = getLightProp

	fn getModifierProp obj prop = 
	(
		if (isProperty obj prop) then
			getProperty obj prop
		else undefined		
	)
	vrayMCLister.getModifierProp = getModifierProp
	
	fn setLightProp obj prop val =
	(
		if (isProperty obj prop) and not (isProperty obj #delegate) then
			setProperty obj prop val
		else
			if isProperty obj #delegate then 
				if isProperty obj.delegate prop then
					setProperty obj.delegate prop val
				else undefined
			else undefined
	)
	vrayMCLister.setLightProp = setLightProp
	
	fn setModifierProp obj prop val =
	(
		if (isProperty obj prop)  then
			setProperty obj prop val
		else undefined
	)
	vrayMCLister.setModifierProp = setModifierProp

	-- Main Function

	local CreateLightRollout

	fn createLightRollout myCollection selectionOnly:false =
	(
		vrayMCLister.LightInspectorSetup.pbar.visible = true

		-- Class Definitions
		VRayCameras = #(Physical)

		-- Scene parser
		try (SceneLights = myCollection as array)
		catch (if (classof myCollection == SelectionSet) do (SceneLights = myCollection))
		
		sceneVRayCameras = #()

		for i in SceneLights do
		(
			LightClass = classof i
			print lightclass
			if findItem VRayCameras LightClass != 0 do append sceneVRayCameras i
		)
		print "sceneVRayCameras"
		print sceneVRayCameras
		
		if sceneVRayCameras.count > 0 then SortNodeArrayByNameAscendingOrder sceneVRayCameras

		
		-- Collect Light Instances and build array to be displayed
		
		tmpParser = #( \

			tmpsceneVRayCameras = copyArray sceneVRayCameras--, \
		)
		print "tmpParser"
		print tmpParser
		
		ListParser = #( \
			vrayMCLister.VRayCamerasList = #()--, \
		)
		
		print "ListParser"
		print ListParser
		
		for i in 1 to tmpParser.count do
		(
			while tmpParser[i].count > 0 do
			(
				tmpNode = tmpParser[i][1].baseObject
				depends = refs.dependents tmpNode
				discard = #()
				for k in depends do if classof k != classof tmpNode or (superclassof k != light and superclassof k != helper and superclassof k != camera) do append discard k
				for k in depends do 
					try
					(
						if classof k == DaylightAssemblyHead or classof k == ParamBlock2ParamBlock2 then 
							append discard k 
						else
							if k.AssemblyMember and not k.AssemblyHead and classof k.parent != DaylightAssemblyHead do append discard k
					) 
					catch()
				depends2 = subtractFromArray depends discard
				depends = for olight in depends2 where (isvalidnode olight)  collect olight
				depends = SortNodeArrayByName depends
				if depends.count > 0 do append listParser[i] depends
				tmpParser[i] = subtractFromArray tmpParser[i] (discard + depends)
			)
		)
		print "tmpParser - 2"
		print tmpParser
		
		
		vrayMCLister.totalLightCount = 	vrayMCLister.VRayCamerasList.count-- + \
		
		-- build controls and rollouts
		
		-- MAX Lights
		
		vrayMCLister.maxLightsRC = rolloutCreator "maxLightsRollout" "Cameras" -- Localize the 2nd string only
		vrayMCLister.maxLightsRC.begin()
		-- print vrayMCLister.maxLightsRC.str.count
		
		vrayMCLister.maxLightsRC.addText "fn clearCheckButtons = for i in vrayMCLister.LightInspectorListRollout.controls do if classof i == checkButtonControl do if i.checked do i.checked = false\n"
		
		vrayMCLister.count = 1
		vrayMCLister.lbCount = 1
		vrayMCLister.LightIndex = #()
		vrayMCLister.UIControlList = #(#(),#())
		
		struct td (label, offset)
		struct titleTemplate (vrayLights,vrayCams)
		-- Start Localization
		
		-----------------------------------------
		-- TOP HEADINGS
		-----------------------------------------
		local titleTemplates = titleTemplate \
		vrayLights:#(td "On" 8, td "Name" 28, td "Multiplier" 147, td "Color" 205, td "Temperature" 233, td "Units" 309, td "Shadows" 407, td "Subdivs" 453, td "Bias" 511, td "Invisible" 567, td "Skylight" 611, td "Diff." 669, td "Spec." 693, td "Reflect." 721, td "Caust. subd." 759, td "Wire Color" 823, td "Text" 881) \
		vrayCams:#(td "Name" 45,td "First Frame" (framesX + 3),td "Last Frame" (framesX + 69) ,td "Hide Layers:" (layersX - 2) , td "Sunpoints:" (sunpointsX), td "Resolution:" (resolutionX),td "Width" (resolutionX+48),td "Height" (resolutionX+114), td "HDRI:" (hdriX))
			
		
		fn WriteTitle labels:undefined =
		(
			local lbName
			fn lbName = 
			(
				if vrayMCLister.lbCount == undefined do vrayMCLister.lbCount = 1
				vrayMCLister.lbCount += 1
				("LB" + vrayMCLister.lbCount as string) as name
			)
			
			if (labels != undefined) do (
				for i = 1 to labels.count do (
					vrayMCLister.maxLightsRC.addControl #label (lbname()) labels[i].label paramStr:(" align:#left offset:[" + labels[i].offset as string + "," + ((if (i == 1) then -3 else -18) + vrayMCLister.yOffset + vrayMCLister.LineOffset) as string + "]")
				)
			)
		)
		
		fn CreateControls hasModifier att =
		(
			local lightClassName = ((classof vrayMCLister.LightIndex[vrayMCLister.count][1]) as string) as name
			


			
			-- Selection Checkbutton
			local isLightSelected = false
			
			for i in vrayMCLister.LightIndex[vrayMCLister.count] where (not isLightSelected) do isLightSelected = i.isSelected
			
			vrayMCLister.UIControlList[1][vrayMCLister.count] = vrayMCLister.LightIndex[vrayMCLister.count][1]
			vrayMCLister.UIControlList[2][vrayMCLister.Count] = #()
			
			-- SELECT BUTTON
			
			vrayMCLister.maxLightsRC.addControl #checkbutton (("LightSel" + vrayMCLister.count as string) as name) "Select" paramStr:("checked:" + (isLightSelected as string) + " offset:[-5,"+ (5+ vrayMCLister.yOffset + vrayMCLister.LineOffset) as string + "] align:#left" + " width:40 height:21 ")
			vrayMCLister.maxLightsRC.addHandler (("LightSel" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("clearCheckButtons();if state then (max modify mode;select vrayMCLister.LightIndex[" + vrayMCLister.count as string + "];LightSel" + (vrayMCLister.count as string) + ".checked = true); else max select none")
			
			append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("LightSel" + vrayMCLister.count as string) as name)
			
			-- On/Off

			
			-- Light Name
			local isUsingEdittextOffset = 0
			
			--NAME FIELD
			
			if vrayMCLister.LightIndex[vrayMCLister.count].count == 1 then
			(
				local wrappedName = wrapString vrayMCLister.LightIndex[vrayMCLister.count][1].name
				vrayMCLister.maxLightsRC.addControl #edittext (("LightName" + vrayMCLister.count as string) as name) "" paramStr:(" text:" + wrappedName + " width:120 offset:[40,"+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
				vrayMCLister.maxLightsRC.addHandler (("LightName" + vrayMCLister.count as string) as name) #'entered txt' filter:on codeStr:("vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].name = txt")

				isUsingEdittextOffset = 4
			)
			else
			(
				theNames = for j in vrayMCLister.LightIndex[vrayMCLister.count] collect j.name
				sort theNames
				namelist = "#("
				for j in 1 to theNames.count do 
				(
					local wrappedName = wrapString theNames[j]
					append namelist wrappedName
					if j != theNames.count do append namelist ","
				)
				append namelist ")"
				vrayMCLister.maxLightsRC.addControl #dropDownList (("LightName" + vrayMCLister.count as string) as name) "" filter:on\
					paramStr:(" items:" + NameList + " width:120 offset:[27,"+ (-21+ vrayMCLister.yOffset) as string + "] ")
			)
			
			append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("LightName" + vrayMCLister.count as string) as name)
			
			-- Light Multiplier
			if hasModifier == true then 
			(
				local subAttribute = att[1]
				local sA_firstFrame = subAttribute.firstFrame_sp as string
				local sA_lastFrame = subAttribute.lastFrame_sp as string
				local cam = vrayMCLister.LightIndex[vrayMCLister.count][1]
				local wrappedName = wrapString subAttribute.name
				
				-- First Frame
				vrayMCLister.maxLightsRC.addControl #spinner (("FirstFrameName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[-1000000,1000000," + sA_firstFrame + "] align:#left width:57 offset:["+(framesX) as string+","+ (-24+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxLightsRC.addHandler (("FirstFrameName" + vrayMCLister.count as string) as name) #'changed n' filter:on 	codeStr:("vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].firstFrame_sp = n")
 				
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("FirstFrameName" + vrayMCLister.count as string) as name)
				
				--Last Frame
				vrayMCLister.maxLightsRC.addControl #spinner (("LastFrameName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[-1000000,1000000," + sA_lastFrame + "] align:#left width:57 offset:["+(framesX+70) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxLightsRC.addHandler (("LastFrameName" + vrayMCLister.count as string) as name) #'changed n' filter:on 	codeStr:("vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].lastFrame_sp = n")
				
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("LastFrameName" + vrayMCLister.count as string) as name)
				
				--Get 
				vrayMCLister.maxLightsRC.addControl #button (("Get" + vrayMCLister.count as string) as name) "Get" paramStr:(" offset:["+(framesX + 132) as string+","+ (-28+ vrayMCLister.yOffset) as string + "] align:#left width:40 height:21")
				vrayMCLister.maxLightsRC.addHandler (("Get" + vrayMCLister.count as string) as name) #'pressed' filter:on codeStr:("fr = vrayMCLister.GetStartEndKeys vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1]; if fr!=undefined then (FirstFrameName"+vrayMCLister.count as string+".value = fr[1]; LastFrameName"+vrayMCLister.count as string+".value = fr[2];vrayMCLister.LightIndex["+vrayMCLister.count as string+"][1].modifiers[#Submitter_Attributes].firstFrame_sp=fr[1];vrayMCLister.LightIndex["+vrayMCLister.count as string+"][1].modifiers[#Submitter_Attributes].lastFrame_sp=fr[2])")
				
				--vrayMCLister.maxLightsRC.addControl #groupbox (("useHideLayersGroup" + vrayMCLister.count as string) as name) "Hide Layers" paramStr:(" offset:[310,"+ (-44+ vrayMCLister.yOffset) as string + "] width:450 height:45")
				
				--Workaround with clearselection(), if the object is selected and another non-selected option is toggled the selected object's properties change, but this is only a dislay isses, the toggled object's property is actually set
				--useHideLayers
				vrayMCLister.maxLightsRC.addControl #checkbox (("useHideLayers" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.LightIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useHideLayers_chb) as string + " offset:["+(layersX) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxLightsRC.addHandler (("useHideLayers" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useHideLayers_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useHideLayers" + vrayMCLister.count as string) as name)
				
				--clearAll
				vrayMCLister.maxLightsRC.addControl #checkbutton (("clearLayers" + vrayMCLister.count as string) as name) "Clear All" paramStr:(" offset:["+(layersX+45) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:50 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("clearLayers" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #clearLayers_btn state;"+("clearLayers" + vrayMCLister.count as string)+".checked = false;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("clearLayers" + vrayMCLister.count as string) as name)
				
				--addHiddenLayers addLayers_btn
				vrayMCLister.maxLightsRC.addControl #checkbutton (("AddHidden" + vrayMCLister.count as string) as name) "Add Hidden" paramStr:(" offset:["+(layersX+105) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:60 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("AddHidden" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #addLayers_btn state;"+("AddHidden" + vrayMCLister.count as string)+".checked = false;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("AddHidden" + vrayMCLister.count as string) as name)
				
				--use Sunpoints
				vrayMCLister.maxLightsRC.addControl #checkbox (("useSunpoints" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.LightIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useSunpoints_chb) as string + " offset:["+(sunpointsX) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxLightsRC.addHandler (("useSunpoints" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useSunpoints_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useSunpoints" + vrayMCLister.count as string) as name)
				
				--showSunpoints
				vrayMCLister.maxLightsRC.addControl #checkbutton (("showSunpoints" + vrayMCLister.count as string) as name) "Show" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.LightIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #showSunPoint_btn) as string + " offset:["+(sunpointsX+45) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("showSunpoints" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #showSunPoint_btn state")
				
				--getSunpoints
				vrayMCLister.maxLightsRC.addControl #checkbutton (("getSunpoints" + vrayMCLister.count as string) as name) "Get" paramStr:(" offset:["+(sunpointsX + 90) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("getSunpoints" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #readSunPos_btn state;"+("getSunpoints" + vrayMCLister.count as string)+".checked = false")
				
				--moveSun
				vrayMCLister.maxLightsRC.addControl #checkbutton (("moveSun" + vrayMCLister.count as string) as name) "Move Sun" paramStr:(" offset:["+(sunpointsX + 135) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:60 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("moveSun" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #moveSunToPos_btn state;"+("moveSun" + vrayMCLister.count as string)+".checked = false")
				
				--use Resolution
				vrayMCLister.maxLightsRC.addControl #checkbox (("useResolution" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.LightIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useSunpoints_chb) as string + " offset:["+(resolutionX) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxLightsRC.addHandler (("useResolution" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useSunpoints_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useResolution" + vrayMCLister.count as string) as name)
								
				--Width
				vrayMCLister.maxLightsRC.addControl #spinner (("WidthName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[-1000000,1000000," + sA_firstFrame + "] align:#left width:57 offset:["+(resolutionX+45) as string+","+ (-24+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxLightsRC.addHandler (("WidthName" + vrayMCLister.count as string) as name) #'changed n' filter:on 	codeStr:("vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].firstFrame_sp = n")
 				
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("WidthName" + vrayMCLister.count as string) as name)
				
				--Height
				vrayMCLister.maxLightsRC.addControl #spinner (("HeightName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[-1000000,1000000," + sA_lastFrame + "] align:#left width:57 offset:["+(resolutionX+115) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxLightsRC.addHandler (("HeightName" + vrayMCLister.count as string) as name) #'changed n' filter:on 	codeStr:("vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].lastFrame_sp = n")
				
				
				--use HDRI
				vrayMCLister.maxLightsRC.addControl #checkbox (("useHDRI" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.LightIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useHDRIMap_chb) as string + " offset:["+(hdriX) as string+","+ (-28+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxLightsRC.addHandler (("useHDRI" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useHDRIMap_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useHDRI" + vrayMCLister.count as string) as name)
				
				--HDRI map button
				vrayMCLister.maxLightsRC.addControl #mapbutton (("hdriMap" + vrayMCLister.count as string) as name) "Map" paramStr:(" offset:["+(hdriX+45) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("hdriMap" + vrayMCLister.count as string) as name) #'picked val' filter:on codeStr:(" vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #hdriMap_btn val")
				
				--Link to Sun
				vrayMCLister.maxLightsRC.addControl #checkbutton (("linkToSun" + vrayMCLister.count as string) as name) "Link" paramStr:(" offset:["+(hdriX + 90) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("linkToSun" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #readSunPos_btn state;"+("getSunpoints" + vrayMCLister.count as string)+".checked = false")
				
				--edit
				vrayMCLister.maxLightsRC.addControl #checkbutton (("editMap" + vrayMCLister.count as string) as name) "Edit" paramStr:(" offset:["+(hdriX + 135) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:60 height:21 ")
				vrayMCLister.maxLightsRC.addHandler (("editMap" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #moveSunToPos_btn state;"+("moveSun" + vrayMCLister.count as string)+".checked = false")

			)
			else
			(
				vrayMCLister.maxLightsRC.addControl #button (("AddModifier" + vrayMCLister.count as string) as name) "Add Modifier" paramStr:(" text:" + wrappedName + " width:120 offset:[45,"+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
				vrayMCLister.maxLightsRC.addHandler (("AddModifier" + vrayMCLister.count as string) as name) #'pressed' filter:on codeStr:("addModifier vrayMCLister.LightIndex[" + vrayMCLister.count as string + "][1] (SubmitterAttributes ()); vrayMCLister.reloadRollout()")
			)
		
			
			if heapFree < 1000000 do heapsize += 1000000 -- AB Jun 20, 2002
		) -- end CreateControls

		local CanAddControls = true
		local LightCountLimit = 150 -- this sets the maximum number of lights displayed

/* 		if vrayMCLister.VRayLightsList.count > 0 and CanAddControls do
		(
			-- Start Localization
			
			vrayMCLister.maxLightsRC.addControl #label #VRayLightTitle "V-Ray Lights" paramStr:" align:#left"
			
			WriteTitle labels:titleTemplates.vrayLights
			
			-- End Localization
			for x in 1 to vrayMCLister.VRayLightsList.count where (CanAddControls = vrayMCLister.count < LightCountLimit) do
			(
				append vrayMCLister.LightIndex vrayMCLister.VRayLightsList[x]
				createControls hasMultiplier:true hasColor:true isVRayLight:true hasCausticsSubdivs:true hasWireColor:true hasIconText:true
				vrayMCLister.count += 1
				vrayMCLister.LightInspectorSetup.pbar.value = vrayMCLister.count*100/vrayMCLister.totalLightCount
			) -- end For i in VRay Lights
		) */
		
		
		---
		--CREATE ENTRIES FOR EACH CAMERA
		---
		
		if vrayMCLister.VRayCamerasList.count > 0 and CanAddControls then
		(
			vrayMCLister.maxLightsRC.addControl #label #VRayCamsTitle "V-Ray Cameras" paramStr:" align:#left"
			WriteTitle labels:titleTemplates.vrayCams

			for x in 1 to vrayMCLister.VRayCamerasList.count do
			(
				append vrayMCLister.LightIndex vrayMCLister.VRayCamerasList[x]
				if ((vrayMClister.getSubmitterAttributeModifier vrayMCLister.VRayCamerasList[x][1]).count == 1) then
				(
					print "Modifier found, grabbing settings"
					createControls true (vrayMClister.getSubmitterAttributeModifier vrayMCLister.VRayCamerasList[x][1])
				)
				else (createControls false undefined)
				
				print ("Found " + ((vrayMClister.getSubmitterAttributeModifier vrayMCLister.VRayCamerasList[x][1]).count) as string + " modifiers in " + (vrayMCLister.VRayCamerasList[x][1]).name) 
				
				vrayMCLister.count += 1
				vrayMCLister.LightInspectorSetup.pbar.value = vrayMCLister.count*100/vrayMCLister.totalLightCount
			) -- end For i in VRay Lights
		)
		
		-- Callback Handlers
		
		vrayMCLister.maxLightsRC.addHandler "maxLightsRollout" #'open' filter:off codeStr:("vrayMCLister.DeleteCallback = when vrayMCLister.UIControlList[1] deleted obj do" + "\n(\nlocal foundMe = findItem vrayMCLister.UIControlList[1] obj\n" + "if foundMe > 0 do\n(\n" + "vrayMCLister.disableUIElements vrayMCLister.UIControlList[2][foundMe]\n)\n)")

		vrayMCLister.maxLightsRC.addHandler "maxLightsRollout" #'close' filter:off codeStr:"DeleteChangeHandler vrayMCLister.DeleteCallback"
			
		-- Removing the Refresh/ProgressBar
		vrayMCLister.LightInspectorSetup.pbar.value = 0
		vrayMCLister.LightInspectorSetup.pbar.visible = false
		
		-- AB: Jun 20, 2002
		-- Add a new control that tells users to use the selection mode if they had too many lights in the list
		
		if not CanAddControls and vrayMCLister.maxLightsRC.str != "" then 
			vrayMCLister.maxLightsRC.addControl #label #lbLimitControls "The maximum number of Lights has been reached, please select fewer lights and use the Selected Lights option" paramStr:" align:#center offset:[0,10]"
		
		if vrayMCLister.maxLightsRC.str != "" then vrayMCLister.maxLightsRC.end() else undefined
	) --end createLightRollout

	vrayMCLister.CreateLightRollout = CreateLightRollout

	vrayMCLister.LightInspectorSetup =
	(
		local LightInspectorSetup
		rollout LightInspectorSetup "Configuration" -- Localize
		(
			checkbutton btnReload "Refresh Lister" align:#center height:21 width:134 highlightColor:(color ((colorman.getcolor #activecommand).x *255) ((colorman.getcolor #activecommand).y *255)((colorman.getcolor #activecommand).z *255)) checked:false -- Localize
			progressBar pbar width:134 pos:(btnReload.pos - [0,-1])
			
									
			on btnReload changed state do
			(
				vrayMCLister.reloadRollout()
			)
			
			
			on LightInspectorSetup close do
			(
				callBacks.RemoveScripts id:#vrayMCListerRollout
				
				dialogUp = false
				updateToolbarButtons()
			)
			
			on LightInspectorSetup open do
			(
				vrayMCLister.reloadRollout()
				
				pbar.visible = false
				
				-- Callbacks to remove Floater
				callBacks.AddScript #systemPreReset "CloseRolloutFloater vrayMCLister.LightInspectorFloater" id:#vrayMCListerRollout  -- do not localize
				callBacks.AddScript #systemPreNew "CloseRolloutFloater vrayMCLister.LightInspectorFloater" id:#vrayMCListerRollout -- do not localize
				callBacks.AddScript #filePreOpen "CloseRolloutFloater vrayMCLister.LightInspectorFloater" id:#vrayMCListerRollout -- do not localize
				
				dialogUp = true
				updateToolbarButtons()
			)
		) -- end Rollout LightInspectorSetup
	) -- end StructDef vrayMCLister.LightInspectorSetup

	local enabled = false

	fn checkRenderer = 
	(
		productRenderer = renderers.production
		--test for vray advanced and vray rt
		if(productRenderer != undefined) then (
			enabled = ((productRenderer.classid[1] == 1941615238) and (productRenderer.classid[2] == 2012806412) or (productRenderer.classid[1] == 1770671000) and (productRenderer.classid[2] == 1323107829))
		) else (
			enabled = false
		)
	)
			
	on execute do
	(	
		--try to load the submitter modifier
		if multiCamUsable != true then
		(
			MessageBox ("MultiCam Lister is not usable, check MAXScript Listener to make sure all MultiCam assets are loaded correctly.") title:"Missing MultiCam Assets"
		)
		else
		(
			try(closeRolloutFloater vrayMCLister.LightInspectorFloater) catch()
			vrayMCLister.LightInspectorFloater = newRolloutFloater "MultiCam Lister" 1200 300
			
			addRollout vrayMCLister.LightInspectorSetup vrayMCLister.LightInspectorFloater
			dialogUp = true
		)
	) -- end on execute

	on isEnabled do
	(
		checkRenderer()
		enabled
	)
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
	
	on closeDialogs do
	(
		try(closeRolloutFloater vrayMCLister.LightInspectorFloater) catch( print "Error in LightLister" )	
		dialogUp = false	
	)
	
	on isChecked return
	(
		dialogUp
	)
)
