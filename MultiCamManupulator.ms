--------------------------------------------------------------------
-- Generic radius manipulator 
-- Written by Scott Morrison
-- This manipulator sets the radius on any object or modifier with 
-- a parameter named "radius". It creates a circle gizmo of the appropriate 
-- radius centered at the origin in the XY plane.

--http://docs.autodesk.com/3DSMAX/15/ENU/MAXScript-Help/index.html?url=files/GUID-2B1DAC46-F27F-44A1-91F9-6E6C426AAAF1.htm,topicNumber=d30e645360
--https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_1E2277FE_7854_4404_89A9_9D72C07CDBDB_htm

plugin simpleManipulator radiusManip
name:"RadiusManip"
invisible:true
(
	-- Create the green and red colors for the gizmo
	local g = [0, 1, 0], r = [1, 0, 0]
	local start = [50,50,50]
	local end = [0,0,0]
	local movePlane = z_axis
	
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return (findItem (getPropNames target) #radius) != 0

	-- Create the manipulator gizmo.
	-- This is called initially and whenever the manipulator targetchanges
	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		
		-- Set the radius of circle gizmo a little bigger than thetarget radius
		--giz = manip.makeCircle [0,0,0] (target.radius * 1.01) 28

		
		gizLine = manip.makeGizmoShape()
		gizLine.startNewLine()
		local endWorld = end* (inverse node.objecttransform)
		local startWorld = start* (inverse node.objecttransform)
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
		--need to convert x,y,z coords to world after separating into components
		case movePlane of
		(
			x_axis:(
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
			y_axis:(
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
			z_axis:(
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
		)
		
		
		-- Add the circle to the manipulator
		--this.addGizmoShape giz 2 g r
		this.addGizmoShape gizLine 2 g r
		this.addGizmoShape up0Line 2 g r
		this.addGizmoShape up1Line 2 g r
		this.addGizmoShape right0Line 2 g r
		this.addGizmoShape right1Line 2 g r
		this.addGizmoShape dropLine 2 g r
		this.addGizmoMarker #bigbox startWorld 0 g r
		this.addGizmoMarker #hollowBox  endWorld 2 g r
		-- return the ToolTip string
		return node.name + " radius = " + target.radius as string
	)
	

	fn getMostOrthoWorld dir =
	(
		result = z_axis 
		if (abs(dir.x) > abs(dir.y) and abs(dir.x) > abs(dir.z)) then result = x_axis
		else if (abs(dir.y) > abs(dir.x) and abs(dir.y) > abs(dir.z)) then result = y_axis
		result
	)
	
	
	-- mouseMove is called on every mouse move when dragging the manip -- It needs to convert the mouse position 'm' into a new value for the radius
	on mouseMove m which do
	(
		-- Compute the hit-ray in local coordinates
		viewRay = this.getLocalViewRay m
		print(viewRay.dir)
		
		-- Create the XY plane. -- manip.makePlaneFromNormal takes a normal vector and a point -- and creates a plane passing through the point with the given normal
		movePlane = (getMostOrthoWorld viewRay.dir)
		local pl = manip.makePlaneFromNormal movePlane (start* (inverse node.objecttransform)),
		projectedPoint = [0,0,0]
		

		
		-- Intersect the plane with the view ray
		res = pl.intersect viewRay &projectedPoint
		
		-- If the intersection worked, set the radius
		if (res) then target.radius = target.radius
		if res then
		(
			start = projectedPoint * node.objecttransform
		)
	)
)