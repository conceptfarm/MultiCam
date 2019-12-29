--global multiCamHDRILibrary = @"C:\temp\Repo\MultiCamHDRI\"
global MultiCamHDRILib
(
	struct MultiCamHDRILibStruct
	(
		
		thumbnails = undefined, --#("C:\\temp\\img\\01.jpg","C:\\temp\\img\\02.jpg","C:\\temp\\img\\03.jpg","C:\\temp\\img\\04.jpg","C:\\temp\\img\\05.jpg"),
		bResult = undefined,

		MultiCamHDRILib_RO = 
		(
			rollout MultiCamHDRILib_RO "MultiCam HDRI Selector" width:500 height:500
			(
				
				dotnetcontrol fl "FlowLayoutPanel" width:MultiCamHDRILib_RO.width height:MultiCamHDRILib_RO.height pos:[0,0]
				
				fn whenButtonIsPressed a b = 
				(
					local MATFile = (getFilenamePath ((a.ImageLocation))) + (getFilenameFile ((a.ImageLocation))) + ".mat"
					local HDRIFile = (getFilenamePath ((a.ImageLocation))) + (getFilenameFile ((a.ImageLocation))) + ".hdr"
					local JSONFile = (getFilenamePath ((a.ImageLocation))) + (getFilenameFile ((a.ImageLocation))) + ".json"
		 			local tempMatLib = loadTempMaterialLibrary MATFile
		 			
		 			if tempMatLib != undefined then
		 			(
			 			local HDRIMap = tempMatLib[1]
						HDRIMap.HDRIMapName = HDRIFile
			 			
			 			local mat = VrayMtl()
			 			mat.texmap_diffuse = HDRIMap
						setMeditMaterial 1 mat
						bResult = HDRIMap
						
						-- parse json file
						local vraySuns = for o in lights where (classof o == VRaySun) collect o
						if vraySuns.count > 0 then
						( 
							local qb = queryBox "Load settings for the VraySun to match the HDRI Map?" 
							if qb == true then
							(
								local JSONFile = openFile JSONFile
								seek JSONFile 0
								try while not eof JSONFile do 
								(
									local parsedLine = readline JSONFile
									local filterLine = filterString parsedLine " : "
									local filterColour = filterString parsedLine "()"
									--setProperty <obj> <property_name> <value>
									if filterColour.count > 1 then
									(
										setProperty vraySuns[1] filterLine[1] (execute(filterColour[2]))
									)
									else (setProperty vraySuns[1] filterLine[1] (execute(filterLine[2])))
								)
								catch(print "end of vray_dr.cfg")
								close JSONFile
								free JSONFile
							)
						)
					)
					try(destroydialog MultiCamHDRILib_RO)catch(print "????")
				)
				
				on MultiCamHDRILib_RO open do
				(
					local oddColor=(dotnetclass "system.drawing.color").fromARGB 68 68 68  	
					for f in thumbnails do
					(
						local gB = (dotnetobject "System.Windows.Forms.GroupBox")
						gb.FlatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").Flat;
						gb.Width = MultiCamHDRILib_RO.width-30;
						gb.Height = gb.Width/2.0 + 20;
						gb.text = getFilenameFile f
						gb.BackColor = oddColor
						gb.ForeColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
						--gb.font = (dotnetClass "System.Drawing.Font").size 12
						--gb.font.size = 12
						
						local pb = dotnetobject "PictureBox"
						pb.BackColor = oddColor
						pb.SizeMode = (dotnetclass "PictureBoxSizeMode").Zoom
						pb.Width = gb.Width - 20.0;
						pb.Height = pb.Width/2.0;
						pb.imageLocation =  f
						pb.Dock = pb.Dock.Bottom
						
						dotNet.addEventHandler pb "click" whenButtonIsPressed
						gB.controls.add pb
						fl.controls.add gB
					)
					
					fl.AutoScroll = true;
					fl.BackColor = oddColor
					fl.BorderStyle = (dotnetclass "System.Windows.Forms.BorderStyle").Fixed3D;
					fl.CausesValidation = false;
					fl.Dock = (dotnetclass "System.Windows.Forms.DockStyle").Fill;
					fl.Name = "flowLayoutPanelMain";
					fl.TabIndex = 0;
				)
			)
		),
		fn parseLibraryFolder =
		(
			local result = undefined
			local HDRIFiles = getFiles (multiCamHDRILibrary + "*.hdr")
			local JSONFiles = getFiles (multiCamHDRILibrary + "*.json")
			local ThumbFiles = getFiles (multiCamHDRILibrary + "*.jpg")
			local MATFiles = getFiles (multiCamHDRILibrary + "*.mat")

			local libraryError = false
			
			if (HDRIFiles.count == JSONFiles.count and HDRIFiles.count == ThumbFiles.count and HDRIFiles.count == MATFiles.count) then
			(
				for i=1 to HDRIFiles.count do
				(
					if (getFilenameFile HDRIFiles[i] == getFilenameFile JSONFiles[i] and getFilenameFile HDRIFiles[i] == getFilenameFile ThumbFiles[i] and getFilenameFile HDRIFiles[i] == getFilenameFile MATFiles[i]) then
					()
					else
					(
						libraryError = true
						exit
					)
				)
			)
			else (libraryError = true)

			if (libraryError == false) then (result = ThumbFiles)
			result
		),

		fn openDialog = (print "opened";return ok),
		
		fn show = 
		(
			bResult = undefined
			thumbnails = parseLibraryFolder()
			if thumbnails != undefined then 
			(
				createdialog MultiCamHDRILib_RO modal:true
				return bResult
			)
			else
			(
				MessageBox "There is an error in the library. "
			)

		),
		fn close = try(destroydialog dialog) catch()
		--on create do dialog.owner = this
		--on dialog open do (print "opened")
	)

	--(MultiCamHDRILib()).show()
	MultiCamHDRILib = MultiCamHDRILibStruct()
)
