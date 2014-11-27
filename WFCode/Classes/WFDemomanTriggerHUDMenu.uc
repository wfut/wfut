class WFDemomanTriggerHUDMenu extends WFClassHUDMenu;

function ProcessSelection(int Selection)
{
	local string DelayString;

	DisplayTimeLeft = DisplayTime;

	if (ChildMenu != none)
	{
		ChildMenu.ProcessSelection(Selection);
		return;
	}

	switch (Selection)
	{
		case 1: DelayString = "1.0"; break;
		case 2: DelayString = "1.5"; break;
		case 3: DelayString = "2.0"; break;
		case 4: DelayString = "2.5"; break;
		case 5: DelayString = "3.0"; break;

		case 10:
			CloseMenu();
			break;

		default: DelayString = "";
	}

	if (DelayString != "")
	{
		PlayerOwner.Special("DeployTrigger"@DelayString);
		CloseMenu();
	}
}

defaultproperties
{
     MenuOptions(0)="1.0s Trigger Delay"
     MenuOptions(1)="1.5s Trigger Delay"
     MenuOptions(2)="2.0s Trigger Delay"
     MenuOptions(3)="2.5s Trigger Delay"
     MenuOptions(4)="3.0s Trigger Delay"
     MenuOptions(8)=" "
     MenuOptions(9)="Close Menu"
     MenuTitle="[ - Deploy Prox Trigger - ]"
     SeparatorString=":  "
     NumOptions=7
     DisplayTime=5
}
