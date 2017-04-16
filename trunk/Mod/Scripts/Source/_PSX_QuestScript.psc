Scriptname _PSX_QuestScript extends Quest  

float Property CurrentVersion = 0.0100 AutoReadonly
float previousVersion

string Property ModName = "Poisoning Extended" AutoReadonly
string Property LogName = "PoisoningExtended" AutoReadonly


GlobalVariable Property _PSX_DebugToFile Auto
bool priDebugToFile
bool Property DebugToFile
	bool function get()
		return priDebugToFile
	endFunction
	function set(bool val)
		_PSX_DebugToFile.SetValue(val as int)
		priDebugToFile = val
	endFunction
endProperty

GlobalVariable Property _PSX_ChargesPerPoisonVial  Auto
int priChargesPerPoisonVial
int Property ChargesPerPoisonVial
	int function get()
		return priChargesPerPoisonVial
	endFunction
	function set(int val)
		_PSX_ChargesPerPoisonVial.SetValue(val as int)
		priChargesPerPoisonVial = val
	endFunction
endProperty

GlobalVariable Property _PSX_ChargeMultiplier  Auto
int priChargeMultiplier
int Property ChargeMultiplier
	int function get()
		return priChargeMultiplier
	endFunction
	function set(int val)
		_PSX_ChargeMultiplier.SetValue(val as int)
		priChargeMultiplier = val
	endFunction
endProperty

GlobalVariable Property _PSX_KeycodePoisonLeft  Auto
int priKeycodePoisonLeft
int Property KeycodePoisonLeft
	int function get()
		return priKeycodePoisonLeft
	endFunction
	function set(int val)
		_PSX_KeycodePoisonLeft.SetValue(val as int)
		priKeycodePoisonLeft = val
	endFunction
endProperty
GlobalVariable Property _PSX_KeycodePoisonRght  Auto
int priKeycodePoisonRght
int Property KeycodePoisonRght
	int function get()
		return priKeycodePoisonRght
	endFunction
	function set(int val)
		_PSX_KeycodePoisonRght.SetValue(val as int)
		priKeycodePoisonRght = val
	endFunction
endProperty


Perk Property _KLV_StashRefPerk  Auto
Sound Property _PSX_PoisonUse Auto
Sound Property _PSX_PoisonRemove  Auto

ObjectReference Property TargetRef Auto
Actor Property PlayerRef Auto


Actor WornObjectSubject
string currentMenu



event OnInit()

	Update()

endEvent

function Update()

	; floating-point math is hard..  let's go shopping!
	int iPreviousVersion = (PreviousVersion * 10000) as int
	int iCurrentVersion = (CurrentVersion * 10000) as int
	
	if (iCurrentVersion != iPreviousVersion)

		;;;;;;;;;;;;;;;;;;;;;;;;;;
		; version-specific updates
		;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; end version-specific updates
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		; notify current version
		string msg = ModName
		if (PreviousVersion > 0)
			msg += " updated from v" + GetVersionAsString(PreviousVersion) + " to "
		else
			msg += " running "
		endIf
		msg += "v" + GetVersionAsString(CurrentVersion)
		DebugStuff(msg, msg, true)

		PreviousVersion = CurrentVersion
	endIf

	Maintenance()

endFunction

Function Maintenance()

	Debug.OpenUserLog(LogName)

	DebugToFile = true;_PSX_DebugToFile.GetValue() as bool
	ChargesPerPoisonVial = _PSX_ChargesPerPoisonVial.GetValue() as int
	ChargeMultiplier = _PSX_ChargeMultiplier.GetValue() as int
	KeycodePoisonLeft = 49;_PSX_KeycodePoisonLeft.GetValue() as int
	KeycodePoisonRght = 48;_PSX_KeycodePoisonRght.GetValue() as int

	RegisterForMenu("InventoryMenu")
	RegisterForMenu("ContainerMenu")
	
	RegisterForModEvent("_KLV_ContainerActivated", "OnContainerActivated")
	
	if (!PlayerRef.HasPerk(_KLV_StashRefPerk))
		PlayerRef.AddPerk(_KLV_StashRefPerk)
	endIf
	
