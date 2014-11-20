class WFHyperWallHit extends Effects;

var() int MaxSparks;
var bool bEffectsCreated;

simulated function Tick(float DeltaTime)
{
	if (!bEffectsCreated)
	{
		CreateEffects();
		bEffectsCreated = true;
	}

	ScaleGlow = 1.5 * (LifeSpan/default.LifeSpan);
}

simulated function CreateEffects()
{
	local int NumSparks;

	NumSparks = 1;
	if (!Level.bDropDetail)
		NumSparks += Rand(MaxSparks);

	while (NumSparks > 0)
	{
		spawn(class'WFHyperSpark',,, Location, Rotation);
		NumSparks--;
	}

	Spawn(class'EnergyImpact');
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=True
	DrawType=DT_None
	Mesh=LodMesh'Botpack.ShockWavem'
	LifeSpan=0.500000
	Style=STY_Translucent
	DrawScale=0.5
	bUnlit=True
	MaxSparks=4
}