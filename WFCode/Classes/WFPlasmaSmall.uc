class WFPlasmaSmall extends WFPlasmaBomb;

// TODO: limit to 128*3 units range

defaultproperties
{
	ExplodeDelay=10
	ArmingDelay=2
	ExplodeClass=class'WFPlasmaWaveSmall'
	ArmedEvent="s_plasma_armed"
}