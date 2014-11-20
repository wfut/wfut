class WFFramedTextListBox extends UWindowDialogControl;

var WFTextListBox ListBox;
var WFLabelControl TextLabel;
var float LabelX, LabelWidth;

// region maps for listbox texture
var region ListBoxTextureTop, ListBoxTextureMid, ListBoxTextureBottom;

function Created()
{
	ListBox = WFTextListBox(CreateWindow(class'WFTextListBox', 16, 24, 120, 80, self));
	ListBox.NotifyOwner = self;

	TextLabel = WFLabelControl(CreateWindow(class'WFLabelControl', 8, 8, 50, 1));
	TextLabel.TextColor = class'ChallengeHUD'.default.WhiteColor;
}

function DrawListBoxTexture(canvas C, float X, float Y, float W, float H, float XScale, float YScale)
{
	DrawStretchedTextureSegment(C, X, Y, W, 32.0*YScale, ListBoxTextureTop.X, ListBoxTextureTop.Y, ListBoxTextureTop.W, ListBoxTextureTop.H, Texture'WFListBoxMap');
	DrawStretchedTextureSegment(C, X, Y+(32.0*YScale), W, H-(48.0*YScale), ListBoxTextureMid.X, ListBoxTextureMid.Y, ListBoxTextureMid.W, ListBoxTextureMid.H, Texture'WFListBoxMap');
	DrawStretchedTextureSegment(C, X, Y+H-(16.0*YScale), W, 16.0*YScale, ListBoxTextureBottom.X, ListBoxTextureBottom.Y, ListBoxTextureBottom.W, ListBoxTextureBottom.H, Texture'WFListBoxMap');
}

function SetText(string NewText)
{
	TextLabel.SetText(NewText);
}

function SetTextColor(color NewColor)
{
	TextLabel.TextColor = class'ChallengeHUD'.default.WhiteColor;
}

function Paint(Canvas C, float X, float Y)
{
	local int W, H;
	local float XMod, YMod, XL, YL, XPos, YPos;;
	local font ComponentFont;

	Super.Paint(C, X, Y);

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = W*4/1024.0;
	YMod = H*3/768.0;

	ComponentFont = class'UTLadderStub'.Static.GetStubClass().Static.GetSmallFont(Root);

	if (ListBox != None)
	{
		DrawListBoxTexture(C, 0, 0, WinWidth, WinHeight, XMod, YMod);
		ListBox.WinLeft = 12.0*XMod;
		ListBox.WinTop = 32.0*YMod;
		ListBox.SetTextFont(ComponentFont);
		XL = WinWidth - (24.0 * XMod);
		YL = WinHeight - (48.0 * YMod);
		if ((ListBox.WinWidth != XL) || (ListBox.WinHeight != YL))
			ListBox.SetSize(XL, YL);

		TextLabel.SetTextFont(ComponentFont);
		TextLabel.WinLeft = LabelX * XMod;
		//TeamLabel.WinTop = (TeamListRegion.Y + LabelY) * YMod;
		TextLabel.WinTop = (16.0 * YMod) - FMin(16.0*YMod, TextLabel.WinHeight/2.0);
		TextLabel.WinWidth = LabelWidth*XMod;
	}
}

defaultproperties
{
	LabelX=12
	LabelWidth=192
	ListBoxTextureTop=(X=0,Y=0,W=224,H=32)
	ListBoxTextureMid=(X=0,Y=32,W=224,H=2)
	ListBoxTextureBottom=(X=0,Y=34,W=224,H=16)
}