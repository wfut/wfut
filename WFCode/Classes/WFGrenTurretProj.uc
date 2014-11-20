class WFGrenTurretProj extends WFS_PCSGrenadeProj;

var() float RisingSpeed;
var() float RiseTime;
var() float ShootTime;
var() float CheckTime;
var() float HoverTime;
var() float Range;
var() int HitDamage;
var() vector MoveOffset;
var() int Health;
var() int NumShots;

var() sound FireSound;
var() sound ExpireSound;

var bool bFalling;

var float LastCheck, LastShot;
var int ShotsFired;

var effects MyEffect;

var() string TeamFireTextureStrings[4];
var firetexture TeamFireTextures[4];

var WFGrenTurretDamageArea DamageArea; // used to get projectiles to collide with grenade

var rotator ShootRotation;
var float SampleRate;
var float TurnRate; // turn rate in rev/s (1.0 = can turn 360 degrees in one second)
var float ShootDot; // will only make shot if dot product is above this value
var float RetryDelay;

simulated function GrenadeLanded()
{
	local rotator r;

	SetPhysics(PHYS_Flying);
	bFixedRotationDir = false;
	bRotateToDesired = true;
	r = Rotation;
	r.Pitch = 0;
	r.Roll = 0;
	DesiredRotation = r;
	RotationRate = rot(20000,20000,20000);

	SetCollision(false, false, false);

	if (DamageArea == None)
	{
		DamageArea = spawn(class'WFGrenTurretDamageArea', self,, Location);
		if (DamageArea != None)
		{
			DamageArea.SetLocation(Location);
			DamageArea.SetBase(self);
			DamageArea.MyGren = self;
		}
	}

	GotoState('Rising');
}

state Rising
{
	simulated function BeginState()
	{
		SetTimer(RiseTime, false);
	}

	simulated function Tick(float DeltaTime)
	{
		if (Physics == PHYS_Flying)
			MoveSmooth(MoveOffset*(DeltaTime/RiseTime));
		else GotoState('GrenadeFalling');
	}

	simulated function Timer()
	{
		GotoState('Hovering');
		LoopAnim('WFTurbob');
	}
}

state Hovering
{
	function BeginState()
	{
		//Log("-- Entered 'Hovering' state");
		if (bFalling)
		{
			ServerExplosion(Location);
			return;
		}
		RemoteRole = ROLE_DumbProxy;
		SetTimer(1.0, false);
		MyEffect = spawn(class'WFGrenTurretEffect', self);
		MyEffect.Mesh = Mesh;
		MyEffect.DrawScale = Drawscale;
		SetEffectTexture();
		ShotsFired = 0;
	}

	function Tick(float DeltaTime)
	{
		if (Instigator == None)
		{
			Explosion(Location);
			return;
		}

		if ((Level.TimeSeconds - LastCheck) >= CheckTime)
		{
			LastCheck = Level.TimeSeconds;

			if (Target == None)
				Target = FindTarget();
		}

		if ((Target != None) && ((Level.TimeSeconds - LastShot) >= ShootTime))
		{
			LastShot = Level.TimeSeconds;
			ShootAt(Target);
		}
	}

	function Timer()
	{
		if (RemoteRole == ROLE_DumbProxy)
		{
			RemoteRole = ROLE_SimulatedProxy;
			SetTimer(FMax(HoverTime - 1.0, 1.0), false);
		}
		else if (!bFalling)
			SetFall();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
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
			if (bSimFall && (Role == ROLE_Authority))
			{
				bSimFall = false;
				RemoteRole = ROLE_SimulatedProxy;
			}
			bBounce = False;
			SetPhysics(PHYS_None);
			GrenadeLanded();
		}
	}

Begin:
	Sleep(SampleRate);
	TurnTurretToward(Target);
	Goto('Begin');
}

function TurnTurretToward(actor Other)
{
	local rotator OtherDir, RotDiff, CurrentDir;
	local int MaxRotDelta;

	if (Other == None)
		return;

	MaxRotDelta = TurnRate*(2**16)*SampleRate;

	OtherDir = rotator(normal(Other.Location - Location));
	CurrentDir = ShootRotation;
	RotDiff = OtherDir - CurrentDir;
	ShootRotation.Yaw += Clamp(RotDiff.Yaw, -MaxRotDelta, MaxRotDelta);
	ShootRotation.Pitch += Clamp(RotDiff.Pitch, -MaxRotDelta, MaxRotDelta);
}

state GrenadeFalling
{
	simulated function GrenadeLanded() { }

	function Timer()
	{
		ServerExplosion(Location);
	}
}

function SetFall()
{
	Disable('Tick');
	TweenAnim('WFTurStill', 0.1);
	PlaySound(ExpireSound);
	bSimFall = true;
	bFalling = true;
	MyEffect.bHidden = true;
	bBounce = true;
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	SetTimer(2.0, false);
	GotoState('GrenadeFalling');
}

function SetEffectTexture()
{
	local int TeamNum;

	TeamNum = Instigator.PlayerReplicationInfo.Team;
	if ( TeamNum != 3 )
		MyEffect.ScaleGlow = 0.5;
	else
		MyEffect.ScaleGlow = 1.0;

	if ( TeamFireTextures[TeamNum] == None )
		TeamFireTextures[TeamNum] = FireTexture(DynamicLoadObject(TeamFireTextureStrings[TeamNum], class'Texture'));
	MyEffect.Texture = TeamFireTextures[TeamNum];
}

