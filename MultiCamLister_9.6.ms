---------------------------------------------------------------------------------------
-- MultiCamLister.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2018
-- Lists all Vray Cameras and their porperties MultiCam Attribute properties
---------------------------------------------------------------------------------------
-- Bug: clicking off, does not commit change, checkbox issues, probably other issues as well. 
-- checking in the modifier, checks in the lister but doesnot un-gray
-- Text feilds when edited lose focus
-- When lost focus dgv needs to comit changes and finalize edits
-- Post delete runs for every object, need to find a way to run once after all the objects are deleted
-- Issue: with nodeeventCallback, interacting with nodeEventCallback from the submitter

macroScript MultiCamLister
category:"ilya_s Scripts"
tooltip:"MCL"
buttontext:"MCL"
Icon:#("MultiCamSq",1)
(
	-- add callback on selectionChanged: to untick or tick selection boxes
	-- http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_7C91D285_5683_4606_9F7C_B8D3A7CA508B_htm
	
	-- use .currentcell
	
	-- consider freezing select and name columns
	-- ISSUE: When deleting or adding object out of range error, probably due to the selected object callback
	
	global multiCamListerFloater
	global MultiCamListerOpen = false
	global MultiCamListerNodeEventCallback = undefined

	fn checkRenderer = 
	(
		local result = false
		local productRenderer = renderers.production
		--test for vray advanced and vray rt
		if(productRenderer != undefined) then (
			result = ((productRenderer.classid[1] == 1941615238) and (productRenderer.classid[2] == 2012806412))
		)
		else 
		(
			result = false
		)
		result
	)
	
	struct MCLStruct
	(
		textEditBox = dotnetobject "DataGridViewTextBoxEditingControl",
		prevtextEditBoxText = "",
		floaterHWND = undefined,
		windowDotNetObj = undefined,
		modalWindowWorkaround = false,
		cameraObjIDs = #(),
		cameraObjIDsNoMod = #(),
		prevSelectedRows = #(),
		prevSelectedRowsLessSelf = #(),
		prevSelectedRowsPlusSelf = #(),
		MultiCamLister_RO,
		dgvMaxHeight = 800,
		dgvRefreshing = false,
		dgvPostDeleteUpdate = false,
		disabledColor = (dotnetclass "system.drawing.color").fromARGB 128 128 128,
		enabledColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255,
		enabledStyle = undefined, --dotnetobject "DataGridViewCellStyle",
		disabledStyle = undefined, --dotnetobject "DataGridViewCellStyle",
		gapBetweenDGVs = 20,
		prevScrollPos = 0,	
		displayScale = 1,
		defList = #(),
		defListNoMod = #(),
		dgvWidth = 1196,
		dgvWidthWithBar = 1212,
		dgvRowHeight = 25,--26
		dgvHeaderRowHeight = 32,--36

		fn scaleForDisplay n s = 
		(
			n*s
		),
		
		fn getWindowClass =
		(
			local source  = "using System;
	"
			source += "using System.Runtime.InteropServices;
	"
			source += "public class Window
	"
			source += "{
	"
			source += "	[DllImport(\"user32.dll\")]
	"
			source += "	public static extern IntPtr GetForegroundWindow();
	"
			source += "}
	"

			local csharpProvider = dotNetObject "Microsoft.CSharp.CSharpCodeProvider"
			local compilerParams = dotNetObject "System.CodeDom.Compiler.CompilerParameters"
				compilerParams.GenerateInMemory = true
				compilerParams.ReferencedAssemblies.Add "System.dll"
			local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
				compilerResults.CompiledAssembly.CreateInstance "Window"
		),
		
		fn compareByObjectName v1 v2 =
		(
			local d = (v1.name < v2.name)
			case of
			(
				(d == true ): -1
				(d == false ): 1
				default: 0
			)
		),
		
		fn getVraySunInScene = 
		(
			local result = undefined
			local allSuns = for o in objects where classof o == VraySun collect o

			if (allSuns.count == 1 ) then
			(
				result = allSuns[1]
			)
			else if (allSuns.count > 1) then 
			(
				--MessageBox ("There are " + allSuns.count as string + " in the scene.\nThere can only be one!")
				result = undefined
			)
			else
			(
				--MessageBox ("No VraySun in the scene.")
				result = undefined
			)
			result
		),
		
		fn updateModPanel obj = 
		(
			if obj == $ then
			(
				try(modpanel.setcurrentobject(modPanel.getCurrentObject()))catch()
			)
		),

		fn convertMaxUtoDisplayU val =
		(
			(val/units.decodeValue "1")
		),
		
		fn convertDisplayUToMaxU val =
		(
			(val * (units.decodeValue "1"))
		),


		fn getCamaraClipping cam prop = 
		(
			result = undefined
			
			clipName = undefined
			nearName = undefined
			farName = undefined
			
			if classof cam == Freecamera or classof cam == Targetcamera then
			(
				clipName = #clipManually
				nearName = #nearclip
				farName = #farclip
			)
			else if classof cam == Physical or classof cam == VRayPhysicalCamera then
			(
				clipName = #clip_on
				nearName = #clip_near
				farName = #clip_far
			)

			if clipName != undefined then
			(
				case prop of
				(
					#clip:(result = getProperty cam clipName)
					#near:(result = convertMaxUtoDisplayU (getProperty cam nearName))
					#far:(result = convertMaxUtoDisplayU (getProperty cam farName))
				)
			)
			result
		),

		fn setCameraClipping cam prop val = 
		(
			clipName = undefined
			nearName = undefined
			farName = undefined
			
			if classof cam == Freecamera or classof cam == Targetcamera then
			(
				clipName = #clipManually
				nearName = #nearclip
				farName = #farclip
			)
			else if classof cam == Physical or classof cam == VRayPhysicalCamera then
			(
				clipName = #clip_on
				nearName = #clip_near
				farName = #clip_far
			)

			case prop of
			(
				#clip:(setProperty cam clipName val)
				#near:(setProperty cam nearName (convertDisplayUToMaxU val))
				#far:(setProperty cam farName (convertDisplayUToMaxU val))
			)
		),


		fn getRowsFromSelection dgvObject = --subtract:true cell:unsupplied = 
		(
			local result = #()
			for i = 0 to dgvObject.SelectedCells.count-1 do
			(
				appendifUnique result dgvObject.SelectedCells.item[i].rowindex
			)
			result
		),

		fn enterEscapeFN sender args = 
		(
			if args.keyCode == ((dotnetclass "System.Windows.Forms.Keys").Enter) then 
			(
				--print "pressed Enter"
				sender.EditingControlDataGridView.endEdit()
			)

			else if args.keyCode == ((dotnetclass "System.Windows.Forms.Keys").Escape) then
			(
				--print  "pressed Esc"
				sender.text = prevtextEditBoxText
				sender.EditingControlDataGridView.endEdit()
			)
		),

		fn subtractCellFromSelection arr cell = 
		(
			local result = copy arr #nomap
			local itemToDelete = (findItem result cell)
			if itemToDelete != 0 then 
			(
				deleteItem result itemToDelete
			)
			result
		),

		fn addCellToSelection arr cell = 
		(
			local result = copy arr #nomap
			appendifUnique result cell
			result
		),
		
		fn checkSelectedCells dgvObject val  = 
		(
			for row in prevSelectedRows do 
			(
				if dgvObject.rows.item[row].cells.item[val.ColumnIndex].readonly != true then
				(
					dgvObject.rows.item[row].cells.item[val.ColumnIndex].value = dgvObject.currentCell.value
				)
			)
		),
		
		-- using cells with stored camera object ids
		fn getObjectByRow dgvObject row = 
		(
			local obj = GetAnimByHandle ((dgvObject.rows.item[row].cells.item["ID"].value) as integerPtr)
			obj		
		),
		
		-- using cells with stored camera object
		fn getObjectByRow2 dgvObject row = 
		(
			local obj = (dgvObject.rows.item[row].cells.item["CamObject"].value).value
			obj		
		),

		--???
		fn getRowFromObject obj dgvObject = 
		(
			local result = undefined
			local objID = (GetHandleByAnim obj) as string
			result	
		),
		
		-- using cells with stored camera object
		fn getRowFromObject2 obj dgvObject = 
		(
			local result = undefined
			local notfound = true
			for r = 0 to (dgvObject.rows.count - 1) while notfound do
			(
				if (dgvObject.rows.item[r].cells.item["CamObject"].value).value == obj then
				(
					result = r
					notfound = false
				)
			)
			result
		),

		fn getObjectsFromChecked dgvObject col = 
		(
			local objToSelect = (for i = 0 to (dgvObject.rows.count - 1) where ( (dgvObject.rows.item[i].cells.item[col].value)  == true ) collect (GetAnimByHandle ((dgvObject.rows.item[i].cells.item["ID"].value) as integerPtr)))
			objToSelect
		),
		
		fn initStyles = 
		(
			--when initializing styles, style options must be declared right after the initial object, otherwise styles become instances of each other
			--could be a max bug or .net bug not sure
			disabledStyle = dotnetobject "DataGridViewCellStyle"
			disabledStyle.forecolor = (dotnetclass "system.drawing.color").fromARGB 128 128 128
			enabledStyle = dotnetobject "DataGridViewCellStyle"
			enabledStyle.forecolor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
		),
		
		fn styleDGV dgvObject = 
		(

			--Colour and Styling
			local oddColor=(dotnetclass "system.drawing.color").fromARGB 32 32 32
			local evenColor= (dotnetclass "system.drawing.color").fromARGB 68 68 68  			
			
			local defaultCellStyle = dotnetobject "DataGridViewCellStyle"
			defaultCellStyle.backColor = evenColor
			defaultCellStyle.SelectionBackColor = (dotnetclass "system.drawing.color").fromARGB 80 200 69
			
			local altDefaultCellSyle = dotnetobject "DataGridViewCellStyle"
			altDefaultCellSyle.backColor = oddColor

			local ColumnHeadersDefaultCellStyle = dotnetobject "DataGridViewCellStyle"
			ColumnHeadersDefaultCellStyle.backcolor = (dotnetclass "system.drawing.color").fromARGB 100 100 100
			ColumnHeadersDefaultCellStyle.forecolor = (dotnetclass "system.drawing.color").fromARGB 255 255 255 
			ColumnHeadersDefaultCellStyle.WrapMode = (dotnetclass "DataGridViewTriState").true

			dgvObject.defaultCellStyle = defaultCellStyle
			dgvObject.AlternatingRowsDefaultCellStyle = altDefaultCellSyle
			dgvObject.BackgroundColor = (dotnetclass "system.drawing.color").fromARGB 68 68 68			
			dgvObject.ForeColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
			dgvObject.ColumnHeadersDefaultCellStyle = ColumnHeadersDefaultCellStyle
			dgvObject.EnableHeadersVisualStyles = false
			dgvObject.CellBorderStyle = (dotnetclass "DataGridViewCellBorderStyle").None
			dgvObject.RowHeadersBorderStyle =  (dotnetclass "DataGridViewHeaderBorderStyle").Single
			dgvObject.ColumnHeadersBorderStyle =(dotnetclass  "DataGridViewHeaderBorderStyle").Single
			
			dgvObject.ColumnHeadersHeight=dgvHeaderRowHeight
			dgvObject.AllowUserToResizeColumns = false
			dgvObject.ColumnHeadersHeightSizeMode = (dotnetclass "DataGridViewColumnHeadersHeightSizeMode").DisableResizing
			dgvObject.AllowUserToResizeRows = false
			dgvObject.RowHeadersWidthSizeMode = (dotnetclass "DataGridViewRowHeadersWidthSizeMode").DisableResizing
		),

		fn changeControlStatus dgvObject row val arr = 
		(
			for cell in arr do
			(
				--here we change the whole style rather than just forecolor, bug in max or dotnet?
				dgvObject.rows.item[row].cells.item[cell].ReadOnly = not val
				if val == true then
				(
					dgvObject.rows.item[row].cells.item[cell].style = enabledStyle
				)
				else
				(
					dgvObject.rows.item[row].cells.item[cell].style = disabledStyle
				)
			)
		),
		
		fn setSelectionCells dgvObject camIDArray = 
		(		
			if dgvObject.Focused == false then 
			(	
				dgvObject.ClearSelection()
				--local vals = for i = 0 to (dgvObject.rows.count - 1) collect dgvObject.rows.item[i].cells.item["ID"].value
				for o in selection where superclassof o == camera do
				(
					local objID = (getHandleByAnim o) as string
					local item = findItem camIDArray objID
					if (item != 0) then
					(
						dgvObject.rows.item[item-1].cells.item[0].selected = true
					)
				)
			)
		),

			
		fn populateColumns dgvObject defList = 
		(
			for o in defList do
			(
				local col = undefined 
				case o[2] of 
				(
					"text":(
								col = (dotnetobject "DataGridViewTextBoxColumn")
							)
					"button": (
								col = (dotnetobject "DataGridViewButtonColumn")
								col.sortmode = (dotnetclass "DataGridViewColumnSortMode").NotSortable
							)
					"number": (
								col = (dotnetobject "DataGridViewTextBoxColumn")
								--Not a good idea to set column to integer mode, harder to handle non-number entries
								--col.valueType = (dotnetclass "type").gettype "System.Int32"
							)
					"check":(
								col = (dotnetobject "DataGridViewCheckBoxColumn")
							)
					"object": (col = (dotnetobject "DataGridViewTextBoxColumn"))
				)
				col.DataPropertyName = "Name"
				col.Name = o[1]
				col.width = o[3]
				if o[1] == "ID" then col.visible = false
				if o[1] == "IDMat" then col.visible = false
				if o[1] == "CamObject" then col.visible = false
				dgvObject.Columns.Add (col)
			)
		),

		fn populateRowNoMod dgvObject rowIndex obj = 
		(

			dgvObject.rows.item[rowIndex].cells.item[0].value = ""
			dgvObject.rows.item[rowIndex].cells.item[0].flatstyle = (dotnetclass "FlatStyle").Flat
			
			dgvObject.rows.item[rowIndex].cells.item[1].value = obj.name
			
			dgvObject.rows.item[rowIndex].cells.item[2].value = "Add Attribute"
			dgvObject.rows.item[rowIndex].cells.item[2].flatstyle = (dotnetclass "FlatStyle").Flat
			
			dgvObject.rows.item[rowIndex].cells.item[3].value = (GetHandleByAnim obj) as string
			dgvObject.rows.item[rowIndex].cells.item[3].ReadOnly = true

			dgvObject.rows.item[rowIndex].cells.item[4].value = dotNetMXSValue obj
			dgvObject.rows.item[rowIndex].cells.item[4].ReadOnly = true
		),

		fn populateRow dgvObject rowIndex obj =
		(
			dgvObject.rows.item[rowIndex].cells.item[0].value = ""
			dgvObject.rows.item[rowIndex].cells.item[0].flatstyle = (dotnetclass "FlatStyle").Flat
			
			dgvObject.rows.item[rowIndex].cells.item[1].value = obj.name
			dgvObject.rows.item[rowIndex].cells.item[2].value = obj.baseObject.MultiCamAttributeData.firstFrame_sp
			dgvObject.rows.item[rowIndex].cells.item[3].value = obj.baseObject.MultiCamAttributeData.lastFrame_sp
			dgvObject.rows.item[rowIndex].cells.item[4].value = "Get"
			dgvObject.rows.item[rowIndex].cells.item[4].flatstyle = (dotnetclass "FlatStyle").Flat
				
			dgvObject.rows.item[rowIndex].cells.item[5].ReadOnly = true
			
			dgvObject.rows.item[rowIndex].cells.item[6].value = obj.baseObject.MultiCamAttributeData.useHideLayers_chb
			dgvObject.rows.item[rowIndex].cells.item[7].value = "Clear All"
			dgvObject.rows.item[rowIndex].cells.item[7].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[7].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[6].value
			dgvObject.rows.item[rowIndex].cells.item[8].value = "Add Hidden"
			dgvObject.rows.item[rowIndex].cells.item[8].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[8].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[6].value
			dgvObject.rows.item[rowIndex].cells.item[9].value = "Add Layer"
			dgvObject.rows.item[rowIndex].cells.item[9].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[9].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[6].value
			
			if dgvObject.rows.item[rowIndex].cells.item[6].value == false then
			(
				dgvObject.rows.item[rowIndex].cells.item[7].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[8].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[9].style = disabledStyle
			)
			else
			(
				dgvObject.rows.item[rowIndex].cells.item[7].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[8].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[9].style = enabledStyle
			)
			
			--if ((mod rowIndex 2 ) == 0) then (dgvObject.rows.item[rowIndex].cells.item[10].visible = false)
			dgvObject.rows.item[rowIndex].cells.item[10].value = obj.baseObject.MultiCamAttributeData.useSunpoints_param
			dgvObject.rows.item[rowIndex].cells.item[11].value = obj.baseObject.MultiCamAttributeData.showSunPoint_btn
			dgvObject.rows.item[rowIndex].cells.item[11].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[10].value
			dgvObject.rows.item[rowIndex].cells.item[12].value = "Move Point"
			dgvObject.rows.item[rowIndex].cells.item[12].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[12].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[10].value
			dgvObject.rows.item[rowIndex].cells.item[13].value = "Move Sun"
			dgvObject.rows.item[rowIndex].cells.item[13].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[13].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[10].value
			
			if dgvObject.rows.item[rowIndex].cells.item[10].value == false then
			(
				dgvObject.rows.item[rowIndex].cells.item[11].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[12].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[13].style = disabledStyle
			)
			else
			(
				dgvObject.rows.item[rowIndex].cells.item[11].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[12].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[13].style = enabledStyle
			)
			
			dgvObject.rows.item[rowIndex].cells.item[14].ReadOnly = true
			
			dgvObject.rows.item[rowIndex].cells.item[15].value = obj.baseObject.MultiCamAttributeData.useHeightWidth_chb
			dgvObject.rows.item[rowIndex].cells.item[16].value = obj.baseObject.MultiCamAttributeData.imgWidth_sp
			dgvObject.rows.item[rowIndex].cells.item[16].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[15].value
			dgvObject.rows.item[rowIndex].cells.item[17].value = obj.baseObject.MultiCamAttributeData.imgHeight_sp
			dgvObject.rows.item[rowIndex].cells.item[17].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[15].value
			dgvObject.rows.item[rowIndex].cells.item[18].value = "Get Res."
			dgvObject.rows.item[rowIndex].cells.item[18].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[18].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[15].value
			
			if dgvObject.rows.item[rowIndex].cells.item[15].value == false then
			(
				dgvObject.rows.item[rowIndex].cells.item[16].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[17].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[18].style = disabledStyle
			)
			else 
			(
				dgvObject.rows.item[rowIndex].cells.item[16].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[17].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[18].style = enabledStyle
			)
			
			dgvObject.rows.item[rowIndex].cells.item[19].ReadOnly = true
			
			dgvObject.rows.item[rowIndex].cells.item[20].value = obj.baseObject.MultiCamAttributeData.useHDRIMap_val
			dgvObject.rows.item[rowIndex].cells.item[21].value = if (obj.baseObject.MultiCamAttributeData.hdriMap_val != undefined) then (obj.baseObject.MultiCamAttributeData.hdriMap_val.name) else ("None")
			dgvObject.rows.item[rowIndex].cells.item[21].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[21].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[20].value
			dgvObject.rows.item[rowIndex].cells.item[22].value = obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
			dgvObject.rows.item[rowIndex].cells.item[22].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[20].value
			dgvObject.rows.item[rowIndex].cells.item[23].value = "Edit"
			dgvObject.rows.item[rowIndex].cells.item[23].flatstyle = (dotnetclass "FlatStyle").Flat
			dgvObject.rows.item[rowIndex].cells.item[23].ReadOnly = not dgvObject.rows.item[rowIndex].cells.item[20].value
			
			if dgvObject.rows.item[rowIndex].cells.item[20].value == false then
			(
				dgvObject.rows.item[rowIndex].cells.item[21].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[22].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item[23].style = disabledStyle
			)
			else
			(
				dgvObject.rows.item[rowIndex].cells.item[21].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[22].style = enabledStyle
				dgvObject.rows.item[rowIndex].cells.item[23].style = enabledStyle
			)

			dgvObject.rows.item[rowIndex].cells.item["Clipping On"].value = getCamaraClipping obj #clip
			dgvObject.rows.item[rowIndex].cells.item["Z-Depth Near"].value = getCamaraClipping obj #near
			dgvObject.rows.item[rowIndex].cells.item["Z-Depth Far"].value = getCamaraClipping obj #far
			
			if dgvObject.rows.item[rowIndex].cells.item["Clipping On"].value == undefined then
			(
				dgvObject.rows.item[rowIndex].cells.item["Clipping On"].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item["Z-Depth Near"].style = disabledStyle
				dgvObject.rows.item[rowIndex].cells.item["Z-Depth Far"].style = disabledStyle

				dgvObject.rows.item[rowIndex].cells.item["Clipping On"].ReadOnly = true
				dgvObject.rows.item[rowIndex].cells.item["Z-Depth Near"].ReadOnly = true
				dgvObject.rows.item[rowIndex].cells.item["Z-Depth Far"].ReadOnly = true
			) 

			dgvObject.rows.item[rowIndex].cells.item["Delete Attribute"].value = "Delete Attribute"
			dgvObject.rows.item[rowIndex].cells.item["Delete Attribute"].flatstyle = (dotnetclass "FlatStyle").Flat
			
			dgvObject.rows.item[rowIndex].cells.item["ID"].value = (GetHandleByAnim obj) as string
			dgvObject.rows.item[rowIndex].cells.item["ID"].ReadOnly = true
			dgvObject.rows.item[rowIndex].cells.item["IDMat"].value = if (obj.baseObject.MultiCamAttributeData.hdriMap_val != undefined) then ((GetHandleByAnim obj.baseObject.MultiCamAttributeData.hdriMap_val) as string) else ("None")
			dgvObject.rows.item[rowIndex].cells.item["IDMat"].ReadOnly = true
			dgvObject.rows.item[rowIndex].cells.item["CamObject"].value = dotNetMXSValue obj
			dgvObject.rows.item[rowIndex].cells.item["CamObject"].ReadOnly = true

		),-- end populateRow

		fn populateDGV dgvObject noMod:true= 
		(
			local allCams = #()
			if noMod then
			(
				--kind of backwards here should change noMod to hasProperty in the future
				allCams = for o in objects where (superclassof o == camera and  (isProperty o.baseObject "MultiCamAttributeData") == true) collect o
				
				qsort allCams compareByObjectName

				for i = 0 to i = (allCams.count - 1) do
				(
					local o = allCams[i+1]
					row = dgvObject.rows.item[dgvObject.rows.add()]
					row.height = dgvRowHeight
					populateRow dgvObject i o
				)
				
				cameraObjIDs = for i = 0 to dgvObject.rows.count - 1 collect dgvObject.rows.item[i].cells.item["ID"].value
			)
			else
			(
				allCams = for o in objects where (superclassof o == camera and  (isProperty o.baseObject "MultiCamAttributeData") == false) collect o
				
				qsort allCams compareByObjectName
				
				for i = 0 to i = (allCams.count - 1) do
				(
					local o = allCams[i+1]
					row = dgvObject.rows.item[dgvObject.rows.add()]
					row.height = dgvRowHeight

					populateRowNoMod dgvObject i o
				)
				
				cameraObjIDsNoMod = for i = 0 to dgvObject.rows.count - 1 collect dgvObject.rows.item[i].cells.item["ID"].value
			)
			
			dgvObject.height = 	ceil ((dgvRowHeight/displayScale*(allCams.count)) + dgvHeaderRowHeight/displayScale + 2)

			dgvObject.AllowUserToAddRows = false
			dgvObject.AllowUserToDeleteRows = false
			--print "clearing selection populate"
			dgvObject.ClearSelection()

		),--end populateDGV

		fn dgvUpdateSize dgv1 dgv2 = 
		(
			if dgv1.rows.count == 0 then 
			(
				dgv1.height = 0
				dgv1.visible = false
			)
			else dgv1.visible = true

			if dgv2.rows.count == 0 then 
			(
				dgv2.height = 0
				dgv2.visible = false
			)
			else dgv2.visible = true

			dgv2.pos = [dgv1.pos[1], dgv1.pos[2] + dgv1.height + gapBetweenDGVs]
			--dgv2.pos = [dgv1.pos[1], dgv1.pos[2] + dgv1.height + 20]
			--multiCamListerFloater.rollouts[1].height = (dgv1.pos[2] + dgv1.height + 20 + dgv2.height + 40)*displayScale
			multiCamListerFloater.rollouts[1].height = (dgv1.pos[2] + dgv1.height + gapBetweenDGVs + dgv2.height + 40)*displayScale
			multiCamListerFloater.size = [multiCamListerFloater.size[1],(multiCamListerFloater.rollouts[1].height + 30)]
			if multiCamListerFloater.size[2] > dgvMaxHeight then multiCamListerFloater.size = [multiCamListerFloater.size[1], dgvMaxHeight]
		),

		fn dgvUpdate = 
		(
			local dgv = MultiCamLister.MultiCamLister_RO.dgv
			local dgvNoMod = MultiCamLister.MultiCamLister_RO.dgvNoMod
			
			dgvRefreshing = true
			
			dgv.Rows.Clear()
			dgvNoMod.Rows.Clear()
			
			populateDGV dgv noMod:true
			populateDGV dgvNoMod noMod:false

			dgvUpdateSize dgv dgvNoMod
			
			setSelectionCells dgv cameraObjIDs
			setSelectionCells dgvNoMod cameraObjIDsNoMod
			
			dgvRefreshing = false
			--print "Updating DGV"
			--setSelectionCells dgv dgvNoMod
		),

		fn updateRowFromObj obj dgvObject = 
		(
			local rowToInvalidate = getRowFromObject2 obj dgvObject
			--fires when adding CAs and causes an error, check if the object is in dgv
			--if yes, update
			if rowToInvalidate != undefined then
			(
				dgvRefreshing = true
				populateRow dgvObject rowToInvalidate obj
				dgvRefreshing = false
			)
		),
		


		--------------------------------------
		-- NODE EVENT CALLBACK FUNCTIONS -----
		--------------------------------------
		
		--executes on array of object handles
		fn selectionFN ev ids =
		(
			--local startT = timeStamp()
			--local endT = timeStamp()
			--print ("selectionFN: " + (endT- startT) as string)

			local dgv = MultiCamLister.MultiCamLister_RO.dgv
			local dgvNoMod = MultiCamLister.MultiCamLister_RO.dgvNoMod
			
			if dgv.Focused == false and dgvnomod.Focused == false then
			(	
				dgv.ClearSelection()
				dgvNoMod.ClearSelection()
				
				local cameraObjIDs = (for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value)
				local cameraObjIDsNoMod = (for i = 0 to dgvNoMod.rows.count - 1 collect dgvNoMod.rows.item[i].cells.item["ID"].value)
				
				for id in ids where (superClassOf (getAnimByHandle id) == camera and (getAnimByHandle id).isSelected==true)  do 
				(
					local objID = (id as string) +"P"
					local item = findItem cameraObjIDs objID
					local itemNoMod = findItem cameraObjIDsNoMod objID
					if (item != 0) then
					(
						dgv.rows.item[item-1].cells.item[0].selected = true
					)
					if (itemNoMod != 0) then
					(
						dgvNoMod.rows.item[itemNoMod-1].cells.item[0].selected = true
					)
				)
			)
			--local endT = timeStamp()
			--print ("selectionFN: " + (endT- startT) as string)
		),
		
		fn nameChangeFN ev ids =
		(
			local dgv = MultiCamLister.MultiCamLister_RO.dgv
			local dgvNoMod = MultiCamLister.MultiCamLister_RO.dgvNoMod
			
			if dgv.Focused == false and dgvnomod.Focused == false then
			(	
				local cameraObjIDs = for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value
				local cameraObjIDsNoMod = for i = 0 to dgvNoMod.rows.count - 1 collect dgvNoMod.rows.item[i].cells.item["ID"].value
				
				for id in ids where (superClassOf (getAnimByHandle id) == camera) do 
				(
					local obj = getAnimByHandle id
					local objID = (id as string) +"P"
					if ((isProperty obj.baseObject "MultiCamAttributeData") == true) then 
					(
						local row = findItem cameraObjIDs objID
						if (row != 0) then
						(
							local rowToInvalidate = row - 1
							--dgv.InvalidateRow rowToInvalidate
							dgvRefreshing = true
							populateRow dgv rowToInvalidate obj
							dgvRefreshing = false
						)
					)
					else if ((isProperty obj.baseObject "MultiCamAttributeData") == false) then
					(
						local row = findItem cameraObjIDsNoMod objID
						if (row != 0) then
						(
							local rowToInvalidate = row - 1
							--dgvNoMod.InvalidateRow rowToInvalidate
							dgvRefreshing = true
							populateRowNoMod dgvNoMod rowToInvalidate obj
							dgvRefreshing = false
						)
					)
				)
			)
			--local endT = timeStamp()
			--print ("selectionFN: " + (endT- startT) as string)
		),

	    --executes on array of object handles, need only to find one camera to trigger refresh
		fn addedNodeFN ev ids =
		(
			
			--local dgv = MultiCamLister_RO.dgv
			--local dgvNoMod = MultiCamLister_RO.dgvNoMod
			--if dgv.Focused == false and dgvnomod.Focused == false then
			--(
				local cameraFound = false
				for id in ids while not cameraFound do 
				(
					if superclassof (GetAnimByHandle id) == camera then
					(
						MultiCamLister.dgvUpdate()
						cameraFound = true
					)
				)
			--)
		),

		--global preDeleteFN, postDeleteFN,
		fn preDeleteFN =
		(
			local deletedObjects = callbacks.notificationParam()
			local notCamera = true
			for o in deletedObjects while notCamera do
			(
				if superclassof o == camera then
				(
					notCamera = false
					dgvPostDeleteUpdate = true
				)
			)
		),

		fn postDeleteFN = 
		(
			if dgvPostDeleteUpdate == true then
			(
				dgvUpdate()
				dgvPostDeleteUpdate == false
			)
		),


		--no longer used
		fn attributeUpdateFN ev ids = 
		(
			--this should only need to use the first element, because editing will come from the selected object in the modifier menuitem
			obj = GetAnimByHandle ids[1]
			if (superclassof obj == camera and isAnimPlaying()==false) then
			(
				local dgv = MultiCamLister.MultiCamLister_RO.dgv
				local dgvNoMod = MultiCamLister.MultiCamLister_RO.dgvNoMod
				local objID = getHandleByAnim obj
				
				if dgv.Focused == false and dgvNoMod.Focused == false then
				(
					cameraObjIDs = (for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value)
					
					if ((isProperty obj.baseObject "MultiCamAttributeData") == true) then 
					(
						--print("attribute update " + obj.name)
						local row = findItem cameraObjIDs ((objID as string))
						if (row != 0) then
						(
							local rowToInvalidate = row - 1
							--dgv.InvalidateRow rowToInvalidate
							dgvRefreshing = true
							--dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
							populateRow dgv rowToInvalidate obj
							dgvRefreshing = false
						)
					)
				)
			)
		),


		--------------------------------------
		-- ROLLOUT  --------------------------
		--------------------------------------
		fn createRO = 
		(
			
			rollout MultiCamLister_RO "MultiCam Lister" --width:1196 height:800
			( 		 
				
				local owner = if owner != undefined do owner
				
				button Refresh_btn "Refresh" --visible:false
				label editSection_lbl "Edit Camera Properties:" width:120 across:2 align:#left offset:[5,5]
				radiobuttons editSections_rb "" labels:#( "Sunpoints", "Layers", "Resolution", "HDRI", "Z-Depth", "Attribute") default:1  columns:6 align:#left offsets:#([0,0],[5,0],[0,0],[8,0],[0,0],[0,0]) offset:[-180,5]
				--label lblFocus "IN FOCUS" visible:false
				timer clock interval:500
				dotnetcontrol dgv "DataGridView"  align:#center width:633 height:600 offset:[0,5]
				dotnetcontrol dgvNoMod "DataGridView"  align:#center width:633 height:600 offset:[0, gapBetweenDGVs]
				--dotnetcontrol dgvNoMod "DataGridView"  align:#center width:633 height:600 offset:[0,20]

				local prevFocus = true, currFocus = true
				


				on Refresh_btn pressed do
				(
					owner.dgvUpdate()
				)
				
				fn updateHiddenColumns =
				(					
					for i = 6 to dgv.columns.count - 1 do dgv.columns.item[i].visible = false

					case editSections_rb.state of
					(
						1: (for item in owner.defList where item[4]=="sunpointsCols" do dgv.columns.item[item[1]].visible = true)
						2: (for item in owner.defList where item[4]=="layersCols" do dgv.columns.item[item[1]].visible = true)
						3: (for item in owner.defList where item[4]=="resolutionCols" do dgv.columns.item[item[1]].visible = true)
						4: (for item in owner.defList where item[4]=="hdriCols" do dgv.columns.item[item[1]].visible = true)
						5: (for item in owner.defList where item[4]=="zdepthCols" do dgv.columns.item[item[1]].visible = true)
						6: (for item in owner.defList where item[4]=="attributeCols" do dgv.columns.item[item[1]].visible = true)
					)
				)

				on editSections_rb changed state do (updateHiddenColumns())

				on MultiCamLister_RO open do
				(	  			
					if NOT isKindOf windowDotNetObj dotNetObject do windowDotNetObj = getWindowClass()
		  			floaterHWND = windowDotNetObj.getForegroundWindow()
		  								
					if ((maxVersion())[1] > 18000) then (displayScale = ((sysInfo.DesktopSizeUnscaled)/(sysInfo.desktopSize)).x)
					print("Dispay Scale is " + displayScale as string)

					-- Name, Type, Width, ColumnGroup
					-- sections should equal to 298 total
					defList = #(
						#("Select","button",scaleForDisplay 41 displayScale,"alwaysOn"),
						#("Camera Name","text",scaleForDisplay 101 displayScale,"alwaysOn"),
						#("First Frame","number",scaleForDisplay 50 displayScale,"alwaysOn"), 
						#("Last Frame","number",scaleForDisplay 50 displayScale,"alwaysOn"), 
						#("Get Range","button",scaleForDisplay 80 displayScale,"alwaysOn"),  
						#(" ","text",scaleForDisplay 11 displayScale,"alwaysOn"),  
						#("Use Hide Layers","check",scaleForDisplay 58 displayScale,"layersCols"),
						#("Clear All","button",scaleForDisplay 80 displayScale,"layersCols"), 
						#("Add Hidden","button",scaleForDisplay 80 displayScale,"layersCols"),
						#("Add Layers","button",scaleForDisplay 80 displayScale,"layersCols"),  
						#("Use Sunpoints","check",scaleForDisplay 63 displayScale,"sunpointsCols"),
						#("Show Sunpoints","check",scaleForDisplay 63 displayScale,"sunpointsCols"), 
						#("Point -> Sun","button",scaleForDisplay 86 displayScale,"sunpointsCols"),
						#("Sun -> Point","button",scaleForDisplay 86 displayScale,"sunpointsCols"),
						#(" ","text",scaleForDisplay 11 displayScale,"none"),  
						#("Use Resolution","check",scaleForDisplay 73 displayScale,"resolutionCols"), 
						#("Width","number",scaleForDisplay 65 displayScale,"resolutionCols"), 
						#("Height","number",scaleForDisplay 65 displayScale,"resolutionCols"), 
						#("Get Res.","button",scaleForDisplay 95 displayScale,"resolutionCols"),
						#(" ","text",scaleForDisplay 11 displayScale,"none"),  
						#("Use HDRI","check",scaleForDisplay 63 displayScale,"hdriCols"),  
						#("HDRI Map","button",scaleForDisplay 86 displayScale,"hdriCols"),
						#("Link HDRI","check",scaleForDisplay 63 displayScale,"hdriCols"),
						#("Edit Map","button",scaleForDisplay 86 displayScale,"hdriCols"),
						#("Clipping On","check",scaleForDisplay 86 displayScale,"zdepthCols"),
						#("Z-Depth Near","number",scaleForDisplay 106 displayScale,"zdepthCols"),
						#("Z-Depth Far","number",scaleForDisplay 106 displayScale,"zdepthCols"),
						#("Delete Attribute","button",scaleForDisplay 298 displayScale,"attributeCols"),
						#("ID","text",scaleForDisplay 42 displayScale,"system"),
						#("IDMat","text",scaleForDisplay 42 displayScale,"system"),
						#("CamObject","object",scaleForDisplay 42 displayScale,"system")
					)
						
					
					defListNoMod = #(
						#("Select","button",scaleForDisplay 41 displayScale), 
						#("Camera Name","text",scaleForDisplay 201 displayScale),
						#("Add MultiCam Attribute","button",scaleForDisplay 389 displayScale),
						#("ID","text",scaleForDisplay 42 displayScale),
						#("CamObject","object",scaleForDisplay 42 displayScale)
					)

					dgvWidth = (local c = 0; for i=1 to defList.count - 2 do c= c+defList[i][3];c) + 3 --1196
					dgvWidthWithBar = dgvWidth + 17--(scaleForDisplay 17 displayScale) --1212
					dgvRowHeight = scaleForDisplay 25 displayScale
					dgvHeaderRowHeight = scaleForDisplay 32 displayScale
					
					owner.initStyles()
		  			
					dgv.Dock = dgv.Dock.Fill
		  			dgv.RowHeadersVisible = false
					
		  			populateColumns dgv defList
					styleDGV dgv
		  			populateDGV dgv noMod:true

					dgvNoMod.Dock = dgvNoMod.Dock.Fill
		  			dgvNoMod.RowHeadersVisible = false

					populateColumns dgvNoMod defListNoMod
					styleDGV dgvNoMod
		  			populateDGV dgvNoMod noMod:false

		  			dgvUpdateSize dgv dgvNoMod
					
					local dgvScale = (1.0*dgvNoMod.width) / dgvNoMod.size.width
								
					--dgv.SelectionMode=(dotNetClass "System.Windows.Forms.DataGridViewSelectionMode").FullRowSelect

					callBacks.AddScript #systemPreReset "closeRolloutFloater  multiCamListerFloater" id:#MultiCamListerDialog
					callBacks.AddScript #systemPreNew "closeRolloutFloater  multiCamListerFloater" id:#MultiCamListerDialog
					callBacks.AddScript #filePreOpen "closeRolloutFloater  multiCamListerFloater" id:#MultiCamListerDialog
					
					--post delete/pre-delete executes 
					callbacks.addscript #selectedNodesPreDelete "MultiCamLister.preDeleteFN()" id:#MultiCamListerDialog
					callBacks.AddScript #selectedNodesPostDelete "MultiCamLister.postDeleteFN()" id:#MultiCamListerDialog

					--addWhenChangeHandlers()
			
					if MultiCamListerNodeEventCallback == undefined then
					(
						MultiCamListerNodeEventCallback = NodeEventCallback mouseUp:true delay:500 selectionChanged:selectionFN nameChanged:nameChangeFn added:addedNodeFN --displayPropertiesChanged:attributeUpdateFN userPropertiesChanged:testUserChange
					)
					else MultiCamListerNodeEventCallback.enabled = true
					
					MultiCamListerOpen = true

					updateHiddenColumns()
				)
				

				on MultiCamLister_RO close do
				(
					dgv.EndEdit()
					dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
					dgv.ClearSelection()

					dgvNoMod.EndEdit()
					dgvNoMod.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
					dgvNoMod.ClearSelection()
					
					callBacks.RemoveScripts id:#MultiCamListerDialog
					--deleteAllChangeHandlers id:#MultiCamListerWhenHandler
					if MultiCamListerNodeEventCallback != undefined then MultiCamListerNodeEventCallback.enabled = false
					MultiCamListerNodeEventCallback = undefined
					--multiCamParamCH = undefined
					--multiCamDeleteCH = undefined
					MultiCamListerOpen =  false
					MultiCamLister = undefined
					gc light:true 
				)
				
				on clock tick do
				(
					currFocus = (owner.floaterHWND == owner.windowDotNetObj.getForegroundWindow())
					if prevFocus != currFocus do 
					(
						--lblFocus.text = if currFocus then "IN FOCUS" else "OUT OF FOCUS"
						
						dgv.EndEdit()
						dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
					

						dgvNoMod.EndEdit()
						dgvNoMod.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
					)

					prevFocus = currFocus
				)
				
				on dgv EditingControlShowing val do
				(
		   			owner.textEditBox = val.Control
		   			owner.prevtextEditBoxText = owner.textEditBox.text
		   			dotNet.addEventHandler owner.textEditBox "keyup" owner.enterEscapeFN
				)

				on dgv cellEndEdit val do 
				(
					dotNet.removeAllEventHandlers owner.textEditBox
				)

				on dgvNoMod EditingControlShowing val do
				(
		   			owner.textEditBox = val.Control
		   			owner.prevtextEditBoxText = owner.textEditBox.text
		   			dotNet.addEventHandler owner.textEditBox "keyup" owner.enterEscapeFN
				)
				
				on dgvNoMod cellEndEdit val do 
				(
					dotNet.removeAllEventHandlers owner.textEditBox
				)
				
				on dgv LostFocus val do
				(
					if owner.modalWindowWorkaround == false then 
					(
						-- editing control loses focus when text field is in edit mode, control returns that field, all other controls return undefined
						if dgv.editingControl != undefined then
						(
							--print (dgv.currentcell.selected)
						)
						else
						(
							dgv.EndEdit()
							dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
							dgv.ClearSelection()
						)

						owner.setSelectionCells dgv owner.cameraObjIDs
					)
					else
					(
						hwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
						hwnd = (windows.getChildrenHWND hwnd)[1][1]
						windows.sendMessage  hwnd 0x0207 0 0
						windows.sendMessage  hwnd 0x0208 0 0
					)
					owner.modalWindowWorkaround = false
				)

				--on dgv KeyDown val do 
				--(
				--	print val
				--)
				
				on dgvNoMod LostFocus val do
				(
					if dgvNoMod.editingControl != undefined then
					(

					)
					else
					(
						dgvNoMod.EndEdit()
						dgvNoMod.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
						dgvNoMod.ClearSelection()
					)
					owner.setSelectionCells dgvNoMod owner.cameraObjIDsNoMod
				)
						
				on dgv cellMouseDown val do
				(
					--local startT = timeStamp()
					--local endT = timeStamp()
					--print ("selectionFN: " + (endT- startT) as string)
					owner.prevSelectedRows = owner.getRowsFromSelection dgv
					owner.prevSelectedRowsLessSelf = owner.subtractCellFromSelection owner.prevSelectedRows val.RowIndex
					owner.prevSelectedRowsPlusSelf = owner.addCellToSelection owner.prevSelectedRows val.RowIndex
								
					if (owner.prevSelectedRows.count == 0 or owner.prevSelectedRows.count == 1) then 
					(
						owner.prevSelectedRows = #(val.rowIndex)
						owner.prevSelectedRowsLessSelf = #(val.rowIndex)
						owner.prevSelectedRowsPlusSelf = #(val.rowIndex)
					)
				)
				
				on dgv CellMouseClick val do
				(
					global val_val = val
					if val.RowIndex >= 0 then
					(
						local colName = dgv.Columns.item[val.ColumnIndex].HeaderText

						case colName of
						--case val.ColumnIndex of
						(					
							"Get Range":(--Get FrameRange
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									local obj = owner.getObjectByRow2 dgv row
									setProperty obj.baseObject.MultiCamAttributeData #getFrameRange_btn true
									dgv.rows.item[row].cells.item["First Frame"].value = obj.baseObject.MultiCamAttributeData.firstFrame_sp
									dgv.rows.item[row].cells.item["Last Frame"].value = obj.baseObject.MultiCamAttributeData.lastFrame_sp
								)
							)--end 4
							
							"Clear All":(--Clear All
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv row
										setProperty obj.baseObject.MultiCamAttributeData #clearLayers_btn true
									)
								)
							)--end 7
							
							"Add Hidden":(--Add Hidden
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv row
										setProperty obj.baseObject.MultiCamAttributeData #addHiddenLayers_btn true
									)
								)
							)--end 8
							
							
							"Point -> Sun":(--Get From Sun
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv row
										setProperty obj.baseObject.MultiCamAttributeData #readSunPos_btn true
									)
								)
							)--end 12
							
							"Sun -> Point":(--Move Sun
									if dgv.rows.item[val.RowIndex].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv val.RowIndex
										setProperty obj.baseObject.MultiCamAttributeData #moveSunToPos_btn true
									)
							)--end 13
												
							"Get Res.":(--Get Res
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv row
										setProperty obj.baseObject.MultiCamAttributeData #getImgFrame_btn true
										dgv.rows.item[row].cells.item["Width"].value = obj.baseObject.MultiCamAttributeData.imgWidth_sp
										dgv.rows.item[row].cells.item["Height"].value = obj.baseObject.MultiCamAttributeData.imgHeight_sp
									)
								)
							)--end 18
							
							"HDRI Map":(--HDRI Map
								dgv.CurrentCell = undefined
								dgv.ClearSelection()
								owner.modalWindowWorkaround = true
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv row
										if (obj.baseObject.MultiCamAttributeData.hdriMap_val == undefined) then
										(
											setProperty obj.baseObject.MultiCamAttributeData #hdriMapLoader_val true
											local map = obj.baseObject.MultiCamAttributeData.hdriMap_val
											dgv.rows.item[row].cells.item[colName].value = if map != undefined then map.name else "None"
											dgv.rows.item[row].cells.item["Link HDRI"].value = obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
											dgv.rows.item[row].cells.item["IDMat"].value = if map != undefined then (GetHandleByAnim map) as string else ""
										)
										else
										(
											local qb = QueryBox "There is already a VrayHDRI map assigned. Overwrite with new?"
											if qb == true then
											(
												setProperty obj.baseObject.MultiCamAttributeData #hdriMapLoader_val true
												local map = obj.baseObject.MultiCamAttributeData.hdriMap_val
												dgv.rows.item[row].cells.item[colName].value = if map != undefined then map.name else "None" --map.name
												dgv.rows.item[row].cells.item["Link HDRI"].value = obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
												dgv.rows.item[row].cells.item["IDMat"].value = if map != undefined then (GetHandleByAnim map) as string else ""
											)
										)
									)								
								)
							)--end 21
							
							"Edit Map":(--Edit Map
									if dgv.rows.item[val.RowIndex].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv val.RowIndex
										setProperty obj.baseObject.MultiCamAttributeData #hdriMapEdit_btn true
									)
							)--end 23
							
							"Delete Attribute":(--Delete Attribute
								
								local qb = QueryBox ("Proceed with deleting " + owner.prevSelectedRowsPlusSelf.count as string + " Attributes?")
								if qb then
								(
									for row in owner.prevSelectedRowsPlusSelf do 
									(
										local obj = owner.getObjectByRow2 dgv row
										setProperty obj.baseObject.MultiCamAttributeData #deleteMultiCamCA_val true
									)
								)
							)--end 27
							
						)--end case
					)--end if
				)--end on Click
				
				on dgv CellMouseUp val do
				(
					dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
					
					if val.RowIndex >= 0 then
					(
						local colName = dgv.Columns.item[val.ColumnIndex].HeaderText

						case colName of
						--case val.ColumnIndex of
						(					
							"Select":( --Selection
								clearSelection()
								local rows = owner.getRowsFromSelection dgv
								--dgv.ClearSelection()
								dgvNoMod.ClearSelection()
								select (for row in rows collect (owner.getObjectByRow2 dgv row))
								dgv.Focus()
							)

							"Add Layers":(--Add Layer
								dgv.CurrentCell = undefined
								dgv.ClearSelection()
								owner.modalWindowWorkaround = true
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[colName].readonly != true then
									(
										local obj = owner.getObjectByRow2 dgv row
										--sleep 0.5
										setProperty obj.baseObject.MultiCamAttributeData #addLayers_btn true
									)
								)
							)--end 9
							
							22:(dgv.endEdit())
						)--end case
					)--end if
				)--end on mouseUp
						
				-- ISSUE: this triggers after the active cell is changed and another cell becomes active
				-- use CellMouseUp to trigger a commit otherwise the even won't know there was a change
				-- and not trigger
				on dgv CellValueChanged val do
				(
					if MultiCamListerOpen == true and owner.dgvRefreshing == false then
					(
						local colName = dgv.Columns.item[val.ColumnIndex].HeaderText

						case colName of
						--case val.ColumnIndex of
						(

							"Camera Name":(--Camera Name
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								obj.name = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
							)--end 1
								
							"First Frame":(--First Frame
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
								local nextValue = (dgv.rows.item[val.RowIndex].cells.item["Last Frame"].value) as integer
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								
								if thisValue != undefined and nextValue != undefined then
								(	
									if (thisValue > nextValue) then 
									(
										--Messagebox ("First frame number can't be grater than last frame number.")
										--(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = nextValue
										(dgv.rows.item[val.RowIndex].cells.item["Last Frame"].value) = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer + 1
										obj.baseObject.MultiCamAttributeData.firstFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
									)
									else
									(
										dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
										obj.baseObject.MultiCamAttributeData.firstFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
									)
								)
								else
								(
									Messagebox ("Frame number must be an number.")
									(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevtextEditBoxText
									obj.baseObject.MultiCamAttributeData.firstFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
								)
							)--end 2
							
							"Last Frame":(--Last Frame
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
								local prevValue = (dgv.rows.item[val.RowIndex].cells.item["First Frame"].value) as integer
								local obj = owner.getObjectByRow dgv val.RowIndex
								
								if thisValue != undefined and prevValue != undefined then
								(	
									if (thisValue < prevValue) then 
									(
										--Messagebox ("Last frame number can't be smaller than first frame number.")
										--(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevValue
										(dgv.rows.item[val.RowIndex].cells.item["First Frame"].value) = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer - 1
										obj.baseObject.MultiCamAttributeData.lastFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
									)
									else
									(
										dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
										obj.baseObject.MultiCamAttributeData.lastFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
									)
								)
								else
								(
									Messagebox ("Frame number must be an number.")
									(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevtextEditBoxText
									obj.baseObject.MultiCamAttributeData.lastFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
								)
							)--end 3
							
							"Use Hide Layers":(--Use Layers
								owner.checkSelectedCells dgv val
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									owner.changeControlStatus dgv row thisValue #(7,8,9)
								)
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #useHideLayers_chb thisValue
							)--end 6
								
							"Use Sunpoints":(--Use Sunpoints
								owner.checkSelectedCells dgv val
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									owner.changeControlStatus dgv row thisValue #(11, 12, 13)
									if thisValue == false then dgv.rows.item[val.RowIndex].cells.item["Show Sunpoints"].value = false
								)
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #useSunpoints_param thisValue
							)--end 10
							
							"Show Sunpoints":(--Show Sunpoints
								owner.checkSelectedCells dgv val
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #showSunPoint_btn thisValue
							)--end 11
								
							"Use Resolution":(--Use Resolution
								owner.checkSelectedCells dgv val
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									owner.changeControlStatus dgv row thisValue #(16, 17, 18)
								)
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #useHeightWidth_chb thisValue
							)--end 15

							"Width":(-- Width
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								
								if (thisValue != undefined and thisValue > 0) then
								(	
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
									obj.baseObject.MultiCamAttributeData.imgWidth_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
								)
								else
								(
									Messagebox ("Image width must be an number or a number greater than 0")
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = obj.baseObject.MultiCamAttributeData.imgWidth_sp
								)
							)

							"Height":(-- Height
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								
								if (thisValue != undefined and thisValue > 0) then
								(	
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
									obj.baseObject.MultiCamAttributeData.imgHeight_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
								)
								else
								(
									Messagebox ("Image height must be an number or a number greater than 0")
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = obj.baseObject.MultiCamAttributeData.imgHeight_sp
								)
							)
								
							"Use HDRI":(--Use HDRI
								owner.checkSelectedCells dgv val
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									owner.changeControlStatus dgv row thisValue #(21, 22, 23)
								)	
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #useHDRIMap_val thisValue
							)--end 20
								
							"Link HDRI":(--Link HDRI
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									if dgv.rows.item[row].cells.item[22].readonly != true then
									(				
										local obj = owner.getObjectByRow2 dgv row
										setProperty obj.baseObject.MultiCamAttributeData #hdriMapLink_chb thisValue
										dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value =  obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
									)
								)
							)--end 22

							"Clipping On":(--Clipping On
								owner.checkSelectedCells dgv val
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								owner.setCameraClipping obj #clip thisValue
							)--end 24

							"Z-Depth Near":(--Z-Depth near
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as float
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								if (thisValue != undefined and thisValue >= 0) then
								(	
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as float
									owner.setCameraClipping obj #near (thisValue as float)
								)
								else
								(
									Messagebox ("Clipping near must be an number or a number greater or equal to 0")
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = getCamaraClipping obj #near
								)
							)--end 25

							"Z-Depth Far":(--Z-Depth Far
								local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as float
								local obj = owner.getObjectByRow2 dgv val.RowIndex
								if (thisValue != undefined and thisValue >= 0) then
								(	
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as float
									owner.setCameraClipping obj #far (thisValue as float)
								)
								else
								(
									Messagebox ("Clipping far must be an number or a number greater or equal to 0")
									dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = getCamaraClipping obj #far
								)
							)--end 26
							
						)--end case
					)--end if
				)--end on Change

				on dgvNoMod cellMouseDown val do
				(
					owner.prevSelectedRows = owner.getRowsFromSelection dgvNoMod
					owner.prevSelectedRowsLessSelf = owner.subtractCellFromSelection owner.prevSelectedRows val.RowIndex
					owner.prevSelectedRowsPlusSelf = owner.addCellToSelection owner.prevSelectedRows val.RowIndex
								
					if (owner.prevSelectedRows.count == 0 or owner.prevSelectedRows.count == 1) then 
					(
						owner.prevSelectedRows = #(val.rowIndex)
						owner.prevSelectedRowsLessSelf = #(val.rowIndex)
						owner.prevSelectedRowsPlusSelf = #(val.rowIndex)
					)
					
					--print ("prevSelectedRows" + prevSelectedRows as string)
					--print ("prevSelectedRowsLessSelf" + prevSelectedRowsLessSelf as string)
					--print ("prevSelectedRowsPlusSelf" + prevSelectedRowsPlusSelf as string)
				)

				on dgvNoMod CellValueChanged val do
				(
					if MultiCamListerOpen == true and owner.dgvRefreshing == false then
					(
						case val.ColumnIndex of
						(
							1:(--Camera Name
								--camChangeName = true
								local obj = owner.getObjectByRow2 dgvNoMod val.RowIndex
								obj.name = (dgvNoMod.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)

							)--end 1
						)
					)
				)

				on dgvNoMod CellMouseUp val do
				(
					--dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
					
					if val.RowIndex >= 0 then
					(
						case val.ColumnIndex of
						(					
							0:( --Selection
								clearSelection()
								local rows = owner.getRowsFromSelection dgvNoMod
								dgv.ClearSelection()
								--dgvNoMod.ClearSelection()
								select (for row in rows collect (owner.getObjectByRow2 dgvNoMod row))
								dgvNoMod.Focus()
							)

						)--end case
					)--end if
				)--end on mouseUp
				
				on dgvNoMod CellMouseClick val do
				(
					if val.RowIndex >= 0 then
					(
						case val.ColumnIndex of
						(					
							2:(--Add Modifier
								for row in owner.prevSelectedRowsPlusSelf do 
								(
									local obj = owner.getObjectByRow2 dgvNoMod row
									custAttributes.add obj MultiCamCustomAttribute
								)
								owner.dgvUpdate()
							)--end 2
						)
					)
				)

		  	)--end rollout
			
			MultiCamLister_RO.owner = this
			MultiCamLister_RO
		),--end rollout variable
		
		fn show =
		(
			try(closeRolloutFloater  multiCamListerFloater )catch()
			multiCamListerFloater = newRolloutFloater  "MultiCam Lister 9.6" 673 800
			addRollout MultiCamLister_RO multiCamListerFloater

		),
		
		on create do
		(
			MultiCamLister_RO = createRO()	
		)
	)--end struct
	

	
	on execute do
	(	
		local errorCheck = false
		while errorCheck != true do
		(
			--try to load the submitter modifier
			if checkRenderer() != true then
			(
				MessageBox ("This scirpt only works with V-Ray Advanced renderer. Set the production renderer to V-Ray Advanced.") title:"Renderer is not V-Ray"
				exit
			)
			
			if multiCamUsable != true then
			(
				MessageBox ("MultiCam Lister is not usable, check MAXScript Listener to make sure all MultiCam assets are loaded correctly.") title:"Missing MultiCam Assets"
				exit
			)
	
			global MultiCamLister
			MultiCamLister = MCLStruct()
			MultiCamLister.show()
			errorCheck = true
			
		)--end while
	) -- end on execute
)

-- dgv = multiCamListerFloater.rollouts[1].dgv
-- dgvnomod = multiCamListerFloater.rollouts[1].dgvnoMod