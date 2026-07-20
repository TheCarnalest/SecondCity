/mob/living/carbon/human/npc/campingstore
	no_movement = TRUE

/mob/living/carbon/human/npc/campingstore/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/campingstore)
