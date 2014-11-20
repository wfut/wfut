//=============================================================================
// WFS_PlayerClassInfo.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFS_PlayerClassInfo extends WFS_PCSystemInfo
	abstract;

var() string 					ClassName;		  // Display name of the class
var() string					ClassNamePlural;  // Name used to refer to more than on of this class
var() string					ShortName;		  // Optional name abbreviation

var() class<WFD_PlayerPawnMeshInfo>	MeshInfo;		  // DPMS Mesh info class used for PLAYERS.
var() class<WFD_BotMeshInfo>		AltMeshInfo;	  // DPMS Mesh info class used for BOTS.
var() class<WFD_DPMSSoundInfo>		SoundInfo;		  // Optional DPMS sound info class (set to None to use the MeshInfo default)

var() class<WFS_InventoryInfo>		DefaultInventory; // List of default inventory.
var() bool						bNoTranslocator;  // Translocator not allowed.
var() bool						bAllowFeignDeath; // Allow player to use the 'feigndeath' command

var() class<WFS_HUDInfo>			ExtendedHUD;	  // Extended hud class.
var() class<WFS_HUDMenuInfo>		HUDMenu;		  // Optional HUDMenu class.

// Health properties
var() int						Health;			  // Default starting health.
var() int						MaxHealth;		  // Maximum reachable health.

// Armor related properties.
// -------------------------
// Set the percent ArmorAbsorption as well as Armor amount to indicate how
// much damage is absorbed by the armor (default ArmorAbsorption is 50%).
//
// Also, add code to accept armor as valid inventory to ValidInventoryType() if
// you want players to be allowed to collect armor during a game (armor will not go
// above the default value).
//
// eg. To accept all items that are armor items (bIsAnArmor set to true) then add
//     something like the following to ValidInventoryType():
//
// if (ItemClass.default.bIsAnArmor && (default.Armor > 0))
//     return true;
//
var() int						Armor;			  // Amount of starting armor.
var() int						MaxArmor;		  // Maximum armor allowed (if different from Armor value).
var() name						ProtectionType1;  // Protects against DamageType (None if non-armor).
var() name						ProtectionType2;  // Secondary protection type (None if non-armor).
var() int						ArmorAbsorption;  // Percent of damage absorbed by armor 0-100.

var() class<WFS_PCSArmor>		ArmorManagerClass;

var() string					ClassDescription;

var() string					ClassSkinName;
var() string					ClassFaceName;

var() string					VoiceType;

struct SClassBindings
{
	var() string Command;       // the actual binding
	var() string Description;   // a description of the binding
};

var() SClassBindings ClassBindings[20];

var() int NumClassBindings;

//-----------------------------------------------------------------------------
// Player Setup and Special Ability Functions.

// called by the server to set up player properties (health, speed, etc)
static function InitialisePlayer(pawn Other)
{
	Other.Health = default.Health;
	ModifyPlayer(Other);
}

// implement in sub-class to set up a player properties (speed, jumpheight, etc)
// (called after the game and any mutators have modified the player, every time
// the player restarts)
static function ModifyPlayer(pawn Other);

// resets a players properties back to the defualt values
// (called before changing to a new PCI class)
static function ResetPlayer(pawn Other)
{
	Other.Health = Other.default.Health;
	Other.DamageScaling = Other.default.DamageScaling;

	Other.GroundSpeed = Other.default.GroundSpeed;
	Other.WaterSpeed = Other.default.WaterSpeed;
	Other.AirSpeed = Other.default.AirSpeed;
	Other.AccelRate = Other.default.AccelRate;

	Other.MaxStepHeight = Other.default.MaxStepHeight;
	Other.UnderWaterTime = Other.default.UnderWaterTime;
	Other.Mass = Other.default.Mass;
	Other.Fatness = Other.default.Fatness;
	Other.Visibility = Other.default.Visibility;
	Other.JumpZ = Other.default.JumpZ;

	Other.AirControl = DeathMatchPlus(Other.Level.Game).AirControl;
}

// function router for player class abilities
static function DoSpecial(pawn Other, string SpecialString, optional name Type);

// use to allow a command to be executed clientside
static function bool IsClientSideCommand(string SpecialString)
{
	return false;
}

//-----------------------------------------------------------------------------
// Inventory Related Functions.

