class WFDisguiseTeamHUDMenu extends WFClassHUDMenu;

function Initialise()
{
	local WFS_PCSystemGRI PGRI;
	local WFDisguise Disguise;

	PGRI = WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo);
	NumOptions = PGRI.MaxTeams;

	// set up the team names
	MenuOptions[0] = PGRI.Teams[0].TeamName;
	MenuOptions[1] = PGRI.Teams[1].TeamName;

	if (NumOptions > 2)
		MenuOptions[2] = PGRI.Teams[2].TeamName;
	else MenuOptions[2] = "";

	if (NumOptions > 3)
		MenuOptions[3] = PGRI.Teams[3].TeamName;
	else MenuOptions[3] = "";
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
			PlayerOwner.Special("disguise red");
			CloseMenu();
			break;
		case 2:
			PlayerOwner.Special("disguise blue");
			CloseMenu();
			break;
		case 3:
			if (NumOptions > 2)
			{
				PlayerOwner.Special("disguise green");
				CloseMenu();
			}
			break;
		case 4:
			if (NumOptions > 3)
			{
				PlayerOwner.Special("disguise gold");
				CloseMenu();
			}
			break;
	}
}

function CloseChildMenu()
{
	if (ParentMenu == None)
		return;

	if (ParentMenu.ChildMenu == self)
		ParentMenu.ChildMenu = None;

	PlayerOwner = None;
	ParentMenu = None;
	OwnerHUD = None;

	SetTimer(0.0, false);
}

defaultproperties
{
	DisplayTime=5
	NumOptions=4
	bAlignAppendString=True
	SeparatorString=":  "
	MenuTitle="[ - Disguise Team - ]"
	MenuOptions(0)="Red"
	MenuOptions(1)="Blue"
	MenuOptions(2)="Green"
	MenuOptions(3)="Gold"
	MenuOptionColors(0)=(R=255,G=0,B=0)
	MenuOptionColors(1)=(R=0,G=128,B=255)
	MenuOptionColors(2)=(R=0,G=255,B=0)
	MenuOptionColors(3)=(R=255,G=255,B=0)
	bUseColors=True
}
