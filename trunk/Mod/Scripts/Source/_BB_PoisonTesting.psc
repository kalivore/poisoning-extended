Scriptname _BB_PoisonTesting extends Quest  

string currentMenu

import _Q2C_Functions

Perk Property _BB_StashRefPerk  Auto

Potion Property _BB_TestPoison  Auto

ObjectReference Property TargetRef Auto
ObjectReference Property PlayerRef Auto

Actor Property WornObjectSubject Auto


function OnInit()
	RegisterForMenu("InventoryMenu")
	RegisterForMenu("ContainerMenu")
	RegisterForMenu("BarterMenu")
	;RegisterForMenu("Crafting Menu")
	
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

	(PlayerRef as Actor).AddPerk(_BB_StashRefPerk)

	_BB_TestPoison.SetName("Test poison of having a totally long and fully unwieldy name...")
	
endFunction


event OnKeyDown(int aiKeyCode)

int x1 = UI.GetInt(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData._x")
int y1 = UI.GetInt(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData._y")

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
		UI.SetInt(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData._y", y1 - 5)
	elseif (aiKeyCode == 75) ; 4
		UI.SetInt(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData._x", x1 - 5)
	elseif (aiKeyCode == 77) ; 6
		UI.SetInt(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData._x", x1 + 5)
	elseif (aiKeyCode == 72) ; 8
		UI.SetInt(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData._y", y1 + 5)
	
	elseif (aiKeyCode == 40) ; '
		Game.GetPlayer().AddItem(_BB_TestPoison, 1)
		Potion poison = Game.GetFormFromFile(0x0003a5a4, "Skyrim.esm") as Potion ; weak damage health
		Game.GetPlayer().AddItem(poison, 1)
	endIf

endEvent



Function WornPoisonStatus(Actor target)

	if (!target)
		Debug.Notification("invalid target")
		return
	endIf
	
	Potion currentPoison = WornGetPoison(target, 1)
	string msg = WornObject.GetDisplayName(target, 1, 0)
	if (!currentPoison)
		msg += " is not poisoned"
	else
		msg += " poisoned with " + currentPoison.GetName() + " (" + currentPoison.GetFormId() + "), has " + WornGetPoisonCharges(target, 1) + " charges"
	endIf
	Debug.Notification(msg)
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
	
	;/
	string path1 = "_root.Menu_mc.DoseCount.text"
	string path2 = "_root.Menu_mc.poisonMonitorContainer.DoseCount.text"
	string path3 = "_root.Menu_mc.PoisonMonitor.DoseCount.text"
	string path4 = "_root.Menu_mc.poisonMonitorContainer.PoisonMonitor.DoseCount.text"
	
	string text1 = UI.GetString(currentMenu, path1)
	string text2 = UI.GetString(currentMenu, path2)
	string text3 = UI.GetString(currentMenu, path3)
	string text4 = UI.GetString(currentMenu, path4)
	
	Debug.Trace("text1: " + text1)
	Debug.Trace("text2: " + text2)
	Debug.Trace("text3: " + text3)
	Debug.Trace("text4: " + text4)
	/;
	
	
	;/
	string[] containerArgs = new string[2]
	containerArgs[0] = "itemSelectionMonitorContainer"
	containerArgs[1] = "-16380"

	UI.InvokeStringA(a_MenuName, "_root.createEmptyMovieClip", containerArgs)
	UI.InvokeString(a_MenuName, "_root.itemSelectionMonitorContainer.loadMovie", "SelectedItemMonitor.swf")
	/;
	
endEvent

event OnMenuClose(string a_MenuName)
	UnregisterForModEvent("bp_selectionChange")
	UnregisterForModEvent("bp_tabChange")
	currentMenu = ""
	TargetRef = None
	Debug.Trace("Closed " + a_MenuName)
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


Actor Function GetPlayerDialogueTarget()
	Actor kPlayerDialogueTarget
	Actor kPlayerRef = Game.GetPlayer()
	Int iLoopCount = 10
	While iLoopCount > 0
		iLoopCount -= 1
		kPlayerDialogueTarget = Game.FindRandomActorFromRef(kPlayerRef , 200.0)
		If kPlayerDialogueTarget != kPlayerRef && kPlayerDialogueTarget.IsInDialogueWithPlayer() 
			Return kPlayerDialogueTarget
		EndIf
	EndWhile
	Return None
EndFunction

Int Function Round(Float i)
	If (i - (i as Int)) < 0.5
		Return (i as Int)
	Else
		Return (Math.Ceiling(i) as Int)
	EndIf
EndFunction
