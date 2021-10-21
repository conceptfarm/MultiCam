/*
Issues:
--Still the issues of lister updating the visible in modifer panel not the actual object
1. Deselect the object when lister is editing
2. Select the object when lister is editing, need to handle multi-object editing without selection
3. Move all the stuff in the parameters back to rollout and add update only if selected, add reload mod panel function to any functions that update the UI elements, could be slow for the panel to reload
4. Go back to making each CA a unique CA, then need to add callback functions for cloning
5. Unique CA is not the answer, bad functionality persists, leave UI functions in parameters but now check if this is selected then do UI updates

source = $'PhysCamera001'
target = $'PhysCamera002'

fn copyMultiCamAttributeData souce target = 
(
	for i=(custAttributes.count target) to 1 by -1 where (classof (custAttributes.get target i) as string == "<AttributeDef:MCCAData>") do custAttributes.delete target i
	
	custAttributes.add target MCCA #unique 
	
	for prop in (getPropNames  source.baseObject.MultiCamAttributeData) do
	(
		p = getProperty  source.baseObject.MultiCamAttributeData prop
		setProperty target.baseObject.MultiCamAttributeData prop p
	)
)


*/
global MultiCamCustomAttribute
MultiCamCustomAttribute = attributes MultiCamAttributeData attribID:#(0x6c19f4d0, 0x29a2ba02) version:2
(
	local hdriMapName = "None"
	local objectName = ""
	local buttonWidth = 135
	local gwDisplaySunpoints
	local gwShowActiveSettings
	local versionText = "0.910"
	--local layers_ro
	--local sunpoints_ro
	--local resolution_ro
	--local hdriMap_ro
	
	-----------------------------------------------------
	--FUNCTIONS------------------------------------
	-----------------------------------------------------
	
	fn checkRenderer = 
	(
		local rend = renderers.current
		
		if (rend != undefined) then 
		(
			if ((rend.classid[1] == 1941615238) and (rend.classid[2] == 2012806412)) != true then
			(
				MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
				rend = undefined
			)
		) 
		else 
		(
			MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
			rend = undefined
		)
		rend
	)

	fn deleteMCCustAttribute obj =
	(
		for i=(custAttributes.count obj) to 1 by -1 where (classof (custAttributes.get obj i) as string == "<AttributeDef:MultiCamAttributeData>") do custAttributes.delete obj i
	)


	fn getVraySunInScene = 
	(
		local result = undefined
		local allSuns = for o in objects where classof o == VraySun collect o

		if (allSuns.count == 1 ) then
		(
			result = allSuns[1]
		)
		else if (allSuns.count > 1) then (MessageBox ("There are " + allSuns.count as string + " in the scene.\nThere can only be one!"); result = undefined)
		else
		(
			MessageBox ("No VraySun in the scene.")
			result = undefined
		)
		result
	)
	
	
	fn findInArrayOfArray n arr = 
	(
		result = undefined
		for i =1 to arr.count do
		(
			if n == arr[i][1] then result = i
		)
		result
	)
	
	fn gwDisplay = gwDisplaySunpoints()
	
	fn gwDisplaySunpoints =
	(
		local cam = (refs.dependentNodes (custattributes.getowner this))
		local camName = ""
		if cam != undefined then
		(
			if cam[1] != undefined then 
			(
				camName = cam[1].name
				--cols = #(yellow,red,blue,green,black)
				gw.setTransform (matrix3 1)
				gw.text ((this.sP_val)) ("Sun_" + camName) color:yellow--color:cols[( cols.count)]
				gw.text ((this.sT_val)) ("SunTarget_" + camName) color:yellow
				gw.Marker ((this.sP_val)) #plusSign color:red
				gw.Marker ((this.sT_val)) #plusSign color:red
				gw.setColor #line red
				gw.Polyline #(((this.sP_val)),((this.sT_val))) false --rgb:#([255,0,0],[255,0,0],[255,0,0])
				gw.enlargeUpdateRect #whole
			)
		)
		--check if the dependent is still there, in this case the camera
 		try
		(
			if ((refs.dependentNodes (custattributes.getowner this)).count  == 0) then
			(
				unregisterRedrawViewsCallback gwDisplay
			)
		)
		catch
		(
			unregisterRedrawViewsCallback gwDisplay
		)
	)

	fn gwActiveSettings = gwShowActiveSettings()

	fn gwShowActiveSettings =
	(
		local cam = (refs.dependentNodes (custattributes.getowner this))
		local camName = ""
		if cam[1] != undefined then camName = cam[1].name
		rect = (box2 13 47 96 97)
		eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
		eRect.right += 1
		eRect.bottom += 1
		local displayText = ("Settings active for camera: " + camName + "\nChanges made to Environment, Frame Range or Resolution will not effect default settings")
		local ext = gw.getTextExtent displayText
		gw.wtext [rect.left + 15 ,rect.top+20,0] displayText color:white
		gw.wrect (box2 (rect.left + 15 ) (rect.top+25+ ext.y/2) ext.x 5) red
		gw.enlargeUpdateRect eRect
		gw.updateScreen()

		if ((refs.dependentNodes (custattributes.getowner this)).count  == 0) then
		(
			unregisterRedrawViewsCallback gwActiveSettings
		)
	)
	
	fn AniCheck_fn obj=
	(
		if (superclassof obj == camera) then
		(
			result = #()
			mapkeys obj (fn CollectKeys t k = (append k t; t)) (keys=#()) #allkeys
			if obj.target != undefined then
			(
				mapkeys obj.target (fn CollectKeys t k = (append k t; t)) (keys2=#()) #allkeys
				result =  #(amin (join keys keys2) , amax (join keys keys2))
			)
			else result =  #(amin keys, amax keys)
			if result[1] == undefined or result[2] == undefined then return undefined
			else return result
		)
		else return undefined
	)

	fn getThisCameraName =
	(
		local result = ( refs.dependentNodes (custattributes.getowner this) )
		if result != undefined then result = result[1].name
		else result = ""
		result
	)

	fn emitUpdateEvent2 = 
	(
		--workaround: need to find a good way to emit an event for callback function to catch
		local cam = (refs.dependentNodes (custattributes.getowner this))
		if cam != undefined then
		(
			if cam[1] != undefined then 
			(
				if isProperty cam[1] "MultiCamAttributeData" then
				(
					r = (random 0 500)
					cam[1].baseObject.hiddenController_spn = r
				)
			)
		)
	)

	fn emitUpdateEvent =
	(
		if MultiCamLister != undefined then
		(
			MultiCamLister.updateRowFromObj $ MultiCamLister.MultiCamLister_ro.dgv
		)
	)

	fn getObjectFromThis =
	(
		local result = ( refs.dependentNodes (custattributes.getowner this) )
		if result != undefined then result = result[1]
		result
	)
	
	fn changeStateLayers state = 
	(
		this.layers_ro.useHideLayers_chb.checked = state
		this.layers_ro.hideLayers_lb.enabled = state
		this.layers_ro.clearLayers_btn.enabled = state
		this.layers_ro.addLayers_btn.enabled = state
		this.layers_ro.addHiddenLayers_btn.enabled = state
		this.layers_ro.removeLayers_btn.enabled = state
	)
	
	fn changeStateSunpoints state = 
	(
		this.sunpoints_ro.useSunpoints_chb.checked = state
		this.sunpoints_ro.sP_txt.enabled = state
		this.sunpoints_ro.sT_txt.enabled = state
		this.sunpoints_ro.showSunPoint_btn.enabled = state
		this.sunpoints_ro.readSunPos_btn.enabled = state
		this.sunpoints_ro.moveSunToPos_btn.enabled = state
		this.sunpoints_ro.createSunPoint_btn.enabled = state
	)

	fn changeStateResolution state = 
	(
		this.resolution_ro.useHeightWidth_chb.checked = state
		this.resolution_ro.imgWidth_sp.enabled = state
		this.resolution_ro.imgHeight_sp.enabled = state
		this.resolution_ro.getImgFrame_btn.enabled = state
	)
	
	fn changeStateHDRI state = 
	(
		this.hdriMap_ro.useHDRIMap_chb.checked = state
		this.hdriMap_ro.hdriMap_btn.enabled = state
		this.hdriMap_ro.hdriMapLink_chb.enabled = state
		this.hdriMap_ro.hdriMapEdit_btn.enabled = state
		--this.hdriMap_ro.hdriMapOffset_sp.enabled = state
		this.hdriMap_ro.hdriMapGIMult_sp.enabled = state
		this.hdriMap_ro.hdriMapReflMult_sp.enabled = state
		this.hdriMap_ro.hdriMapRefrMult_sp.enabled = state
		this.hdriMap_ro.hdriMapGI_chb.enabled = state
		this.hdriMap_ro.hdriMapRefl_chb.enabled = state
		this.hdriMap_ro.hdriMapRefr_chb.enabled = state
	)
		
	fn checkHDRIconnection =
	(
		if (this.hdriMap_val != undefined and (classof this.hdriMap_val == VrayHDRI or classof this.hdriMap_val == VRayBitmap)) then
		(
			if ((classof this.hdriMap_val.cropplace_u.controller) == float_script) then
			(
				if (refs.dependentNodes ((this.hdriMap_val.cropplace_u.controller.Gettarget "t_x_pos").parent)).count < 1 then
				(
					this.hdriMapLink_chb = false
					this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
				)
				else
				(
					if this.hdriMapLink_chb != true then this.hdriMapLink_chb = true
					this.hdrimap_ro.hdriMapLink_chb.caption = "Linked Press to Unlink"
				)
			)
		)

		if (this.hdriMap_val != undefined) then
		(
			hdriMapName = this.hdriMap_val.name
			this.hdrimap_ro.hdriMapLoader_btn.caption = hdriMapName
		)
		else
		(
			this.hdriMapLink_chb = false
			this.hdrimap_ro.hdriMapLoader_btn.caption = "None"
			this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
		)
	)
	
	-----------------------------------------------------
	--PARAMETERS-----------------------------------
	-----------------------------------------------------
	
	parameters main rollout:params
	(
		cameraObject_btn type:#node animatable:false ui:cameraObject_btn
		hiddenController_spn type:#float animatable:true ui:hiddenController_spn default:0.0
		--customPass_txt type:#string animatable:false ui:customPass_txt default:""
		--activateSettings_btn type:#boolean animatable:false ui:activateSettings_btn default:false

		/*
		on activateSettings_btn set state do
		(
			if state == true then
			(
				registerRedrawViewsCallback gwActiveSettings
			)
			else
			(
				unregisterRedrawViewsCallback gwActiveSettings
			)
		)
		

		on main reload do 
		(
			--allMods = for m in $.modifiers where (classof m == MultiCamAttribute) collect m
			passNames = #("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
			allMods = #()
			for m in $.modifiers where (classof m == MultiCamAttribute) do
			(
				append allMods m
			)
			
			for i = 1 to allMods.count do
			(
				--allMods[i].customPass_txt.text = passNames[i]
			)
		)
		*/
	)
	
	parameters sunpoints_params rollout:sunpoints_ro
	(
		--SUNPOINTS
		useSunpoints_param type:#boolean animatable:false ui:useSunpoints_chb default:true
		sP_val type:#point3 animatable:false default:[10000,-7000,5500]
		sT_val type:#point3 animatable:false default:[0,0,0]
		showSunPoint_btn type:#boolean animatable:false ui:showSunPoint_btn default:false
		viewFromSun_btn type:#boolean animatable:false ui:viewFromSun_btn default:false
		readSunPos_btn type:#boolean animatable:false ui:readSunPos_btn default:false
		moveSunToPos_btn type:#boolean animatable:false ui:moveSunToPos_btn default:false
		--old variables for backwards compatibility
		sP_txt type:#string animatable:false default:"[10000,-7000,5500]"
		sT_txt type:#string animatable:false default:"[0,0,0]"
		
		on useSunpoints_param set state do 
		(
			--format "this param com obj %\n" (getObjectFromThis())
			if getObjectFromThis() == $ then
			(
				this.sunpoints_ro.sP_txt.enabled = state
				this.sunpoints_ro.sT_txt.enabled = state
				this.sunpoints_ro.showSunPoint_btn.enabled = state
				this.sunpoints_ro.readSunPos_btn.enabled = state
				this.sunpoints_ro.moveSunToPos_btn.enabled = state
				this.sunpoints_ro.createSunPoint_btn.enabled = state
				this.sunpoints_ro.viewFromSun_btn.enabled = state
			)
			
			if state == false then
			(
				showSunPoint_btn = false
				unregisterRedrawViewsCallback gwDisplay
			)
			emitUpdateEvent()
		)
		
		on showSunPoint_btn set state do
		(
			if state == true then
			(
				registerRedrawViewsCallback gwDisplay
			)
			else
			(
				unregisterRedrawViewsCallback gwDisplay
			)
			emitUpdateEvent()
		)
		
		on viewFromSun_btn set val do
		(
			if val == true then
			(
				if ((getVraySunInScene()) != undefined) then
				(
					viewport.setCamera (getVraySunInScene())
				)
				viewFromSun_btn = false
			)
		)
		
		on readSunPos_btn set val do
		(
			if val == true then
			(
				if ((getVraySunInScene()) != undefined) then
				(
					
					local sun = getVraySunInScene()
					this.sP_val = sun.position
					this.sT_val = sun.target.position
					this.sunpoints_ro.sP_txt.text = this.sP_val as string
					this.sunpoints_ro.sT_txt.text = this.sT_val as string

				)
				readSunPos_btn = false	
			)
		)
		
		on moveSunToPos_btn set val do
		(
			if val == true then
			(
				if ((getVraySunInScene()) != undefined) then
				(
					local sun = getVraySunInScene()
					sun.pos = (this.sP_val)
					sun.target.pos = (this.sT_val)
				)
				moveSunToPos_btn = false
			)
		)		
	)
	
	parameters frameRange_params rollout:frameRange_ro
	(
		--FRAME RANGE
		getFrameRange_btn type:#boolean animatable:false ui:getFrameRange_btn default:false
		firstFrame_sp type:#integer animatable:false ui:firstFrame_sp default:0
		lastFrame_sp type:#integer animatable:false ui:lastFrame_sp default:0

		on getFrameRange_btn set val do
		(
			if val == true then
			(
				local cam = (refs.dependentNodes (custattributes.getowner this))[1]
				if aniCheck_fn cam != undefined then
				(
					local camAnimation = AniCheck_fn cam
					firstFrame_sp = camAnimation[1]
					lastFrame_sp = camAnimation[camAnimation.count]

					emitUpdateEvent()
				)
				else (MessageBox ("No Animation"))
				getFrameRange_btn = false
			)
		)
	)
	
	parameters layers_params rollout:layers_ro
	(
		--HIDE LAYERS
		useHideLayers_chb type:#boolean animatable:false ui:useHideLayers_chb default:false
		hideLayers_tab type:#stringTab tabSize:1 tabSizeVariable:true ui:hideLayers_lb default:"-- All Layers Unhidden --"
		--hideLayers_lb type:#boolean ui:hideLayers_lb
		clearLayers_btn type:#boolean animatable:false ui:clearLayers_btn default:false
		addLayers_btn type:#boolean animatable:false ui:addLayers_btn default:false
		addHiddenLayers_btn type:#boolean animatable:false ui:addHiddenLayers_btn default:false
		
		on addLayers_btn set val do
		(
			if val == true then
			(			
				local layerNameSelector = rollout layerNameSelector "Select Layers to Hide" width:200 height:460
				(
					local result = #()
					local layerNames

					MultiListBox  layerSelection_lb "Layers:" items:#() height:30
					button addSelected_btn "Add Selected" across:2 width:80
					button cancelAdding_btn "Cancel" width:80
					
					fn init val:undefined =
					(
						try destroyDialog layerNameSelector catch()
						result = val
						createDialog layerNameSelector modal:true
						result
					)
					
					--on layerSelection_lb selectionEnd do format "selectionEnd: %\n" layerSelection_lb.selection

					on layerNameSelector open do 
					(
						layerNames = (for i=0 to layermanager.count-1 collect (layermanager.getlayer i).name)
						layerNames = sort layerNames
						layerSelection_lb.items = layerNames
						setFocus layerNameSelector						
					)

					on cancelAdding_btn pressed do
					(
						result = #()
						destroydialog layerNameSelector
					)

					on addSelected_btn pressed do
					(
						for l in layerSelection_lb.selection do
						(
							append result layerNames[l]
						)

						destroydialog layerNameSelector
					)
				)
				
				local layerResult = layerNameSelector.init()
				hideLayers_tab = makeUniqueArray(join layerResult hideLayers_tab )

				if hideLayers_tab.count > 1 then
				(
					local itemToDelete = (findItem hideLayers_tab "-- All Layers Unhidden --" )
					if itemToDelete != 0 then deleteItem hideLayers_tab itemToDelete
				)
				
				if getObjectFromThis() == $ then
				(
					this.layers_ro.hideLayers_lb.items = hideLayers_tab as array
				)
				addLayers_btn = false
			)
		)

		on clearLayers_btn set val do
		(
			if val == true then
			(
				/*
				hideLayers_tab = #()
				this.layers_ro.hideLayers_lb.items = #()
				
				if hideLayers_tab.count == 0 then
				(
					hideLayers_tab =  #("-- All Layers Unhidden --")
					this.layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
				)
				*/
				
				hideLayers_tab = #("-- All Layers Unhidden --")
				
				if getObjectFromThis() == $ then
				(
					this.layers_ro.hideLayers_lb.items = hideLayers_tab as array
				)
				clearLayers_btn = false
			)
		)
		
		on addHiddenLayers_btn set val do
		(
			if val == true then
			(
				hideLayers_tab = #()
				--this.layers_ro.hideLayers_lb.items = #()
				
				n = LayerManager.count
				for i = 0 to n-1 do
				(
					if (layermanager.getlayer i).on == false then
					(
						appendifunique hideLayers_tab (layermanager.getlayer i).name
						--this.layers_ro.hideLayers_lb.items = makeUniqueArray (append this.layers_ro.hideLayers_lb.items (layermanager.getlayer i).name)
					)
				)
				
				if hideLayers_tab.count == 0 then
				(
					hideLayers_tab = #("-- All Layers Unhidden --")
				)
				
				if getObjectFromThis() == $ then
				(
					this.layers_ro.hideLayers_lb.items = hideLayers_tab as array
				)

				addHiddenLayers_btn = false
			)
		)

		on useHideLayers_chb set val do 
		(

			if val == true and hideLayers_tab.count == 0 then
			(
				hideLayers_tab = #("-- All Layers Unhidden --")
				--this.layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
			)
			else if val == false and hideLayers_tab == "-- All Layers Unhidden --" then
			(
				-- workaround when adding a modifier through MultiCam Lister
				try(
					hideLayers_tab = deleteItem hideLayers_tab 1
					--this.layers_ro.hideLayers_lb.items = deleteItem this.layers_ro.hideLayers_lb.items 1
				)catch()
			)

			if getObjectFromThis() == $ then
			(
				this.layers_ro.hideLayers_lb.enabled = val
				this.layers_ro.clearLayers_btn.enabled = val
				this.layers_ro.addLayers_btn.enabled = val
				this.layers_ro.addHiddenLayers_btn.enabled = val
				this.layers_ro.removeLayers_btn.enabled = val
				this.layers_ro.hideLayers_lb.items = hideLayers_tab as array
			)

			emitUpdateEvent()
		)	
		
	)

	parameters hdriMap_params rollout:hdriMap_ro
	(
		--HDRI MAP
		useHDRIMap_val type:#boolean animatable:false ui:useHDRIMap_chb default:false
		hdriMapLoader_val type:#boolean animatable:false ui:hdriMapLoader_btn default:false
		hdriMap_val type:#texturemap animatable:false ui:hdriMap_btn --this actually holds the map, hidden in ui
		
		--old variable for backwards compatibility
		hdriMap_btn type:#texturemap animatable:false
		useHDRIMap_chb type:#boolean animatable:false
		
		hdriMapLink_chb type:#boolean animatable:false ui:hdriMapLink_chb default:false
		hdriMapEdit_btn type:#boolean animatable:false ui:hdriMapEdit_btn default:false
		
		hdriMapGIMult_sp type:#float animatable:false ui:hdriMapGIMult_sp default:1.0
		hdriMapReflMult_sp type:#float animatable:false ui:hdriMapReflMult_sp default:1.0
		hdriMapRefrMult_sp type:#float animatable:false ui:hdriMapRefrMult_sp default:1.0
		
		hdriMapGI_val type:#boolean animatable:false ui:hdriMapGI_chb default:false
		hdriMapRefl_val type:#boolean animatable:false ui:hdriMapRefl_chb default:false
		hdriMapRefr_val type:#boolean animatable:false ui:hdriMapRefr_chb default:false

		on useHDRIMap_val set state do 
		(
			if getObjectFromThis() == $ then
			(
				this.hdriMap_ro.hdriMap_btn.enabled = state
				this.hdriMap_ro.hdriMapLink_chb.enabled = state
				this.hdriMap_ro.hdriMapLoader_btn.enabled = state
				this.hdriMap_ro.hdriMapEdit_btn.enabled = state
				
				this.hdriMap_ro.hdriMapGIMult_sp.enabled = (state and hdriMapGI_val)
				this.hdriMap_ro.hdriMapReflMult_sp.enabled = (state and hdriMapRefl_val)
				this.hdriMap_ro.hdriMapRefrMult_sp.enabled = (state and hdriMapRefr_val)
				
				this.hdriMap_ro.hdriMapGI_chb.enabled = state
				this.hdriMap_ro.hdriMapRefl_chb.enabled = state
				this.hdriMap_ro.hdriMapRefr_chb.enabled = state
			)
			emitUpdateEvent()
		)
		
		on hdriMapGI_val set state do 
		(
			this.hdriMap_ro.hdriMapGIMult_sp.enabled = state
		)
		
		on hdriMapRefl_val set state do 
		(
			this.hdriMap_ro.hdriMapReflMult_sp.enabled = state
		)
		
		on hdriMapRefr_val set state do 
		(
			this.hdriMap_ro.hdriMapRefrMult_sp.enabled = state
		)

		on hdriMapLoader_val set val do
		(
			if val == true then
			(
				local selectedMap = MultiCamHDRILib.show()
				local hdriMapLoaderButtonCaption = "None"
				local hdriMapLinkButtonCaption = "Link HDRI to Sun"
				
				if selectedMap != undefined then 
				(
					if (classof selectedMap == VrayHDRI or classof selectedMap == VRayBitmap) then
					(
						selectedMap.name = "HDRI for " + (getThisCameraName())
						hdriMap_val = selectedMap
						hdriMapLoaderButtonCaption = selectedMap.name

						-- ask to link here --
						local vraySuns = for o in lights where (classof o == VRaySun) collect o
						if vraySuns.count > 0 then
						( 
							local qb = QueryBox "Link the HDRI map to the VraySun?"
							if qb == true then
							(
								hdriMapLink_chb = true
							)
							else 
							(
								hdriMapLink_chb = false
								hdriMapLinkButtonCaption = "Link HDRI to Sun"
							)
						)
						else 
						(
							hdriMapLink_chb = false
							hdriMapLinkButtonCaption = "Link HDRI to Sun"
						)
					)
					else if (selectedMap == "none") then
					(
						hdriMap_val = undefined
						hdriMapLoaderButtonCaption = "None"
						hdriMapLink_chb = false
						hdriMapLinkButtonCaption = "Link HDRI to Sun"
					)
					else if (selectedMap == "vraysky") then
					(
						local newVraySky = VraySky()
						newVraySky.name = "VraySky for " + (getThisCameraName())
						
						hdriMap_val = newVraySky
						hdriMapLoaderButtonCaption = newVraySky.name
						hdriMapLink_chb = false
						hdriMapLinkButtonCaption = "Link HDRI to Sun"
					)
				)
				--cancelled selection but map alredy there
				else if (selectedMap == undefined and hdriMap_val != undefined) then
				(
					hdriMapLoaderButtonCaption = hdriMap_val.name
				)
				--cancelled selection with no map already present
				else 
				(
					hdriMapLoaderButtonCaption = "None"
					hdriMapLink_chb = false
					hdriMapLinkButtonCaption = "Link HDRI to Sun"
				)
				
				if getObjectFromThis() == $ then
				(
					this.hdrimap_ro.hdriMapLink_chb.caption = hdriMapLinkButtonCaption
					this.hdrimap_ro.hdriMapLoader_btn.caption = hdriMapLoaderButtonCaption
				)

				hdriMapLoader_val = false
			)
			emitUpdateEvent()

		)
		
		on hdriMap_val set val do
		(
			if (classof val == VRayHDRI or classof val == VRayBitmap or classof val == VraySky) then
			(
				hdriMap_val = val				
			)
			else
			(
				hdriMap_val = undefined
			)
		)
		
		on hdriMapEdit_btn set val do
		(
			if val == true then
			(
				if (hdriMap_val != undefined) then
				(
					MatEditor.Open() 
					medit.PutMtlToMtlEditor hdriMap_val 1
					medit.SetActiveMtlSlot 1 true
				)
				else (MessageBox ("No VrayHDRI map in the map slot."))
				
				hdriMapEdit_btn = false
			)
		)

		on hdriMapLink_chb set val do
		(
			local hdriMapLinkButtonCaption = "Link HDRI to Sun"

			if val == true then
			(	
				if ((getVraySunInScene()) != undefined) then
				(
					if (hdriMap_val != undefined and (classof hdriMap_val == VrayHDRI or classof hdriMap_val == VRayBitmap)) then
					(
						local m = hdriMap_val
						m.cropplace_u.controller = float_script()
						
						local sun = getVraySunInScene()
						sunTarget = sun.target
						saModifier = this
						--saModifier.hdriMapOffset_sp.controller = Bezier_Float()
						
						m.cropplace_on = true
						m.cropplace_u.controller.AddTarget "t_x_pos" sun.pos.controller.'X Position'.controller
						m.cropplace_u.controller.AddTarget "t_y_pos" sun.pos.controller.'Y Position'.controller
						m.cropplace_u.controller.AddTarget "s_x_pos" sunTarget.pos.controller.'X Position'.controller
						m.cropplace_u.controller.AddTarget "s_y_pos" sunTarget.pos.controller.'Y Position'.controller
						--We use addNode because of circular dependency
						--m.cropplace_u.controller.addNode "offset" (refs.dependentNodes saModifier)[1]
						
						--issue: when copy and pasted the link will be broken
						--scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos)) + offset.modifiers[#MultiCam_Attribute].'hdriMapOffset_sp') 360 )/360.0"
						scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos))) 360 )/360.0"
						m.cropplace_u.controller.script = scriptstring
						
						hdriMapLink_chb = true
						hdriMapLinkButtonCaption = "Linked Press to Unlink"
					)
					else
					(
						MessageBox ("The map is not a VrayHDRI map.")
						if (hdriMap_val == undefined) then print "HDRI Settings is undefined"
						else print (classof hdriMap_val)
						if (hdriMap_btn == undefined) then print "HDRI old Settings is undefined"
						else print (classof hdriMap_btn)
						hdriMapLink_chb = false
						hdriMapLinkButtonCaption = "Link HDRI to Sun"
					)
				)
				else
				(
					hdriMapLink_chb = false
					hdriMapLinkButtonCaption = "Link HDRI to Sun"
				)
			)
			else
			(
				if (hdriMap_val != undefined and (classof hdriMap_val == VrayHDRI or classof hdriMap_val == VRayBitmap)) then
				(
					hdriMap_val.cropplace_u.controller = Bezier_Float()
				)

				hdriMapLink_chb = false
				hdriMapLinkButtonCaption = "Link HDRI to Sun"
			)

			if getObjectFromThis() == $ then
			(
				this.hdrimap_ro.hdriMapLink_chb.caption = hdriMapLinkButtonCaption
			)

			emitUpdateEvent()
		)
	)
	
	parameters resolution_params rollout:resolution_ro
	(
		--RESOLUTION
		useHeightWidth_chb type:#boolean animatable:false ui:useHeightWidth_chb default:false
		imgWidth_sp type:#integer animatable:false ui:imgWidth_sp default:1920
		imgHeight_sp type:#integer animatable:false ui:imgHeight_sp default:1080
		getImgFrame_btn type:#boolean animatable:false ui:getImgFrame_btn default:false
		

		on useHeightWidth_chb set val do 
		(
			if getObjectFromThis() == $ then
			(		
				this.resolution_ro.imgWidth_sp.enabled = val
				this.resolution_ro.imgHeight_sp.enabled = val
				this.resolution_ro.getImgFrame_btn.enabled = val
			)
			emitUpdateEvent()
		)

		on getImgFrame_btn set val do
		(
			if val == true then
			(	
				local vrayRend = checkRenderer()
				if vrayRend != undefined then
				(
					if (vrayRend.output_getsetsfrommax == false) then
					(
						imgWidth_sp = vrayRend.output_width
						imgHeight_sp = vrayRend.output_height
					)
					else
					(
						imgWidth_sp = renderWidth
						imgHeight_sp = renderHeight
					)

					if getObjectFromThis() == $ then
					(
						this.resolution_ro.imgWidth_sp.value = imgWidth_sp
						this.resolution_ro.imgHeight_sp.value = imgHeight_sp
					)
				)
				else 
				(
					MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
				)
				
				getImgFrame_btn = false
			)
			emitUpdateEvent()
		)
	)
	

	-----------------------------------------------------
	--ROLLOUTS--------------------------------------
	-----------------------------------------------------

	rollout params "Submitter Properties"
	(
		button openSubmitter_btn images:#(MCIconImgSq , MCIconImgSqMask, 3,2,2,2,2,true) toolTip:"Open Submitter" width:24 height:24 pos:[14,7] align:#left
		button openLister_btn images:#(MCIconImgSq , MCIconImgSqMask, 3,1,1,1,1,true) toolTip:"Open Camera Lister" width:24 height:24 pos:[69,7] align:#center
		button deleteMultiCamCA_btn images:#(MCIconImgSq , MCIconImgSqMask, 3,3,3,3,3,true) toolTip:"Delete this Custom Attribute" width:24 height:24 pos:[125,7] align:#right
		--checkbutton activateSettings_btn "Activate Settings" width:buttonWidth pos:[14,59] align:#center
		spinner hiddenController_spn pos:[0,0] visible:false
		pickbutton cameraObject_btn width:1 height:1 pos:[0,0] visible:false
		--editText customPass_txt "Custom Pass" text:""
		
		on openSubmitter_btn pressed do
		(
			macros.run "ilya_s Scripts" "MultiCamSubmitter"
		)
		
		on openLister_btn pressed do
		(
			macros.run "ilya_s Scripts" "MultiCamLister"
		)

		on deleteMultiCamCA_btn pressed do 
		(
			unregisterRedrawViewsCallback gwDisplay
			unregisterRedrawViewsCallback gwActiveSettings
			deleteMCCustAttribute $
			if multiCamListerFloater != undefined then
			(
				if multiCamListerFloater.open == true then ( multiCamListerFloater.rollouts[1].refresh_btn.pressed() )
			)
		)

		on params open do
		(
			local cam = ( refs.dependentNodes (custattributes.getowner this) )[1]
			cameraObject_btn.object = cam
		)

		
	)--end rollout

	rollout sunpoints_ro "Sunpoints"
	(
		checkbox useSunpoints_chb "Use Sunpoints" pos:[13,7] align:#center checked:useSunpoints_param
		checkbutton showSunPoint_btn images:#(MCiconImg , MCiconImgMask, 8,3,3,4,4,true) toolTip:"Show sun points" checked:false enabled:useSunpoints_param width:(buttonWidth/2) pos:[14,27]  align:#left
		checkbutton viewFromSun_btn images:#(MCiconImg , MCiconImgMask, 8,5,5,6,6,true) toolTip:"Set viewport to Sun's POV"  checked:false  enabled:useSunpoints_param width:(buttonWidth/2) pos:[82,27] align:#right
		edittext sP_txt "sP" text:(this.sP_val as string) readonly:true enabled:useSunpoints_param width:buttonWidth pos:[14,53] align:#center
		edittext sT_txt "sT" text:(this.sT_val as string) readonly:true enabled:useSunpoints_param width:buttonWidth pos:[14,75] align:#center
		checkbutton moveSunToPos_btn images:#(MCiconImg , MCiconImgMask, 8,1,1,2,2,true) toolTip:"Move Sun to point position" checked:false  enabled:useSunpoints_param width:buttonWidth pos:[14,123] align:#center
		checkbutton readSunPos_btn images:#(MCiconImg , MCiconImgMask, 8,7,7,8,8,true) toolTip:"Move Point to current sun position" checked:false  enabled:useSunpoints_param width:buttonWidth pos:[14,97] align:#center
		button createSunPoint_btn "Create Sun Helpers" enabled:useSunpoints_param width:buttonWidth pos:[14,175] align:#center
		
		on sunpoints_ro open do
		(
			objectName = getThisCameraName()
			--gto()
		)
		
		/*
		on useSunpoints_chb changed state do 
		(
			sP_txt.enabled = state
			sT_txt.enabled = state
			showSunPoint_btn.enabled = state
			readSunPos_btn.enabled = state
			moveSunToPos_btn.enabled = state
			createSunPoint_btn.enabled = state
			viewFromSun_btn.enabled = state
			
			if state == false then
			(
				showSunPoint_btn.checked = false
				unregisterRedrawViewsCallback gwDisplay
			)
			emitUpdateEvent()
		)
		*/
		
		on createSunPoint_btn pressed do
		(
			if ((getVraySunInScene()) != undefined) then
			(
				sunPointName = "Sun_" + selection[1].name
				sunTargetName = "SunTarget_" + selection[1].name
				sunPoint = point name: sunPointName pos: ( this.sP_val) constantscreensize: on
				sunTarget = point name: sunTargetName pos: ( this.sT_val) constantscreensize: on
				MessageBox ("Submitter no longer uses these helpers, use these as a placeholder or for debugging purposes.")
			)
		)

	)

	rollout frameRange_ro "Frame Range"
	(
		spinner firstFrame_sp "First Frame: " type:#integer range:[-1000000,1000000,0] pos:[38,7] fieldWidth:60 width:(buttonWidth - 24)
		spinner lastFrame_sp "Last Frame: " type:#integer range:[-1000000,1000000,0] pos:[38,28] fieldWidth:60 width:(buttonWidth - 24)
		checkbutton getFrameRange_btn "Get Frame Range" width:buttonWidth pos:[14,49]
		
		on firstFrame_sp changed n do
		(
			if (n > lastFrame_sp.value) then (lastFrame_sp.value = n + 1)
			emitUpdateEvent()
			--if (n > lastFrame_sp.value) then (firstFrame_sp.value = lastFrame_sp.value)
		)
		
		on lastFrame_sp changed n do
		(
			if (n < firstFrame_sp.value) then (firstFrame_sp.value = n - 1)
			emitUpdateEvent()
			--if (n < firstFrame_sp.value) then (lastFrame_sp.value = firstFrame_sp.value)
		)
	)
	
	rollout layers_ro "Layers"
	(			
		checkbox useHideLayers_chb "Use Hide Layers" pos:[13,7] align:#center
		listbox hideLayers_lb "Hide Layers:" items:(hideLayers_tab as array) enabled:useHideLayers_chb.state width:buttonWidth pos:[13,27] align:#center -- y position is desired position (pos:[13,43]) minus 16
		checkbutton addLayers_btn "Add Layers"  enabled:useHideLayers_chb.state width:buttonWidth pos:[14,185] align:#center
		checkbutton addHiddenLayers_btn "Add Hidden"  enabled:useHideLayers_chb.state width:buttonWidth pos:[14,211] align:#center
		button removeLayers_btn "Remove Selected" enabled:useHideLayers_chb.state width:buttonWidth pos:[13,237] align:#center
		checkbutton clearLayers_btn "Clear All" enabled:useHideLayers_chb.state width:buttonWidth pos:[13,263] align:#center
		
		on removeLayers_btn pressed do
		(
			if (hideLayers_lb.items.count > 0 and hideLayers_lb.selection > 0) then
			(
				hideLayers_tab = deleteItem hideLayers_tab hideLayers_lb.selection
				hideLayers_lb.items = deleteItem hideLayers_lb.items hideLayers_lb.selection
			)
			
			if hideLayers_lb.items.count == 0 then
			(
				hideLayers_lb.items = #("-- All Layers Unhidden --")
				hideLayers_tab = hideLayers_lb.items
			)
		)
	)
	
	rollout hdriMap_ro "HDRI Map"
	(
		checkbox useHDRIMap_chb "Use HDRI Map" pos:[13,7] align:#center
		checkbutton hdriMapLoader_btn hdriMapName tooltip:"Select Background Map" enabled:useHDRIMap_chb.state width:buttonWidth pos:[14,27] align:#center 
		mapbutton hdriMap_btn hdriMapName tooltip:"Select Background Map" enabled:useHDRIMap_chb.state width:buttonWidth pos:[14,105] align:#center visible:false
		checkbutton hdriMapEdit_btn "Edit HDRI"  enabled:useHDRIMap_chb.state width:buttonWidth pos:[14,53] align:#center
		checkbutton hdriMapLink_chb "Link HDRI to Sun" enabled:useHDRIMap_chb.state width:buttonWidth pos:[14,79] align:#center
		--spinner hdriMapOffset_sp "Map Rotation: "  type:#integer range:[0,360.0,0] enabled:useHDRIMap_chb.state pos:[21,105] align:#center fieldWidth:54 width:(buttonWidth - 7)
		
		groupBox hdriMults_gpb "HDRI Multipliers" pos:[4,126] width:154 height:83
			
		spinner hdriMapGIMult_sp   "        GI:"  type:#float range:[-1000000,1000000,1] enabled:(hdriMapGI_val and useHDRIMap_chb.state) pos:[38,145] fieldWidth:40 width:(buttonWidth - 32) align:#left across:2
		checkbox hdriMapGI_chb ""  checked:false enabled:useHDRIMap_chb.state tooltip:"Enable/Disable HDRI from affecting GI, current map in GI channel is unaffected if off." pos:[135,145] width: 15
		spinner hdriMapReflMult_sp "Reflection:"  type:#float range:[-1000000,1000000,1] enabled:(hdriMapRefl_val and useHDRIMap_chb.state) pos:[25,166] fieldWidth:40 width:(buttonWidth - 19) align:#left across:2
		checkbox hdriMapRefl_chb ""  checked:false enabled:useHDRIMap_chb.state tooltip:"Enable/Disable HDRI from affecting Reflection/Refraction, current map in Reflection/Refraction channel is unaffected if off." pos:[135,166] width: 15
		spinner hdriMapRefrMult_sp "Refraction:"  type:#float range:[-1000000,1000000,1] enabled:(hdriMapRefr_val and useHDRIMap_chb.state) pos:[23,187] fieldWidth:40 width:(buttonWidth - 17) align:#left across:2
		checkbox hdriMapRefr_chb ""  checked:false enabled:useHDRIMap_chb.state tooltip:"Enable/Disable HDRI from affecting Refraction, current map in Refraction channel is unaffected if off." pos:[135,187] width: 15
			
		
		on hdriMap_ro open do
		(
			this.checkHDRIconnection()
		)
		
-- 		on hdriMapOffset_sp changed n do
-- 		(
-- 			if (hdriMap_btn.map != undefined and (classof hdriMap_btn.map.cropplace_u.controller == float_script)) then
-- 			(
-- 				hdriMap_btn.map.cropplace_u.controller.update()
-- 			)
-- 			else
-- 			(
-- 				MessageBox ("HDRI Map not linked to sun or no HDRI map defined")
-- 				hdriMapOffset_sp.value = 0
-- 			)
-- 		)
	)
	
	rollout resolution_ro "Resolution"
	(	
		checkbox useHeightWidth_chb "Use Custom Size" pos:[13,7] align:#center
		spinner imgWidth_sp  " Width: " type:#integer range:[1,1000000,1920] enabled:useHeightWidth_chb.state pos:[41,27] width:(buttonWidth - 27)
		spinner imgHeight_sp "Height: " type:#integer range:[1,1000000,1080] enabled:useHeightWidth_chb.state pos:[41,48] width:(buttonWidth - 27)
		checkbutton getImgFrame_btn "Get Resolution"                         enabled:useHeightWidth_chb.state pos:[14,69] width:buttonWidth align:#center

		on imgWidth_sp changed n do (emitUpdateEvent())
		on imgHeight_sp changed n do (emitUpdateEvent())
	)
		
	rollout import_ro "Import from Old"
	(
		button importFromOld_bn "Import from Old" width:buttonWidth pos:[13,7] align:#center
		
		on importfromOld_bn pressed do
		(			
			if (doesfileexist(maxfilepath + "FrameRange.txt")) != false then
			(
				f = openFile (maxfilepath + "FrameRange.txt")
					
				if (f != undefined) then (seek f 0)
				try
				while not eof f do 
				(
					print "Parsing FrameRange.txt"
					parsedLine = readline f
					filterLine = filterString parsedLine "@ "
					filterLine2 = filterString parsedLine "#"
					print "@ Tokens from FrameRange.txt"
					print filterline
					print "# Tokens from FrameRange.txt"
					print filterline2[2]
					
					if (filterLine[1] as string == selection[1].name) then 
					( 
						this.firstFrame_sp = filterLine[2] as integer
						this.lastFrame_sp = filterLine[3] as integer
						
						if (filterLine[4] != undefined and filterline[4] as integer != undefined and filterLine[5] != undefined and filterline[5] as integer != undefined) then 
						(
							changeStateResolution true
							
							this.imgWidth_sp = filterLine[4] as integer
							this.imgHeight_sp = filterLine[5] as integer
						)
						else
						(
							changeStateResolution false
						)
							
						if (filterLine2[2] != undefined) then 
						(
							changeStateLayers true
							
							layer_array = execute ("#" + filterLine2[2]) as array
							print ("Will hide these layers" + layer_array as string)
							
							this.hideLayers_lb.items = layer_array
							this.hideLayers_tab = layer_array
							
							seek f 0
							exit
						)
						else
						(
							changeStateLayers false
						)
					)
				)			
				catch
				(
					MessageBox ("Camera " + selection[1].name + " was not found in the FrameRange.txt")
					
					changeStateLayers false
					changeStateResolution false
					
					print "end of file"
				)
				close f
				free f
			)
			else
			(
				MessageBox ("FrameRange.txt is not found in " + (maxfilepath) as string)
				changeStateLayers false
				changeStateResolution false
			)
			
			if (getNodebyName ("Sun_" + selection[1].name)) != undefined then
			(
				changeStateSunpoints true
				this.sP_val = (getNodebyName ("Sun_" + selection[1].name)).pos --as string
				
				if ((getVraySunInScene()) != undefined) then
				(
					local sun = getVraySunInScene()
					
					this.sT_val = sun.target.pos --as string
				)
			)
			else
			(
				if ((getVraySunInScene()) != undefined) then
				(
					Messagebox ("No sunpoints found, using current sun position.")
					
					changeStateSunpoints true
					
					local sun = getVraySunInScene()
					this.sP_val = sun.pos --as string
					this.sT_val = sun.target.pos --as string
				)
				else
				(
					Messagebox ("No sunpoints or VraySun found, sunpoints are not imported")
					changeStateSunpoints false
				)
			)
		)
	)
	
	rollout about_ro "About" 
	(
		label version_lbl versionText pos:[63,7] align:#center
	)
		
	
	on load do
	(
		
		if (multiCamUsable == true) then
		(
			if (hdriMap_val != undefined and (classof hdriMap_val == VrayHDRI or classof hdriMap_val == VRayBitmap)) then
			(
				if ((classof hdriMap_val.cropplace_u.controller) == float_script) then
				(
					m = hdriMap_val
					if (refs.dependentNodes ((m.cropplace_u.controller.Gettarget "t_x_pos").parent)).count < 1 then
					(
						relink = queryBox "Sun and HDRI Map link is broken.\nYES - to relink.\nNO  - leave unlinked." title:"Missing Link" beep:false
						if (relink == true) then
						(
							------NEEDS TESTING----------
							allSuns = for o in objects where classof o == VraySun collect o
							if (allSuns.count == 1 ) then
							(
								m.cropplace_u.controller = float_script()
								
								sun = allSuns[1]
								sunTarget = sun.target
								--hdriMapOffset_sp.controller = Bezier_Float()
								
								m.cropplace_on = true
								m.cropplace_u.controller.AddTarget "t_x_pos" sun.pos.controller.'X Position'.controller
								m.cropplace_u.controller.AddTarget "t_y_pos" sun.pos.controller.'Y Position'.controller
								m.cropplace_u.controller.AddTarget "s_x_pos" sunTarget.pos.controller.'X Position'.controller
								m.cropplace_u.controller.AddTarget "s_y_pos" sunTarget.pos.controller.'Y Position'.controller
								--We use addNode because of circular dependency
								--Needs testing $ may not work
								--m.cropplace_u.controller.addNode "offset" (refs.dependentNodes this)[1] --$
								
								--issue: when copy and pasted the link will be broken
								--scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos)) + offset.modifiers[#MultiCam_Attribute].'hdriMapOffset_sp') 360 )/360.0"
								scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos))) 360 )/360.0"
								m.cropplace_u.controller.script = scriptstring
							)
							else if (allSuns.count > 1) then (MessageBox ("RELINK FAILED!\nThere are " + allSuns.count as string + " in the scene.\nThere can only be one!"))
							else
							(
								MessageBox ("RELINK FAILED!\nNo VraySun in the scene.")
							)
						)
					)
				)
			)
		)
		else 
		(
			MessageBox ("MultiCam script is not loaded properly, MultiCam Attribute cannot be created.\nCheck MAXScript Listener.")
		)
		showSunPoint_btn = false
	)
	
	on update do
 	(
 		print("Current MultiCam Attribute version is " + version as string)
		if version == 1 then 
		( 
			print ("Beginning the update of MultiCam Attribute from v1")
			try
			(
				sP_val = (execute sP_txt)
				sT_val = (execute sT_txt)
				hdriMap_val = hdriMap_btn
				useHDRIMap_val = useHDRIMap_chb 
				print ("Updated the MultiCam Attribute from v1")
			)
			catch
			(
				print "Unable to update the MultiCam Attribute"
			)
			
		)
		
 	)
	/*
 	on postload do
 	(
 		MessageBox "postloaded"
 	)
 	

 	
 	on params reload do
 	(
 		MessageBox "reloaded"
 	)
 	
 	on create do
 	(
 		MessageBox "created"
 	)
 	
 	on postcreate do
 	(
		MessageBox "postcreated"
 	)
 	
	on clone orig do (format "cloned: % : % : % : %\n" this orig(this == orig) (delegate == orig.delegate); print delegate)
 	on attachedToNode this do print ("attaching to node " + this as string)


 	
 	on attachedToNode this do
 	(
 		print "attaching to node"
 		if this != undefined then
 		(
			result = for i=1 to this.modifiers.count where (classof this.modifiers[i] == MultiCamAttribute) collect i
			if (result.count > 1 and multiCamUsable == true) then 
			(
				local qb = QueryBox "There are more than one MultiCam Attribute added to this object.\nOverwrite?\nYES - Delete old replace with new\nNO - Do not add the new modifier, leave as is."
				if qb == true then
				(
					for i = result.count to 2 by -1 do
					(
						print ("false - deleting " + i as string)
						deleteModifier this (result[i])
					)
				)
				else 
				(
					for i = result.count - 1 to 1 by -1 do
					(
						print ("true - deleting " + i as string)
						deleteModifier this (result[i])
					)
				)
			)
			else if (result.count >= 1 and multiCamUsable == false) then
			(
				MessageBox ("MultiCam script is not loaded properly, MultiCam Attribute cannot be created.\nCheck MAXScript Listener.")
				for i = result.count to 1 by -1 do
				(
					print ("no good to go - deleting " + i as string)
					--deleteModifier this i
					this.modifiers[result[i]].enabled = false
				)
			)
		)
 	)	
	*/	
	on deleted  do
	(

		-- store map's handle as custom attribute
		-- convert float_expression to bezier_float with the result of the previous float_expression
		-- hdriMap_btn.cropplace_u.controller = Bezier_Float()
		unregisterRedrawViewsCallback gwDisplay
		unregisterRedrawViewsCallback gwActiveSettings
	)

	on detachedFromNode this do
	(	
		for i=1 to 24 do
		(
			if (getmeditmaterial i == hdriMap_val) then
			(
				setmeditmaterial i (standard())
			)
		)
		unregisterRedrawViewsCallback gwDisplay
		unregisterRedrawViewsCallback gwActiveSettings
	)
	
)