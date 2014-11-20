//=============================================================================
// WFMapSetupInfo.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Data class used to setup maps.
//=============================================================================
class WFMapSetupInfo extends WFS_MapSetupInfo
	config(WeaponsFactory)
	abstract;

var config string MapDataClassList[20];
var WFMapData MapDataList;

function SetupMap()
{
	local bool bSkipDefaultSetup;

	Log("=== Initialising Map Setup ===");

	LoadMapData();

	// Setup map inventory to stop bots from getting stuck trying to
	// collect something they can't.
	SetupMapInventory();

	if (caps(GetMapString()) == "CTF-WF-2FORTWFUT")
		TempFix_2FortWFUT();

	if (MapDataList != None)
		bSkipDefaultSetup = MapDataList.HandleMapSetup(GetMapString(), self);

	if (!bSkipDefaultSetup)
		DefaultMapSetup();

	if (MapDataList != None)
		MapDataList.HandlePostMapSetup(GetMapString(), self);

	Log("=== Map Setup Complete ===");
}

// Ob1: temp fix to disable the damage zones in the upper spawn rooms
// on "CTF-WF-2FortWFUT"
function TempFix_2FortWFUT()
{
	local ladder InfoClass;

	foreach allactors(class'ladder', InfoClass)
	{
		if (InfoClass != None)
		{
			if ( (InfoClass.name == 'LadderCTF86')
				|| (InfoClass.name == 'LadderCTF116')
				|| (InfoClass.name == 'LadderCTF117')
				|| (InfoClass.name == 'LadderCTF118')
				|| (InfoClass.name == 'LadderCTF123')
				|| (InfoClass.name == 'LadderCTF124')
				|| (InfoClass.name == 'LadderCTF127')
				|| (InfoClass.name == 'LadderCTF126') )
				InfoClass.MapPrefix = "";
		}
	}
}

// Load any map data packs and add them to the list.
function LoadMapData()
{
	local int i;
	local class<WFMapData> MapDataClass;
	local WFMapData MapData;

	for (i=0; i<ArrayCount(MapDataClassList); i++)
	{
		if (InStr(MapDataClassList[i], ".") != -1)
		{
			MapDataClass = class<WFMapData>(DynamicLoadObject(MapDataClassList[i], class'Class', true));
			if (MapDataClass != None)
			{
				MapData = spawn(MapDataClass);
				if (MapDataList == None) MapDataList = MapData;
				else MapDataList.AddMapData(MapData);
			}
			else Log("WARNING: failed to load map data class: "$MapDataClassList[i]);
		}
	}
}

function DefaultMapSetup()
{
	// implement in sub-class
}

function ProcessInfoClasses()
{
	local Ladder InfoClass;
	local int Count;

	// process any info classes
	Count = 0;
	foreach AllActors(class'Ladder', InfoClass)
	{
		if (InfoClass != None)
		{
			Count++;
			ProcessInfoClass(InfoClass);
			InfoClass.RemoteRole = ROLE_None;
			InfoClass.Tag = 'Processed';
			//InfoClass.Destroy();
		}
	}

	if (Count > 0)
		Log("Processed "$Count$" info classes");
}

// Implement in sub-class to support more info classes.
function ProcessInfoClass(Ladder InfoClass)
{
	if (InfoClass == None)
		return;

	switch (caps(InfoClass.MapPrefix))
	{
		case "TEAM_DAMAGE_ZONE":
			ProcessTeamDamageZoneInfo(InfoClass);
			break;

		case "SUPPLY_PACK":
			ProcessSupplyPackInfo(InfoClass);
			break;

		case "":
			break; // info class disabled

		default:
			Log("Unknown info type: "$InfoClass.MapPrefix$", for info class: "$InfoClass.name);
	}
}

function ProcessTeamDamageZoneInfo(Ladder InfoClass)
{
	local WFTeamDamageZone DZone;

	DZone = spawn(class'WFTeamDamageZone',,, InfoClass.Location);
	if (DZone != None)
		DZone.TeamFlags = InfoClass.NumTeams;
	else Log("WARNING: Couldn't create Team Damage Zone at: "$InfoClass.Location$" for info class: "$InfoClass.Name);
}

