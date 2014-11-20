class WFRDUForceEffect4 extends UT_ComboRing;

simulated function SpawnEffects()
{
	local actor a;

	if ( Level.bHighDetailMode && !Level.bDropDetail )
	{
		a = Spawn(class'ut_RingExplosion4',self);
		a.RemoteRole = ROLE_None;
	}

	//Spawn(class'BigEnergyImpact',,,,rot(16384,0,0));

	a = Spawn(class'shockexplo');
	a.RemoteRole = ROLE_None;

	a =	Spawn(class'WFRDUForceWave2');
	a.RemoteRole = ROLE_None;
}

defaultproperties
{
}