static function AddDefaultInventory(actor GameActor, pawn Other)
{
	local Inventory Inv;

	// remove translocator if not allowed for this class
	for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.IsA('Translocator') && default.bNoTranslocator)
		{
			Other.DeleteInventory(Inv);
			if (Other.IsA('Bot') && (bot(Other).MyTranslocator == Inv))
				bot(Other).MyTranslocator = None;
			Inv.Destroy();
		}
	}

	// add default inventory for this class
	if (default.DefaultInventory != none)
		default.DefaultInventory.static.AddInventory(GameActor, Other);

	// set up the players starting armor
	if (default.Armor > 0)
		AddDefaultArmor(GameActor, Other);
}

// set up a players default armor
static function AddDefaultArmor(actor GameActor, pawn Other)
{
	local WFS_PCSArmor a;

	a = GameActor.spawn(default.ArmorManagerClass);
	if (a != None)
	{
		a.Charge = default.Armor;
		if (default.MaxArmor > 0) a.MaxCharge = default.MaxArmor;
		else a.MaxCharge = default.Armor;
		a.ProtectionType1 = default.ProtectionType1;
		a.ProtectionType2 = default.ProtectionType2;
		a.ArmorAbsorption = default.ArmorAbsorption;
		a.GiveTo(Other);
	}
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	// implement in sub-class
	return true;
}

// called before a player collects an item (return false to abort pickup)
static function bool ValidPickup(pawn Other, inventory Item)
{
	if (ValidInventoryType(Other, Item.Class))
		return true;

	return false;
}

// Called before Inventory.HandlePickupQuery().
// Gives the WFS_PlayerClassInfo a chance to deal with an item pickup query before the
// players inventory. Return true to handle pickup, false to allow the players
// inventory to deal with the pickup query.
static function bool HandlePickupQuery(Pawn Other, Inventory item);

// function to handle standard health pickups
static function HandleHealthPickup(pawn Other, Inventory item)
{
	// limit the amount of health gained
	if (Item.IsA('TournamentHealth'))
	{
		// don't allow non-superheal health pickup if health already at default for
		// this player class
		if ((Other.Health >= default.Health) && !TournamentHealth(Item).bSuperHeal)
			return;

		if ((Other.Health >= default.MaxHealth) && TournamentHealth(Item).bSuperHeal)
			return;

		// handle pickup for this player class
		if ( !TournamentHealth(Item).bSuperHeal && (Other.Health < default.Health) )
		{
			// increase health
			if ((Other.Health + TournamentHealth(Item).HealingAmount) > default.Health)
				Other.Health = default.Health;
			else Other.Health += TournamentHealth(Item).HealingAmount;
		}
		else if (TournamentHealth(Item).bSuperHeal)
		{
			// increase health
			if ((Other.Health + TournamentHealth(Item).HealingAmount) > default.MaxHealth)
				Other.Health = default.MaxHealth;
			else Other.Health += TournamentHealth(Item).HealingAmount;
		}

		if (Other.Level.Game.LocalLog != None)
			Other.Level.Game.LocalLog.LogPickup(Item, Other);
		if (Other.Level.Game.WorldLog != None)
			Other.Level.Game.WorldLog.LogPickup(Item, Other);
		TournamentHealth(Item).PlayPickupMessage(Other);
		Item.PlaySound(Item.PickupSound,,2.5);
		Other.MakeNoise(0.2);
		Item.SetRespawn();
	}
}

//-----------------------------------------------------------------------------
// Player Notifications.

static function PlayerChangingClass(pawn Other, class<WFS_PlayerClassInfo> NewClass)
{
	DestroyAllRelatedActors(Other);
}
static function PlayerTakeDamage(pawn Other, out int Damage, out Pawn instigatedBy,	out vector hitlocation, out vector momentum, out name damageType, out byte bIgnoreDamage);
static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation);
static function PlayerLeaving(pawn Exiting)
{
	DestroyAllRelatedActors(Exiting);
}
static function PlayerChangedTeam(pawn Other)
{
	DestroyAllRelatedActors(Other);
}

//-----------------------------------------------------------------------------
// Misc utility functions.

