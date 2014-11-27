class WFCloakBlurEffect extends WFMotionBlurEffect;

simulated function InitFor(actor Other)
{
	Mesh = Other.Mesh;
	Fatness = Other.Fatness;
	DrawScale = Other.DrawScale;
	PrePivot = Other.PrePivot;
	DesiredRotation = other.Rotation;
	AnimSequence = Other.AnimSequence;
	AnimFrame = Other.AnimFrame;
	SimAnim.X = 10000 * AnimFrame;
	ScaleGlow = 0.5;
}

defaultproperties
{
	RemoteRole=ROLE_None
	FadeScale=0.75
	DrawType=DT_Mesh
	bOwnerNoSee=True
	Style=STY_Translucent
	Skin=Texture'JDomN0'
	Texture=Texture'JDomN0'
	bMeshEnviroMap=True
	bUnlit=True
}