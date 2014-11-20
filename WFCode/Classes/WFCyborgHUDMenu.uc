class WFCyborgHUDMenu extends WFClassHUDMenu;

var bool bCanSetPlasma, bCanUseKami;

function Initialise()
{
	if (class'WFS_PlayerClassInfo'.static.RelatedActorCount(PlayerOwner, class'WFPlasmaBomb', true) != 0)
	{
		if (PlayerOwner.FindInventoryType(class'WFStatusKami') == None)
			MenuOptions[0] = "[ - Plasma already active - ]";
		else
			MenuOptions[0] = "[ - Can't arm plasma with Kamikaze active - ]";
		MenuOptions[1] = "";
		MenuOptions[2] = "";
		NumOptions = 5;
		bCanSetPlasma = false;
	}
	else bCanSetPlasma = true;
}

function string GetBaseStringForOption(int num)
{
	if (num == 9) return "0"$SeparatorString;
	else if ((num == 0) && !bCanSetPlasma) return "";
	else return num+1$SeparatorString;
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
			if (bCanSetPlasma)
			{
				PlayerOwner.Special("plasma small");
				CloseMenu();
			}
			break;
		case 2:
			if (bCanSetPlasma)
			{
				PlayerOwner.Special("plasma medium");
				CloseMenu();
			}
			break;
		case 3:
			if (bCanSetPlasma)
			{
				PlayerOwner.Special("plasma large");
				CloseMenu();
			}
			break;

		case 5:
			PlayerOwner.Special("kami");
			CloseMenu();
			break;

		case 10:
			CloseMenu();
			break;
	}
}

defaultproperties
{
	DisplayTime=5
	bAlignAppendString=True
	bUseColors=True
	NumOptions=7
	SeparatorString=":  "
	MenuTitle=""
	MenuOptions(0)="Arm Small Plasma (10s)"
	MenuOptions(1)="Arm Medium Plasma (25s)"
	MenuOptions(2)="Arm Large Plasma (50s)"
	MenuOptions(3)=" "
	MenuOptions(4)="Activate Self-Destruct"
	MenuOptions(5)=" "
	MenuOptions(9)="Close Menu"
}