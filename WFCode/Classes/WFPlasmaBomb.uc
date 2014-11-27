class WFPlasmaBomb extends Effects;

var bool bEffectsCreated;

var() int ExplodeDelay;
var() int ArmingDelay;
var() class<actor> EffectClass[4];
var() class<actor> ExplodeClass;
var int ArmingTime;

var int MyTeam;
var actor MyEffect;

var pawn PawnOwner;

var float DisruptionTime;
var class<actor> DisruptionEffectClass;
var actor DisruptionEffect;

var() bool bStartArmed;
var bool bPlayerDied; // player died while arming the plasma
var bool bArming;

var bool bHoldPlayer;
var vector HoldLocation;
var EPhysics OldPhysics;

var string ArmedEvent;

simulated function PostBeginPlay()
{
	//LoopAnim('plasmanim');
}

auto state Startup
{
	function BeginState()
	{
		if (Role == ROLE_Authority)
		{
			PawnOwner = pawn(Owner);
			MyTeam = PawnOwner.PlayerReplicationInfo.Team;
			if (bStartArmed)
				GotoState('Armed');
			else
				GotoState('Arming');
		}
	}
}

state Arming
{
	function BeginState()
	{
		// freeze player
		FreezePlayer();
		bArming = True;
		SetTimer(1.0, true);
	}

	function Timer()
	{
		ArmingTime++;
		SendTimeMessage(ArmingDelay - ArmingTime);
		if (ArmingTime >= ArmingDelay)
			GotoState('Armed');
	}

	function EndState()
	{
		// unfreeze player
		if (!bPlayerDied)
			UnfreezePlayer();
	}
}

function SendTimeMessage(int TimeLeft)
{
	if (TimeLeft > 0)
		PawnOwner.ClientMessage("Arming plasma: "$TimeLeft$" seconds left...", 'CriticalEvent');
	else if (TimeLeft == 0)
		PawnOwner.ClientMessage("Plasma Armed! Detonation in "$ExplodeDelay$" seconds.", 'CriticalEvent', true);
}

function FreezePlayer()
{
	local WFS_PCSystemPlayer P;
	P = WFS_PCSystemPlayer(Owner);
	if (P != None)
		P.FreezePlayer(ArmingDelay, 'SettingPlasma');
	bHoldPlayer = true;
	OldPhysics = Owner.Physics;
	Owner.SetPhysics(PHYS_None);
	HoldLocation = Location;
}

function UnfreezePlayer()
{
	local WFS_PCSystemPlayer P;
	P = WFS_PCSystemPlayer(Owner);
	if (P != None)
		P.UnfreezePlayer('SettingPlasma');
	bHoldPlayer = false;
	Owner.SetPhysics(OldPhysics);
}

function Explode()
{
	spawn(ExplodeClass,,, Location);
	Destroy();
}

state Armed
{
	function BeginState()
	{
		if (bStartArmed)
		{
			bArming = True;
			FreezePlayer();
			SetTimer(ArmingDelay, false);
		}
		else
		{
			if (PawnOwner.IsA('WFPlayer'))
				WFPlayer(PawnOwner).ClientReceiveEvent(ArmedEvent, 'Special');
			SetTimer(ExplodeDelay, false);
		}
	}

	function Timer()
	{
		if (bArming)
		{
			bArming = False;
			if (PawnOwner.IsA('WFPlayer'))
				WFPlayer(PawnOwner).ClientReceiveEvent(ArmedEvent, 'Special');
			if (!bPlayerDied)
			{
				PawnOwner.ClientMessage("Plasma detonation in "$string(ExplodeDelay - ArmingDelay)$" seconds!", 'CriticalEvent');
				UnfreezePlayer();
			}

			SetTimer(ExplodeDelay - ArmingDelay, false);
		}
		else Explode();
	}
}

function Tick(float DeltaTime)
{
	if (!bEffectsCreated)
		CreateEffects();

	if ((Owner != None) && !bPlayerDied && bHoldPlayer)
	{
		Owner.Acceleration = vect(0,0,0);
		Owner.Velocity = vect(0,0,0);
		if (Owner.Location != Location)
			Owner.SetLocation(Location);
	}
}

function CreateEffects()
{
	if (MyTeam != -1)
	{
		MyEffect = spawn(EffectClass[MyTeam], self,, Location);
		bEffectsCreated = true;
	}
}

function Destroyed()
{
	// clean up effects here
	if (MyEffect != None)
		MyEffect.Destroy();
	if (DisruptionEffect != None)
		DisruptionEffect.Destroy();

	super.Destroyed();
}

// plasma has been made unstable due to player dying while being set
function Disrupt()
{
	SetTimer(0.0, false);
	GotoState('Disrupted');
}

state Disrupted
{
	function BeginState()
	{
		SetTimer(DisruptionTime, false);
		DisruptionEffect = spawn(DisruptionEffectClass);
	}

	function Timer()
	{
		Explode();
	}
}

defaultproperties
{
	DrawType=DT_Mesh
	RemoteRole=ROLE_SimulatedProxy
	bNetOptional=False
	bNetTemporary=False
	//Mesh=Mesh'PlasmaBomb'
	//bParticles=True
	//Texture=Texture'WFMedia.PLazer_Alt.flare2_a05'
     SoundRadius=50
     SoundVolume=255
     //AmbientSound=Sound'Ambmodern.wpipes3'
     SoundPitch=32
	LodBias=0.0
	//bFixedRotationDir=True
	bUnlit=True
	//RotationRate=(Pitch=7500,Yaw=10000,Roll=7500)
	Style=STY_Translucent
	Physics=PHYS_None
	EffectClass(0)=class'WFPlasmaEffectRed'
	EffectClass(1)=class'WFPlasmaEffectBlue'
	EffectClass(2)=class'WFPlasmaEffectGreen'
	EffectClass(3)=class'WFPlasmaEffectGold'
	DisruptionEffectClass=class'WFPlasmaDisruptEffect'
	DisruptionTime=3.0
	AmbientSound=sound'WFPlasmaAmb'
	bStartArmed=True
	MyTeam=-1
}