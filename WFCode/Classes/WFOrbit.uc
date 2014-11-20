class WFOrbit extends Effects;

simulated function PostBeginPlay()
{
	LoopAnim(AnimSequence);
}

defaultproperties
{
	DrawType=DT_Mesh
	RemoteRole=ROLE_None
	bNetOptional=False
	bNetTemporary=False
	Mesh=Mesh'plasmeffect'
	bParticles=True
	Texture=Texture'Tranglow'
	DrawScale=0.5
	bFixedRotationDir=True
	bUnlit=True
	RotationRate=(Pitch=7500,Yaw=10000,Roll=7500)
	Style=STY_Translucent
	Physics=PHYS_Rotating
}