//=============================================================================
// WFS_InventoryInfo.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFS_InventoryInfo extends WFS_PCSystemInfo
	abstract;

// inventory lists
var() class<Weapon> Weapons[32];
var() class<Pickup> Pickups[32];

var() class<Inventory> Items[32];

// use GameActor to add items to PawnOther
static function AddInventory(actor GameActor, pawn PawnOther)
{
	local int i;
	local inventory item;

	// add weapons
	for (i=0; i<32; i++)
		if (default.Weapons[i] != none)
			GiveWeapon(GameActor, PawnOther, default.Weapons[i]);

	// add pickup items
	for (i=0; i<32; i++)
		if (default.Pickups[i] != none)
			GivePickup(GameActor, PawnOther, default.Pickups[i]);

	// add other items
	for (i=0; i<32; i++)
		if (default.Items[i] != none)
			GiveItem(GameActor, PawnOther, default.Items[i]);
}

// slightly modified DMPlus GiveWeapon() function
static function GiveWeapon(Actor GameActor, Pawn PlayerPawn, class<Weapon> WeaponClass)
{
	local Weapon NewWeapon;

	if( PlayerPawn.FindInventoryType(WeaponClass) != None )
		return;
	newWeapon = GameActor.Spawn(WeaponClass,,,PlayerPawn.Location);
	if( newWeapon != None )
	{
		if (CustomWeaponSetup(PlayerPawn, newWeapon))
			return;
		newWeapon.RespawnTime = 0.0;
		newWeapon.GiveTo(PlayerPawn);
		newWeapon.bHeldItem = true;
		newWeapon.GiveAmmo(PlayerPawn);
		newWeapon.SetSwitchPriority(PlayerPawn);
		newWeapon.WeaponSet(PlayerPawn);
		newWeapon.AmbientGlow = 0;
		if ( PlayerPawn.IsA('PlayerPawn') )
			newWeapon.SetHand(PlayerPawn(PlayerPawn).Handedness);
		else
			newWeapon.GotoState('Idle');
		PlayerPawn.Weapon.GotoState('DownWeapon');
		PlayerPawn.PendingWeapon = None;
		PlayerPawn.Weapon = newWeapon;
		ModifyWeapon(newWeapon);
	}
}

static function GivePickup(Actor GameActor, Pawn PlayerPawn, class<Pickup> PickupClass)
{
	local pickup newPickup;
	newPickup = GameActor.Spawn(PickupClass,,,PlayerPawn.Location);
	if( newPickup != None )
	{
		if (CustomPickupSetup(PlayerPawn, newPickup))
			return;
		newPickup.bHeldItem = true;
		newPickup.RespawnTime = 0.0;
		newPickup.GiveTo(PlayerPawn);
		newPickup.PickupFunction(PlayerPawn);
		// activate the new pickup if needed
		if (newPickup.bActivatable && newPickup.bAutoActivate && PlayerPawn.bAutoActivate)
			newPickup.GotoState('Activated');
		ModifyPickup(newPickup);
	}
}

static function GiveItem(Actor GameActor, Pawn PlayerPawn, class<Inventory> ItemClass)
{
	local Inventory newItem;
	newItem = GameActor.Spawn(ItemClass,,,PlayerPawn.Location);
	if( newItem != None )
	{
		if (CustomItemSetup(PlayerPawn, newItem))
			return;
		newItem.bHeldItem = true;
		newItem.RespawnTime = 0.0;
		newItem.GiveTo(PlayerPawn);
		ModifyItem(newItem);
	}
}

// don't use default inventory setup for this item (return true to abort default setup)
static function bool CustomWeaponSetup(pawn PlayerPawn, weapon newWeapon)
{
	return false;
}

static function bool CustomPickupSetup(pawn PlayerPawn, pickup newPickup)
{
	return false;
}

static function bool CustomItemSetup(pawn PlayerPawn, inventory newPickup)
{
	return false;
}


// can use these functions to further set up new items
static function ModifyWeapon(weapon newWeapon);
static function ModifyPickup(pickup newPickup);
static function ModifyItem(inventory newPickup);

// used to query inventory
static function bool IsDefaultInventory(class<inventory> ItemClass)
{
	local class<ammo> a;
	local bool bIsAmmo;
	local int i;

	bIsAmmo = false;
	if (ClassIsChildOf(ItemClass,class'Ammo'))
	{
		a = class<ammo>(ItemClass);
		bIsAmmo = true;
	}

	for (i=0; i<32; i++)
	{
		if ((default.Weapons[i] != none) && (ItemClass == default.Weapons[i]))
			return true;

		if ((default.Pickups[i] != none) && (ItemClass == default.Pickups[i]))
			return true;

		if ((default.Items[i] != none) && (ItemClass == default.Items[i]))
			return true;

 		if (bIsAmmo)
		{
			if (default.Weapons[i] != none)
			{
				if ((default.Weapons[i].default.AmmoName == a) || (default.Weapons[i].default.AmmoName == a.default.ParentAmmo))
					return true;
			}
		}
	}

	return false;
}

static function bool IsDefaultWeapon(class<inventory> ItemClass)
{
	local int i;

	for (i=0; i<32; i++)
		if (ItemClass == default.Weapons[i])
			return true;

	return false;
}

defaultproperties
{
}