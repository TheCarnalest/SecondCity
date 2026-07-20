/mob/living/carbon/human/npc/garden
	no_movement = TRUE

/mob/living/carbon/human/npc/garden/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/garden)
