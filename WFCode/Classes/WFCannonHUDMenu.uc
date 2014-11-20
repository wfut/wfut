//=============================================================================
// WFCannonHUDMenu.
//
// RelatedActor is the cannon that displayed this menu.
//=============================================================================
class WFCannonHUDMenu extends WFClassHUDMenu;

var bool bInitialised;
var bool bNoRemove, bNoUpgrade, bNoRepair, bMaxLevel;
var Ammo Resources;
var class<WFEngineer> EngPCI;

function Initialise()
{
	EngPCI = class<WFEngineer>(PlayerOwner.PCInfo);
	Resources = Ammo(PlayerOwner.FindInventoryType(class'WFEngineerResource'));

	// set up the options
	if (RelatedActor != None)
		if (RelatedActor != EngPCI.static.FindRelatedActorClass(PlayerOwner, class'WFAutoCannon'))
		{
			bNoRemove = true;
			MenuOptionColors[8] = GreyColor * 0.5;
		}

	bMaxLevel = (WFAutoCannon(RelatedActor).TechLevel == 2);
	if (bMaxLevel || (Resources.AmmoAmount < EngPCI.default.CannonUpgradeCost))
	{
		bNoUpgrade = true;
		MenuOptionColors[1] = GreyColor * 0.5;
	}

	if (Resources.AmmoAmount <= 0)
	{
		bNoRepair = true;
		MenuOptionColors[2] = GreyColor * 0.5;
	}
	bInitialised = true;
}

function DisplayMenu(canvas Canvas)
{
	if (!bInitialised)
		return;

	if (!bMaxLevel && bNoUpgrade && (Resources.AmmoAmount >= EngPCI.default.CannonUpgradeCost))
	{
		bNoUpgrade = false;
		MenuOptionColors[1] = WhiteColor;
	}

	if (bNoRepair && (Resources.AmmoAmount > 0))
	{
		bNoRepair = false;
		MenuOptionColors[2] = WhiteColor;
	}

	super.DisplayMenu(Canvas);
}

function string GetAppendStringForOption(int Num)
{
	if ((Num == 1) && bNoUpgrade && !bMaxLevel)
		return "   ("$EngPCI.default.CannonUpgradeCost$")";

	return "";
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
			PlayerOwner.Special("AddAmmo");
			CloseMenu();
			break;
		case 2:
			if (!bNoUpgrade)
			{
				PlayerOwner.Special("Upgrade");
				CloseMenu();
			}
			break;
		case 3:
			if (!bNoRepair)
			{
				PlayerOwner.Special("Repair");
				CloseMenu();
			}
			break;
		case 4:
			PlayerOwner.Special("RotateL");
			CloseMenu();
			break;
		case 5:
			PlayerOwner.Special("RotateR");
			CloseMenu();
			break;
		case 9:
			if (!bNoRemove)
			{
				PlayerOwner.Special("Remove");
				CloseMenu();
			}
			break;
	}
}

function Timer()
{
	if ((RelatedActor == None) || (VSize(PlayerOwner.Location - RelatedActor.Location) > 100.0))
		CloseMenu();
	else super.Timer();
}

defaultproperties
{
	bUseColors=True
	bAlignAppendString=True
	DisplayTime=5
	NumOptions=7
	SeparatorString=":  "
	MenuOptions(0)="Add Ammo to Cannon"
	MenuOptions(1)="Upgrade Cannon"
	MenuOptions(2)="Repair Cannon"
	MenuOptions(3)="Rotate Cannon Left"
	MenuOptions(4)="Rotate Cannon Right"
	MenuOptions(7)=" "
	MenuOptions(8)="Remove Cannon"
}