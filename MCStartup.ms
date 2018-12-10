-------------------------------------------------------------------------------
-- MCStartup.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2001
-- Loads all the neccessary assets for MultiCam Suite of scripts
-------------------------------------------------------------------------------

multiCamRepo = @"C:\temp\Repo\"
--multiCamRepo = @"X:\00-000_ScriptTest\scripts\MultiCamRepo\"
multiCamUsable = false

fn checkMacro macro =
(
	local update = false
	local localScript = (getDir #scripts + "\\MultiCam\\" + macro + ".ms")
	local remoteScript = ((getfiles (multiCamRepo + macro + "*.ms")))[(getfiles (multiCamRepo+ macro + "*.ms")).count]
	
	print ("--------------- Info for Macro: "+macro+" ---------------")
	
	if ((doesFileExist localScript)==true) then
	(					
		print ("INFO: Local file for macro "+macro+" is found.")
		if (doesFileExist remoteScript) then 
		(
			print ("INFO: Remote file for macro "+macro+" is found.")
			
			if (getFileModDate remoteScript > getFileModDate localScript ) then 
			(
				print ("INFO: Update to "+macro+" is found.")
				
				if (isDirectoryWriteable (getDir #scripts)) == true then
				(
					print ("INFO: Local scripts directory is writable.")
					d = deleteFile localScript
					
					if d ==  true then
					(
						print ("INFO: Deleted local macro "+macro+" successfully.")
						c = copyFile remoteScript localScript
						if (c==true) then 
						(
							print ("INFO: Update to "+macro+" is successful, loading new macro")
							try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed for some reason.");false)
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
						try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed for some reason.");false)
					)
					
				)
				else
				(
					print ("ERROR: Update to macro "+macro+" failed, scripts directory is not writable. Loading local.")
					try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed for some reason.");false)
				)
			)
			else
			(
				print ("INFO: No update for macro "+macro+" is available, loading local.")
				try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed for some reason.");false)
			)
		)
		else
		(
			print ("INFO: No remote file for macro "+macro+" found. Loading local.")
			try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed for some reason.");false)
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
				c = copyFile remoteScript localScript
				if (c==true) then 
				(
					print ("INFO: Copied macro "+macro+" to local location, loading new macro.")
					try(execute (openfile localScript);print("INFO: Loaded macro "+macro+" successfully.");true)catch(print ("ERROR: Loading of macro "+macro+" failed for some reason.");false)
				)
				else
				( 
					print ("ERROR: Copy of macro "+macro+" failed for some reason.")
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

MCL = checkMacro "MultiCamLister"
MCA = checkMacro "MultiCamAttribute"
MCS = checkMacro "MultiCamSubmitter"
if (MCL == true and MCA == true and MCS == true)then(multiCamUsable = true)