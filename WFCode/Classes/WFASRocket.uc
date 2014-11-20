class WFASRocket extends Projectile;

var float SmokeRate;
var	redeemertrail trail;
var float PlayerDamageScale;
var float DamageRange;

var sound ProximitySound;
var bool bDecalSpawned;

simulated function PostBeginPlay()
{
	SmokeRate = 0.3;
	SetTimer(0.3,false);
}

// prevent multiple decals from appearing in netgames
simulated function HitWall (vector HitNormal, actor Wall)
{
	if ( Role == ROLE_Authority )
	{
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');

		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( (ExplosionDecal != None) && !bDecalSpawned && (Level.NetMode != NM_DedicatedServer) )
	{
		Spawn(ExplosionDecal,self,,Location, rotator(HitNormal));
		bDecalSpawned = true;
	}
}

auto state Flying
{
	function BeginState()
	{
		local vector InitialDir;

		initialDir = vector(Rotation);
		if ( Role == ROLE_Authority )
			Velocity = speed*initialDir;
		Acceleration = initialDir*50;
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if ( NewZone.bWaterZone != Region.Zone.bWaterZone )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None;
		}
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( Other != instigator )
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if ( Role < ROLE_Authority )
			return;

		DamageRadius(Damage, DamageRange, MyDamageType, MomentumTransfer, HitLocation );
 		spawn(class'WarExplosion',,,Location);
		RemoteRole = ROLE_SimulatedProxy;
 		Destroy();
	}
}

function DamageRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			if (!Victims.bIsPawn || !Victims.IsA('TeamCannon'))
				damageScale = (1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius)) * PlayerDamageScale;
			else
				damageScale = 1;

			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);
		}
	}
	bHurtEntry = false;
}

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

	if ( Trail == None )
		Trail = Spawn(class'RedeemerTrail',self);

	ProximityCheck(); // explode if sentry with range

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
	{
		SetTimer(SmokeRate, false);
		Return;
	}

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail )
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed;
	}
	else
	{
		SmokeRate = 0.15;
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.Destroy();
	Super.Destroyed();
}

function ProximityCheck()
{
	local teamcannon c;
	foreach RadiusActors(class'TeamCannon', c, DamageRange*0.5)
		if ((c != None) && ValidCannon(c))
		{
			PlaySound(ProximitySound, SLOT_None, 2.0);
			Explode(Location, vect(0,0,1));
		}
}

function bool ValidCannon(TeamCannon sentry)
{
	if ((Instigator == None) || (sentry.MyTeam != Instigator.PlayerReplicationInfo.Team))
		return true;
	return false;
}

defaultproperties
{
	Speed=750
	MaxSpeed=750
	Damage=250
	DamageRange=250.0
	PlayerDamageScale=0.25
	MomentumTransfer=50000
	ExplosionDecal=Class'Botpack.BlastMark'
	RemoteRole=ROLE_SimulatedProxy
	AmbientSound=Sound'Botpack.Redeemer.WarFly'
	Mesh=LodMesh'Botpack.missile'
	AmbientGlow=78
	bUnlit=True
	bNetTemporary=False
	SoundRadius=100
	SoundVolume=255
	CollisionRadius=15.000000
	CollisionHeight=8.000000
	ProximitySound=Sound'UnrealShare.Eightball.SeekLost'
}