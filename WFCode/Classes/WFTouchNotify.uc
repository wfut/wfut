// notifys owner of a touch event
class WFTouchNotify extends Triggers;

function Touch(actor Other)
{
	if ((Owner != None) && (Other != Owner))
		Owner.Touch(Other);
}

defaultproperties
{
	RemoteRole=ROLE_None
	bCollideWorld=False
}