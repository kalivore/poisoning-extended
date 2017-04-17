ScriptName _PSX_ConfigMenuScript extends SKI_ConfigBase

; SCRIPT VERSION ----------------------------------------------------------------------------------
;
; History
;
; 1 - Initial version

int function GetVersion()
	return 1
endFunction


; PRIVATE VARIABLES -------------------------------------------------------------------------------
; string constants
string C_LOGO_PATH = "PoisoningExtended/mcm_logo.dds"
; Image size 768x384
; X offset = 376 - (width / 2) = -8
int offsetX = -8
; Y offset = 223 - (height / 2) = 31
int offsetY = 31

string C_STRING_EMPTY = ""

; Translatables
string C_MOD_NAME = "$PSXModName"
string C_PAGE_MISC = "$PSXPageMisc"
string C_FORMAT_PLACEHOLDER_SECONDS = "$PSXFormatPlaceholderSeconds"
string C_FORMAT_PLACEHOLDER_PERCENT = "$PSXFormatPlaceholderPercent"
string C_MENU_OPTION_ALWAYS = "$PSXMenuOptionAlways"
string C_MENU_OPTION_NEW_POISON = "$PSXMenuOptionNewPoison"
string C_MENU_OPTION_BENEFICIAL = "$PSXMenuOptionBeneficial"
string C_MENU_OPTION_NEVER = "$PSXMenuOptionNever"
string C_OPTION_LABEL_PROMPTS = "$PSXOptionLabelPrompts"
string C_OPTION_LABEL_HOTKEYLEFT = "$PSXOptionLabelHotkeyLeft"
string C_OPTION_LABEL_HOTKEYRGHT = "$PSXOptionLabelHotkeyRght"
string C_OPTION_LABEL_SHOWWIDGETS = "$PSXOptionLabelShowWidgets"
string C_OPTION_LABEL_DEBUG = "$PSXOptionLabelDebug"
string C_OPTION_LABEL_CURRENT_VERSION = "$PSXOptionLabelCurrentVersion"
string C_INFO_TEXT_POISONPROMPT = "$PSXInfoTextPoisonPrompt"
string C_INFO_TEXT_SHOWWIDGETS = "$PSXInfoTextShowWidgets"
string C_INFO_TEXT_DEBUG = "$PSXInfoTextDebug"

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int			_poisonPromptOID_M
int			_hotkeyLeftOID_K
int			_hotkeyRghtOID_K
int			_showWidgetsOID_B
int			_debugOID_B
int			_currentVersionOID_T


; State
int poisonPrompt
int poisonPromptDefault
int hotkeyLeft
int hotkeyLeftDefault
int hotkeyRght
int hotkeyRghtDefault
bool showWidgets
bool showWidgetsDefault
bool modDebug
bool modDebugDefault

; Internal
_PSX_QuestScript Property PSXQuest Auto

string[] poisonPromptOptions


; INITIALIZATION ----------------------------------------------------------------------------------

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
	if (a_version > 1)
		OnConfigInit()
	endIf
endEvent

; @overrides SKI_ConfigBase
event OnConfigInit()

	ModName = C_MOD_NAME

	Pages = new string[1]
	Pages[0] = C_PAGE_MISC
	
	poisonPromptOptions = new string[4]
	poisonPromptOptions[0] = C_MENU_OPTION_ALWAYS
	poisonPromptOptions[1] = C_MENU_OPTION_NEW_POISON
	poisonPromptOptions[2] = C_MENU_OPTION_BENEFICIAL
	poisonPromptOptions[3] = C_MENU_OPTION_NEVER
	
	poisonPromptDefault = 1
	hotkeyLeftDefault = -1
	hotkeyRghtDefault = -1
	showWidgetsDefault = true
	modDebugDefault = false
	
endEvent


; EVENTS ------------------------------------------------------------------------------------------

Event OnConfigOpen()
EndEvent

Event OnConfigClose()
EndEvent

; @implements SKI_ConfigBase
event OnPageReset(string a_page)
	{Called when a new page is selected, including the initial empty page}

	; Load custom logo in DDS format
	if (a_page == C_STRING_EMPTY)
		LoadCustomContent(C_LOGO_PATH, offsetX, offsetY)
		return
	else
		UnloadCustomContent()
	endIf

	SetCursorFillMode(TOP_TO_BOTTOM)
	
	; get values to use on page
	if (a_page == C_PAGE_MISC)
	
		poisonPrompt = PSXQuest.ConfirmPoison
		hotkeyLeft = PSXQuest.KeycodePoisonLeft
		hotkeyRght = PSXQuest.KeycodePoisonRght
		showWidgets = PSXQuest.ShowWidgets
		modDebug = PSXQuest.DebugToFile
	
		_poisonPromptOID_M	= AddMenuOption(C_OPTION_LABEL_PROMPTS, poisonPromptOptions[poisonPrompt])
		
		AddEmptyOption()
		
		_hotkeyRghtOID_K	= AddKeyMapOption(C_OPTION_LABEL_HOTKEYRGHT, hotkeyRght)
		_hotkeyLeftOID_K	= AddKeyMapOption(C_OPTION_LABEL_HOTKEYLEFT, hotkeyLeft)
		
		AddEmptyOption()
		
		_showWidgetsOID_B	= AddToggleOption(C_OPTION_LABEL_SHOWWIDGETS, showWidgets)
		
		AddEmptyOption()
		
		_debugOID_B	= AddToggleOption(C_OPTION_LABEL_DEBUG, modDebug)
		
		AddEmptyOption()
		
		_currentVersionOID_T = AddTextOption(C_OPTION_LABEL_CURRENT_VERSION, PSXQuest.GetVersionAsString(PSXQuest.CurrentVersion), OPTION_FLAG_DISABLED)
		
		SetCursorPosition(1) ; Move to the top of the right-hand pane
		
		return

	endIf
	
