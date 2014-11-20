class WFMeshPulseEffect extends Effects;

var bool bPlayedSound;

simulated function Tick(float DeltaTime)
{
	if (!bPlayedSound)
	{
		PlaySound(EffectSound1);
		bPlayedSound = true;
	}

	ScaleGlow -= DeltaTime;
	Fatness = 136 + 32*FClamp(ScaleGlow/default.ScaleGlow, 0.0, 1.0);
	if (Owner != None)
		PrePivot = Owner.PrePivot;

	if (ScaleGlow <= 0.5)
		Destroy();
}

defaultproperties
{
	bAnimByOwner=True
	bOwnerNoSee=True
	bNetTemporary=True
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	ScaleGlow=2.000000
	AmbientGlow=64
	Fatness=160
	bUnlit=True
	bMeshEnviroMap=True
}
