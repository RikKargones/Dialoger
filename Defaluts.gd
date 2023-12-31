extends Node

enum PICKER_TYPES 	{PERSON, MOOD, FONT, ALIGN}
enum DIALOG_BLOCKS	{NONE, REPLICK, TEXTURE, OPTIONS, VARIBLE}

var LocalesNames = {
	"ar" : "Arabic",
	"ar_AE" : "Arabic (United Arab Emirates)",
	"ar_BH" : "Arabic (Bahrain)",
	"ar_DZ" : "Arabic (Algeria)",
	"ar_EG" : "Arabic (Egypt)",
	"ar_IQ" : "Arabic (Iraq)",
	"ar_JO" : "Arabic (Jordan)",
	"ar_KW" : "Arabic (Kuwait)",
	"ar_LB" : "Arabic (Lebanon)",
	"ar_LY" : "Arabic (Libya)",
	"ar_MA" : "Arabic (Morocco)",
	"ar_OM" : "Arabic (Oman)",
	"ar_QA" : "Arabic (Qatar)",
	"ar_SA" : "Arabic (Saudi Arabia)",
	"ar_SD" : "Arabic (Sudan)",
	"ar_SY" : "Arabic (Syria)",
	"ar_TN" : "Arabic (Tunisia)",
	"ar_YE" : "Arabic (Yemen)",
	"be" : "Belarusian",
	"be_BY" : "Belarusian (Belarus)",
	"bg" : "Bulgarian",
	"bg_BG" : "Bulgarian (Bulgaria)",
	"ca" : "Catalan",
	"ca_ES" : "Catalan (Spain)",
	"cs" : "Czech",
	"cs_CZ" : "Czech (Czech Republic)",
	"da" : "Danish",
	"da_DK" : "Danish (Denmark)",
	"de" : "German",
	"de_AT" : "German (Austria)",
	"de_CH" : "German (Switzerland)",
	"de_DE" : "German (Germany)",
	"de_LU" : "German (Luxembourg)",
	"el" : "Greek",
	"el_CY" : "Greek (Cyprus)",
	"el_GR" : "Greek (Greece)",
	"en" : "English",
	"en_AU" : "English (Australia)",
	"en_CA" : "English (Canada)",
	"en_GB" : "English (United Kingdom)",
	"en_IE" : "English (Ireland)",
	"en_IN" : "English (India)",
	"en_MT" : "English (Malta)",
	"en_NZ" : "English (New Zealand)",
	"en_PH" : "English (Philippines)",
	"en_SG" : "English (Singapore)",
	"en_US" : "English (United States)",
	"en_ZA" : "English (South Africa)",
	"es" : "Spanish",
	"es_AR" : "Spanish (Argentina)",
	"es_BO" : "Spanish (Bolivia)",
	"es_CL" : "Spanish (Chile)",
	"es_CO" : "Spanish (Colombia)",
	"es_CR" : "Spanish (Costa Rica)",
	"es_DO" : "Spanish (Dominican Republic)",
	"es_EC" : "Spanish (Ecuador)",
	"es_ES" : "Spanish (Spain)",
	"es_GT" : "Spanish (Guatemala)",
	"es_HN" : "Spanish (Honduras)",
	"es_MX" : "Spanish (Mexico)",
	"es_NI" : "Spanish (Nicaragua)",
	"es_PA" : "Spanish (Panama)",
	"es_PE" : "Spanish (Peru)",
	"es_PR" : "Spanish (Puerto Rico)",
	"es_PY" : "Spanish (Paraguay)",
	"es_SV" : "Spanish (El Salvador)",
	"es_US" : "Spanish (United States)",
	"es_UY" : "Spanish (Uruguay)",
	"es_VE" : "Spanish (Venezuela)",
	"et" : "Estonian",
	"et_EE" : "Estonian (Estonia)",
	"fi" : "Finnish",
	"fi_FI" : "Finnish (Finland)",
	"fr" : "French",
	"fr_BE" : "French (Belgium)",
	"fr_CA" : "French (Canada)",
	"fr_CH" : "French (Switzerland)",
	"fr_FR" : "French (France)",
	"fr_LU" : "French (Luxembourg)",
	"ga" : "Irish",
	"ga_IE" : "Irish (Ireland)",
	"hi" : "Hindi (India)",
	"hi_IN" : "Hindi (India)",
	"hr" : "Croatian",
	"hr_HR" : "Croatian (Croatia)",
	"hu" : "Hungarian",
	"hu_HU" : "Hungarian (Hungary)",
	"in" : "Indonesian",
	"in_ID" : "Indonesian (Indonesia)",
	"is" : "Icelandic",
	"is_IS" : "Icelandic (Iceland)",
	"it" : "Italian",
	"it_CH" : "Italian (Switzerland)",
	"it_IT" : "Italian (Italy)",
	"iw" : "Hebrew",
	"iw_IL" : "Hebrew (Israel)",
	"ja" : "Japanese",
	"ja_JP" : "Japanese (Japan)",
	"ja_JP_JP" : "Japanese (Japan,JP)",
	"ko" : "Korean",
	"ko_KR" : "Korean (South Korea)",
	"lt" : "Lithuanian",
	"lt_LT" : "Lithuanian (Lithuania)",
	"lv" : "Latvian",
	"lv_LV" : "Latvian (Latvia)",
	"mk" : "Macedonian",
	"mk_MK" : "Macedonian (Macedonia)",
	"ms" : "Malay",
	"ms_MY" : "Malay (Malaysia)",
	"mt" : "Maltese",
	"mt_MT" : "Maltese (Malta)",
	"nl" : "Dutch",
	"nl_BE" : "Dutch (Belgium)",
	"nl_NL" : "Dutch (Netherlands)",
	"no" : "Norwegian",
	"no_NO" : "Norwegian (Norway)",
	"no_NO_NY" : "Norwegian (Norway,Nynorsk)",
	"pl" : "Polish",
	"pl_PL" : "Polish (Poland)",
	"pt" : "Portuguese",
	"pt_BR" : "Portuguese (Brazil)",
	"pt_PT" : "Portuguese (Portugal)",
	"ro" : "Romanian",
	"ro_RO" : "Romanian (Romania)",
	"ru" : "Russian",
	"ru_RU" : "Russian (Russia)",
	"sk" : "Slovak",
	"sk_SK" : "Slovak (Slovakia)",
	"sl" : "Slovenian",
	"sl_SI" : "Slovenian (Slovenia)",
	"sq" : "Albanian",
	"sq_AL" : "Albanian (Albania)",
	"sr" : "Serbian",
	"sr_BA" : "Serbian (Bosnia and Herzegovina)",
	"sr_CS" : "Serbian (Serbia and Montenegro)",
	"sr_ME" : "Serbian (Montenegro)",
	"sr_RS" : "Serbian (Serbia)",
	"sv" : "Swedish",
	"sv_SE" : "Swedish (Sweden)",
	"th" : "Thai",
	"th_TH" : "Thai (Thailand)",
	"th_TH_TH" : "Thai (Thailand,TH)",
	"tr" : "Turkish",
	"tr_TR" : "Turkish (Turkey)",
	"uk" : "Ukrainian",
	"uk_UA" : "Ukrainian (Ukraine)",
	"vi" : "Vietnamese",
	"vi_VN" : "Vietnamese (Vietnam)",
	"zh" : "Chinese",
	"zh_CN" : "Chinese (China)",
	"zh_HK" : "Chinese (Hong Kong)",
	"zh_SG" : "Chinese (Singapore)",
	"zh_TW" : "Chinese (Taiwan)",
}

const version 					= "0.9.0"
const defalut_project_folder 	= "user://Projects"

var max_lines 				= 4
var default_font_size 		= 16
var max_symbols_per_line	= 100
var main_lang 				= "English"

var preview_miror_left 		= true
var preview_miror_right 	= true
var preview_miror_center	= false


func reset_defaluts():
	max_lines 				= 4
	default_font_size 		= 16
	max_symbols_per_line 	= 100
	
	main_lang 				= "English"
	
	preview_miror_center 	= true
	preview_miror_left 		= true
	preview_miror_right		= false

func get_main_lang_name():
	return main_lang
	
func set_main_lang_name(lang_name):
	if lang_name in ProjectManager.font_lang_atlas.keys():
		main_lang = lang_name

func is_text_can_be_replic(text : String):
	var lines_req = text.countn("\n") < max_lines || max_lines == 0
	
	var one_line_lengh_req = true
	
	if max_symbols_per_line != 0:
		for line in text.split("\n"):
			if line.length() > max_symbols_per_line:
				one_line_lengh_req = false
				break
	
	return lines_req && one_line_lengh_req
