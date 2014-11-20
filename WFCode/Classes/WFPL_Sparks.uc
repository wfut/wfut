//=============================================================================
// WFPL_Sparks.
//=============================================================================
class WFPL_Sparks expands AnimSpriteEffect;

simulated function PostBeginPlay()
{
	local actor a;
	Super.PostBeginPlay();
	Texture = Default.Texture;
}

defaultproperties
{
     NumFrames=30
     Pause=0.050000
     RemoteRole=ROLE_None
     LifeSpan=1.000000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'plazer_a00'
}
