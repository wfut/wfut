//=============================================================================
// WFSSClient.
// Sets up the client area for the WF Settings.
//=============================================================================
class WFSSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'WFSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}