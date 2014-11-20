class WFStatusKami extends WFPlayerStatus;

var string CountdownMessage;
var float deltacount;
var float Countdown;
var float TimerLag;
var float PulseDelta;
var float PulseScale;
var float CountRate;

var string CriticalMassMessage;

function ServerInitialise()
{
	if (Level.NetMode != NM_Standalone)
	{
		CountDown = 10 + TimerLag;
		CountRate = 1.0 + TimerLag;
	}
}

function KamiTimer()
{
	local actor effect;

	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}
		else if ((Owner != None) && (Countdown > 0))
		{
			effect = Spawn(class'WFKamiPulseEffect', Owner,, Owner.Location, Owner.Rotation);
			effect.Mesh = Owner.Mesh;
		}
		if (Countdown <= 0)
			GotoState('Exploding');
	}
}

state Exploding
{
	function BeginState()
	{
		SetTimer(0.1, false);
	}

	function Timer()
	{
		local float RangeScale;
		local int ArmorAmount, MaxArmor;
		local WFArmor A;
		local pawn PawnOwner;
		PawnOwner = pawn(Owner);
		if (PawnOwner == None)
			return;
		A = WFArmor(pawn(owner).FindInventoryType(class'WFArmor'));
		if (A != None)
			RangeScale = A.Charge/A.MaxCharge;
		Spawn(class'WFKamiWave',,, PawnOwner.Location);
		PawnOwner.Health = -1000;
		PawnOwner.Died(PawnOwner, 'KamikazeStatus', PawnOwner.Location);
		PawnOwner.HurtRadius(1000, 650.0 - 350.0*RangeScale, 'KamikazeStatus', 100000, PawnOwner.Location);
	}
}

simulated function StatusTick(float DeltaTime)
{
	deltacount += DeltaTime;
	if (deltacount >= CountRate)
	{
		CountDown -= CountRate;
		deltacount -= CountRate;
		CountRate = 1.0;
		KamiTimer();
	}
	PulseDelta += DeltaTime;
	if (PulseDelta > 2.0)
		PulseDelta -= 2.0;
	PulseScale = sin(PI*PulseDelta);
}

simulated function RenderStatus(canvas Canvas)
{
	local float XL, YL;
	local font OldFont;
	local string Message;
	local color OldDrawClr;

	OldFont = Canvas.font;
	OldDrawClr = Canvas.DrawColor;
	Canvas.Font = class'FontInfo'.static.GetStaticBigFont(Canvas.ClipX);
	if ((Countdown <= 0) && (Level.NetMode != NM_Standalone))
	{
		Message = CriticalMassMessage;
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255*abs(PulseScale);
		Canvas.DrawColor.B = 0;
	}
	else Message = CountdownMessage $ int(Countdown);
	Canvas.StrLen(Message, XL, YL);
	Canvas.SetPos(Canvas.ClipX/2 - XL/2, Canvas.ClipY/2 - YL/2);
	Canvas.DrawText(Message, false);
	Canvas.DrawColor = OldDrawClr;
	Canvas.font = OldFont;
}

defaultproperties
{
	bRenderStatus=True
	CountdownMessage="Self-Destruct in: "
	Countdown=10
	PickupMessage="Self-Destruct Sequnce Begun"
	DeathMessage="%o was killed by %k's kamikaze."
	SuicideMessage="%k blew himself up for the team."
	CriticalMassMessage="*** CRITICAL MASS ***"
	TimerLag=0.5
	CountRate=1.0
}