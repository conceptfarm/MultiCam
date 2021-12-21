-------------------------------------------------------------------------------
-- MultiCamSubmitter_906.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2018
-- Submits jobs to Deadline
-- Requires: Deadline functions and Attribute
-------------------------------------------------------------------------------

--to do:
--	split camera option
--  Add checking for deadline installation
--  add checking for ffmpeg 

--  Strange bug with create camera from view when submitter and lister are open, something about passing Scene Explorer as a variable
--  probably something to do with layer hidding in the attribute

--  Reset vray frame buffer to old res
--  Reset region to old region
--  Very large resolution settings
--  Look at different systemTools options for screen scaling
--  systemScale = (sysInfo.DesktopSizeUnscaled)/(sysInfo.desktopSize)
--  systemScale = (systemTools.GetScreenWidth applyUIScaling:false) / (systemTools.GetScreenWidth applyUIScaling:true)




--ver.902
----------------------------------------------------
-- Esc. to cancel preview 
-- Esc. to cancel submission (needs testing)
-- ffmpeg camera parameters and frame numbers
-- consolidate all submission functions into one FA and SA functions with case for types
-- Submission resolution is now 1/10th for max resolution and vray resolution is always used
-- Parent cancel dialog to the submitter window so that it always stays on top of it

--  Bugs:
--	Esc. to cancel for submission
--  check if ffmpeg exists before preview
--  check if ffmpeg exists in deadline, somehow access plugin paths and check those?
--  escape/cancel dialog doesn't work
--  on open reset vp layout and convert to #layout_1, enable safe frame view
--  Cancel window doesn't disappear after submission when using checkboxes

--  Post submission bug:
--  After submission - max resolution doesn't return to previous - seems to work on close but not after submission
--  Error on selected camera submission
--  Error old animation doesn't set back when using single camera submission from drop down, works on checkbox and fully automatic
--  ^ Error appears after using the camera chooser dropdown
--  SetOldRPS function is the issue, vrayRend variable gets lost and no settings can be set after that function runs
--  getoldprs grabs settings before submission and restores them that why vfb gets the correct settings but since no changes can be made after setoldrps those settings stay
--  Turns out vray settings could be stored by making a *copy* of the renderers.current, when vrayRend variable get assigned back to rend.curr the settings from the previous submission get restored as well

--  Test at work:
--  Find out about shaded camera view for all video graphics options
--  check paths with special characters, works in 2016 , check in 2018

--  DR Issues:
--  when using DR need to create a new identical camera and delete attribute holder modifier 
--  need to find out if prerender callback fires before DR assets are transfered - can only test with a dr machine at work




--ver.901
----------------------------------------------------
-- Sunpoints are no longer stored as helpers but rather in submitter attribute
-- Move sun to sunpoint function needs rewritting
-- cameras are passed as strings as opposed to objects, needs to be fixed

--ver.900
----------------------------------------------------
-- Removing dependency on framerange.txt
-- Integrating submitter attributes per camera
-- HDRI per camera

--ver.879
----------------------------------------------------
-- Attempt to submit DR jobs to Deadline, still in progress
-- Issues with copying vrayconfig file to userprofile
-- Prerender script needs work

--ver.878
----------------------------------------------------
-- 4K screen support for preview functions

--ver.877
----------------------------------------------------
-- Brute force with spheres now hides all geometry but spheres
-- Strict enforcement of sphere mask to jpg format, less space 
-- Deadline 10

--ver.876
----------------------------------------------------
-- Hide everything but geometry for preview
-- Don't do sanity check

--ver.875
----------------------------------------------------
-- Removed Dirty Pass GI, replaced with AS IS setting

--ver.874
----------------------------------------------------
-- Removed Quicktime submission, replaced with ffmpeg

--ver.873
----------------------------------------------------
-- Added override frame range txt
-- Removed avid mov option from preview

--ver.872
----------------------------------------------------
-- Preview functions now test for codecs

--ver.871
----------------------------------------------------
-- New mov/avi compression using ffmpeg

--ver.870
----------------------------------------------------
-- New Deadline 8 submission function integration

--ver.868
----------------------------------------------------
-- New Folder structure revision
-- Preview with single frame fix

--ver.867
----------------------------------------------------
-- Layer handling function revision
-- defaultVFB() disables VFB colour correction

--ver.866
----------------------------------------------------
-- Deadline version 8

--ver.865
----------------------------------------------------
-- Fixed get res from max bug

--ver.86
----------------------------------------------------
-- Fixed preview bug , wrong scaling/cropping

--ver.85.5
----------------------------------------------------
-- Fixed preview bug when framerange.txt exists but no camera entry
-- Added submission groups "frames" + "irmap"
-- Changed tempPreset file location to system temp folder

--ver.85
----------------------------------------------------
-- Fixed preview dib copy pasteBitmap bug

--ver.84
----------------------------------------------------
-- Fixed preview SA function not to ask to explore C; after every camera

--ver.83
----------------------------------------------------
-- Fixed Nth frame bug, only used to apply to IR Submission

--ver.82
----------------------------------------------------
-- Fixed callback bug (not removing copyJpg callback between cam submissions)s

--ver.81
----------------------------------------------------
-- exr + jpg option for render extension now works
-- Latest using vbfsave , same as exr -> jpg, only saves last rendered frame
-- When choosing compress to mov, jpg conversion will happen regardless of ext
-- When render is a single frame disable mov compression, needs testing
-- fixed single frame submission bug
-- rpsindex fix
-- task time out for QT job
-- Fixed dot in exr frame names

--ver.80
----------------------------------------------------
-- exr + jpg option for render extension
-- single image mix bug fixed

--ver.79
----------------------------------------------------
-- jpg support added
-- rewrite latest image function, now max opens the image files and saves it, no external xcopy command
-- frame nth frame added
-- set/get rps preset rework, no need for vray versions, needs testing
-- single image mixed with frame range bug in parsing FrameRange.txt needs fixing

--ver.78
----------------------------------------------------
--Latest folder option is now using an xcopy callback script
--Integrate Deadline7 batch 

--ver.77
----------------------------------------------------
--Camera list bug fixes
--Region render warning on opening the script
--Latest folder option
--Fix Suspension bug

--ver.76
----------------------------------------------------
--Region Render deadline bug fix

--ver.75
----------------------------------------------------
--Custom attributes to store scene default data

--ver.74
----------------------------------------------------
--Added:
--Sphere render added
--Set save requirement
--Added mov exporter using QT local deadline cmd

--ver.73
----------------------------------------------------
--Added:
--Output Root chooser
--Took out the extra rollout now just a single dialogue
--Need to do update fn for frameout

--ver.72
----------------------------------------------------
--Added:
--Deadline Submitter

--ver.71
----------------------------------------------------
--Added:
--nra submitter 

--ver.70G
----------------------------------------------------
-- Added:
-- Animated Brute Force Button
-- New Set old get old using temp preset file

--ver.70F
----------------------------------------------------
--Added
-- Full Auto Animation Pass
-- Preview Button bug fixed
-- Fixed setting not going back to old settings after submission of Ani frames

--ver.70
----------------------------------------------------
--Done needs testing:
--	Vray buffer no matter what
--	sequential submittion
--	use new file parsing option instead of filterstring option
--  layers option added, listed layers will be hidden
--  fixed layer bug
--  fixed single frame submission

--ver.68
----------------------------------------------------
--submitting without framerange.txt will default to single frame of the current time
--preview buttons interaction remaped to prevent user errors

--ver.67
----------------------------------------------------
--callback option for automated unsuspension of frames jobs

--ver.66
----------------------------------------------------
--fixed leading zero problem in preview
--localtime fixed
--connection is automatic

--ver.65
----------------------------------------------------
--to do:
--split camera option
--integrate camera setup
--preview camera option to be refined with custom frame size
--file "localtime" bug by using getlocaltime instead
--use new file parsing option instead of filterstring option

--Connection is faster since there is no need to get q control
--zdepth exr should work for mult entries

--ver.64
----------------------------------------------------
--no save replaced with job.name ="" function instead
--to do: make z-depth as exr work for mult entries
--		ignore sunpoints
--old setting 


--ver.63
----------------------------------------------------
-- new interface
--v3 has custom frame format
--v3 camera selection dropdown added "no camera"
--v4 cleaned up code

--ver.62
----------------------------------------------------
--enabled and disabled button options to minimize user error

--ver.61
----------------------------------------------------
--sorted cameras in the dropdown
--extention selection

--ver.6
----------------------------------------------------
--added new interface and usage section
--clear now clears all render paths

--ver.53
----------------------------------------------------
--added single cam function

--ver.52 
----------------------------------------------------
--added NoGI button for Sky and Z-depth passes
--tested ver.51 with Tunis project - it works
--FrameRange.txt warning box added
--Connection status works

--ver.51
----------------------------------------------------
--implementing pass type into folder structure
--moved srv_list to top function
--moved frameout to top


