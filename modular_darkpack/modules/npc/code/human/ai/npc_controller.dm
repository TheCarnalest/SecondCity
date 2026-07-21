/datum/ai_controller/human_npc
	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(

	)
	blackboard = list(

	)

/datum/ai_controller/human_npc/TryPossessPawn(atom/new_pawn)
	if (!isnpc(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/carbon/human/npc/npc_pawn = new_pawn

	if (!HAS_TRAIT(npc_pawn, TRAIT_RELAYING_ATTACKER))
		npc_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(npc_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, PROC_REF(on_startpulling))
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))
	// Get annoyed when pushed around
	RegisterSignal(src, COMSIG_LIVING_MOB_BUMPED, PROC_REF(on_bumped))
	// Get annoyed when hugged or headpatted
	RegisterSignal(src, COMSIG_CARBON_HELP_ACT, PROC_REF(on_helped))

	movement_delay = npc_pawn.cached_multiplicative_slowdown

/datum/ai_controller/human_npc/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_LIVING_START_PULL,
		COMSIG_MOB_MOVESPEED_UPDATED,
		COMSIG_LIVING_MOB_BUMPED,
		COMSIG_CARBON_HELP_ACT
	))

	return ..()

/datum/ai_controller/human_npc/proc/on_attacked(mob/living/carbon/human/npc/pawn, atom/attacker, attack_flags, direction)
	SIGNAL_HANDLER

	// TODO: [Lucia]

/datum/ai_controller/human_npc/proc/on_startpulling(mob/living/carbon/human/npc/pawn, atom/attacker, attack_flags, direction)
	SIGNAL_HANDLER

	// TODO: [Lucia]

/datum/ai_controller/human_npc/proc/update_movespeed(mob/living/carbon/human/npc/pawn)
	SIGNAL_HANDLER

	movement_delay = pawn.cached_multiplicative_slowdown

/datum/ai_controller/human_npc/proc/on_bumped(mob/living/carbon/human/npc/pawn, mob/living/bumped_by)
	SIGNAL_HANDLER

	// TODO: [Lucia]

/datum/ai_controller/human_npc/proc/on_helped(mob/living/carbon/human/npc/pawn, mob/living/helper)
	SIGNAL_HANDLER

	// TODO: [Lucia]
