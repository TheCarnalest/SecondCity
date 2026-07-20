/mob/living/carbon/human/npc/gummaguts
	no_movement = TRUE

/mob/living/carbon/human/npc/gummaguts/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/gummaguts)
