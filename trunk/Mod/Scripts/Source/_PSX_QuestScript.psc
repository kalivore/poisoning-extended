Scriptname _PSX_QuestScript extends Quest  

string currentMenu

import _Q2C_Functions

Perk Property _KLV_StashRefPerk  Auto

Potion Property _PSX_TestPoison  Auto

ObjectReference Property TargetRef Auto
ObjectReference Property PlayerRef Auto

Actor Property WornObjectSubject Auto


function OnInit()
	RegisterForMenu("InventoryMenu")
	RegisterForMenu("ContainerMenu")
	RegisterForMenu("BarterMenu")
	
	RegisterForModEvent("_KLV_ContainerActivated", "OnContainerActivated")
	
	RegisterForKey(12) ; -
	RegisterForKey(13) ; =
	RegisterForKey(26) ; [
	RegisterForKey(27) ; ]
	RegisterForKey(39) ; ;
	
	RegisterForKey(181) ; /
	RegisterForKey(55) ; *
	RegisterForKey(74) ; -
	RegisterForKey(78) ; +
	RegisterForKey(156) ; Num Ent
	
	RegisterForKey(80) ; 2
	RegisterForKey(75) ; 4
	RegisterForKey(77) ; 6
	RegisterForKey(72) ; 8
	
	RegisterForKey(40) ; '

	(PlayerRef as Actor).AddPerk(_KLV_StashRefPerk)

	_PSX_TestPoison.SetName("Test poison of having a totally long and fully unwieldy name...")
	
endFunction


event OnKeyDown(int aiKeyCode)

	if (aiKeyCode == 26) ; [
		Actor target = Game.GetCurrentCrosshairRef() as Actor
		Potion poison = Game.GetFormFromFile(0x000663e1, "Skyrim.esm") as Potion ; philter of phantom
		WornPoisonObject(target, poison)
	elseif (aiKeyCode == 27) ; ]
		Actor target = Game.GetCurrentCrosshairRef() as Actor
		WornUnpoisonObject(target)
	elseif (aiKeyCode == 12) ; -
		Actor target = Game.GetCurrentCrosshairRef() as Actor
		WornDecreasePoisonCharges(target)
	elseif (aiKeyCode == 13) ; =
		Actor target = Game.GetCurrentCrosshairRef() as Actor
		WornIncreasePoisonCharges(target)
	elseif (aiKeyCode == 39) ; ;
		Actor target = Game.GetCurrentCrosshairRef() as Actor
		WornPoisonStatus(target)
	
	elseif (aiKeyCode == 181) ; /
		Actor target = Game.GetPlayer()
		Potion poison = Game.GetFormFromFile(0x0003eb3e, "Skyrim.esm") as Potion ; invisibility
		WornPoisonObject(target, poison)
	elseif (aiKeyCode == 55) ; *
		Actor target = Game.GetPlayer()
		WornUnpoisonObject(target)
	elseif (aiKeyCode == 74) ; -
		Actor target = Game.GetPlayer()
		WornDecreasePoisonCharges(target)
	elseif (aiKeyCode == 78) ; +
		Actor target = Game.GetPlayer()
		WornIncreasePoisonCharges(target)
	elseif (aiKeyCode == 156) ; Num Ent
		Actor target = Game.GetPlayer()
		WornPoisonStatus(target)
	
	elseif (aiKeyCode == 80) ; 2
		SendModEvent("_PSX_BumpPoisonDown")
	elseif (aiKeyCode == 75) ; 4
		SendModEvent("_PSX_BumpPoisonLeft")
	elseif (aiKeyCode == 77) ; 6
		SendModEvent("_PSX_BumpPoisonRight")
	elseif (aiKeyCode == 72) ; 8
		SendModEvent("_PSX_BumpPoisonUp")
	
	elseif (aiKeyCode == 40) ; '
		;Potion poison = Game.GetFormFromFile(0x0003a5a4, "Skyrim.esm") as Potion ; weak damage health
		;Potion poison = Game.GetFormFromFile(0x00073f31, "Skyrim.esm") as Potion ; weak damage health
		;Potion poison = Game.GetFormFromFile(0x00073f32, "Skyrim.esm") as Potion ; weak damage health
		;Potion poison = Game.GetFormFromFile(0x00073f33, "Skyrim.esm") as Potion ; weak damage health
		Potion poison = Game.GetFormFromFile(0x00073f34, "Skyrim.esm") as Potion ; deadly damage health
		Game.GetPlayer().AddItem(poison, 1)
		Game.GetPlayer().AddItem(_PSX_TestPoison, 1)
		;SendModEvent("_PSX_VisToggle")
	endIf

