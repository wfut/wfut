class WFRefereeHUDInfo extends WFHUDInfo;

simulated function DrawStatus(out byte bDisableFunction, Canvas Canvas)
{
	if (OwnerHUD.PlayerOwner.ViewTarget == None)
		bDisableFunction = 1;
}

simulated function DrawAmmo(out byte bDisableFunction, Canvas Canvas)
{
	if (OwnerHUD.PlayerOwner.ViewTarget == None)
		bDisableFunction = 1;
}

simulated function DrawFragCount(out byte bDisableFunction, Canvas Canvas)
{
	if (OwnerHUD.PlayerOwner.ViewTarget == None)
		bDisableFunction = 1;
}

simulated function DrawWeapons(out byte bDisableFunction, Canvas Canvas)
{
	if (OwnerHUD.PlayerOwner.ViewTarget == None)
		bDisableFunction = 1;
}

