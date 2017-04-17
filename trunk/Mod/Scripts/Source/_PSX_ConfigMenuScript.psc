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
string C_STRING_FORMAT_PLACEHOLDER_ZERO = "{0}"
string C_STRING_INDEX_NAME_SEPARATOR = ": "

; Translatables
string C_MOD_NAME = "$PSXModName"
string C_PAGE_MISC = "$PSXPageMisc"
string C_FORMAT_PLACEHOLDER_SECONDS = "$PSXFormatPlaceholderSeconds"
string C_FORMAT_PLACEHOLDER_PERCENT = "$PSXFormatPlaceholderPercent"
string C_MENU_OPTION_ALWAYS = "$PSXMenuOptionAlways"
string C_MENU_OPTION_NEW_POISON = "$PSXMenuOptionNewPoison"
string C_MENU_OPTION_BENEF = "$PSXMenuOptionBeneficial"
string C_MENU_OPTION_NEVER = "$PSXMenuOptionNever"
string C_OPTION_LABEL_PROMPTS = "$PSXOptionLabelPrompts"
string C_OPTION_LABEL_DEBUG = "$PSXOptionLabelDebug"
string C_OPTION_LABEL_CURRENT_VERSION = "$PSXOptionLabelCurrentVersion"
string C_INFO_TEXT_POISONPROMPT = "$PSXInfoTextPoisonPrompt"
string C_INFO_TEXT_DEBUG = "$PSXInfoTextDebug"

; OIDs (T:Text B:Toggle S:Slider M:Menu, C:Color, K:Key)
int			_poisonPromptOID_M
int			_debugOID_B
int			_currentVersionOID_T


; State
int poisonPrompt
bool modDebug

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
	poisonPromptOptions[0] = C_MENU_OPTION_NEVER
	poisonPromptOptions[1] = C_MENU_OPTION_BENEF
	poisonPromptOptions[2] = C_MENU_OPTION_NEW_POISON
	poisonPromptOptions[3] = C_MENU_OPTION_ALWAYS
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
	
		_poisonPromptOID_M	= AddMenuOption(C_OPTION_LABEL_PROMPTS, PSXQuest.ConfirmPoison)
		
		AddEmptyOption()
		
		_debugOID_B	= AddToggleOption(C_OPTION_LABEL_DEBUG, PSXQuest.DebugToFile)
		
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
	
	elseIf (a_option == _debugOID_B)
		SetInfoText(C_INFO_TEXT_DEBUG)
	
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}
	if (a_option == _poisonPromptOID_M)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)
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

	if (a_option == _debugOID_B)
		modDebug = !modDebug
		SetToggleOptionValue(a_option, modDebug)
		PSXQuest.DebugToFile = modDebug

	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionDefault(int a_option)
	{Called when resetting an option to its default value}

	; ...
endEvent

; @implements SKI_ConfigBase
event OnOptionSliderOpen(int a_option)
	{Called when a slider option has been selected}

endEvent

; @implements SKI_ConfigBase
event OnOptionSliderAccept(int a_option, float a_value)
	{Called when a new slider value has been accepted}

endEvent


string Function FormatString(string asTemplate, string asEffectName)
	int subPos = StringUtil.Find(asTemplate, C_STRING_FORMAT_PLACEHOLDER_ZERO)
	return StringUtil.Substring(asTemplate, 0, subPos) \
			+ asEffectName \
			+ StringUtil.Substring(asTemplate, subPos + StringUtil.GetLength(C_STRING_FORMAT_PLACEHOLDER_ZERO))
endFunction
