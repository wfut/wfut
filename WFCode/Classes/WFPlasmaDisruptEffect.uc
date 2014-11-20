class WFPlasmaDisruptEffect extends Effects;

defaultproperties
{
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	AnimSequence=None
	Physics=PHYS_Rotating
	DrawType=DT_Mesh
	Style=STY_Translucent
	bFixedRotationDir=True
	RotationRate=(Pitch=45345,Yaw=33453,Roll=63466)
	DesiredRotation=(Pitch=23442,Yaw=34234,Roll=34234)
	Mesh=LodMesh'Botpack.ShockWavem'
	bUnlit=True
	AmbientGlow=255
	DrawScale=1.0
	MultiSkins(1)=Texture'fireeffect3a'
	AmbientSound=Sound'Botpack.PulseGun.PulseFly'
}