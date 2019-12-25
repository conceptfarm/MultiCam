-------------------------------------------------------------------------------
-- MCStartup.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2018
-- Loads all the neccessary assets for MultiCam Suite of scripts
-------------------------------------------------------------------------------

--global multiCamRepo = @"X:\00-000_ScriptTest\scripts\MultiCamRepo\"
--global DeadlineRoot = @"\\fs-01\DeadlineRepository10"
--global multiCamHDRILibrary = @"Y:\Maps\HDRI\MultiCamHDRI\"

--DEADLINE_PATH = C:\Program Files\Thinkbox\Deadline10\bin
--%PROGRAMDATA%\Thinkbox\Deadline[VERSION]\deadline.ini
--NetworkRoot=C:/DeadlineRepository10
global DeadlineRoot = @"C:\DeadlineRepository10"

print ("current dir is " + getThisScriptFilename() )

global multiCamRepo = @"C:\temp\Repo\"
global multiCamHDRILibrary = multiCamRepo + "MultiCamHDRI\\"



multiCamUsable = false

--global drCreateNewCam,drDeleteNewCam,getHideCamsCategory,setHideCamsCategory
--global multiCamHideCams = false
--global multiCamPrerenderSelection

fn checkINIEncode iniFile = 
(
	--check if the first character in file is BOM character
	--getINISettings will fail on non-ASCII encoding
	local result = undefined
	local fBinary = fopen iniFIle "rb"
	fseek fBinary 0 #seek_set
	if ((ReadByte fBinary) < 0) then (result = false)
	else (result = true)
	fclose fBinary
	result
)

fn getTimeNow =
(	
	local result = ""
	local timenow = getlocaltime()
	for i = 1 to timenow.count do (result = result + timenow[i] as string + "_")
	result = substring result 1 (result.count - 1)
	result
)

fn reEncodeINIFile iniFile = 
(
	local result = undefined
	local timeNow = getTimeNow()
	local rn = renamefile iniFile (iniFile + "_" + timeNow)
	if rn == true then
	(
		try
		(
			local oldINI  = openFile  (iniFile + "_" + timeNow) mode:"r" writeBOM:false
			local newINI = openFile iniFile mode:"w" writeBOM:false
			while not eof oldINI do
			(
				local s = readLine oldINI
				format s to:newINI
				format "\n" to:newINI
			)
			flush oldINI
			flush newINI
			close oldINI
			close newINI
			free oldINI
			free newINI
			result = true
		)catch (result = undefined)
	)
	result
)


fn getDeadlineRoot =
(
	local result = undefined
	local deadlinePath = systemTools.getEnvVariable "DEADLINE_PATH"
	local deadlineVersionPath = pathConfig.removePathLeaf deadlinePath
 	deadlineVersionPath = pathConfig.stripPathToLeaf deadlineVersionPath
 	local deadlineINI = (systemTools.getEnvVariable "PROGRAMDATA") + "\\Thinkbox\\" + deadlineVersionPath + "\\deadline.ini"
	if (doesFileExist deadlineINI) then
	(
		if (checkINIEncode deadlineINI) == false  then
		(
			local reEncode = reencodeINIFile deadlineINI
			if reEncode == true then result = getINISetting deadlineINI "Deadline" "NetworkRoot"
			if (result == "" or (doesfileexist result) != true ) then result = undefined
		)
		else 
		(
			result = getINISetting deadlineINI "Deadline" "NetworkRoot"
			if (result == "" or (doesfileexist result) != true ) then result = undefined
		)
	)
 	result
)

fn checkLocalDir localDir = 
(
	local result = false
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
		print ("INFO: Directory "+localDir+" already exists.")
		result = true
	)
	result
)

