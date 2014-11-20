class WFGunnerHUDMenu extends WFClassHUDMenu;

// proccess a selection
function ProcessSelection(int Selection)
{
	DisplayTimeLeft = DisplayTime;
	switch (Selection)
	{
		case 0:
			break;
		case 1:
			PlayerOwner.Special("setmine");
			CloseMenu();
			break;
		case 2:
			PlayerOwner.Special("removemine");
			CloseMenu();
			break;
		case 4:
			PlayerOwner.Special("DeployAlarm");
			CloseMenu();
			break;
		case 8:
			PlayerOwner.Special("RemoveDecloaker");
			CloseMenu();
			break;
		case 10:
			CloseMenu();
			break;
	}
}

defaultproperties
{
	DisplayTime=10
	NumOptions=8
	bAlignAppendString=True
	SeparatorString=":  "
	MenuTitle="[ - Gunner Options - ]"
	MenuOptions(0)="Set InstaGib Mine"
	MenuOptions(1)="Remove InstaGib Mine"
	MenuOptions(2)=" "
	MenuOptions(3)="Deploy Alarm"
	MenuOptions(4)=" "
	MenuOptions(7)="Remove Decloaker Mine"
	MenuOptions(8)=" "
	MenuOptions(9)="Close Menu"
	//MenuOptionColors(3)=(R=128,G=128,B=128)
	//MenuOptionColors(4)=(R=128,G=128,B=128)
	bUseColors=True
}
