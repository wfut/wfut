class WFInfiltratorHUDMenu extends WFClassHUDMenu;

var bool bDisguised;
var WFDisguise Disguise;

function Initialise()
{
	local WF_PRI WFPRI;
	local bool bDisguiseActive;

	Disguise = WFDisguise(PlayerOwner.FindInventoryType(class'WFDisguise'));
	if (Disguise != None)
		bDisguised = Disguise.bDisguised;

	if (PlayerOwner != None)
		bDisguised = class'WFDisguise'.static.IsDisguised(PlayerOwner.PlayerReplicationInfo);

	if (bDisguised)
	{
		if (Disguise != None)
		{
			NumOptions = 8;
			MenuOptions[3] = " ";
			MenuOptions[4] = "Disguise Team:   ";
			MenuOptions[5] = "Disguise Class:   ";
		}
	}
}

function string GetAppendStringForOption(int num)
{
	if ((bDisguised) && (Disguise != None))
	{
		if (num == 4)
			return GetStringForTeam(Disguise.DisguiseTeam);
		else if (num == 5)
		{
			if (Disguise.DisguisePCI != None)
				return Disguise.DisguisePCI.default.ClassName;
			else return "None";
		}
	}

	return "";
}

function string GetStringForTeam(byte Team)
{
	switch (Team)
	{
		case 0: return "Red";
		case 1: return "Blue";
		case 2: return "Green";
		case 3: return "Gold";
	}
	return "None";
}

function color GetAppendStringColor(int num)
{
	if (bUseTeamColor)
		return GetColorForTeam(PlayerOwner.PlayerReplicationInfo.Team);

	if ((num == 4) || (num == 5))
	{
		if (Disguise != None)
			return class'ChallengeTeamHUD'.default.TeamColor[Clamp(Disguise.DisguiseTeam, 0, 3)];
	}

	return MenuOptionColors[num];
}

function string GetBaseStringForOption(int num)
{
	if (bDisguised && ((num == 4) || (num == 5))) return "";
	else if (num == 9) return "0"$SeparatorString;
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
			//WFS_PCSystemPlayer(PlayerOwner).Special("Disguise");
			CreateChildMenu(class'WFDisguiseTeamHUDMenu');
			break;
		case 2:
			CreateChildMenu(class'WFDisguiseClassHUDMenu');
			break;

		case 3:
			PlayerOwner.Special("cloak");
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
	NumOptions=5
	bAlignAppendString=True
	SeparatorString=":  "
	MenuTitle="[ - Disguise Options - ]"
	MenuOptions(0)="Change Team"
	MenuOptions(1)="Change Class"
	MenuOptions(2)="Cloak/Decloak"
	MenuOptions(8)=" "
	MenuOptions(9)="Close Menu"
	MenuOptionColors(4)=(R=128,G=128,B=128)
	MenuOptionColors(5)=(R=128,G=128,B=128)
	//SelectionMenuClass=class'WFInfDisguiseHUDMenu'
	bUseColors=True
}