class WFRocket extends RocketMk2;

var() float BlastRadius;

simulated function PostBeginPlay()
{
	Trail = Spawn(class'WFRocketTrail',self);
	if ( Level.bHighDetailMode )
	{
		SmokeRate = (200 + (0.5 + 2 * FRand()) * NumExtraRockets * 24)/Speed;
		if ( Level.bDropDetail )
		{
			SoundRadius = 6;
			LightRadius = 3;
		}
	}
	else
	{
		SmokeRate = 0.15 + FRand()*(0.02+NumExtraRockets);
		LightRadius = 3;
	}
	SetTimer(SmokeRate, true);
}

auto state Flying
{
	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage,BlastRadius, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}
}

defaultproperties
{
	//speed=900.000000
	//MaxSpeed=1600.000000
	speed=1125.000000
	MaxSpeed=2000.000000
	Damage=80
	Mesh=LodMesh'WF_Rocket'
	DrawScale=1
    BlastRadius=165.000000
    Damage=90.000000
}
