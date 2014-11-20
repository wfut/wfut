class WFFlagTexturePreviewClient extends UWindowDialogClientWindow;

var UWindowButton CenterButton;
var UWindowButton LeftButton, RightButton;

var WFFlagMeshActor MeshActor;
var mesh FlagMesh;

var rotator CenterRotator, ViewRotator;
var vector DrawOffset;
var bool bRotate, bTween;

function Created()
{
	Super.Created();

	MeshActor = GetEntryLevel().Spawn(class'WFFlagMeshActor', GetEntryLevel());
	MeshActor.Mesh = FlagMesh;
	MeshActor.WFNotifyClient = Self;

	//if(MeshActor.Mesh != None)
	//	MeshActor.PlayAnim('Breath3', 0.4);

	CenterButton = UWindowButton(CreateControl(class'UWindowButton', WinWidth/3, 0, WinWidth/3, WinHeight));
	CenterButton.bIgnoreLDoubleclick = True;
	ViewRotator = default.ViewRotator + CenterRotator;

	LeftButton = UWindowButton(CreateControl(class'UWindowButton', 0, 0, WinWidth/3, WinHeight));
	LeftButton.bIgnoreLDoubleclick = True;

	RightButton = UWindowButton(CreateControl(class'UWindowButton', (WinWidth/3)*2, 0, WinWidth/3, WinHeight));
	RightButton.bIgnoreLDoubleclick = True;
}

function Resized()
{
	Super.Resized();

	CenterButton.SetSize(WinWidth/3, WinHeight);
	CenterButton.WinLeft = WinWidth/3;

	LeftButton.SetSize(WinWidth/3, WinHeight);
	LeftButton.WinLeft = 0;

	RightButton.SetSize(WinWidth/3, WinHeight);
	RightButton.WinLeft = (WinWidth/3)*2;
}

function BeforePaint(Canvas C, float X, float Y)
{
	if (LeftButton.bMouseDown) {
		ViewRotator.Yaw += 512;
	} else if (RightButton.bMouseDown) {
		ViewRotator.Yaw -= 512;
	}
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

function Tick(float Delta)
{
	if (bRotate)
		ViewRotator.Yaw += 128;
}

function ClearSkins()
{
	local int i;

	MeshActor.Skin = None;
	for(i=0;i<4;i++)
		MeshActor.MultiSkins[i] = None;
}

function SetSkin(texture NewSkin)
{
	ClearSkins();
	MeshActor.Skin = NewSkin;
}

function SetMesh(mesh NewMesh)
{
	MeshActor.bMeshEnviroMap = False;
	MeshActor.DrawScale = MeshActor.Default.DrawScale;
	MeshActor.Mesh = NewMesh;
	if(MeshActor.Mesh != None)
		MeshActor.PlayAnim('pflag', 0.5);
}

function SetNoAnimMesh(mesh NewMesh)
{
	MeshActor.bMeshEnviroMap = False;
	MeshActor.DrawScale = MeshActor.Default.DrawScale;
	MeshActor.Mesh = NewMesh;
}

function SetMeshString(string NewMesh)
{
	SetMesh(mesh(DynamicLoadObject(NewMesh, Class'Mesh')));
}

function SetNoAnimMeshString(string NewMesh)
{
	SetNoAnimMesh(mesh(DynamicLoadObject(NewMesh, Class'Mesh')));
}

function Close(optional bool bByParent)
{
	//Log("Mesh client closed!");
	Super.Close(bByParent);
	if(MeshActor != None)
	{
		MeshActor.Destroy();
		MeshActor = None;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	switch (E)
	{
		case DE_Click:
			switch (C)
			{
				case CenterButton:
					ViewRotator = default.ViewRotator + CenterRotator;
					break;
			}
			break;
	}
}

function AnimEnd(MeshActor MyMesh)
{
	MyMesh.LoopAnim('pflag');
}

defaultproperties
{
     FlagMesh=LodMesh'Botpack.pflag'
     ViewRotator=(Yaw=49152,Roll=-6940)
     DrawOffset=(X=0,Y=0,Z=-1)
}