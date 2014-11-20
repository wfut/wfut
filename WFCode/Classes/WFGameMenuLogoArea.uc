class WFGameMenuLogoArea extends NotifyWindow;

var float LogoWidth;
var float LogoHeight;

function Paint(canvas C, float X, float Y)
{
	local float XMod, YMod, XL, YL, PosX, PosY;
	local int W, H;

	class'WFGameMenu'.static.GetTiledSegmentScale(Root, W, H);

	XMod = W*4/1024.0;
	YMod = H*3/768.0;

	PosX = (WinWidth/2) - (LogoWidth*XMod/2);
	PosY = (WinHeight/2) - (LogoHeight*YMod/2);

	DrawStretchedTextureSegment(C, PosX, PosY, 256.0*XMod, LogoHeight*YMod, 0, 0, 256, 80, Texture'WFMenuLogo');
	DrawStretchedTextureSegment(C, PosX + 256.0*XMod, PosY, (LogoWidth-256)*XMod, LogoHeight*YMod*2, 0, LogoHeight, LogoWidth-256, LogoHeight*2, Texture'WFMenuLogo');
}

defaultproperties
{
	LogoWidth=320
	LogoHeight=80
}