/*try(
	close MCiconImgMask
	close MCiconImg
	free MCiconImgMask
	free MCiconImg
)catch("sfsdffsdfsadf")
MCiconImgMask = null
MCiconImg = null
*/



MultiCamCustomAttribute = attributes MultiCamAttributeData
(
	local hdriMapName = "None"
	local objectName = ""
	local buttonWidth = 135
	local gwDisplaySunpoints
	local gwShowActiveSettings
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
		--cols = #(yellow,red,blue,green,black)
		gw.setTransform (matrix3 1)
		gw.text (execute(this.sP_txt)) ("Sun_" + objectName) color:yellow--color:cols[( cols.count)]
		gw.text (execute(this.sT_txt)) ("SunTarget_" + objectName) color:yellow
		gw.Marker (execute(this.sP_txt)) #plusSign color:red
		gw.Marker (execute(this.sT_txt)) #plusSign color:red
		gw.setColor #line red
		gw.Polyline #((execute(this.sP_txt)),(execute(this.sT_txt))) false --rgb:#([255,0,0],[255,0,0],[255,0,0])
		gw.enlargeUpdateRect #whole
		
		--check if the dependent is still there, in this case the camera
 		if ((refs.dependentNodes (custattributes.getowner this)).count  == 0) then
 		(
 			unregisterRedrawViewsCallback gwDisplay
 		)
	)

	/*
unregisterRedrawViewsCallback GW_displayObjectNames
fn GW_displayObjectNames =
(
	rect = (box2 13 47 96 97)
	--gw.wrect rect red
	gw.wmarker [rect.left,rect.top,0] #point color:green
	gw.wmarker [rect.left,rect.bottom,0] #point color:green
	gw.wmarker [rect.right,rect.top,0] #point color:green
	gw.wmarker [rect.right,rect.bottom,0] #point color:green
	eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
	eRect.right += 1
	eRect.bottom += 1
	local displayText = ("Settings active for camera: " +"camera Name"+"\nNo changes to environment, frame range or resolution will affect default settings")
	gw.wtext [rect.left + 15 ,rect.top+20,0] displayText color:white
	local ext = gw.getTextExtent displayText
	gw.wrect (box2 (rect.left + 15 ) (rect.top+25+ ext.y/2) ext.x 5) red
	gw.enlargeUpdateRect eRect
	gw.updateScreen()
)

registerRedrawViewsCallback GW_displayObjectNames
	*/

	fn gwActiveSettings = gwShowActiveSettings()

	fn gwShowActiveSettings =
	(
		rect = (box2 13 47 96 97)
		eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
		eRect.right += 1
		eRect.bottom += 1
		local displayText = ("Settings active for camera: " + objectName + "\nChanges made to Environment, Frame Range or Resolution will not effect default settings")
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
	
	fn changeStateLayers state = 
	(
		this.layers_ro.useHideLayers_chb.checked = state
		this.layers_ro.hideLayers_lb.enabled = state
		this.layers_ro.clearLayers_btn.enabled = state
		this.layers_ro.addLayers_btn.enabled = state
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
	)
		
	fn checkHDRIconnection =
	(
		print "checking connection"
		print hdriMap_btn
		print this.hdrimap_btn
		if (this.hdriMap_btn != undefined and (classof this.hdriMap_btn.cropplace_u.controller) == float_script) then
		(
			if (refs.dependentNodes ((this.hdriMap_btn.cropplace_u.controller.Gettarget "t_x_pos").parent)).count < 1 then
			(
				print "--1"
				this.hdriMapLink_chb = false
				this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
			)
			else
			(
				print "--2"
				if this.hdriMapLink_chb != true then this.hdriMapLink_chb = true
				this.hdrimap_ro.hdriMapLink_chb.caption = "Linked Press to Unlink"
			)
		)
		if (this.hdriMap_btn != undefined) then
		(
			print "--3"
			hdriMapName = this.hdriMap_btn.name
			this.hdrimap_ro.hdriMapLoader_btn.caption = hdriMapName
		)
		else
		(
			print "--4"
			this.hdriMapLink_chb = false
			this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
		)
	)
	
	-----------------------------------------------------
	--PARAMETERS-----------------------------------
	-----------------------------------------------------
	
	parameters main rollout:params
	(
		--customPass_txt type:#string animatable:false ui:customPass_txt default:""
		activateSettings_btn type:#boolean animatable:false ui:activateSettings_btn default:false

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
	)
	
	parameters sunpoints_params rollout:sunpoints_ro
	(
		--SUNPOINTS
		useSunpoints_chb type:#boolean animatable:false ui:useSunpoints_chb default:true
		sP_txt type:#string animatable:false ui:sp_txt default:"[10000,-7000,5500]"
		sT_txt type:#string animatable:false ui:sT_txt default:"[0,0,0]"
		sP_name type:#string animatable:false default:""
		sT_name type:#string animatable:false default:""
		showSunPoint_btn type:#boolean animatable:false ui:showSunPoint_btn default:false
		viewFromSun_btn type:#boolean animatable:false ui:viewFromSun_btn default:false
		readSunPos_btn type:#boolean animatable:false ui:readSunPos_btn default:false
		moveSunToPos_btn type:#boolean animatable:false ui:moveSunToPos_btn default:false
		
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
					print "sP_txt"
					print sP_txt
					sP_txt = sun.position as string
					sT_txt = sun.target.position as string
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
					sun.pos = (execute sP_txt)
					sun.target.pos = (execute sT_txt)
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
		hideLayers_tab type:#stringTab tabSize:0 tabSizeVariable:true --ui:hideLayers_lb 
		--hideLayers_lb type:#boolean ui:hideLayers_lb
		clearLayers_btn type:#boolean animatable:false ui:clearLayers_btn default:false
		addLayers_btn type:#boolean animatable:false ui:addLayers_btn default:false
		
		on clearLayers_btn set val do
		(
			if val == true then
			(
				hideLayers_tab = #()
				this.layers_ro.hideLayers_lb.items = #()
				
				if hideLayers_tab.count == 0 then
				(
					hideLayers_tab =  #("-- All Layers Unhidden --")
					this.layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
				)
				clearLayers_btn = false
			)
		)
		
		on addLayers_btn set val do
		(
			if val == true then
			(
				hideLayers_tab = #()
				this.layers_ro.hideLayers_lb.items = #()
				
				n = LayerManager.count
				for i = 0 to n-1 do
				(
					if (layermanager.getlayer i).on == false then
					(
						appendifunique hideLayers_tab (layermanager.getlayer i).name
						this.layers_ro.hideLayers_lb.items = makeUniqueArray (append this.layers_ro.hideLayers_lb.items (layermanager.getlayer i).name)
					)
				)
				
				if hideLayers_tab.count == 0 then
				(
					hideLayers_tab = #("-- All Layers Unhidden --")
					this.layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
				)
				addLayers_btn = false
			)
		)

		on useHideLayers_chb set val do 
		(
			this.layers_ro.hideLayers_lb.enabled = val
			this.layers_ro.clearLayers_btn.enabled = val
			this.layers_ro.addLayers_btn.enabled = val
			this.layers_ro.removeLayers_btn.enabled = val
			
			if val == true and hideLayers_tab.count == 0 then
			(
				hideLayers_tab = #("-- All Layers Unhidden --")
				this.layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
			)
			else if val == false and hideLayers_tab == "-- All Layers Unhidden --" then
			(
				-- workaround when adding a modifier through MultiCam Lister
				try(
					hideLayers_tab = deleteItem hideLayers_tab 1
					this.layers_ro.hideLayers_lb.items = deleteItem this.layers_ro.hideLayers_lb.items 1
				)catch()
			)
		)	
		
	)

	parameters hdriMap_params rollout:hdriMap_ro
	(
		--HDRI MAP
		useHDRIMap_chb type:#boolean animatable:false ui:useHDRIMap_chb default:false
		hdriMapLoader_btn type:#boolean animatable:false ui:hdriMapLoader_btn default:false
		hdriMap_btn type:#texturemap animatable:false ui:hdriMap_btn
		hdriMapLink_chb type:#boolean animatable:false ui:hdriMapLink_chb default:false
		hdriMapEdit_btn type:#boolean animatable:false ui:hdriMapEdit_btn default:false
		--hdriMapOffset_sp type:#float animatable:true ui:hdriMapOffset_sp default:0.0
		hdriMapGIMult_sp type:#float animatable:false ui:hdriMapGIMult_sp default:1.0
		hdriMapReflMult_sp type:#float animatable:false ui:hdriMapReflMult_sp default:1.0
		hdriMapRefrMult_sp type:#float animatable:false ui:hdriMapRefrMult_sp default:1.0

		on useHDRIMap_chb set state do 
		(
			this.hdriMap_ro.hdriMap_btn.enabled = state
			this.hdriMap_ro.hdriMapLink_chb.enabled = state
			this.hdriMap_ro.hdriMapLoader_btn.enabled = state
			this.hdriMap_ro.hdriMapEdit_btn.enabled = state
			--this.hdriMap_ro.hdriMapOffset_sp.enabled = state
			this.hdriMap_ro.hdriMapGIMult_sp.enabled = state
			this.hdriMap_ro.hdriMapReflMult_sp.enabled = state
			this.hdriMap_ro.hdriMapRefrMult_sp.enabled = state
		)

		on hdriMapLoader_btn set val do
		(
			if val == true then
			(
				local selectedMap = MultiCamHDRILib.show()
				if selectedMap != undefined then 
				(
					selectedMap.name = "HDRI for " + objectName
					hdriMap_btn = selectedMap
					this.hdrimap_ro.hdriMapLoader_btn.caption = selectedMap.name

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
							this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
						)
					)
					else 
					(
						hdriMapLink_chb = false
						this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
					)
				)
				else if (selectedMap == undefined and this.hdriMap_btn != undefined) then
				(
					this.hdrimap_ro.hdriMapLoader_btn.caption = this.hdriMap_btn.name
				)
				else 
				(
					this.hdrimap_ro.hdriMapLoader_btn.caption = "None"
					hdriMapLink_chb = false
					this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
				)
				
				hdriMapLoader_btn = false
			)

		)
		
		on hdriMap_btn set val do
		(
			if (classof val == VRayHDRI) then
			(
				print ("val is " + val as string)
				hdriMap_btn = val				
			)
			else
			(
				hdriMap_btn = undefined
			)
		)
		

		on hdriMapEdit_btn set val do
		(
			if val == true then
			(
				if (hdriMap_btn != undefined) then
				(
					MatEditor.Open() 
					medit.PutMtlToMtlEditor hdriMap_btn 1
					medit.SetActiveMtlSlot 1 true
				)
				else (MessageBox ("No VrayHDRI map in the map slot."))
				
				hdriMapEdit_btn = false
			)
		)


		on hdriMapLink_chb set val do
		(
			print "1"
			if val == true then
			(	
				print "2"
				if ((getVraySunInScene()) != undefined) then
				(
					print "3"
					if (hdriMap_btn != undefined) then
					(
						local m = hdriMap_btn
						print m.name
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
						this.hdrimap_ro.hdriMapLink_chb.caption = "Linked Press to Unlink"
						print "4"
					)
					else
					(
						print "5"
						MessageBox ("The map is not a VrayHDRI map.")
						hdriMapLink_chb = false
						this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
					)
				)
				else
				(
					print "6"
					hdriMapLink_chb = false
					this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
				)
			)
			else
			(
				print "7"
				if (hdriMap_btn != undefined) then
				(
					print "8"
					hdriMap_btn.cropplace_u.controller = Bezier_Float()
				)

				hdriMapLink_chb = false
				this.hdrimap_ro.hdriMapLink_chb.caption = "Link HDRI to Sun"
			)
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
			this.resolution_ro.imgWidth_sp.enabled = val
			this.resolution_ro.imgHeight_sp.enabled = val
			this.resolution_ro.getImgFrame_btn.enabled = val
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
						this.resolution_ro.imgWidth_sp.value = vrayRend.output_width
						this.resolution_ro.imgHeight_sp.value = vrayRend.output_height
					)
					else
					(
						this.resolution_ro.imgWidth_sp.value = renderWidth
						this.resolution_ro.imgHeight_sp.value = renderHeight
					)
				)
				else 
				(
					MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
				)
				
				getImgFrame_btn = false
			)
		)
	)
	


	
	-----------------------------------------------------
	--ROLLOUTS--------------------------------------
	-----------------------------------------------------

	rollout params "Submitter Properties"
	(
		button openSubmitter_btn "Open Submitter" width:buttonWidth pos:[14,7] align:#center
		button openLister_btn "Open Cam Lister" width:buttonWidth pos:[14,33] align:#center
		checkbutton activateSettings_btn "Activate Settings" width:buttonWidth pos:[14,59] align:#center
		--editText customPass_txt "Custom Pass" text:""
		
		on openSubmitter_btn pressed do
		(
			macros.run "ilya_s Scripts" "MultiCamSubmitter"
		)
		
		on openLister_btn pressed do
		(
			macros.run "ilya_s Scripts" "MultiCamLister"
		)
		
	)--end rollout

	rollout sunpoints_ro "Sunpoints"
	(
		checkbox useSunpoints_chb "Use Sunpoints" pos:[13,7] align:#center
		edittext sP_txt "sP" text:"[10000,-7000,5500]" readonly:true enabled:useSunpoints_chb.state width:buttonWidth pos:[14,53] align:#center
		edittext sT_txt "sT" text:"[0,0,0]" readonly:true enabled:useSunpoints_chb.state width:buttonWidth pos:[14,75] align:#center
		checkbutton showSunPoint_btn images:#(MCiconImg , MCiconImgMask, 4,2,2,2,2,true) toolTip:"Show sun points" checked:false enabled:useSunpoints_chb.state width:buttonWidth pos:[14,27]  align:#center
		checkbutton moveSunToPos_btn images:#(MCiconImg , MCiconImgMask, 4,1,1,1,1,true) toolTip:"Move Sun to point position" checked:false  enabled:useSunpoints_chb.state width:buttonWidth pos:[14,123] align:#center
		checkbutton readSunPos_btn images:#(MCiconImg , MCiconImgMask, 4,4,4,4,4,true) toolTip:"Move Point to current sun position" checked:false  enabled:useSunpoints_chb.state width:buttonWidth pos:[14,97] align:#center
		checkbutton viewFromSun_btn images:#(MCiconImg , MCiconImgMask, 4,3,3,3,3,true) toolTip:"Set viewport to Sun's POV"  checked:false  enabled:useSunpoints_chb.state width:buttonWidth pos:[14,149] align:#center
		button createSunPoint_btn "Create Sun Helpers" enabled:useSunpoints_chb.state width:buttonWidth pos:[14,175] align:#center
		
		on sunpoints_ro open do
		(
			objectName = selection[1].name
		)
		
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
		)
		
		on createSunPoint_btn pressed do
		(
			if ((getVraySunInScene()) != undefined) then
			(
				sunPointName = "Sun_" + selection[1].name
				sunTargetName = "SunTarget_" + selection[1].name
				sunPoint = point name: sunPointName pos: (execute sP_txt.text) constantscreensize: on
				sunTarget = point name: sunTargetName pos: (execute sT_txt.text) constantscreensize: on
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
			--if (n > lastFrame_sp.value) then (firstFrame_sp.value = lastFrame_sp.value)
		)
		
		on lastFrame_sp changed n do
		(
			if (n < firstFrame_sp.value) then (firstFrame_sp.value = n - 1)
			--if (n < firstFrame_sp.value) then (lastFrame_sp.value = firstFrame_sp.value)
		)
	)
	
	rollout layers_ro "Layers"
	(			
		checkbox useHideLayers_chb "Use Hide Layers" pos:[13,7] align:#center
		listbox hideLayers_lb "Hide Layers:" items:(hideLayers_tab as array) enabled:useHideLayers_chb.state width:buttonWidth pos:[13,27] align:#center -- y position is desired position (pos:[13,43]) minus 16
		checkbutton addLayers_btn "Add Hidden"  enabled:useHideLayers_chb.state width:buttonWidth pos:[14,185] align:#center
		button removeLayers_btn "Remove Selected" enabled:useHideLayers_chb.state width:buttonWidth pos:[13,211] align:#center
		checkbutton clearLayers_btn "Clear All" enabled:useHideLayers_chb.state width:buttonWidth pos:[13,237] align:#center
		
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
		checkbutton hdriMapEdit_btn "Edit HDRI" align:#center enabled:useHDRIMap_chb.state width:buttonWidth pos:[14,53] align:#center
		checkbutton hdriMapLink_chb "Link HDRI to Sun" align:#center enabled:useHDRIMap_chb.state width:buttonWidth pos:[14,79] align:#center
		--spinner hdriMapOffset_sp "Map Rotation: "  type:#integer range:[0,360.0,0] enabled:useHDRIMap_chb.state pos:[21,105] align:#center fieldWidth:54 width:(buttonWidth - 7)
		
		groupBox hdriMults_gpb "HDRI Multipliers" pos:[4,126] width:154 height:83
			
		spinner hdriMapGIMult_sp   "        GI:"  type:#float range:[-1000000,1000000,1] enabled:useHDRIMap_chb.state pos:[38,145] fieldWidth:60 width:(buttonWidth - 24)
		spinner hdriMapReflMult_sp "Reflection:"  type:#float range:[-1000000,1000000,1] enabled:useHDRIMap_chb.state pos:[25,166] fieldWidth:60 width:(buttonWidth - 11)
		spinner hdriMapRefrMult_sp "Refraction:"  type:#float range:[-1000000,1000000,1] enabled:useHDRIMap_chb.state pos:[23,187] fieldWidth:60 width:(buttonWidth - 9)
		
		
		
		on hdriMap_ro open do
		(
			print "hdrimap_ro open"
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
				this.sP_txt = (getNodebyName ("Sun_" + selection[1].name)).pos as string
				
				if ((getVraySunInScene()) != undefined) then
				(
					local sun = getVraySunInScene()
					
					this.sT_txt = sun.target.pos as string
				)
			)
			else
			(
				if ((getVraySunInScene()) != undefined) then
				(
					Messagebox ("No sunpoints found, using current sun position.")
					
					changeStateSunpoints true
					
					local sun = getVraySunInScene()
					this.sP_txt = sun.pos as string
					this.sT_txt = sun.target.pos as string
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
		label version_lbl "v 0.909" pos:[63,7] align:#center
	)
		
-- 	on params reload do
-- 	(
-- 		MessageBox "reloaded"
-- 	)
-- 	
-- 	on create do
-- 	(
-- 		MessageBox "created"
-- 	)
-- 	
-- 	on postcreate do
-- 	(
-- 		MessageBox "postcreated"
-- 	)
	
	on load do
	(
		print "loading"
		if (multiCamUsable == true) then
		(
			if (hdriMap_btn != undefined and (classof hdriMap_btn.cropplace_u.controller) == float_script) then
			(
				m = hdriMap_btn
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
		else 
		(
			MessageBox ("MultiCam script is not loaded properly, MultiCam Attribute cannot be created.\nCheck MAXScript Listener.")
		)
		showSunPoint_btn = false
	)
	
-- 	on postload do
-- 	(
-- 		MessageBox "postloaded"
-- 	)
-- 	
-- 	on update do
-- 	(
-- 		MessageBox "updated"
-- 	)
-- 	
-- 	
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
		
	on deleted  do
	(
		print "deleting"
		-- store map's handle as custom attribute
		-- convert float_expression to bezier_float with the result of the previous float_expression
		-- hdriMap_btn.cropplace_u.controller = Bezier_Float()
		unregisterRedrawViewsCallback gwDisplay
		unregisterRedrawViewsCallback gwActiveSettings
	)

	on detachedFromNode this do
	(	
		print "detaching"
		for i=1 to 24 do
		(
			if (getmeditmaterial i == hdriMap_btn) then
			(
				setmeditmaterial i (standard())
			)
		)
		unregisterRedrawViewsCallback gwDisplay
		unregisterRedrawViewsCallback gwActiveSettings
	)
)
custAttributes.delete $ 1

custAttributes.add $ MultiCamCustomAttribute