/mob/living/carbon/human/npc/shop
	no_movement = TRUE

/mob/living/carbon/human/npc/shop/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop)
