class WFDisguiseClassHUDMenu extends WFClassHUDMenu;

var class<WFS_PlayerClassInfo> PlayerClasses[10];
var byte DisguiseTeam;

var int MAX_CLASSES;

function Initialise()
{
	GetPlayerClasses();
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

function ProcessSelection(int Selection)
{
	DisplayTimeLeft = DisplayTime;

	if (ChildMenu != none)
	{
		ChildMenu.ProcessSelection(Selection);
		return;
	}

	if (Selection <= NumOptions)
	{
		if (PlayerClasses[Selection-1].default.ShortName == "")
			PlayerOwner.Special("disguise "$PlayerClasses[Selection-1].default.ClassName);
		else PlayerOwner.Special("disguise "$PlayerClasses[Selection-1].default.ShortName);
		CloseMenu();
	}
}

defaultproperties
{
	DisplayTime=5
	SeparatorString=":  "
	MAX_CLASSES=10
	NumOptions=0
	MenuTitle="[ - Disguise Class - ]"
}
