class WFMutator extends DMMutator;

function bool AlwaysKeep(Actor Other)
{
	local bool bTemp;

	if ( Other.IsA('StationaryPawn') || Other.IsA('WFS_PCSBotWeaponMarker') || Other.IsA('WFS_PCSBotPickupMarker'))
		return true;

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function CreateInventoryMarkerFor(inventory Item)
{
	local WFS_PCSBotWeaponMarker WM;
	local WFS_PCSBotPickupMarker PM;

	if (Item != None)
	{
		if (Item.IsA('Weapon') && !Item.IsA('WFS_PCSBotWeaponMarker'))
		{
			WM = spawn(class'WFS_PCSBotWeaponMarker',,, Item.Location, Item.Rotation);
			if (WM == None) Log(self$": WARNING: WM == none!");
			WM.InitFor(weapon(Item));
			if (Item.MyMarker != None)
				Item.MyMarker.MarkedItem = WM;
		}

		if (Item.IsA('Pickup') && !Item.IsA('WFS_PCSBotPickupMarker'))
		{
			PM = spawn(class'WFS_PCSBotPickupMarker',,, Item.Location, Item.Rotation);
			if (PM == None) Log(self$": WARNING: PM == none!");
			PM.InitFor(pickup(Item));
			if (Item.MyMarker != None)
				Item.MyMarker.MarkedItem = PM;
		}
	}
}
