Scriptname _PSX_QuestScript extends Quest  

string currentMenu

import _Q2C_Functions

Perk Property _KLV_StashRefPerk  Auto
Sound Property _PSX_PoisonUse Auto
Sound Property _PSX_PoisonRemove  Auto  

Potion Property _PSX_TestPoison  Auto

ObjectReference Property TargetRef Auto
Actor Property PlayerRef Auto

int ChargesPerPoison = 1
int ChargesRefundedPerPoison = 1


Actor WornObjectSubject
int currentEquipSlot

event OnInit()
	Maintenance()
endEvent

function Maintenance()

	RegisterForMenu("InventoryMenu")
	RegisterForMenu("ContainerMenu")
	
	RegisterForModEvent("_KLV_ContainerActivated", "OnContainerActivated")
	
	if (!PlayerRef.HasPerk(_KLV_StashRefPerk))
		PlayerRef.AddPerk(_KLV_StashRefPerk)
	endIf
	
	currentEquipSlot = -1
	
	; stuff for testing
	RegisterForKey(40) ; '
	_PSX_TestPoison.SetName("Test poison of having a totally long and fully unwieldy name...")
	
endFunction


event OnKeyDown(int aiKeyCode)

	if (aiKeyCode == 48) ; B - direct LH poison
		HandleInventoryHotkey(aiKeyCode)
	
	elseif (aiKeyCode == 49) ; N - direct RH poison
		HandleInventoryHotkey(aiKeyCode)
	
	elseif (aiKeyCode == 40) ; '
		;Potion poison = Game.GetFormFromFile(0x0003a5a4, "Skyrim.esm") as Potion ; weak damage health
		;Potion poison = Game.GetFormFromFile(0x00073f31, "Skyrim.esm") as Potion ; weak damage health
		;Potion poison = Game.GetFormFromFile(0x00073f32, "Skyrim.esm") as Potion ; weak damage health
		;Potion poison = Game.GetFormFromFile(0x00073f33, "Skyrim.esm") as Potion ; weak damage health
		Potion poison = Game.GetFormFromFile(0x00073f34, "Skyrim.esm") as Potion ; deadly damage health
		playerRef.AddItem(poison, 1)
		playerRef.AddItem(_PSX_TestPoison, 1)
	endIf

endEvent

event OnMenuOpen(string a_MenuName)

	RegisterForModEvent("_psx_selectionChange", "OnItemSelectionChange")
	RegisterForModEvent("_psx_tabChange", "OnTabChange")
	currentMenu = a_MenuName
	string msg = "Opened " + currentMenu

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
			currentEquipSlot = -1
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
	;Debug.Notification(msg)
	
	string[] counterArgs = new string[2]
	counterArgs[0] = "poisonMonitorContainer"
	counterArgs[1] = "5"

	UI.InvokeStringA(currentMenu, "_root.createEmptyMovieClip", counterArgs)
	UI.InvokeString(currentMenu, "_root.poisonMonitorContainer.loadMovie", "PoisonMonitor.swf")
	
	RegisterForKey(48) ; B - direct LH poison or remove poison
	RegisterForKey(49) ; N - direct RH poison
	
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

