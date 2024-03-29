--global multiCamHDRILibrary = @"C:\temp\Repo\MultiCamHDRI\"
global MultiCamHDRILib
(
	struct MultiCamHDRILibStruct
	(
		
		thumbFiles = undefined, --#("C:\\temp\\img\\01.jpg","C:\\temp\\img\\02.jpg","C:\\temp\\img\\03.jpg","C:\\temp\\img\\04.jpg","C:\\temp\\img\\05.jpg"),
		bResult = undefined,

		MultiCamHDRILib_RO = 
		(
			rollout MultiCamHDRILib_RO "MultiCam HDRI Selector v1.1" width:500 height:500
			(
				
				dotnetcontrol flowLayout_pnl "FlowLayoutPanel" width:MultiCamHDRILib_RO.width height:MultiCamHDRILib_RO.height pos:[0,0]
				
				fn whenButtonIsPressed a b = 
				(
					if (a.tag == "hdrimap") then
					(
						local MATFile = (getFilenamePath ((a.ImageLocation))) + (getFilenameFile ((a.ImageLocation))) + ".mat"
						local HDRIFile = (getFilenamePath ((a.ImageLocation))) + (getFilenameFile ((a.ImageLocation))) + ".hdr"
						local JSONFile = (getFilenamePath ((a.ImageLocation))) + (getFilenameFile ((a.ImageLocation))) + ".json"
			 			local tempMatLib = loadTempMaterialLibrary MATFile
			 			
			 			if tempMatLib != undefined then
			 			(
				 			local HDRIMap = tempMatLib[1]
							HDRIMap.HDRIMapName = HDRIFile
							HDRIMap.ground_on = true
							HDRIMap.ground_position = [0,0,0]
				 			
				 			local mat = VrayMtl()
				 			mat.texmap_diffuse = HDRIMap
							--setMeditMaterial 1 mat
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
									catch(print "end of VraySun JSON file.")
									close JSONFile
									free JSONFile
								)
							)
						)
					)
					else if a.tag == "custom" then
					(
						local HDRIMap = VrayHDRI()
						HDRIMap.maptype = 2 --Mapping type: Spherical
						HDRIMap.horizontalRotation = 180
						HDRIMap.ground_on = true
						HDRIMap.ground_position = [0,0,0]
						HDRIMap.rgbColorSpace = 1 --RGB Color Space: sRGB Primaries
						HDRIMap.color_space = 0 --Color space transfer function : None
						
						theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
						theDialog.title = "Select a HDR Image file." --set the title
						theDialog.Multiselect = false --don't allow multiple files to be selected
						theDialog.Filter = "HDRI (*.hdr)|*.hdr|OpenEXR (*.exr)|*.exr|Jpg(*.jpg,*.jpeg)|*.jpg;*.jpeg|PNG(*.png)|*.png|Tiff(*.tiff)|*.tiff|Tif(*.tif)|*.tif |Tga(*.tga)|*.tga"
						theDialog.FilterIndex = 1 --set the filter drop-down list to HDRI
						result = theDialog.showDialog() --display the dialog, get result into variable
						result.ToString() --when closed, convert the result to string
						result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
						result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
						local HDRIFile = theDialog.fileName --the selected filenames will be returned as an array
						
						HDRIMap.HDRIMapName = HDRIFile
						
						bResult = HDRIMap
					)
					else if a.tag == "none" then (bResult = "none")
					else if a.tag == "vraysky" then (bResult = "vraysky")

					try(destroydialog MultiCamHDRILib_RO)catch(print "????")
				)
				
				on MultiCamHDRILib_RO open do
				(
					local backColor=(dotnetclass "system.drawing.color").fromARGB 68 68 68  	
					local foreColor=(dotnetclass "system.drawing.color").fromARGB 255 255 255
					
					fn createDotnetThumbs parentRollout parentPanel fileString bgColour frColour =
					(
						local groupBoxForm = (dotnetobject "System.Windows.Forms.GroupBox")
						groupBoxForm.FlatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").Flat
						groupBoxForm.Width = parentRollout.width-30
						groupBoxForm.Height = groupBoxForm.Width/2.0 + 20
						groupBoxForm.text = getFilenameFile fileString
						groupBoxForm.BackColor = bgColour
						groupBoxForm.ForeColor = frColour
						--gb.font = (dotnetClass "System.Drawing.Font").size 12
						--gb.font.size = 12
						
						local pictureBox = dotnetobject "PictureBox"
						pictureBox.BackColor = bgColour
						pictureBox.SizeMode = (dotnetclass "PictureBoxSizeMode").Zoom
						pictureBox.Width = groupBoxForm.Width - 20.0
						pictureBox.Height = pictureBox.Width/2.0
						pictureBox.imageLocation =  fileString
						pictureBox.Dock = pictureBox.Dock.Bottom
						
						if (getFilenameFile fileString) == "00-00_None_Remove_Existing" then (pictureBox.tag = "none")
						else if (getFilenameFile fileString) == "00-00_VraySky" then (pictureBox.tag = "vraysky")
						else if (getFilenameFile fileString) == "00-00_Custom" then (pictureBox.tag = "custom")
						else (pictureBox.tag = "hdrimap")
						
						dotNet.addEventHandler pictureBox "click" whenButtonIsPressed
						groupBoxForm.controls.add pictureBox
						parentPanel.controls.add groupBoxForm
					)

					for thumbFile in thumbFiles do
					(
						createDotnetThumbs MultiCamHDRILib_RO flowLayout_pnl thumbFile backColor foreColor
						/*
						local gB = (dotnetobject "System.Windows.Forms.GroupBox")
						gb.FlatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").Flat
						gb.Width = MultiCamHDRILib_RO.width-30
						gb.Height = gb.Width/2.0 + 20
						gb.text = getFilenameFile f
						gb.BackColor = backColor
						gb.ForeColor = foreColor
						--gb.font = (dotnetClass "System.Drawing.Font").size 12
						--gb.font.size = 12
						
						local pb = dotnetobject "PictureBox"
						pb.BackColor = backColor
						pb.SizeMode = (dotnetclass "PictureBoxSizeMode").Zoom
						pb.Width = gb.Width - 20.0
						pb.Height = pb.Width/2.0
						pb.imageLocation =  f
						pb.Dock = pb.Dock.Bottom
						
						if (getFilenameFile f) == "00-00_None_Remove_Existing" then (pb.tag = "none")
						else if (getFilenameFile f) == "00-00_VraySky" then (pb.tag = "vraysky")
						else if (getFilenameFile f) == "00-00_Custom" then (pb.tag = "custom")
						else (pb.tag = "hdrimap")


						dotNet.addEventHandler pb "click" whenButtonIsPressed
						gB.controls.add pb
						flowLayout_pnl.controls.add gB
						*/
					)
					
					flowLayout_pnl.AutoScroll = true
					flowLayout_pnl.BackColor = backColor
					flowLayout_pnl.BorderStyle = (dotnetclass "System.Windows.Forms.BorderStyle").Fixed3D
					flowLayout_pnl.CausesValidation = false
					flowLayout_pnl.Dock = (dotnetclass "System.Windows.Forms.DockStyle").Fill
					flowLayout_pnl.Name = "flowLayoutPanelMain"
					flowLayout_pnl.TabIndex = 0
					setFocus MultiCamHDRILib_RO
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
			thumbFiles = parseLibraryFolder()
			if thumbFiles != undefined then 
			(
				createdialog MultiCamHDRILib_RO modal:true
				bResult
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
