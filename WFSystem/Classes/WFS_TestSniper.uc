//=============================================================================
// WFS_TestSniper.
//=============================================================================
class WFS_TestSniper extends WFS_TestPCI;

static function InitialisePlayer(pawn Other)
{
	Other.DamageScaling = 1.9;
	Other.Mass = Other.default.Mass * 0.8;
	Other.Health = 80;
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if (default.DefaultInventory.static.IsDefaultInventory(ItemClass))
		return true;

	if (ItemClass == class'Enforcer')
		return true;

	if (ItemClass == class'ThighPads')
		return true;

	if (ItemClass == class'miniammo')
		return true;

	return false;
}

static function bool HandlePickupQuery(Pawn Other, Inventory item)
{
	local weapon w;
	local int amount;

	if (Item.IsA('Enforcer'))
	{
		w = weapon(Other.FindInventoryType(class'Enforcer'));
		if ((w != none) && (w.AmmoType != none))
		{
			w.AmmoType.AddAmmo(weapon(item).PickupAmmoCount);
			item.PlaySound(item.PickupSound);
			item.SetRespawn();
		}

		return true;
	}
}

defaultproperties
{
	ClassName="Sniper"
	ClassNamePlural="Snipers"
	Health=80
	ExtendedHUD=class'WFS_CTFHUDInfo'
	DefaultInventory=class'WFS_TestSniperInv'
}