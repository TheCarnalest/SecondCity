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
	var/directionwalk

/obj/effect/landmark/npcbeacon/directed
	name = "NPC traffic"
	icon = 'modular_darkpack/modules/deprecated/icons/effects/landmarks_static.dmi'
	icon_state = "npc"

/obj/effect/landmark/npcbeacon/directed/Initialize(mapload)
	. = ..()

	directionwalk = dir

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

/obj/effect/landmark/npcability
	name = "NPC Ability"
	icon = 'modular_darkpack/modules/deprecated/icons/effects/landmarks_static.dmi'
	icon_state = "ability"

/obj/effect/landmark/npcactivity/Initialize(mapload)
	. = ..()

	GLOB.npc_activities += src

/obj/effect/landmark/npcactivity/Destroy()
	. = ..()

	GLOB.npc_activities -= src

/mob/living/carbon/human/npc/death()
	GLOB.alive_npc_list -= src
	SShumannpcpool.try_repopulate()
	GLOB.move_manager.stop_looping(src)

	if (!last_attacker || (get_dist(src, last_attacker) >= 10) || key || hostile)
		return ..()

	if (istype(last_attacker, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/HS = last_attacker
		if(HS.my_creator)
			SEND_SIGNAL(HS.my_creator, COMSIG_PATH_HIT, -1, 0, FALSE, 8)
			HS.my_creator.killed_count += 1
			if(!HS.my_creator.warrant && !HS.my_creator.ignores_warrant)
				if(HS.my_creator.killed_count >= 5)
					HS.my_creator.warrant = TRUE
					SEND_SOUND(HS.my_creator, sound('modular_darkpack/modules/deprecated/sounds/suspect.ogg', volume = 75))
					to_chat(HS.my_creator, span_userdanger("<b>POLICE ASSAULT IN PROGRESS</b>"))
				else
					SEND_SOUND(HS.my_creator, sound('modular_darkpack/modules/deprecated/sounds/sus.ogg', volume = 75))
					to_chat(HS.my_creator, span_userdanger("<b>SUSPICIOUS ACTION (murder)</b>"))
	else if (ishuman(last_attacker))
		var/mob/living/carbon/human/HM = last_attacker
		SEND_SIGNAL(HM, COMSIG_PATH_HIT, -1, 0, FALSE, 8)
		HM.killed_count += 1
		if(!HM.warrant && !HM.ignores_warrant)
			if(HM.killed_count >= 5)
				HM.warrant = TRUE
				SEND_SOUND(HM, sound('modular_darkpack/modules/deprecated/sounds/suspect.ogg', volume = 75))
				to_chat(HM, span_userdanger("<b>POLICE ASSAULT IN PROGRESS</b>"))
			else
				SEND_SOUND(HM, sound('modular_darkpack/modules/deprecated/sounds/sus.ogg', volume = 75))
				to_chat(HM, span_userdanger("<b>SUSPICIOUS ACTION (murder)</b>"))

	. = ..()

/mob/living/carbon/human/npc/Life()
	// huh, NPCs don't run Life() at all if they're dead
	// this means NPCs' organs will never rot, they'll stop bleeding, their body will stay
	// the temperature it was when they died, etc. remove?
	if (stat == DEAD)
		return

	. = ..()

	// Aggro on whoever is pulling them
	if (pulledby && (prob(25) || aggressive))
		INVOKE_ASYNC(src, PROC_REF(Aggro), pulledby, TRUE)

	if (!can_npc_move())
		return

	// NPCs don't need to eat apparently
	nutrition = 400

	// Refresh hostility if the danger source is in view distance
	if (get_dist(danger_source, src) < 7)
		last_antagonised = world.time

	// Stop, drop, and roll!
	if (fire_stacks >= 1)
		INVOKE_ASYNC(src, PROC_REF(execute_resist))

	if (no_movement)
		return

	// Try to walk around
	if (walktarget)
		// Log the path currently being taken to the target
		EVLOG_PATH(src, EVLOG_CATEGORY_MOVELOOPS, "Set walktarget: [walktarget]", list(loc, get_turf(walktarget)))
	else
		// Start walking towards a nearby NPC landmark
		walktarget = ChoosePath()

	// Keep track of how many life ticks the NPC has been stuck
	if (loc == last_life_tick_location)
		life_ticks_since_moved += 1
	else
		last_life_tick_location = loc
		life_ticks_since_moved = 0

	if (life_ticks_since_moved <= 3)
		return

	// The NPC can't find a path to walk, just make them randomly move
	var/turf/T = get_step(src, pick(NORTH, SOUTH, WEST, EAST))
	face_atom(T)
	step_to(src, T, 0)

	if (!walktarget || random_movement)
		return
	if (observed_by_player())
		return

	// The NPC has no way to reach its destination and no players are watching, just teleport it there
	var/turf/old_loc = loc
	var/turf/new_loc = get_turf(walktarget)
	forceMove(new_loc)
	EVLOG_PATH(src, EVLOG_CATEGORY_MOVELOOPS, "Teleported using evil russian shitcode", list(old_loc, new_loc))

/mob/living/carbon/human/npc/proc/CreateWay(direction)
	var/turf/location = get_turf(src)
	for(var/distance = 1 to 50)
		location = get_step(location, direction)
		if(iswallturf(location))
			return location
		for(var/atom/A in location)
			// DARKPACK TODO - reimplement decor
			/*
			if(A.density && !istype(A, /obj/structure/lamppost))
				return location
			*/
			if(istype(A, /obj/effect/landmark/npcwall))
				return get_step_towards(location, get_turf(src))
			if(istype(A, /obj/effect/landmark/npcbeacon) && prob(50))
				stopturf = 1
				return get_step(location, direction)

/mob/living/carbon/human/npc/proc/ChoosePath()
	if(!random_movement)
		var/list/possible_list = list()
		for(var/obj/effect/landmark/npcactivity/N in GLOB.npc_activities)
			if(get_dist(src, N) < 64)
				var/turf/T = get_step(N, turn(get_dir(src, N), 180))
				var/obj/effect/landmark/npcability/A = locate() in T
				if(A)
					if(N.x > x-3 && N.x < x+3)
						possible_list += N
					if(N.y > y-3 && N.y < y+3)
						possible_list += N
		if(!length(possible_list))
			var/atom/shitshit
			for(var/obj/effect/landmark/npcactivity/N in GLOB.npc_activities)
				if(!shitshit)
					shitshit = N
				if(get_dist(src, N) > 1 && get_dist(src, N) < get_dist(src, shitshit))
					shitshit = N
			if(shitshit)
				return shitshit
			else if (length(GLOB.npc_activities))
				return pick(GLOB.npc_activities)
			else
				return

		return pick(possible_list)
	else
		var/turf/north_steps = CreateWay(NORTH)
		var/turf/south_steps = CreateWay(SOUTH)
		var/turf/west_steps = CreateWay(WEST)
		var/turf/east_steps = CreateWay(EAST)

		if(dir == NORTH || dir == SOUTH)
			if(get_dist(src, west_steps) >= 7 && get_dist(src, east_steps) >= 7)
				return(pick(west_steps, east_steps))
			if(get_dist(src, west_steps) > get_dist(src, east_steps))
				if(prob(75))
					return west_steps
			else if(get_dist(src, east_steps) > get_dist(src, west_steps))
				if(prob(75))
					return east_steps
			else
				if(dir == NORTH)
					return pick(west_steps, east_steps, south_steps)
				else
					return pick(west_steps, east_steps, north_steps)

		if(dir == WEST || dir == EAST)
			if(get_dist(src, north_steps) >= 7 && get_dist(src, south_steps) >= 7)
				return pick(north_steps, south_steps)
			if(get_dist(src, north_steps) > get_dist(src, south_steps))
				if(prob(75))
					return north_steps
			else if(get_dist(src, south_steps) > get_dist(src, north_steps))
				if(prob(75))
					return south_steps
			else
				if(dir == WEST)
					return pick(north_steps, south_steps, east_steps)
				else
					return pick(north_steps, south_steps, west_steps)

/mob/living/carbon/human/npc/proc/can_npc_move()
	if(stat >= HARD_CRIT)
		return FALSE
	if((last_grabbed + 1.5 SECONDS) > world.time)
		return FALSE
	if(mind || client)
		return FALSE
	if(IsSleeping())
		return FALSE
	if(IsUnconscious())
		return FALSE
	if(IsParalyzed())
		return FALSE
	if(IsKnockdown())
		return FALSE
	if(IsStun())
		return FALSE
	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return FALSE
	if(is_talking)
		return FALSE
	if(pulledby)
		if (HAS_TRAIT(pulledby, TRAIT_CHARMER))
			return FALSE
		if (prob(10))
			execute_resist()
		return FALSE

	return TRUE

/mob/living/carbon/human/npc/proc/observed_by_player()
	for (var/mob/observing_mob in viewers(DEFAULT_SIGHT_DISTANCE, src))
		if (!observing_mob.client)
			continue
		return TRUE

	return FALSE

/mob/living/carbon/human/npc/proc/handle_automated_movement()
	if (!can_npc_move())
		return

	// Not going anywhere, decide on a place to walk to
	if (!walktarget && !no_movement)
		stopturf = rand(1, 2)
		walktarget = ChoosePath()
		face_atom(walktarget)

	// Can't do anything if in a container
	if (!isturf(loc))
		return

	// Checks for fire, clearing the stored fire if none is in view
	afraid_of_fire = locate(/obj/effect/abstract/turf_fire) in view(DEFAULT_SIGHT_DISTANCE, src)

	// Combat behaviour
	if (danger_source)
		// Run away from the danger source if they aren't aggressive and have no weapon
		if (!has_weapon && !aggressive)
			GLOB.move_manager.move_away(src, danger_source, 10, cached_multiplicative_slowdown)
		else
			if(!spawned_weapon && has_weapon)
				npc_draw_weapon()
			if(spawned_weapon && get_active_held_item() != my_weapon)
				has_weapon = FALSE
			if(danger_source)
				if(danger_source == src)
					danger_source = null
				else
					ClickOn(danger_source)
					face_atom(danger_source)
					GLOB.move_manager.move_to(src, danger_source, 1, cached_multiplicative_slowdown)

		// Deaggro if the danger source has been beaten up
		if (danger_source.stat > UNCONSCIOUS)
			end_combat()

		// Deaggro if 30 second have passed since being antagonised
		if ((last_antagonised + 30 SECONDS) <= world.time)
			end_combat()

	// Running away from fire behaviour
	else if (afraid_of_fire)
		GLOB.move_manager.move_away(src, afraid_of_fire, 10, cached_multiplicative_slowdown)
		if (prob(25))
			emote("scream")

	// Walking around behaviour
	else if (walktarget && !no_movement)
		GLOB.move_manager.move_to(src, walktarget, 0, cached_multiplicative_slowdown)

	if (!has_weapon || danger_source || !spawned_weapon)
		return

	// Put their weapon away when not in combat or note that they lost it
	if (get_active_held_item() == my_weapon)
		npc_stow_weapon()
	else
		has_weapon = FALSE
