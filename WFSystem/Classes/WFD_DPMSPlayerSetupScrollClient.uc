class WFD_DPMSPlayerSetupScrollClient extends UMenuPlayerSetupScrollClient;

function Created()
{
	ClientClass = class'WFD_DPMSPlayerSetupClient';
	FixedAreaClass = None;

	Super(UWindowScrollingDialogClient).Created();
}

defaultproperties
{
}