endEvent


; @implements SKI_ConfigBase
event OnOptionHighlight(int a_option)
	{Called when highlighting an option}

	if (a_option == _poisonPromptOID_M)
		SetInfoText(C_INFO_TEXT_POISONPROMPT)
	
	elseIf (a_option == _showWidgetsOID_B)
		SetInfoText(C_INFO_TEXT_SHOWWIDGETS)
	
	elseIf (a_option == _debugOID_B)
		SetInfoText(C_INFO_TEXT_DEBUG)
	
	endIf
	
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}
	
	if (a_option == _poisonPromptOID_M)
		SetMenuDialogStartIndex(poisonPrompt)
		SetMenuDialogDefaultIndex(poisonPromptDefault)
		SetMenuDialogOptions(poisonPromptOptions)
	endIf
	
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when the user accepts a new menu entry}
	
	if (a_option == _poisonPromptOID_M)
		poisonPrompt = a_index
		SetMenuOptionValue(_poisonPromptOID_M, poisonPromptOptions[poisonPrompt])
		PSXQuest.ConfirmPoison = poisonPrompt

	endIf	

endEvent

; @implements SKI_ConfigBase
event OnOptionSelect(int a_option)
	{Called when a non-interactive option has been selected}

	if (a_option == _showWidgetsOID_B)
		showWidgets = !showWidgets
		SetToggleOptionValue(a_option, showWidgets)
		PSXQuest.ShowWidgets = showWidgets

	elseIf (a_option == _debugOID_B)
		modDebug = !modDebug
		SetToggleOptionValue(a_option, modDebug)
		PSXQuest.DebugToFile = modDebug

	endIf

endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when a slider option has been selected}

endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when a new slider value has been accepted}

endEvent

event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped}
	
	if (!passesKeyConflictControl(a_keyCode, a_conflictControl, a_conflictName))
		return
	endIf
	
	if (a_option == _hotkeyLeftOID_K)
		hotkeyLeft = a_keyCode
		SetKeyMapOptionValue(a_option, hotkeyLeft)
		PSXQuest.KeycodePoisonLeft = hotkeyLeft

	elseIf (a_option == _hotkeyRghtOID_K)
		hotkeyRght = a_keyCode
		SetKeyMapOptionValue(a_option, hotkeyRght)
		PSXQuest.KeycodePoisonRght = hotkeyRght

	endIf

endEvent

; @implements SKI_ConfigBase
event OnOptionDefault(int a_option)
	{Called when resetting an option to its default value}

	if (a_option == _showWidgetsOID_B)
		showWidgets = showWidgetsDefault
		SetToggleOptionValue(a_option, showWidgets)
		PSXQuest.ShowWidgets = showWidgets

	elseIf (a_option == _debugOID_B)
		modDebug = modDebugDefault
		SetToggleOptionValue(a_option, modDebug)
		PSXQuest.DebugToFile = modDebug

	elseIf (a_option == _hotkeyLeftOID_K)
		hotkeyLeft = hotkeyLeftDefault
		SetKeyMapOptionValue(a_option, hotkeyLeft)
		PSXQuest.KeycodePoisonLeft = hotkeyLeft

	elseIf (a_option == _hotkeyRghtOID_K)
		hotkeyRght = hotkeyRghtDefault
		SetKeyMapOptionValue(a_option, hotkeyRght)
		PSXQuest.KeycodePoisonRght = hotkeyRght

	elseIf (a_option == _poisonPromptOID_M)
		poisonPrompt = poisonPromptDefault
		SetMenuOptionValue(_poisonPromptOID_M, poisonPromptOptions[poisonPrompt])
		PSXQuest.ConfirmPoison = poisonPrompt

	endIf

endEvent


; shamelessly robbed from sevencardz.. :p
bool Function passesKeyConflictControl(int keyCode, String conflictControl, String conflictName)
	if conflictControl != "" && keyCode > 0
		String msg = "$PSXKeyConflict{" + conflictControl + "}"
		if conflictName != ""
			msg += "{" + conflictName + "}"
		endIf
		return ShowMessage(msg, true, "$Yes", "$No")
	else
		return true
	endIf
endFunction
