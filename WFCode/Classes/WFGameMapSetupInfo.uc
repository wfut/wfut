//=============================================================================
// WFMapSetupInfo.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Data class used to setup maps for the 'WFGame' CTF game type.
//=============================================================================
class WFGameMapSetupInfo extends WFMapSetupInfo;

var WFGame WFGameType; // local reference to the WFGame type
var() texture DefaultFlagTextures[4];

function PostBeginPlay()
{
	super.PostBeginPlay();
	WFGameType = WFGame(Owner);
	Log("WFGameMapSetupInfo created. WFGameType: "$WFGameType);
}

function DefaultMapSetup()
{
	local CTFFlag aFlag;
	local int Count, NumFlags;

	// check to see if this is a standard CTF map
	if (Left(GetMapString(), 3) ~= "CTF")
		SetupCTFMap();
	else
	{
		// try to find any CTFFlags in map anyway
		foreach AllActors(class'CTFFlag', aFlag)
			Count++;

		if (Count >= 2)
			SetupCTFMap();
	}

	// process any info classes
	ProcessInfoClasses();

	// adjust the maximum teams for this map
	AdjustMaxTeams();
}

function ProcessInfoClass(Ladder InfoClass)
{
	if (InfoClass == None)
		return;

	switch (caps(InfoClass.MapPrefix))
	{
		case "DEFAULT_GAME_RULES":
			ProcessDefaultRulesInfo(InfoClass);
			break;
		case "FLAG_CAP_POINT":
			ProcessCapturePointInfo(InfoClass);
			break;
		case "SUPPLY_PACK":
			ProcessSupplyPackInfo(InfoClass);
			break;
		case "LONE_FLAG":
			ProcessLoneFlagInfo(InfoClass);
			break;

		// not yet implemented
		case "NO_FLAG_ZONE":
			ProcessNoFlagZoneInfo(InfoClass);
			break;

		case "TEAM_DAMAGE_ZONE":
			ProcessTeamDamageZoneInfo(InfoClass);
			break;

		case "":
			break; // info class disabled

		default:
			Log("Unknown info type: "$InfoClass.MapPrefix$", for info class: "$InfoClass.name);
	}
}

function ProcessNoFlagZoneInfo(Ladder InfoClass)
{
	local WFNoFlagZone NoFlagZ;
	NoFlagZ = spawn(class'WFNoFlagZone',,, InfoClass.Location);
	if (NoFlagZ == None)
		Log("WARNING: Couldn't create No Flag Zone at: "$InfoClass.Location$" for info class: "$InfoClass.Name);
}

function AdjustMaxTeams()
{
	local CTFFlag aFlag;
	local int NumFlags;

	// Check and adjust MaxTeams based on the number of flags on the level
	NumFlags = 0;
	foreach AllActors(class'CTFFlag',aFlag)
		if (aFlag != None) NumFlags++;
	if (NumFlags >= 2)
	{
		WFGameType.MaxTeams = NumFlags;
		WFGameGRI(WFGameType.GameReplicationInfo).MaxTeams = WFGameType.MaxTeams;
	}
}

// set up game using map rules
function ProcessDefaultRulesInfo(Ladder InfoClass)
{
	local WFFlag aFlag;
	local FlagBase aBase;
	local texture FlagSkins[4];
	local string SkinName;
	local int i;

	// load the default map skins
	if (!WFGameType.bOverrideMapFlagTextures)
	{
		for (i=0; i<4; i++)
		{
			if (InfoClass.Maps[i] != InfoClass.default.Maps[i])
			{
				SkinName = InfoClass.Maps[i];
				FlagSkins[i] = Texture(DynamicLoadObject(SkinName, class'Texture', true));
				if (FlagSkins[i] == None)
					Log("Warning: Couldn't load skin: "$SkinName);
			}
		}

		// update skins
		foreach AllActors(class'WFFlag', aFlag)
			if ((aFlag != None) && (FlagSkins[aFlag.Team] != None))
				aFlag.Skin = FlagSkins[aFlag.Team];

		foreach AllActors(class'Flagbase', aBase)
			if ((aBase != None) && (FlagSkins[aBase.Team] != None))
				aBase.Skin = FlagSkins[aBase.Team];
	}
}

// Alternate capture point.
// TODO:
// - Add configurable collision cylinder
function ProcessCapturePointInfo(Ladder InfoClass)
{
	local WFFlagGoal CapturePoint;
	local WFFlag aFlag;
	local int Team;

	Team = InfoClass.NumTeams;
	if ((Team > 3) && (Team != 255))
		Log("WARNING: Bad team property for Capture Point; "$InfoClass.name$".NumTeams: "$InfoClass.NumTeams$", should be: 0, 1, 2, 3, or 255.");
	CapturePoint = spawn(class'WFFlagGoal',, InfoClass.Tag, InfoClass.Location, InfoClass.Rotation);
	if (CapturePoint != None)
	{
		CapturePoint.SetCollision(true, false, false);
		CapturePoint.Team = Team;
		if (WFGameType.FlagReturnStyle == WFGameType.FRS_DelayReturn)
			CapturePoint.bAlwaysCap = true;
		foreach allactors(class'WFFlag', aFlag)
			if ( (aFlag != None) && ((Team == 255) || (aFlag.Team == Team)) )
			{
				if ((aFlag.CapturePoint == None) || (aFlag.Team == 255))
					aFlag.CapturePoint = CapturePoint;
				CapturePoint.MyFlag = aFlag;
			}
		if (CapturePoint.MyFlag == None)
			Log("WARNING: Couldn't find flag for Capture Point (Team: "$Team$"). Check that the 'NumTeams' property is set correctly for '"$InfoClass.name$"'.");
	}
	else Log("WARNING: Couldn't create Capture Point at InfoClass: "$InfoClass.name);
}

