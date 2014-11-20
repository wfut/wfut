//=============================================================================
// WFStatusBlinded.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFStatusBlinded extends WFPlayerStatus;

var() float BlindTime; // amount of time that the screen is black for
var() float FadeTime; // the time taken to return view to normal after BlindedTime has passed

var bool bInitialised;
var float BlindedTime; // the time the player has been blinded for so far
var float FadeTimeLeft;

var vector ViewFog, FogAdded;
var float ScaleAdded;

var bool bFadeCompleted;

var PlayerPawn PlayerOwner;

var int FadeX, FadeY; // pixel drawn from the modulated texture
var texture FadeTexture;

var ERenderStyle DrawStyle;

function bool HandleStatusFor(pawn Other)
{
	local inventory Inv;

	// remove any current status of this type
	Inv = Other.FindInventoryType(self.class);
	if (Inv != None) Inv.Destroy();

	return false;
}

simulated function StatusTick(float DeltaTime)
{
	if (bInitialised)
		FadeView(DeltaTime);
}

simulated function RenderStatus(canvas Canvas)
{
	local byte OldStyle;
	local float OldX, OldY;
	local bool bNoSmooth;
	if (!bInitialised || bFadeCompleted)
		return;

	OldStyle = Canvas.Style;
	OldX = Canvas.CurX;
	OldY = Canvas.CurY;
	bNoSmooth = Canvas.bNoSmooth;

	Canvas.Style = DrawStyle;
	Canvas.SetPos(0,0);
	Canvas.bNoSmooth = true;
	Canvas.DrawTile(FadeTexture, Canvas.ClipX, Canvas.ClipY, FadeX, FadeY, 1, 1);

	Canvas.Style = OldStyle;
	Canvas.SetPos(OldX, OldY);
	Canvas.bNoSmooth = bNoSmooth;
}

simulated function ClientInitialise()
{
	local float ExpireTime;

	PlayerOwner = PlayerPawn(Owner);
	if ((PlayerOwner != None) && (ViewPort(PlayerOwner.Player) != None))
	{
		// set up the initial client-side display
		FadeTimeLeft = FadeTime;
		FadeX = 0;
		FadeY = 0;
		bInitialised = true;
	}
	else Disable('StatusTick');
}

function ServerInitialise()
{
	// set up timer to remove status
	SetTimer(BlindTime+FadeTime+0.5, false);
}

function Timer()
{
	UsedUp();
}

// fade the players view from solid black
simulated function FadeView(float DeltaTime)
{
	local int FadeAlpha;
	if (bFadeCompleted) return;

	// start fading the view back in
	BlindedTime += DeltaTime;
	if (BlindedTime > BlindTime)
	{
		// calculate the faded view
		DrawStyle = ERenderStyle.STY_Modulated;
		FadeTimeLeft -= DeltaTime;
		FadeAlpha = int( (1 - (FadeTimeLeft/FadeTime)) * 128.0 );
		FadeX = FadeAlpha & 0x0F;
		FadeY = (FadeAlpha>>4) & 0x0F;
		if (FadeTimeLeft <= 0.0)
			bFadeCompleted = true;
	}
	else DrawStyle = ERenderStyle.STY_Normal;
}

defaultproperties
{
	PickupMessage="You have been blinded!"
	ExpireMessage="The blind effect has worn off."
	BlindTime=5.000000
	FadeTime=10.000000
	FadeTexture=texture'FadeTex'
	//bExclusiveRender=True
	bRenderStatus=True
	RenderPriority=255
	StatusID=2
	StatusType="Blinded"
}