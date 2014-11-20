class WFRoboticHandArmorSparks extends UT_WallHit;

simulated function SpawnSound()
{
	PlaySound(EffectSound1,, 1.5,,1000, 0.75+(FRand()*0.5));
}

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;
	//Log(self.name$": Spawning effects...");

	NumSparks = rand(MaxSparks) + 1;

	SpawnSound();

	A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	A.RemoteRole = ROLE_None;
	if ( Region.Zone.bWaterZone || Level.bDropDetail )
	{
		Destroy();
		return;
	}
	Spawn(class'UT_Sparks');
	if ( NumSparks > 0 )
		for (j=0; j<NumSparks; j++)
			spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
	bHidden = true;
	SetTimer(1.0, false);
}

simulated function Timer()
{
	Destroy();
}

simulated function AnimEnd()
{
}

simulated function Destroyed()
{
	//Log(self.name$": destroyed");
	super.Destroyed();
}

defaultproperties
{
     MaxSparks=4
     EffectSound1=sound'ArmorUT'
     bNetOptional=False
}
