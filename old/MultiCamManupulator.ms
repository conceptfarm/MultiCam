---------------------------------------------------------------------------------------
-- MultiCamManipulator.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Jun 15th 2020
-- Manipulator for editing sun positions of the camera with MultiCam Custom
-- Attribute
---------------------------------------------------------------------------------------

plugin simpleManipulator MultiCamSunManip
name:"MultiCamSunManip"
invisible:true
(
	-- Create the green and red colors for the gizmo
	local g = [0, 1, 0], r = [1, 0, 0], b=[0,0,1]
	local start = [50,50,50]
	local end = [5,5,5]
	local localPlaneName = "z_plane"
	local drawOrtho = false
	
	--transforms local Point3 to world Point3 value
	fn localToWorld n = n * (inverse node.objecttransform)
	
	fn getViewDirectionRay =
	(
		-- The affine TM transforms from world coords to view coords
		-- so we need the inverse of this matrix
		local coordSysTM = Inverse(getViewTM())
		-- The Z axis of this matrix is the view direction.
		local viewDir = -coordSysTM.row3
		-- get the view position from this matrix
		local viewPt = coordSysTM.row4
		return ray viewPt viewDir
	)
	
	fn getViewDirection =
	(
		-- The affine TM transforms from world coords to view coords
		-- so we need the inverse of this matrix
		local coordSysTM = Inverse(getViewTM())
		-- The Z axis of this matrix is the view direction.
		local viewDir = -coordSysTM.row3
		viewDir
	)
	
	--between centre point and radius
	fn getAngle cP rP lpn=
	(
		/*
		int r = (int)Math.sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0));
		int x = x0-r;
		int y = y0-r;
		int width = 2*r;
		int height = 2*r;
		int startAngle = (int) (180/Math.PI*atan2(y1-y0, x1-x0));
		int endAngle = (int) (180/Math.PI*atan2(y2-y0, x2-x0));
		graphics.drawArc(x, y, width, height, startAngle, endAngle);
		
		for(int i=0; i < points;++i) {
		angle1 = i * 2 * Pi / points;
		angle2 = (i+1) * 2 * Pi / points;
		line(OriginX + r * cos( angle1), OriginY + r * sin(angle1), OriginX + r * cos( angle2), OriginY + r * sin(angle2)) ;
	}
		
		
		
		*/
		local cPP = [0,0]
		local rPP = [0,0]
		local nodeTMInv = (inverse node.objecttransform)
		
		case lpn of
		(
			"x_plane":( cPP = [cP.y,cP.z] ; rPP =  [rP.y,rP.z])
			"y_plane":( cPP = [cP.x,cP.z] ; rPP =  [rP.x,rP.z])
			"z_plane":( cPP = [cP.x,cP.y] ; rPP =  [rP.x,rP.y])
		)
		
		local r = distance cPP rPP
		local a = atan2 (rPP.y-cPP.y) (rPP.x - cPP.x)
		local startAngle = a - 180
		local endAngle = a + 180
		--print a
		local gizArc = manip.makeGizmoShape()
		gizArc.startNewLine()
		
		for i = startAngle to (endAngle) by 10 do
		(
			case lpn of
			(
				"x_plane":( 
					local x = cP.y + r * cos(i)
					local y = cP.z + r * sin(i)
					gizArc.addPoint ([cP.x,x,y]* nodeTMInv)
				)
				
				
				
				"y_plane":(
					local x = cP.x + r * cos(i)
					local y = cP.z + r * sin(i)
					gizArc.addPoint ([x,cP.y,y]* nodeTMInv)
				)
				
				
				"z_plane":( 					
					local x = cP.x + r * cos(i)
					local y = cP.y + r * sin(i)
					gizArc.addPoint ([x,y,cP.z]* nodeTMInv)
				)
			)
				

			
		)
		return gizArc
		--gizArc.addPoint endWorld 
		--gizArc.addPoint startWorld
		
	)
	
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return	isProperty target "MultiCamAttributeData"
	
	-- on canManipulate target return true--(findItem (getPropNames target) #radius) != 0
	
	-- Create the manipulator gizmo.
	-- This is called initially and whenever the manipulator targetchanges
	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		
		start = node.baseObject.MultiCamAttributeData.sP_val --[50,50,50]
		end = node.baseObject.MultiCamAttributeData.sT_val
			
		local nodeTMInv = (inverse node.objecttransform)
		local endWorld = end * nodeTMInv
		local startWorld = start * nodeTMInv
		local gizRad = 0.0
		
		gizLine = manip.makeGizmoShape()
		gizLine.startNewLine()
		gizLine.addPoint endWorld 
		gizLine.addPoint startWorld
		
		up0Line = manip.makeGizmoShape()
		up0Line.startNewLine()
		right0Line = manip.makeGizmoShape()
		right0Line.startNewLine()
		up1Line = manip.makeGizmoShape()
		up1Line.startNewLine()
		right1Line = manip.makeGizmoShape()
		right1Line.startNewLine()
		dropLine = manip.makeGizmoShape()
		dropLine.startNewLine()
		diagLine = manip.makeGizmoShape()
		diagLine.startNewLine()
		
		--need to convert x,y,z coords to world after separating into components
		case localPlaneName of
		(
			/*
			"x_plane":(
				up0Line.addPoint endWorld
				up0Line.addPoint [endWorld.x,endWorld.y,startWorld.z]
				
				up1Line.addPoint [endWorld.x,startWorld.y,endWorld.z]
				up1Line.addPoint [endWorld.x,startWorld.y,startWorld.z]
				
				right0Line.addPoint endWorld
				right0Line.addPoint [endWorld.x,startWorld.y,endWorld.z]
				
				right1Line.addPoint [endWorld.x,endWorld.y,startWorld.z]
				right1Line.addPoint [endWorld.x,startWorld.y,startWorld.z]
				
				dropLine.addPoint startWorld
				dropLine.addPoint [endWorld.x,startWorld.y,startWorld.z]
				
				)
			"y_plane":(
				up0Line.addPoint endWorld
				up0Line.addPoint [endWorld.x,endWorld.y,startWorld.z]
				
				up1Line.addPoint [startWorld.x,endWorld.y,endWorld.z]
				up1Line.addPoint [startWorld.x,endWorld.y,startWorld.z]
				
				right0Line.addPoint endWorld
				right0Line.addPoint [startWorld.x,endWorld.y,endWorld.z]
				
				right1Line.addPoint  [endWorld.x,endWorld.y,startWorld.z]
				right1Line.addPoint [startWorld.x,endWorld.y,startWorld.z]
				
				dropLine.addPoint startWorld
				dropLine.addPoint [startWorld.x,endWorld.y,startWorld.z]

				)
			"z_plane":(
				up0Line.addPoint endWorld
				up0Line.addPoint [endWorld.x,startWorld.y,endWorld.z]
				
				up1Line.addPoint [startWorld.x,endWorld.y,endWorld.z]
				up1Line.addPoint [startWorld.x,startWorld.y,endWorld.z]
				
				right0Line.addPoint endWorld
				right0Line.addPoint [startWorld.x,endWorld.y,endWorld.z]
				
				right1Line.addPoint  [endWorld.x,startWorld.y,endWorld.z]
				right1Line.addPoint [startWorld.x,startWorld.y,endWorld.z]
				
				dropLine.addPoint startWorld
				dropLine.addPoint [startWorld.x,startWorld.y,endWorld.z]

				)
			*/
			"x_plane":(
				up0Line.addPoint endWorld
				up0Line.addPoint ([end.x,end.y,start.z] * nodeTMInv)
				
				up1Line.addPoint ([end.x,start.y,end.z] * nodeTMInv)
				up1Line.addPoint ([end.x,start.y,start.z] * nodeTMInv)
				
				right0Line.addPoint endWorld
				right0Line.addPoint ([end.x,start.y,end.z] * nodeTMInv)
				
				right1Line.addPoint ([end.x,end.y,start.z] * nodeTMInv)
				right1Line.addPoint ([end.x,start.y,start.z] * nodeTMInv)
				
				dropLine.addPoint startWorld
				dropLine.addPoint ([end.x,start.y,start.z] * nodeTMInv)
				
				diagLine.addPoint endWorld
				diagLine.addPoint ([end.x,start.y,start.z] * nodeTMInv)
				
				gizRad = distance endWorld ([end.x,start.y,start.z] * nodeTMInv)
				)
			
			"y_plane":(
				up0Line.addPoint endWorld
				up0Line.addPoint ([end.x,end.y,start.z] * nodeTMInv)
				
				up1Line.addPoint ([start.x,end.y,end.z] * nodeTMInv)
				up1Line.addPoint ([start.x,end.y,start.z] * nodeTMInv)
				
				right0Line.addPoint endWorld
				right0Line.addPoint ([start.x,end.y,end.z] * nodeTMInv)
				
				right1Line.addPoint ([end.x,end.y,start.z] * nodeTMInv)
				right1Line.addPoint ([start.x,end.y,start.z] * nodeTMInv)
				
				dropLine.addPoint startWorld
				dropLine.addPoint ([start.x,end.y,start.z] * nodeTMInv)
				
				diagLine.addPoint endWorld
				diagLine.addPoint ([start.x,end.y,start.z] * nodeTMInv)
				
				gizRad = distance endWorld ([start.x,end.y,start.z] * nodeTMInv)
				)
			
			"z_plane":(
				up0Line.addPoint endWorld
				up0Line.addPoint ([end.x,start.y,end.z] * nodeTMInv)
				
				up1Line.addPoint ([start.x,end.y,end.z] * nodeTMInv)
				up1Line.addPoint ([start.x,start.y,end.z] * nodeTMInv)
				
				right0Line.addPoint endWorld
				right0Line.addPoint ([start.x,end.y,end.z] * nodeTMInv)
				
				right1Line.addPoint ([end.x,start.y,end.z] * nodeTMInv)
				right1Line.addPoint ([start.x,start.y,end.z] * nodeTMInv)
				
				dropLine.addPoint startWorld
				dropLine.addPoint ([start.x,start.y,end.z] * nodeTMInv)
				
				diagLine.addPoint endWorld
				diagLine.addPoint ([start.x,start.y,end.z] * nodeTMInv)
				
				gizRad = distance endWorld ([start.x,start.y,end.z] * nodeTMInv)
				)
		)
		
		gArc = getAngle end start localPlaneName
		
		if drawOrtho then
		(
			--this.addGizmoShape up0Line 2 g g
			--this.addGizmoShape up1Line 2 g g
			--this.addGizmoShape right0Line 2 g g
			--this.addGizmoShape right1Line 2 g g
			this.addGizmoShape dropLine 2 [1,1,1] [1,1,1]
			this.addGizmoShape diagLine 2 [1,1,1] [1,1,1]
			this.addGizmoShape gArc 2 g g
		)
		
		this.addGizmoShape gizLine 2 g r
		this.addGizmoMarker #bigbox startWorld 0 r r
		this.addGizmoMarker #hollowBox  endWorld 2 g g
			
		-- return the ToolTip string
		return node.name + " Sun Location = " + startWorld as string
	)
	
	fn getMostOrthoWorld2 dir =
	(
		result = (quat 0 0 0 1) --z_axis
		if (abs(dir.x) > abs(dir.y) and abs(dir.x) > abs(dir.z)) then result = (quat 0 0.707107 0 0.707107) -- [1,0,0]
		else if (abs(dir.y) > abs(dir.x) and abs(dir.y) > abs(dir.z)) then result = (quat 0.5 -0.5 -0.5 -0.5) --[0,1,0]
		((result * (inverse node.rotation)) as matrix3).row3
	)
	
	fn getMostOrthoWorld3 dir =
	(
		dir = dir *  node.rotation
		result = [0,0,1]
		planeName = "z_plane"
		if (abs(dir.x) > abs(dir.y) and abs(dir.x) > abs(dir.z)) then (result = [1,0,0]; planeName = "x_plane")
		else if (abs(dir.y) > abs(dir.x) and abs(dir.y) > abs(dir.z)) then (result = [0,1,0]; planeName = "y_plane")
		#((result) * node.rotation, planeName)
	)
	
	fn getMostOrthoWorld dir =
	(		
		result = [0,0,1]
		planeName = "z_plane"
		
		if (abs(dir.x) > abs(dir.y) and abs(dir.x) > abs(dir.z)) then (result = [1,0,0]; planeName = "x_plane")
		else if (abs(dir.y) > abs(dir.x) and abs(dir.y) > abs(dir.z)) then (result = [0,1,0]; planeName = "y_plane")
		#((result) *  inverse ((node.transform).rotationPart as Matrix3), planeName)
	)
	
	-- https://forums.cgsociety.org/t/get-a-ray-in-local-coordinates/1376350
	-- mouseMove is called on every mouse move when dragging the manip 
	-- It needs to convert the mouse position 'm' into a new value for the radius
	on mouseMove m which do
	(
		-- Compute the hit-ray in local coordinates
		local viewRay = this.getLocalViewRay m
		local dir = getViewDirection()
		
		-- Create the XY plane. 
		-- manip.makePlaneFromNormal takes a normal vector and a point 
		-- and creates a plane passing through the point with the given normal
		local localPlane = (getMostOrthoWorld dir)
		localPlaneName = localPlane[2]
		local pl = manip.makePlaneFromNormal localPlane[1] (start * (inverse node.objecttransform))
			
		local projectedPoint = [0,0,0]
			
		-- Intersect the plane with the view ray
		local res = pl.intersect viewRay &projectedPoint
		
		-- If the intersection worked, set the radius
		if res then
		(
			node.targeted = node.targeted
			sp_val = node.baseObject.MultiCamAttributeData.sP_val
			newStart = projectedPoint * (node.objecttransform)
			start = [newStart.x, sP_val.y, sp_val.z]
			node.baseObject.MultiCamAttributeData.sP_val = start 
		)
		else
		(
			print("not res")
			max select
		)
	)
	
	on mouseUp m which do
	(
		drawOrtho = false
		node.baseObject.MultiCamAttributeData.sP_val = start 
		node.targeted = node.targeted
	)
	
	on mouseDown m which do
	(
		drawOrtho = true
	)
)