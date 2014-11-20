//=============================================================================
// WFMotionBlurGenerator.
//
// EffectSpawnTime detail: 0.5 low, 0.25 medium, 0.1 high, 0.05 highest
//=============================================================================
class WFMotionBlurGenerator extends Effects;

var() float BlurEffectTime;
var() class<WFMotionBlurEffect> MotionBlurEffectClass;
var float LastEffectTime;

var float LastLog;

function PostBeginPlay()
{
	super.PostBeginPlay();
	//Log(self.name$" Created for: "$Owner);
}

function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	//Log(self.name$" NET Created for: "$Owner);
}

simulated function Tick(float DeltaTime)
{
	local WFMotionBlurEffect Blur;

	if (bHidden) return;

	if (Level.NetMode == NM_DedicatedServer)
	{
		Disable('Tick');
		return;
	}

	//DLog(self.name$".Tick() called", 1.0);

	if ( (Level.TimeSeconds - LastEffectTime) > BlurEffectTime )
	{
		//Log(self.name$".Tick():  creating blur effect for: "$Owner);
		LastEffectTime = Level.TimeSeconds;
		Blur = spawn(MotionBlurEffectClass, Owner,, Owner.Location, Owner.Rotation);
		Blur.InitFor(Owner);
	}
}

simulated function DLog(coerce string S, float Delay)
{
	if ((Level.TimeSeconds - LastLog) > Delay)
	{
		LastLog = Level.TimeSeconds;
		Log(S);
	}
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
     BlurEffectTime=0.250000
     bHidden=False
     MotionBlurEffectClass=class'WFMotionBlurEffect'
     //DrawType=DT_Mesh
     //Style=STY_Translucent
     //DrawType=DT_Sprite
     Texture=Texture'MenuBlack'
     //Style=STY_Masked
     //DrawType=DT_None
     bUnlit=True
}