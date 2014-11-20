//=============================================================================
// WFS_PCSGrenadeProj.
//
// A grenade type projectile. This is basically a modified ut_grenade with
// some configurable options.
//=============================================================================
class WFS_PCSGrenadeProj extends Projectile;

// grenade variables
var() float DetonationTime; // the time before the grenade explodes
var() float BounceDampening; // the dampening coefficient used when bouncing of walls
var() float DamageRadius; // the range that the explosion is effective

var() float ShakeTime, RollMag, VertMag;

// grenade flags
var() bool bRandomSpin; // should the grenade have a random spin
var() bool bCanHitPlayers; // grenade explodes if it hits a player

var() bool bShakeView; // if true shakes the view of clients within range
var() bool bThrowPlayer; // if true throws the player about (like an earthquake)

// internal variables
var bool bCanHitOwner, bHitWater;

var float ArmedTime;
var bool bExploded;

replication
{
	reliable if (bNetInitial && (Role == ROLE_Authority))
		ArmedTime;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		if (bRandomSpin)
			RandSpin(50000);
		bCanHitOwner = False;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
	}
}

simulated function BeginPlay()
{
	BounceDampening = FClamp(BounceDampening, 0.0, 0.95);
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	local waterring w;

	if (!NewZone.bWaterZone || bHitWater) Return;

	bHitWater = True;
	w = Spawn(class'WaterRing',,,,rot(16384,0,0));
	w.DrawScale = 0.2;
	w.RemoteRole = ROLE_None;
	Velocity=0.6*Velocity;
}

simulated function Tick(float DeltaTime)
{
	CheckExplosion(DeltaTime);
}

// returns true if grenade has exploded
simulated function bool CheckExplosion(float DeltaTime)
{
	if (!bExploded && (DetonationTime > 0.0))
	{
		ArmedTime += DeltaTime;

		if (ArmedTime >= DetonationTime)
		{
			bExploded = True;
			Explosion(Location+Vect(0,0,1)*16);
		}
	}

	return bExploded;
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( bCanHitPlayers && ((Pawn(Other)!=Instigator) || bCanHitOwner) )
		Explosion(HitLocation);
}

simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = True;
	Velocity = BounceDampening*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	if (bRandomSpin)
		RandSpin(100000);
	speed = VSize(Velocity);
	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5 );
	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	else if ( speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
		GrenadeLanded();
	}
}

// called when the grenade has stopped bouncing
simulated function GrenadeLanded();

function BlowUp(vector HitLocation)
{
	HurtRadius(damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	if (bShakeView)
		ShakeClients();
	MakeNoise(1.0);
}

function ShakeClients()
{
	local pawn p;

	foreach visiblecollidingactors(class'pawn', p, DamageRadius, Location, true)
		if ((P != None) && P.bIsPlayer && !P.IsInState('Dying')
			&& ((P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)
			|| (P == Instigator)) ) // for testing
			P.ShakeView(ShakeTime, RollMag, VertMag);
}

simulated function Explosion(vector HitLocation)
{
	local UT_SpriteBallExplosion s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	S = spawn(class'ut_spriteballexplosion',,,hitlocation);
	s.RemoteRole = ROLE_None;

	GotoState('Exploded');
}

// give the clients a chance to simulate the explosion
state Exploded
{
	simulated function BeginState()
	{
		bHidden=True;
		Disable('Tick');
		Disable('Touch');
	}

	simulated function Tick(float DeltaTime)
	{
	}

	simulated function Touch(actor Other)
	{
	}

Begin:
	Sleep(0.5);
	Destroy();
}

defaultproperties
{
     speed=600.000000
     MaxSpeed=1000.000000
     Damage=80.000000
     DamageRadius=200.000000
     DetonationTime=5.000000
     MomentumTransfer=50000
     MyDamageType=GrenadeDeath
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     ExplosionDecal=Class'Botpack.BlastMark'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=64
     bBounce=True
     BounceDampening=0.750000
     bFixedRotationDir=True
     LifeSpan=0.000000
     bCanHitPlayers=True
}