function pawn FindTarget()
{
	local pawn p, best;
	local float dist, bestdist;

	dist = 0;
	bestdist = Range;
	best = None;

	foreach VisibleCollidingActors(class'pawn', p, Range)
	{
		if ( p.bIsPlayer && (p.Health > 0) && FastTrace(p.Location, Location)
			&& (p.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)
			&& (!class'WFDisguise'.static.IsDisguised(P.PlayerReplicationInfo)
				|| (GetDisguiseTeam(p) != Instigator.PlayerReplicationInfo.Team)) )
		{
			dist = VSize(p.Location - Location);
			if (dist < bestdist)
			{
				best = p;
				bestdist = dist;
			}
		}
	}

	return best;
}

function byte GetDisguiseTeam(pawn Other)
{
	local WFDisguise Disguise;

	Disguise = WFDisguise(Other.FindInventoryType(class'WFDisguise'));
	if (Disguise != None)
		return Disguise.DisguiseTeam;

	return 255;
}

function ShootAt(actor Other)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace;
	local vector ActualDir, Dir, X, Y, Z;
	local pawn PawnOther;

	if (Other == None)
		return;

	PawnOther = pawn(Other);

	ActualDir = Normal(Other.Location - Location);
	Dir = vector(GetShootRot());

	if ( (VSize(Other.Location - Location) > Range)
		|| (Other.bIsPawn && ( (PawnOther.Health <= 0))
			|| (class'WFDisguise'.static.IsDisguised(PawnOther.PlayerReplicationInfo)
				&& (GetDisguiseTeam(PawnOther) == Instigator.PlayerReplicationInfo.Team)) )
		|| !FastTrace(Other.Location, Location))
	{
		Target = FindTarget();
		if (Target == None)
			return;
		Other = Target;
		ActualDir = Normal(Other.Location - Location);
	}

	// TODO: Need to scale this a bit based on target's distance
	if (Dir dot ActualDir < ShootDot)
	{
		// don't make the shot if player too far off current aim direction
		// so instead try again in 0.5 seconds
		LastShot = Level.TimeSeconds - ShootTime + RetryDelay;
		return;
	}

	// shoot at the target
	StartTrace = Location + (Dir * 15);
	EndTrace = Location + Dir * Range;
	Other = Instigator.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	GetAxes(rotator(Dir), X, Y, Z);
	ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
	PlaySound(FireSound, SLOT_None, 4.0);

	//if (Other.bIsPawn && (pawn(Other).Health <= 0))
	if ((Other != None) && Other.bIsPawn && (pawn(Other).Health <= 0))
		Target = FindTarget();

	if (NumShots > 0)
	{
		ShotsFired++;
		if (ShotsFired == NumShots)
			ServerExplosion(Location);
	}
}

function rotator GetShootRot()
{
	return ShootRotation;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int i;
	local PlayerPawn PlayerOwner;

	if (Other==None)
	{
		HitNormal = -X;
		//HitLocation = Owner.Location + X*Range;
		HitLocation = Location + X*Range;
	}

	SpawnEffect(HitLocation, Location);

	Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));

	//if ( (Other != None) && (Other != Owner) && (Other != Self) )
	if ( (Other != None) && (Other != Self) )
		Other.TakeDamage(HitDamage, Instigator, HitLocation, 60000.0*X, MyDamageType);
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'ShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

function ServerExplosion(vector HitLocation)
{
	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	spawn(class'ut_spriteballexplosion',,,hitlocation);

	Destroy();
}

function GrenTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local float actualDamage;

	if ((Health <= 0) || (DamageType == 'PlagueGrenade') || (DamageType == 'Gassed'))
		return;

	actualDamage = Damage;
	//if ((EventInstigator != None) && (Instigator != None))
	if ((EventInstigator != None) && EventInstigator.bIsPlayer && (Instigator != None))
	{
		if (EventInstigator.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)
			actualDamage = 0;
	}

	Health -= actualDamage;
	if (Health <= 0)
		ServerExplosion(Location);
}

simulated function Destroyed()
{
	if (DamageArea != None)
		DamageArea.Destroy();
	if (MyEffect != None)
		MyEffect.Destroy();
	super.Destroyed();
}

defaultproperties
{
	bNetTemporary=False
	bCollideActors=True
	DetonationTime=0.0
	//bProjTarget=True
	bCanHitPlayers=False
	CheckTime=1
	HoverTime=45
	Range=1000.0
	ShootTime=3.0
	NumShots=5
	RiseTime=1.5
	RisingSpeed=400.0
	HitDamage=20
	Mass=25.000000
	LifeSpan=0.000000
	Damage=50
	Health=10
	DamageRadius=250.000000
	MomentumTransfer=50000
	CollisionRadius=8.000000
	CollisionHeight=8.000000
	MyDamageType=TurretGrenade
	AnimSequence=WFTurStill
	Mesh=LODMesh'WF_Turretgr'
	FireSound=Sound'UnrealShare.ASMD.TazerFire'
	DrawScale=0.2
	//Skin=Texture'JDomN0'
	//Texture=Texture'JDomN0'
	//bMeshEnviroMap=True
	bRandomSpin=True
	BounceDampening=0.5
	MoveOffset=(Z=100.0)
	TeamFireTextureStrings(0)="UnrealShare.Belt_fx.ShieldBelt.RedShield"
	TeamFireTextureStrings(1)="UnrealShare.Belt_fx.ShieldBelt.BlueShield"
	TeamFireTextureStrings(2)="UnrealShare.Belt_fx.ShieldBelt.Greenshield"
	TeamFireTextureStrings(3)="UnrealShare.Belt_fx.ShieldBelt.N_Shield"
	TeamFireTextures(0)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield'
	TeamFireTextures(1)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.BlueShield'
	TeamFireTextures(2)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'
	TeamFireTextures(3)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
	//bFixedRotationDir=True
	SampleRate=0.1
	//MaxTurnRate=
	TurnRate=0.8
	ShootDot=0.95
	RetryDelay=0.25
}
