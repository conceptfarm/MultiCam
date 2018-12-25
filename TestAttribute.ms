plugin modifier TestAttributes
name:"Test Attributes"
classID:#(685321,452287)
extends:EmptyModifier
replaceUI:true
(
	local temp = "temp text"
	local thisID = 0
	local GW_displayObjectNames
	parameters main rollout:params
	(
		showPosPoint_btn type:#boolean animatable:false ui:showPosPoint_btn default:false
		sP_txt type:#string animatable:false ui:sp_txt default:"[10,-70,5]"
		--test_txt type:#string animatable:false default:"temp text"
	)
	
	
	
	fn rv = GW_displayObjectNames()
	
	fn GW_displayObjectNames =
	(
		cols = #(yellow,red,blue,green,black)
		gw.setTransform (matrix3 1)
		--print (refs.dependson this)
		--print (refs.dependentNodes this)
		--print (refs.getNumRefs this)
		--print (refs.getReference this 2)
		--print ((refs.dependentNodes this) as string)
		gw.text (execute(this.sP_txt)) temp color:cols[(random 1 cols.count)]
			
		if ((refs.dependentNodes this).count  == 0) then
		(
			print "0"
			unregisterRedrawViewsCallback rv
		)
		
		
		/*
		--this method works but the function is still registered, it just doesn't display anything
		
		if ((refs.dependentNodes this).count  != 0) then
		(
			gw.text (execute(this.sP_txt)) temp color:cols[(random 1 cols.count)]
		)
		else 
		(
			refs.replaceReference this 1 undefined
			refs.replaceReference this 2 undefined
			unregisterRedrawViewsCallback rv
		)
		*/
		gw.enlargeUpdateRect #whole
	)
	
	

		
	rollout params "Test Properties"
	(
		--global rv
		checkbutton  showPosPoint_btn " Display Position Points "	checked:false 
		edittext sP_txt "sP" text:"[10000,-7000,5500]" 

		--global rv
		--fn rv = GW_displayObjectNames()
		on params open do
		(
			temp = selection[1].name
			thisID = selection[1].inode.handle
		)
		
		on showPosPoint_btn changed state do
		(
			if state == true then
			(
				registerRedrawViewsCallback rv
			)
			else
			(
				unregisterRedrawViewsCallback rv
			)
		)
	)
	on params reload do
	(
		MessageBox "reloaded"
	)
	
	on create do
	(
		MessageBox "created"
	)
	
	on postcreate do
	(
		MessageBox "postcreated"
	)
	on postload do
	(
		MessageBox "postloaded"
	)
	
	on update do
	(
		unregisterRedrawViewsCallback rv
		MessageBox "updated"
	)
	
	
	on attachedToNode this do
	(
		MessageBox "attachedToNode "
	)	
	
	
	on detachedFromNode this do
	(
		showPosPoint_btn = false
		gw.clearScreen (box2 0 0 1920 1080) useBkg:true
		unregisterRedrawViewsCallback rv
		unregisterRedrawViewsCallback GW_displayObjectNames
		gw.clearScreen (box2 0 0 1920 1080) useBkg:true
		MessageBox "detached"
	)
	
	on deleted  do
	(
		showPosPoint_btn = false
		gw.clearScreen (box2 0 0 1920 1080) useBkg:true
		unregisterRedrawViewsCallback rv
		unregisterRedrawViewsCallback GW_displayObjectNames
		gw.clearScreen (box2 0 0 1920 1080) useBkg:true
		MessageBox "deleted   "

	)

)