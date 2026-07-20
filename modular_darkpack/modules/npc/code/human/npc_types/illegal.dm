/mob/living/carbon/human/npc/illegal
	no_movement = TRUE

/mob/living/carbon/human/npc/illegal/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/illegal)
