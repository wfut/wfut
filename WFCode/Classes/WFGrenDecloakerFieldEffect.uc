class WFGrenDecloakerFieldEffect extends Effects;

var bool bfadedown;
var float TargetGlow;
var float FadeScale;

simulated function Tick(float DeltaTime)
{
	if (!bfadedown)
	{
		ScaleGlow += DeltaTime*FadeScale;
		if (ScaleGlow >= TargetGlow)
			bfadedown = true;
	}
	else
	{
		ScaleGlow -= DeltaTime*FadeScale;
		if (ScaleGlow <= 0.0)
		{
			bHidden = true;
			Destroy();
		}
	}
}

defaultproperties
{
	Style=STY_Translucent
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.ShockWavem'
	bNetTemporary=True
	bNetOptional=False
	RemoteRole=ROLE_SimulatedProxy
	DrawScale=9.0
	ScaleGlow=0
	TargetGlow=1.0
	bCollideWorld=False
	bCollideActors=False
	bBlockPlayers=False
	bBlockActors=False
	bUnlit=True
	MultiSkins(1)=Texture'unrealshare.fireeffect3'
	CollisionHeight=0.0
	CollisionRadius=0.0
	Physics=PHYS_Rotating
	bFixedRotationDir=True
	RotationRate=(Pitch=7500,Yaw=10000,Roll=15000)
	FadeScale=1.0
}