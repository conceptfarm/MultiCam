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
	local textEditBox = dotnetobject "DataGridViewTextBoxEditingControl"
	local prevtextEditBoxText = ""		


	local floaterHWND = undefined
	local windowDotNetObj = undefined
	local MultiCamLister = undefined
	local modalWindowWorkaround = false
	local cameraObjIDs = #()
	local cameraObjIDsNoMod = #()
	local prevSelectedRows = #()
	local prevSelectedRowsLessSelf = #()
	local prevSelectedRowsPlusSelf = #()

	local dgvMaxHeight = 800
	local dgvRefreshing = false
	local dgvPostDeleteUpdate = false
	local disabledColor = (dotnetclass "system.drawing.color").fromARGB 128 128 128
	local enabledColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
	local enabledStyle = dotnetobject "DataGridViewCellStyle"
		enabledStyle.forecolor = enabledColor
	local disabledStyle = dotnetobject "DataGridViewCellStyle"
		disabledStyle.forecolor = disabledColor
	local gapBetweenDGVs = 20
	local prevScrollPos = 0	
	local displayScale = 1
	local defList = #()
	local defListNoMod = #()
	local dgvWidth = 1196
	local dgvWidthWithBar = 1212
	local dgvRowHeight = 25--26
	local dgvHeaderRowHeight = 32--36

	fn scaleForDisplay n s = 
	(
		--return ((floor (n*s)) as integer)
		n*s
	)
	
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
	)
	
	fn updateModPanel obj = 
	(
		if obj == $ then
		(
			try(modpanel.setcurrentobject(modPanel.getCurrentObject()))catch()
		)
	)

	fn getRowsFromSelection dgvObject = --subtract:true cell:unsupplied = 
	(
		local result = #()
		for i = 0 to dgvObject.SelectedCells.count-1 do
		(
			--print " cell supplied"
			appendifUnique result dgvObject.SelectedCells.item[i].rowindex
		)
		/*if cell != unsupplied then
		(
			--print " cell unsupplied"
			if subtract then 
			(
				local itemToDelete = (findItem result cell)
				if itemToDelete != 0 then 
				(
					--local itemToDelete = (findItem result cell)
					--print ("item to delete " + itemtodelete as string)
					deleteItem result itemToDelete
					--print ("result is " + result as string)
				)
			)
			else if not subtract then
			(
				--print " cell subtract"
				appendifUnique result cell
			)
		)*/
		result
	)

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
	)

	fn subtractCellFromSelection arr cell = 
	(
		local result = copy arr #nomap
		local itemToDelete = (findItem result cell)
		if itemToDelete != 0 then 
		(
			--local itemToDelete = (findItem result cell)
			--print ("item to delete " + itemtodelete as string)
			deleteItem result itemToDelete
			--print ("result is " + result as string)
		)
		result
	)

	fn addCellToSelection arr cell = 
	(
		local result = copy arr #nomap
		appendifUnique result cell
		result
	)
	
	fn checkSelectedCells dgvObject val  = 
	(
		for row in prevSelectedRows do 
		(
			if dgvObject.rows.item[row].cells.item[val.ColumnIndex].readonly != true then
			(
				dgvObject.rows.item[row].cells.item[val.ColumnIndex].value = dgvObject.currentCell.value
			)
		)
	)
	
	fn getObjectByRow dgvObject row = 
	(
		local obj = GetAnimByHandle ((dgvObject.rows.item[row].cells.item["ID"].value) as integerPtr)
		obj		
	)

	fn getObjectByRow2 dgvObject row = 
	(
		local obj = (dgvObject.rows.item[row].cells.item["CamObject"].value).value
		obj		
	)

	fn getRowFromObject obj dgvObject = 
	(
		local result = undefined
		local objID = (GetHandleByAnim obj) as string
		result	
	)

	
	fn getObjectsFromChecked dgvObject col = 
	(
		local objToSelect = (for i = 0 to (dgvObject.rows.count - 1) where ( (dgvObject.rows.item[i].cells.item[col].value)  == true ) collect (GetAnimByHandle ((dgvObject.rows.item[i].cells.item["ID"].value) as integerPtr)))
		objToSelect
	)
	
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
	)
	
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
	)

		
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
							col =  (dotnetobject "DataGridViewButtonColumn")
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
	)

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
	)

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
		
		dgvObject.rows.item[rowIndex].cells.item[20].value = obj.baseObject.MultiCamAttributeData.useHDRIMap_chb
		dgvObject.rows.item[rowIndex].cells.item[21].value = if (obj.baseObject.MultiCamAttributeData.hdriMap_btn != undefined) then (obj.baseObject.MultiCamAttributeData.hdriMap_btn.name) else ("None")
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

		dgvObject.rows.item[rowIndex].cells.item["ID"].value = (GetHandleByAnim obj) as string
		dgvObject.rows.item[rowIndex].cells.item["ID"].ReadOnly = true
		dgvObject.rows.item[rowIndex].cells.item["IDMat"].value = if (obj.baseObject.MultiCamAttributeData.hdriMap_btn != undefined) then ((GetHandleByAnim obj.baseObject.MultiCamAttributeData.hdriMap_btn) as string) else ("None")
		dgvObject.rows.item[rowIndex].cells.item["IDMat"].ReadOnly = true
		dgvObject.rows.item[rowIndex].cells.item["CamObject"].value = dotNetMXSValue obj
		dgvObject.rows.item[rowIndex].cells.item["CamObject"].ReadOnly = true

	)-- end populateRow


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

	)--end populateDGV

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
		multiCamListerFloater.rollouts[1].height = (dgv1.pos[2] + dgv1.height + gapBetweenDGVs + dgv2.height + 40)*displayScale
		multiCamListerFloater.size = [multiCamListerFloater.size[1],(multiCamListerFloater.rollouts[1].height + 30)]
		if multiCamListerFloater.size[2] > dgvMaxHeight then multiCamListerFloater.size = [multiCamListerFloater.size[1], dgvMaxHeight]
	)

	fn dgvUpdate = 
	(
		local dgv = MultiCamLister.dgv
		local dgvNoMod = MultiCamLister.dgvNoMod
		
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
	)
	
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
	)


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


	--------------------------------------
	-- NODE EVENT CALLBACK FUNCTIONS -----
	--------------------------------------
	
	--executes on array of object handles
	fn selectionFN ev ids =
	(
		--local startT = timeStamp()
				--local endT = timeStamp()
		--print ("selectionFN: " + (endT- startT) as string)
		local dgv = MultiCamLister.dgv
		local dgvNoMod = MultiCamLister.dgvNoMod
		
		if dgv.Focused == false and dgvnomod.Focused == false then
		(	
			dgv.ClearSelection()
			dgvNoMod.ClearSelection()
			
			cameraObjIDs = (for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value)
			cameraObjIDsNoMod = (for i = 0 to dgvNoMod.rows.count - 1 collect dgvNoMod.rows.item[i].cells.item["ID"].value)
			
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
	)
	
	fn nameChangeFN ev ids =
	(
		--local startT = timeStamp()
		local dgv = MultiCamLister.dgv
		local dgvNoMod = MultiCamLister.dgvNoMod
		
		if dgv.Focused == false and dgvnomod.Focused == false then
		(	
			cameraObjIDs = for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value
			cameraObjIDsNoMod = for i = 0 to dgvNoMod.rows.count - 1 collect dgvNoMod.rows.item[i].cells.item["ID"].value
			
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
	)

    --executes on array of object handles, need only to find one camera to trigger refresh
	fn addedNodeFN ev ids =
	(
		--local dgv = MultiCamLister.dgv
		--local dgvNoMod = MultiCamLister.dgvNoMod
		--if dgv.Focused == false and dgvnomod.Focused == false then
		--(
			local cameraFound = false
			for id in ids while not cameraFound do 
			(
				if superclassof (GetAnimByHandle id) == camera then
				(
					dgvUpdate()
					cameraFound = true
				)
			)
		--)
	)

	fn attributeUpdateFN ev ids = 
	(
		--this should only need to use the first element, because editing will come from the selected object in the modifier menuitem
		obj = GetAnimByHandle ids[1]
		if (superclassof obj == camera and isAnimPlaying()==false) then
		(
			local dgv = MultiCamLister.dgv
			local dgvNoMod = MultiCamLister.dgvNoMod
			local objID = getHandleByAnim obj
			
			if dgv.Focused == false and dgvNoMod.Focused == false then
			(
				cameraObjIDs = (for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value)
				
				if ((isProperty obj.baseObject "MultiCamAttributeData") == true) then 
				(
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

	)

	global preDeleteFN, postDeleteFN
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
				--print "updated on preDeleteFN"
			)
		)
		
	)

	fn postDeleteFN = 
	(
		if dgvPostDeleteUpdate == true then
		(
			dgvUpdate()
			dgvPostDeleteUpdate == false
		)
		--print "updated on postDeleteFN"
	)

	-- removing this method, seems buggy
	fn addWhenChangeHandlers = 
	(
		/*
		--something buggy here, when deleting all the camera the callback stop executing all togher, needs to be reinitiated
		--executes once for a group of objects
		global multiCamDeleteCH = when cameras deleted id:#MultiCamListerWhenHandler handleAt:#redrawViews obj do 
		(
			print obj
			local dgv = MultiCamLister.dgv
			if dgv.Focused == false then
			(
				dgvUpdate()
			)

		)
		

		--this executes when time is scrubbed, need to fix, not sure how just yet
		global multiCamParamCH = when parameters cameras change id:#MultiCamListerWhenHandler handleAt:#redrawViews obj do 
		(
			--print sliderTime
			--local obj = GetAnimByHandle nd[1]
			if (superclassof obj == camera and isAnimPlaying()==false) then
			(
				local dgv = MultiCamLister.dgv
				local dgvNoMod = MultiCamLister.dgvNoMod
				local objID = getHandleByAnim obj
				
				if dgv.Focused == false and dgvNoMod.Focused == false then
				(
					cameraObjIDs = (for i = 0 to dgv.rows.count - 1 collect dgv.rows.item[i].cells.item["ID"].value)
					
					if ((isProperty obj.baseObject "MultiCamAttributeData") == true) then 
					(
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
		)*/
	)--end fn



	--------------------------------------
	-- ROLLOUT  --------------------------
	--------------------------------------
	
	rollout MultiCamLister "MultiCam Lister" --width:1196 height:800
	( 		 
		button Refresh_btn "Refresh" --visible:false
		label editSection_lbl "Edit Camera Properties:" width:120 across:2 align:#left offset:[5,5]
		radiobuttons editSections_rb "" labels:#( "Sunpoints", "Layers", "Resolution", "HDRI") default:1  columns:4 align:#left offsets:#([0,0],[5,0],[0,0],[8,0]) offset:[-180,5]
		label lblFocus "IN FOCUS" --visible:false
		timer clock interval:500
		dotnetcontrol dgv "DataGridView"  align:#center width:633 height:600 offset:[0,5]
		dotnetcontrol dgvNoMod "DataGridView"  align:#center width:633 height:600 offset:[0,gapBetweenDGVs]
		

		local prevFocus = true, currFocus = true
		
		on clock tick do
		(
			currFocus = floaterHWND == (windowDotNetObj.getForegroundWindow())
			if prevFocus != currFocus do 
			(
				lblFocus.text = if currFocus then "IN FOCUS" else "OUT OF FOCUS"
				
				dgv.EndEdit()
				dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
			

				dgvNoMod.EndEdit()
				dgvNoMod.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
			)

			prevFocus = currFocus
		)

		on Refresh_btn pressed do
		(
			dgvUpdate()
		)
		
		fn updateHiddenColumns =
		(
			layersCols = #("Use Hide Layers","Clear All","Add Hidden","Add Layers")
			sunpointsCols =  #("Use Sunpoints","Show Sunpoints","Point -> Sun","Sun -> Point")
			resolutionCols =  #("Use Resolution","Width","Height","Get Res.")
			hdriCols = #("Use HDRI","HDRI Map","Link HDRI","Edit Map")
			
			for i=6 to dgv.columns.count - 1 do dgv.columns.item[i].visible = false
			
			case editSections_rb.state of
			(
				1: (for col in sunpointsCols do dgv.columns.item[col].visible = true)
				2: (for col in layersCols do dgv.columns.item[col].visible = true)
				3: (for col in resolutionCols do dgv.columns.item[col].visible = true)
				4: (for col in hdriCols do dgv.columns.item[col].visible = true)
			)
		)

		on editSections_rb changed state do (updateHiddenColumns())

		on MultiCamLister open do
		(
			 
  			if NOT isKindOf windowDotNetObj dotNetObject do windowDotNetObj = getWindowClass()
  			floaterHWND = windowDotNetObj.getForegroundWindow()		
			if ((maxVersion())[1] > 18000) then (displayScale = ((sysInfo.DesktopSizeUnscaled)/(sysInfo.desktopSize)).x)
			print("Dispay Scale is " + displayScale as string)

			-- Name, Type, Width
			defList = #(
				#("Select","button",scaleForDisplay 41 displayScale),
				#("Camera Name","text",scaleForDisplay 101 displayScale),
				#("First Frame","number",scaleForDisplay 50 displayScale), 
				#("Last Frame","number",scaleForDisplay 50 displayScale), 
				#("Get Range","button",scaleForDisplay 80 displayScale),  
				#(" ","text",scaleForDisplay 11 displayScale),  
				#("Use Hide Layers","check",scaleForDisplay 58 displayScale),
				#("Clear All","button",scaleForDisplay 80 displayScale), 
				#("Add Hidden","button",scaleForDisplay 80 displayScale),
				#("Add Layers","button",scaleForDisplay 80 displayScale),  
				#("Use Sunpoints","check",scaleForDisplay 63 displayScale),
				#("Show Sunpoints","check",scaleForDisplay 63 displayScale), 
				#("Point -> Sun","button",scaleForDisplay 86 displayScale),
				#("Sun -> Point","button",scaleForDisplay 86 displayScale),
				#(" ","text",scaleForDisplay 11 displayScale),  
				#("Use Resolution","check",scaleForDisplay 73 displayScale), 
				#("Width","number",scaleForDisplay 65 displayScale), 
				#("Height","number",scaleForDisplay 65 displayScale), 
				#("Get Res.","button",scaleForDisplay 95 displayScale),
				#(" ","text",scaleForDisplay 11 displayScale),  
				#("Use HDRI","check",scaleForDisplay 63 displayScale),  
				#("HDRI Map","button",scaleForDisplay 86 displayScale),
				#("Link HDRI","check",scaleForDisplay 63 displayScale),
				#("Edit Map","button",scaleForDisplay 86 displayScale),
				#("ID","text",scaleForDisplay 42 displayScale),
				#("IDMat","text",scaleForDisplay 42 displayScale),
				#("CamObject","object",scaleForDisplay 42 displayScale)
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
			callbacks.addscript #selectedNodesPreDelete "preDeleteFN()" id:#MultiCamListerDialog
			callBacks.AddScript #selectedNodesPostDelete "postDeleteFN()" id:#MultiCamListerDialog

			--addWhenChangeHandlers()
	
			if MultiCamListerNodeEventCallback == undefined then
			(
				MultiCamListerNodeEventCallback = NodeEventCallback mouseUp:true delay:500 selectionChanged:selectionFN nameChanged:nameChangeFn added:addedNodeFN displayPropertiesChanged:attributeUpdateFN
			)
			else MultiCamListerNodeEventCallback.enabled = true
			
			MultiCamListerOpen = true

			updateHiddenColumns()
		)
		

		on MultiCamLister close do
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
			gc light:true 
			MultiCamListerOpen =  false	
		)
				
		on dgv EditingControlShowing val do
		(
   			textEditBox = val.Control
   			prevtextEditBoxText = textEditBox.text
   			dotNet.addEventHandler textEditBox "keyup" enterEscapeFN
		)

		on dgv cellEndEdit val do 
		(
			dotNet.removeAllEventHandlers textEditBox
		)

		on dgvNoMod EditingControlShowing val do
		(
   			textEditBox = val.Control
   			prevtextEditBoxText = textEditBox.text
   			dotNet.addEventHandler textEditBox "keyup" enterEscapeFN
		)
		
		on dgvNoMod cellEndEdit val do 
		(
			dotNet.removeAllEventHandlers textEditBox
		)
		
		on dgv LostFocus val do
		(
			if modalWindowWorkaround == false then 
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

				setSelectionCells dgv cameraObjIDs
			)
			else
			(
				hwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
				hwnd = (windows.getChildrenHWND hwnd)[1][1]
				windows.sendMessage  hwnd 0x0207 0 0
				windows.sendMessage  hwnd 0x0208 0 0
			)
			modalWindowWorkaround = false
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
			setSelectionCells dgvNoMod cameraObjIDsNoMod
		)
				
		on dgv cellMouseDown val do
		(
			--local startT = timeStamp()
			--local endT = timeStamp()
			--print ("selectionFN: " + (endT- startT) as string)
			prevSelectedRows = getRowsFromSelection dgv
			prevSelectedRowsLessSelf = subtractCellFromSelection prevSelectedRows val.RowIndex
			prevSelectedRowsPlusSelf = addCellToSelection prevSelectedRows val.RowIndex
						
			if (prevSelectedRows.count == 0 or prevSelectedRows.count == 1) then 
			(
				prevSelectedRows = #(val.rowIndex)
				prevSelectedRowsLessSelf = #(val.rowIndex)
				prevSelectedRowsPlusSelf = #(val.rowIndex)
			)
			--print "cellmousedown"
			
			--print ("prevSelectedRows" + prevSelectedRows as string)
			--print ("prevSelectedRowsLessSelf" + prevSelectedRowsLessSelf as string)
			--print ("prevSelectedRowsPlusSelf" + prevSelectedRowsPlusSelf as string)
		)
		
		on dgv CellMouseClick val do
		(
			if val.RowIndex >= 0 then
			(
				case val.ColumnIndex of
				(					
					4:(--Get FrameRange
						for row in prevSelectedRowsPlusSelf do 
						(
							local obj = getObjectByRow2 dgv row
							setProperty obj.baseObject.MultiCamAttributeData #getFrameRange_btn true
							dgv.rows.item[row].cells.item[2].value = obj.baseObject.MultiCamAttributeData.firstFrame_sp
							dgv.rows.item[row].cells.item[3].value = obj.baseObject.MultiCamAttributeData.lastFrame_sp
						)
					)--end 4
					
					7:(--Clear All
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[7].readonly != true then
							(
								local obj = getObjectByRow2 dgv row
								setProperty obj.baseObject.MultiCamAttributeData #clearLayers_btn true
							)
						)
					)--end 7
					
					8:(--Add Hidden
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[8].readonly != true then
							(
								local obj = getObjectByRow2 dgv row
								setProperty obj.baseObject.MultiCamAttributeData #addHiddenLayers_btn true
							)
						)
					)--end 8
					


									
					12:(--Get From Sun
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[12].readonly != true then
							(
								local obj = getObjectByRow2 dgv row
								setProperty obj.baseObject.MultiCamAttributeData #readSunPos_btn true
							)
						)
					)--end 12
					
					13:(--Move Sun
							if dgv.rows.item[val.RowIndex].cells.item[13].readonly != true then
							(
								local obj = getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #moveSunToPos_btn true
							)
					)--end 13
										
					18:(--Get Res
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[18].readonly != true then
							(
								local obj = getObjectByRow2 dgv row
								setProperty obj.baseObject.MultiCamAttributeData #getImgFrame_btn true
								dgv.rows.item[row].cells.item[16].value = obj.baseObject.MultiCamAttributeData.imgWidth_sp
								dgv.rows.item[row].cells.item[17].value = obj.baseObject.MultiCamAttributeData.imgHeight_sp
							)
						)
					)--end 18
					
					21:(--HDRI Map
						dgv.CurrentCell = undefined
						dgv.ClearSelection()
						modalWindowWorkaround = true
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[21].readonly != true then
							(
								local obj = getObjectByRow2 dgv row
								if (obj.baseObject.MultiCamAttributeData.hdriMap_btn == undefined) then
								(
									local map = VrayHDRI()
									map.name = "HDRI for " + obj.name
									setProperty obj.baseObject.MultiCamAttributeData #hdriMapLoader_btn true
									dgv.rows.item[row].cells.item[25].value = (GetHandleByAnim map) as string
									dgv.rows.item[row].cells.item[21].value = map.name
									dgv.rows.item[row].cells.item[22].value = obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
								)
								else
								(
									local qb = QueryBox "There is already a VrayHDRI map assigned. Overwrite with new?"
									if qb == true then
									(
										local map = VrayHDRI()
										map.name = "HDRI for " + obj.name
										setProperty obj.baseObject.MultiCamAttributeData #hdriMapLoader_btn true
										dgv.rows.item[row].cells.item[25].value = (GetHandleByAnim map) as string
										dgv.rows.item[row].cells.item[21].value = map.name
										dgv.rows.item[row].cells.item[22].value = obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
									)
								)
							)								
						)
					)--end 21
					
					23:(--Edit Map
							if dgv.rows.item[val.RowIndex].cells.item[23].readonly != true then
							(
								local obj = getObjectByRow2 dgv val.RowIndex
								setProperty obj.baseObject.MultiCamAttributeData #hdriMapEdit_btn true
							)
					)--end 23
					
				)--end case
			)--end if
		)--end on Click
		
		on dgv CellMouseUp val do
		(
			dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
			
			if val.RowIndex >= 0 then
			(
				case val.ColumnIndex of
				(					
					0:( --Selection
						clearSelection()
						local rows = getRowsFromSelection dgv
						--dgv.ClearSelection()
						dgvNoMod.ClearSelection()
						select (for row in rows collect (getObjectByRow2 dgv row))
						dgv.Focus()
					)

					9:(--Add Layer
						dgv.CurrentCell = undefined
						dgv.ClearSelection()
						modalWindowWorkaround = true
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[9].readonly != true then
							(
								local obj = getObjectByRow2 dgv row
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
			if MultiCamListerOpen == true and dgvRefreshing == false then
			(
				case val.ColumnIndex of
				(

					1:(--Camera Name
						local obj = getObjectByRow2 dgv val.RowIndex
						obj.name = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
					)--end 1
						
					2:(--First Frame
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local nextValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex + 1].value) as integer
						local obj = getObjectByRow2 dgv val.RowIndex
						
						if thisValue !=undefined and nextValue != undefined then
						(	
							if (thisValue > nextValue) then 
							(
								--Messagebox ("First frame number can't be grater than last frame number.")
								--(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = nextValue
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex + 1].value) = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer + 1
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
					
					3:(--Last Frame
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local prevValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex - 1].value) as integer
						local obj = getObjectByRow dgv val.RowIndex
						
						if thisValue != undefined and prevValue != undefined then
						(	
							if (thisValue < prevValue) then 
							(
								--Messagebox ("Last frame number can't be smaller than first frame number.")
								--(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevValue
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex - 1].value) = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer - 1
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
					
					6:(--Use Layers
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(7,8,9)

						)
						local obj = getObjectByRow2 dgv val.RowIndex
						setProperty obj.baseObject.MultiCamAttributeData #useHideLayers_chb thisValue
					)--end 6
						
					10:(--Use Sunpoints
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(11, 12, 13)
							if thisValue == false then dgv.rows.item[val.RowIndex].cells.item["Show Sunpoints"].value = false
						)
						local obj = getObjectByRow2 dgv val.RowIndex
						setProperty obj.baseObject.MultiCamAttributeData #useSunpoints_param thisValue
						--updateModPanel obj
					)--end 10
					
					11:(--Show Sunpoints
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						
						local obj = getObjectByRow2 dgv val.RowIndex
						setProperty obj.baseObject.MultiCamAttributeData #showSunPoint_btn thisValue
					)--end 11
						
					15:(--Use Resolution
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(16, 17, 18)
						)
						local obj = getObjectByRow2 dgv val.RowIndex
						setProperty obj.baseObject.MultiCamAttributeData #useHeightWidth_chb thisValue
					)--end 15

					16:(-- Width
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local obj = getObjectByRow2 dgv val.RowIndex
						
						if thisValue != undefined then
						(	
							dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
							obj.baseObject.MultiCamAttributeData.imgWidth_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
						)
						else
						(
							Messagebox ("Image width must be an number.")
							dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = obj.baseObject.MultiCamAttributeData.imgWidth_sp
						)
					)

					17:(-- Height
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local obj = getObjectByRow2 dgv val.RowIndex
						
						if thisValue != undefined then
						(	
							dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
							obj.baseObject.MultiCamAttributeData.imgHeight_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
						)
						else
						(
							Messagebox ("Image height must be an number.")
							dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = obj.baseObject.MultiCamAttributeData.imgHeight_sp
						)
					)
						
					20:(--Use HDRI
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(21, 22, 23)
						)	
						local obj = getObjectByRow2 dgv val.RowIndex
						setProperty obj.baseObject.MultiCamAttributeData #useHDRIMap_chb thisValue
					)--end 20
						
					22:(--Link HDRI
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[22].readonly != true then
							(				
								local obj = getObjectByRow2 dgv row
								setProperty obj.baseObject.MultiCamAttributeData #hdriMapLink_chb thisValue
								dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value =  obj.baseObject.MultiCamAttributeData.hdriMapLink_chb
							)
						)
					)--end 22
					
				)--end case
			)--end if
		)--end on Change

		on dgvNoMod cellMouseDown val do
		(
			prevSelectedRows = getRowsFromSelection dgvNoMod
			prevSelectedRowsLessSelf = subtractCellFromSelection prevSelectedRows val.RowIndex
			prevSelectedRowsPlusSelf = addCellToSelection prevSelectedRows val.RowIndex
						
			if (prevSelectedRows.count == 0 or prevSelectedRows.count == 1) then 
			(
				prevSelectedRows = #(val.rowIndex)
				prevSelectedRowsLessSelf = #(val.rowIndex)
				prevSelectedRowsPlusSelf = #(val.rowIndex)
			)
			
			--print ("prevSelectedRows" + prevSelectedRows as string)
			--print ("prevSelectedRowsLessSelf" + prevSelectedRowsLessSelf as string)
			--print ("prevSelectedRowsPlusSelf" + prevSelectedRowsPlusSelf as string)
		)

		on dgvNoMod CellValueChanged val do
		(
			if MultiCamListerOpen == true and dgvRefreshing == false then
			(
				case val.ColumnIndex of
				(
					1:(--Camera Name
						--camChangeName = true
						local obj = getObjectByRow2 dgvNoMod val.RowIndex
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
						local rows = getRowsFromSelection dgvNoMod
						dgv.ClearSelection()
						--dgvNoMod.ClearSelection()
						select (for row in rows collect (getObjectByRow2 dgvNoMod row))
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
						for row in prevSelectedRowsPlusSelf do 
						(
							local obj = getObjectByRow2 dgvNoMod row
							custAttributes.add obj MultiCamCustomAttribute
							--addModifier obj (MultiCamAttribute ())
						)
						dgvUpdate()
					)--end 2

				)
			)
		)

  	)--end rollout
	
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

			try(closeRolloutFloater  multiCamListerFloater )catch()
			multiCamListerFloater = newRolloutFloater  "MultiCam Lister 9.3" (673) 800
			addRollout MultiCamLister multiCamListerFloater
			--try(destroydialog MultiCamLister )catch()
			--createDialog MultiCamLister width:1196 height:800 lockWidth:true lockHeight:false
			errorCheck = true
			
		)--end while
	) -- end on execute
)

-- dgv = multiCamListerFloater.rollouts[1].dgv
-- dgvnomod = multiCamListerFloater.rollouts[1].dgvnoMod
