#define MODIFICATION_ORGANIC 1
#define MODIFICATION_SILICON 2
#define MODIFICATION_REMOVED 3

var/global/list/body_modifications = list()
var/global/list/modifications_types = list(
	BP_CHEST = "",  "chest2" = "", BP_HEAD = "",   BP_GROIN = "",
	BP_L_ARM  = "", BP_R_ARM  = "", BP_L_HAND = "", BP_R_HAND = "",
	BP_L_LEG  = "", BP_R_LEG  = "", BP_L_FOOT = "", BP_R_FOOT = "",
	O_HEART  = "", O_LUNGS  = "", O_LIVER  = "", O_EYES   = ""
)

/proc/generate_body_modification_lists()
	for(var/mod_type in typesof(/datum/body_modification))
		var/datum/body_modification/BM = new mod_type()
		if(!BM.id) continue
		body_modifications[BM.id] = BM
		for(var/part in BM.body_parts)
			modifications_types[part] += "<div onclick=\"set('body_modification', '[BM.id]');\" class='block'><b>[BM.name]</b><br>[BM.desc]</div>"

/proc/get_default_modificaton(var/nature = MODIFICATION_ORGANIC)
	switch(nature)
		if(MODIFICATION_ORGANIC) return body_modifications["nothing"]
		if(MODIFICATION_SILICON) return body_modifications["prosthesis_basic"]
		if(MODIFICATION_REMOVED) return body_modifications["amputated"]

/datum/body_modification
	var/name = ""
	var/short_name = ""
	var/id = ""								// For savefile. Must be unique.
	var/desc = ""							// Description.
	var/list/body_parts = list(				// For sorting'n'selection optimization.
		BP_CHEST, "chest2", BP_HEAD, BP_GROIN, BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG,\
		BP_L_FOOT, BP_R_FOOT, O_HEART, O_LUNGS, O_LIVER, O_BRAIN, O_EYES)
	var/list/allowed_species = list("Human")// Species restriction.
	var/replace_limb = null					// To draw usual limb or not.
	var/mob_icon = ""
	var/icon/icon = 'icons/mob/human_races/body_modification.dmi'
	var/nature = MODIFICATION_ORGANIC

	proc/get_mob_icon(organ, body_build = "", color="#ffffff", gender = MALE, species)	//Use in setup character only
		return new/icon('icons/mob/human.dmi', "blank")

	proc/is_allowed(var/organ = "", datum/preferences/P)
		if(!organ || !(organ in body_parts))
			usr << "[name] isn't useable for [organ_tag_to_name[organ]]"
			return 0
		if(allowed_species && !(P.species in allowed_species))
			usr << "[name] isn't allowed for [P.species]"
			return 0
		var/list/organ_data = organ_structure[organ]
		if(organ_data)
			var/parent_organ = organ_data["parent"]
			if(parent_organ)
				var/datum/body_modification/parent = P.get_modification(parent_organ)
				if(parent.nature > nature)
					usr << "[name] can't be attached to [parent.name]"
					return 0
		return 1

	proc/create_organ(var/organ_data, var/color)
		return null

/datum/body_modification/none
	name = "Unmodified organ"
	id = "nothing"
	short_name = "nothing"
	desc = "Normal organ."
	allowed_species = null

	create_organ(var/datum/organ_description/O, var/color)
		if(istype(O))
			return new O.default_type (null, O)
		else if(ispath(O))
			return new O (null)
		else
			return null

/datum/body_modification/limb
	create_organ(var/datum/organ_description/O, var/color)
		if(replace_limb)
			return new replace_limb(null, O)
		else
			return new O.default_type (null, O)

/datum/body_modification/limb/amputation
	name = "Amputated"
	short_name = "Amputated"
	id = "amputated"
	desc = "Organ was removed."
	body_parts = list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
	replace_limb = 1
	nature = MODIFICATION_REMOVED
	create_organ()
		return null

