//=============================================================================
// WFMotionBlurEffect.
//=============================================================================
class WFMotionBlurEffect extends Effects;

var() float FadeScale;	// the larger the value, the shorter the effect lasts
var() float FinalScaleGlow;

function PostBeginPlay()
{
	Enable('Tick');
}

simulated function InitFor(actor Other)
{
	local int i;
	local rotator fxRotation;

	PrePivot = Other.PrePivot;
	if (Other.bIsPawn)
	{
		for ( i=0; i<4; i++ )
			Multiskins[i] = Pawn(Other).MultiSkins[i];
	}

	bMeshCurvy = Other.bMeshCurvy;
	bMeshEnviroMap = Other.bMeshEnviroMap;
	Mesh = Other.Mesh;
	Skin = Other.Skin;
	Texture = Other.Texture;
	Fatness = Other.Fatness;
	DrawScale = Other.DrawScale;

	DesiredRotation = other.Rotation;
	AnimSequence = Other.AnimSequence;
	AnimFrame = Other.AnimFrame;
	SimAnim.X = 10000 * AnimFrame;

	ScaleGlow = 1.0;

	Enable('Tick');
}

simulated event Tick( float DeltaTime )
{
	ScaleGlow -= DeltaTime * FadeScale;
	if ( ScaleGlow < FinalScaleGlow )
		Destroy();
}

defaultproperties
{
	Style=STY_Translucent
	DrawType=DT_Mesh
	RemoteRole=ROLE_None
	bOwnerNoSee=True
	FadeScale=1.500000
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	//bNetOptional=True
	FinalScaleGlow=0.000000
}