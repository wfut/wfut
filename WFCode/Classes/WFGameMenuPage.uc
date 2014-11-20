class WFGameMenuPage extends UWindowDialogClientWindow;

function BeforePaint(canvas C, float X, float Y)
{
	super.BeforePaint(C, X, Y);

	SetDesiredSize(C);
}

function SetDesiredSize(canvas C)
{
	local int W, H;
	local float XMod, YMod;

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = 4*H;
	YMod = 3*H;

	DesiredWidth = default.DesiredWidth/1024.0 * XMod;
	DesiredHeight = default.DesiredHeight/768.0 * YMod;
}

function Paint(canvas C, float X, float Y)
{
	super(UWindowClientWindow).Paint(C, X, Y);
	DrawStretchedTextureSegment(C, 0, 0, WinWidth, WinHeight, 72, 24, 1, 1, Texture'WFInfoPanelMap');
}

defaultproperties
{
	DesiredWidth=540
	DesiredHeight=301
}
