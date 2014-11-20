//=============================================================================
// WFRocketExpl.
//=============================================================================
class WFRocketExpl extends WarExplosion2;

simulated function PostBeginPlay()
{
	local actor a;

	Super.PostBeginPlay();
	if ( !Level.bHighDetailMode ) 
		Drawscale = 1.9;
	PlaySound (EffectSound1,,12.0,,3000);	
    Texture = Default.Texture;
}


defaultproperties
{
     Texture=Texture'Botpack.WarExplosionS2.ne_a00'
     DrawScale=1.50000
     EffectSound1=Sound'UnrealShare.General.Explo1'
}
