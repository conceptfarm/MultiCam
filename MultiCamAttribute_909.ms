plugin modifier SubmitterAttributes
name:"Submitter Attributes"
category:"ilya_s Scripts"
classID:#(685321,452281)
extends:EmptyModifier
replaceUI:true
version:0.909
(
	local hdriMapName = "None"
	local objectName = ""
	local buttonWidth = 135
	local gwDisplaySunpoints
	local layers_ro
	local sunpoints_ro
	local resolution_ro
	local hdriMap_ro
	
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
		)
		return rend
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
		return result
	)
	
	
	fn findInArrayOfArray n arr = 
	(
		result = undefined
		for i =1 to arr.count do
		(
			if n == arr[i][1] then result = i
		)
		return result
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
		
		if ((refs.dependentNodes this).count  == 0) then
		(
			unregisterRedrawViewsCallback gwDisplay
		)
	)
	
	fn AniCheck_fn obj=
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
	
	fn changeStateLayers state = 
	(
		layers_ro.useHideLayers_chb.checked = state
		layers_ro.hideLayers_lb.enabled = state
		layers_ro.clearLayers_btn.enabled = state
		layers_ro.addLayers_btn.enabled = state
		layers_ro.removeLayers_btn.enabled = state
	)
	
	fn changeStateSunpoints state = 
	(
		sunpoints_ro.useSunpoints_chb.checked = state
		sunpoints_ro.sP_txt.enabled = state
		sunpoints_ro.sT_txt.enabled = state
		sunpoints_ro.showSunPoint_btn.enabled = state
		sunpoints_ro.readSunPos_btn.enabled = state
		sunpoints_ro.moveSunToPos_btn.enabled = state
		sunpoints_ro.createSunPoint_btn.enabled = state
	)

	fn changeStateResolution state = 
	(
		resolution_ro.useHeightWidth_chb.checked = state
		resolution_ro.imgWidth_sp.enabled = state
		resolution_ro.imgHeight_sp.enabled = state
		resolution_ro.getImgFrame_btn.enabled = state
	)
	
	fn changeStateHDRI state = 
	(
		hdriMap_ro.useHDRIMap_chb.checked = state
		hdriMap_ro.hdriMap_btn.enabled = state
		hdriMap_ro.hdriMapLink_lbl.enabled = state
		hdriMap_ro.hdriMapLink_btn.enabled = state
		hdriMap_ro.hdriMapEdit_btn.enabled = state
		hdriMap_ro.hdriMapOffset_sp.enabled = state
		hdriMap_ro.hdriMapGIMult_sp.enabled = state
		hdriMap_ro.hdriMapReflMult_sp.enabled = state
		hdriMap_ro.hdriMapRefrMult_sp.enabled = state
	)
	
	
	fn checkHDRIconnection =
	(
		if (hdriMap_ro.hdriMap_btn.map != undefined and hdriMap_ro.hdriMap_btn.map.cropplace_u.controller != undefined and hdriMap_ro.hdriMap_btn.enabled == true) then
		(
			if (refs.dependentNodes ((hdriMap_ro.hdriMap_btn.map.cropplace_u.controller.Gettarget "t_x_pos").parent)).count < 2 then
			(
				--MessageBox "Sun and HDRI Map link is broken.\nRelink"
				--workaround: maxscript doesnt know that this variable is a dotnetobject on initial run
				try(hdriMap_ro.hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Red)catch()
				hdriMap_ro.hdriMapLink_lbl.text = "Not Linked"
				hdriMap_ro.hdriMapLinkStatus = "Not Linked"
			)
			else
			(
				--workaround: maxscript doesnt know that this variable is a dotnetobject on initial run
				try(hdriMap_ro.hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Green)catch()
				hdriMap_ro.hdriMapLink_lbl.text = "Linked"
				hdriMap_ro.hdriMapLinkStatus = "Linked"
			)
		)
		else
		(
			--workaround: maxscript doesnt know that this variable is a dotnetobject on initial run
			try(hdriMap_ro.hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Gray)catch()
			hdriMap_ro.hdriMapLink_lbl.text = "Not Used"
			hdriMap_ro.hdriMapLinkStatus = "Not Used"
		)
	)
	
	-----------------------------------------------------
	--PARAMETERS-----------------------------------
	-----------------------------------------------------
	
	parameters main rollout:params
	(
		customPass_txt type:#string animatable:false ui:customPass_txt default:""
		on main reload do 
		(
			--allMods = for m in $.modifiers where (classof m == SubmitterAttributes) collect m
			passNames = #("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
			allMods = #()
			for m in $.modifiers where (classof m == SubmitterAttributes) do
			(
				append allMods m
			)
			
			for i = 1 to allMods.count do
			(
				allMods[i].customPass_txt.text = passNames[i]
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
		firstFrame_sp type:#integer animatable:false ui:firstFrame_sp default:0
		lastFrame_sp type:#integer animatable:false ui:lastFrame_sp default:0
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
				layers_ro.hideLayers_lb.items = #()
				
				if hideLayers_tab.count == 0 then
				(
					hideLayers_tab =  #("-- All Layers Unhidden --")
					layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
				)
				clearLayers_btn = false
			)
		)
		
		on addLayers_btn set val do
		(
			print val
			if val == true then
			(
				hideLayers_tab = #()
				layers_ro.hideLayers_lb.items = #()
				
				n = LayerManager.count
				for i = 0 to n-1 do
				(
					if (layermanager.getlayer i).on == false then
					(
						appendifunique hideLayers_tab (layermanager.getlayer i).name
						layers_ro.hideLayers_lb.items = makeUniqueArray (append layers_ro.hideLayers_lb.items (layermanager.getlayer i).name)
					)
				)
				
				if hideLayers_tab == 0 then
				(
					hideLayers_tab =  #("-- All Layers Unhidden --")
					layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
				)
				addLayers_btn = false
			)
		)

		on useHideLayers_chb set val do 
		(
			layers_ro.hideLayers_lb.enabled = val
			layers_ro.clearLayers_btn.enabled = val
			layers_ro.addLayers_btn.enabled = val
			layers_ro.removeLayers_btn.enabled = val
			
			if val == true and hideLayers_tab.count == 0 then
			(
				hideLayers_tab = #("-- All Layers Unhidden --")
				layers_ro.hideLayers_lb.items = #("-- All Layers Unhidden --")
			)
			else if val == false and hideLayers_tab == "-- All Layers Unhidden --" then
			(
				-- workaround when adding a modifier through MultiCam Lister
				try(
					hideLayers_tab = deleteItem hideLayers_tab 1
					layers_ro.hideLayers_lb.items = deleteItem layers_ro.hideLayers_lb.items 1
				)catch()
			)
		)	
		
	)

	parameters hdriMap_params rollout:hdriMap_ro
	(
		--HDRI MAP
		useHDRIMap_chb type:#boolean animatable:false ui:useHDRIMap_chb default:false
		hdriMap_btn type:#texturemap animatable:false ui:hdriMap_btn
		hdriMapLinkStatus type:#string animatable:false default:"Not Linked" --ui:hdriMapLink_lbl
		hdriMapLink_lbl type:#string animatable:false ui:hdriMapLink_lbl
		hdriMapLink_btn type:#boolean animatable:false ui:hdriMapLink_btn default:false
		hdriMapEdit_btn type:#boolean animatable:false ui:hdriMapEdit_btn default:false
		hdriMapOffset_sp type:#float animatable:true ui:hdriMapOffset_sp default:0.0
		hdriMapGIMult_sp type:#float animatable:false ui:hdriMapGIMult_sp default:1.0
		hdriMapReflMult_sp type:#float animatable:false ui:hdriMapReflMult_sp default:1.0
		hdriMapRefrMult_sp type:#float animatable:false ui:hdriMapRefrMult_sp default:1.0

		on useHDRIMap_chb set state do 
		(
			print "use hdri triggered"
			hdriMap_ro.hdriMap_btn.enabled = state
			hdriMap_ro.hdriMapLink_lbl.enabled = state
			
			if state == false then
			(
				--workaround: maxscript doesnt know that this variable is a dotnetobject on initial run
				try(hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Gray)catch()
				hdriMapLinkStatus = "Not Used"
				hdriMapLink_lbl = "Not Used"
			)
			else
			(
				this.checkHDRIconnection()				
			)
			
			hdriMap_ro.hdriMapLink_btn.enabled = state
			hdriMap_ro.hdriMapEdit_btn.enabled = state
			hdriMap_ro.hdriMapOffset_sp.enabled = state
			hdriMap_ro.hdriMapGIMult_sp.enabled = state
			hdriMap_ro.hdriMapReflMult_sp.enabled = state
			hdriMap_ro.hdriMapRefrMult_sp.enabled = state
		)

		on hdriMap_btn set val do
		(
			if (classof val == VRayHDRI) then
			(
				hdriMap_btn = val
				--workaround: maxscript doesnt know that this variable is a dotnetobject on initial run
				try(hdriMap_ro.hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Red)catch()
				hdriMap_ro.hdriMapLinkStatus = "Not Linked"
				hdriMap_ro.hdriMapLink_lbl.text = "Not Linked"
				
			)
			else
			(
				hdriMap_btn = undefined
				--workaround: maxscript doesnt know that this variable is a dotnetobject on initial run
				try(hdriMap_ro.hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Gray)catch()
				hdriMap_ro.hdriMapLinkStatus = "Not Linked"
				hdriMap_ro.hdriMapLink_lbl.text = "Not Linked"
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


		on hdriMapLink_btn set val do
		(
			if val == true then
			(	
				if ((getVraySunInScene()) != undefined) then
				(
					if (hdriMap_btn != undefined) then
					(
						local m = hdriMap_btn
						m.cropplace_u.controller = float_script()
						
						local sun = getVraySunInScene()
						sunTarget = sun.target
						saModifier = this
						saModifier.hdriMapOffset_sp.controller = Bezier_Float()
						
						m.cropplace_on = true
						m.cropplace_u.controller.AddTarget "t_x_pos" sun.pos.controller.'X Position'.controller
						m.cropplace_u.controller.AddTarget "t_y_pos" sun.pos.controller.'Y Position'.controller
						m.cropplace_u.controller.AddTarget "s_x_pos" sunTarget.pos.controller.'X Position'.controller
						m.cropplace_u.controller.AddTarget "s_y_pos" sunTarget.pos.controller.'Y Position'.controller
						--We use addNode because of circular dependency
						m.cropplace_u.controller.addNode "offset" (refs.dependentNodes saModifier)[1]
						
						--issue: when copy and pasted the link will be broken
						scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos)) + offset.modifiers[#Submitter_Attributes].'hdriMapOffset_sp') 360 )/360.0"
						m.cropplace_u.controller.script = scriptstring
						
						try(hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Green)catch()
						hdriMapLinkStatus = "Linked"
						hdriMapLink_lbl = "Linked"
					)
					else
					(
						MessageBox ("The map is not a VrayHDRI map.")
						try(hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Gray)catch()
						hdriMapLinkStatus = "Not Linked"
						hdriMapLink_lbl = "Not Linked"
					)
				)
				else
				(
					Messagebox ("No Suns")
					try(hdriMapLink_lbl.Backcolor = (dotnetclass "System.Drawing.Color").Gray)catch()
					hdriMapLinkStatus = "Not Used"
					hdriMapLink_lbl = "Not Used"
				)

				hdriMapLink_btn = false
			)
		)
	)
	
	parameters resolution_params rollout:resolution_ro
	(
		--RESOLUTION
		useHeightWidth_chb type:#boolean animatable:false ui:useHeightWidth_chb default:false
		imgWidth_sp type:#integer animatable:false ui:imgWidth_sp default:1920
		imgHeight_sp type:#integer animatable:false ui:imgHeight_sp default:1080
	)
	


	
	-----------------------------------------------------
	--ROLLOUTS--------------------------------------
	-----------------------------------------------------

	rollout params "Submitter Properties"
	(
		button openSubmitter_btn "Open Submitter" width:buttonWidth
		button openLister_btn "Open Cam Lister" width:buttonWidth
		editText customPass_txt "Custom Pass" text:""
		
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
		checkbox useSunpoints_chb "Use Sunpoints"
		edittext sP_txt "sP" text:"[10000,-7000,5500]" readonly:true enabled:useSunpoints_chb.state
		edittext sT_txt "sT" text:"[0,0,0]" readonly:true enabled:useSunpoints_chb.state
		checkbutton  showSunPoint_btn " Display Sun Points "	checked:false enabled:useSunpoints_chb.state width:buttonWidth
		checkbutton readSunPos_btn "Get Point from Sun" checked:false  enabled:useSunpoints_chb.state width:buttonWidth
		checkbutton moveSunToPos_btn " Move Sun to Point " checked:false  enabled:useSunpoints_chb.state width:buttonWidth
		checkbutton viewFromSun_btn "Sun POV"  checked:false  enabled:useSunpoints_chb.state width:buttonWidth
		button createSunPoint_btn "Create Sun Helpers" enabled:useSunpoints_chb.state width:buttonWidth
		
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
		
-- 		on viewFromSun_btn pressed do
-- 		(
-- 			if ((getVraySunInScene()) != undefined) then
-- 			(
-- 				viewport.setCamera (getVraySunInScene())
-- 			)
-- 		)
-- 		
-- 		on readSunPos_btn pressed do
-- 		(
-- 			if ((getVraySunInScene()) != undefined) then
-- 			(
-- 				local sun = getVraySunInScene()
-- 				sP_txt.text = sun.position as string
-- 				sT_txt.text = sun.target.position as string
-- 			)
-- 		)
-- 		
-- 		on moveSunToPos_btn pressed do
-- 		(
-- 			if ((getVraySunInScene()) != undefined) then
-- 			(
-- 				local sun = getVraySunInScene()
-- 				sun.pos = (execute sP_txt.text)
-- 				sun.target.pos = (execute sT_txt.text)
-- 			)
-- 		)
		
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
		spinner firstFrame_sp "First Frame: " type:#integer range:[-1000000,1000000,0]
		spinner lastFrame_sp "Last Frame: " type:#integer range:[-1000000,1000000,0]
		button getFrameRange_btn "Get Frame Range" width:buttonWidth
		
		on firstFrame_sp changed n do
		(
			if (n > lastFrame_sp.value) then (firstFrame_sp.value = lastFrame_sp.value)
		)
		
		on lastFrame_sp changed n do
		(
			if (n < firstFrame_sp.value) then (lastFrame_sp.value = firstFrame_sp.value)
		)
		
		on getFrameRange_btn pressed do
		(
			if aniCheck_fn $ != undefined then
			(
				camAnimation = AniCheck_fn $
				firstFrame_sp.value = camAnimation[1]
				lastFrame_sp.value = camAnimation[camAnimation.count]
			)
			else (MessageBox ("No Animation"))
		)
	)
	
	rollout layers_ro "Layers"
	(			
		checkbox useHideLayers_chb "Use Hide Layers" 
		listbox hideLayers_lb "Hide Layers:" items:(hideLayers_tab as array) enabled:useHideLayers_chb.state width:buttonWidth
		checkbutton addLayers_btn "Add Hidden"  enabled:useHideLayers_chb.state width:buttonWidth
		button removeLayers_btn "Remove Selected" enabled:useHideLayers_chb.state width:buttonWidth
		checkbutton clearLayers_btn "Clear All" enabled:useHideLayers_chb.state width:buttonWidth
		
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
		checkbox useHDRIMap_chb "Use HDRI Map"
		mapbutton hdriMap_btn hdriMapName tooltip:"Select Background Map" enabled:useHDRIMap_chb.state width:buttonWidth
		dotnetcontrol hdriMapLink_lbl "Label" text:hdriMapLinkStatus height:20 align:#center  width:buttonWidth
		checkbutton hdriMapLink_btn "Link Map to Sun" align:#center enabled:useHDRIMap_chb.state width:buttonWidth
		checkbutton hdriMapEdit_btn "Edit in MEdit" align:#center enabled:useHDRIMap_chb.state width:buttonWidth
		spinner hdriMapOffset_sp "U Offsets:"  type:#integer range:[0,360.0,0] enabled:useHDRIMap_chb.state
		spinner hdriMapGIMult_sp   "    GI mult:"  type:#float range:[-1000000,1000000,1] enabled:useHDRIMap_chb.state
		spinner hdriMapReflMult_sp "Ref_L mult:"  type:#float range:[-1000000,1000000,1] enabled:useHDRIMap_chb.state
		spinner hdriMapRefrMult_sp "Ref_R mult:"  type:#float range:[-1000000,1000000,1] enabled:useHDRIMap_chb.state
		
		
		on hdriMap_ro open do
		(
			hdriMapLink_lbl.TextAlign = (dotnetclass "System.Drawing.ContentAlignment").MiddleCenter
			checkHDRIconnection()
		)
		
		on hdriMapOffset_sp changed n do
		(
			if (hdriMap_btn.map != undefined and hdriMap_btn.map.cropplace_u.controller != undefined) then
			(
				hdriMap_btn.map.cropplace_u.controller.update()
			)
			else
			(
				MessageBox ("HDRI Map not linked to sun or no HDRI map defined")
				hdriMapOffset_sp.value = 0
			)
		)
	)
	
	rollout resolution_ro "Resolution"
	(	
		checkbox useHeightWidth_chb "Use Custom Size"
		spinner imgWidth_sp "  Width: " type:#integer range:[1,1000000,1920] enabled:useHeightWidth_chb.state 
		spinner imgHeight_sp "Height: " type:#integer range:[1,1000000,1080] enabled:useHeightWidth_chb.state 
		button getImgFrame_btn "Get Resolution" enabled:useHeightWidth_chb.state width:buttonWidth
		
		on useHeightWidth_chb changed state do 
		(
			imgWidth_sp.enabled = state
			imgHeight_sp.enabled = state
			getImgFrame_btn.enabled = state
		)
		
 		on getImgFrame_btn pressed do
		(
			local vrayRend = checkRenderer()
			if vrayRend != undefined then
			(
				if (vrayRend.output_getsetsfrommax == false) then
				(
					imgWidth_sp.value = vrayRend.output_width
					imgHeight_sp.value = vrayRend.output_height
				)
				else
				(
					imgWidth_sp.value = renderWidth
					imgHeight_sp.value = renderHeight
				)
			)
			else 
			(
				MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
			)
		) 
	)
		
	rollout import_ro "Import from Old"
	(
		button importFromOld_bn "Import from Old" width:buttonWidth
		
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
		label version_lbl "v 0.909"
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
		if (multiCamUsable == true) then
		(
			if (hdriMap_btn != undefined and hdriMap_btn.cropplace_u.controller != undefined) then
			(
				m = hdriMap_btn
				if (refs.dependentNodes ((m.cropplace_u.controller.Gettarget "t_x_pos").parent)).count < 2 then
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
							hdriMapOffset_sp.controller = Bezier_Float()
							
							m.cropplace_on = true
							m.cropplace_u.controller.AddTarget "t_x_pos" sun.pos.controller.'X Position'.controller
							m.cropplace_u.controller.AddTarget "t_y_pos" sun.pos.controller.'Y Position'.controller
							m.cropplace_u.controller.AddTarget "s_x_pos" sunTarget.pos.controller.'X Position'.controller
							m.cropplace_u.controller.AddTarget "s_y_pos" sunTarget.pos.controller.'Y Position'.controller
							--We use addNode because of circular dependency
							--Needs testing $ may not work
							m.cropplace_u.controller.addNode "offset" (refs.dependentNodes this)[1] --$
							
							--issue: when copy and pasted the link will be broken
							scriptstring =  "(mod ((atan2 (t_y_pos-s_y_pos) (s_x_pos-t_x_pos)) + offset.modifiers[#Submitter_Attributes].'hdriMapOffset_sp') 360 )/360.0"
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
		result = for i=1 to this.modifiers.count where (classof this.modifiers[i] == SubmitterAttributes) collect i
		print result.count
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
		
	on deleted  do
	(
		unregisterRedrawViewsCallback gwDisplay
	)

	on detachedFromNode this do
	(	
		for i=1 to 24 do
		(
			if (getmeditmaterial i == hdriMap_btn) then
			(
				setmeditmaterial i (standard())
			)
		)
		
		unregisterRedrawViewsCallback gwDisplay
	)
)