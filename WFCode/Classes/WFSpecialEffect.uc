class WFSpecialEffect extends Effects;

var() float EffectRate;

var float EffectTime; // internal
var bool bInitialised;

replication
{
	reliable if (Role == ROLE_Authority)
		EffectRate;
}

simulated function Tick(float DeltaTime)
{
	EffectTime += DeltaTime*EffectRate;

	// er, rewrite this..
	if (!bInitialised)
	{
		bInitialised = InitialiseEffect();
		if (!bInitialised)
			return;
	}

	UpdateEffect(DeltaTime);
}

simulated function UpdateEffect(float DeltaTime)
{
}

simulated function bool InitialiseEffect()
{
	return true; // override to handle effect initialising
}

defaultproperties
{
     EffectRate=1.000000
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
}
