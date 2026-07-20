/mob/living/carbon/human/npc/incel
	no_movement = TRUE

/mob/living/carbon/human/npc/incel/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/usualmale)
