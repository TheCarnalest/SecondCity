/mob/living/carbon/human/npc/pharmacystore
	no_movement = TRUE

/mob/living/carbon/human/npc/pharmacystore/Initialize(mapload)
	. = ..()

	AssignSocialRole(/datum/socialrole/shop/pharmacystore)
