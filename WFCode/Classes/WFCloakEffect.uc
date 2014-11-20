//=============================================================================
// WFCloakEffect.
//=============================================================================
class WFCloakEffect extends Effects;

var effects FadeEffect;
var class<effects> FadeEffectClass;
var byte FadeMode, LastMode;
var bool bEffectSetup;

const MODE_None		= 0;
const MODE_FadeIn	= 1;
const MODE_FadeOut	= 2;

var float LastLog;

replication
{
	reliable if (Role == ROLE_Authority)
		FadeMode;
}

simulated function CreateFadeEffect()
{
	if (Level.NetMode == NM_DedicatedServer)
	{
		bEffectSetup = true;
		return;
	}

	if (Owner != None)
	{
		//Log(self$"Effect successfully created for: "$Owner);
		FadeEffect = spawn(FadeEffectClass, Owner,, Owner.Location, Owner.Rotation);
		FadeEffect.Mesh = Owner.Mesh;
		FadeEffect.DrawScale = Owner.DrawScale;
		bEffectSetup = true;
	}
	//else DLog(self$"Owner: None", 1.0);
}

simulated function DLog(coerce string S, float Delay)
{
	if ((Level.TimeSeconds - LastLog) > Delay)
	{
		LastLog = Level.TimeSeconds;
		Log(S);
	}
}

function FadeIn()
{
	//Log(self$" FadeIn() called");
	FadeMode = MODE_FadeIn;
	SetTimer(2.0, false);
}

function FadeOut()
{
	//Log(self$" FadeOut() called");
	FadeMode = MODE_FadeOut;
	SetTimer(2.0, false);
}

function Timer()
{
	//Log(self$" Timer() called");
	FadeMode = MODE_None;
}

// effect state check (only does something if the FadeMode changes)
simulated function Tick(float DeltaTime)
{
	if (!bEffectSetup)
		CreateFadeEffect();

	if ((FadeMode == LastMode) || (FadeEffect == None))
		return;

	LastMode = FadeMode;
	if (FadeMode == MODE_None)
		return;

	if (FadeMode == MODE_FadeIn)
		FadeEffect.GotoState('FadingIn');
	else if (FadeMode == MODE_FadeOut)
		FadeEffect.GotoState('FadingOut');
}

simulated function Destroyed()
{
	if (FadeEffect != None)
		FadeEffect.Destroy();
}

defaultproperties
{
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	bAnimByOwner=True
	bOwnerNoSee=True
	bNetTemporary=False
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	//DrawType=DT_Mesh
	//DrawType=DT_Sprite
	//Style=STY_Masked
	//Skin=Texture'JDomN0'
	//Texture=Texture'JDomN0'
	Texture=Texture'MenuBlack'
	ScaleGlow=1.000000
	FadeEffectClass=class'WFCloakFadeEffect'
	//Fatness=136
	//bMeshEnviroMap=True
}