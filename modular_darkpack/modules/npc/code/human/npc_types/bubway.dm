/mob/living/carbon/human/npc/bubway
	no_movement = TRUE

/mob/living/carbon/human/npc/bubway/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/bubway)
