//=============================================================================
// WFS_TestEngineerHUDMenu.
//=============================================================================
class WFS_TestEngineerHUDMenu extends WFS_HUDTextMenu;

var bool bOutOfRange;

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
			PlayerOwner.Special("Build");
			CloseMenu();
			break;
		case 2:
			PlayerOwner.Special("Repair");
			CloseMenu();
			break;
		case 3:
			PlayerOwner.Special("AddAmmo");
			CloseMenu();
			break;
		case 4:
			PlayerOwner.Special("Upgrade");
			CloseMenu();
			break;
		case 9:
			PlayerOwner.Special("Remove");
			CloseMenu();
			break;
		case 10:
			PlayerOwner.Special("Destruct");
			CloseMenu();
			break;
	}
}

function string GetAppendStringForOption(int num)
{
	return "";
}

defaultproperties
{
	DisplayTime=5
	NumOptions=7
	//MenuTitle="--- Build Options ---"
	MenuTitle=""
	MenuOptions(0)="Build Automatic Cannon"
	MenuOptions(1)="Repair Cannon"
	MenuOptions(2)="Add Ammo to Cannon"
	MenuOptions(3)="Upgrade Cannon"
	MenuOptions(4)=" "
	MenuOptions(8)="Remove Cannon"
	MenuOptions(9)="Cannon Self Destruct"
}
