//=============================================================================
// WFRSClient.
// Sets up the client area for the WF Rules.
//=============================================================================
class WFRSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'WFRulesCWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}