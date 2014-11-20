class WFD_DPMSPlayerWindow extends UMenuPlayerWindow;

function BeginPlay()
{
	Super.BeginPlay();

	ClientClass = class'WFD_DPMSPlayerClientWindow';
}

defaultproperties
{
	 WindowTitle="Player Setup"
}
