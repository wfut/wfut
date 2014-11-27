//=============================================================================
// WFInfiltrator.
//=============================================================================
class WFInfiltrator extends WFPlayerClassInfo;

static function bool IsClientSideCommand(string SpecialString)
{
	if (SpecialString == "")
		return true;

	return false;
}

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	local inventory Inv;

	if (SpecialString == "")
	{
		WFS_PCSystemPlayer(Other).ClientDisplayHUDMenu(default.HUDMenu);
		return;
	}

	if (Left(SpecialString, 8) ~= "disguise")
		Disguise(Other, SpecialString);
	if (SpecialString ~= "cloak")
	{
		Inv = Other.FindInventoryType(class'WFCloaker');
		if (Inv != None)
			Inv.Activate();
	}
}

static function Disguise(pawn Other, string DisguiseString)
{
	local WFS_PCIList ClassList;
	local string DesiredClassName;
	local int DesiredTeam, i;
	local class<WFS_PlayerClassInfo> PCI;
	local WFDisguise Disguise;

	if (DisguiseString ~= "disguise")
	{
		Log("-- disguise called with no options");
		return;
	}

	DisguiseString = caps(DisguiseString);
	//Log("DisguiseString: "$DisguiseString);

	Disguise = WFDisguise(Other.FindInventoryType(class'WFDisguise'));

	if (InStr(DisguiseString, " RED") != -1) DesiredTeam = 0;
	else if (InStr(DisguiseString, " BLUE") != -1) DesiredTeam = 1;
	//else if (InStr(DisguiseString, " GREEN") != -1) DesiredTeam = 2;
	//else if (InStr(DisguiseString, " GOLD") != -1) DesiredTeam = 3;
	else if ((Disguise != None) && Disguise.bDisguised)
		DesiredTeam = Disguise.DisguiseTeam;
	else
	{
		// no team specified, so use first available enemy team
		// TODO: keep track of last enemy team and assume that for the default
		for (i=0; i<4; i++)
		{
			if (i != Other.PlayerReplicationInfo.Team)
			{
				DesiredTeam = i;
				break;
			}
		}
	}

	//Log("-- DesiredTeam: "$DesiredTeam);

	for (i=Len(DisguiseString)-1; i >= 0; i--)
	{
		if (Mid(DisguiseString, i, 1) ~= " ")
		{
			DesiredClassName = Right(DisguiseString, Len(DisguiseString)-1 - i);
			if ((DesiredClassName ~= "RED") || (DesiredClassName ~= "BLUE"))
			{
				//Log("-- No class name specified, assuming current DisguisePCI as disguise class.");
				if (Disguise.DisguisePCI != None)
					PCI = Disguise.DisguisePCI;
				else
					PCI = GetPCIFor(Other);
			}
			//Log("-- DesiredClassName: "$DesiredClassName);
			break;
		}
	}

	ClassList = WFS_PCSystemGRI(playerpawn(Other).GameReplicationInfo).TeamClassList[DesiredTeam];
	if ( (ClassList != none) && ((PCI == None) || (ClassList.GetIndexOfClass(PCI) == -1)) )
			PCI = ClassList.GetClassByClassName(DesiredClassName);

	if (PCI != None)
	{
		// add disguise code here...
		//Log("-- Desguising as: "$DesiredTeam$", "$DesiredClassName$", "$PCI.name);
		if (Disguise != None)
			Disguise.ChangeDisguise(DesiredTeam, PCI);
		//else Log("-- Couldn't change disguise: Disguise == None");
	}
	else
	{
		// couldn't disguise
		//Log("-- Disguise failed: "$DesiredTeam$", "$DesiredClassName);
	}
}

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	local WFDisguise Disguise;

	Disguise = WFDisguise(Other.FindInventoryType(class'WFDisguise'));
	if (Disguise != None)
		Disguise.RemoveDisguise();
}

defaultproperties
{
	ClassName="Infiltrator"
	ClassNamePlural="Infiltrators"
	bNoTranslocator=false
	Health=100
	Armor=50
	DefaultInventory=class'WFInfiltratorInv'
	ExtendedHUD=class'WFInfiltratorHUDInfo'
	MeshInfo=class'WFD_TMale2MeshInfo'
	AltMeshInfo=class'WFD_TMale2BotMeshInfo'
	bNoImpactHammer=True
	ClassDescription="WFCode.WFClassHelpInfiltrator"
	HUDMenu=class'WFInfiltratorHUDMenu'
	ClassSkinName="WFSkins.infi"
	ClassFaceName="WFSkins.Terrik"
	bAllowFeignDeath=True
	TranslocatorAmmoUsed=10
	VoiceType="BotPack.VoiceMaleTwo"
	bNoEnforcer=True
}
