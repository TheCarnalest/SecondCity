/obj/effect/landmark/npc_spawn_point
	icon = 'modular_darkpack/modules/deprecated/icons/effects/landmarks_static.dmi'
	icon_state = "spawn"

/obj/effect/landmark/npc_spawn_point/Initialize(mapload)
	. = ..()

	GLOB.npc_spawn_points += src

/obj/effect/landmark/npc_spawn_point/Destroy()
	GLOB.npc_spawn_points -= src

	return ..()

/obj/effect/landmark/npcbeacon
	name = "NPC beacon"

/// This doesn't do anything and never has
/obj/effect/landmark/npcbeacon/directed

/**
 * Marker to be placed on a turf that AI (like NPCs) shouldn't be able to path or walk through.
 *
 * Players could theoretically immobilize NPCs by placing them on or inbetween these, so use with
 * caution and try not to cover areas in them.
 */
/obj/effect/landmark/npcwall
	name = "NPC Wall"
	icon_state = "x"

/obj/effect/landmark/npcwall/Initialize(mapload)
	. = ..()

	var/turf/on_turf = get_turf(src)
	ADD_TRAIT(on_turf, TRAIT_AI_AVOID_TURF, src)

/obj/effect/landmark/npcwall/Destroy()
	// This effect isn't supposed to ever move
	var/turf/on_turf = get_turf(src)
	REMOVE_TRAIT(on_turf, TRAIT_AI_AVOID_TURF, src)

	return ..()

/obj/effect/landmark/npcactivity
	name = "NPC Activity"
	icon = 'modular_darkpack/modules/deprecated/icons/effects/landmarks_static.dmi'
	icon_state = "bullets"

/obj/effect/landmark/npcactivity/Initialize(mapload)
	. = ..()

	GLOB.npc_activities += src

/obj/effect/landmark/npcactivity/Destroy()
	. = ..()

	GLOB.npc_activities -= src

/obj/effect/landmark/npcability
	name = "NPC Ability"
	icon = 'modular_darkpack/modules/deprecated/icons/effects/landmarks_static.dmi'
	icon_state = "ability"
