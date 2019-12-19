plugin modifier TestAttributes
name:"Test Attributes"
classID:#(685321,452287)
extends:EmptyModifier
replaceUI:true
(
	local test_ro

	parameters main rollout:test_ro
	(
		sP_txt type:#string animatable:false ui:sp_txt default:"[10,-70,5]"
		random_btn type:#boolean animatable:false ui:random_btn default:false
		
		on random_btn set val do
		(
			if val == true then
			(
				test_ro.sP_txt.text = "[" + (random 0 1000) as string + "," + (random 0 1000) as string + "," + (random 0 1000) as string + "]"
				random_btn = false
			)
		)
	)

	rollout test_ro "Test Rollout" 
	(
		checkbutton  random_btn " Random "	checked:false 
		edittext sP_txt "sP" text:"[10000,-7000,5500]" 
	)
)
