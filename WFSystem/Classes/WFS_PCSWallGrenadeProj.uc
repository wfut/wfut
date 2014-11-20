//=============================================================================
// PCSStickyGrenadeProj.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// A grenade that can stick to walls.
// Note: The surface normal is multiplied by 10000 so that it can be replicated
//       when bNetInitial is true while keeping precision of 4 decimal places.
//       Multiply the surface normal by 0.0001 before using it.
//=============================================================================
class WFS_PCSWallGrenadeProj extends WFS_PCSGrenadeProj;

var() bool bStickToWalls; // grenade sticks to walls and movers

// Internal variables.
var bool bOnSurface;
var vector SurfaceNormal; // the normal of the surface currently attached to

var float LastLog;

replication
{
	reliable if (bNetInitial && bStickToWalls && bOnSurface && (Role == ROLE_Authority))
		SurfaceNormal; // quantised surface normal (multply by 0.0001 before use)

	reliable if (bNetInitial && (Role == ROLE_Authority))
		bOnSurface;
}

simulated function bool CheckExplosion(float DeltaTime)
{
	if (!bExploded && (DetonationTime > 0.0))
	{
		ArmedTime += DeltaTime;

		if (ArmedTime >= DetonationTime)
		{
			bExploded = True;
			if (bOnSurface)
				Explosion(Location+(SurfaceNormal*0.0001)*16);
			else
				Explosion(Location+Vect(0,0,1)*16);
		}
	}

	return bExploded;
}

simulated function Explosion(vector HitLocation)
{
	local UT_SpriteBallExplosion s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (bOnSurface)
			spawn(class'Botpack.BlastMark',,,,rotator(SurfaceNormal*0.0001));
		else
			spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	}
	S = spawn(class'ut_spriteballexplosion',,,hitlocation);
	s.RemoteRole = ROLE_None;

	GotoState('Exploded');
}

function ServerExplosion(vector HitLocation)
{
	local UT_SpriteBallExplosion s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (bOnSurface)
			spawn(class'Botpack.BlastMark',,,,rotator(SurfaceNormal*0.0001));
		else
			spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	}
	S = spawn(class'ut_spriteballexplosion',,,hitlocation);

	Destroy();
}

// use a server-side explosion function if grenade should explode on contact with players
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( bCanHitPlayers && ((Pawn(Other)!=Instigator) || bOnSurface) )
	{
		if (!bOnSurface)
			ServerExplosion(Normal(Other.Location - Location));
		else
			Explosion(Normal(Other.Location - Location));
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	if (bStickToWalls)
	{
		StickToWall(HitNormal, Wall);
		return;
	}
	super.HitWall(HitNormal, Wall);
}

simulated function StickToWall( vector HitNormal, actor Wall )
{
	local actor HitActor;
	local rotator RandRot;

	//Log("Sticking grenade to wall: "$Wall);

	SetPhysics(PHYS_None);
	MakeNoise(0.3);
	bOnSurface = True;

	if (Role == ROLE_Authority)
		PlaySound(ImpactSound);

	SurfaceNormal = HitNormal * 10000;
	SetupInitialRotation(HitNormal);
	if ( Mover(Wall) != None )
		SetBase(Wall);

	GoToState('OnSurface');
}

simulated function SetupInitialRotation(vector HitNormal)
{
	// implement in sub-class
}

simulated function DLog(coerce string S, optional float LogDelay)
{
	if ((Level.TimeSeconds - LastLog) > LogDelay)
	{
		LastLog = Level.TimeSeconds;
		Log(S);
	}
}

// grenade is stuck to a wall or mover
state OnSurface
{
}

defaultproperties
{
	ArmedTime=0.000000
	Damage=150
	CollisionRadius=2.000000
	CollisionHeight=2.000000
	bStickToWalls=True
	DetonationTime=30.000000
	Mesh=LodMesh'DampenerM'
	DrawScale=0.500000
	bReplicateInstigator=True
	bNetTemporary=False
}