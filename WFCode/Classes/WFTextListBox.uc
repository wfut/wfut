class WFTextListBox extends UWindowListBox;

var UWindowDialogControl	NotifyOwner;
var font TextFont;
var float ItemTextPadding, PadRatio;

function BeforePaint(canvas C, float X, float Y)
{
	local float XL, YL;

	if (TextFont != None)
	{
		C.Font = TextFont;
		C.TextSize("Testing", XL, YL);
		ItemTextPadding = PadRatio*YL;
		ItemHeight = YL + ItemTextPadding;
		ItemHeight /= Root.GUIScale;
	}

	super.BeforePaint(C, X, Y);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float XL, YL;

	if(WFTextList(Item).bSelected)
	{
		C.DrawColor.r = 32;
		C.DrawColor.g = 32;
		C.DrawColor.b = 32;
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		//DrawStretchedTexture(C, X, Y, W, (H/Root.GUIScale)-1, Texture'WhiteTexture');
		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
	else
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 0;
	}

	if (TextFont != None) C.Font = TextFont;
	else C.Font = Root.Fonts[F_Normal];

	C.DrawColor = WFTextList(Item).TextColor;
	C.TextSize(WFTextList(Item).Text, XL, YL);
	//ClipText(C, X+2, Y, WFTextList(Item).Text);
	ClipText(C, X+2, Y + (ItemTextPadding/(Root.GUIScale*2.0)), WFTextList(Item).Text);
	//ClipText(C, X+2, Y + (H/2.0) - (YL/2.0), WFTextList(Item).Text);
	C.DrawColor.r = 255;
	C.DrawColor.g = 255;
	C.DrawColor.b = 255;
}

function Notify(byte E)
{
	if(NotifyOwner != None)
	{
		NotifyOwner.Notify(E);
	} else {
		Super.Notify(E);
	}
}

function SetTextFont(font NewFont)
{
	TextFont = NewFont;
}

defaultproperties
{
	ItemHeight=15
	ListClass=class'WFTextList'
	PadRatio=0.125
}