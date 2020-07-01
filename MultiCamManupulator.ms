---------------------------------------------------------------------------------------
-- MultiCamManipulator.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Jun 15th 2020
-- Manipulator for editing sun positions of the camera with MultiCam Custom
-- Attribute
---------------------------------------------------------------------------------------

plugin simpleManipulator MultiCamSunManipX
name:"MultiCamSunManipX"
invisible:true
(
	local start = [50,50,50]
	local localPlaneName = "x_plane"
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return	isProperty target "MultiCamAttributeData"
	
	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		
		start = node.baseObject.MultiCamAttributeData.sP_val --[50,50,50]
					
		local nodeTMInv = (inverse node.objecttransform)
		local startWorld = start * nodeTMInv
		
		scaleFactor = gw.nonScalingObjectSize() * (gw.getVPWorldWidth start) / 360.0
		
		
		up0Line = manip.makeGizmoShape()
		up0Line.startNewLine()
		up0Line.addPoint startWorld
		up0LineEnd = ([start.x+25*scaleFactor,start.y,start.z] * nodeTMInv)
		up0Line.addPoint up0LineEnd
		--need to convert x,y,z coords to world after separating into components
				
						
		this.addGizmoShape up0Line 0 [1,0,0] [1,1,0] 
		this.addGizmoMarker #bigbox  up0LineEnd 0 [1,0,0] [1,1,0] 
			
		-- return the ToolTip string
		return node.name + " Sun Location = " + startWorld as string
	)
	
	on mouseMove m which do
	(
		-- Compute the hit-ray in local coordinates
		local viewRay = this.getLocalViewRay m
		--local dir = getViewDirection()
		
		-- Create the XY plane. 
		-- manip.makePlaneFromNormal takes a normal vector and a point 
		-- and creates a plane passing through the point with the given normal
		local localPlane = [0,0,1] *  inverse ((node.transform).rotationPart as Matrix3)
		localPlaneName = "y_plane"
		local pl = manip.makePlaneFromNormal localPlane (start * (inverse node.objecttransform))
			
		local projectedPoint = [0,0,0]
			
		-- Intersect the plane with the view ray
		local res = pl.intersect viewRay &projectedPoint
		
		-- If the intersection worked, set the radius
		if res then
		(
			node.targeted = node.targeted
			sp_val = node.baseObject.MultiCamAttributeData.sP_val
			newStart = projectedPoint * (node.objecttransform)
			start = [newStart.x, sP_val.y, sP_val.z]
			node.baseObject.MultiCamAttributeData.sP_val = start 
		)
	)

	on mouseUp m which do
	(
		drawOrtho = false
		node.baseObject.MultiCamAttributeData.sP_val = start 
		node.targeted = node.targeted
	)
)

plugin simpleManipulator MultiCamSunManipY
name:"MultiCamSunManipY"
invisible:true
(
	local start = [50,50,50]
	local localPlaneName = "y_plane"
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return	isProperty target "MultiCamAttributeData"
	
	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		
		start = node.baseObject.MultiCamAttributeData.sP_val --[50,50,50]
					
		local nodeTMInv = (inverse node.objecttransform)
		local startWorld = start * nodeTMInv
		
		scaleFactor = gw.nonScalingObjectSize() * (gw.getVPWorldWidth start) / 360.0
		
		up0Line = manip.makeGizmoShape()
		up0Line.startNewLine()
		up0Line.addPoint startWorld
		up0LineEnd = ([start.x,start.y+25*scaleFactor,start.z] * nodeTMInv)
		up0Line.addPoint up0LineEnd
		--need to convert x,y,z coords to world after separating into components
				
						
		this.addGizmoShape up0Line 0 [0,1,0] [1,1,0] 
		this.addGizmoMarker #bigbox  up0LineEnd 0 [0,1,0] [1,1,0] 
			
		-- return the ToolTip string
		return node.name + " Sun Location = " + startWorld as string
	)
	
	on mouseMove m which do
	(
		-- Compute the hit-ray in local coordinates
		local viewRay = this.getLocalViewRay m
		--local dir = getViewDirection()
		
		-- Create the XY plane. 
		-- manip.makePlaneFromNormal takes a normal vector and a point 
		-- and creates a plane passing through the point with the given normal
		local localPlane = [0,0,1] *  inverse ((node.transform).rotationPart as Matrix3)
		localPlaneName = "y_plane"
		local pl = manip.makePlaneFromNormal localPlane (start * (inverse node.objecttransform))
			
		local projectedPoint = [0,0,0]
			
		-- Intersect the plane with the view ray
		local res = pl.intersect viewRay &projectedPoint
		
		-- If the intersection worked, set the radius
		if res then
		(
			node.targeted = node.targeted
			sp_val = node.baseObject.MultiCamAttributeData.sP_val
			newStart = projectedPoint * (node.objecttransform)
			start = [sP_val.x, newStart.y, sP_val.z]
			node.baseObject.MultiCamAttributeData.sP_val = start 
		)
	)

	on mouseUp m which do
	(
		drawOrtho = false
		node.baseObject.MultiCamAttributeData.sP_val = start 
		node.targeted = node.targeted
	)
)

