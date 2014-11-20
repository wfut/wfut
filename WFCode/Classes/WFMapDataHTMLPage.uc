class WFMapDataHTMLPage extends WFS_DynamicHTMLPage;

static function string GetHTML
(
	optional string Options, 		// an optional string of options/information
	optional int SwitchNum, 		// an optional switch number
	optional Object OptionalObject	// an optional object reference
)
{
	local class<WFMapData> MapData;
	local string HTML;

	MapData = class<WFMapData>(OptionalObject);

	HTML = (
		"<BODY BGCOLOR=\"#000000\" LINK=\"#FF0000\" ALINK=\"#FF00FF\">"
	$		"<p><b>Name: </b><font color=#C0C0C0>"$ProcessText(MapData.default.MapDataText)$"</font></p>"
	$		"<p><b>General Info:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>"$ProcessText(MapData.default.MapDataInfoText)
	$		"</font></p>"
	$		"<p><b>Supported Maps:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>"$ProcessText(MapData.default.SupportedMapsText)
	$		"</font></p>"
	);

	return HTML;
}

static function string ProcessText(string S)
{
	ReplaceText(S, "&", "&amp;");
	ReplaceText(S, ">", "&gt;");
	ReplaceText(S, "<", "&lt;");

	return S;
}