macroScript MultiCamSubmitter
category:"ilya_s Scripts"
tooltip:"v.906.00"
buttontext:"v.906.00"
Icon:#("MultiCamSq",2)
(
	global SMTDSettings
	global SMTDFunctions
	global SMTDPaths
	global DeadlineSlaves	
	global multiCamSubmitter
	global camChecklistRO
	global cancelProcessRO
	global SubmitterNodeEventCallback
	
	local vrayRend = undefined
	local vrayRendPreSubmission = undefined
	local updateMultiCamSubmitterRollout = false
	local begframe = 0
	local endframe = 1
	local sceneCams = #()
	local vraySuns = #()
	local sceneCamsNames = #()
	local currentCameraName = undefined
	local currentCamera = undefined
	local SingleFrame = false
	local OverrideSingleFrame = false
	local disableVFB = false
	--local z_var = false --whether or not to repath Zdepth as exr
	local extensions = #(".tga", ".exr", ".exr", ".exr",".jpg")
	local extensionsList = #(".tga", ".exr", ".exr + .jpg", ".exr (split)", ".jpg")
	local zdeptharray = #()
	local view_size = [1920,1080] 
	local projectName = "Project Noname"
	local outputPaths = #("X:\\ProjectName\\07_Production\\02_RawImageRender\\", "Z:\\Project\\01_Frames\\", "Z:\\Project\\03_Previews\\", "Custom")
	
	local oldRenderRes = #()
	local oldHideLayers = #()
	local oldNonRenderLayers = #()
	local oldAnimationSettings = #()
	local oldRenderTimeType = rendTimeType
	local oldRenderNthFrame = rendNThFrame
	local oldEnvSettings = #()
	local oldHideCats = #()
	local oldViewportLayout = undefined
	local oldRenderRegion = #()
	local as_is_diag_settings = undefined
	
	
	local utvideoDir = @"C:\Program Files\utvideo\unins000.exe"
	local avidDir = @"C:\Program Files (x86)\QuickTime\QTComponents\AvidAVdnCodec.qtx"
	local FFmpegExe = ""
	local UnixDeadlineRoot = "" 
	local OCIOconfig = "Y:\\Resources\\23_OCIO\\aces_1.2\\config.ocio"

	--########################--	
	--GENERAL FUNCTIONS
	--########################--

	fn getMaxVer = (return ("20" + (((substring ((maxVersion())[1] as string) 1 2) as integer) - 2) as string))

	--List is a string of comma separated entries
	
	fn checkWindowsLegalPath str =
	(
		--https://docs.microsoft.com/en-gb/windows/win32/fileio/naming-a-file
		--not allowed as part of name < > : " / \ ' | ? * .  
		--not allowed as name CON, PRN, AUX, NUL, COM1, COM2, COM3, COM4, COM5, COM6, COM7, COM8, COM9, LPT1, LPT2, LPT3, LPT4, LPT5, LPT6, LPT7, LPT8, LPT9
		--not allowed space at beginning or end
		
		local result = undefined
		local legalCharsSet = "1234567890-=!@#$%^&*()_+[]{}ABCDEFGHIJKLMNOPQRSTUVWXYZ "
		local illegalCharsSet = #("<",">",":","\"","/","\\","'","|",".") -- can use with matchpattern
		local illegalCharsSet2 = #("?","*") --reserved chars for matchpattern need to use findstring instead
		local illegalNameSet = #("CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9")
		
		for i=1 to str.count while result == undefined do
		(
			if ((matchpattern legalCharsSet pattern:("*"+str[i]+"*") caseSensitive:false) == false) then (result = #(str,("bad character " + (substring str 1 (i-1)) + "<bad>" + (substring str (i+1) -1))))
		)
			
		for char in illegalCharsSet while result == undefined do
		(
			if ((matchpattern str pattern:("*"+char+"*")) == true) then (result = #(str,("illegal character " + char)))
		)
		
		for char in illegalCharsSet2 while result == undefined do
		(
			if ((findstring str char) != undefined) then (result = #(str,("illegal character " + char)))
		)
		
		for n in illegalNameSet while result == undefined do
		(
			if (toUpper str == n) then (result = #(str,("illegal name " + n)))
		)

		if (str[1] == " ") then (result = #(str,"space at beginning"))
		if (str[str.count] == " ") then (result = #(str,"space at end"))
				
		result
	)

	fn setBitmapIOClasses = 
	(
		targa.itgaio.setColorDepth 32
		targa.itgaio.setCompressed true
		targa.itgaio.setAlphaSplit false
		targa.itgaio.setPreMultAlpha true
		targa.itgaio.setAuthor "Cicada Design Inc."

		--TODO: exr settings here--
		--needs testing for best settings--
		--http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_FDECDBDE_C741_4CD8_9DE4_F3355490C796_htm
		
		--fopenexr.setLayerOutputFormat 0 0 -- set Main Render to 0: FLOAT32  1: FLOAT16
		--fopenexr.setLayerOutputType 0 0 -- set Main Render to RGBA
		--fopenexr.setSaveRegion false -- save full image
		--fopenexr.setSaveScanline true -- save as scanline 
		--fopenexr.SetCompression 2 -- 2:single line , 3:line 16 
	)


	fn getDrServers = 
	(
		local drServers = ""
		local drSettings = #("restart_slaves","list_in_scene","max_servers","use_local_machine","transfer_missing_assets","use_cached_assets","cache_limit_type","cache_limit","render_region_warning")
		local drFile = openFile (getdir (#plugcfg) + "\\vray_dr.cfg")

		if drFile != undefined then
		(
			seek drFile 0
			try while not eof drFile do 
			(
				--print "Parsing vray_dr.cfg"
				parsedLine = readline drFile
				filterLine = filterString parsedLine " "
				if ((filterLine[2] == "1") and (findItem drSettings filterLine[1]) == 0) then
				(
					drServers = drServers + "," + filterLine[1] 
				)
			)
			catch
			(
				print "end of vray_dr.cfg"
			)
			
			close drFile
			free drFile
		)
		else (print "Distributed Settings file does not exist")
		return (substring drServers 2 drServers.count)
	)
		
	fn compareByObjectName v1 v2 =
	(
		local d = (v1.name < v2.name)
		case of
		(
			(d == true ): -1
			(d == false ): 1
			default: 0
		)
	)
	
	fn padNumber nr padLen = (local n = (nr as string)	for x = 1 to (padLen - n.count) do n = "0" + n 	return n)
		
	fn useToday =
	(	
		local todayDate = ""
		local timenow = getlocaltime()
		todayDate = timenow[1] as string + "_" + (padnumber timenow[2] 2) as string + "_" + (padnumber timenow[4] 2) as string
		return todayDate
	)
	
	fn getProjectName = 
	(
		local result = "Project Noname"
		if (maxfilepath != "" and  (filterstring maxfilepath "\\")[1] == "X:") then
		(
			result = (filterstring maxfilepath "\\")[2]
		)
		
		return result
	)

	fn getCamFocalLength cam =
	(
		local result = 
		case (classof cam) of 
		(
			VRayPhysicalCamera: (cam.focal_length) as integer
			Targetcamera: (cameraFOV.FOVtoMM cam.curFOV) as integer
			Freecamera: (cameraFOV.FOVtoMM cam.curFOV) as integer
			Physical: (cam.focal_length_mm) as integer
			default:0
		)
		result
	)
	
	fn IFLwriter f =
	(
		for i = begframe to endframe do
		(
			camstring = currentCameraName + "_.SphereMask_." + (padNumber i 4) as string + ".tga" + "\n"
			format camstring to: f
		)
		close f
	)
			
	fn defaultVFB = 
	(
		if vrayRend.options_rgbColorSpace == 2 and OCIOconfig != undefined and doesFileExist OCIOconfig then 
		(
			vfbControl #ocio true -- possible issue in the future with OCIOconfig
		)
		else
		(
			vfbControl #srgb true -- possible issue in the future with OCIOconfig
		)
		vfbControl #trackmouse false
		vfbControl #clamp true
		vfbControl #info false
		vfbControl #exposure false
		vfbControl #whitebalance false
		vfbControl #huesat false
		vfbControl #colorbalance false
		vfbControl #levels false
		vfbControl #curve false
		vfbControl #bkgr false	
		vfbcontrol #testresolution false	
	)


	-- Doesn't really work well
	/*
	global renderParamsFN
	fn renderParamsFN = 
	(
		print ("Dialog is open = " + renderSceneDialog.isOpen() as string )
		MessageBox ("Changing render parameters with Submitter open will screw things up - closing Submitter window.")
		destroydialog multiCamSubmitter
	)
	*/
		
	fn AddCallbackLatest denoise:true =
	(
		makedir (rootnode.CA_frameOutput + "Latest")
			
		local outputFile = ""
		
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then
		(
			outputFile = vrayRend.output_rawfilename
		)
		else 
		(
			outputFile = vrayRend.output_splitfilename
		)
		
		--outFileRGB = getFilenamePath outputFile + getFilenameFile outputFile + ".jpg"
		outFileRGB = rootnode.CA_frameOutput +"Latest" + "\\" + getFilenameFile outputFile + ".jpg"
		print ("latest2 callback dir " + outFileRGB)
		tempFile = (getDir #downloads)+ "\\Temp_.jpg"					
		
		local setChannel = ""
		if not denoise then (setChannel = "vfbControl #setchannel 0;")
		
		a = "vfbControl #srgb true;"+setChannel+"vfbControl #rgb true; vfbControl #saveimage ((sysInfo.tempdir ) + \"" + "Temp_.jpg" +"\"); tempb = openBitMap ((sysInfo.tempdir ) + \"" + "Temp_.jpg" +"\"); newtemp = copy tempb; newtemp.filename = \"" + outFileRGB +"\"; save newtemp  frame:slidertime quiet:true; close tempb; close newtemp; free tempb; free newtemp; deleteFile ((sysInfo.tempdir ) +  \"" + "Temp_.jpg" +"\")"
		--a = "vfbControl #srgb true; vfbControl #setchannel 0; vfbControl #rgb true; vfbControl #saveimage \"" + tempFile +"\"; tempb = openBitMap \"" + tempFile +"\"; newtemp = copy tempb; newtemp.filename = \"" + outFileRGB +"\"; save newtemp  frame:slidertime quiet:true; close tempb; close newtemp; free tempb; free newtemp; deleteFile  \"" + tempFile +"\""
		callbacks.addscript #postRender a persistent:true id:#copyLatest_callback
	)
	
	fn AddCallbackJPG denoise:true =
	(
		local outputFile = ""
		
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then
		(
			outputFile = vrayRend.output_rawfilename
		)
		else 
		(
			outputFile = vrayRend.output_splitfilename
		)
		
		outFileRGB = getFilenamePath outputFile + getFilenameFile outputFile + "..jpg" --the extra dot is for dot-delimited frame number for exr
		
		tempFile = (getDir #downloads)+ "\\Temp_.jpg"					
		
		local setChannel = ""
		if not denoise then (setChannel = "vfbControl #setchannel 0;")
		local setDisplay = "vfbControl #srgb true;"
		if vrayRend.options_rgbColorSpace == 2 and OCIOconfig != undefined and doesFileExist OCIOconfig then 
		(
			setDisplay = "vfbControl #ocio true; vfbControl #loadocio \""+ OCIOconfig+"\"; vfbControl #ocioinputcolorspace \"ACES - ACEScg\"; vfbControl #ociodisplaydevice \"ACES\"; vfbControl #ocioviewtransform \"sRGB\" "
		)
		
		--a = "vfbControl #srgb true; vfbControl #setchannel 0; vfbControl #rgb true; vfbControl #saveimage \"" + tempFile +"\"; tempb = openBitMap \"" + tempFile +"\"; newtemp = copy tempb; newtemp.filename = \"" + outFileRGB +"\"; save newtemp  frame:slidertime quiet:true; close tempb; close newtemp; free tempb; free newtemp; deleteFile  \"" + tempFile +"\""
		a = setDisplay+setChannel+"vfbControl #rgb true; vfbControl #saveimage ((sysInfo.tempdir) + \"" \
		+ "Temp_.jpg" +"\"); tempb = openBitMap ((sysInfo.tempdir ) + \"" + "Temp_.jpg" +"\"); newtemp = copy tempb; newtemp.filename = \"" \
		+ outFileRGB +"\"; save newtemp  frame:slidertime quiet:true; close tempb; close newtemp; free tempb; free newtemp; deleteFile ((sysInfo.tempdir ) +  \"" \
		+ "Temp_.jpg" +"\")"
		callbacks.addscript #postRenderFrame a persistent:true id:#copyJPG_callback
	)

	-- this should be a rollout update function, update dropdown and updata LV_ITEMS, triggers when the submitter is open and user changes the name of the camera or adds or subtracts one.
	fn SubmitterNodeEventFN ev nd = 
	(
		print "--submitter callbacksEnd function--"
		if updateMultiCamSubmitterRollout == true then
		(
			try(destroydialog multiCamSubmitter;destroydialog camChecklistRO )catch()
			macros.run "ilya_s Scripts" "MultiCamSubmitter"
			--createdialog multiCamSubmitter
		)
		updateMultiCamSubmitterRollout = false
	)
	
	fn SubmitterNodeEventSetUpdate ev nd =
	(
		print "--submitter callback added function--"
		updateMultiCamSubmitterRollout = true
	)

	fn gwActiveSettings =
	(
		rect = (box2 13 47 96 97)
		eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
		eRect.right += 1
		eRect.bottom += 1
		local displayText = ("Submitter is OPEN!\nChanges made to Environment, Frame Range or Resolution will not be stored.")
		local ext = gw.getTextExtent displayText
		gw.wtext [rect.left + 15 ,rect.top+20,0] displayText color:white
		gw.wrect (box2 (rect.left + 15 ) (rect.top+25+ ext.y/2) ext.x 5) red
		gw.enlargeUpdateRect eRect
		gw.updateScreen()

		--if ((refs.dependentNodes this).count  == 0) then
		--(
		--	unregisterRedrawViewsCallback gwActiveSettings
		--)
	)
	
	
	------------------------------------
	--Layer Fuctions
	------------------------------------
	
	fn layersHideAll = ( for i = 0 to (LayerManager.count - 1) do (b = LayerManager.getLayer i; b.on = false ))

	fn layersShowAll = ( for i = 0 to (LayerManager.count - 1) do (b = LayerManager.getLayer i; b.on = true ))
		
	fn getHiddenLayers =
	(
		local result = #()
		local n = LayerManager.count
		for i = 0 to n-1  do
		(
			if (layermanager.getlayer i).on == false then
			(
				appendifunique result (layermanager.getlayer i).name
			)
		)
		result
	)
	
	fn getNonRenderLayers =
	(
		local result = #()
		local n = LayerManager.count
		for i = 0 to n-1  do
		(
			if (layermanager.getlayer i).renderable == false then
			(
				appendifunique result (layermanager.getlayer i).name
			)
		)
		result
	)
	
	fn setHiddenLayers arr =
	(
		for i = 0 to (LayerManager.count - 1 ) do 
		(
			local thisLayerName = (layermanager.getlayer i).name
			if ((findItem arr thisLayerName) != 0) then
			(
				layer = layerManager.getLayer i
				layer.on = false
				layer.renderable = false
				print ("Hiding layer: " + thisLayerName)
			)
			else 
			(
				layer = layerManager.getLayer i
				layer.on = true
				layer.renderable = true
			)
		)
	)
	
	fn setNonRenderLayers arr =
	(
		for i = 0 to (LayerManager.count - 1 ) do 
		(
			local thisLayerName = (layermanager.getlayer i).name
			if ((findItem arr thisLayerName) != 0) then
			(
				layer = layerManager.getLayer i
				layer.renderable = false
				print ("NonRender layer: " + thisLayerName)
			)
			else 
			(
				layer = layerManager.getLayer i
				layer.renderable = true
			)
		)
	)
	
	-------------------------------------------
	--Get and Set Old Settings Functions
	-------------------------------------------
	
	fn getAnimation = 
	(
		print ("getting animation " + #(rendTimeType,rendNThFrame,animationRange) as string)
		return #(rendTimeType,rendNThFrame,animationRange)
	)
	
	fn setAnimation arr = 
	(
		print ("setting animation " + arr as string)
		rendTimeType = arr[1]
		rendNThFrame = arr[2]
		animationRange = arr[3]
		print animationRange
	)
	
	fn getOldRPS = 
	(
     	vrayRendPreSubmission = copy vrayRend
		oldRenderTimeType = rendTimeType
		oldRenderNthFrame = rendNThFrame	
	)
	
	fn setOldRPS = 
	(
     	
		renderers.current = vrayRendPreSubmission
     	vrayRend = renderers.current
		rendTimeType = oldRenderTimeType
		rendNThFrame = oldRenderNthFrame
 	)

 	fn disableVrayLog =
 	(
 		vrayrend.system_vrayLog_show = 0
		vrayrend.system_vrayLog_level = 1
		vrayrend.system_vrayLog_file = ""
 	)
	
	fn hideCatsForPreview = 
	(
		hideByCategory.geometry = false
		hideByCategory.shapes =  true
		hideByCategory.lights = true
		hideByCategory.cameras = true
		local animaHelpers = for o in objects where classof o == animaScene collect o
		if animaHelpers.count > 0 then
		(
			hideByCategory.helpers = false
		)
		else
		(
			hideByCategory.helpers = true
		)
		hideByCategory.spacewarps = true
		hideByCategory.particles = true
		hideByCategory.bones = true
	)
	
	fn getOldHideCats = 
	(
		oldHideCats[1] = hideByCategory.geometry 
		oldHideCats[2] = hideByCategory.shapes 
		oldHideCats[3] = hideByCategory.lights 
		oldHideCats[4] = hideByCategory.cameras 
		oldHideCats[5] = hideByCategory.helpers
		oldHideCats[6] = hideByCategory.spacewarps 
		oldHideCats[7] = hideByCategory.particles 
		oldHideCats[8] = hideByCategory.bones	
		
		hideCatsForPreview()
	)
	
	fn setOldHideCats = 
	(
		hideByCategory.geometry = oldHideCats[1] 
		hideByCategory.shapes =  oldHideCats[2] 
		hideByCategory.lights = oldHideCats[3]
		hideByCategory.cameras = oldHideCats[4]
		hideByCategory.helpers = oldHideCats[5] 
		hideByCategory.spacewarps = oldHideCats[6]
		hideByCategory.particles = oldHideCats[7]
		hideByCategory.bones = oldHideCats[8]
	)
	
	fn getRenderResolution = 
	(
		-- max w, max h, vrayRes bol, vray w, vray h
		result = #()
		
		result[1] = renderWidth
		result[2] = renderHeight
		result[3] = vrayRend.output_getsetsfrommax
		result[4] = vrayRend.output_width
		result[5] = vrayRend.output_height

		return result
	)
	

	fn setRenderResolution arr submission:false= 
	(
		if renderSceneDialog.isOpen() then renderSceneDialog.close()

		if arr.count < 3 then
		(
			arr[3] = false
			arr[4] = arr[1]
			arr[5] = arr[2]
		)
		
		renderWidth = arr[1]
		renderHeight = arr[2]
		vrayRend.output_getsetsfrommax = arr[3]
		vrayRend.output_width = arr[4]
		vrayRend.output_height = arr[5]
		
		if submission == true then
		(
			print "submission true"
			if arr[3] == true then 
			(
				vrayRend.output_getsetsfrommax = false
				vrayRend.output_width = arr[1]
				vrayRend.output_height = arr[2]
				renderWidth = arr[1]/10
				renderHeight = arr[2]/10
			)
			else
			(
				vrayRend.output_getsetsfrommax = false
				vrayRend.output_width = arr[4]
				vrayRend.output_height = arr[5]
				renderWidth = arr[4]/10
				renderHeight = arr[5]/10
			)
		)
	)
	
	fn setEnvSettings arr = 
	(
		environmentMap = arr[1]
		useEnvironmentMap = arr[2]
		
		vrayRend.environment_gi_on = arr[3]
		vrayRend.environment_gi_color_multiplier = arr[4]
		vrayRend.environment_gi_map = arr[5]
		vrayRend.environment_gi_map_on = arr[6]
		
		vrayRend.environment_rr_on = arr[7]
		vrayRend.environment_rr_color_multiplier = arr[8]
		vrayRend.environment_rr_map = arr[9]
		vrayRend.environment_rr_map_on = arr[10]
  
		vrayRend.environment_refract_on = arr[11]
		vrayRend.environment_refract_color_multiplier = arr[12]
		vrayRend.environment_refract_map = arr[13]
		vrayRend.environment_refract_map_on = arr[14]
	)
	
	fn getEnvSettings = 
	(
		local arr = #()
		
		arr[1] = environmentMap
		arr[2] = useEnvironmentMap 
		
		arr[3] = vrayRend.environment_gi_on
		arr[4] = vrayRend.environment_gi_color_multiplier
		arr[5] = vrayRend.environment_gi_map
		arr[6] = vrayRend.environment_gi_map_on
		
		arr[7] = vrayRend.environment_rr_on
		arr[8] = vrayRend.environment_rr_color_multiplier
		arr[9] = vrayRend.environment_rr_map
		arr[10] = vrayRend.environment_rr_map_on
  
		arr[11] = vrayRend.environment_refract_on
		arr[12] = vrayRend.environment_refract_color_multiplier
		arr[13] = vrayRend.environment_refract_map
		arr[14] = vrayRend.environment_refract_map_on
		
		return arr
	)

	fn getOldEnvLayers = 
	(
		oldRenderRes = getRenderResolution()
		oldHideLayers = getHiddenLayers()
		oldNonRenderLayers = getNonRenderLayers()
		oldEnvSettings = getEnvSettings()
		print ("Old resolution is " + oldRenderRes as string)
		print ("Old environmet is " + oldEnvSettings as string)
	)

	fn setOldEnvLayers = 
	(

	)
	fn resetViewports = 
	(
		disableSceneRedraw()
		local layout = viewport.getLayout()
		local activeViewportType = undefined
		local activeViewportCamera = undefined
		local activeViewportTm = undefined 
		local activeViewportRegion = undefined 
		
		if layout == #layout_1 then
		(
			activeViewportType = viewport.getType()
			activeViewportCamera = getActiveCamera()
			activeViewportTm = viewport.getTM()
			activeViewportRegion = viewport.getRegionRect viewport.activeViewport
			
			viewport.ResetAllViews()
			try(viewport.activeViewport = 4)catch("Viewport out of index range")
			max tool maximize
			
			if activeViewportType == #view_camera then viewport.setCamera activeViewportCamera
			else if activeViewportType == #view_persp_user then viewport.setTM activeViewportTm
			
			viewport.setRegionRect viewport.activeViewport activeViewportRegion
			
		)
		else
		(
			if viewport.getType() != #view_camera then
			(
				local viewportIndex = 0
				for i = 1 to viewport.numViews do
				(
					case (viewport.getType index:i) of
					(
						#view_camera: (
							print "found cam"
							viewportIndex = i
							activeViewportType = viewport.getType index:i
							activeViewportCamera = viewport.getCamera index:i
							activeViewportRegion = viewport.getRegionRect i
							exit
							)
						#view_persp_user: (
							viewportIndex = i
							activeViewportType = viewport.getType index:i
							viewport.activeViewport = i
							activeViewportTm = viewport.getTM()
							activeViewportRegion = viewport.getRegionRect i
							)
					)			
				)
				
				viewport.ResetAllViews()
				try(viewport.activeViewport = 4)catch("Viewport out of index range")
				max tool maximize

				if viewportIndex > 0 then 
				(
						if (activeViewportType == #view_camera) then (viewport.setCamera activeViewportCamera)
						else if (activeViewportType == #view_persp_user) then (viewport.setTM activeViewportTm)
				)
				
				viewport.setRegionRect viewport.activeViewport activeViewportRegion
			)
			else
			(
				activeViewportCamera = getActiveCamera()
				activeViewportRegion = viewport.getRegionRect viewport.activeViewport
				viewport.ResetAllViews()
				try(viewport.activeViewport = 4)catch("Viewport out of index range")
				max tool maximize
				viewport.setCamera activeViewportCamera
				
				viewport.setRegionRect viewport.activeViewport activeViewportRegion
			)
			
		)
		if ( (matchpattern (gw.getDriverString()) pattern:"Direct3d*") == true) then actionMan.executeAction -844228238 "7"
		else (actionMan.executeAction 0 "550")  -- Views: Viewport Visual Style Shaded
		enableSceneRedraw() 
	)


	------------------------------------
	--UI Functions
	------------------------------------
	fn setUIElementEnabled state strPattern =
	(
		for c in MultiCamSubmitter.controls where (matchpattern c.name pattern:strPattern) == true do c.enabled = state
	)

	------------------------------------
	-- Region Render Functions
	------------------------------------
	-- Issues with region rendering
	-- Each viewport can have its own region coordinates 
	-- Not sure which deadline will pick up, probably best to convert to vray coordinates
	-- General issue with 3dsmax - sometimes decides to render non-active viewport
	-- Further issues max resolution can be different from vray resolution - that effects the coordinates of the region since they are absolute values of the final image resolution.
	-- Even bigger issue: setting vray region on  a window smaller than region clips the region, need to resize the window before setting the region 

	--vrayVFBGetRegion()
	--vrayVFBSetRegion 134 241 1920 617 --x1 y1 x2 y2


	--x,y,w,h
	--viewport.setRegionRect viewport.activeViewport (Box2 1000 638 910 333)
	--viewport.getRegionRect viewport.activeViewport --removeUIScaling: false

	-- test conflict in aspect ratios of max resolution and vray resolution
	-- test conflict in regions from max to vray 

	fn disableAllRenderRegions = 
	(
		local rs = renderSceneDialog.isopen()
		if renderSceneDialog.isOpen() then renderSceneDialog.close()
		try (vrayVFBSetRegionEnabled false) catch()
		setRenderType #view
		if rs == true then renderSceneDialog.open()
	)

	fn convertMaxRegionToVray =
	(
		local regionCoords = viewport.getRegionRect viewport.activeViewport
		setRenderType #view
		local widthScale = 1
		local heightScale = 1
		local _w = renderWidth
		local _h = renderHeight
		if vrayRend.output_getsetsfrommax == false then
		(
			_w = vrayRend.output_width
			_h = vrayRend.output_height
			widthScale = _w/renderWidth
			heightScale = _h/renderHeight
		)
		
		-- Workaround for setting the size of the vray frame buffer by loading the right size image into it.
		local vraySizeBitmap = bitmap _w _h color:black gamma:0.45454545 filename:((getdir #temp)+"\\vraySizeBitmap.jpg")
		save vraySizeBitmap
		close vraySizeBitmap
		vfbControl #hide
		vfbControl #loadimage vraySizeBitmap.filename
		
		vrayVFBSetRegionEnabled true
		vrayVFBSetRegion (regionCoords.x*widthScale) (regionCoords.y*heightScale) ((regionCoords.x+regionCoords.w)*widthScale) ((regionCoords.y+regionCoords.h)*heightScale)
		
		deletefile vraySizeBitmap.filename
		free vraySizeBitmap
		vfbControl #clearimage
	)

	fn convertVrayRegionToMax =
	(
		if vrayVFBGetRegionEnabled() == true then
		(
			--local regionAsRatio = convertRegionToRatio type:#vrayToVray
			local vrayReg = vrayVFBGetRegion()
			local ratio = #()
			local _x, _y, _w, _h
			if vrayRend.output_getSetsFromMax == false then
			( 
				_x = ((1.0*vrayReg[1])/vrayRend.output_width * renderWidth) as integer
				_y = ((1.0*vrayReg[2])/vrayRend.output_height * renderHeight) as integer
				_w = ((1.0*(vrayReg[3] - vrayReg[1]))/vrayRend.output_width * renderWidth) as integer
				_h = ((1.0*(vrayReg[4] - vrayReg[2]))/vrayRend.output_height * renderHeight) as integer

			)
			else 
			(
				_x = vrayReg[1]
				_y = vrayReg[2]
				_w = vrayReg[3] - vrayReg[1]
				_h = vrayReg[4] - vrayReg[2]
			)

			setRenderType #region
			vrayVFBSetRegionEnabled false
			viewport.setRegionRect viewport.activeViewport (Box2 _x _y _w _h)
		)
	)

	fn getOldRenderRegion = 
	(
		local result = #()
		if vrayVFBGetRegionEnabled() == true then
		(
			result = join #("vray") (vrayVFBGetRegion())
		)
		else if (getRenderType() != #view) then
		(
			local maxRegion = viewport.getRegionRect viewport.activeViewport
			result = #("max", maxRegion)
		)
		return result
	)

	fn setOldRenderRegion arr = 
	(
		print "setting old region"
		if arr[1]=="vray" then
		(
			print "rr is vray"
			setRenderType #view
			vrayVFBSetRegionEnabled true
			vrayVFBSetRegion arr[2] arr[3] arr[4] arr[5]
		)
		else if arr[1]=="max" then
		(
			print "rr is max"
			setRenderType #region
			vrayVFBSetRegionEnabled false
			viewport.setRegionRect viewport.activeViewport arr[2]
		)
	)

	fn setVFBSize arr setOldRegion: = 
	(
		-- expecting oldRenderRes #(640, 480, true, 640, 480)
		-- Workaround for setting the size of the vray frame buffer by loading the right size image into it.
		local _w, _h
		
		if arr[3] == true then
		(
			_w = arr[1]
			_h = arr[2]
		)
		else
		(
			_w = arr[4]
			_h = arr[5]
		)
		
		local vraySizeBitmap = bitmap _w _h color:black gamma:0.45454545 filename:((getdir #temp)+"\\vraySizeBitmap.jpg")
		save vraySizeBitmap
		close vraySizeBitmap
		vfbControl #hide
		vfbControl #clearimage -- clear image before loading the image, otherwise get the vray history error popup
		vfbControl #loadimage vraySizeBitmap.filename --error here
		deletefile vraySizeBitmap.filename
		free vraySizeBitmap
		vfbControl #clearimage
		
		if setOldRegion != unsupplied then setOldRenderRegion setOldRegion 
	)

	fn getVFBSize = 
	(
		local result = undefined
		local vbfWindowName = filterstring (tolower ((for wnd in (windows.getChildrenHWND 0) where ((matchpattern wnd[5] pattern:"V-Ray frame buffer*")) collect wnd)[1][5])) "abcdefghijklmnopqrstuvwxyz[] -"
		--returns #("25%", "2500", "2500")

		if ((vbfWindowName.count == 3) and (vbfWindowName[1][vbfWindowName[1].count] == "%") and (vbfWindowName[2] as integer) != undefined and (vbfWindowName[3] as integer) != undefined) then 
		(
			result = #(vbfWindowName[2] as integer,vbfWindowName[3] as integer)
		)
		return result
	)
	
	fn deadlineRegionRendering = 
	(
		--convert to vray region here, max region will be disabled but coordinates will still be readable.
		SMTDSettings.RegionRenderingMode = #none
		
		if (getRenderType() == #region or vrayVFBGetRegionEnabled() == true) then 
		(
			print "--region rendering enabled--"
			convertMaxRegionToVray()
		)
	)

	------------------------------------
	--Deadline Functions
	------------------------------------
	
	fn CollectDeadlineSlaves =
	(
		local st = timestamp()
		local tempArray = #("")
		local result = SMTDFunctions.waitForCommandToComplete ("-slaves " + SMTDSettings.CurrentRepository ) SMTDSettings.TimeoutCollectData
		
		if  result == #success then			
		(
			SMTDFunctions.ReadFileIntoArray SMTDPaths.SubmitOutput tempArray
			DeadlineSlaves = for i in tempArray where i != "" collect i
			--print DeadlineSlaves
		)
	)
	
	
	------------------------------------
	-- PARSE  Functions
	------------------------------------
	fn moveSunToPoint = 
	(		
		if ((isProperty currentCamera.baseObject "MultiCamAttributeData") == true) then
		(			
			local mcData = currentCamera.baseObject.MultiCamAttributeData
			if (mcData.useSunpoints_param == true and vraySuns.count == 1) then
			(
				--endSetRes #(m.imgWidth_sp, m.imgHeight_sp)
				vraySuns[1].pos = mcData.sP_val
				vraySuns[1].target.pos = mcData.sT_val
			)
			else if (mcData.useSunpoints_param == true and vraySuns.count == 0) then
			(
				MessageBox ("No VRay Sun in the scene found but Use Sunpoints in ON. Either uncheck Use Sunpoints or create a VRay Sun.") title:"Minor Error" beep:false
			)
		)
	)
	
	fn parseRangeFile c =
	(
		if (EditRenderRegion.IsEditing == true) do (EditRenderRegion.EditRegion() )
		begframe = endframe = undefined
		
		--local allMods = for m in c.modifiers where (classof m == MultiCamAttribute) collect m
		--print("allmods count is: " + allmods.count as string)
		
		if (((isProperty c.baseObject "MultiCamAttributeData") == true) and OverrideSingleFrame == false) then
		(
			local mcData = c.baseObject.MultiCamAttributeData
			
			begframe = mcData.firstFrame_sp
			endframe = mcData.lastFrame_sp 
			
			if begframe != endframe then 
			(
				animationRange = interval begframe endframe
				sliderTime = begframe
				SingleFrame = false
			)
			else if begframe == endframe then 
			( 
				animationRange = interval begframe (begframe + 1)
				sliderTime = begframe
				SingleFrame = true
			)
			
			if (mcData.useHeightWidth_chb == true) then
			(
				print ("Setting old res in parse with found " + oldRenderRes as string)
				setRenderResolution #(mcData.imgWidth_sp, mcData.imgHeight_sp) submission:true
			)
			else
			(
				print ("Setting old res in parse " + oldRenderRes as string)
				setRenderResolution oldRenderRes submission:true
			)
			
			if (mcData.useHideLayers_chb == true) then
			(
				local layer_array = mcData.hideLayers_tab
				print ("Will hide these layers" + layer_array as string)
				setHiddenLayers layer_array			
			)
			else 
			(
				setHiddenLayers oldHideLayers
			)
			
			if (mcData.useHDRIMap_val == true) then
			(
				local arr = #()
				arr[1] = mcData.hdriMap_val
				arr[2] = true
				
				arr[3] = if mcData.hdriMapGI_val then true else vrayRend.environment_gi_on
				arr[4] = if mcData.hdriMapGI_val then mcData.hdriMapGIMult_sp else vrayRend.environment_gi_color_multiplier
				arr[5] = if mcData.hdriMapGI_val then mcData.hdriMap_val else vrayRend.environment_gi_map
				arr[6] = if mcData.hdriMapGI_val then true else vrayRend.environment_gi_map_on
				
				arr[7] = if mcData.hdriMapRefl_val then true else vrayRend.environment_rr_on
				arr[8] = if mcData.hdriMapRefl_val then mcData.hdriMapReflMult_sp else vrayRend.environment_rr_color_multiplier
				arr[9] = if mcData.hdriMapRefl_val then mcData.hdriMap_val else vrayRend.environment_rr_map
				arr[10] = if mcData.hdriMapRefl_val then true else vrayRend.environment_rr_map_on
		  
				arr[11] = if mcData.hdriMapRefr_val then true else vrayRend.environment_refract_on
				arr[12] = if mcData.hdriMapRefr_val then mcData.hdriMapRefrMult_sp else vrayRend.environment_refract_color_multiplier
				arr[13] = if mcData.hdriMapRefr_val then mcData.hdriMap_val else vrayRend.environment_refract_map
				arr[14] = if mcData.hdriMapRefr_val then true else vrayRend.environment_refract_map_on
						
				setEnvSettings arr
			)
			else
			(
				setEnvSettings oldEnvSettings	
			)
		
		)
		else if (OverrideSingleFrame == true) then
		(
			begframe = (currenttime as integer)/(4800/framerate)
			endframe = ((currenttime+1) as integer)/(4800/framerate)
			print ("Setting old res in parse no mod with override " + oldRenderRes as string)
			setRenderResolution oldRenderRes submission:true
			setHiddenLayers oldHideLayers
			setEnvSettings oldEnvSettings
			SingleFrame = true
		)
		else
		(
			MessageBox ("Camera " + c.name + " does not have a Submitter Attribute.\nUsing one frame.") title:"Missing Submitter Attribute" beep:false
			begframe = (currenttime as integer)/(4800/framerate)
			endframe = ((currenttime+1) as integer)/(4800/framerate)
			print ("Setting old resolution in parse no mod no override " + oldRenderRes as string)
			setRenderResolution oldRenderRes submission:true
			setHiddenLayers oldHideLayers
			setEnvSettings oldEnvSettings
			SingleFrame = true
		)
		print ("Setting old res in parse at end " + oldRenderRes as string)
	)
	
	
	
--########################--	
--FFMPEG JOB FUNCTIONS
--########################--	
		
	fn FFmpegCreateSubmitInfoFile filename outputFileName =
	(
		--local formattedJobName = (SMTDFunctions.FormatJobName SMTDSettings.JobName)
		--local formattedComment = (SMTDFunctions.FormatComment SMTDSettings.Comment)
		
		--if rendNthFrame == 1
		local submitInfoFile = CreateFile filename
		if (submitInfoFile != undefined) then
		(
			StartFrame = EndFrame = 0
			case rendTimeType of
			(
				2: (
					StartFrame = animationRange.start.frame as integer
					EndFrame = animationRange.end.frame as integer
				)	
				3: (
					StartFrame = rendStart.frame as integer
					EndFrame = rendEnd.frame as integer
				)	
			)
			
			format "Plugin=FFmpeg\n" to:submitInfoFile
			
			format "JobDependencies=%\n" 	SMTDSettings.DeadlineSubmissionLastJobID  to:submitInfoFile
			format "ResumeOnDeletedDependencies=%\n" SMTDSettings.ResumeOnDeletedDependencies to:submitInfoFile
			
			format "OverrideJobFailureDetection=True\n"						to:submitInfoFile
			format "FailureDetectionJobErrors=1\n"								to:submitInfoFile
			
			format "Priority=%\n" 			SMTDSettings.Priority 	 				to:submitInfoFile
			format "Pool=%\n" 				SMTDSettings.QuicktimePoolName			to:submitInfoFile
			format "Group=%\n" 				SMTDSettings.QuicktimeGroupName			to:submitInfoFile
			format "BatchName=%\n" 		(getProjectName())					to:submitInfoFile
			
			format "Name=%\n" 			(currentCameraName + "_"+ rootnode.CA_passDirectory	)		to:submitInfoFile
			
			format "UserName=%\n"			SMTDSettings.UserName				to:submitInfoFile
			format "TaskTimeoutSeconds=600\n"										 to:submitInfoFile
			
			format "Department=%\n" 		SMTDSettings.Department 				to:submitInfoFile				
			format "Frames=%\n" ((StartFrame as string) + "-" + (EndFrame as string))	to:submitInfoFile
			format "ChunkSize=100000\n" 											to:submitInfoFile
			
			format "OutputDirectory0=%\n" (getFileNamePath outputFileName) 				to:submitInfoFile
			format "OutputFilename0=%\n" (filenameFromPath outputFileName) 			to:submitInfoFile
			
			close submitInfoFile
			true
		)
		else
			false
	)
	
	fn FFmpegCreateJobInfoFile filename inputImages outputFileName =
	(
		local JobInfoFile = CreateFile filename
		if (JobInfoFile != undefined) then
		(
			StartFrame = EndFrame = 0
			case rendTimeType of
			(
				2: (
					StartFrame = animationRange.start.frame as integer
					EndFrame = animationRange.end.frame as integer
				)	
				3: (
					StartFrame = rendStart.frame as integer
					EndFrame = rendEnd.frame as integer
				)	
			)
		
			theBaseFile = getFileNameFile inputImages
			theSource = if superclassof (try(execute (substring theBaseFile (theBaseFile.count-3) 4))catch()) == Number then
				inputImages 
			else
				getFileNamePath inputImages + theBaseFile + "." + SMTDFunctions.getZeros StartFrame + StartFrame as string + getFileNameType inputImages 

			format "InputFile0=%\n" theSource  to:JobInfoFile
			format "InputArgs0=%\n" ("-f image2 -y -framerate " + frameRate as string + " -start_number " + begframe as string + " \n")  to:JobInfoFile
			format "ReplacePadding0=True\n" to:JobInfoFile
			format "OutputFile=%\n" outputFileName to:JobInfoFile
			format "OutputArgs=%\n" (" -vcodec utvideo -pred left -pix_fmt rgb24 -r " + frameRate as string +" \n") to:JobInfoFile
			format "UseSameInputArgs=False\n" to:JobInfoFile
			Close JobInfoFile
			true
		)
		else
			false
	)

	fn AutomaticFFmpegGeneration overrideOutputPath:"" overrideInput:""=
	(
		local goOn = true
		if rendTimeType == 1 do (goOn = false)
		if rendTimeType == 4 do (goOn = false)
		
		if goOn then
		(
			local submitInfo = SMTDPaths.TempDir + "FFmpeg_max_submit_info.job"
			local jobInfo = SMTDPaths.TempDir + "FFmpeg_max_job_info.job"
			
			tempFilter = filterstring rootnode.CA_frameOutput  "\\"
			
			makeDir(tempFilter[1] + "\\" + tempFilter[2] + "\\" + "03_Previews" + "\\" + rootnode.CA_passDirectory )
			
			theMOVFile = tempFilter[1] + "\\" + tempFilter[2] + "\\" + "03_Previews" +"\\" + rootnode.CA_passDirectory + "\\" + currentCameraName + ".avi"
			
			if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then
			(
				outputFile = vrayRend.output_rawfilename
			)
			else 
			(
				outputFile = vrayRend.output_splitfilename
			)
		
			theInputPath = getFilenamePath outputFile + getFilenameFile outputFile + ".jpg"
			
			
			FFmpegCreateSubmitInfoFile submitInfo theMOVfile 
			FFmpegCreateJobInfoFile jobinfo theInputPath theMOVfile 
			local initialArgs = ""
			initialArgs += "\"" + submitInfo + "\" \"" + jobInfo + "\""
			local retCode = SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutQTSubmission
			local renderMsg = SMTDFunctions.getRenderMessage() 
			SMTDFunctions.getJobIDFromMessage renderMsg
			if result == #success then 
			(
				format "Submitted successfully as Job %.\n\n%\n\n" \
				SMTDSettings.DeadlineSubmissionLastJobID renderMsg
			)
			else 
				(format "Job Submission FAILED.\n\n%" renderMsg)
		)	
	)

	
--########################--	
--VRAY SPAWNER JOB FUNCTIONS
--########################--	
	
	--Job Info File	
	fn VraySpawnGeneration =
	(

		local submitInfo = SMTDPaths.TempDir + "VraySpawn_max_submit_info.job"
		local jobInfo = SMTDPaths.TempDir + "VraySpawn_max_job_info.job"
		
		local submitInfoFile = CreateFile submitInfo
		if (submitInfoFile != undefined) then
		(		
			format "Plugin=VraySpawner\n" to:submitInfoFile
				
			format "OverrideJobFailureDetection=True\n"						to:submitInfoFile
			format "FailureDetectionJobErrors=1\n"								to:submitInfoFile
			
			format "Priority=%\n" 			(rootnode.CA_Priority)	 				to:submitInfoFile
			format "Pool=%\n" 				SMTDSettings.QuicktimePoolName			to:submitInfoFile
			format "Group=%\n" 				SMTDSettings.QuicktimeGroupName			to:submitInfoFile
			format "BatchName=%\n" 		(getProjectName())					to:submitInfoFile
			
			format "Name=%\n" 			("01.DR___" + rootnode.CA_jobPrefix + "___" + currentCameraName)		to:submitInfoFile
			
			format "UserName=%\n"			SMTDSettings.UserName				to:submitInfoFile
			format "TaskTimeoutSeconds=600\n"										 to:submitInfoFile
			
			format "Department=%\n" 		SMTDSettings.Department 				to:submitInfoFile				
			format "Frames=%\n" ("0-" + ((filterstring (getDrServers()) ",").count - 1) as string)	to:submitInfoFile
			format "ChunkSize=1\n" 											to:submitInfoFile
			format "Whitelist=%\n"			(getDrServers())	to:submitInfoFile
						
			close submitInfoFile
		)
		
		local JobInfoFile = CreateFile jobInfo
		if (JobInfoFile != undefined) then
		(
			format "Version=Max%\n" (getMaxVer())  to:JobInfoFile
			close JobInfoFile
		)
		
		local initialArgs = ""
		initialArgs += "\"" + submitInfo + "\" \"" + jobInfo + "\""
		local retCode = SMTDFunctions.waitForCommandToComplete initialArgs 120
		local renderMsg = SMTDFunctions.getRenderMessage() 
		SMTDFunctions.getJobIDFromMessage renderMsg

		if retCode == #success then 
		(
			format "Submitted successfully as Job %.\n\n%\n\n" 	SMTDSettings.DeadlineSubmissionLastJobID renderMsg
			append SMTDSettings.PreviousJobsArray #((currentCameraName + "_"+ rootnode.CA_passDirectory),SMTDSettings.DeadlineSubmissionLastJobID,"3dsmax",SMTDSettings.UserName,SMTDSettings.Department,SMTDSettings.Group, "Previous")
		)
		else 
			(format "Job Submission FAILEDD.\n\n%" renderMsg)
		
	)
	
--########################--	
--PREVIEW FUNCTIONS
--########################--		

	fn preview_jpg =
	(
		if SingleFrame == true then (endframe = begframe)
		
		local padLength = 4		
		local x = y = 0, v
		local s = getViewSize()
		local k = getRendImageAspect()
		
		local anim_bmp = undefined
		local dib = (gw.getViewportDib())
		local windowScaleWidth = dib.width / s.x
		local windowScaleHeight = dib.height / s.y

		free dib

		s = [s.x*windowScaleWidth,s.y*windowScaleHeight]

		if k < (s.x/s.y) then -- if portrait
		(
			v = [s.y*k,s.y]
			x = (s.x-v.x)/2 + 1
		)
		else -- if landscape
		(
			v = [s.x, s.x/k]
			y = (s.y-v.y)/2 + 1
		)	
	
		local progressPercent = true
		local aniRange = (((animationrange.end - animationrange.start) as integer) / TicksPerFrame) as float
		progressStart "Generating Preview"
		
		for t = begframe to endframe while progressPercent do
		(	
			local percentage = 100.0 * ((t-begframe)/(aniRange-begframe))
			progressPercent = progressUpdate percentage
			sliderTime = t
			--local frame_num = (slidertime as integer) / TicksPerFrame
			local frame_num = (padNumber t padLength ) as string
			local preview_name = rootnode.CA_frameOutput + currentCameraName + "\\"+ currentCameraName +"__"+ frame_num +".jpg"

			anim_bmp = bitmap v.x v.y filename:preview_name
				
			dib = (gw.getViewportDib())
			pasteBitmap dib anim_bmp (box2 x y v.x v.y) [0,0]
			save anim_bmp
			free dib
			free anim_bmp

			if keyboard.escPressed or progressPercent == false do 
			(
				progressEnd()
				close dib
				close anim_bmp
				destroyDialog multiCamSubmitter
				return false
			)
		)

		close anim_bmp
		close dib
		progressEnd()
		return true
	)
	
	-- Outdated function probably needs to be deleted
	fn preview_mov =
	(
		local oldEscapeEnable = escapeEnable
		escapeEnable = true
		local firstFrameFile = ""
		local padLength = 4

		for t = begframe to endframe do
		(	
			sliderTime = t
			local frame_num = (slidertime as integer) / TicksPerFrame
			frame_num = (padNumber frame_num padLength ) as string
			local preview_name = "C:\\tempPreview" + "\\"+ currentCameraName + "\\"+ currentCameraName +"__"+ frame_num +".jpg"
			if t == begframe then firstFrameFile = "C:\\tempPreview" + "\\"+ currentCameraName + "\\"+ currentCameraName +"__"+ "%0" + padLength as string +"d.jpg"
			local x = y = 0, v
			local s = getViewSize()
			local k = getRendImageAspect()
 
			if k < (s.x/s.y) then -- if portrait
			(
				v = [s.y*k,s.y]
				x = (s.x-v.x)/2 + 1
			)
			else -- if landscape
			(
				v = [s.x, s.x/k]
				y = (s.y-v.y)/2 + 1
			)
			
			anim_bmp = bitmap v.x v.y filename:preview_name
				
			dib = (gw.getViewportDib())			
			pasteBitmap dib anim_bmp (box2 x y v.x v.y) [0,0]
			--copy dib anim_bmp
			save anim_bmp
			free dib
			free anim_bmp
		)
		
		if ((doesfileexist "c:\\PreviewMOVs") == false) then (makedir "c:\\PreviewMOVs")
		MOVDest = "C:\\PreviewMOVs\\" + currentCameraName + ".mov"

		command = "\"\"" + FFmpegExe + "\"" + " -f image2 -framerate " + framerate as string + " -y -start_number " + (begframe) as string + " -i " + "\"" + firstFrameFile + "\"" + " -vf " + "\"" + "scale=" + renderWidth as string + ":" + renderHeight as string +", colormatrix=bt601:bt709" +  "\"" + " -vcodec dnxhd -r " + framerate as string + " -b:v 175M " + "\"" + MOVDest +  "\"\""
		print command
		DOSCommand (command)
		escapeEnable = oldEscapeEnable
	)
	
	fn preview_avi =
	(
		local firstFrameFile = ""
		local padLength = 4
		
		local x = y = 0, v
		local s = getViewSize()
		local k = getRendImageAspect()
		
		local anim_bmp = undefined
		local dib = (gw.getViewportDib())
		local windowScaleWidth = dib.width / s.x
		local windowScaleHeight = dib.height / s.y

		free dib
		
		s = [s.x*windowScaleWidth,s.y*windowScaleHeight]

		if k < (s.x/s.y) then -- if portrait
		(
			v = [s.y*k,s.y]
			x = (s.x-v.x)/2 + 1
		)
		else -- if landscape
		(
			v = [s.x, s.x/k]
			y = (s.y-v.y)/2 + 1
		)

		local progressPercent = true
		local aniRange = (((animationrange.end - animationrange.start) as integer) / TicksPerFrame) as float
		
		progressStart "Generating Preview"

		for t = begframe to endframe while progressPercent do
		(	
			local percentage = 100.0 * ((t-begframe)/(aniRange-begframe))
			progressPercent = progressUpdate percentage
			sliderTime = t
			--local frame_num = (slidertime as integer) / TicksPerFrame
			local frame_num = (padNumber t padLength ) as string
			local preview_name = "C:\\tempPreview" + "\\"+ currentCameraName + "\\"+ currentCameraName +"__"+ frame_num +".jpg"
			if t == begframe then firstFrameFile = "C:\\tempPreview" + "\\"+ currentCameraName + "\\"+ currentCameraName +"__"+ "%0" + padLength as string +"d.jpg"
						
			anim_bmp = bitmap v.x v.y filename:preview_name
				
			dib = (gw.getViewportDib())			
			pasteBitmap dib anim_bmp (box2 x y v.x v.y) [0,0]
			save anim_bmp
			free dib
			free anim_bmp

			if keyboard.escPressed or progressPercent == false do 
			(
				progressEnd()
				close dib
				close anim_bmp
				destroyDialog multiCamSubmitter
				return false
			)
		)
		close dib
		close anim_bmp
		
		if ((doesfileexist "c:\\PreviewMOVs") == false) then (makedir "c:\\PreviewMOVs")
		MOVDest = "C:\\PreviewMOVs\\" + currentCameraName + ".avi"

		local prevWidth = ""
		local prevHeight = ""
		local camLens = (getCamFocalLength currentCamera) as string

		if (vrayRend.output_getsetsfrommax == false) then
		(
			prevWidth = vrayRend.output_width as string
			prevHeight = vrayRend.output_height as string
		)
		else 
		(
			prevWidth = renderWidth as string
			prevHeight = renderHeight as string
		)

		command = "\"\"" + FFmpegExe + "\"" + " -f image2 -framerate " + (frameRate as string) + " -y -start_number " + (begframe as string) + " -i "  + "\"" + firstFrameFile + "\"" + " -vf " + "\"" + "scale=" + prevWidth + ":" + prevHeight  + ", drawtext=fontfile=/Windows/Fonts/calibri.ttf: text='camera\: " + currentCameraName + "    frame\: %{frame_num}    lens\: "+camLens+"mm': start_number=" + (begframe as string) + ": x=(w-tw)/10: y=h-(2*lh): fontcolor=black: fontsize=20: box=1: boxcolor=white: boxborderw=5" + "\"" + " -vcodec utvideo -pred left -pix_fmt gbrp -r " + (frameRate as string) + " " + "\"" + MOVDest +  "\"\""
		print command
		DOSCommand (command)
		
		progressEnd()
		return true
	)
	

--########################--	
--RENDER SETTINGS
--########################--	

	fn exrSettingsOff = 
	(
		vrayRend.output_on=true
		defaultVFB()
		vrayRend.output_useram = true
		vrayRend.output_saverawfile = false
		vrayRend.output_splitgbuffer = false
		vrayRend.output_saveFile = false
		vrayRend.output_splitRGB = false
		vrayRend.output_splitAlpha = false
		vrayRend.output_splitfilename = ""		
		vrayRend.output_rawfilename = ""
	)
	
	
	fn exrSettings useRAM = 
	(
		vrayRend.output_on=true
		defaultVFB()
		vrayRend.output_useram = (not useRAM) --false: show render window
		vrayRend.output_saverawfile = true
		vrayRend.output_splitgbuffer = false
		vrayRend.output_saveFile = false
		vrayRend.output_splitRGB = false
		vrayRend.output_splitAlpha = false
		vrayRend.output_splitfilename = ""		
		vrayRend.output_force32bit_3dsmax_vfb = true
		vrayRend.fileName_addDot = true
		vrayRend.output_rawfilename = rootnode.CA_frameOutput + currentCameraName + "\\" + rootnode.CA_passDirectory + "\\" + currentCameraName + "_" + rootnode.CA_extension
		
	)
		
	fn nonExrSettings override = 
	(
		if override != "" then overrideExt = override 
		else (overrideExt = rootnode.CA_extension)
		vrayRend.output_on=true
		defaultVFB()
		vrayRend.output_useram = true
		vrayRend.output_saverawfile = false
		vrayRend.output_rawfilename = ""
		vrayRend.output_splitgbuffer = true
		vrayRend.output_saveFile = true
		vrayRend.output_splitRGB = true
		vrayRend.output_splitAlpha = false
		vrayRend.output_splitfilename = rootnode.CA_frameOutput + currentCameraName + "\\" + rootnode.CA_passDirectory + "\\" + currentCameraName + "_" + overrideExt
		mybitmap = bitmap 320 240 color:white gamma: 0.454545
		mybitmap.filename = rootnode.CA_frameOutput + currentCameraName + "\\" + rootnode.CA_passDirectory + "\\" + currentCameraName + "_" + overrideExt
		save mybitmap
		vrayRend.output_splitbitmap = mybitmap
		close mybitmap
		free mybitmap
		
		--REMOVE--
		/*
		if (z_var == true) then
		(
			for i =1 to zdeptharray.count by 2 do 
			( 
				save_path = rendoutputFilename 
				newpath = getFilenamePath save_path + getFilenameFile save_path + "__" + zdeptharray[i+ 1] + rootnode.CA_extension
				re = maxops.getcurrenderelementmgr()
				re.setrenderelementfilename zdeptharray[i] newpath
			)
		)
		*/
	)
	
	------------------------------------------------------------------
	--Diagnostic Submission 
	------------------------------------------------------------------
	
	fn openDiagnosticJobSelectorRO = 
	(
		diagnosticJobSelectorRO = rollout diagnosticJobSelectorRO "Job Type Selector" width: 280
		(
			local result
			
			listbox jobTypes_lb "Select Type:" items:#("Single: Turn off one layer per job" , "Recursive: Turn on half the layers per job" , "Cumulative: Turn on one additional layer per job" ) selected:1 height:8
			spinner machinesPerJob_spn "Machines per Job" range:[0,500,0] type:#integer
			spinner errorsAllowed_spn "Errors Allowed" range:[0,500,0] type:#integer
			button submit_btn "Submit" width:85 across: 2
			button cancel_btn "Cancel"  width:85 
			
			fn init val:undefined=
			(
				try(destroydialog diagnosticJobSelectorRO)catch()
				result = val
				CreateDialog diagnosticJobSelectorRO modal:true
				result 
			)
			
			fn switchAndClose val =
			(
				result = val
				destroyDialog diagnosticJobSelectorRO
			)
			
			on cancel_btn pressed do switchAndClose undefined
			
			on submit_btn pressed do switchAndClose #(jobTypes_lb.selection, machinesPerJob_spn.value, errorsAllowed_spn.value)
		
		)
		diagnosticJobSelectorRO.init()
	)
	

		
	 fn generateHalfArrays arr res = 
	 (
		local a = for i=1 to arr.count/2 collect arr[i]
		local b = for i= (arr.count/2 + 1) to arr.count collect arr[i]

		append res a
		append res b

		if a.count > 2 then half a res
		if b.count > 2 then half b res

		res
	 )


	fn layersSequentialUnhide machinesPerJob errorsAllowed = 
	(
		layersHideAll()
		local layerArray = for i = 0 to (LayerManager.count - 1) collect (LayerManager.getLayer i)
		qsort layerArray compareByObjectName 
		local visibleLayersArray = #()
		for l in layerArray while (cancelProcessRO.cancelPreview_bn.checked == false and cancelProcessRO.open == true) do
		(
			l.on = true
			append visibleLayersArray l.name
			local jobSuffix = "--Layers unhidden: 0 to " + visibleLayersArray.count as string
			as_is_diag_settings jobSuffix "Visible Layers" visibleLayersArray machinesPerJob errorsAllowed
		)
	)
	
	fn layersHideOneAtATime machinesPerJob errorsAllowed = 
	(
		
		local layerArray = for i = 0 to (LayerManager.count - 1) collect (LayerManager.getLayer i)
		qsort layerArray compareByObjectName 
		for l in layerArray while (cancelProcessRO.cancelPreview_bn.checked == false and cancelProcessRO.open == true) do
		(
			layersShowAll()
			l.on = false
			local jobSuffix = "--Layer hidden: " + l.name
			as_is_diag_settings jobSuffix "Hidden Layer" #(l.name) machinesPerJob errorsAllowed
		)
	)

	fn layersHideHalfAtATime machinesPerJob errorsAllowed = 
	(
		local halvedLayerArray = #()
		local halvedLayerIndexes = #()
		local layerArray = for i = 0 to (LayerManager.count - 1) collect (LayerManager.getLayer i)
		local layerArrayIndexes = for i = 0 to (LayerManager.count - 1) collect i
		
		qsort layerArray compareByObjectName
 		generateHalfArrays layerArray halvedLayerArray
 		generateHalfArrays layerArrayIndexes halvedLayerIndexes
		
		for i=1 to halvedLayerArray.count while (cancelProcessRO.cancelPreview_bn.checked == false and cancelProcessRO.open == true) do
		(
			layersHideAll()
			local visibleLayersArray = #()
			for l in halvedLayerArray[i] do 
			(
				l.on = true
				append visibleLayersArray l.name
			)
			local jobSuffix = "--Layers unhidden: " + (halvedLayerIndexes[i][1] as string) + " to " + (halvedLayerIndexes[i][halvedLayerIndexes[i].count] as string)
			as_is_diag_settings jobSuffix "Visible Layers" visibleLayersArray machinesPerJob errorsAllowed
		)
	)
	
	------------------------------------------------------------------
	--Vray NOGI Settings
	------------------------------------------------------------------
	fn nogi_settings begframe endframe = 
	(

						
		--Vray Properties
		renderSceneDialog.close()
		rendOutputFilename = ""													    --reset render 
		vrayRend.gi_on = false
		vrayRend.options_dontRenderImage = false
		rendFieldRender = false 
		if (SingleFrame == false) then (rendTimeType = 2)
		else (rendTimeType = 1)
		rendNThFrame = rootnode.CA_FRNthFrame
		rendShowVFB = false
		rendSaveFile = false
		
		makedir (rootnode.CA_frameOutput +"\\" + currentCameraName +"\\"+ rootnode.CA_passDirectory)
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then exrSettings rootnode.CA_disableVFB
		else if extensionsList[rootnode.CA_extensionType] == ".exr (split)" then nonExrSettings ".exr"
		else nonExrSettings ""

		if rootnode.CA_latestDir == true then (AddCallbackLatest())
		if (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" or rootnode.CA_SubmitMOV == true and SingleFrame != true) then (AddCallbackJPG())	

		deadlineRegionRendering()
			
		--AddCallbackRemoveModifier()
		
		SMTDSettings.JobName = rootnode.CA_jobPrefix + currentCameraName + "--NOGI"
		SMTDSettings.Comment = "Scripted No GI Frame Job"
		SMTDSettings.Priority = rootnode.CA_Priority
		SMTDSettings.ChunkSize = 1
		SMTDSettings.OverrideJobFailureDetection = false
		SMTDSettings.FailureDetectionJobErrors = 0
		SMTDSettings.LimitEnabled = false 
		SMTDSettings.MachineLimit = 0
		SMTDSettings.SlavesBlackList = true
		SMTDSettings.SlavesList = #()
		SMTDSettings.SubmitAsSuspended = true
		SMTDSettings.LimitGroups = #()
		SMTDSettings.LimitGroupsToUse= #()
		SMTDSettings.group = "frames"
		SMTDSettings.SequentialJob = false
		SMTDSettings.JobIsInterruptible = false
		SMTDSettings.RestartRenderer = true
		SMTDSettings.purifyFilenames = true
		SMTDSettings.IgnoreMissingXREFs = false							
		SMTDSettings.SubmitAsDependent = false
		SMTDSettings.ExtraInfoKeyValues = #(#("framerate",framerate))
		
		local batchName = getProjectName()
		SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:currentCameraName
		
		if rootnode.CA_latestDir == true then (callbacks.removescripts id:#copyLatest_callback)
		if (rootnode.CA_SubmitMOV == true) or (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg") then (callbacks.removescripts id:#copyJPG_callback)
		
		if (rootnode.CA_SubmitMOV == true and SingleFrame != true) then
		(
			AutomaticFFmpegGeneration()						
		)
						
	)--end nogi_settings	

	
	------------------------------------------------------------------
	--Vray AS IS Settings
	------------------------------------------------------------------
	fn as_is_settings begframe endframe = 
	(

						
		--Vray Properties
		renderSceneDialog.close()
		rendOutputFilename = ""													    --reset render 
		vrayRend.options_dontRenderImage = false
		rendFieldRender = false 
		if (SingleFrame == false) then (rendTimeType = 2)
		else (rendTimeType = 1)                    											-- time output in render dialogue 2 is active time segment
		rendNThFrame = rootnode.CA_FRNthFrame
		rendSaveFile = false
		rendShowVFB = false
		
		makedir (rootnode.CA_frameOutput +"\\" + currentCameraName +"\\"+ rootnode.CA_passDirectory) 
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then exrSettings rootnode.CA_disableVFB
		else if extensionsList[rootnode.CA_extensionType] == ".exr (split)" then nonExrSettings ".exr"
		else nonExrSettings ""
		
		if rootnode.CA_latestDir == true then (AddCallbackLatest())
		if (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" or rootnode.CA_SubmitMOV == true and SingleFrame != true) then (AddCallbackJPG())	
		
		deadlineRegionRendering()
		
		--AddCallbackRemoveModifier()
		
		SMTDSettings.JobName = rootnode.CA_jobPrefix + currentCameraName + "--AS_IS"
		SMTDSettings.Comment = "Scripted AS IS Frame Job"
		SMTDSettings.Priority = rootnode.CA_Priority
		SMTDSettings.ChunkSize = 1
		SMTDSettings.OverrideJobFailureDetection = false
		SMTDSettings.FailureDetectionJobErrors = 0
		SMTDSettings.LimitEnabled = false 
		SMTDSettings.MachineLimit = 0
		SMTDSettings.SlavesBlackList = true
		SMTDSettings.SlavesList = #()
		SMTDSettings.SubmitAsSuspended = true
		SMTDSettings.LimitGroups = #()
		SMTDSettings.LimitGroupsToUse= #()
		SMTDSettings.group = "frames"
		SMTDSettings.SequentialJob = false
		SMTDSettings.JobIsInterruptible = false
		SMTDSettings.RestartRenderer = true
		SMTDSettings.purifyFilenames = true
		SMTDSettings.IgnoreMissingXREFs = false
		SMTDSettings.ExtraInfoKeyValues = #(#("framerate",framerate))
		
		SMTDSettings.SubmitAsDependent = false
		

		local batchName = getProjectName()
		SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:currentCameraName
		
		if rootnode.CA_latestDir == true then (callbacks.removescripts id:#copyLatest_callback)
		if (rootnode.CA_SubmitMOV == true) or (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg") then (callbacks.removescripts id:#copyJPG_callback)
		
		if (rootnode.CA_SubmitMOV == true and SingleFrame != true) then
		(
			AutomaticFFmpegGeneration()						
		)
		SMTDSettings.group = "none"
		
	)--end as_is_settings
	
	------------------------------------------------------------------
	--Vray AS IS Diagnostic Settings
	------------------------------------------------------------------
	fn as_is_diag_settings jobSuffix layerArrayName layersArray machinesPerJob errorsAllowed = 
	(

						
		--Vray Properties
		renderSceneDialog.close()
		rendOutputFilename = ""													    --reset render 
		vrayRend.options_dontRenderImage = false
		rendFieldRender = false 
		if (SingleFrame == false) then (rendTimeType = 2)
		else (rendTimeType = 1)                    									-- time output in render dialogue 2 is active time segment
		rendNThFrame = rootnode.CA_FRNthFrame
		rendSaveFile = false
		rendShowVFB = false
		
		makedir (rootnode.CA_frameOutput +"\\" + currentCameraName +"\\"+ rootnode.CA_passDirectory) 
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then exrSettings rootnode.CA_disableVFB
		else if extensionsList[rootnode.CA_extensionType] == ".exr (split)" then nonExrSettings ".exr"
		else nonExrSettings ""
		
		--if rootnode.CA_latestDir == true then (AddCallbackLatest())
		if (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" or rootnode.CA_SubmitMOV == true and SingleFrame != true) then (AddCallbackJPG())	
		
		deadlineRegionRendering()
		
		--AddCallbackRemoveModifier()
		
		--SMTDSettings.JobName = rootnode.CA_jobPrefix + currentCameraName + "--Layers: 0 to " + layersArray.count as string
		SMTDSettings.JobName = rootnode.CA_jobPrefix + currentCameraName + jobSuffix
		
		SMTDSettings.Comment = "Scripted Diagnostic Frame Job"
		SMTDSettings.Priority = rootnode.CA_Priority
		SMTDSettings.ChunkSize = 1
		
		if errorsAllowed != 0 then 
		(
			SMTDSettings.OverrideJobFailureDetection = true
			SMTDSettings.FailureDetectionJobErrors = errorsAllowed
		)
		else
		(
			SMTDSettings.OverrideJobFailureDetection = false
			SMTDSettings.FailureDetectionJobErrors = 0
		)
		
		SMTDSettings.LimitEnabled = true
		SMTDSettings.MachineLimit = machinesPerJob
		SMTDSettings.SlavesBlackList = true
		SMTDSettings.SlavesList = #()
		SMTDSettings.SubmitAsSuspended = true
		SMTDSettings.LimitGroups = #()
		SMTDSettings.LimitGroupsToUse= #()
		SMTDSettings.group = "frames"
		SMTDSettings.SequentialJob = false
		SMTDSettings.JobIsInterruptible = false
		SMTDSettings.RestartRenderer = true
		SMTDSettings.purifyFilenames = true
		SMTDSettings.IgnoreMissingXREFs = false
		SMTDSettings.ExtraInfoKeyValues = #(#("framerate",framerate), #(layerArrayName, (with printAllElements on layersArray as string)))
		
		SMTDSettings.SubmitAsDependent = false
		

		local batchName = getProjectName()  + "_Diagnostic"
		SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:currentCameraName
		
		if rootnode.CA_latestDir == true then (callbacks.removescripts id:#copyLatest_callback)
		if (rootnode.CA_SubmitMOV == true) or (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg") then (callbacks.removescripts id:#copyJPG_callback)
		
		if (rootnode.CA_SubmitMOV == true and SingleFrame != true) then
		(
			AutomaticFFmpegGeneration()						
		)
		SMTDSettings.group = "none"
		
	)--end as_is_settings
	
	------------------------------------------------------------------
	--Vray BRUTE FORCE ANIMATION Settings
	------------------------------------------------------------------
	fn bruteForce_settings begframe endframe = 
	(
		--Vray Properties
		renderSceneDialog.close()
		rendOutputFilename = ""								 	--reset render 
		fullfilename = maxFilePath + currentCameraName
		vrayRend.gi_on = true
		vrayRend.gi_primary_type = 2      						-- Brute Force
		vrayRend.gi_secondary_type = 3 						-- Light Cashe
		vrayRend.lightmap_preset = 1							--Animation
		
		--REPLACED BY PRESET IN VRAY 5--
		--vrayRend.lightcache_multipleViews = true 					--use camera path
		--vrayRend.lightcache_mode = 0 									--single frame				
		--vrayRend.lightcache_scale = 0 								-- screen 
		--vrayRend.lightcache_prefilter_on = false
		--vrayRend.lightcache_useForGlossyRays  = false
		--vrayRend.lightcache_subdivs  = 2000
		--vrayRend.lightcache_interpSamples  = 10				
		
		vrayRend.lightcache_loadFileName = ""
		vrayRend.lightcache_autosave = false
		vrayRend.lightcache_autosaveFileName = ""			
		vrayRend.options_dontRenderImage = false

		rendFieldRender = false 
		rendShowVFB = false
		rendSaveFile = false
		if (SingleFrame == false) then (rendTimeType = 2)
		else (rendTimeType = 1)
		
		-- time output in render dialogue 2 is active time segment
		rendNThFrame = rootnode.CA_FRNthFrame

		makedir (rootnode.CA_frameOutput + currentCameraName +"\\"+ rootnode.CA_passDirectory) 
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then exrSettings rootnode.CA_disableVFB
		else if extensionsList[rootnode.CA_extensionType] == ".exr (split)" then nonExrSettings ".exr"
		else nonExrSettings ""
		
		if rootnode.CA_latestDir == true then (AddCallbackLatest())
		if (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" or rootnode.CA_SubmitMOV == true and SingleFrame != true) then (AddCallbackJPG())	
		
		deadlineRegionRendering()
		
		--AddCallbackRemoveModifier()
		
		SMTDSettings.JobName = "BF_ani___" + rootnode.CA_jobPrefix + "___" + currentCameraName
		SMTDSettings.Comment = "Scripted Brute Force Frame Job"
		SMTDSettings.Priority = rootnode.CA_Priority
		SMTDSettings.ChunkSize = 1
		SMTDSettings.OverrideJobFailureDetection = false
		SMTDSettings.FailureDetectionJobErrors = 0
		SMTDSettings.LimitEnabled = false 
		SMTDSettings.MachineLimit = 0
		SMTDSettings.SlavesBlackList = true
		SMTDSettings.SlavesList = #()
		SMTDSettings.SubmitAsSuspended = true
		SMTDSettings.LimitGroups = #()
		SMTDSettings.LimitGroupsToUse= #()
		SMTDSettings.group = "frames"
		SMTDSettings.SequentialJob = false
		SMTDSettings.JobIsInterruptible = false
		SMTDSettings.RestartRenderer = true
		SMTDSettings.purifyFilenames = true
		SMTDSettings.IgnoreMissingXREFs = false
		SMTDSettings.ExtraInfoKeyValues = #(#("framerate",framerate))
		
		SMTDSettings.SubmitAsDependent = false

		local batchName = getProjectName()
		SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:currentCameraName
		
		if rootnode.CA_latestDir == true then (callbacks.removescripts id:#copyLatest_callback)
		if (rootnode.CA_SubmitMOV == true) or (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg") then (callbacks.removescripts id:#copyJPG_callback)
		
		if (rootnode.CA_SubmitMOV == true and SingleFrame != true) then
		(
			AutomaticFFmpegGeneration()						
		)
		
		SMTDSettings.group = "none"

	)--end animated_settings
	
	------------------------------------------------------------------
	--Vray BRUTE FORCE ANIMATION W/ SPHERES Settings
	------------------------------------------------------------------
	fn bruteForceSphere_settings begframe endframe = 
	(

						
		--Vray Properties
		renderSceneDialog.close()
		rendOutputFilename = ""								 --reset render 
		fullfilename = maxFilePath + currentCameraName
		
		oldOptions = #()
		oldOptions[1] =vrayRend.gi_on  
		oldOptions[2] =vrayRend.options_shadows  
		oldOptions[3] =vrayRend.options_maps
		oldOptions[4] =vrayRend.options_reflectionRefraction  
		oldOptions[5] =vrayRend.options_glossyEffects  
		oldOptions[6] =vrayRend.options_lights  
		oldOptions[7] =vrayRend.options_hiddenLights  
		oldOptions[8] =vrayRend.options_dontRenderImage  

		vrayRend.gi_on = false
		vrayRend.options_shadows = false
		vrayRend.options_maps = true
		vrayRend.options_reflectionRefraction = false  -- NOT SURE , MAYBE SHOULD BE TRUE
		vrayRend.options_glossyEffects = false
		vrayRend.options_lights = false
		vrayRend.options_hiddenLights = false
		vrayRend.options_dontRenderImage = false

		rendFieldRender = false 
		rendShowVFB = false
		rendSaveFile = false
		rendTimeType = 2                    						-- time output in render dialogue 2 is active time segment
		rendNThFrame = rootnode.CA_FRNthFrame

		makedir (rootnode.CA_frameOutput + currentCameraName +"\\"+ rootnode.CA_passDirectory) 
		nonExrSettings ".tga"
			
		-- correct frame pathing
		frame_file = createFile (rootnode.CA_frameOutput + currentCameraName +"\\"+ rootnode.CA_passDirectory + "\\" + "SphereMask.ifl")
		IFLwriter frame_file
		
		
		-- disable all render elements from affecting the vfb
		re = maxOps.GetCurRenderElementMgr()
		print ("number of eles pre Sphere " + re.NumRenderElements() as string)
			
		for i = 0 to (re.NumRenderElements()-1) do 
		(
			(re.GetRenderElement i).vrayVFB = false
		)
		
		-- new render element
		re.addrenderelement (MultiMatteElement elementname:("SphereMask_"))
		newElement = re.GetRenderElement (re.NumRenderElements()-1)
		newElement.enabled = true
		newElement.filterOn = true
		newElement.R_gbufIDOn = true
		newElement.R_gbufID = 42
		newElement.G_gbufIDOn = false
		newElement.G_gbufID = 0
		newElement.B_gbufIDOn = false
		newElement.B_gbufID = 0
		newElement.MatID = false
		newElement.vrayVFB = true
		
			
		print ("number of eles post Sphere " + re.NumRenderElements()  as string)
		
		
		vrayRend.imageSampler_renderMask_type = 0
		vrayRend.imageSamper_renderMask_texmap = undefined 	
		clearSelection()
		for o in objects where o.gbufferchannel == 42 do (o.renderable = true; selectmore o)
		IsolateSelection.EnterIsolateSelectionMode()  -- Tools: Isolate Selection
		oldRenderHidden = rendHidden
		renderHidden = false
		
		deadlineRegionRendering()
		
		--AddCallbackRemoveModifier()
		
		SMTDSettings.JobName = "01.SphereMask_ani___" + rootnode.CA_jobPrefix + "___" + currentCameraName
		SMTDSettings.Comment = "Scripted Spheres Mask Pre-pass Job"
		SMTDSettings.Priority = rootnode.CA_Priority
		SMTDSettings.ChunkSize = 1
		SMTDSettings.OverrideJobFailureDetection = false
		SMTDSettings.FailureDetectionJobErrors = 0
		SMTDSettings.LimitEnabled = false 
		SMTDSettings.MachineLimit = 0
		SMTDSettings.SlavesBlackList = true
		SMTDSettings.SlavesList = #()
		SMTDSettings.SubmitAsSuspended = true
		SMTDSettings.LimitGroups = #()
		SMTDSettings.LimitGroupsToUse= #()
		SMTDSettings.group = "frames"
		SMTDSettings.SequentialJob = false
		SMTDSettings.JobIsInterruptible = false
		SMTDSettings.RestartRenderer = true
		SMTDSettings.purifyFilenames = true
		SMTDSettings.IgnoreMissingXREFs = false
		SMTDSettings.ExtraInfoKeyValues = #(#("framerate",framerate))
		
		SMTDSettings.SubmitAsDependent = false
		
		
		local batchName = getProjectName()
		SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:currentCameraName
						
		------------------------------------------------------------------
		--Vray Frames-
		------------------------------------------------------------------		
						
		vrayRend.gi_on = oldOptions[1]
		vrayRend.options_shadows = oldOptions[2]
		vrayRend.options_maps = oldOptions[3]
		vrayRend.options_reflectionRefraction = oldOptions[4]
		vrayRend.options_glossyEffects = oldOptions[5]
		vrayRend.options_lights = oldOptions[6]
		vrayRend.options_hiddenLights = oldOptions[7]
		vrayRend.options_dontRenderImage = oldOptions[8]

		vrayRend.gi_on = true
		vrayRend.gi_primary_type = 2      						-- Brute Force
		vrayRend.gi_secondary_type = 3 						-- Light Cashe
		vrayRend.lightmap_preset = 1							--Animation
		
		--REPLACED BY PRESET IN VRAY 5--
		--vrayRend.lightcache_multipleViews = true 					--use camera path
		--vrayRend.lightcache_mode = 0 									--single frame				
		--vrayRend.lightcache_scale = 0 								-- screen 
		--vrayRend.lightcache_prefilter_on = false
		--vrayRend.lightcache_useForGlossyRays  = false
		--vrayRend.lightcache_subdivs  = 2000
		--vrayRend.lightcache_interpSamples  = 10				
		
		vrayRend.lightcache_loadFileName = ""
		vrayRend.lightcache_autosave = false
		vrayRend.lightcache_autosaveFileName = ""			
		vrayRend.options_dontRenderImage = false
		
		print ("number of eles pre delete " + re.NumRenderElements() as string)
		
		newElement = re.GetRenderElement (re.NumRenderElements()-1)
		re.RemoveRenderElement newElement
		
		print ("number of eles post delete " + re.NumRenderElements()  as string)
		
		for i = 0 to (re.NumRenderElements()-1) do 
		(
			(re.GetRenderElement i).vrayVFB = true
		)

		sphereMask  = bitmaptex()
		sphereMask.filename = rootnode.CA_frameOutput + currentCameraName +"\\"+ rootnode.CA_passDirectory + "\\" + "SphereMask.ifl"
		sphereMask.coords.mappingType = 1
		sphereMask.coords.mapping = 3
		sphereMask.name = "SphereMask"
		sphereMask.output.output_amount = 15
		
		vrayRend.imageSampler_renderMask_type = 1
		vrayRend.imageSamper_renderMask_texmap = sphereMask 
		for o in objects where o.gbufferchannel == 42 do (o.renderable = false)
		IsolateSelection.ExitIsolateSelectionMode()
		rendHidden = oldRenderHidden
		
		makedir (rootnode.CA_frameOutput + currentCameraName +"\\"+ rootnode.CA_passDirectory) 
		if extensionsList[rootnode.CA_extensionType] == ".exr" or extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" then exrSettings rootnode.CA_disableVFB
		else if extensionsList[rootnode.CA_extensionType] == ".exr (split)" then nonExrSettings ".exr"
		else nonExrSettings ""
		
		if rootnode.CA_latestDir == true then (AddCallbackLatest())
		if (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg" or rootnode.CA_SubmitMOV == true and SingleFrame != true) then (AddCallbackJPG())	
		
		
		SMTDSettings.JobName = "02.BF_ani__" + rootnode.CA_jobPrefix + "___" + currentCameraName
		SMTDSettings.Comment = "Scripted Spheres Mask Render Job"
		SMTDSettings.Priority = rootnode.CA_Priority
		SMTDSettings.ChunkSize = 1
		SMTDSettings.OverrideJobFailureDetection = false
		SMTDSettings.FailureDetectionJobErrors = 0
		SMTDSettings.LimitEnabled = false 
		SMTDSettings.MachineLimit = 0
		SMTDSettings.SlavesBlackList = true
		SMTDSettings.SlavesList = #()
		SMTDSettings.SubmitAsSuspended = false
		SMTDSettings.LimitGroups = #()
		SMTDSettings.LimitGroupsToUse= #()
		SMTDSettings.group = "frames"
		SMTDSettings.SequentialJob = false
		SMTDSettings.JobIsInterruptible = false
		SMTDSettings.RestartRenderer = true
		SMTDSettings.purifyFilenames = true
		SMTDSettings.IgnoreMissingXREFs = false
		SMTDSettings.ExtraInfoKeyValues = #(#("framerate",framerate))
		
		SMTDSettings.SubmitAsDependent = true
		SMTDSettings.DependOnPreviousJobMode = #last
		SMTDSettings.DependencyJobItems = #{1}

		local batchName = getProjectName()
		SMTDFunctions.SubmitJobFromUI batchName:batchName forceCamera:currentCameraName
		
		if rootnode.CA_latestDir == true then (callbacks.removescripts id:#copyLatest_callback)
		if (rootnode.CA_SubmitMOV == true) or (extensionsList[rootnode.CA_extensionType] == ".exr + .jpg") then (callbacks.removescripts id:#copyJPG_callback)
		
		if (rootnode.CA_SubmitMOV == true and SingleFrame != true) then
		(
			AutomaticFFmpegGeneration()						
		)
		SMTDSettings.group = "none"

	)--end animated_settings
	
--########################--	
--RENDER FUNCTIONS
--########################--
	
	fn FA_submission_fn camArray submissionType = 
	(
		getOldRPS()
		disableVrayLog()
		local hideCatCams = hideByCategory.cameras
		hideByCategory.cameras = true
		resetViewports()
		--not sure why this is here?
		--getOldEnvLayers()

		try(destroydialog cancelProcessRO)catch()
		createDialog cancelProcessRO parent:multiCamSubmitter.hwnd--escapeEnable:true --modal:true 

		local iterator = 0
		for i = 1 to camArray.count while (cancelProcessRO.cancelPreview_bn.checked == false and cancelProcessRO.open == true)  do ---while not keyboard.escPressed do
		(
			currentCameraName = camArray[i].name as string
			currentCamera = camArray[i]
			parseRangeFile currentCamera
			moveSuntoPoint()
			viewport.setCamera currentCamera
			
			case submissionType of
			(
				#noGI:nogi_settings begframe endframe
				#asIs:as_is_settings begframe endframe
				#bruteForce:bruteForce_settings begframe endframe
				#bruteForceSpheres:bruteForceSphere_settings begframe endframe
			)
			iterator += 1  
		)	--end for
		
		if cancelProcessRO.cancelPreview_bn.checked == true or iterator != camArray.count then 
		(
			local s = ""
			if iterator > 1 then s = "s"
			Messagebox ("Submission Cancelled after " + iterator as string + " camera"+ s +" submitted.")
		)

		setOldRPS()
		hideByCategory.cameras = hideCatCams
		
		destroydialog multiCamSubmitter
		setSaveRequired true

	)--end function FA_flythrough_fn
	
	fn FA_preview_fn camArray = 
	(
		getOldHideCats()
		displaySafeFrames = true
		autosave.Enable = false
		if (viewport.getLayout() != #layout_1) then ( max tool maximize) --maximize the viewport
		--cui.expertModeOn()  -- Views: Expert Mode Toggle
		clearSelection()
		--viewport.SetRenderLevel #smoothhighlights
		actionMan.executeAction 0 "550"  -- Views: Viewport Visual Style Shaded
		
		unregisterRedrawViewsCallback gwActiveSettings

		local notCancelled = true
		if ((rootnode.CA_previewOutputExt == ".mov" and doesfileexist avidDir and doesfileexist ffmpegExe) or (rootnode.CA_previewOutputExt == ".avi" and doesfileexist utvideoDir and doesfileexist ffmpegExe) or (rootnode.CA_previewOutputExt == ".jpg")) then
		(
			for i = 1 to camArray.count while notCancelled do
			(
				currentCameraName = camArray[i].name as string
				currentCamera = camArray[i]
				viewport.setCamera currentCamera

				parseRangeFile currentCamera
				
				if (rootnode.CA_previewOutputExt == ".jpg") then 
				(
					makedir (rootnode.CA_frameOutput + currentCameraName)
					notCancelled = preview_jpg()
				)
				else if (rootnode.CA_previewOutputExt == ".mov") then 
				(
					makedir ("C:\\tempPreview\\" + currentCameraName) 
					notCancelled = preview_mov()
					removeCommand = "RD " + "\"" + "C:\\tempPreview"  + "\"" + " /S /Q"
					DOSCommand (removeCommand)
				)
				else 
				(
					makedir ("C:\\tempPreview\\" + currentCameraName) 
					notCancelled = preview_avi()
					removeCommand = "RD " + "\"" + "C:\\tempPreview"  + "\"" + " /S /Q"
					DOSCommand (removeCommand)
				)
			)--end for
			
			if notCancelled then
			(
				if (rootnode.CA_previewOutputExt == ".mov" or rootnode.CA_previewOutputExt == ".avi") then
				(
					if queryBox "Exported mov file is on C:\\PreviewMOVs - Show in Explorer?" beep:false then (DOSCommand ("explorer.exe C:\\PreviewMOVs\\"))
				)
				else if (rootnode.CA_previewOutputExt == ".jpg") then
				(
					if queryBox ("Exported .jpg file sequence is on " + rootnode.CA_frameOutput + " - Show in Explorer?") beep:false then (DOSCommand ("explorer.exe " + rootnode.CA_frameOutput))
				)
			)
			destroydialog multiCamSubmitter
		)
		else 
		( 
			if (doesfileexist ffmpegExe) != true then ( if queryBox ("FFMPEG is missing!\nCheck the directory\n"+ffmpegExe+".\n\nDownload FFMPEG?\n") then (DOSCommand (("explorer " + "\"" + "https://ffmpeg.org/" + "\""))))

			if (rootnode.CA_previewOutputExt == ".mov") then ( if queryBox ("Avid codec is missing.\nDownload latest?\n") then (DOSCommand (("explorer " + "\"" + "http://avid.force.com/pkb/articles/en_US/download/Avid-QuickTime-Codecs-LE" + "\""))))
			else if (rootnode.CA_previewOutputExt == ".avi" and (doesfileexist utvideoDir == false)) then ( if queryBox ("UTVideo codec is missing.\nDownload latest?\n") then (DOSCommand (("explorer " + "\"" + "http://www.videohelp.com/software/Ut-Video-Codec-Suite" + "\""))))
		)
		
		--cui.expertModeOff()  -- Views: Expert Mode Toggle
		setOldHideCats()
		autosave.Enable = true
	)--end function FA_preview_fn
		
	fn FA_submission_diag_fn camArray = 
	(
		local diagJobSelector = openDiagnosticJobSelectorRO()
		
		if diagJobSelector != undefined then 
		(
			getOldRPS()
			disableVrayLog()
			local hideCatCams = hideByCategory.cameras
			hideByCategory.cameras = true
			resetViewports()
			--not sure why this is here?
			--getOldEnvLayers()

			try(destroydialog cancelProcessRO)catch()
			createDialog cancelProcessRO parent:multiCamSubmitter.hwnd--escapeEnable:true --modal:true 

			local iterator = 0
			for i = 1 to sceneCams.count while (cancelProcessRO.cancelPreview_bn.checked == false and cancelProcessRO.open == true)  do ---while not keyboard.escPressed do
			(
				currentCameraName = sceneCams[i].name as string
				currentCamera = sceneCams[i]
				parseRangeFile currentCamera
				moveSuntoPoint()
				viewport.setCamera currentCamera
		
				--#("Single: Turn off on layer per job" , "Recursive: Turn on half the layers per job" , "Cumulative: Turn on one additional layer per job" )
				case diagJobSelector[1] of
				(
					1: layersHideOneAtATime diagJobSelector[2] diagJobSelector[3]
					2: layersHideHalfAtATime diagJobSelector[2] diagJobSelector[3]
					3: layersSequentialUnhide diagJobSelector[2] diagJobSelector[3]
				)
				iterator += 1  
			)	--end for
			
			if cancelProcessRO.cancelPreview_bn.checked == true or iterator != sceneCams.count then 
			(
				local s = ""
				if iterator > 1 then s = "s"
				Messagebox ("Submission Cancelled after " + iterator as string + " camera"+ s +" submitted.")
			)

			setOldRPS()
			hideByCategory.cameras = hideCatCams
		)
		
		destroydialog multiCamSubmitter
		setSaveRequired true

	)--end function FA_flythrough_fn

--########################--
--ROLLOUT--
--########################--
	

	rollout multiCamSubmitter "MultiCam Submitter v.906.00" width:570 height:625
	(
	
		label JobPrefixLbl "Job Prefix:" pos:[24,18] width:56 height:18 tooltip:"Job prefix for the job name in Deadline, helps identify your jobs in the queue. Erase the text to set the Job prefix to the name of the file."
		editText jobPrefix_txt "" pos:[88,16] width:155 tooltip:JobPrefixLbl.tooltip
		label FileExtension "Ext:" pos:[280,18] tooltip:"File format of the render output, use tga for stills, exr or exr+jpg for animation, exr (split) if you want all passes as separate files but in exr format."
		dropDownList extSelection "" pos:[305,14] width:84 height:21 selection: rootnode.CA_extensionType items:extensionsList tooltip:FileExtension.tooltip
		button MLCLister_btn "Open MultiCam Lister" pos:[425,14] width:123 height:21 tooltip:"Opens the MultiCam camera lister"
		
		local groupWidth = 538
		local buttonSpace = 8
		local buttonN = 6 -- number of buttons in a row
		local buttonW = (groupWidth - 2*(2*buttonSpace) - (buttonN-1)*buttonSpace)/buttonN
		
		local nogi_tooltip = "Turns off GI and submits. Use to render masks, background pass."
		local asis_tooltip =	"Submits with the settings you have now, no change. Use for stills."
		local prvw_tooltip =	"Viewport preview, no submission. Use for animation previews."
		local bf_tooltip = "Sets primary to Brute Force, secondary to Light Cache, sets Light Cache preset to Animation. Use to render final animation."
		local bfs_tooltip = "Sets primary to Brute Force, secondary to Light Cache, sets Light Cache preset to Animation. 
Submits two passes one for sphere masks the other for rendering frames. To use create geometry spheres and assign object id 
42 and use like sphere fade sphere. Use to render patches or people pass."
		
		groupBox FrameOutGrp "Frames Output" pos:[16,48] width:groupWidth height:115
			radioButtons pathRootChoice "" pos:[32,65] enabled:true labels: outputPaths default:rootnode.CA_frameOutputType columns:1 tooltip:"Select a preset destination for you render output.
\nX:\\ProjectName for stills\nZ:\\ProjectName\\01_Frames for animation\n\nIf the project is not saved in the X: drive use the Custom option."
			--radioButtons pathRootChoice "" pos:[32,65] enabled:true labels: #("Y:\\RenderOutput\\Project\\", "Z:\\Project\\01_Frames\\", "Z:\\Project\\03_Previews\\", "Custom") default:rootnode.CA_frameOutputType columns:1
			button pathButton "..." pos:[50,130] enabled:false tooltip:"Set the Custom path for your render output."
			editText pathLable "" text:rootnode.CA_frameOutputCustom pos:[90,132] width:440 height:18 enabled:false tooltip:pathButton.tooltip
			
		groupBox PassTypeGrp "Pass Directory" pos:[16,172] width:groupWidth height:75
			radioButtons out_type "" pos:[32,188] height:176 enabled:true labels:#("Today's Date", "01_Sky", "02_Background", "03_Foreground", "04_PeopleCars", "Date+Custom", "06_Z-Depth", "07_ExtraPass02", "08_ExtraPass03", "Custom") \
			default:rootnode.CA_passDirectoryType columns:5 tooltip:"Choose a subdirectory for the render output. Use 'Today's Date' for stills images version control. User the other pass names for the animation output."
			editText customPassDate "" text:rootnode.CA_passDateCustom pos:[32,225] width:100 height:16 enabled:false
			editText customPass "" text:rootnode.CA_passCustom pos:[435,225] width:100 height:16 enabled:false
		
		groupBox ImageControlsGrp "Other Controls" pos:[16,255] width:groupWidth height:128
			--label IRnthLbl "IR nth Frame" pos:[32,275] width:64 height:16
			--spinner nthspinner "" pos:[101,275] width:48 height:16 enabled:true range:[1,100,rootnode.CA_IRNthFrame] type:#integer scale:1 	
			label FRnthLbl "Every Nth Frame" pos:[32,275] width:80 height:16 tooltip:"Render animation every # frame, default: 1"
			spinner fnthspinner "" pos:[121,275] width:48 height:16 enabled:true range:[1,100,rootnode.CA_FRNthFrame] type:#integer scale:1 tooltip:"Render animation every # frame, default: 1"	 
			label priority_lbl "Job Priority" pos:[32,305] width:64 height:16 tooltip:"Job priority in Deadline Queue, higher renders sooner, default: 50"
			spinner priority_spnr "" pos:[121,305] width:48 height:16 range:[1,97,rootnode.CA_Priority] type:#integer scale:1	tooltip:"Job priority in Deadline Queue, higher renders sooner, default: 50"
			
			button clearRend "Clear Render Paths" pos:[205,272] width:114 height:21 tooltip:"Clears output file paths from all render outputs, frame render and render elements."
			button repath_btn "Assing Render Paths" pos:[205,305] width:114 height:21 tooltip:"Reassings output file paths for all render outputs, frame render and render elements based on a chosen master path."
			radioButtons preview_type "Preview output file: " pos:[210,345] width:25 height:50 enabled:true labels:#("UT avi", "JPG") default:rootnode.CA_previewOutputExtType columns:2 tooltip:"Output file format and compression for animation viewport preview. Use UTVideo for animation previews, use JPG for still camera previews."--pos:[190,360] 

			checkbox submov_check "Submit ffmpeg job from frames" pos:[355,275] height:16 checked:rootnode.CA_SubmitMOV tooltip:"Submit a dependent job to compress output frames to a video file, good idea when rendering animations with exr output."
			checkbox latestDir_check "Copy Output to Latest Dir" pos:[355,302]  height:16 checked:rootnode.CA_LatestDir tooltip:"Copies the output image to the 'Latest' folder, good idea when doing a lot of itteration of the same stills."
			--checkbox z_check "Z-Depth as EXR" pos:[350,329] height:16
			checkbox singleOverride_check "Submit First Frame Only" pos:[355,329] height:16 tooltip:"Overrides frame range of the camera and submits the first frame only, good for lighting previews."
			checkbox vrfbDisplay_check "Disable VFB when rendering" pos:[355,356] height:16 checked:rootnode.CA_disableVFB tooltip:"Disable or Enables the display of the Vray Frame Buffer, disable to save more RAM."																																								   
		
		groupBox FAGrp "Submit: All Scene Cameras" pos:[16,400] width:groupWidth height:72
			button FA_pv_btn "Viewport Preview" width:buttonW height:32 enabled:false across:5 pos:[FAGrp.pos.x+(2*buttonSpace),FAGrp.pos.y+24] tooltip:prvw_tooltip --pos:[FA_as_is_btn.pos.x+buttonW+buttonSpace,FAGrp.pos.y+24] tooltip:prvw_tooltip
			button FA_nogi_btn "No GI" width:buttonW height:32 enabled:false across:5 pos:[FA_pv_btn.pos.x+buttonW+buttonSpace,FAGrp.pos.y+24] tooltip:nogi_tooltip
			button FA_as_is_btn "Current Settings (As Is)" width:buttonW height:32 enabled:false pos:[FA_nogi_btn.pos.x+buttonW+buttonSpace,FAGrp.pos.y+24] tooltip:asis_tooltip
			button FA_BF_btn "Brute Force Animation" width:buttonW height:32 enabled:false pos:[FA_as_is_btn.pos.x+buttonW+buttonSpace,FAGrp.pos.y+24] tooltip:bf_tooltip
			button FA_BFS_btn "Brute Force Spheres" width:buttonW height:32 enabled:false pos:[FA_BF_btn.pos.x+buttonW+buttonSpace,FAGrp.pos.y+24] tooltip:bfs_tooltip
			button FA_DIAG_btn "Diagnostic" width:buttonW height:32 enabled:false pos:[FA_BFS_btn.pos.x+buttonW+buttonSpace,FAGrp.pos.y+24]
		
		
		groupBox SaGrp "Submit: Per Camera" pos:[16,490] width:groupWidth height:120
			dropDownList camSelection_dd "Scene Cameras" width:344 height:40 items:sceneCamsNames enabled:true pos:[SaGrp.pos.x+(2*buttonSpace),SaGrp.pos.y+16] 
			checkbutton showCamSelector_btn "Select Cameras"  width:140 height:24 enabled:false pos:[camSelection_dd.pos.x+344+16,SaGrp.pos.y+32] 
			button SA_pv_btn "Viewport Preview"  width:buttonW height:32 enabled:false across:5 pos:[SaGrp.pos.x+(2*buttonSpace),camSelection_dd.pos.y+40] tooltip:prvw_tooltip
			button SA_nogi_btn "No GI"  width:buttonW height:32 enabled:false  pos:[SA_pv_btn.pos.x+buttonW+buttonSpace,camSelection_dd.pos.y+40] tooltip:nogi_tooltip
			button SA_as_is_btn "Current Settings (As Is)"  width:buttonW height:32 enabled:false pos:[SA_nogi_btn.pos.x+buttonW+buttonSpace,camSelection_dd.pos.y+40] tooltip:asis_tooltip
			button SA_BF_btn "Brute Force Animation"  width:buttonW height:32 enabled:false pos:[SA_as_is_btn.pos.x+buttonW+buttonSpace,camSelection_dd.pos.y+40] tooltip:bf_tooltip
			button SA_BFS_btn "Brute Force Spheres" width:buttonW height:32 enabled:false pos:[SA_BF_btn.pos.x+buttonW+buttonSpace,camSelection_dd.pos.y+40] tooltip:bfs_tooltip
			button SA_DIAG_btn "Diagnostic" width:buttonW height:32 enabled:false pos:[SA_BFS_btn.pos.x+buttonW+buttonSpace,camSelection_dd.pos.y+40] enabled:false

		
	fn updateFrameOut = 
	(
		if (maxfilename == "" or (filterstring maxfilepath "\\")[1] != "X:" or (filterstring maxfilepath "\\").count <= 1) then 
		(
			pathRootChoice.state = 4
			if (rootnode.CA_frameOutputCustom  == "" or frameout == "None Defined") then
			(	
				MessageBox ("File is not saved in the X:\\Projects directory, only Custom Frame Output option is available.") title:"File not saved in X:" beep:false
				pathLable.text = "None Defined"
				FA_nogi_btn.enabled = false 
				FA_as_is_btn.enabled = false 
				FA_pv_btn.enabled = true
				FA_BF_btn.enabled = false
				FA_BFS_btn.enabled = false
				FA_DIAG_btn.enabled = false
				showCamSelector_btn.enabled = false			
			) 
			else
			(
				--MessageBox "Save this file to the X:\\Projects directory first to use this option."
				pathLable.text = rootnode.CA_frameOutputCustom
				FA_nogi_btn.enabled = true 
				FA_as_is_btn.enabled = true 
				FA_pv_btn.enabled = true
				FA_BF_btn.enabled = true	
				FA_BFS_btn.enabled = true
				FA_DIAG_btn.enabled = true
				showCamSelector_btn.enabled = true	

			)
			pathButton.enabled = true
			print ("Root Directory is " + rootnode.CA_frameOutput  as string )
		)--end if
		else
		(
			FA_nogi_btn.enabled = true 
			FA_as_is_btn.enabled = true 
			FA_pv_btn.enabled = true
			FA_BF_btn.enabled = true
			FA_BFS_btn.enabled = true
			FA_DIAG_btn.enabled = true
			showCamSelector_btn.enabled = true	
			
			rootnode.CA_frameOutput = case pathRootChoice.state of 
			(
				1: (pathLable.text = ""; "X:\\" + projectName + "\\07_Production\\02_RawImageRender\\")
				2: (pathLable.text = ""; "Z:\\" + projectName+ "\\01_Frames\\" )
				3: (pathLable.text = ""; "Z:\\" + projectName + "\\03_Previews\\")
				4: (	pathButton.enabled = true
						if rootnode.CA_frameOutputCustom == "" or rootnode.CA_frameOutputCustom == "None Defined" then
						(
							pathLable.text = "None Defined"
							FA_nogi_btn.enabled = false 
							FA_as_is_btn.enabled = false 
							FA_pv_btn.enabled = true
							FA_BF_btn.enabled = false
							FA_BFS_btn.enabled = false
							FA_DIAG_btn.enabled = false
							showCamSelector_btn.enabled = false	
							""
						)
						else
						(
							pathLable.text = rootnode.CA_frameOutputCustom
							FA_nogi_btn.enabled = true 
							FA_as_is_btn.enabled = true 
							FA_pv_btn.enabled = true
							FA_BF_btn.enabled = true
							FA_BFS_btn.enabled = true
							FA_DIAG_btn.enabled = true
							showCamSelector_btn.enabled = true	
							rootnode.CA_frameOutputCustom
						)
					)
			)
			outputPaths = #("X:\\"+ projectName + "\\07_Production\\02_RawImageRender\\", \
				"Z:\\" + ProjectName + "\\01_Frames\\", \
				"Z:\\" + ProjectName + "\\03_Previews\\", "Custom")
			/*
			outputPaths = #("X:\\"+ projectName + "\\07_Production\\02_RawImageRender\\Camera Name\\" + rootnode.CA_passDirectory , \
				"Z:\\" + ProjectName + "\\01_Frames\\Camera Name\\" + rootnode.CA_passDirectory, \
				"Z:\\" + ProjectName + "\\03_Previews\\Camera Name\\" + rootnode.CA_passDirectory, "Custom")
			*/
			rootnode.CA_frameOutputType = pathRootChoice.state
			if (pathRootChoice.state != 4) then (pathButton.enabled = false)
			print ("Root Directory is " + rootnode.CA_frameOutput as string )
		)--end else
		
		if (out_type.state == 10) then (customPass.enabled = true)
		if (out_type.state == 6) then (customPassDate.enabled = true)	
	)-- end updateFrameOut
	
	fn clearRenderElementsPaths = 
	(
		if renderSceneDialog.isOpen() then renderSceneDialog.close()
		rendOutputFilename = ""
		re = maxops.getcurrenderelementmgr()
		ele_num = re.numrenderelements() as integer
		for i= 0 to (ele_num - 1) do
		(
			re.setrenderelementfilename i ""
		)	
	)
	
	fn repathRenderElements =
	(
		re = maxops.getcurrenderelementmgr()
		ele_num = re.numrenderelements() as integer
		for i= 0 to (ele_num - 1) do
		(
			this_ele = re.getrenderelement i 
			this_ele_name = this_ele.elementname as string
			save_path = rendoutputFilename 
			newpath = replace save_path  (save_path.count - 3) 1 ("__" + this_ele_name + ".")
			re.setrenderelementfilename i newpath
		)
	)
	
	on nthspinner changed n do
	(
		rootnode.CA_IRNthFrame = n
		print ("IR nth frame is " + rootnode.CA_IRNthFrame as string)
	)
	
	on fnthspinner changed n do
	(
		rootnode.CA_FRNthFrame = n
		print ("FR nth frame is " + rootnode.CA_FRNthFrame as string)
	)
	
	on priority_spnr changed n do
	(
		rootnode.CA_Priority = n
		print ("Priority is " + rootnode.CA_Priority as string)
	)
	
	on repath_btn pressed do
	(
		if renderSceneDialog.isOpen() then renderSceneDialog.close()
		if (rendOutputFilename != "") then (repathRenderElements())
		else 
		(
			try(rendOutputFilename = getSaveFileName caption: "Render Output File"  types:"Targa (*.tga)|*.tga|JPEG (*.jpg)|*.jpg|OpenEXR (*.exr)|*.exr"	
			repathRenderElements() ) catch()
		)
	)
		
  	on vrfbDisplay_check changed thestate do
	(
		rootnode.CA_disableVFB = thestate
	)
	on singleOverride_check changed thestate do
	(
		OverrideSingleFrame = singleOverride_check.state
	)
	
	on submov_check changed thestate do
	(
		rootnode.CA_SubmitMOV = thestate
	)
	
	on latestDir_check changed thestate do
	(
		rootnode.CA_latestDir = thestate
	)
	
	on clearRend pressed do
	(
		clearRenderElementsPaths()
	)
		
	on out_type changed state do 
	(
		rootnode.CA_passDirectory = case out_type.state of 
		(
			1: usetoday()
			2: "01_Sky"
			3: "02_Background"
			4: "03_Foreground"
			5: "04_PeopleCars"
			6: (
					customPassDate.enabled = true	
					rootnode.CA_passDirectory = useToday()
					rootnode.CA_passDateCustom = customPassDate.text
					rootnode.CA_passDirectory = rootnode.CA_passDirectory + rootnode.CA_passDateCustom
				)
			7: "06_Z-Depth"
			8: "07_ExtraPass02"
			9: "08_ExtraPass03"
			10: (
					customPass.enabled = true
					rootnode.CA_passCustom = customPass.text
					rootnode.CA_passDirectory = rootnode.CA_passCustom
				)
		)

		if (out_type.state != 10) then (customPass.enabled = false)
		if (out_type.state != 6) then (customPassDate.enabled = false)	
		rootnode.CA_passDirectoryType = out_type.state		
		print ("Pass Directory is " + rootnode.CA_passDirectory as string )
	)
	
	on preview_type changed state do 
	(
		rootnode.CA_previewOutputExt = case preview_type.state of
		(
			1:".avi"
			2:".jpg"
			3:".mov"
		)
		rootnode.CA_previewOutputExtType = preview_type.state
		print ("Preview Extension is " + rootnode.CA_previewOutputExt)
	)
	
	on multiCamSubmitter open do 
	( 
		jobPrefix_txt.text = rootnode.CA_jobPrefix
		updateFrameOut()
		--resetViewports()
		displaySafeFrames = true

		--if both are enabled
		if (getRenderType() != #view and vrayVFBGetRegionEnabled() == true) then
		(
			if (EditRenderRegion.IsEditing == true) do (EditRenderRegion.EditRegion() )
			local qb = yesNoCancelBox ("Warning, both Vray and Max render regions are ON!\n\n[ YES ]        Keep VRAY Region\n[ NO ]         Keep MAX Region\n[ CANCEL ] Disable BOTH") title:"Render Region"
			case qb of
			(
				#yes:(oldRenderRegion = getOldRenderRegion(); convertVrayRegionToMax()) --keep vray
				#no:(oldRenderRegion = getOldRenderRegion(); vrayVFBSetRegionEnabled false) --keep max
				#cancel:(disableAllRenderRegions()) --disable both
			)
		)
		--if one of them is enabled
		else if (getRenderType() != #view or vrayVFBGetRegionEnabled() == true) then
		(
			if (EditRenderRegion.IsEditing == true) do (EditRenderRegion.EditRegion() )
			if (queryBox  "Warning, render region is ON! Do you want to disable?" title:"Render Region") then
			(
				--yes, disable region render
				disableAllRenderRegions()
			)
			else
			(
				--no, keep region render on
				if vrayVFBGetRegionEnabled() == true then 
				(
					oldRenderRegion = getOldRenderRegion()
					convertVrayRegionToMax()
				)
				else 
				(
					oldRenderRegion = getOldRenderRegion()
				)
			)
		)

		unregisterRedrawViewsCallback gwActiveSettings
		registerRedrawViewsCallback gwActiveSettings

		callBacks.AddScript #systemPreReset "destroydialog multiCamSubmitter;unregisterRedrawViewsCallback gwActiveSettings" id:#MultiCamSubmitterDialog
		callBacks.AddScript #systemPreNew "destroydialog multiCamSubmitter;unregisterRedrawViewsCallback gwActiveSettings" id:#MultiCamSubmitterDialog
		callBacks.AddScript #filePreOpen "destroydialog multiCamSubmitter;unregisterRedrawViewsCallback gwActiveSettings" id:#MultiCamSubmitterDialog
		--callbacks.addScript #renderParamsChanged "renderParamsFN()" id:#MultiCamSubmitterDialog
		if SubmitterNodeEventCallback == undefined then	
		(
			SubmitterNodeEventCallback = NodeEventCallback mouseUp:true delay:500  added:SubmitterNodeEventSetUpdate nameChanged:SubmitterNodeEventSetUpdate deleted:SubmitterNodeEventSetUpdate callbackEnd:SubmitterNodeEventFN
		)
		else SubmitterNodeEventCallback.enabled = true
	)--end on buttons open
	
	on multiCamSubmitter close do
	(
		print ("Setting old res on close " + oldRenderRes as string)
		setRenderResolution oldRenderRes
		setHiddenLayers oldHideLayers
		setNonRenderLayers oldNonRenderLayers
		setEnvSettings oldEnvSettings
		setAnimation oldAnimationSettings
		setVFBSize oldRenderRes setOldRegion:oldRenderRegion

		try(destroydialog camChecklistRO)catch()
		try(destroydialog cancelProcessRO)catch()
		--try(DestroyDialog diagnosticJobSelectorRO)catch()
		
		callBacks.RemoveScripts id:#MultiCamSubmitterDialog
		if SubmitterNodeEventCallback != undefined then SubmitterNodeEventCallback.enabled = false
		
		--SubmitterNodeEventCallback = undefined
		unregisterRedrawViewsCallback gwActiveSettings
		--gc light:true
	)
	
	on extSelection selected i do
	(
		--old_state = z_var
		rootnode.CA_extension = extensions[i]
		if (i== 2 or i==3 or i==4) then 
		(
			--z_check.state = false
			--z_check.enabled = false
			--z_var = false
			rootnode.CA_extensionType = i
		)
		else 
		(
			--z_check.enabled = true
			--z_check.state = old_state
			--z_var = old_state
			rootnode.CA_extensionType = i
		)
		print ("Extension is " + rootnode.CA_extension)
	)

	on MLCLister_btn pressed do
	(
		macros.run "ilya_s Scripts" "MultiCamLister"
	)
	
	on camSelection_dd selected i do
	(
		if (camSelection_dd.selection != 1 and FA_as_is_btn.enabled == true) then
		(
				SA_nogi_btn.enabled = true 
				SA_as_is_btn.enabled = true	
				SA_pv_btn.enabled = true
				SA_BF_btn.enabled = true
				SA_BFS_btn.enabled = true
				SA_DIAG_btn.enabled = true	
		)
		else 
		(
				SA_nogi_btn.enabled = false 
				SA_as_is_btn.enabled = false
				SA_pv_btn.enabled = if camSelection_dd.selection != 1 then true else false
				SA_BF_btn.enabled = false
				SA_BFS_btn.enabled = false
				SA_DIAG_btn.enabled = false
		)
		
		if (camSelection_dd.selection != 1) then 
		(
			--currentCamera = getnodebyname sceneCamsNames[i]
			currentCamera = sceneCams[i-1]
			viewport.setCamera currentCamera

			--currentCameraName = sceneCamsNames[i] as string
			currentCameraName = currentCamera.name
			print ("Current camera is " + currentCameraName)
			parseRangeFile currentCamera
			moveSunToPoint()
		)
	)
	
	on pathLable entered txt do
	(
		rootnode.CA_frameOutputCustom = pathLable.text
		rootnode.CA_frameOutput = rootnode.CA_frameOutputCustom
		print ("Root Directory is " + rootnode.CA_frameOutput as string )
	)
	
	on customPass entered txt do
	(
		local checkPath = checkWindowsLegalPath txt
		if checkPath != undefined then 
		(
			Messagebox ("Illegal path name " + checkPath[1] + "\nProblem is " + checkPath[2]+"\nPlease re-enter path legal text.")
			customPass.text = ""
			rootnode.CA_passCustom = ""
			rootnode.CA_passDirectory = ""
		)
		else
		(
			rootnode.CA_passCustom = customPass.text
			rootnode.CA_passDirectory = rootnode.CA_passCustom
			print ("Pass Directory is " + rootnode.CA_passDirectory as string )
		)
	)
	
	on customPassDate entered txt do
	(
		rootnode.CA_passDirectory = useToday()
		local checkPath = checkWindowsLegalPath txt
		if checkPath != undefined then 
		(
			Messagebox ("Illegal path name " + checkPath[1] + "\nProblem is " + checkPath[2]+"\nPlease re-enter path legal text.")
			customPassDate.text = ""
			rootnode.CA_passDateCustom = ""
		)
		else 
		(
			rootnode.CA_passDateCustom = customPassDate.text
			rootnode.CA_passDirectory = rootnode.CA_passDirectory + rootnode.CA_passDateCustom
			print ("Pass Directory is " + rootnode.CA_passDirectory)
		)
	)
	
	on jobPrefix_txt entered txt do
	(
		if (txt != "") then
		(
			rootnode.CA_jobPrefix = jobPrefix_txt.text
		)
	
		if (txt == "") then (
			if maxfilename == "" then (rootnode.CA_jobPrefix = "Untitled")
			if maxfilename != "" then rootnode.CA_jobPrefix = (filterstring maxfilename ".")[1]
			jobPrefix_txt.text = rootnode.CA_jobPrefix
		)
		print ("Project Prefix is " + rootnode.CA_jobPrefix as string)
	)
		
	on pathRootChoice changed state do 
	(
		updateFrameOut()
	)
	
	on pathButton pressed do
	(
		try 
		(
			vrayRend.output_splitfilename = getBitmapSaveFileName  caption:"Click OK" filename:"Go to Dir an Click Save.tga"
			if true then
			(	
				rootnode.CA_frameOutput = getFilenamePath vrayRend.output_splitfilename
				rootnode.CA_frameOutputCustom = rootnode.CA_frameOutput
				pathLable.text = (rootnode.CA_frameOutputCustom)
				setUIElementEnabled true "FA_*"
				showCamSelector_btn.enabled = true
			)
		) 
		catch 
		(
			pathRootChoice.state = 4
			pathLable.text = "None Defined" 
			rootnode.CA_frameOutput = pathLable.text
			rootnode.CA_frameOutputCustom = rootnode.CA_frameOutput
			setUIElementEnabled false "FA_*"
			setUIElementEnabled false "SA_*"
			showCamSelector_btn.enabled = false
		)
	)

	on showCamSelector_btn changed state do
	(
		if state == true then
		(
			camSelection_dd.enabled = false	
			setUIElementEnabled false "FA_*"
			setUIElementEnabled true "SA_*"
			--showCamSelector_btn.enabled = true

			createdialog camChecklistRO style:#(#style_sysmenn) pos:[((GetDialogPos multiCamSubmitter).x) + 580,(GetDialogPos multiCamSubmitter).y + 0] parent:multiCamSubmitter.hwnd
		)
		else
		(
				destroydialog camChecklistRO
				camSelection_dd.enabled = true
				camSelection_dd.selection = 1
				
				setUIElementEnabled true "FA_*"
				setUIElementEnabled false "SA_*"
				--showCamSelector_btn.enabled = true	
		)
	)
		
	on FA_as_is_btn pressed do 
	(
		clearRenderElementsPaths()
		FA_submission_fn sceneCams #asIS
		--FA_as_is_fn()
	)
		
	on FA_nogi_btn pressed do
	(
		clearRenderElementsPaths()
		FA_submission_fn sceneCams #noGI
		--FA_nogi_fn()
	)
	on FA_pv_btn pressed do
	(
		FA_preview_fn sceneCams
	)
		
	on FA_bf_btn pressed do
	(
		clearRenderElementsPaths()
		FA_submission_fn sceneCams #bruteForce
		--FA_bruteForce_fn()
	)

	on FA_bfs_btn pressed do
	(
		clearRenderElementsPaths()
		FA_submission_fn sceneCams #bruteForceSpheres
		--FA_bruteForceSphere_fn()
	)
	
	on FA_Diag_btn pressed do
	(
		local submitJob = false
		if (sceneCams.count * LayerManager.count) > 25 then
		(
			local qb = queryBox ("About to submit " + (sceneCams.count * LayerManager.count) as string + " jobs.\nContinue?")
			if qb then submitJob = true
		)
		else
		(
			submitJob = true
		)
		
		if submitJob then
		(
			clearRenderElementsPaths()
			FA_submission_diag_fn sceneCams
			--FA_bruteForceSphere_fn()
		)
	)
	
	fn collectCamerasFromRO = 
	(
		local result = #()
		if (camChecklistRO.open == true) then 
		(
			for i=0 to (camChecklistRO.lv_objects.Items.Count - 1) where (camChecklistRO.lv_objects.Items.item[i].checked == true) do 
			(
				local objID = camChecklistRO.lv_objects.Items.item[i].SubItems.item[1].text as IntegerPtr
				append result (getAnimByHandle objID)
			)
		)
		else
		(
			result = #(currentCamera)
		)
		result
	)

	on SA_as_is_btn pressed do 
	(
		local camArray = collectCamerasFromRO()
		clearRenderElementsPaths()
		FA_submission_fn camArray #asIs
		--SA_as_is_fn()
	)
	
	on SA_nogi_btn pressed do
	(
		local camArray = collectCamerasFromRO()
		clearRenderElementsPaths()
		FA_submission_fn camArray #noGI
		--SA_nogi_fn()
	)
	
	on SA_pv_btn pressed do
	(
		local camArray = collectCamerasFromRO()
		FA_preview_fn camArray
	)
		
	on SA_bf_btn pressed do
	(
		local camArray = collectCamerasFromRO()
		clearRenderElementsPaths()
		FA_submission_fn camArray #bruteForce
		--SA_bruteForce_fn()
	)
	
	on SA_BFS_btn pressed do
	(
		local camArray = collectCamerasFromRO()
		clearRenderElementsPaths()
		FA_submission_fn camArray #bruteForceSpheres
		--SA_bruteForceSphere_fn()
	)
	
	on SA_Diag_btn pressed do
	(
		local camArray = collectCamerasFromRO()
		local submitJob = false
		if (camArray.count * LayerManager.count) > 25 then
		(
			local qb = queryBox ("About to submit " + (camArray.count * LayerManager.count) as string + " jobs.\nContinue?")
			if qb then submitJob = true
		)
		else
		(
			submitJob = true
		)
		
		if submitJob then
		(
			clearRenderElementsPaths()
			FA_submission_diag_fn camArray
		)
	)
	
	on genBatchButton pressed do
	(
		batch_gen_fn ()
	)
	
	on multiCamSubmitter moved pos do
	(
		--print (GetDialogPos multiCamSubmitter)
		try(SetDialogPos camChecklistRO [((GetDialogPos multiCamSubmitter).x) + 580,((GetDialogPos multiCamSubmitter).y) + 0])catch()
	)

	
	)--end submission rollout
	
	----------------------------------------------------------
	-- CAMERA SELECTION CHECKLIST ROLLOUT --
	----------------------------------------------------------
	
	rollout camChecklistRO "Camera Selector" width: 220
	(
		dotNetControl lv_objects "System.Windows.Forms.ListView" height:400
		button check_all "Check All" width:85 across: 2
		button uncheck_all "Uncheck All"  width:85 
					
		on check_all pressed do
		(
			for i=0 to (camChecklistRO.lv_objects.Items.Count - 1) do
			(
				camChecklistRO.lv_objects.Items.item[i].checked = true
			)
		)
		
		on uncheck_all pressed do
		(
			for i=0 to (camChecklistRO.lv_objects.Items.Count - 1) do
			(
				camChecklistRO.lv_objects.Items.item[i].checked = false
			)
		)
		
		on camChecklistRO open do 
		(
			lv_objects.GridLines = false  
			lv_objects.CheckBoxes = true
			lv_objects.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").Ascending
			lv_objects.HeaderStyle = (dotNetClass "System.Windows.Forms.ColumnHeaderStyle").NonClickable 
			lv_objects.View = (dotNetClass "System.Windows.Forms.View").Details
			lv_objects.FullRowSelect = true 
			lv_objects.HideSelection = false
			layout_def = #("Cameras","Obj")	 
			
			for i in layout_def do lv_objects.Columns.add i --96 --add column with name and optional width
			
			--fill in spreadsheet dotNet version
			ItemsArray = #() --array to collect the list items
			
			for o in sceneCams do
			(
				li = dotNetObject "System.Windows.Forms.ListViewItem" #(o.name, (GetHandleByAnim o) as string)
				append ItemsArray li
			)
			
			--when done, we populate the ListView
			lv_objects.Items.AddRange ItemsArray 
			lv_objects.columns.item[1].width=0
			lv_objects.columns.item[0].width=190
			lv_objects.Refresh()
		)
		
		on camChecklistRO close do 
		(
			for i=0 to (camChecklistRO.lv_objects.Items.Count - 1) do
			(
				camChecklistRO.lv_objects.Items.item[i].checked = false
			)
		)
	)
	
	rollout cancelProcessRO "Cancel Process" width: 220 --modal:true
	(
		checkbutton cancelPreview_bn "Cancel"
		
		on cancelPreview_bn changed state do 
		(
			if state == true then
			(
				cancelPreview_bn.text = "Cancelling..."
				cancelPreview_bn.enabled = false
			)
		)
	)
		
	on execute do 
	(
		local errorCheck = false
		
		while errorCheck != true do
		(
			vrayRend = renderers.current
			
			if(vrayRend != undefined) then 
			(
				if ((vrayRend.classid[1] == 1941615238) and (vrayRend.classid[2] == 2012806412)) != true then
				(
					MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
					exit
				)
			) 
			else 
			(
				MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
				exit
			)
			
			--try to load the submitter modifier
			if multiCamUsable != true then
			(
				MessageBox ("MultiCam Lister is not usable, check MAXScript Listener to make sure all MultiCam assets are loaded correctly.") title:"Missing MultiCam Assets"
				exit
			)

			if (doesfileexist (systemTools.getEnvVariable "deadline_path")) != true then
			(
				MessageBox ("Deadline Client is not installed or DEADLINE_PATH Environment variable is not configured on this machine") title:"Deadline Error"
				exit
			)

			if (doesfileexist (DeadlineRoot + "\\settings\\repository.ini")) != true then
			(
				MessageBox ("Deadline Repository cannot be found at path\n"+(DeadlineRoot + "\\settings\\repository.ini")) title:"Deadline Error"
				exit
			)
				
			print ("Using " + vrayRend as string +" to render.")
			
			setBitmapIOClasses()
			FFmpegExe = DeadlineRoot + "\\custom\\submission\\FFmpeg\\bin\\ffmpeg.exe"
			UnixDeadlineRoot = substituteString DeadlineRoot @"\" "/"
			sceneCams = for o in cameras where (superclassof o == camera) collect o
			
			local nameProblems = #()
			for cam in sceneCams do
			(
				local checkName = checkWindowsLegalPath cam.name
				if checkName != undefined then (append nameProblems checkName )
			)

			if nameProblems.count != 0 then
			(
				local problemString = "Found naming issues in the following cameras:\n\n"
				for i=1 to nameProblems.count do
				(
					problemString = problemString + nameProblems[i][1] + " - problem is " + nameProblems[i][2] + "\n" 
				)
				Messagebox (problemString) title:"Camera Name Problem"
				exit
			)

			qsort sceneCams compareByObjectName
			sceneCamsNames = for o in sceneCams collect (toLower o.name)
			sceneCamsNames = makeUniqueArray sceneCamsNames
			
			if sceneCamsNames.count != sceneCams.count then 
			(
				MessageBox ("There are " + (sceneCams.count - sceneCamsNames.count + 1) as string + " cameras with the same name in the scene. Rename or delete these cameras and rerun the script.") title:"Duplicate Cameras"
				exit
			)
			
			print ("Found " + sceneCams.count as string + " cameras in the scene.")
			local spacer = #("Select Camera to Render")
			sceneCamsNames = join spacer sceneCamsNames
			
			vraySuns = for o in lights where (classof o == VRaySun) collect o
			
			if vraySuns.count > 1 then 
			(
				MessageBox ("There are " + (vraySuns.count) as string + " VRaySuns in the scene. There can only be one.") title:"Duplicate vraySuns"
				exit
			)

			getOldEnvLayers()
			oldAnimationSettings = getAnimation()
			print ("Old animation settings are " + oldAnimationSettings as string)
			
			projectName = getProjectName()
			if projectName != "Project Noname" then 
			(
				outputPaths = #("X:\\"+ projectName + "\\07_Production\\02_RawImageRender\\", "Z:\\" + ProjectName + "\\01_Frames\\", "Z:\\" + ProjectName + "\\03_Previews\\", "Custom")
			)
			else 
			(
				outputPaths = #("X:\\ProjectName\\07_Production\\02_RawImageRender\\", "Z:\\ProjectName\\01_Frames\\", "Z:\\ProjectName\\03_Previews\\", "Custom")
			)
			
			print ("Project name is " + projectName)
			
			--------------------------------------
			---Deadline Load Submitter script	
			--------------------------------------		
			
			local remoteScript = DeadlineRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms"  
			local localScript = getDir #scripts + "\\SubmitMaxToDeadline_Functions.ms"
			
			if (doesFileExist remoteScript) then
			(
				if (isDirectoryWriteable (getDir #scripts)) == true then
				(
					if ((doesFileExist localScript)==true) then
					(					
						if ( getFileModDate remoteScript > getFileModDate localScript ) then 
						(
							deleteFile localScript
							copyFile remoteScript localScript
							print "Old Functions Script is deleted."
							print "New Functions Script is updated."
							fileIn localScript
							SMTDFunctions.loadSettings()
						)
					)
					else 
					(
						print "No local script found, copied the remote script"
						copyFile remoteScript localScript
					)
					
					if SMTDFunctions == undefined then
					(
						fileIn localScript
						SMTDFunctions.loadSettings()
						print "No script update, running localy."
					)
				)
				else
				(
					fileIn remoteScript
					print "Scripts folder is not accessable, running remotely."
					SMTDFunctions.loadSettings()
				)
			)
			else (Messagebox "Can't find remote script, check the Deadline Repository path.")
			
			
			if DeadlineSlaves == undefined then CollectDeadlineSlaves()
			SMTDSettings.WarnAboutMissingExternalFiles = false
			SMTDSettings.PerformSanityCheck = false
			
			-- test and initialize custom attribute
			-- change version only if CA name is changed/added/removed, default values can be changed regardless of the version
			CA_CurrentVersion = 0.83
			sceneCustomAttributes = rootnode.custAttributes
			
			--check the version of the CA , delete if old or if has no version
			if (sceneCustomAttributes["MultiCamDef"] != undefined) then
			(
				if (try (rootnode.CA_Version)catch()) != undefined then
				(
					if rootnode.CA_Version < CA_CurrentVersion then
					(
						deleteItem sceneCustomAttributes "MultiCamDef"
					)
				)
				else if (try (rootnode.CA_Version)catch()) == undefined then
				(
					deleteItem sceneCustomAttributes "MultiCamDef"
				)
			)
			
			if sceneCustomAttributes["MultiCamDef"] == undefined or (custAttributes.count rootnode)==0 then 
			(
				MultiCamCA = attributes "MultiCamDef"
				(
					parameters main
					(	
						CA_Version type:#float default:0.0
						CA_jobPrefix type:#string default:""
						CA_extension type:#string default:".tga"
						CA_extensionType type:#integer default:1
						CA_frameOutputType type:#integer default:1
						CA_frameOutputCustom type:#string default:""
						CA_frameOutput type:#string default:""
						CA_passDirectoryType type:#integer default:1
						CA_passDirectory type:#string default:""
						CA_passDateCustom type:#string default:""
						CA_passCustom type:#string default:""
						CA_IRNthFrame type:#integer default:5
						CA_FRNthFrame type:#integer default:1
						CA_previewOutputExtType type:#integer default:1
						CA_previewOutputExt type:#string default:".avi"
						CA_Priority type:#integer default:50
						CA_LatestDir type:#boolean default:false
						CA_SubmitMOV type:#boolean default:false
						CA_disableVFB type:#boolean default:false
					)
				)
				custAttributes.add rootnode MultiCamCA 
				
				if (maxfilename == "") then (rootnode.CA_jobPrefix = "Untitled") else (rootnode.CA_jobPrefix = (filterstring maxfilename ".")[1])
				rootnode.CA_passDirectory = useToday()
				rootnode.CA_Version = CA_CurrentVersion
			)
			
			rootnode.CA_passDirectory = case rootnode.CA_passDirectoryType of 
			(
				1: usetoday()
				2: "01_Sky"
				3: "02_Background"
				4: "03_Foreground"
				5: "04_PeopleCars"
				6: (
						rootnode.CA_passDirectory = useToday()
						rootnode.CA_passDirectory = rootnode.CA_passDirectory + rootnode.CA_passDateCustom
					)
				7: "06_Z-Depth"
				8: "07_ExtraPass02"
				9: "08_ExtraPass03"
				10: rootnode.CA_passDirectory = rootnode.CA_passCustom
			)
			
			try(destroydialog multiCamSubmitter;destroydialog camChecklistRO)catch()
			createDialog multiCamSubmitter
			errorCheck = true
		)
	) --end execute
)-- The End