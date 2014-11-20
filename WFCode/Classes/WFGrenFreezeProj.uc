class WFGrenFreezeProj extends WFS_PCSGrenadeProj;

var WFIceEffect MyEffect;
var WFTouchNotify MyTouchNotify;
var int ArmedTime;

var int Health;

var bool bInit;
var float MoveTime;
var float SlowdownRate;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	// can't do anthing until armed
}

simulated function Explosion(vector HitLocation)
{
	GotoState('Armed');
}

simulated function Tick(float DeltaTime)
{
	local vector NewVelocity, SpeedChange;
	super.Tick(DeltaTime);
	if (VSize(Velocity) == 0)
		return;

	if (!bInit)
	{
		SlowDownRate = VSize(Velocity)/MoveTime;
		bInit = true;
	}

	if (VSize(Velocity) > 0)
	{
		SpeedChange = normal(Velocity)*(SlowDownRate*DeltaTime);
		NewVelocity = Velocity - SpeedChange;
		if (Normal(NewVelocity) dot Normal(Velocity) > 0)
			Velocity = NewVelocity;
		else Velocity = vect(0,0,0);
	}
	else Velocity = vect(0,0,0);

	/*if (!IsInState('Armed'))
	{
		MoveTimeCount += DeltaTime;
		if (MoveTimeCount < MoveTime)
			MoveSmooth(vector(Rotation)*MoveOffset*(DeltaTime/MoveTime));
	}*/
}

state Armed
{
	function BeginState()
	{
		if (MyEffect == None)
		{
			MyEffect = spawn(class'WFIceEffect', self,, Location);
			MyEffect.InitFor(self);
		}
		if (MyTouchNotify == None)
		{
			MyTouchNotify = spawn(class'WFTouchNotify', self,, Location);
			MyTouchNotify.SetCollisionSize(50.0, 50.0);
		}

		SetTimer(ArmedTime, false);
	}

	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		local pawn PawnOther;
		local bool bGiveStatus, bSameTeam;
		local WFPlayerStatus s;
		local class<WFPlayerClassInfo> PCI;

		if ((Other != None) && Other.bIsPawn && pawn(Other).bIsPlayer)
		{
			PawnOther = pawn(Other);
			if ((PawnOther.Health > 0) && ((Instigator == None) || (PawnOther.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)))
			{
				spawn(class'WFGrenFreezeCloud', self,, Location);
				Timer();
			}
		}
	}

	function EndState()
	{
		if (MyEffect != None)
			MyEffect.Destroy();
		if (MyTouchNotify != None)
			MyTouchNotify.Destroy();
		SetTimer(0.0, false);
	}

Begin:
	RemoteRole = ROLE_Dumbproxy;
	Sleep(1.0);
	RemoteRole = ROLE_SimulatedProxy;
}

function Timer()
{
	spawn(class'shockexplo',,,Location);
	Destroy();
}

function Destroyed()
{
	if (MyEffect != None)
		MyEffect.Destroy();
	super.Destroyed();
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local float actualDamage;

	if ((Health <= 0) || (DamageType == 'PlagueGrenade') || (DamageType == 'Gassed'))
		return;

	actualDamage = Damage;
	if ((EventInstigator != None) && (Instigator != None))
	{
		if (EventInstigator.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)
			actualDamage = 0;
	}

	Health -= actualDamage;
	if (Health <= 0)
		Timer();
}

defaultproperties
{
	MoveTime=3
	bCanHitPlayers=True
	bCollideActors=True
	DetonationTime=5.0
	bNetTemporary=False
	//Physics=PHYS_Flying
	Physics=PHYS_Projectile
	CollisionRadius=15.0
	CollisionRadius=15.0
	ArmedTime=45
	Mesh=LodMesh'Botpack.BioGelm'
	Skin=Texture'JDomN0'
	Texture=Texture'JDomN0'
	bMeshEnviroMap=True
	Health=50
}