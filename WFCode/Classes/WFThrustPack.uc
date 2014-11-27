class WFThrustPack extends WFPickup;

var() float ThrustSpeed;
var() float ThrustLift;
var() int ChargeUsed;
var() int MinChargeUsed;
var() int MaxCharge;

var() int ThrustTime;
var int ThrustTimeLeft;

var() bool bCanThrustWithFlag;
var() bool bDropFlagOnThrust;

var effects MyEffect;
var EPhysics FlyingPhysics;

var float LastMessage;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(1.0, true);
}

function Timer()
{
	if (Charge < MaxCharge)
		Charge++;
}

function Use(pawn User)
{
	local CTFFlag aFlag;

	User = pawn(Owner);

	if (User == None)
		return;

	if (Charge < MinChargeUsed)
	{
		SendMessage(User, "Not enough energy to use Thrust Pack (need "$ChargeUsed$" energy)");
		return;
	}

	if (bDropFlagOnThrust && (User.PlayerReplicationInfo.HasFlag != None))
	{
		SendMessage(User, "You dropped the flag!");
		User.PlayerReplicationInfo.HasFlag.Drop(0.5 * User.Velocity);
	}
	else if (!bCanThrustWithFlag && (User.PlayerReplicationInfo.HasFlag != None))
	{
		SendMessage(User, "Cannot use Thrust Pack while holding flag");
		return;
	}

	Charge = Max(0, Charge - ChargeUsed);
	GotoState('Thrusting');
}

function SendMessage(pawn Other, coerce string S)
{
	if ((Level.TimeSeconds - LastMessage) > 1.0)
	{
		LastMessage = Level.TimeSeconds;
		Other.ClientMessage(S, 'CriticalEvent');
	}
}

function SetThrust(pawn Other)
{
	local bool bWasFalling;
	local vector Thrust;
	local float SpeedScaling;

	if (DeathMatchPlus(Other.Level.Game).bMegaSpeed)
		SpeedScaling = 1.4;
	else SpeedScaling = 1.0;

	bWasFalling = ( Other.Physics == PHYS_Falling );
	Thrust = vector(Other.ViewRotation) * (ThrustSpeed * SpeedScaling);

	if ( Other.IsA('Bot') )
	{
		if ( bWasFalling )
			Bot(Other).bJumpOffPawn = true;
		Bot(Other).SetFall();
	}
	//Other.SetPhysics(PHYS_Falling);
	Other.AirSpeed = ThrustSpeed * SpeedScaling;
	//Other.Velocity += Thrust + vect(0,0,1)*ThrustLift;
	Other.Acceleration = vect(0,0,0);
	Other.bCanFly = true;

	Other.PlayInAir();
}

state Thrusting
{
	function BeginState()
	{
		DisableFlagTouch();
		ThrustTimeLeft = ThrustTime;
		Owner.SetPhysics(FlyingPhysics);
		SetThrust(pawn(Owner));
		SetTimer(1.0, true);
		//Owner.PlaySound(ActivateSound);

		if (MyEffect == None)
			MyEffect = Spawn(class'WFSmokeTrailEffect', owner);

		if (MyEffect != None)
		{
			MyEffect.bHidden = false;
			MyEffect.AmbientSound = ActivateSound;
		}
	}

	function Timer()
	{
		ThrustTimeLeft--;
		if (ThrustTimeLeft <= 0)
			GotoState('WaitForLanding');
	}

	function Use(pawn User) { }

	function Tick(float DeltaTime)
	{
		if (Owner != None)
			Owner.Velocity = vector(pawn(owner).ViewRotation) * ThrustSpeed;
	}

	function EndState()
	{
		local class<WFS_PlayerClassInfo> PCI;
		local inventory status;
		local pawn PawnOwner;

		if (MyEffect != None)
		{
			MyEffect.bHidden = true;
			MyEffect.AmbientSound = None;
		}

		PawnOwner = pawn(Owner);
		if (PawnOwner != None)
		{
			PawnOwner.bCanFly = false;
			if (Owner.Region.Zone.bWaterZone)
				PawnOwner.SetPhysics(PHYS_Swimming);
			else
				PawnOwner.SetPhysics(PHYS_Falling);
			PawnOwner.PlaySound(DeActivateSound);

			PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(PawnOwner);
			if (PCI != None)
				PCI.static.ModifyPlayer(PawnOwner);

			status = PawnOwner.FindInventoryType(class'WFStatusTranquilised');
			if (status != None)
				WFStatusTranquilised(status).SetPlayerMovement();

			status = PawnOwner.FindInventoryType(class'WFStatusLegDamage');
			if (status != None)
				WFStatusLegDamage(status).SetPlayerMovement();
		}
	}
}

state WaitForLanding
{
	function Tick(float DeltaTime)
	{
		super.Tick(deltaTime);
		if (Owner.Physics != PHYS_Falling)
		{
			// landed
			EnableFlagTouch();
			CheckTouching();
			GotoState('Idle2');
		}
	}
}

function CheckTouching()
{
	local int i;
	for(i=0; i<4; i++)
		if (Touching[i] != None)
			Touching[i].Touch(Owner);
}

function DisableFlagTouch()
{
	local pawn Other;

	Other = pawn(Owner);
	if (Other == None)
		return;

	if (Other.IsA('WFPlayer'))
		WFPlayer(Other).bFlagTouchDisabled = true;
	else if (Other.IsA('WFBot'))
		WFBot(Other).bFlagTouchDisabled = true;
}

function EnableFlagTouch()
{
	local pawn Other;

	Other = pawn(Owner);
	if (Other == None)
		return;

	if (Other.IsA('WFPlayer'))
		WFPlayer(Other).bFlagTouchDisabled = false;
	else if (Other.IsA('WFBot'))
		WFBot(Other).bFlagTouchDisabled = false;
}

function Destroyed()
{
	if (MyEffect != None)
		MyEffect.Destroy();
	super.Destroyed();
}

defaultproperties
{
	Charge=50
	ChargeUsed=20
	MaxCharge=50
	MinChargeUsed=20
	ThrustSpeed=1200.0
	ThrustTime=1
	ThrustLift=400
	ActivateSound=sound'WarFly'
	DeActivateSound=sound'WarheadPickup'
	FlyingPhysics=PHYS_Flying
	bCanThrustWithFlag=False
	bDropFlagOnThrust=True
}