// Supply pack.
function WFSupplyPack ProcessSupplyPackInfo(Ladder InfoClass)
{
	local WFSupplyPack Pack;
	local string Types, Param, Key, Value;
	local int Pos, i;

	Pack = spawn(class'WFSupplyPack',, InfoClass.Tag, InfoClass.Location, InfoClass.Rotation);
	if (Pack != None)
	{
		Pack.SetCollision(true, false, false);
		if (Left(InfoClass.Maps[0], 11) ~= "AMMO_TYPES?")
		{
			Types = Right(InfoClass.Maps[0], Len(InfoClass.Maps[0]) - 11);
			if (Types ~= "NO_AMMO")
			{
				for (i=0; i<ArrayCount(Pack.AmmoAmounts); i++)
				{
					Pack.AmmoTypes[i] = None;
					Pack.AmmoAmounts[i] = 0;
				}
			}
			else
			{
				// parse ammo string
				GrabAmmoParam(Types, Param);
				Level.Game.GetKeyValue(Param, Key, Value);
				SetAmmoAmount(Pack, Key, Value);
				while (Types != "")
				{
					GrabAmmoParam(Types, Param);
					Level.Game.GetKeyValue(Param, Key, Value);
					SetAmmoAmount(Pack, Key, Value);
				}
			}
		}

		// set up supply pack options
		Pack.ItemFlags = InfoClass.Matches;
		if (InfoClass.TimeLimits[0] != 0)
			Pack.RespawnTime = InfoClass.TimeLimits[0];
		Pack.ArmorAmount = InfoClass.TimeLimits[1];
		Pack.CustomHealth = InfoClass.TimeLimits[2];
		Pack.ResourceAmount = InfoClass.TimeLimits[3];

		// set up grenades
		Pack.bAllGrenadeTypes = True;
		if (InfoClass.TimeLimits[4] > 0)
			Pack.NumGrenades = InfoClass.TimeLimits[4];
		else if (InfoClass.TimeLimits[4] == -1)
			Pack.NumGrenades = 0;

		// set up team flags
		Pack.TeamFlags = InfoClass.TimeLimits[5];

		return Pack;
	}
	return None;
}

function GrabAmmoParam(out string AmmoString, out string Param)
{
	local int i;

	for (i=0; i<Len(AmmoString); i++)
		if (Mid(AmmoString, i, 1) == ",")
			break;

	Param = Left(AmmoString, i);
	AmmoString = Right(AmmoString, Len(AmmoString) - Len(Param) -1);

	if (InStr(Param, "=") == -1)
		Param = "";

	if (InStr(AmmoString, "=") == -1)
		AmmoString = "";
}

function SetAmmoAmount(WFSupplyPack Pack, string AmmoType, string AmountString)
{
	local int i, Amount;
	local bool bFound;

	Amount = int(AmountString);
	if ((AmmoType == "") || (Amount <= 0))
		return;

	if (AmmoType ~= "DefaultAmmoAmount")
	{
		Pack.DefaultAmmoAmount = Amount;
		return;
	}

	for (i=0; i<ArrayCount(Pack.AmmoTypes); i++)
	{
		if ((Pack.AmmoTypes[i] != None) && (string(Pack.AmmoTypes[i].name) ~= AmmoType))
		{
			Pack.AmmoAmounts[i] = Amount;
			break;
		}
	}
}

function SetupMapInventory()
{
	local inventory Inv;
	local Ladder InfoClass;
	local bool bHasInfoClasses;

	// check to see if this is a WF map by searching for any supply pack info classes already
	bHasInfoClasses = false;
	foreach allactors(class'Ladder', InfoClass)
		if ((InfoClass != None) && (caps(InfoClass.MapPrefix) == "SUPPLY_PACK"))
			{ bHasInfoClasses = true; break; }

	if (bHasInfoClasses)
	{
		Log("Map already has info classes, clearing map inventory.");
		MapDataList.RemoveMapInventory();
	}
	else
	{
		// replace all weapons with ammo
		Inv = None;
		foreach allactors(class'Inventory', Inv)
			if ((Inv != None) && !Inv.bDeleteMe && Inv.IsA('Weapon'))
				if ( Level.Game.BaseMutator.ReplaceWith(Inv, string(weapon(Inv).AmmoName)) )
					Inv.Destroy();

		// set up inventory AI markers
		Inv = None;
		foreach allactors(class'Inventory', Inv)
		{
			if ((Inv != None) && !Inv.bDeleteMe && Inv.IsA('Pickup') && !Inv.IsA('WFS_PCSBotPickupMarker'))
			{
				//Log("Creating Marker for: "$Inv);
				CreateInventoryMarkerFor(Inv);
			}
		}
	}
}

function CreateInventoryMarkerFor(inventory Item)
{
	local WFS_PCSBotWeaponMarker WM;
	local WFS_PCSBotPickupMarker PM;

	if (Item != None)
	{
		// weapon markers are not used in WF, but the code is here if needed later
		if (Item.IsA('Weapon') && !Item.IsA('WFS_PCSBotWeaponMarker'))
		{
			WM = spawn(class'WFS_PCSBotWeaponMarker',,, Item.Location, Item.Rotation);
			if (WM == None) Log(self$": WARNING: WM == none! Item: "$Item);
			WM.InitFor(weapon(Item));
		}

		if (Item.IsA('Pickup') && !Item.IsA('WFS_PCSBotPickupMarker'))
		{
			PM = spawn(class'WFS_PCSBotPickupMarker',,, Item.Location, Item.Rotation);
			if (PM == None) Log(self$": WARNING: PM == none! Item: "$Item);
			PM.InitFor(pickup(Item));
		}
	}
}

defaultproperties
{
}