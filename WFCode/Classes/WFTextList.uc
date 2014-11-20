class WFTextList extends UWindowListBoxItem;

var string Text;
var int Value;
var color TextColor;

function int Compare(UWindowList T, UWindowList B)
{
	if(Caps(WFTextList(T).Text) < Caps(WFTextList(B).Text))
		return -1;

	return 1;
}

defaultproperties
{
	TextColor=(R=255,B=255,G=255)
}