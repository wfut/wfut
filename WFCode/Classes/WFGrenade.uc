class WFGrenade extends ut_grenade;

var float Range;

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	Super(Projectile).PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim('glgrenade');
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
		RandSpin(50000);
		bCanHitOwner = False;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = True;
			Disable('Tick');
			Velocity=0.6*Velocity;
		}
	}
}

function BlowUp(vector HitLocation)
{
	HurtRadius(damage, Range, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}

simulated function Explosion(vector HitLocation)
{
	local effects e;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
  		e = spawn(class'UT_SpriteBallExplosion',,,HitLocation);
		e.RemoteRole = ROLE_None;
  		e = spawn(class'WFGrenadeWave',,,HitLocation);
		e.RemoteRole = ROLE_None;
	}
 	Destroy();
}

defaultproperties
{
     Damage=100
     Range=300
     MomentumTransfer=75000
     AnimSequence=glgrenade
     Mesh=LodMesh'WFMedia.glgrenade'
     DrawScale=2.3
     MyDamageType=WFGrenade
}
