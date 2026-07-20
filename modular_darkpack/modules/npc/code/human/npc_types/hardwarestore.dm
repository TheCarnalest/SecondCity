/mob/living/carbon/human/npc/hardwarestore
	no_movement = TRUE

/mob/living/carbon/human/npc/hardwarestore/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/hardwarestore)
