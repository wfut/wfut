class WFLaserTripmineBeamHead expands WFLaserTripmineBeam;

var WFLaserTripmineModule MainDefense;

simulated function RelayAlert( string Alert, int Direction, Actor PActor, optional float Delay)
{
	if ( Direction == 1 )
		NextBeam.SendAlert( Alert, Direction, PActor, Delay );
	else if (Direction == -1)
		MainDefense.ReceiveAlert( Alert, Direction, PActor );
}