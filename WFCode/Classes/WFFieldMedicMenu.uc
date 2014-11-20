class WFFieldMedicMenu extends WFClassHUDMenu;

var bool bHasDepot, bInitialised;
var actor Depot;

function Initialise()
{
	Depot = class'WFS_PlayerClassInfo'.static.FindRelatedActorClass(PlayerOwner, class'WFHealingDepot');
	bHasDepot = (Depot != None);
	if (bHasDepot)
	{
		MenuOptions[0] = "Move Healing Depot";
		MenuOptions[1] = "Remove Healing Depot";
		NumOptions = 2;
	}
	else
	{
		MenuOptions[0] = "Deploy Healing Depot";
		NumOptions = 1;
	}

	bInitialised = true;
}

function ProcessSelection(int Selection)
{
	DisplayTimeLeft = DisplayTime;

	if (ChildMenu != none)
	{
		ChildMenu.ProcessSelection(Selection);
		return;
	}

	switch (Selection)
	{
		case 1:
			PlayerOwner.Special("DeployDepot");
			CloseMenu();
			break;

		case 2:
			if (bHasDepot)
			{
				PlayerOwner.Special("RemoveDepot");
				CloseMenu();
			}
			break;
	}
}

defaultproperties
{
	DisplayTime=5
	NumOptions=1
}