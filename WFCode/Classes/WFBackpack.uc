//=============================================================================
// WFBackpack.
//=============================================================================
class WFBackpack extends TournamentPickup;

// team constants
const TEAM_Any = 0;
const TEAM_Red = 1;
const TEAM_Blue = 2;
const TEAM_Green = 4;
const TEAM_Gold = 8;

var() int TeamFlags; // the teams that can collect the backpack

var() class<ammo> AmmoTypes[16];
var() float AmmoAmounts[16];

var() float ResourceAmount;
var() float ArmorAmount;

// used in AddInventoryFrom() to setup ResourceAmount
var() float MinSalvageRatio; // minimum percent of armor salvaged from the pack (0.0 - 1.0)
var() float MaxSalvageRatio; // maximum percent of armor salvaged from the pack (0.0 - 1.0)

var() bool bAddGrenadeAmmo; // players grenades can be increased
var() bool bAllGrenadeTypes; // adds 'NumGrenades' to each of the players grenade types
var() name GrenadeTypes[16]; // the types of grenade that are increased
var() int NumGrenades; // amount that grenades are increased by
var() int MaxGrenades; // maximum grenades allowed to be carried by a player

var() bool bAlwaysAllowPickup;

// Call this function after creating a backpack to set up the ammo and resource amounts.
function AddInventoryFrom(pawn Other)
{
	local int num, grentypes;
	local inventory Item;

	num = 0;
	grentypes = 0;
	Item = Other.Inventory;
	while (Item != None)
	{
		if (Item.IsA('Ammo') && !Item.IsA('WFRechargingAmmo') && (num < ArrayCount(AmmoTypes)) && (ammo(Item).AmmoAmount > 0))
		{
			AmmoTypes[num] = class<ammo>(Item.class);
			AmmoAmounts[num] = ammo(Item).AmmoAmount;
			num++;
		}

		// add some resources
		if (Item.IsA('WFS_PCSArmor'))
			ResourceAmount = WFS_PCSArmor(Item).MaxCharge * FClamp(FRand(), MinSalvageRatio, MaxSalvageRatio);

		if (Item.IsA('WFS_PCSGrenadeItem'))
		{
			GrenadeTypes[grentypes] = Item.class.name;
			grentypes++;
		}

		Item = Item.Inventory;
	}
}

function bool AddAmmoType(class<ammo> NewType, int AmmoAmount)
{
	local int i;
	for (i=0; i<ArrayCount(AmmoTypes); i++)
	{
		if (AmmoTypes[i] == NewType)
			return false; // ammo type already in list
		else if (AmmoTypes[i] == None)
		{
			AmmoTypes[i] = NewType;
			AmmoAmounts[i] = AmmoAmount;
			return true;
		}
	}
	return false;
}

function bool HasAmmoType(class<ammo> AmmoClass)
{
	local int i;
	for (i=0; i<ArrayCount(AmmoTypes); i++)
		if ((AmmoTypes[i] != None) && (AmmoTypes[i] == AmmoClass))
			return true;

	return false;
}

auto state Pickup
{
	function Touch(actor Other)
	{
		if ( ValidTouch(Other) && CanPickup(pawn(Other)) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			if ( PickupMessageClass == None )
				Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			else
				Pawn(Other).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );
			PlaySound(PickupSound,,2.0);
			PickupFunction(Pawn(Other));
			SetRespawn();
		}
	}

	// Landed on ground.
	simulated function Landed(Vector HitNormal)
	{
		local rotator newRot;

		newRot = Rotation;
		newRot.pitch = 0;
		SetRotation(newRot);
		if ( Role == ROLE_Authority )
		{
			bSimFall = false;
			if (bRotatingPickup)
				SetPhysics(PHYS_Rotating);
			SetTimer(2.0, false);
		}
	}
}

function PickupFunction(pawn Other)
{
	local int i;
	local inventory Item;
	local ammo AmmoInv;
	local WFS_PCSArmor ArmorInv;
	local class<WFS_PlayerClassInfo> PCI;

	// add any valid ammo types that the pack contains and set the AmmoAmount to 0
	PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
	AmmoInv = None;
	for (i=0; i<ArrayCount(AmmoTypes); i++)
	{
		if ((AmmoTypes[i] != None) && ((PCI == None) || PCI.static.ValidInventoryType(Other, AmmoTypes[i]))
			&& (Other.FindInventoryType(AmmoTypes[i]) == None)
			&& (Other.FindInventoryType(AmmoTypes[i].default.ParentAmmo) == None))
		{
			if (AmmoTypes[i].default.ParentAmmo != None)
				AmmoInv = spawn(AmmoTypes[i].default.ParentAmmo,,, Other.Location);
			else AmmoInv = spawn(AmmoTypes[i],,, Other.Location);
			if (AmmoInv != None)
			{
				Other.AddInventory(AmmoInv);
				AmmoInv.BecomeItem();
				AmmoInv.AmmoAmount = 0;
				AmmoInv.GotoState('Idle2');
			}
		}
	}

	AmmoInv = None;
	for (Item=Other.Inventory; Item!=None; Item=Item.Inventory)
	{
		if (Item != None)
		{
			// increase ammo levels
			if (Item.IsA('Ammo'))
			{
				AmmoInv = Ammo(Item);
				for (i=0; i<ArrayCount(AmmoTypes); i++)
					if ( (AmmoTypes[i] != None) && ((AmmoInv.class == AmmoTypes[i])
						|| (AmmoTypes[i].default.ParentAmmo == AmmoInv)) )
						AmmoInv.AddAmmo(AmmoAmounts[i]);
			}

			// add salvaged resources
			if (Item.class == class'WFEngineerResource')
				ammo(Item).AddAmmo(ResourceAmount);

			// add armor
			if (Item.IsA('WFS_PCSArmor'))
			{
				ArmorInv = WFS_PCSArmor(Item);
				if (ArmorInv != None)
					ArmorInv.AddArmor(ArmorAmount);
			}

			// add grenades
			if (bAddGrenadeAmmo && Item.IsA('WFS_PCSGrenadeItem') && IsValidGrenadeType(Item.class.name))
				pickup(Item).NumCopies = Min(pickup(Item).Charge + NumGrenades, MaxGrenades-1);
		}
	}
}