endFunction


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
		DebugStuff(msg, msg, true)
	endIf
	DebugStuff(msg)
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
			DebugStuff(msg, msg, true)
			return
		endIf
		
		if (TargetRef.GetType() == 28) ; Container is type 28
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
	DebugStuff(msg)
	
	string[] counterArgs = new string[2]
	counterArgs[0] = "poisonMonitorContainer"
	counterArgs[1] = "5"

	UI.InvokeStringA(currentMenu, "_root.createEmptyMovieClip", counterArgs)
	UI.InvokeString(currentMenu, "_root.poisonMonitorContainer.loadMovie", "PoisonMonitor.swf")
	
	RegisterForKey(KeycodePoisonLeft) ; direct LH poison or remove poison
	RegisterForKey(KeycodePoisonRght) ; direct RH poison
	
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
	DebugStuff(msg)
endEvent

event OnItemSelectionChange(string asEventName, string asStrArg, float afNumArg, Form akSender)

	if (!WornObjectSubject || asStrArg != "weapon")
		return
	endIf
	
	int currentEquipSlot = afNumArg as int
	if (currentEquipSlot == 2)
		; bows are UI state 2, but count as slot 1 for WornObject
		currentEquipSlot = 1
	endIf
	
	Potion currentPoison = _Q2C_Functions.WornGetPoison(WornObjectSubject, currentEquipSlot)
	if (!currentPoison)
		return
	endIf
	
	string msg = currentPoison.GetName()
	int currentCharges = _Q2C_Functions.WornGetPoisonCharges(WornObjectSubject, currentEquipSlot)
	if (currentCharges > 1)
		msg += " (" + currentCharges + ")"
	endIf
	UI.SetString(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData.text", msg)
	
endEvent

event OnKeyDown(int aiKeyCode)

	if (aiKeyCode == KeycodePoisonLeft)
		HandleInventoryHotkey(aiKeyCode)
	elseif (aiKeyCode == KeycodePoisonRght)
		HandleInventoryHotkey(aiKeyCode)
	endIf

endEvent

event OnMenuClose(string a_MenuName)
	UnregisterForModEvent("_psx_selectionChange")
	UnregisterForModEvent("_psx_tabChange")
	UnregisterForKey(KeycodePoisonLeft)
	UnregisterForKey(KeycodePoisonRght)
	currentMenu = ""
	TargetRef = None
	DebugStuff("Closed " + a_MenuName)
	UpdatePoisonWidgets()
endEvent


function HandleInventoryHotkey(int aiKeyCode)

	if (!WornObjectSubject || currentMenu == "")
		;DebugStuff("Not a person's inventory", "Not a person's inventory")
		return
	endIf

	int formId = UI.GetInt(currentMenu, "_root.Menu_mc.inventoryLists.panelContainer.itemList.selectedEntry.formId")
	Form invForm = Game.GetForm(formId)
	if (invForm as Potion)
		if (aiKeyCode == KeycodePoisonLeft)
			DirectPoison(invForm as Potion, 0)
		else
			DirectPoison(invForm as Potion, 1)
		endIf
	elseIf (invForm as Weapon)
		RemovePoison(invForm as Weapon)
	else
		Debug.Notification("Can't find game form " + formId)
		Debug.Trace("Can't find game form " + formId)
	endIf

endFunction

Function DirectPoison(Potion akPoison, int aiHand)

	Weapon actorWeapon = WornObjectSubject.GetEquippedWeapon(aiHand == 0)
	if (!actorWeapon)
		string msg = "No weapon to poison in " + GetHandName(aiHand) + " hand"
		DebugStuff(msg, msg)
		return
	endIf
	
	Potion currentPoison = _Q2C_Functions.WornGetPoison(WornObjectSubject, aiHand)
	int chargesToSet = ChargesPerPoisonVial * ChargeMultiplier
	if (currentPoison)
		if (currentPoison != akPoison)
			string msg = "The current weapon is already poisoned with " + currentPoison.GetName()
			DebugStuff(msg, msg)
			return
		endIf
		chargesToSet += _Q2C_Functions.WornGetPoisonCharges(WornObjectSubject, aiHand)
		_Q2C_Functions.WornSetPoisonCharges(WornObjectSubject, aiHand, chargesToSet)
	else
		_Q2C_Functions.WornSetPoison(WornObjectSubject, aiHand, akPoison, chargesToSet)
	endIf
	
	WornObjectSubject.RemoveItem(akPoison, 1, true)
	_PSX_PoisonUse.Play(playerRef)
	
	string msg = WornObjectSubject.GetLeveledActorBase().GetName() + "'s " + actorWeapon.GetName() + " has " + chargesToSet + " of " + akPoison.GetName()
	DebugStuff(msg)
	
endFunction

Function RemovePoison(Weapon akWeapon)

	int currentEquipSlot = UI.GetInt(currentMenu, "_root.Menu_mc.inventoryLists.panelContainer.itemList.selectedEntry.equipState")
	if (currentEquipSlot < 2)
		return
	endIf
	; vals are 2,3,4 for left/right/both - remove 2 to convert to SKSE's 0/1
	currentEquipSlot -= 2
	if (currentEquipSlot == 2)
		; bows are UI state 2, but count as slot 1 for WornObject
		currentEquipSlot = 1
	endIf
	
	Potion currentPoison = _Q2C_Functions.WornGetPoison(WornObjectSubject, currentEquipSlot)
	if (!currentPoison)
		DebugStuff("This weapon is not poisoned", "This weapon is not poisoned")
		return
	endIf
	
	int currentCharges = _Q2C_Functions.WornGetPoisonCharges(WornObjectSubject, currentEquipSlot)
	_Q2C_Functions.WornRemovePoison(WornObjectSubject, currentEquipSlot)
	_PSX_PoisonRemove.Play(playerRef)
	UI.SetString(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance._poisonData.text", "")
	UI.InvokeString(currentMenu, "_root.Menu_mc.itemCard.PoisonInstance.gotoAndStop", "Off")
	; need a way to access current list entry
	; "_root.Menu_mc.inventoryLists.panelContainer.itemList.ItemsListEntryXX.poisonIcon._height"
	; or run InvalidateListData to rebuild everything
	; UI.Invoke(currentMenu, "_root.Menu_mc.inventoryLists.InvalidateListData")
	
	string msg = "Removed " + currentCharges + " of " + currentPoison.GetName() + " from " + WornObjectSubject.GetLeveledActorBase().GetName() + "'s " + akWeapon.GetName()
	DebugStuff(msg)
	
endFunction

function UpdatePoisonWidgets()

	Potion currentPoisonLeft = _Q2C_Functions.WornGetPoison(playerRef, 0)
	Potion currentPoisonRight = _Q2C_Functions.WornGetPoison(playerRef, 1)
	
	if (!currentPoisonLeft)
		SendModEvent("_PSX_SetPoisonTextLeft", "")
	else
		string poisonNameLeft = currentPoisonLeft.GetName()
		int chargesLeft = _Q2C_Functions.WornGetPoisonCharges(playerRef, 0)
		if (chargesLeft > 1)
			poisonNameLeft += " (" + chargesLeft + ")"
		endIf
		SendModEvent("_PSX_SetPoisonTextLeft", poisonNameLeft)
	endIf
	
	if (!currentPoisonRight)
		SendModEvent("_PSX_SetPoisonTextRight", "")
	else
		string poisonNameRight = currentPoisonRight.GetName()
		int chargesRight = _Q2C_Functions.WornGetPoisonCharges(playerRef, 1)
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

string function GetVersionAsString(float afVersion)

	string raw = afVersion as string
	int dotPos = StringUtil.Find(raw, ".")
	string major = StringUtil.SubString(raw, 0, dotPos)
	string minor = StringUtil.SubString(raw, dotPos + 1, 2)
	string revsn = StringUtil.SubString(raw, dotPos + 3, 2)
	return major + "." + minor + "." + revsn

endFunction

function DebugStuff(string asLogMsg, string asScreenMsg = "", bool abPrefix = false)

	if (DebugToFile)
		Debug.TraceUser(LogName, asLogMsg)
	endIf
	if (asScreenMsg != "")
		if (abPrefix)
			asScreenMsg = ModName + " - " + asScreenMsg
		endIf
		Debug.Notification(asScreenMsg)
	endIf

endFunction
