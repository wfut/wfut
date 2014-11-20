//=============================================================================
// WFFlameGenerator.
//=============================================================================
class WFFlameGenerator extends Effects;

var WFSmokeEffect SmokeEffect1;
var WFFireEffect FireEffect;
var bool bEffectsCreated;

simulated function Tick(float DeltaTime)
{
	if (Level.NetMode == NM_DedicatedServer)
	{
		Disable('Tick');
		return;
	}

	if (!bEffectsCreated && (Owner != None))
	{
		CreateEffects();
		Disable('Tick');
	}
}

// create the client-side smoke and fire effects
simulated function CreateEffects()
{
	if (!bEffectsCreated)
	{
		if (SmokeEffect1 == None)
			SmokeEffect1 = spawn(class'WFSmokeEffect', Owner,, Owner.Location, Owner.Rotation);

		if (FireEffect == None)
		{
			FireEffect = spawn(class'WFFireEffect', Owner,, Owner.Location, Owner.Rotation);
			FireEffect.Mesh = Owner.Mesh;
		}
		bEffectsCreated = true;
	}
}

simulated function Destroyed()
{
	if (SmokeEffect1 != None)
		SmokeEffect1.Destroy();
	if (FireEffect != None)
		FireEffect.Destroy();
	super.Destroyed();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	Physics=PHYS_Trailer
	AmbientSound=sound'firesound'
	SoundVolume=255
	bNetTemporary=False
}