//=============================================================================
// WFSupplyPack.
//
// TODO:
// - Needs to be more configurable for map creators.
//=============================================================================
class WFSupplyPack extends WFBackpack;

const ITEM_UDamage = 1;
const ITEM_Invisibility = 2;
const ITEM_JumpBoots = 4;

const ITEM_HealthVial = 8;
const ITEM_HealthPack = 16;
const ITEM_SuperHealth = 32;

const ITEM_CustomHealth = 64;
const ITEM_CustomSuperHealth = 128;

var() int ItemFlags;

var() int CustomHealth;
var() int DefaultAmmoAmount; // default amount given to an unlisted ammo type

function PickupFunction(pawn Other)
{
	super.PickupFunction(Other);

	if (bool(ItemFlags & ITEM_UDamage))
		GivePickup(Other, class'UDamage');

	if (bool(ItemFlags & ITEM_Invisibility))
		GivePickup(Other, class'UT_Invisibility');

	if (bool(ItemFlags & ITEM_JumpBoots))
		GivePickup(Other, class'UT_JumpBoots');

	if (bool(ItemFlags & ITEM_HealthVial))
		GiveHealth(Other, 5, true);

	if (bool(ItemFlags & ITEM_HealthPack))
		GiveHealth(Other, 20, false);

	if (bool(ItemFlags & ITEM_SuperHealth))
		GiveHealth(Other, 100, true);

	if (bool(ItemFlags & ITEM_CustomSuperHealth))
		GiveHealth(Other, CustomHealth, true);
	else if (bool(ItemFlags & ITEM_CustomHealth))
		GiveHealth(Other, CustomHealth, false);
}

function GivePickup(pawn Other, class<pickup> ItemClass)
{
	local pickup Item;

	if (ItemClass == None)
		return;

	Item = pickup(Other.FindInventoryType(ItemClass));
	if (Item != None)
	{
		if (Item.bCanHaveMultipleCopies)
			Item.NumCopies++;
		else if (Item.bDisplayableInv)
			Item.Charge = Item.default.Charge;
	}
	else
	{
		Item = spawn(ItemClass,,, Other.Location);
		if (Item != None)
		{
			Item.bHeldItem = true;
			Item.RespawnTime = 0.0;
			Item.GiveTo(Other);
			if (Item.bActivatable && Item.bAutoActivate && Other.bAutoActivate)
				Item.GotoState('Activated');
		}
	}
}

function GiveHealth(pawn Other, int Amount, bool bSuperHealth)
{
	local class<WFS_PlayerClassInfo> PCI;
	local int MaxHealth;

	if ((Other == None) || (Amount == 0))
		return;

	PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
	if (PCI != None)
	{
		if (bSuperHealth) MaxHealth = PCI.default.MaxHealth;
		else MaxHealth = PCI.default.Health;
	}
	else
	{
		if (bSuperHealth) MaxHealth = 199;
		else MaxHealth = 100;
	}

	if (Amount > 0)
	{
		if (Other.Health < MaxHealth)
			Other.Health = Min(Other.Health + Amount, MaxHealth);
	}
	else Other.TakeDamage(Amount*-1, None, vect(0,0,0), vect(0,0,0), '');
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
	if (ItemMaxed(Other) && AmmoMaxed(Other) && HealthMaxed(Other))
		return false;

	return true;
}

function bool HealthMaxed(pawn Other)
{
	local int MaxHealth;
	local class<WFS_PlayerClassInfo> PCI;

	MaxHealth = 0;
	PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
	if ( bool(ItemFlags & ITEM_HealthVial)
		|| bool(ItemFlags & ITEM_SuperHealth)
		|| bool(ItemFlags & ITEM_CustomSuperHealth) )
	{
		if (PCI != None)
			MaxHealth = PCI.default.MaxHealth;
		else MaxHealth = 199;
	}
	else if (bool(ItemFlags & ITEM_HealthPack)
		|| bool(ItemFlags & ITEM_CustomHealth) )
	{
		if (PCI != None)
			MaxHealth = PCI.default.Health;
		else MaxHealth = 100;
	}

	if (Other.Health < MaxHealth)
		return false;

	return true;
}

function bool ItemMaxed(pawn Other)
{
	if (bool(ItemFlags & ITEM_UDamage)
		|| bool(ItemFlags & ITEM_Invisibility)
		|| bool(ItemFlags & ITEM_JumpBoots))
			return false; // always give packs with items

	return true; // no items given
}

defaultproperties
{
	AmmoTypes(0)=class'BioAmmo'
	AmmoTypes(1)=class'BladeHopper'
	AmmoTypes(2)=class'BulletBox'
	AmmoTypes(3)=class'FlakAmmo'
	AmmoTypes(4)=class'MiniAmmo'
	AmmoTypes(5)=class'PAmmo'
	AmmoTypes(6)=class'RocketPack'
	AmmoTypes(7)=class'ShockCore'
	AmmoTypes(8)=class'WarheadAmmo'
	AmmoTypes(9)=class'WFASAmmo'
	AmmoTypes(10)=class'WFChainCannonAmmo'
    AmmoTypes(11)=Class'WFFlameThrowerAmmo'
	AmmoAmounts(0)=50
	AmmoAmounts(1)=35
	AmmoAmounts(2)=25
	AmmoAmounts(3)=25
	AmmoAmounts(4)=50
	AmmoAmounts(5)=50
	AmmoAmounts(6)=24
	AmmoAmounts(7)=25
	AmmoAmounts(8)=1
	AmmoAmounts(9)=5
	AmmoAmounts(10)=50
    AmmoAmounts(11)=25.000000
	ResourceAmount=50
	ArmorAmount=100
	DefaultAmmoAmount=20
	bAddGrenadeAmmo=True
	bAllGrenadeTypes=True
	NumGrenades=2
	MultiSkins(0)=Texture'WF_SupplyPackSkin'
	bAlwaysAllowPickup=False
	PickupMessage="You picked up a Supply Pack."
	ItemName="Supply Pack"
}
