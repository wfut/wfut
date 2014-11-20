//=============================================================================
// WFPLazerBlast.
//=============================================================================
class WFPLazerAltBlast expands WFPLazerBlast;

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation) {
	local vector momentum;
	If ( Other!=Instigator  && WFPLazerBlast(Other)==None ) {

				momentum = MomentumTransfer * Normal(Velocity);
				HurtRadius(Damage, 125, MyDamageType, MomentumTransfer, Location );
				Destroy();


	}
   }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local WFPL_Sparks s;
 	s = spawn(class'WFPL_Sparks');
	s.RemoteRole = ROLE_None;
	s.DrawScale = s.Default.DrawScale * 2;
	Spawn(class'UT_RingExplosion',,, HitLocation+HitNormal*8,rotator(HitNormal));
	Destroy();
}

defaultproperties
{
     NumFrames=13
     speed=700.000000
     Damage=65.000000
     MomentumTransfer=85000
     ExplosionDecal=Class'Botpack.EnergyImpact'
     Texture=Texture'WFMedia.PLazer_Pri.flare2_a00'
     DrawScale=0.750000
     CollisionRadius=15.000000
     CollisionHeight=15.000000
     bCorona=True
}