// Location of lone flag in single flag CTF
function ProcessLoneFlagInfo(Ladder InfoClass);

function WFSupplyPack ProcessSupplyPackInfo(Ladder InfoClass)
{
	local WFSupplyPack Pack;
	Pack = super.ProcessSupplyPackInfo(InfoClass);
	if (Pack != None)
		WFGameType.ModifySupplyPack(Pack);
}

// setup a standard CTF map for WF
// TODO: use custom WF skins for flags
function SetupCTFMap()
{
	local CTFFlag aFlag;
	local FlagBase aBase;
	local WFFlagBase WFBase;
	local int count;
	local WFMarker BaseLoc;
	local bool bCapFlag;
	local texture FlagTexture;

	Log("Setting up CTF map");
	// remove all the CTFFlags
	foreach allactors(class'CTFFlag', aFlag)
	{
		count++;
		aFlag.Destroy();
	}
	Log("Removed "$count$" flags");

	bCapFlag = WFGameType.FlagReturnStyle == class'WFGame'.default.FRS_DelayReturn;

	// spawn a WF flag and flag base at each of the existing bases
	foreach AllActors(class'FlagBase', aBase)
		if ((aBase != None) && !aBase.IsA('WFFlagBase'))
		{
			switch (aBase.Team)
			{
				case 0:
					aFlag = spawn(class'WFRedFlag',,, aBase.Location, aBase.Rotation);
					WFBase = spawn(class'WFFlagBase',,, aBase.Location, aBase.Rotation);
					BaseLoc = spawn(class'WFMarker',,, aBase.Location, aBase.Rotation);
					BaseLoc.Team = 0;
					WFBase.BaseMarker = BaseLoc;
					WFBase.Team = 0;
					WFBase.SetCollision(true, false, false);
					WFBase.DrawScale = aBase.DrawScale;
					WFBase.bCapFlag = bCapFlag;
					WFBase.HomeFlag = WFFlag(aFlag);
					WFBase.Event = aBase.Event;
					aFlag.HomeBase = WFBase;
					aFlag.SendHome();
					aFlag.SetCollision(true, false, false);
					// set up flag skins
					FlagTexture = GetFlagTextureForTeam(0);
					WFBase.Skin = FlagTexture;
					aBase.Skin = FlagTexture;
					aFlag.Skin = FlagTexture;
					WFGameGRI(WFGameType.GameReplicationInfo).FlagList[0] = aFlag;
					break;
				case 1:
					aFlag = spawn(class'WFBlueFlag',,, aBase.Location, aBase.Rotation);
					WFBase = spawn(class'WFFlagBase',,, aBase.Location, aBase.Rotation);
					BaseLoc = spawn(class'WFMarker',,, aBase.Location, aBase.Rotation);
					BaseLoc.Team = 1;
					WFBase.BaseMarker = BaseLoc;
					WFBase.Team = 1;
					WFBase.SetCollision(true, false, false);
					WFBase.DrawScale = aBase.DrawScale;
					WFBase.bCapFlag = bCapFlag;
					WFBase.HomeFlag = WFFlag(aFlag);
					WFBase.Event = aBase.Event;
					aFlag.HomeBase = WFBase;
					aFlag.SendHome();
					aFlag.SetCollision(true, false, false);
					// set up flag skins
					FlagTexture = GetFlagTextureForTeam(1);
					WFBase.Skin = FlagTexture;
					aBase.Skin = FlagTexture;
					aFlag.Skin = FlagTexture;
					WFGameGRI(WFGameType.GameReplicationInfo).FlagList[1] = aFlag;
					break;
			}
		}

	// count the flags in the game
	count = 0;
	foreach allactors(class'CTFFlag', aFlag)
		if (aFlag.IsA('WFFlag'))
			count++;
	Log("Added "$count$" WF flags");
}

function texture GetFlagTextureForTeam(int Team)
{
	local string SkinName;
	local texture FlagTexture;

	SkinName = WFGameType.FlagTextures[Team];
	if (SkinName != "")
		FlagTexture = texture(DynamicLoadObject(SkinName$"_t"$Team, class'Texture', true));

	if (FlagTexture != None)
		return FlagTexture;

	return DefaultFlagTextures[Team];
}

defaultproperties
{
	DefaultFlagTextures(0)=Texture'WFRedFlag'
	DefaultFlagTextures(1)=Texture'WFBlueFlag'
	DefaultFlagTextures(2)=Texture'WFGreenFlag'
	DefaultFlagTextures(3)=Texture'WFGoldFlag'
	MapDataClassList(0)="WFStockCTFMapData.WFStockCTFMapData"
	MapDataClassList(1)="WFBonusPackCTFMapData.WFBonusPackCTFMapData"
}