fn loadIcons =
(
	local result = false
	local iconCopyError = false
	local localDirs = #((getDir #ui_ln + "IconsDark"),(getDir #ui_ln + "Icons"))
	local remoteIcons = (getfiles (multiCamRepo + "icons\\MultiCam*.bmp"))
	
	for dir in localDirs while iconCopyError == false do
	(
		iconCopyError = not (checkLocalDir dir)

		for ico in remoteIcons do 
		(
			local localIcon = dir + "\\" + (pathConfig.stripPathToLeaf ico)
			print ("--------------- Info for Macro: "+ico+" ---------------")
			if (doesFileExist localIcon ) then
			(					
				print ("INFO: Local file for icon "+ico+" is found in" + dir)
				
				if (doesFileExist ico) then 
				(
					print ("INFO: Remote file for icon "+ico+" is found.")
					
					--ISSUE: getFileModDate comparison is flawed, can't compare dates that way, use dotnet instead
					if ( ( ( (dotnetclass "System.IO.File").GetLastWriteTime(ico) ).ticks) > (((dotnetclass "System.IO.File").GetLastWriteTime(localIcon)).ticks) ) then 
					(
						print ("INFO: Update to "+ico+" is found.")
						
						if (isDirectoryWriteable dir) == true then
						(
							print ("INFO: Local icons directory is writable.")
							local d = deleteFile localIcon
							
							if d ==  true then
							(
								print ("INFO: Deleted local icon "+ico+" successfully.")
								local c = copyFile ico localIcon
								if (c==true) then 
								(
									print ("INFO: Update to "+ico+" is successful, loading new icon")
									--try(execute (openfile localIcon);print("INFO: Loaded icon "+icon+" successfully.");true)catch(print ("ERROR: Loading of icon "+icon+" failed, error in script.");false)
								) 
								else
								(
									MessageBox ("ERROR: Macro "+icon+" was delete but failed to copy.\nCopy icon"+ico+" to "+ dir +" manually.")
									iconCopyError = true
								)
							)
							else
							(
								print ("ERROR: Failed to delete local icon "+ico+". Update failed, loading local.")
								--try(execute (openfile localIcon);print("INFO: Loaded icon "+icon+" successfully.");true)catch(print ("ERROR: Loading of icon "+icon+" failed, error in script.");false)
							)
							
						)
						else
						(
							print ("ERROR: Update to icon "+ico+" failed, scripts directory is not writable. Loading local.")
							--try(execute (openfile localIcon);print("INFO: Loaded icon "+icon+" successfully.");true)catch(print ("ERROR: Loading of icon "+icon+" failed, error in script.");false)
						)
					)
					else
					(
						print ("INFO: Last update to local script "+ico+" was done on " + (( ( (dotnetclass "System.IO.File").GetLastWriteTime(localIcon) ).ticks)) as string)
						print ("INFO: Last update to remote script "+ico+" was done on " + (( ( (dotnetclass "System.IO.File").GetLastWriteTime(ico) ).ticks)) as string)
						print ("INFO: No update for icon "+ico+" is available, loading local.")
						--try(execute (openfile localIcon);print("INFO: Loaded icon "+icon+" successfully.");true)catch(print ("ERROR: Loading of icon "+icon+" failed, error in script.");false)
					)
				)
				else
				(
					print ("INFO: No remote file for icon "+ico+" found. Loading local.")
					--try(execute (openfile localIcon);print("INFO: Loaded icon "+icon+" successfully.");true)catch(print ("ERROR: Loading of icon "+icon+" failed, error in script.");false)
				)
			)
			else
			(
				print ("INFO: Local file for icon "+ico+" is not found, trying to load remote file.")
				if (doesFileExist ico) then 
				(
					print ("INFO: Remote file for icon "+ico+" is found.")
					if (isDirectoryWriteable dir) == true then
					(
						print ("INFO: Local icon directory is writable.")
						local c = copyFile ico localIcon
						if (c == true) then 
						(
							print ("INFO: Copied icon "+ico+" to local location, loading new icon.")
							--try(execute (openfile localIcon);print("INFO: Loaded icon "+icon+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed, error in script.");false)
						)
						else
						( 
							print ("ERROR: Copy of icon "+ico+" failed, error in script.")
							iconCopyError = true
						)
					)
					else
					(
						MessageBox ("ERROR: Failed to load icon "+ico+", "+dir+ " directory is not writable!")
						iconCopyError = true
					)
				)
				else
				(
					MessageBox ("ERROR: No remote file for icon "+ico+" found!")
					iconCopyError = true
				)
			)
		)
	)
	
	try 
	(
		if iconCopyError == false then
		(
			global MCiconImg = openBitMap ((getDir #ui_ln) + "iconsDark\\MultiCamIcons.bmp")
			global MCiconImgMask = openBitMap ((getDir #ui_ln) + "iconsDark\\MultiCamIconsMask.bmp")

			global MCiconImgSq = openBitMap ((getDir #ui_ln) + "iconsDark\\MultiCamSq_24i.bmp")
			global MCiconImgSqMask = openBitMap ((getDir #ui_ln) + "iconsDark\\MultiCamSq_24a.bmp")
			result = true
		)
	)catch (result = false)
	result
)


fn loadMacro macro =
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

/*
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
*/

fn nullVariables = 
(

)

DeadlineRoot = getDeadlineRoot()

if DeadlineRoot != undefined then
(
	MCIco = loadIcons()
	MD = checkLocalDir (getDir #scripts + "\\MultiCam\\")
	MCHDlib = loadMacro "MultiCamHDRILibrary"
	MCA = loadMacro "MulitCamAttributeCA"
	MCL = loadMacro "MultiCamLister"
	MCS = loadMacro "MultiCamSubmitter"

	--MCCB = addMCCallbacks()

	if (MCIco == true and MCL == true and MCA == true and MCS == true and MD == true and MCHDlib==true and DeadlineRoot != undefined) then
	(
		multiCamUsable = true
		print ("--------------- Info for MultiCam Suite ---------------")
		print ("INFO: MultiCam is usable.")
		MCIco = undefined
		MD = undefined
		MCHDlib = undefined
		MCA = undefined
		MCL = undefined
		MCS = undefined
	)
	else
	(
		print ("--------------- Info for MultiCam Suite ---------------")
		print ("ERROR: MultiCam is NOT usable.")
		print ("INFO: MultiCamLister usable is: " + MCL as string)
		print ("INFO: MultiCamAttribute usable is: " + MCA as string)
		print ("INFO: MultiCamSubmitter usable is: " + MCS as string)
		print ("INFO: MultiCamHDRILibrary usable is: " + MCHDlib as string)
		print ("INFO: DeadlineRoot is: " + DeadlineRoot as string)
		MessageBox ("MulticCam is not usable, check MAXScript Listener.")
		MCIco = undefined
		MD = undefined
		MCHDlib = undefined
		MCA = undefined
		MCL = undefined
		MCS = undefined
	)
)
else
(
	print ("INFO: DeadlineRoot is: " + DeadlineRoot as string)
	MessageBox ("MulticCam is not usable, Deadline Repository Root not found")
)
--callbacks.removeScripts id:#MCPrerender
--callbacks.show #preRender 