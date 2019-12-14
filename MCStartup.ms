-------------------------------------------------------------------------------
-- MCStartup.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2018
-- Loads all the neccessary assets for MultiCam Suite of scripts
-------------------------------------------------------------------------------

--global multiCamRepo = @"X:\00-000_ScriptTest\scripts\MultiCamRepo\"
--global DeadlineRoot = @"\\fs-01\DeadlineRepository10"
--global multiCamHDRILibrary = @"Y:\Maps\HDRI\MultiCamHDRI\"

global DeadlineRoot = @"C:\DeadlineRepository10"
global multiCamRepo = @"C:\temp\Repo\"
global multiCamHDRILibrary = @"C:\temp\Repo\MultiCamHDRI\"

multiCamUsable = false

global drCreateNewCam,drDeleteNewCam,getHideCamsCategory,setHideCamsCategory
global multiCamHideCams = false
global multiCamPrerenderSelection

fn getHideCamsCategory = (multiCamHideCams = hideByCategory.cameras;multiCamPrerenderSelection = selection as array)
fn setHideCamsCategory = (hideByCategory.cameras = multiCamHideCams;select multiCamPrerenderSelection)

fn drCreateNewCam = 
(
	local vr = renderers.current	
	if(vr != undefined) then 
	(
		if ((vr.classid[1] == 1941615238) and (vr.classid[2] == 2012806412)) == true then
		(
			if vr.system_distributedRender == true then
			(
				if viewport.getCamera() != undefined then 
				(
					if (viewport.getCamera()).modifiers.count != 0 then
					(
						global newTempCamera = copy (viewport.getCamera())
						for i = newTempCamera.modifiers.count to 1 by -1 do
						(
							deleteModifier newTempCamera i
						)
						viewport.setCamera newTempCamera
					)
				)
			)
		)
	) 
)

fn drDeleteNewCam = 
(
	try(delete newTempCamera)catch()
)

fn checkMacroLocalDir = 
(
	local result = false
	local localDir = (getDir #scripts + "\\MultiCam\\")
	if doesFileExist localDir != true then
	(
		local md = makeDir localDir
		if md == true then
		(
			print ("INFO: Created MultiCam directory in " + localDir)
			result = true
		)
		else (result = false)
	)
	else
	(
		print ("INFO: Directory MultiCam is already existing.")
		result = true
	)
	return result
)

fn checkMacro macro =
(
	local update = false
	local localScript = (getDir #scripts + "\\MultiCam\\" + macro + ".ms")
	local remoteScript = ((getfiles (multiCamRepo + macro + "*.ms")))[(getfiles (multiCamRepo + macro + "*.ms")).count]
	
	print ("--------------- Info for Macro: "+macro+" ---------------")
	
	if ((doesFileExist localScript)==true) then
	(					
		print ("INFO: Local file for macro "+macro+" is found.")
		
		if (doesFileExist remoteScript) then 
		(
			print ("INFO: Remote file for macro "+macro+" is found.")
			
			--ISSUE: getFileModDate comparison is flawed, can't compare dates that way, use dotnet instead
			if ( ( ( (dotnetclass "System.IO.File").GetLastWriteTime(remoteScript) ).ticks) > (((dotnetclass "System.IO.File").GetLastWriteTime(localScript)).ticks) ) then 
			(
				print ("INFO: Update to "+macro+" is found.")
				
				if (isDirectoryWriteable (getDir #scripts)) == true then
				(
					print ("INFO: Local scripts directory is writable.")
					local d = deleteFile localScript
					
					if d ==  true then
					(
						print ("INFO: Deleted local macro "+macro+" successfully.")
						local c = copyFile remoteScript localScript
						if (c==true) then 
						(
							print ("INFO: Update to "+macro+" is successful, loading new macro")
							try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
						) 
						else
						(
							MessageBox ("ERROR: Macro "+macro+" was delete but failed to copy.\nCopy macro"+macro+" to "+(getDir #scripts + "\\MultiCam\\")as string+" manually.")
							false
						)
					)
					else
					(
						print ("ERROR: Failed to delete local macro "+macro+". Update failed, loading local.")
						try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
					)
					
				)
				else
				(
					print ("ERROR: Update to macro "+macro+" failed, scripts directory is not writable. Loading local.")
					try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
				)
			)
			else
			(
				print ("INFO: Last update to local script "+macro+" was done on " + (( ( (dotnetclass "System.IO.File").GetLastWriteTime(localScript) ).ticks)) as string)
				print ("INFO: Last update to remote script "+macro+" was done on " + (( ( (dotnetclass "System.IO.File").GetLastWriteTime(remoteScript) ).ticks)) as string)
				print ("INFO: No update for macro "+macro+" is available, loading local.")
				try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
			)
		)
		else
		(
			print ("INFO: No remote file for macro "+macro+" found. Loading local.")
			try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
		)
	)
	else
	(
		print ("INFO: Local file for macro "+macro+" does is not found, trying to load remote file.")
		if (doesFileExist remoteScript) then 
		(
			print ("INFO: Remote file for macro "+macro+" is found.")
			if (isDirectoryWriteable (getDir #scripts)) == true then
			(
				print ("INFO: Local scripts directory is writable.")
				local c = copyFile remoteScript localScript
				if (c == true) then 
				(
					print ("INFO: Copied macro "+macro+" to local location, loading new macro.")
					try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
				)
				else
				( 
					print ("ERROR: Copy of macro "+macro+" failed, error in script.")
					false
				)
			)
			else
			(
				MessageBox ("ERROR: Failed to load macro "+macro+", scripts directory is not writable!")
				false
			)
		)
		else
		(
			MessageBox ("ERROR: No remote file for macro "+macro+" found!")
			false
		)
	)
)

fn addMCCallbacks = 
(
	result = false
	callbacks.removeScripts id:#MCPrerender
	callbacks.removeScripts id:#MCpostrender
	preRend = callbacks.addScript #preRender ("enableSceneRedraw();getHideCamsCategory();hideByCategory.cameras = true;completeRedraw();drCreateNewCam()") id:#MCPrerender
	postRend = callbacks.addScript #postRender("setHideCamsCategory();drDeleteNewCam()") id:#MCPostrender
	
	print ("--------------- Info for MultiCam Callbacks ---------------")
	print ("INFO: MultiCam preRender callback is " + preRend as string )
	print ("INFO: MultiCam postRender callback is " + postRend as string)

	if (preRend == OK and postRend == OK) then
	(
		result = true
	)
	
	result
)

MD = checkMacroLocalDir()
MCHDlib = checkMacro "MultiCamHDRILibrary"
MCA = checkMacro "MultiCamAttribute"
MCL = checkMacro "MultiCamLister"
MCS = checkMacro "MultiCamSubmitter"

MCCB = addMCCallbacks()

if (MCL == true and MCA == true and MCS == true and MCCB == true and MD == true and MCHDlib==true) then
(
	multiCamUsable = true
	print ("--------------- Info for MultiCam Suite ---------------")
	print ("INFO: MultiCam is usable.")
)
else
(
	print ("--------------- Info for MultiCam Suite ---------------")
	print ("ERROR: MultiCam is NOT usable.")
	print ("INFO: MultiCamLister usable is: " + MCL as string)
	print ("INFO: MultiCamAttribute usable is: " + MCA as string)
	print ("INFO: MultiCamSubmitter usable is: " + MCS as string)
	print ("INFO: MultiCamHDRILibrary usable is: " + MCHDlib as string)
	MessageBox ("MulticCam is not usable, check MAXScript Listener.")
)
--callbacks.removeScripts id:#MCPrerender
--callbacks.show #preRender 