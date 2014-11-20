//=============================================================================
// WFS_PCSelectionMenu.
//=============================================================================
class WFS_PCSelectionMenu extends WFS_HUDTextMenu;

var class<WFS_PlayerClassInfo> PlayerClasses[10];
var int PlayerCounts[10];
var int MaxPlayers[10];
var int MAX_CLASSES; // max number of classes that this menu can deal with

var const byte SpectatorTeam;

function DisplayMenu(canvas Canvas)
{
	if (PlayerOwner.PlayerReplicationInfo.Team != SpectatorTeam)
	{
		GetPlayerClasses();
		super.DisplayMenu(Canvas);
	}
}

function GetPlayerClasses()
{
	local int i, count, Team;
	local WFS_PCSystemGRI GRI;

	GRI = WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo);
	Team = PlayerOwner.PlayerReplicationInfo.Team;
	for (i=0; i<MAX_CLASSES; i++)
	{
		PlayerClasses[i] = GRI.TeamClassList[Team].PlayerClasses[i];
		MenuOptions[i] = GRI.TeamClassList[Team].PlayerClassNames[i];
		if (MenuOptions[i] != "")
			count++;
	}
	NumOptions = count;
}

function string GetAppendStringForOption(int num)
{
	local string s;
	local int Team;
	local WFS_PCSystemGRI GRI;

	if ((PlayerOwner != none) && (num < MAX_CLASSES))
	{
		GRI = WFS_PCSystemGRI(PlayerOwner.GameReplicationInfo);
		Team = PlayerOwner.PlayerReplicationInfo.Team;
		s = string(GRI.TeamClassList[Team].PlayerCounts[num]);
		if (GRI.TeamClassList[Team].MaxPlayers[num] > 0)
			s = s$"/"$string(GRI.TeamClassList[Team].MaxPlayers[num]);
		s = "("$ s $")";
		if (bool(MaxPlayers[num]) && (PlayerCounts[num] >= MaxPlayers[num]))
			s = "(max)";
		return "    "$s;
	}

	return "";
}

function color GetAppendStringColor(int num)
{
	if (bUseTeamColor)
		return GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team, bool(MaxPlayers[num]) && (PlayerCounts[num] >= MaxPlayers[num]));
	return MenuOptionColors[num];
}

// proccess a selection
function ProcessSelection(int Selection)
{
	local bool bMaxPlayers;
	DisplayTimeLeft = DisplayTime;

	if (ChildMenu != none)
	{
		ChildMenu.ProcessSelection(Selection);
		return;
	}

	bMaxPlayers = (MaxPlayers[Selection-1] > 0) && (PlayerCounts[Selection-1] >= MaxPlayers[Selection-1]);
	if (PlayerClasses[Selection-1] != none)
	{
		if (!PlayerOwner.IsInState('PCSpectating'))
		{
			PlayerOwner.SetClass(PlayerClasses[Selection-1].default.ClassName);
			CloseMenu();
		}
		else if (!bMaxPlayers)
		{
			PlayerOwner.ChangePlayerClass(PlayerClasses[Selection-1]);
			CloseMenu();
		}
	}
}

function Timer()
{
	if ((PlayerOwner != None) && (PlayerOwner.IsInState('PCSpectating')))
		DisplayTimeLeft = DisplayTime;

	super.Timer();
}

defaultproperties
{
	DisplayTime=5
	SeparatorString=":  "
	MAX_CLASSES=10
	NumOptions=4
	MenuTitle="[ - Select Class - ]"
	MenuOptions(0)="Scout (n/a)"
	MenuOptions(1)="Heavy Weapons Guy"
	MenuOptions(2)="Engineer"
	MenuOptions(3)="Sniper (n/a)"
	bAlignAppendString=true
	bUseColors=True
	bUseTeamColor=True
	bBorderUseTeamColor=True
	SpectatorTeam=4
}