static function class<WFS_PlayerClassInfo> GetPCIFor(pawn Other)
{
	if (Other.IsA('WFS_PCSystemPlayer'))
		return WFS_PCSystemPlayer(Other).PCInfo;
	else if (Other.IsA('WFS_PCSystemBot'))
		return WFS_PCSystemBot(Other).PCInfo;

	return None;
}

//-----------------------------------------------------------------------------
// RelatedActor utility functions.

static function actor GetRelatedActor(pawn Other, int Index)
{
	local WFS_PCSystemPlayer PCSPlayer;
	local WFS_PCSystemBot PCSBot;

	PCSPlayer = WFS_PCSystemPlayer(Other);
	if (PCSPlayer != None)
		return PCSPlayer.RelatedActors[Index];

	PCSBot = WFS_PCSystemBot(Other);
	if (PCSBot != None)
		return PCSBot.RelatedActors[Index];

	return None;
}

static function SetRelatedActor(pawn Other, int Index, actor RelatedActor)
{
	local WFS_PCSystemPlayer PCSPlayer;
	local WFS_PCSystemBot PCSBot;

	PCSPlayer = WFS_PCSystemPlayer(Other);
	if (PCSPlayer != None)
		PCSPlayer.RelatedActors[Index] = RelatedActor;

	PCSBot = WFS_PCSystemBot(Other);
	if (PCSBot != None)
		PCSBot.RelatedActors[Index] = RelatedActor;
}

static function int RelatedActorCount(pawn Other, class<Actor> SearchClass, optional bool bIncludeSubClasses)
{
	local int i, count;
	local actor RelatedActor;

	if (SearchClass == none)
		return RelatedActorFreeSlotCount(Other);

	count = 0;
	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ((RelatedActor != none) && !RelatedActor.bDeleteMe)
		{
			if (bIncludeSubClasses)
			{
				if (RelatedActor.IsA(SearchClass.name))
					count++;
			}
			else
			{
				if (RelatedActor.Class == SearchClass)
					count++;
			}
		}
	}

	return count;
}

static function bool AddRelatedActor(pawn Other, actor newActor)
{
	local int i;
	local actor RelatedActor;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ((RelatedActor == none) ||
			((RelatedActor != none) && RelatedActor.bDeleteMe))
		{
			SetRelatedActor(Other, i, newActor);
			return true;
		}
	}

	return false;
}

static function actor FindRelatedActorClass(pawn Other, class<actor> SearchClass, optional name Tag)
{
	local int i;
	local actor RelatedActor;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ((RelatedActor != none) && !RelatedActor.bDeleteMe)
		{
			if (RelatedActor.Class == SearchClass)
			{
				return RelatedActor;
			}
		}
	}

	return None;
}

static function bool RemoveRelatedActor(pawn Other, actor RemoveActor)
{
	local int i;
	local actor RelatedActor;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if (RelatedActor == RemoveActor)
		{
			RelatedActor = None;
			return true;
		}
	}

	return false;
}

static function int RelatedActorFreeSlotCount(pawn Other)
{
	local int i, count;
	local actor RelatedActor;

	count = 0;
	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ( (RelatedActor == none) || ((RelatedActor != none) && RelatedActor.bDeleteMe) )
			count++;
	}

	return count;
}

static function DestroyRelatedActorClass(pawn Other, class<actor> SearchClass, optional bool bIncludeSubClasses)
{
	local int i;
	local actor RelatedActor;

	if (SearchClass == none)
		return;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ((RelatedActor != none) && !RelatedActor.bDeleteMe)
		{
			if (bIncludeSubClasses)
			{
				if (RelatedActor.IsA(SearchClass.name))
					RelatedActor.Destroy();
			}
			else if (RelatedActor.Class == SearchClass)
			{
				RelatedActor.Destroy();
			}
		}
	}
}

static function bool IsOnRelatedActorList(pawn Other, actor SearchActor)
{
	local int i;
	local actor RelatedActor;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if (RelatedActor == SearchActor)
			return true;
	}

	return false;
}

static function DestroyAllRelatedActors(pawn Other)
{
	local int i;
	local actor RelatedActor;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ((RelatedActor != none) && !RelatedActor.bDeleteMe)
			RelatedActor.Destroy();
	}
}

defaultproperties
{
	Health=100
	MaxHealth=199
	bAllowFeignDeath=True
	ArmorManagerClass=class'WFS_PCSArmor'
	ArmorAbsorption=50
}