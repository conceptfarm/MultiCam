global MultiCamHDRILib
(
	struct MultiCamHDRILibStruct
	(
		
		pics =#("C:\\temp\\img\\01.jpg","C:\\temp\\img\\02.jpg","C:\\temp\\img\\03.jpg","C:\\temp\\img\\04.jpg","C:\\temp\\img\\05.jpg"),
		bResult = undefined,

		someRollout = 
		(
			rollout someRollout "test" width:500 height:500
			(
				
				dotnetcontrol fl "FlowLayoutPanel" width:someRollout.width height:someRollout.height pos:[0,0]
				
				fn whenButtonIsPressed a b = 
				(
		 			local mat = VrayMtl()
		 			local bT = VRayHDRI()
		 			bT.HDRIMapName = ((a.ImageLocation))
		 			mat.texmap_diffuse = bT
					setMeditMaterial 1 mat
					bResult = bt
					try(destroydialog someRollout)catch(print "????")
				)
				
				on someRollout open do
				(
					local oddColor=(dotnetclass "system.drawing.color").fromARGB 68 68 68  	
					for f in pics do
					(
						local gB = (dotnetobject "System.Windows.Forms.GroupBox")
						gb.FlatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").Flat;
						gb.Height = 128;
						gb.Width = someRollout.width-30;
						gb.text = f
						gb.BackColor = oddColor
						gb.ForeColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
						--gb.font = (dotnetClass "System.Drawing.Font").size 12
						--gb.font.size = 12
						local pb = dotnetobject "PictureBox"
						pb.BackColor = oddColor
						pb.SizeMode = (dotnetclass "PictureBoxSizeMode").Zoom
						pb.Height = 108;
						pb.Width = someRollout.width-30;
						pb.imageLocation =  f
						pb.Dock = pb.Dock.Bottom
						
						--dotNet.addEventHandler gb "paint" paintEvent
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

		fn openDialog = (print "opened";return ok),
		fn show2 = 
		(
			bResult = undefined
			createdialog someRollout modal:true
			return bResult

		),
		fn close = try(destroydialog dialog) catch()
		--on create do dialog.owner = this
		--on dialog open do (print "opened")
	)

	--(MultiCamHDRILib()).show()
	MultiCamHDRILib = MultiCamHDRILibStruct()
)