endEvent



Function WornPoisonStatus(Actor target)

	if (!target)
		Debug.Notification("invalid target")
		return
	endIf
	
	Potion currentPoisonLeft = WornGetPoison(target, 0)
	Potion currentPoisonRight = WornGetPoison(target, 1)
	string poisonNameLeft = "Not poisoned"
	string poisonNameRight = "Not poisoned"
	int chargesLeft
	int chargesRight
	string msg
	
	if (currentPoisonLeft)
		chargesLeft = WornGetPoisonCharges(target, 0)
		poisonNameLeft = currentPoisonLeft.GetName()
		if (chargesLeft > 1)
			poisonNameLeft += " (" + chargesLeft + ")"
		endIf
		SendModEvent("_PSX_SetPoisonTextLeft", poisonNameLeft)
		string itemLeft = WornObject.GetDisplayName(target, 0, 0)
		msg = itemLeft + ": " + poisonNameLeft + " (" + currentPoisonLeft.GetFormId() + ")"
	else
		SendModEvent("_PSX_SetPoisonTextLeft", "")
	endIf
	
	if (currentPoisonRight)
		chargesRight = WornGetPoisonCharges(target, 1)
		poisonNameRight = currentPoisonRight.GetName()
		if (chargesRight > 1)
			poisonNameRight += " (" + chargesRight + ")"
		endIf
		SendModEvent("_PSX_SetPoisonTextRight", poisonNameRight)
		string itemRight = WornObject.GetDisplayName(target, 1, 0)
		if (msg)
			msg += "; "
		else
			msg = ""
		endIf
		msg += itemRight + ": " + poisonNameRight + " (" + currentPoisonRight.GetFormId() + ")"
	else
		SendModEvent("_PSX_SetPoisonTextRight", "")
	endIf
	
	;Debug.Notification(msg)
	Debug.Trace(msg)
	
endFunction


Function WornIncreasePoisonCharges(Actor target)

	if (!target)
		Debug.Notification("invalid target")
		return
	endIf
	
	string msg = WornObject.GetDisplayName(target, 1, 0)
	int initialCharges = WornGetPoisonCharges(target, 1)
	if (initialCharges < 0)
		msg += " is not poisoned"
		Debug.Notification(msg)
	else
		int newCharges = initialCharges + 1
		WornSetPoisonCharges(target, 1, newCharges)
		msg += " had " + initialCharges + ", now has " + WornGetPoisonCharges(target, 1)
	endIf
	Debug.Trace(msg)
endFunction

Function WornDecreasePoisonCharges(Actor target)

	if (!target)
		Debug.Notification("invalid target")
		return
	endIf
	
	string msg = WornObject.GetDisplayName(target, 1, 0)
	int initialCharges = WornGetPoisonCharges(target, 1)
	if (initialCharges < 0)
		msg += " is not poisoned"
		Debug.Notification(msg)
	else
		int newCharges = initialCharges - 1
		if (newCharges < 0)
			newCharges = 0
		endIf
		WornSetPoisonCharges(target, 1, newCharges)
		msg += " had " + initialCharges + ", now has " + WornGetPoisonCharges(target, 1)
	endIf
	Debug.Trace(msg)
endFunction

Function WornPoisonObject(Actor target, Potion poison)

	if (!target)
		Debug.Notification("invalid target")
		return
	endIf
	
	if (!poison)
		Debug.Notification("can't find poison")
		return
	endIf
	int ret = WornSetPoison(target, 1, poison, 1)
	if (ret < 0)
		Debug.Notification("can't poison target")
	else
		WornPoisonStatus(target)
	endIf

endFunction

Function WornUnpoisonObject(Actor target)

	if (!target)
		Debug.Notification("invalid target")
		return
	endIf
	
	Potion removedPoison = WornObjectRemovePoison(target, 1, 0)
	
	string msg = "Attempting to un-poison: "
	
	if (!removedPoison)
		msg += "failed"
	else
		msg += "successful - got back " + removedPoison.GetName() + " (" + removedPoison.GetFormId() + ")"
		Game.GetPlayer().AddItem(removedPoison, 1, true)
		Game.GetPlayer().RemoveItem(removedPoison, 1, true, target)
	endIf
	
	Debug.Notification(msg)
	Debug.Trace(msg)

