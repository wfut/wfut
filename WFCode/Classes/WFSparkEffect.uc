class WFSparkEffect extends Effects;

var() int NumSparks;
var() int RandomExtraSparks;

var() class<actor> SparkClass;

var rotator RealRotation;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		RealRotation;
}

simulated function SpawnSound()
{
	PlaySound(EffectSound1,, 1.5,,1000, 0.75+(FRand()*0.5));
}

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int Sparks;
	//Log(self.name$": Spawning effects...");

	Sparks = NumSparks + rand(RandomExtraSparks);

	SpawnSound();

	//A = Spawn(class'UT_SpriteSmokePuff',,,Location + 8 * Vector(Rotation));
	//A.RemoteRole = ROLE_None;
	if ( Region.Zone.bWaterZone /*|| Level.bDropDetail*/ )
	{
		Destroy();
		return;
	}
	if ( Sparks > 0 )
		for (j=0; j<Sparks; j++)
			spawn(SparkClass,,,Location + 8 * Vector(Rotation));
	bHidden = true;
	Disable('Tick');
}

simulated function Timer()
{
	Destroy();
}

simulated function AnimEnd()
{
}

Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		if ( Instigator != None )
			MakeNoise(0.3);
		if ( Role == ROLE_Authority )
			RealRotation = Rotation;
		else
			SetRotation(RealRotation);

		if ( Level.NetMode != NM_DedicatedServer )
			SpawnEffects();
	}
}

simulated function Destroyed()
{
	//Log(self.name$": destroyed");
	super.Destroyed();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     bNetOptional=False
     bNetTemporary=False
     LifeSpan=2.5
}
