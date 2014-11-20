class WFPlasmaEffectRed extends Effects;

var actor MyEffects[3];

simulated function PostBeginPlay()
{
	LoopAnim('core');
	MyEffects[0] = spawn(class'WFOrbit1', self,, Location);
	MyEffects[0].Texture = Texture;
	MyEffects[1] = spawn(class'WFOrbit2', self,, Location);
	MyEffects[1].Texture = Texture;
	MyEffects[2] = spawn(class'WFOrbit3', self,, Location);
	MyEffects[2].Texture = Texture;
}

simulated function Destroyed()
{
	local int i;
	for (i=0; i<3; i++)
		if ((MyEffects[i] != None) && !MyEffects[i].bDeleteMe)
			MyEffects[i].Destroy();
	super.Destroyed();
}

defaultproperties
{
	DrawType=DT_Mesh
	RemoteRole=ROLE_SimulatedProxy
	bNetOptional=False
	bNetTemporary=False
	//Mesh=Mesh'plasmeffect'
	Mesh=Mesh'WFPlasmaCore'
	bParticles=True
	Texture=Texture'Tranglow'
	DrawScale=1.0
	LodBias=0.0
	bFixedRotationDir=True
	bUnlit=True
	RotationRate=(Pitch=7500,Yaw=10000,Roll=7500)
	Style=STY_Translucent
	Physics=PHYS_Rotating
}