endFunction


event OnMenuOpen(string a_MenuName)

	RegisterForModEvent("bp_selectionChange", "OnItemSelectionChange")
	RegisterForModEvent("bp_tabChange", "OnTabChange")
	currentMenu = a_MenuName
	string msg = "Opened " + a_MenuName

	if (currentMenu == "InventoryMenu")
		WornObjectSubject = PlayerRef as Actor
	else
		; sometimes the container opens before the activate script has run
		; give the script 50ms to settle
		int i = 50
		while (!TargetRef && i)
			Utility.WaitMenuMode(1)
			i -= 1
		endWhile
		if (!TargetRef)
			msg = "Can't find target - can't continue"
			Debug.Trace(msg)
			Debug.Notification(msg)
			return
		endIf
		if (TargetRef.GetType() == 28)
			WornObjectSubject = None
		else
			WornObjectSubject = TargetRef as Actor
		endIf
	endIf
	
	if (WornObjectSubject)
		msg += " of " + WornObjectSubject.GetLeveledActorBase().GetName()
	elseIf (TargetRef)
		msg += " of " + TargetRef.GetBaseObject().GetName()
	else
		msg += " (of nothing)"
	endIf
	Debug.Trace(msg)
	Debug.Notification(msg)
	
	string[] counterArgs = new string[2]
	counterArgs[0] = "poisonMonitorContainer"
	counterArgs[1] = "5"

	UI.InvokeStringA(a_MenuName, "_root.createEmptyMovieClip", counterArgs)
	UI.InvokeString(a_MenuName, "_root.poisonMonitorContainer.loadMovie", "PoisonMonitor.swf")
	
endEvent

event OnMenuClose(string a_MenuName)
	UnregisterForModEvent("bp_selectionChange")
	UnregisterForModEvent("bp_tabChange")
	currentMenu = ""
	TargetRef = None
	Debug.Trace("Closed " + a_MenuName)
	WornPoisonStatus(Game.GetPlayer())
endEvent

event OnItemSelectionChange(string asEventName, string asStrArg, float afNumArg, Form akSender)
	;Weapon w = akSender as Weapon
	;Armor am = akSender as Armor
	;if (!w && !am)
		;return
	;endIf
	
	;Debug.Trace("Selected " + akSender + ", type " + asStrArg + ", slot " + afNumArg)

	if (asStrArg != "weapon")
		return
	endIf
	
	;bows are afNumArg 2
	if (afNumArg == 2)
		afNumArg = 1
	endIf
	
	if (!WornObjectSubject)
		return
	endIf
	
	int currentCharges = WornObjectGetPoisonCharges(WornObjectSubject, afNumArg as int, 0)
	
	if (currentCharges <= 0)
		return
	endIf
	
	Potion currentPoison = WornObject.GetPoison(WornObjectSubject, afNumArg as int, 0)
	string msg = currentPoison.GetName()
	if (currentCharges > 1)
		msg += " (" + currentCharges + ")"
	endIf
	UI.SetString(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData.text", msg)
	
	;string currName = UI.GetString(currentMenu, "_root.Menu_mc.itemCard.ItemName.text")
	;Debug.Trace("Selected " + akSender + ", Item Card Name: " + currName + ", Charges on slot " + afNumArg + ": " + currentCharges)

endEvent

event OnTabChange(string asEventName, string asStrArg, float afNumArg, Form akSender)
	string msg = "Showing tab " + afNumArg
	if (afNumArg == 1)
		WornObjectSubject = PlayerRef as Actor
	else
		WornObjectSubject = TargetRef as Actor
	endIf
	if (WornObjectSubject)
		msg += " (" + WornObjectSubject.GetLeveledActorBase().GetName() + ")"
	elseIf(TargetRef)
		msg += " (" + TargetRef.GetBaseObject().GetName() + ")"
	endIf
	Debug.Trace(msg)
endEvent

event OnContainerActivated(Form akTargetRef)
	string msg
	TargetRef = akTargetRef as ObjectReference
	if (TargetRef)
		Actor isActor = TargetRef as Actor
		if (isActor)
			msg = "TargetRef set to " + isActor.GetLeveledActorBase().GetName()
		else
			msg = "TargetRef set to " + TargetRef.GetBaseObject().GetName()
		endIf
	else
		msg = "Could not set TargetRef"
		Debug.Notification(msg)
	endIf
	Debug.Trace(msg)
endEvent
