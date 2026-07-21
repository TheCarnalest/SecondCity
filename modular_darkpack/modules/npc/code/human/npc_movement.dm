/mob/living/carbon/human/npc/proc/movement_tick(seconds_per_tick)
	if (no_movement)
		return

	// Try to walk around
	if (destination)
		// Log the path currently being taken to the target
		EVLOG_PATH(src, EVLOG_CATEGORY_MOVELOOPS, "Set destination: [destination]", list(loc, get_turf(destination)))
	else
		// Start walking
		choose_new_destination()

	// Keep track of how long the NPC has been stuck
	if (loc == last_location)
		time_since_moved += seconds_per_tick
	else
		last_location = loc
		time_since_moved = 0

	if (time_since_moved <= 6 SECONDS)
		return

	// The NPC can't find a path to walk, just make them randomly move
	var/turf/T = get_step(src, pick(NORTH, SOUTH, WEST, EAST))
	face_atom(T)
	step_to(src, T, 0)

	if (!destination || random_movement)
		return
	if (observed_by_player())
		return

	// The NPC has no way to reach its destination and no players are watching, just teleport it there
	EVLOG_PATH(src, EVLOG_CATEGORY_MOVELOOPS, "Teleported using evil russian shitcode", list(loc, destination))
	forceMove(destination)

/mob/living/carbon/human/npc/proc/observed_by_player()
	// This includes ghosts and observers
	for (var/mob/observing_mob in viewers(DEFAULT_SIGHT_DISTANCE, src))
		if (!observing_mob.client)
			continue
		return TRUE

	return FALSE

/mob/living/carbon/human/npc/proc/choose_new_destination()
	if (!random_movement)
		destination = get_turf(choose_landmark())
	else
		destination = choose_random_path()

/mob/living/carbon/human/npc/proc/choose_landmark()
	var/list/possible_list = list()
	for (var/obj/effect/landmark/npcactivity/activity in GLOB.npc_activities)
		if (get_dist(src, activity) >= 64)
			continue

		var/turf/T = get_step(activity, turn(get_dir(src, activity), 180))
		var/obj/effect/landmark/npcability/A = locate() in T
		if (!A)
			continue

		if (activity.x > x-3 && activity.x < x+3)
			possible_list += activity
		if (activity.y > y-3 && activity.y < y+3)
			possible_list += activity

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

/mob/living/carbon/human/npc/proc/choose_random_path()
	// Add some variance to how close to its destination the NPC will stop
	stop_at_distance = rand(2, 3)

	var/turf/north_steps = find_destination_in_direction(NORTH)
	var/turf/south_steps = find_destination_in_direction(SOUTH)
	var/turf/west_steps = find_destination_in_direction(WEST)
	var/turf/east_steps = find_destination_in_direction(EAST)

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

/mob/living/carbon/human/npc/proc/find_destination_in_direction(direction)
	var/turf/valid_location = get_turf(src)
	for (var/distance = 1 to 50)
		var/turf/checking_location = get_step(valid_location, direction)
		if (iswallturf(checking_location))
			return checking_location
		if (!checking_location.can_cross_safely(src))
			return valid_location
		if ((locate(/obj/effect/landmark/npcbeacon) in checking_location) && prob(50))
			return checking_location

		valid_location = checking_location

/mob/living/carbon/human/npc/proc/handle_automated_movement()
	set waitfor = FALSE

	if (!can_npc_move())
		return

	// Not going anywhere, decide on a place to walk to and how far away from it to stop
	if (!destination && !no_movement)
		choose_new_destination()
		face_atom(destination)

	// Can't do anything if in a container
	if (!isturf(loc))
		return

	// Checks for fire, clearing the stored fire if none is in view
	afraid_of_fire = WEAKREF(locate(/obj/effect/abstract/turf_fire) in view(DEFAULT_SIGHT_DISTANCE, src))

	var/obj/effect/abstract/turf_fire/seeing_fire = afraid_of_fire?.resolve()
	if (danger_source)
		// Combat behavior
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
	else if (seeing_fire)
		// Running away from fire behaviour
		GLOB.move_manager.move_away(src, seeing_fire, 10, cached_multiplicative_slowdown)
		if (prob(25))
			emote("scream")
	else if (destination && !no_movement)
		// Walking around behaviour
		GLOB.move_manager.move_to(src, destination, 0, cached_multiplicative_slowdown)

	if (!has_weapon || danger_source || !spawned_weapon)
		return

	// Put their weapon away when not in combat or note that they lost it
	if (get_active_held_item() == my_weapon)
		npc_stow_weapon()
	else
		has_weapon = FALSE

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
