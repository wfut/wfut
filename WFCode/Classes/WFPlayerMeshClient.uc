class WFPlayerMeshClient extends UMenuPlayerMeshClient;

var vector DrawOffset;

function Created()
{
	super.Created();
	FaceButton.HideWindow();
	CenterButton.HideWindow();
	LeftButton.HideWindow();
	RightButton.HideWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local float OldFov;

	C.Style = GetPlayerOwner().ERenderStyle.STY_Modulated;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;

	if (MeshActor != None)
	{
		OldFov = GetPlayerOwner().FOVAngle;
		GetPlayerOwner().SetFOVAngle(30);
		DrawClippedActor( C, WinWidth/2, WinHeight/2, MeshActor, False, ViewRotator, DrawOffset );
		GetPlayerOwner().SetFOVAngle(OldFov);
	}
}