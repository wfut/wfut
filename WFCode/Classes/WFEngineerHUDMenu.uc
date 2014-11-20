//=============================================================================
// WFEngineerHUDMenu.
//
// Cannon maintanance options are done via the WFCannonHUDMenu class.
//
// TODO: Work out a reliable way to determine if a player has already built
//		 a cannon, depot, or alarm.
//
//       - Could use boolean flags in WFPlayer, set up some general purpose
//         flags in WFS_PCSystemPlayer, or put some flags in the PCSystemPRI.
//=============================================================================
class WFEngineerHUDMenu extends WFClassHUDMenu;

var bool bInitialised;
var actor AutoCannon, Depot, Alarm;
var class<WFEngineer> EngPCI;
var ammo Resources;
var bool bNoBuildCannon, bNoBuildDepot, bNoBuildAlarm, bNoDestructCannon, bNoDestructDepot;
var bool bHasCannon, bHasDepot, bHasAlarm;

function Initialise()
{
	EngPCI = class<WFEngineer>(PlayerOwner.PCInfo);
	AutoCannon = EngPCI.static.FindRelatedActorClass(PlayerOwner, class'WFAutoCannon');
	Depot = EngPCI.static.FindRelatedActorClass(PlayerOwner, class'WFSupplyDepot');
	Alarm = EngPCI.static.FindRelatedActorClass(PlayerOwner, class'WFAlarm');
	Resources = Ammo(PlayerOwner.FindInventoryType(class'WFEngineerResource'));

	NumOptions = 3;

	// TODO: check that this is reliable in net play
	bHasCannon = (AutoCannon != None);
	bHasDepot = (Depot != None);
	bHasAlarm = (Alarm != None);

	// build cannon
	if (bHasCannon || (Resources.AmmoAmount < EngPCI.default.CannonBuildCost))
	{
		bNoBuildCannon = true;
		MenuOptionColors[0] = GreyColor * 0.5;
		// remove build cannon option if already built
		if (bHasCannon)
		{
			MenuOptions[0] = "";
			NumOptions--;
		}
	}

	// build supply depot
	if (bHasDepot || (Resources.AmmoAmount < EngPCI.default.DepotBuildCost))
	{
		bNoBuildDepot = true;
		MenuOptionColors[1] = GreyColor * 0.5;
		// remove build supply depot option if already built
		if (bHasDepot)
		{
			MenuOptions[1] = "";
			NumOptions--;
		}
	}

	// build/remove alarm
	//if (bHasAlarm)
	//	MenuOptions[2] = "Remove Alarm";

	// remote detonate cannon
	if (AutoCannon == None)
	{
		MenuOptions[8] = "";
		bNoDestructCannon = true;
	}
	else NumOptions++;

	// remote detonate depot (not yet implemented)
	if (Depot == None)
	{
		MenuOptions[9] = "";
		bNoDestructDepot = true;
	}
	else NumOptions++;

	if (bNoDestructCannon && bNoDestructDepot)
		MenuOptions[3] = "";
	else NumOptions++;

	bInitialised = true;
}

function DisplayMenu(canvas Canvas)
{
	if (!bInitialised)
		return;

	if (!bHasCannon && bNoBuildCannon && (Resources.AmmoAmount >= EngPCI.default.CannonBuildCost))
	{
		bNoBuildCannon = false;
		MenuOptionColors[0] = WhiteColor;
	}

	if (!bHasDepot && bNoBuildDepot && (Resources.AmmoAmount >= EngPCI.default.DepotBuildCost))
	{
		bNoBuildDepot = false;
		MenuOptionColors[1] = WhiteColor;
	}

	if (!bHasAlarm && bNoBuildAlarm && (Resources.AmmoAmount >= EngPCI.default.AlarmBuildCost))
	{
		bNoBuildAlarm = false;
		MenuOptionColors[2] = WhiteColor;
	}

	super.DisplayMenu(Canvas);
}

function string GetAppendStringForOption(int Num)
{
	if ((Num == 0) && !bHasCannon && bNoBuildCannon)
		return "    ("$EngPCI.default.CannonBuildCost$")";
	else if ((Num == 1) && !bHasDepot && bNoBuildDepot)
		return "    ("$EngPCI.default.DepotBuildCost$")";
	//else if ((Num == 2) && !bHasAlarm && bNoBuildAlarm)
	//	return "    ("$EngPCI.default.AlarmBuildCost$")";

	return "";
}

// proccess a selection
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
			if (!bNoBuildCannon)
			{
				PlayerOwner.Special("Build");
				CloseMenu();
			}
			break;
		case 2:
			if (!bNoBuildDepot)
			{
				PlayerOwner.Special("BuildDepot");
				CloseMenu();
			}
			break;
		case 3:
			PlayerOwner.Special("DeployAlarm");
			CloseMenu();
			/*if (bHasAlarm)
			{
				WFS_PCSystemPlayer(PlayerOwner).Special("RemoveAlarm");
				CloseMenu();
			}
			else
			{
				WFS_PCSystemPlayer(PlayerOwner).Special("BuildAlarm");
				CloseMenu();
			}*/
			break;
		case 9:
			if (!bNoDestructCannon)
			{
				PlayerOwner.Special("Destruct");
				CloseMenu();
			}
			break;
		case 10:
			if (!bNoDestructDepot)
			{
				PlayerOwner.Special("DestructDepot");
				CloseMenu();
			}
			break;
	}
}

defaultproperties
{
	DisplayTime=5
	bAlignAppendString=True
	bUseColors=True
	NumOptions=6
	SeparatorString=":  "
	//MenuTitle="[ - Build Options - ]"
	MenuTitle=""
	MenuOptions(0)="Build Automatic Cannon"
	MenuOptions(1)="Build Supply Depot"
	MenuOptions(2)="Deploy Alarm"
	MenuOptions(3)=" "
	MenuOptions(8)="Detonate Automatic Cannon"
	MenuOptions(9)="Detonate Supply Depot"
	//MenuOptions(9)="Close Menu"
	//MenuOptions(1)="Upgrade Cannon"
	//MenuOptions(2)="Repair Cannon"
	//MenuOptions(3)="Add Ammo to Cannon"
	//MenuOptions(4)="Rotate Cannon 45°"
	//MenuOptions(4)="Rotate Cannon 45° Clockwise"
	//MenuOptions(5)="Rotate Cannon 45° Counter-Clockwise"
	//MenuOptions(5)=" "
	//MenuOptions(8)="Remove Cannon"
	//MenuOptions(9)="Cannon Self Destruct"
}