plugin simpleManipulator MultiCamSunManipZ
name:"MultiCamSunManipZ"
invisible:true
(
	local start = [50,50,50]
	local end = [5,5,5]
	local localPlaneName = "z_plane"
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return	isProperty target "MultiCamAttributeData"
	
	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		
		start = node.baseObject.MultiCamAttributeData.sP_val --[50,50,50]
					
		local nodeTMInv = (inverse node.objecttransform)
		local startWorld = start * nodeTMInv
		
		scaleFactor = gw.nonScalingObjectSize() * (gw.getVPWorldWidth start) / 360.0
			
		up0Line = manip.makeGizmoShape()
		up0Line.startNewLine()
		up0Line.addPoint startWorld
		up0LineEnd = ([start.x,start.y,start.z+25*scaleFactor] * nodeTMInv)
		up0Line.addPoint up0LineEnd
		--need to convert x,y,z coords to world after separating into components
				
						
		this.addGizmoShape up0Line 0 [0,0,1] [1,1,0] 
		this.addGizmoMarker #bigbox  up0LineEnd 0 [0,0,1] [1,1,0]  
			
		-- return the ToolTip string
		return node.name + " Sun Location = " + startWorld as string
	)
	
	on mouseMove m which do
	(
		-- Compute the hit-ray in local coordinates
		local viewRay = this.getLocalViewRay m
		--local dir = getViewDirection()
		
		-- Create the XY plane. 
		-- manip.makePlaneFromNormal takes a normal vector and a point 
		-- and creates a plane passing through the point with the given normal
		local localPlane = [0,1,0] *  inverse ((node.transform).rotationPart as Matrix3)
		localPlaneName = "z_plane"
		local pl = manip.makePlaneFromNormal localPlane (start * (inverse node.objecttransform))
			
		local projectedPoint = [0,0,0]
			
		-- Intersect the plane with the view ray
		local res = pl.intersect viewRay &projectedPoint
		
		-- If the intersection worked, set the radius
		if res then
		(
			node.targeted = node.targeted
			sp_val = node.baseObject.MultiCamAttributeData.sP_val
			newStart = projectedPoint * (node.objecttransform)
			start = [sP_val.x, sP_val.y, newStart.z]
			node.baseObject.MultiCamAttributeData.sP_val = start 
		)
	)

	on mouseUp m which do
	(
		drawOrtho = false
		node.baseObject.MultiCamAttributeData.sP_val = start 
		node.targeted = node.targeted
	)
)


plugin simpleManipulator MultiCamSunManip
name:"MultiCamSunManip"
invisible:true
(
	local start = [50,50,50]
	local end = [5,5,5]
	
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return	isProperty target "MultiCamAttributeData"
	
	-- on canManipulate target return true--(findItem (getPropNames target) #radius) != 0
	
	-- Create the manipulator gizmo.
	-- This is called initially and whenever the manipulator targetchanges
	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		
		start = node.baseObject.MultiCamAttributeData.sP_val
		end = node.baseObject.MultiCamAttributeData.sT_val
			
		local nodeTMInv = (inverse node.objecttransform)
		local endWorld = end * nodeTMInv
		local startWorld = start * nodeTMInv

		
		gizLine = manip.makeGizmoShape()
		gizLine.startNewLine()
		gizLine.addPoint endWorld 
		gizLine.addPoint startWorld
		
		this.addGizmoShape gizLine 2 [1,1,0] [1,1,0]
		this.addGizmoMarker #hollowBox startWorld 2 [1,1,0] [1,1,0]
		this.addGizmoMarker #hollowBox  endWorld 2 [1,1,0] [1,1,0]
			
		-- return the ToolTip string
		--return node.name + " Sun Location = " + startWorld as string
	)
		

)