event OnItemSelectionChange(string asEventName, string asStrArg, float afNumArg, Form akSender)

	if (!WornObjectSubject || asStrArg != "weapon")
		currentEquipSlot = -1
		return
	endIf
	
	currentEquipSlot = afNumArg as int
	if (currentEquipSlot == 2)
		;bows are 2
		currentEquipSlot = 1
	endIf
	
	Potion currentPoison = WornGetPoison(WornObjectSubject, currentEquipSlot)
	if (!currentPoison)
		currentEquipSlot = -1
		return
	endIf
	
	string msg = currentPoison.GetName()
	int currentCharges = WornGetPoisonCharges(WornObjectSubject, currentEquipSlot)
	if (currentCharges > 1)
		msg += " (" + currentCharges + ")"
	endIf
	UI.SetString(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData.text", msg)
	
	;string currName = UI.GetString(currentMenu, "_root.Menu_mc.itemCard.ItemName.text")
	;Debug.Trace("Selected " + akSender + ", Item Card Name: " + currName + ", Charges on slot " + currentEquipSlot + ": " + currentCharges)

endEvent

event OnMenuClose(string a_MenuName)
	UnregisterForModEvent("_psx_selectionChange")
	UnregisterForModEvent("_psx_tabChange")
	UnregisterForKey(48) ; B - direct RH poison
	UnregisterForKey(49) ; N - direct RH poison
	currentMenu = ""
	TargetRef = None
	currentEquipSlot = -1
	Debug.Trace("Closed " + a_MenuName)
	UpdatePoisonWidgets()
endEvent


function HandleInventoryHotkey(int aiKeyCode)

	if (!WornObjectSubject || currentMenu == "")
		;Debug.Notification("Not a person's inventory")
		return
	endIf

	int formId = UI.GetInt(currentMenu, "_root.Menu_mc.inventoryLists.panelContainer.itemList.selectedEntry.formId")
	Form invForm = Game.GetForm(formId)
	if (invForm as Potion)
		if (aiKeyCode == 48)
			DirectPoison(invForm as Potion, 0)
		else
			DirectPoison(invForm as Potion, 1)
		endIf
	elseIf (invForm as Weapon)
		RemovePoison(invForm as Weapon)
	endIf

endFunction

Function DirectPoison(Potion akPoison, int aiHand)

	Weapon actorWeapon = WornObjectSubject.GetEquippedWeapon(aiHand == 0)
	if (!actorWeapon)
		Debug.Notification("No weapon to poison in " + GetHandName(aiHand) + " hand")
		return
	endIf
	
	Potion currentPoison = WornGetPoison(WornObjectSubject, aiHand)
	int chargesToSet = ChargesPerPoison
	if (currentPoison)
		if (currentPoison != akPoison)
			Debug.Notification("The current weapon is already poisoned with " + currentPoison.GetName() + ". Remove this poison before using another.")
			return
		endIf
		chargesToSet += WornGetPoisonCharges(WornObjectSubject, aiHand)
		WornSetPoisonCharges(WornObjectSubject, aiHand, chargesToSet)
	else
		WornSetPoison(WornObjectSubject, aiHand, akPoison, chargesToSet)
	endIf
	
	WornObjectSubject.RemoveItem(akPoison, 1, true)
	_PSX_PoisonUse.Play(playerRef)
	
	string msg = WornObjectSubject.GetLeveledActorBase().GetName() + "'s " + actorWeapon.GetName() + " has " + chargesToSet + " of " + akPoison.GetName()
	Debug.Trace(msg)
	
endFunction

Function RemovePoison(Weapon akWeapon)

	; think I need a better way than currentEquipSlot..
	Potion currentPoison = WornGetPoison(WornObjectSubject, currentEquipSlot)
	if (!currentPoison)
		Debug.Notification("Weapon in slot " + currentEquipSlot + " not poisoned")
		return
	endIf
	
	int currentCharges = WornGetPoisonCharges(WornObjectSubject, currentEquipSlot)
	WornRemovePoison(WornObjectSubject, currentEquipSlot)
	
	; need a better remove sound
	_PSX_PoisonRemove.Play(playerRef)
	UI.SetString(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData.text", "")
	UI.InvokeBool(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance.gotoAndStop", false)
	; ought to remove little icon in main item list too if poss..
	
	
	string msg = "Removed " + currentCharges + " of " + currentPoison.GetName() + " from " + WornObjectSubject.GetLeveledActorBase().GetName() + "'s " + akWeapon.GetName()
	Debug.Trace(msg)
	
endFunction

function UpdatePoisonWidgets()

	Potion currentPoisonLeft = WornGetPoison(playerRef, 0)
	Potion currentPoisonRight = WornGetPoison(playerRef, 1)
	
	if (!currentPoisonLeft)
		SendModEvent("_PSX_SetPoisonTextLeft", "")
	else
		string poisonNameLeft = currentPoisonLeft.GetName()
		int chargesLeft = WornGetPoisonCharges(playerRef, 0)
		if (chargesLeft > 1)
			poisonNameLeft += " (" + chargesLeft + ")"
		endIf
		SendModEvent("_PSX_SetPoisonTextLeft", poisonNameLeft)
	endIf
	
	if (!currentPoisonRight)
		SendModEvent("_PSX_SetPoisonTextRight", "")
	else
		string poisonNameRight = currentPoisonRight.GetName()
		int chargesRight = WornGetPoisonCharges(playerRef, 1)
		if (chargesRight > 1)
			poisonNameRight += " (" + chargesRight + ")"
		endIf
		SendModEvent("_PSX_SetPoisonTextRight", poisonNameRight)
	endIf
	
endFunction


string function GetHandName(int aiHand)
	if (aiHand == 0)
		return "left"
	elseIf (aiHand == 1)
		return "right"
	endIf
	return "unknown"
endFunction
