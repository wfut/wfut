class WFRDUForceEffect3 extends UT_ComboRing;

simulated function SpawnEffects()
{
	local actor a;

	if ( Level.bHighDetailMode && !Level.bDropDetail )
	{
		a = Spawn(class'ut_RingExplosion4',self);
		a.DrawScale = 2.0;
		a.RemoteRole = ROLE_None;
	}

	//Spawn(class'BigEnergyImpact',,,,rot(16384,0,0));

	a = Spawn(class'shockexplo');
	a.RemoteRole = ROLE_None;

	a =	Spawn(class'WFRDUForceWave');
	a.RemoteRole = ROLE_None;
}

defaultproperties
{
	DrawScale=2.0
}