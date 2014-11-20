class WFInfoPageLookAndFeel extends UMenuBlueLookAndFeel;

function Texture GetTexture(UWindowFramedWindow W)
{
	return Active;
}

function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	W.DrawStretchedTexture(C, 0, 0, W.WinWidth, W.WinHeight, Texture'MenuBlack');
	W.DrawMiscBevel(C, 0, 0, W.WinWidth, W.WinHeight, Misc, EditBoxBevel);
}

function Button_DrawSmallButton(UWindowSmallButton B, Canvas C)
{
	local float Y;

	if(B.bDisabled)
		Y = 34;
	else
	if(B.bMouseDown)
		Y = 17;
	else
		Y = 0;

	B.DrawStretchedTextureSegment(C, 0, 0, 3, 16, 0, Y, 3, 16, Texture'WFButtonTex');
	B.DrawStretchedTextureSegment(C, B.WinWidth - 3, 0, 3, 16, 45, Y, 3, 16, Texture'WFButtonTex');
	B.DrawStretchedTextureSegment(C, 3, 0, B.WinWidth-6, 16, 3, Y, 42, 16, Texture'WFButtonTex');
}

defaultproperties
{
	Misc=Texture'WFInfoMisc'
	Active=Texture'WFInfoActiveFrame'
}