function bool IsValidGrenadeType(name GrenType)
{
	local int i;

	if (bAllGrenadeTypes)
		return true;

	for (i=0; i<ArrayCount(GrenadeTypes); i++)
		if (GrenadeTypes[i] == GrenType)
			return true;

	return false;
}

function bool ValidTeam(byte Team)
{
	return (TeamFlags == 0) || bool(TeamFlags & (2**Team));
}

function DropFrom(vector StartLocation)
{
	bSimFall = true;
	//if ( !SetLocation(StartLocation) )
	//	return;
	RespawnTime = 0.0; //don't respawn
	LifeSpan = 60.0; // disappear after 1 minute
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	BecomePickup();
	NetPriority = 2.5;
	bCollideWorld = true;
	if ( Pawn(Owner) != None )
		Pawn(Owner).DeleteInventory(self);
	Inventory = None;
	GotoState('PickUp', 'Dropped');
}


function bool CanPickup(pawn Other)
{
	if (Other == None)
		return false;

	if (!ValidTeam(Other.PlayerReplicationInfo.Team))
		return false;

	if (bAlwaysAllowPickup)
		return true;

	// don't allow collection if player maxed out
	if (AmmoMaxed(Other))
		return false;

	return true;
}

function bool AmmoMaxed(pawn Other)
{
	local inventory Item;
	local ammo AmmoInv;
	local WFS_PCSGrenadeItem Gren;
	local bool bMaxedOut;
	local int i;
	local class<WFS_PlayerClassInfo> PCI;

	// - check if player is carrying all allowed ammo types
	PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
	for (i=0; i<ArrayCount(AmmoTypes); i++)
	{
		if ((AmmoTypes[i] != None) && ((PCI == None) || PCI.static.ValidInventoryType(Other, AmmoTypes[i]))
			&& (Other.FindInventoryType(AmmoTypes[i]) == None)
			&& (Other.FindInventoryType(AmmoTypes[i].default.ParentAmmo) == None))
				return false;
	}

	// - check if all ammo is at max amount
	for (Item = Other.Inventory; Item != None; Item = Item.Inventory)
	{
		if (Item.IsA('Ammo') && IsValidAmmoType(class<ammo>(Item.class)))
		{
			AmmoInv = Ammo(Item);
			if ((AmmoInv != None) && (AmmoInv.AmmoAmount < AmmoInv.MaxAmmo))
				return false;
		}
		else if ((NumGrenades > 0) && Item.IsA('WFS_PCSGrenadeItem'))
		{
			// check grenades
			if (pickup(Item).NumCopies+1 < MaxGrenades)
				return false;
		}
		else if ((ArmorAmount > 0) && Item.IsA('WFS_PCSArmor'))
		{
			if (Item.Charge < WFS_PCSArmor(Item).MaxCharge)
				return false;
		}
		else if ((ResourceAmount > 0) && Item.IsA('WFEngineerResource'))
		{
			AmmoInv = Ammo(Item);
			if (AmmoInv.AmmoAmount < AmmoInv.MaxAmmo)
				return false;
		}
	}

	return true;
}

function float BotDesireability(pawn Bot)
{
	if (!CanPickup(Bot))
		return -1;

	return super.BotDesireability(Bot);
}

// returns true if AmmoClass is increased by this pack
function bool IsValidAmmoType(class<ammo> AmmoClass)
{
	local int i;

	for (i=0; i<ArrayCount(AmmoTypes); i++)
		if ((AmmoTypes[i] != None) && (AmmoTypes[i] == AmmoClass))
			return true;

	return false;
}

defaultproperties
{
	bDisplayableInv=True
	PickupMessage="You picked up a Backpack."
	ItemName="Backpack"
	RespawnTime=30.000000
	MaxDesireability=2.000000
	PickupSound=Sound'Botpack.Pickups.AmmoPick'
	//PickupViewMesh=Mesh'UnrealShare.WeaponPowerUpMesh'
	PickupViewMesh=LodMesh'WFMedia.WF_Backpack'
	//AnimSequence=AnimEnergy
	Mesh=Mesh'WFMedia.WF_Backpack'
	CollisionRadius=22.000000
	CollisionHeight=11.000000
	//bMeshEnviroMap=True
	//Texture=texture'JDomN0'
	AmbientGlow=64
	MinSalvageRatio=0.050000
	MaxSalvageRatio=0.250000
	bRotatingPickup=True
	bToggleSteadyFlash=True
	bAlwaysAllowPickup=True
	MaxGrenades=2
}