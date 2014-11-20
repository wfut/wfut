//=============================================================================
// WFMapData.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Map data classes can be used to modify a map before the game starts. They
// are linked together in a chain with the ones at the beginning of the list
// having priority over the ones later in the list.
//
// These classes are loaded at the beginning of each game, and are queried
// using the map name (eg. "CTF-Face") and the map setup info actor.
//
// They are intended to be used for adding WFUT specific items to non-WFUT maps,
// like: Supply Packs, Alt Capture Points, etc. Although they can also be used
// to change the gametype's settings (eg. MaxTeams), and modify the content of
// a map (eg. disable triggers, block off areas, etc). So they can also be used
// in converting non-CTF maps for WFUT.
//
// By default these actors are server-side only, and do not need to be added to
// the 'ServerPackages' list unless they contain content (ie. new models) that
// needs to be sent to the client.
//=============================================================================
class WFMapData extends Info
	abstract;

var() bool bSkipDefaultMapSetup; // skip default WFUT map setup

// map data info text (displayed by setup menu)
var() string SupportedMapsText; // text based list of supported maps
var() string MapDataText; // name of map pack, eg: "WF Map Data v1.0"
var() string MapDataInfoText; // any extra misc info, eg. "Author: .."

var WFMapData NextMapData;

final function bool HandleMapSetup(string MapName, WFMapSetupInfo MapSetupClass)
{
    if (HandleMapSetupFor(MapName, MapSetupClass))
        return bSkipDefaultMapSetup;
    else if (NextMapData != None)
        return NextMapData.HandleMapSetup(MapName, MapSetupClass);

    return false;
}

final function bool HandlePostMapSetup(string MapName, WFMapSetupInfo MapSetupClass)
{
    if (HandlePostMapSetupFor(MapName, MapSetupClass))
        return true;
    else if (NextMapData != None)
        return NextMapData.HandlePostMapSetup(MapName, MapSetupClass);

    return false;
}

function AddMapData(WFMapData NewMapData)
{
	if (NewMapData == None)
		return;

	if (NextMapData != None)
		NextMapData.AddMapData(NewMapData);
	else NextMapData = NewMapData;
}

// return true to prevent other map data classes from modifying the map
function bool HandleMapSetupFor(string MapName, WFMapSetupInfo MapSetupClass)
{
	return false; // implement in sub-class
}

// return true to prevent other map data classes from modifying the map
function bool HandlePostMapSetupFor(string MapName, WFMapSetupInfo MapSetupClass)
{
	return false; // implement in sub-class
}

// === Map setup functions ===

// spawn a supply pack with default info setup
function Ladder AddSupplyPackInfo(vector NewLocation, optional int TeamFlags)
{
	local Ladder L;
	L = spawn(class'LadderDM',,, NewLocation);
	if (L != None)
	{
		L.RemoteRole = ROLE_None;
		L.MapPrefix = "Supply_Pack";
		L.Matches = 0; // clear item flags (important)
		L.TimeLimits[5] = TeamFlags;
	}
	else Log("WARNING: failed to spawn 'Supply_Pack' info class at: "$NewLocation);
	return L;
}

// remove all inventory from a map
function RemoveMapInventory()
{
	local inventory Inv;
	local int count;

	Log("Removing all inventory items from map...");
	count = 0;
	foreach AllActors(class'Inventory', Inv)
	{
		if ((Inv != None) && !Inv.bDeleteMe && !Inv.IsA('WFSupplyPack'))
		{
			Inv.Destroy();
			count++;
		}
	}
	Log(count$" inventory items removed");
}

defaultproperties
{
	RemoteRole=ROLE_None
}