/datum/body_modification/limb/tattoo
	name = "Abstract"
	short_name = "T: Abstract"
	desc = "Simple tattoo (use flavor)."
	id = "abstract"
	body_parts = list(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_ARM,\
		BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
	icon = 'icons/mob/tattoo.dmi'
	mob_icon = "abstract"

	New()
		if(!short_name) short_name = "T: [name]"
		name = "Tattoo: [name]"

	get_mob_icon(organ, body_build = "", color = "#ffffff")
		var/icon/I = new/icon(icon, "[organ]_[mob_icon][body_build]")
		I.Blend(color, ICON_ADD)
		return I

	create_organ(var/datum/organ_description/O, var/color)
		var/obj/item/organ/external/E = ..(O, color)
		E.tattoo = mob_icon
		E.tattoo_color = color
		return E

/datum/body_modification/limb/tattoo/tajara_stripes
	name = "Tiger Stripes"
	short_name = "T: Tiger"
	desc = "A great camouflage to hide in long grass."
	id = "stripes"
	body_parts = list(BP_HEAD, BP_CHEST)
	mob_icon = "tajara"
	allowed_species = list("Tajara")

/datum/body_modification/limb/tattoo/tribal_markings
	name = "Unathi Tribal Markings"
	short_name = "T: Tribal"
	desc = "A specific identification and beautification marks designed on the face or body."
	id = "tribal"
	body_parts = list(BP_HEAD, BP_CHEST)
	mob_icon = "unathi"
	allowed_species = list("Unathi")

/datum/body_modification/limb/prosthesis
	name = "Unbranded"
	id = "prosthesis_basic"
	desc = "Simple, brutal and reliable prosthesis"
	body_parts = list(BP_L_ARM, BP_R_ARM, BP_L_HAND, BP_R_HAND, \
		BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
	replace_limb = /obj/item/organ/external/robotic
	icon = 'icons/mob/human_races/cyberlimbs/robotic.dmi'
	mob_icon = ""
	var/model = "basic"
	nature = MODIFICATION_SILICON

	New()
		short_name = "P: [name]"
		name = "Prosthesis: [name]"
		if(mob_icon)
			mob_icon = "_[mob_icon]"

	get_mob_icon(organ, body_build)
		return new/icon(icon, "[organ][mob_icon][body_build]")

	create_organ(var/datum/organ_description/O, var/color)
		var/obj/item/organ/external/robotic/R = new replace_limb(null, O)
		R.icon = icon
		R.model = model
		return R

/datum/body_modification/limb/prosthesis/bishop
	name = "Bishop"
	id = "prosthesis_bishop"
	desc = "Prosthesis with white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop.dmi'
	model = "bishop"

/datum/body_modification/limb/prosthesis/hesphaistos
	name = "Hesphaistos"
	id = "prosthesis_hesphaistos"
	desc = "Prosthesis with militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hesphaistos.dmi'
	model = "hesphaistos"

/datum/body_modification/limb/prosthesis/zenghu
	name = "Zeng-Hu"
	id = "prosthesis_zenghu"
	desc = "Prosthesis with rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu.dmi'
	model = "zenghu"

/datum/body_modification/limb/prosthesis/xion
	name = "Xion"
	id = "prosthesis_xion"
	desc = "Prosthesis with minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion.dmi'
	model = "xion"

/datum/body_modification/limb/prosthesis/cyber_interprize
	name = "Cyber Interprize"
	id = "prosthesis_enforcer"
	icon = 'icons/mob/human_races/cyberlimbs/cyber.dmi'
	model = "cyber"

/datum/body_modification/limb/mutation
	New()
		short_name = "M: [name]"
		name = "Mutation: [name]"

/datum/body_modification/limb/mutation/exoskeleton
	name = "Exoskeleton"
	id = "mutation_exoskeleton"
	desc = "Your limb covered with bony shell (act as shield)."
	body_parts = list(BP_HEAD, BP_CHEST, BP_GROIN, BP_L_ARM, BP_R_ARM,\
		BP_L_HAND, BP_R_HAND, BP_L_LEG, BP_R_LEG, BP_L_FOOT, BP_R_FOOT)
	icon = 'icons/mob/human_races/cyberlimbs/exo.dmi'
	mob_icon = "exo"

	create_organ(var/datum/organ_description/O, var/color)
		var/obj/item/organ/external/E = ..(O, color)
		E.force_icon = icon
		E.model = "exo"
		E.brute_mod = 0.8

	get_mob_icon(organ, body_build = "", color="#ffffff", gender = MALE)
		if(organ in list(BP_HEAD, BP_CHEST, BP_GROIN))
			return new/icon(icon, "[organ]_[mob_icon]_[gender==FEMALE?"f":"m"][body_build]")
		else
			return new/icon(icon, "[organ]_[mob_icon][body_build]")

////Internals////

/datum/body_modification/organ
	create_organ(var/organ_type, var/color)
		if(replace_limb)
			return new replace_limb(null)
		else
			return new organ_type(null)

/datum/body_modification/organ/assisted
	name = "Assisted organ"
	short_name = "P: assisted"
	id = "assisted"
	desc = "Assisted organ."
	body_parts = list(O_HEART, O_LUNGS, O_LIVER, O_EYES)

	create_organ()
		var/obj/item/organ/internal/I = ..()
		I.robotic = ORGAN_ASSISTED
		I.min_bruised_damage = 15
		I.min_broken_damage = 35
		return I

/datum/body_modification/organ/robotize_organ
	name = "Assisted organ"
	short_name = "P: prosthesis"
	id = "robotize_organ"
	desc = "Robotic organ."
	body_parts = list(O_HEART, O_LUNGS, O_LIVER, O_EYES)

	create_organ(organ_type, color)
		var/obj/item/organ/internal/I = ..()
		I.robotic = ORGAN_ROBOT
		if(istype(I, /obj/item/organ/internal/eyes))
			var/obj/item/organ/internal/eyes/E = I
			E.robo_color = color
		return I

////Eyes////
/*
/datum/body_modification/organ/eyecam
	name = "Eye cam"
	short_name = "P: Eye cam"
	id = "prosthesis_eye_cam"
	desc = "One of your eyes replaced with portable cam. Do not lose it."
	body_parts = list(O_EYES)
	allowed_species = list("Human")

	get_mob_icon(organ, body_build, color, gender, species)
		var/datum/species/S = all_species[species]
		var/icon/I = new/icon(S.icobase, "one_eye_[body_build]")
		I.Blend("#C0C0C0", ICON_ADD)
		return I

	create_organ()
		return new /obj/item/organ/internal/eyes/mechanic/cam(null)
*/

/datum/body_modification/organ/oneeye
	name = "One eye"
	short_name = "M: One eye"
	id = "missed_eye"
	desc = "One of your eyes was missed."
	body_parts = list(O_EYES)
	replace_limb = /obj/item/organ/internal/eyes/oneeye

	get_mob_icon(organ, body_build, color, gender, species)
		var/datum/species/S = all_species[species]
		var/icon/I = new/icon(S.icobase, "one_eye[body_build]")
		I.Blend(color, ICON_ADD)
		return I

	create_organ(var/organ_type, var/color)
		var/obj/item/organ/internal/eyes/E = ..()
		E.eye_color = color


/datum/body_modification/organ/heterochromia
	name = "Heterochromia"
	short_name = "M: Heterochromia"
	id = "mutation_heterochromia"
	desc = "Special color for left eye."
	body_parts = list(O_EYES)

	get_mob_icon(organ, body_build, color, gender, species)
		var/datum/species/S = all_species[species]
		var/icon/I = new/icon(S.icobase, "one_eye[body_build]")
		I.Blend(color, ICON_ADD)
		return I

	create_organ(organ_type, color)
		var/obj/item/organ/internal/eyes/heterohromia/E = new(null)
		E.second_color = color
		return E

#undef MODIFICATION_REMOVED
#undef MODIFICATION_ORGANIC
#undef MODIFICATION_SILICON
