/obj/item/proc/use_multi(mob/user, list/res_list)
	. = TRUE
	for(var/x in res_list)
		var/obj/item/stack/S = x
		if(S.amount < res_list[x])
			. = FALSE
			to_chat(user, "There is not enough [S.name]. You need [res_list[x]].")
			break
	if(.)
		for(var/x in res_list)
			var/obj/item/stack/S = x
			S.use(res_list[x])

/obj/item/weapon/transparant
	icon = 'icons/obj/transparant.dmi'
	icon_state = "blank"
	item_state = "blank"
	name = "blank sign"
	desc = "Nothing."
	var/not_bloody_state
	force = 8
	w_class = 4.0
	throwforce = 5
	attack_verb = list("bashed", "pacified", "smashed", "opressed", "flapped")

/obj/item/weapon/transparant/New()
	..()
	not_bloody_state = icon_state

/obj/item/weapon/transparant/attackby(obj/item/I, mob/user)
	..()
	if(icon_state!="blank")
		to_chat(user, "<span class='notice'>Something allready written on this sign.</span>")
		return
	if(istype(I, /obj/item/weapon/pen))

		var/defaultText = "FUK NT!1"
		var/targName = copytext(sanitize(input(usr, "Just write something here", "Transparant text", defaultText)),1,MAX_MESSAGE_LEN)
		var/obj/item/weapon/transparant/text/W = new /obj/item/weapon/transparant/text
		W.desc = targName
		user.remove_from_mob(src)
		user.put_in_hands(W)
		qdel(src)
		to_chat(user, "<span class='notice'>You writed: [targName] on your sign.</span>")
		return

	if(istype(I, /obj/item/weapon/pen/crayon))
		var/paths = typesof(/obj/item/weapon/transparant) - /obj/item/weapon/transparant - /obj/item/weapon/transparant/text
		var/targName = input(usr, "Choose transparant pattern", "Pattern list") in paths
		if(!targName)
			return
		var/obj/item/weapon/transparant/W = new targName
		user.remove_from_mob(src)
		user.put_in_hands(W)
		qdel(src)
		to_chat(user, "<span class='notice'>You painted your blank sign as [W.name].</span>")

/obj/item/weapon/transparant/attack_self(mob/user)
	for(var/mob/O in viewers(user, null))
		O.show_message("[user] shows you: [icon(src)] [src.blood_DNA ? "bloody " : ""][src.name]: it says: [src.desc]", 1)

/obj/item/weapon/transparant/attack(mob/M, mob/user)
	..()
	M.show_message("<span class='attack'>\The <EM>[src.blood_DNA ? "bloody " : ""][icon(src)][src.name]</EM> says: <EM>[src.desc]</EM></span>", 2)


/obj/item/weapon/transparant/update_icon()
	if(blood_DNA)
		icon_state = "bloody"
	else
		icon_state = not_bloody_state
	..()
	if(istype(src.loc, /mob/living))
		var/mob/living/user = src.loc
		user.update_inv_l_hand()
		user.update_inv_r_hand()


/obj/item/weapon/transparant/clean_blood()
	..()
	update_icon()


/obj/item/weapon/transparant/add_blood()
	..()
	update_icon()




/obj/item/weapon/transparant/no_nt
	icon_state = "no_nt"

	name = "no NT sign"
	desc = "Nanotrasen go home! Nanotrasen go home!"

/obj/item/weapon/transparant/peace
	icon_state = "peace"

	name = "peace sign"
	desc = "No more war! No more opression! No more violence!"

/obj/item/weapon/transparant/text
	icon_state = "text"

	name = "text sign"
	desc = "..."






/obj/item/stack/rods/attackby(obj/item/I, mob/user)
	..()

	if(istype(I, /obj/item/stack/material/cardboard))
		var/obj/item/stack/material/cardboard/C = I

		var/list/resources_to_use = list()
		resources_to_use[C] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		var/obj/item/weapon/transparant/W = new /obj/item/weapon/transparant

		user.remove_from_mob(src)

		user.put_in_hands(W)

		to_chat(user, "<span class='notice'>You attached a big cardboard sign to the metal rod, making a blank transparant.</span>")
