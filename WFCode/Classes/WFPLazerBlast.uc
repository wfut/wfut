//=============================================================================
// WFPLazerBlast.
//=============================================================================
class WFPLazerBlast expands Projectile;

var() texture SpriteAnim[20];
var() int NumFrames;
var() float Pause;
var int i;
var Float AnimTime;


function PostBeginPlay()
{
	Velocity = Vector(Rotation) * speed;
	PlaySound(SpawnSound,SLOT_None,4.0);
	Super.PostBeginPlay();

}


simulated function Explode(vector HitLocation, vector HitNormal)
{
	local WFPL_Sparks s;
 	s = spawn(class'WFPL_Sparks');
	s.RemoteRole = ROLE_None;
	Destroy();
}


auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation) {
	local vector momentum;
	If ( Other!=Instigator  && WFPLazerBlast(Other)==None ) {
		momentum = MomentumTransfer * Normal(Velocity);
		Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);
		Destroy();

	}
   }



Begin:
	Sleep(2.0); //self destruct after 7.0 seconds
	Explode(Location, vect(0,0,0));
}

defaultproperties
{
     NumFrames=17
     speed=1450.000000
     Damage=15.000000
     MomentumTransfer=10000
     MyDamageType=Pulsed
     ImpactSound=Sound'Botpack.PulseGun.PulseExp'
     ExploWallOut=10.000000
     ExplosionDecal=Class'Botpack.BoltScorch'
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'WFMedia.PLazer_Pri.flare_a00'
     DrawScale=0.250000
     AmbientGlow=187
     bUnlit=True
     SoundRadius=10
     SoundVolume=218
     LightType=LT_Flicker
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=150
     LightSaturation=51
     LightRadius=5
     bFixedRotationDir=True
}
