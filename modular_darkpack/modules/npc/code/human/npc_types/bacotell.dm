/mob/living/carbon/human/npc/bacotell
	no_movement = TRUE

/mob/living/carbon/human/npc/bacotell/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/bacotell)
