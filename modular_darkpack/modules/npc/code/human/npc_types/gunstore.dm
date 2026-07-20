/mob/living/carbon/human/npc/gunstore
	no_movement = TRUE

/mob/living/carbon/human/npc/gunstore/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/gunstore)
