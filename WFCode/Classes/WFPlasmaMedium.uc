class WFPlasmaMedium extends WFPlasmaBomb;

// TODO: limit to 128*6 units range

defaultproperties
{
	ExplodeDelay=25
	ArmingDelay=4
	ExplodeClass=class'WFPlasmaWaveMedium'
	ArmedEvent="m_plasma_armed"
}