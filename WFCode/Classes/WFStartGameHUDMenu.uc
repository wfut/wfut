class WFStartGameHUDMenu extends WFS_PCStartGameHUDMenu;

var bool bDisplaySelectionMenu;

function DisplayMenu(canvas Canvas)
{
	if (PGRI == None) PGRI = WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo);
	if (PGRI != None) NumOptions = PGRI.MaxTeams + 2;

	if ((ChildMenu == None) && ValidTeam(PlayerOwner.PlayerReplicationInfo.Team))
		CreateChildMenu(SelectionMenuClass);
	else
		super(WFS_HUDTextMenu).DisplayMenu(Canvas);
}

function bool ValidTeam(int Team)
{
	if ((PGRI != None) && (Team >= 0) && (Team < PGRI.MaxTeams))
		return true;

	return false;
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
			PlayerOwner.ChangeTeam(0);
			bDisplaySelectionMenu = true;
			break;
		case 2:
			PlayerOwner.ChangeTeam(1);
			bDisplaySelectionMenu = true;
			break;
		case 3:
			if (NumOptions > 3)
			{
				PlayerOwner.ChangeTeam(2);
				bDisplaySelectionMenu = true;
			}
			break;
		case 4:
			if (NumOptions > 4)
			{
				PlayerOwner.ChangeTeam(3);
				bDisplaySelectionMenu = true;
			}
			break;
		case 10:
			PlayerOwner.ChangeTeam(255);
			bDisplaySelectionMenu = true;
			break;
	}
}

function Tick(float DeltaTime)
{
	if (bDisplaySelectionMenu && ValidTeam(PlayerOwner.PlayerReplicationInfo.Team))
	{
		bDisplaySelectionMenu = false;
		CreateChildMenu(SelectionMenuClass);
	}
}