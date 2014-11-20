//=============================================================================
// WFStatusTranquilised.
//=============================================================================
class WFStatusTranquilised extends WFPlayerStatus;

var() float EffectTime;
var() float MovementScale; // scaling factor to change movement by (0.0 - 1.0)

var() float PulseRate; // time taken to fade in and out
var() byte FadeMag; // 0-127
var byte BaseFade; // the darkest that the screen gets during a pulse

var() bool bSlowPulse;
var float PulseFrequency;

var float PulseTime;
var bool bInitialised;
var int FadeX, FadeY; // pixel drawn from the modulated texture
var texture FadeTexture;

function ServerInitialise()
{
	SetPlayerMovement();

	SetTimer(EffectTime, false);
}

function Timer()
{
	UsedUp();
}

function SetPlayerMovement()
{
	local float MovementScaling;
	local pawn PawnOwner;
	MovementScaling = MovementScale;// * 1.0/ScaleFactor;

	PawnOwner = pawn(Owner);
	if (PawnOwner != None)
	{
		PawnOwner.GroundSpeed *= MovementScaling;
		PawnOwner.WaterSpeed *= MovementScaling;
		PawnOwner.AirSpeed *= MovementScaling;
		PawnOwner.AccelRate *= MovementScaling;
	}
}

function ResetPlayerMovement()
{
	local pawn PawnOwner;
	local float SpeedScaling;
	local class<WFS_PlayerClassInfo> PCI;
	local WFStatusLegDamage LegDamageStatus;

	if (DeathMatchPlus(Level.Game).bMegaSpeed)
		SpeedScaling = 1.4;
	else SpeedScaling = 1.0;

	PawnOwner = pawn(Owner);
	if (PawnOwner != None)
	{
		PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(PawnOwner);

		PawnOwner.GroundSpeed = PawnOwner.default.GroundSpeed * SpeedScaling;
		PawnOwner.WaterSpeed = PawnOwner.default.WaterSpeed * SpeedScaling;
		PawnOwner.AirSpeed = PawnOwner.default.AirSpeed * SpeedScaling;
		PawnOwner.AccelRate = PawnOwner.default.AccelRate * SpeedScaling;

		if (PCI != None)
			PCI.static.ModifyPlayer(PawnOwner);

		LegDamageStatus = WFStatusLegDamage(PawnOwner.FindInventoryType(class'WFStatusLegDamage'));
		if ((LegDamageStatus != None) && !LegDamageStatus.bDeleteMe && (PawnOwner.Health > 0)
			&& (LegDamageStatus.Owner == Owner))
			LegDamageStatus.SetPlayerMovement();

		// let the current weapon know that the players movement has been reset
		if ((PawnOwner.Weapon != None) && !PawnOwner.Weapon.bDeleteMe && PawnOwner.Weapon.IsA('WFWeapon')
			&& (PawnOwner.Health > 0) && (PawnOwner.Weapon.Owner == Owner))
			WFWeapon(PawnOwner.Weapon).WeaponEvent('PlayerMovementReset');
	}
}

simulated function Destroyed()
{
	if (Role == ROLE_Authority)
		ResetPlayerMovement();
	super.Destroyed();
}

simulated function ClientInitialise()
{
	local playerpawn PlayerOwner;
	local float ExpireTime;

	PlayerOwner = PlayerPawn(Owner);
	if ((PlayerOwner != None) && (ViewPort(PlayerOwner.Player) != None))
	{
		// set up the initial client-side display
		if (PulseRate > 0) PulseFrequency = PulseRate/PI;
		else PulseFrequency = 1;
		BaseFade = 127 - FadeMag;
		FadeX = 16;
		FadeY = 8;
		bInitialised = true;
	}
	else Disable('StatusTick');
}

simulated function StatusTick(float DeltaTime)
{
	if (bInitialised)
		FadePulse(DeltaTime);
}

// fade the players view from solid black
simulated function FadePulse(float DeltaTime)
{
	local int FadeAlpha;
	local float PulsePhase;

	PulseTime += DeltaTime;

	// calculate the faded view
	if (bSlowPulse)
	{
		PulsePhase = sin(PulseTime * PulseFrequency);
		if (PulsePhase < 0) PulsePhase *= -1.0;
		FadeAlpha = int( (1.0 - PulsePhase) * FadeMag );
		FadeAlpha += BaseFade;
	}
	else
	{
		FadeAlpha = int( sin((PulseTime * PulseFrequency) - PI/2.0) * FadeMag);
		if (FadeAlpha < 0) FadeAlpha *= -1;
		FadeAlpha += BaseFade;
	}
	FadeX = FadeAlpha & 0x0F;
	FadeY = (FadeAlpha>>4) & 0x0F;
}

simulated function RenderStatus(canvas Canvas)
{
	local byte OldStyle;
	local float OldX, OldY;
	local bool bNoSmooth;
	if (!bInitialised)
		return;

	OldStyle = Canvas.Style;
	OldX = Canvas.CurX;
	OldY = Canvas.CurY;
	bNoSmooth = Canvas.bNoSmooth;

	Canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.SetPos(0,0);
	Canvas.bNoSmooth = true;
	Canvas.DrawTile(FadeTexture, Canvas.ClipX, Canvas.ClipY, FadeX, FadeY, 1, 1);

	Canvas.Style = OldStyle;
	Canvas.SetPos(OldX, OldY);
	Canvas.bNoSmooth = bNoSmooth;
}

defaultproperties
{
	PickupMessage="You have been tranquilised!"
	ExpireMessage="The tranquiliser has worn off."
	MovementScale=0.500000
	EffectTime=30.000000
	StatusID=6
	bRenderStatus=True
	FadeTexture=texture'FadeTex'
	FadeMag=80
	StatusType="Tranquilised"
}