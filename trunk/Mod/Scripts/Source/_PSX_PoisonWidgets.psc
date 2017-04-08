scriptname _PSX_PoisonWidgets extends SKI_WidgetBase  

; PRIVATE VARIABLES -------------------------------------------------------------------------------

bool	_visible			= true
string	_poisonTextLeft
string	_poisonTextRight
float 	_leftX
float 	_leftY
float 	_rightX
float 	_rightY


; PROPERTIES --------------------------------------------------------------------------------------

bool Property Visible
	bool function get()
		return _visible
	endFunction

	function set(bool a_val)
		_visible = a_val
		if (Ready)
			UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", _visible) 
		endIf
	endFunction
endProperty

string Property PoisonTextLeft
	string function get()
		return _poisonTextLeft
	endFunction

	function set(string a_val)
		_poisonTextLeft = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonTextLeft", _poisonTextLeft) 
		endIf
	endFunction
endProperty

string Property PoisonTextRight
	string function get()
		return _poisonTextRight
	endFunction

	function set(string a_val)
		_poisonTextRight = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonTextRight", _poisonTextRight) 
		endIf
	endFunction
endProperty

float Property LeftX
	float function get()
		return _leftX
	endFunction

	function set(float a_val)
		_leftX = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonLeftPosX", _leftX) 
		endIf
	endFunction
endProperty

float Property LeftY
	float function get()
		return _leftY
	endFunction

	function set(float a_val)
		_leftY = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonLeftPosY", _leftY) 
		endIf
	endFunction
endProperty

float Property RightX
	float function get()
		return _rightX
	endFunction

	function set(float a_val)
		_rightX = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonRightPosX", _rightX) 
		endIf
	endFunction
endProperty

float Property RightY
	float function get()
		return _rightY
	endFunction

	function set(float a_val)
		_rightY = a_val
		if (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonRightPosY", _rightY) 
		endIf
	endFunction
endProperty



; EVENTS ------------------------------------------------------------------------------------------

Event OnGameReload()
	Y = 680
	_leftX = 90
	_rightX = 850
	parent.OnGameReload()
	RegisterForModEvent("_PSX_VisToggle", "OnVisToggle")
	RegisterForModEvent("_PSX_SetPoisonTextLeft", "OnSetPoisonTextLeft")
	RegisterForModEvent("_PSX_SetPoisonTextRight", "OnSetPoisonTextRight")
	RegisterForModEvent("_PSX_BumpPoisonUp", "OnBumpPoisonUp")
	RegisterForModEvent("_PSX_BumpPoisonDown", "OnBumpPoisonDown")
	RegisterForModEvent("_PSX_BumpPoisonLeft", "OnBumpPoisonLeft")
	RegisterForModEvent("_PSX_BumpPoisonRight", "OnBumpPoisonRight")
	Debug.Trace("_PSX_PoisonWidgets - OnGameReload (type '" + GetWidgetType() + "')")
	UpdateStatus()
EndEvent

; @override SKI_WidgetBase
event OnWidgetReset()
	parent.OnWidgetReset()
	
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", _visible)
	UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonLeftPosX", _leftX) 
	UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonRightPosX", _rightX) 
	
	string msg = "OnWidgetReset - visible: " + _visible + ", text: " + _poisonTextLeft
	Debug.Notification(msg)
	Debug.Trace(msg)
endEvent


Event OnVisToggle(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	bool wasVis = Visible
	Visible = !wasVis
	;UpdateStatus()
EndEvent

Event OnSetPoisonTextLeft(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	PoisonTextLeft = a_strArg
	;UpdateStatus()
EndEvent

Event OnSetPoisonTextRight(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	PoisonTextRight = a_strArg
	;UpdateStatus()
EndEvent

Event OnBumpPoisonUp(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	float oldRightY = RightY
	RightY = oldRightY - 50
	Debug.Notification(oldRightY + " => " + RightY)
EndEvent

Event OnBumpPoisonDown(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	float oldRightY = RightY
	RightY = oldRightY + 50
	Debug.Notification(oldRightY + " => " + RightY)
EndEvent

Event OnBumpPoisonLeft(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	float oldRightX = RightX
	RightX = oldRightX - 50
	Debug.Notification(oldRightX + " => " + RightX)
EndEvent

Event OnBumpPoisonRight(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	float oldRightX = RightX
	RightX = oldRightX + 50
	Debug.Notification(oldRightX + " => " + RightX)
EndEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @overrides SKI_WidgetBase
string function GetWidgetSource()
	return "poisoningextended/poisoninfo.swf"
endFunction

; @overrides SKI_WidgetBase
string function GetWidgetType()
	; Must be the same as scriptname
	return "_PSX_PoisonWidgets"
endFunction


function UpdateStatus()
	if (Ready)
		UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", _visible)
		UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonLeftPosX", _leftX) 
		UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonRightPosX", _rightX) 
		
		;UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonTextLeft", _poisonTextLeft)
		;UI.InvokeString(HUD_MENU, WidgetRoot + ".setPoisonTextRight", _poisonTextRight)
		;UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setPositionX", 950)
		;UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setPositionY", 500)
		;UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setAlpha", 50)
		string msg = "UpdateStatus - visible: pub " + Visible + ", pri " + _visible + "; text: pub " + PoisonTextLeft + ", pri " + _poisonTextLeft
		;Debug.Notification(msg)
		Debug.Trace(msg)
	endIf
endFunction

