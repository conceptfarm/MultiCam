-------------------------------------------------------------------------------
-- MultiCamLister.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2018
-- Lists all Vray Cameras and their porperties, adapted from Vray Light Lister
-------------------------------------------------------------------------------
macroScript MultiCamLister
category:"ilya_s Scripts"
tooltip:"MCL"
buttontext:"MCL"
Icon:#("Lights",7)
(
	global vrayMCLister, vrayMCListerYOffset
	
	struct MultiCamListerStruct 
	(
		CamerasInspectorSetup,
		CameraInspectorFloater,
		CameraInspectorListRollout,
		maxCamerasRC, 
		CreateCamerasRollout,
		GetStartEndKeys,
		GetImgResolution,
		UIControlList, 
		DeleteCallback, 
		disableUIElements,
		LLUndoStr, 
		count, 
		lbcount, 
		cameraIndex, 
		totalLightCount, 
		getModifierProp,
		setModifierProp,
		VRayCamerasList,	
		yOffset, 
		LineOffset,
		reloadRollout,
		getSubmitterAttributeModifier
	)

	if vrayMCLister == undefined or debug == true do vrayMCLister = MultiCamListerStruct()
	vrayMCLister.LLUndoStr = "MCLister"

	local dialogUp = false
	local multiCamRepo = @"C:\temp\Repo\"
	--local multiCamRepo = @"X:\00-000_ScriptTest\scripts\MultiCamRepo\"
	
	--X positions for grouped rollout elements
	local framesX = 170
	local layersX = 360
	local sunpointsX = 545
	local resolutionX = 760
	local hdriX = 995

	--floater dimensions
	local floaterWidth = 1230
	local floaterHeight = 300

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
		vrayMCLister.CamerasInspectorSetup.btnReload.visible = false
		try(RemoveRollout vrayMCLister.CameraInspectorListRollout vrayMCLister.CameraInspectorFloater) catch()
		
		arrayCameras = cameras
		vrayMCLister.CameraInspectorListRollout = vrayMCLister.CreateCamerasRollout arrayCameras
		
		if vrayMCLister.CameraInspectorListRollout != undefined then
		(
			addRollout vrayMCLister.CameraInspectorListRollout vrayMCLister.CameraInspectorFloater
		)
		
		vrayMCLister.maxCamerasRC = undefined
		gc camera:true
		vrayMCLister.CamerasInspectorSetup.btnReload.visible = true		
		vrayMCLister.CamerasInspectorSetup.btnReload.checked = false
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
	
	fn GetImgResolution = with undo off
	(
		local vrayRend = renderers.current
		local result = #(renderWidth,renderHeight)
		
		if (vrayRend.output_getsetsfrommax == false) then
		(
			result[1] = vrayRend.output_width
			result[2] = vrayRend.output_height
		)

		return result
	)
	vrayMCLister.GetImgResolution = GetImgResolution


	fn disableUIElements array1 = for i in array1 do execute ("maxLightsRollout." + i as string + ".enabled = false")
	vrayMCLister.disableUIElements = disableUIElements


	fn getModifierProp obj prop = 
	(
		if (isProperty obj prop) then
			getProperty obj prop
		else undefined		
	)
	vrayMCLister.getModifierProp = getModifierProp
	

	fn setModifierProp obj prop val =
	(
		if (isProperty obj prop)  then
			setProperty obj prop val
		else undefined
	)
	vrayMCLister.setModifierProp = setModifierProp

	-- Main Function

	local CreateCamerasRollout

	fn createCamerasRollout myCollection selectionOnly:false =
	(
		vrayMCLister.CamerasInspectorSetup.pbar.visible = true

		-- Class Definitions
		VRayCameras = #(Physical,Targetcamera,Freecamera)

		-- Scene parser
		try (SceneCameras = myCollection as array)
		catch (if (classof myCollection == SelectionSet) do (SceneCameras = myCollection))
		
		sceneVRayCameras = #()

		for i in SceneCameras do
		(
			cameraClass = classof i
			if findItem VRayCameras cameraClass != 0 do append sceneVRayCameras i
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
		
		vrayMCLister.maxCamerasRC = rolloutCreator "maxLightsRollout" "Cameras" -- Localize the 2nd string only
		vrayMCLister.maxCamerasRC.begin()
		-- print vrayMCLister.maxCamerasRC.str.count
		
		vrayMCLister.maxCamerasRC.addText "fn clearCheckButtons = for i in vrayMCLister.CameraInspectorListRollout.controls do if classof i == checkButtonControl do if i.checked do i.checked = false\n"
		
		vrayMCLister.count = 1
		vrayMCLister.lbCount = 1
		vrayMCLister.cameraIndex = #()
		vrayMCLister.UIControlList = #(#(),#())
		
		struct td (label, offset)
		struct titleTemplate (vrayLights,vrayCams,maxCams)
		-- Start Localization
		
		-----------------------------------------
		-- TOP HEADINGS
		-----------------------------------------
		local titleTemplates = titleTemplate \
		vrayLights:#(td "On" 8, td "Name" 28, td "Multiplier" 147, td "Color" 205, td "Temperature" 233, td "Units" 309, td "Shadows" 407, td "Subdivs" 453, td "Bias" 511, td "Invisible" 567, td "Skylight" 611, td "Diff." 669, td "Spec." 693, td "Reflect." 721, td "Caust. subd." 759, td "Wire Color" 823, td "Text" 881) \
		vrayCams:#(td "Name" 45,td "First Frame" (framesX + 3),td "Last Frame" (framesX + 69) ,td "Hide Layers:" (layersX - 2) , td "Sunpoints:" (sunpointsX), td "Res:" (resolutionX),td "Width" (resolutionX+48),td "Height" (resolutionX+114), td "HDRI:" (hdriX)) \
		maxCams:#(td "Name" 45,td "First Frame" (framesX + 3),td "Last Frame" (framesX + 69) ,td "Hide Layers:" (layersX - 2) , td "Sunpoints:" (sunpointsX), td "Res:" (resolutionX),td "Width" (resolutionX+48),td "Height" (resolutionX+114), td "HDRI:" (hdriX))
			
		
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
					vrayMCLister.maxCamerasRC.addControl #label (lbname()) labels[i].label paramStr:(" align:#left offset:[" + labels[i].offset as string + "," + ((if (i == 1) then -3 else -18) + vrayMCLister.yOffset + vrayMCLister.LineOffset) as string + "]")
				)
			)
		)
		
		fn CreateControls hasModifier att =
		(
			local cameraClassName = ((classof vrayMCLister.cameraIndex[vrayMCLister.count][1]) as string) as name
			
			-- Selection Checkbutton
			local isLightSelected = false
			
			for i in vrayMCLister.cameraIndex[vrayMCLister.count] where (not isLightSelected) do isLightSelected = i.isSelected
			
			vrayMCLister.UIControlList[1][vrayMCLister.count] = vrayMCLister.cameraIndex[vrayMCLister.count][1]
			vrayMCLister.UIControlList[2][vrayMCLister.Count] = #()
			
			-- SELECT BUTTON
			
			vrayMCLister.maxCamerasRC.addControl #checkbutton (("LightSel" + vrayMCLister.count as string) as name) "Select" paramStr:("checked:" + (isLightSelected as string) + " offset:[-5,"+ (5+ vrayMCLister.yOffset + vrayMCLister.LineOffset) as string + "] align:#left" + " width:40 height:21 ")
			vrayMCLister.maxCamerasRC.addHandler (("LightSel" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("clearCheckButtons();if state then (max modify mode;select vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "];LightSel" + (vrayMCLister.count as string) + ".checked = true); else max select none")
			
			append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("LightSel" + vrayMCLister.count as string) as name)
			
			-- On/Off

			
			-- Light Name
			local isUsingEdittextOffset = 0
			
			--NAME FIELD
			
			if vrayMCLister.cameraIndex[vrayMCLister.count].count == 1 then
			(
				local wrappedName = wrapString vrayMCLister.cameraIndex[vrayMCLister.count][1].name
				vrayMCLister.maxCamerasRC.addControl #edittext (("LightName" + vrayMCLister.count as string) as name) "" paramStr:(" text:" + wrappedName + " width:120 offset:[40,"+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
				vrayMCLister.maxCamerasRC.addHandler (("LightName" + vrayMCLister.count as string) as name) #'entered txt' filter:on codeStr:("vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].name = txt")

				isUsingEdittextOffset = 4
			)
			else
			(
				theNames = for j in vrayMCLister.cameraIndex[vrayMCLister.count] collect j.name
				sort theNames
				namelist = "#("
				for j in 1 to theNames.count do 
				(
					local wrappedName = wrapString theNames[j]
					append namelist wrappedName
					if j != theNames.count do append namelist ","
				)
				append namelist ")"
				vrayMCLister.maxCamerasRC.addControl #dropDownList (("LightName" + vrayMCLister.count as string) as name) "" filter:on\
					paramStr:(" items:" + NameList + " width:120 offset:[27,"+ (-21+ vrayMCLister.yOffset) as string + "] ")
			)
			
			append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("LightName" + vrayMCLister.count as string) as name)
			
			-- Light Multiplier
			if hasModifier == true then 
			(
				local subAttribute = att[1]
				local sA_firstFrame = subAttribute.firstFrame_sp as string
				local sA_lastFrame = subAttribute.lastFrame_sp as string
				local sA_width = subAttribute.imgWidth_sp as string
				local sA_height = subAttribute.imgHeight_sp as string
				local cam = vrayMCLister.cameraIndex[vrayMCLister.count][1]
				local wrappedName = wrapString subAttribute.name
				
				-- First Frame
				vrayMCLister.maxCamerasRC.addControl #spinner (("FirstFrameName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[-1000000,1000000," + sA_firstFrame + "] align:#left width:57 offset:["+(framesX) as string+","+ (-24+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxCamerasRC.addHandler (("FirstFrameName" + vrayMCLister.count as string) as name) #'changed n' filter:on 	codeStr:("if (n > vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].lastFrame_sp) then (n = vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].lastFrame_sp);vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].firstFrame_sp = n;FirstFrameName" + (vrayMCLister.count as string)+".value = n")
 				
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("FirstFrameName" + vrayMCLister.count as string) as name)
				
				--Last Frame
				vrayMCLister.maxCamerasRC.addControl #spinner (("LastFrameName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[-1000000,1000000," + sA_lastFrame + "] align:#left width:57 offset:["+(framesX+70) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxCamerasRC.addHandler (("LastFrameName" + vrayMCLister.count as string) as name) #'changed n' filter:on 	codeStr:("if (n < vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].firstFrame_sp) then (n = vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].firstFrame_sp);vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].lastFrame_sp = n;LastFrameName" + (vrayMCLister.count as string)+".value = n")
				
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("LastFrameName" + vrayMCLister.count as string) as name)
				
				--Get 
				vrayMCLister.maxCamerasRC.addControl #button (("getFrameRange" + vrayMCLister.count as string) as name) "Get" paramStr:(" offset:["+(framesX + 132) as string+","+ (-28+ vrayMCLister.yOffset) as string + "] align:#left width:40 height:21")
				vrayMCLister.maxCamerasRC.addHandler (("getFrameRange" + vrayMCLister.count as string) as name) #'pressed' filter:on codeStr:("fr = vrayMCLister.GetStartEndKeys vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1]; if fr!=undefined then (FirstFrameName"+vrayMCLister.count as string+".value = fr[1]; LastFrameName"+vrayMCLister.count as string+".value = fr[2];vrayMCLister.cameraIndex["+vrayMCLister.count as string+"][1].modifiers[#Submitter_Attributes].firstFrame_sp=fr[1];vrayMCLister.cameraIndex["+vrayMCLister.count as string+"][1].modifiers[#Submitter_Attributes].lastFrame_sp=fr[2])")
				 
				--vrayMCLister.maxCamerasRC.addControl #groupbox (("useHideLayersGroup" + vrayMCLister.count as string) as name) "Hide Layers" paramStr:(" offset:[310,"+ (-44+ vrayMCLister.yOffset) as string + "] width:450 height:45")
				
				--Workaround with clearselection(), if the object is selected and another non-selected option is toggled the selected object's properties change, but this is only a dislay isses, the toggled object's property is actually set
				--useHideLayers
				vrayMCLister.maxCamerasRC.addControl #checkbox (("useHideLayers" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.cameraIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useHideLayers_chb) as string + " offset:["+(layersX) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxCamerasRC.addHandler (("useHideLayers" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useHideLayers_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useHideLayers" + vrayMCLister.count as string) as name)
				
				--clearAll
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("clearLayers" + vrayMCLister.count as string) as name) "Clear All" paramStr:(" offset:["+(layersX+45) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:50 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("clearLayers" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #clearLayers_btn state;"+("clearLayers" + vrayMCLister.count as string)+".checked = false;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("clearLayers" + vrayMCLister.count as string) as name)
				
				--addHiddenLayers addLayers_btn
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("AddHidden" + vrayMCLister.count as string) as name) "Add Hidden" paramStr:(" offset:["+(layersX+105) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:60 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("AddHidden" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #addLayers_btn state;"+("AddHidden" + vrayMCLister.count as string)+".checked = false;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("AddHidden" + vrayMCLister.count as string) as name)
				
				--use Sunpoints
				vrayMCLister.maxCamerasRC.addControl #checkbox (("useSunpoints" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.cameraIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useSunpoints_chb) as string + " offset:["+(sunpointsX) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxCamerasRC.addHandler (("useSunpoints" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useSunpoints_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useSunpoints" + vrayMCLister.count as string) as name)
				
				--showSunpoints
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("showSunpoints" + vrayMCLister.count as string) as name) "Show" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.cameraIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #showSunPoint_btn) as string + " offset:["+(sunpointsX+45) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("showSunpoints" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #showSunPoint_btn state")
				
				--getSunpoints
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("getSunpoints" + vrayMCLister.count as string) as name) "Get" paramStr:(" offset:["+(sunpointsX + 90) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("getSunpoints" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #readSunPos_btn state;"+("getSunpoints" + vrayMCLister.count as string)+".checked = false")
				
				--moveSun
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("moveSun" + vrayMCLister.count as string) as name) "Move Sun" paramStr:(" offset:["+(sunpointsX + 135) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:60 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("moveSun" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #moveSunToPos_btn state;"+("moveSun" + vrayMCLister.count as string)+".checked = false")
				
				--use Resolution
				vrayMCLister.maxCamerasRC.addControl #checkbox (("useResolution" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.cameraIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useHeightWidth_chb) as string + " offset:["+(resolutionX) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxCamerasRC.addHandler (("useResolution" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useHeightWidth_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useResolution" + vrayMCLister.count as string) as name)
								
				--Width
				vrayMCLister.maxCamerasRC.addControl #spinner (("WidthName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[1,1000000," + sA_width + "] align:#left width:57 offset:["+(resolutionX+45) as string+","+ (-24+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxCamerasRC.addHandler (("WidthName" + vrayMCLister.count as string) as name) #'changed n' filter:on codeStr:("vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].imgWidth_sp = n")
 				
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("WidthName" + vrayMCLister.count as string) as name)
				
				--Height
				vrayMCLister.maxCamerasRC.addControl #spinner (("HeightName" + vrayMCLister.count as string) as name) "" paramStr:(" type:#integer range:[1,1000000," + sA_height + "] align:#left width:57 offset:["+(resolutionX+115) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
 				vrayMCLister.maxCamerasRC.addHandler (("HeightName" + vrayMCLister.count as string) as name) #'changed n' filter:on codeStr:("vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes].imgHeight_sp = n")
				
				--Get Width Height
				vrayMCLister.maxCamerasRC.addControl #button (("getResolution" + vrayMCLister.count as string) as name) "Get" paramStr:(" offset:["+(resolutionX + 177) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("getResolution" + vrayMCLister.count as string) as name) #'pressed' filter:on codeStr:("fr = vrayMCLister.GetImgResolution(); if fr!=undefined then (WidthName"+vrayMCLister.count as string+".value = fr[1]; HeightName"+vrayMCLister.count as string+".value = fr[2];vrayMCLister.cameraIndex["+vrayMCLister.count as string+"][1].modifiers[#Submitter_Attributes].imgWidth_sp=fr[1];vrayMCLister.cameraIndex["+vrayMCLister.count as string+"][1].modifiers[#Submitter_Attributes].imgHeight_sp=fr[2])")
				
				--use HDRI
				vrayMCLister.maxCamerasRC.addControl #checkbox (("useHDRI" + vrayMCLister.count as string) as name) "Use" paramStr:(" checked:" + (vrayMCLister.getModifierProp vrayMCLister.cameraIndex[vrayMCLister.count][1].modifiers[#Submitter_Attributes] #useHDRIMap_chb) as string + " offset:["+(hdriX) as string+","+ (-28+ vrayMCLister.yOffset) as string + "] width:45 height:21")
				vrayMCLister.maxCamerasRC.addHandler (("useHDRI" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #useHDRIMap_chb state;prevSel = $;clearselection(); if prevSel != undefined then select prevSel")
				append vrayMCLister.UIControlList[2][vrayMCLister.Count] (("useHDRI" + vrayMCLister.count as string) as name)
				
				--HDRI map button
				vrayMCLister.maxCamerasRC.addControl #mapbutton (("hdriMap" + vrayMCLister.count as string) as name) "Map" paramStr:(" offset:["+(hdriX+45) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("hdriMap" + vrayMCLister.count as string) as name) #'picked val' filter:on codeStr:(" vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #hdriMap_btn val")
				
				--Link to Sun
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("linkToSun" + vrayMCLister.count as string) as name) "Link" paramStr:(" offset:["+(hdriX + 90) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:40 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("linkToSun" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #readSunPos_btn state;"+("getSunpoints" + vrayMCLister.count as string)+".checked = false")
				
				--edit
				vrayMCLister.maxCamerasRC.addControl #checkbutton (("editMap" + vrayMCLister.count as string) as name) "Edit" paramStr:(" offset:["+(hdriX + 135) as string+","+ (-26+ vrayMCLister.yOffset) as string + "] align:#left" + " width:60 height:21 ")
				vrayMCLister.maxCamerasRC.addHandler (("editMap" + vrayMCLister.count as string) as name) #'changed state' filter:on codeStr:("vrayMCLister.setModifierProp vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1].modifiers[#Submitter_Attributes] #moveSunToPos_btn state;"+("moveSun" + vrayMCLister.count as string)+".checked = false")

			)
			else
			(
				vrayMCLister.maxCamerasRC.addControl #button (("AddModifier" + vrayMCLister.count as string) as name) "Add Modifier" paramStr:(" text:" + wrappedName + " width:120 offset:[45,"+ (-26+ vrayMCLister.yOffset) as string + "] height:21")
				vrayMCLister.maxCamerasRC.addHandler (("AddModifier" + vrayMCLister.count as string) as name) #'pressed' filter:on codeStr:("addModifier vrayMCLister.cameraIndex[" + vrayMCLister.count as string + "][1] (SubmitterAttributes ()); vrayMCLister.reloadRollout()")
			)
		
			
			if heapFree < 1000000 do heapsize += 1000000 -- AB Jun 20, 2002
		) -- end CreateControls

		local CanAddControls = true
		local LightCountLimit = 150 -- this sets the maximum number of lights displayed

/* 		if vrayMCLister.VRayLightsList.count > 0 and CanAddControls do
		(
			-- Start Localization
			
			vrayMCLister.maxCamerasRC.addControl #label #VRayLightTitle "V-Ray Lights" paramStr:" align:#left"
			
			WriteTitle labels:titleTemplates.vrayLights
			
			-- End Localization
			for x in 1 to vrayMCLister.VRayLightsList.count where (CanAddControls = vrayMCLister.count < LightCountLimit) do
			(
				append vrayMCLister.cameraIndex vrayMCLister.VRayLightsList[x]
				createControls hasMultiplier:true hasColor:true isVRayLight:true hasCausticsSubdivs:true hasWireColor:true hasIconText:true
				vrayMCLister.count += 1
				vrayMCLister.CamerasInspectorSetup.pbar.value = vrayMCLister.count*100/vrayMCLister.totalLightCount
			) -- end For i in VRay Lights
		) */
		
		
		---
		--CREATE ENTRIES FOR EACH CAMERA
		---
		
		if vrayMCLister.VRayCamerasList.count > 0 and CanAddControls then
		(
			vrayMCLister.maxCamerasRC.addControl #label #VRayCamsTitle "V-Ray Cameras" paramStr:" align:#left"
			WriteTitle labels:titleTemplates.vrayCams

			for x in 1 to vrayMCLister.VRayCamerasList.count do
			(
				append vrayMCLister.cameraIndex vrayMCLister.VRayCamerasList[x]
				if ((vrayMClister.getSubmitterAttributeModifier vrayMCLister.VRayCamerasList[x][1]).count == 1) then
				(
					print "Modifier found, grabbing settings"
					createControls true (vrayMClister.getSubmitterAttributeModifier vrayMCLister.VRayCamerasList[x][1])
				)
				else (createControls false undefined)
				
				print ("Found " + ((vrayMClister.getSubmitterAttributeModifier vrayMCLister.VRayCamerasList[x][1]).count) as string + " modifiers in " + (vrayMCLister.VRayCamerasList[x][1]).name) 
				
				vrayMCLister.count += 1
				vrayMCLister.CamerasInspectorSetup.pbar.value = vrayMCLister.count*100/vrayMCLister.totalLightCount
			) -- end For i in VRay Lights
		)
		
		-- Callback Handlers
		
		vrayMCLister.maxCamerasRC.addHandler "maxLightsRollout" #'open' filter:off codeStr:("vrayMCLister.DeleteCallback = when vrayMCLister.UIControlList[1] deleted obj do" + "\n(\nlocal foundMe = findItem vrayMCLister.UIControlList[1] obj\n" + "if foundMe > 0 do\n(\n" + "vrayMCLister.disableUIElements vrayMCLister.UIControlList[2][foundMe]\n)\n)")

		vrayMCLister.maxCamerasRC.addHandler "maxLightsRollout" #'close' filter:off codeStr:"DeleteChangeHandler vrayMCLister.DeleteCallback"
			
		-- Removing the Refresh/ProgressBar
		vrayMCLister.CamerasInspectorSetup.pbar.value = 0
		vrayMCLister.CamerasInspectorSetup.pbar.visible = false
		
		-- AB: Jun 20, 2002
		-- Add a new control that tells users to use the selection mode if they had too many lights in the list
		
		if not CanAddControls and vrayMCLister.maxCamerasRC.str != "" then 
			vrayMCLister.maxCamerasRC.addControl #label #lbLimitControls "The maximum number of Lights has been reached, please select fewer lights and use the Selected Lights option" paramStr:" align:#center offset:[0,10]"
		
		if vrayMCLister.maxCamerasRC.str != "" then vrayMCLister.maxCamerasRC.end() else undefined
	) --end createCamerasRollout

	vrayMCLister.CreateCamerasRollout = CreateCamerasRollout

	vrayMCLister.CamerasInspectorSetup =
	(
		local CamerasInspectorSetup
		rollout CamerasInspectorSetup "Configuration" -- Localize
		(
			checkbutton btnReload "Refresh Lister" align:#center height:21 width:134 highlightColor:(color ((colorman.getcolor #activecommand).x *255) ((colorman.getcolor #activecommand).y *255)((colorman.getcolor #activecommand).z *255)) checked:false -- Localize
			progressBar pbar width:134 pos:(btnReload.pos - [0,-1])
			
									
			on btnReload changed state do
			(
				vrayMCLister.reloadRollout()
			)
			
			on CamerasInspectorSetup close do
			(
				callBacks.RemoveScripts id:#vrayMCListerRollout
				
				dialogUp = false
				updateToolbarButtons()
			)
			
			on CamerasInspectorSetup open do
			(
				vrayMCLister.reloadRollout()
				
				pbar.visible = false
				
				-- Callbacks to remove Floater
				callBacks.AddScript #systemPreReset "CloseRolloutFloater vrayMCLister.CameraInspectorFloater" id:#vrayMCListerRollout  -- do not localize
				callBacks.AddScript #systemPreNew "CloseRolloutFloater vrayMCLister.CameraInspectorFloater" id:#vrayMCListerRollout -- do not localize
				callBacks.AddScript #filePreOpen "CloseRolloutFloater vrayMCLister.CameraInspectorFloater" id:#vrayMCListerRollout -- do not localize
				
				dialogUp = true
				updateToolbarButtons()
			)
		) -- end Rollout CamerasInspectorSetup
	) -- end StructDef vrayMCLister.CamerasInspectorSetup

	local enabled = false

	fn checkRenderer = 
	(
		productRenderer = renderers.production
		--test for vray advanced and vray rt
		if(productRenderer != undefined) then (
			enabled = ((productRenderer.classid[1] == 1941615238) and (productRenderer.classid[2] == 2012806412))
		)
		else 
		(
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
			try(closeRolloutFloater vrayMCLister.CameraInspectorFloater) catch()
			vrayMCLister.CameraInspectorFloater = newRolloutFloater "MultiCam Lister" floaterWidth floaterHeight
			
			addRollout vrayMCLister.CamerasInspectorSetup vrayMCLister.CameraInspectorFloater
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
		try(closeRolloutFloater vrayMCLister.CameraInspectorFloater) catch( print "Error in MultiCam Lister" )	
		dialogUp = false	
	)
	
	on isChecked return
	(
		dialogUp
	)
)
