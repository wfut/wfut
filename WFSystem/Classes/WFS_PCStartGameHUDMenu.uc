//=============================================================================
// WFS_PCStartGameHUDMenu.
//=============================================================================
class WFS_PCStartGameHUDMenu extends WFS_HUDTextMenu;

var() class<WFS_HUDMenuInfo> SelectionMenuClass;
var() byte TEAM_Spectator;

var WFS_PCSystemGRI PGRI;

function Initialise()
{
	if (PGRI == None) PGRI = WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo);
	if (PGRI != None) NumOptions = PGRI.MaxTeams + 2;

	// set up the team names
	MenuOptions[0] = PGRI.Teams[0].TeamName;
	MenuOptions[1] = PGRI.Teams[1].TeamName;

	if (NumOptions > 4)
		MenuOptions[2] = PGRI.Teams[2].TeamName;
	else MenuOptions[2] = "";

	if (NumOptions > 5)
		MenuOptions[3] = PGRI.Teams[3].TeamName;
	else MenuOptions[3] = "";

}

function DisplayMenu(canvas Canvas)
{
	if (PGRI == None) PGRI = WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo);
	if (PGRI != None) NumOptions = PGRI.MaxTeams + 2;

	if ((ChildMenu == None) && (PlayerOwner.PlayerReplicationInfo.Team != TEAM_Spectator))
		CreateChildMenu(SelectionMenuClass);
	else
		super.DisplayMenu(Canvas);
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
			CreateChildMenu(SelectionMenuClass);
			break;
		case 2:
			PlayerOwner.ChangeTeam(1);
			CreateChildMenu(SelectionMenuClass);
			break;
		case 3:
			if (NumOptions > 3)
			{
				PlayerOwner.ChangeTeam(2);
				CreateChildMenu(SelectionMenuClass);
			}
			break;
		case 4:
			if (NumOptions > 4)
			{
				PlayerOwner.ChangeTeam(3);
				CreateChildMenu(SelectionMenuClass);
			}
			break;
		case 10:
			PlayerOwner.ChangeTeam(255);
			CreateChildMenu(SelectionMenuClass);
			break;
	}
}

function string GetAppendStringForOption(int num)
{
	local string s;
	local WFS_PCSystemGRI GRI;

	if ((PlayerOwner != none) && (num < 4))
		return "   ("$string(WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo).Teams[num].Size)$")";

	return "";
}

defaultproperties
{
	DisplayTime=0
	NumOptions=4
	bAlignAppendString=True
	SeparatorString=":  "
	MenuTitle="[ - Select Team - ]"
	MenuOptions(0)="Red"
	MenuOptions(1)="Blue"
	MenuOptions(2)="Green"
	MenuOptions(3)="Gold"
	MenuOptions(8)=" "
	MenuOptions(9)="Auto Team"
	TEAM_Spectator=4
	SelectionMenuClass=class'WFS_PCSelectionMenu'
	MenuOptionColors(0)=(R=255,G=0,B=0)
	MenuOptionColors(1)=(R=0,G=128,B=255)
	MenuOptionColors(2)=(R=0,G=255,B=0)
	MenuOptionColors(3)=(R=255,G=255,B=0)
	bUseColors=True
}
