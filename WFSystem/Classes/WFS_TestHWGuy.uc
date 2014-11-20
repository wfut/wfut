//=============================================================================
// WFS_TestHWGuy.
//=============================================================================
class WFS_TestHWGuy extends WFS_TestPCI;

static function ModifyPlayer(pawn Other)
{
	Other.GroundSpeed = Other.default.GroundSpeed * 0.5;
	Other.WaterSpeed = Other.default.WaterSpeed * 0.5;
	Other.AirSpeed = Other.default.AirSpeed * 0.5;
	Other.AccelRate = Other.default.AccelRate * 0.5;
	Other.AirControl = Other.default.AirControl * 0.5;
	Other.Fatness = 150;
	Other.Mass = Other.default.Mass * 1.5;
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if (default.DefaultInventory.static.IsDefaultInventory(ItemClass))
		return true;

	if (ItemClass == class'Enforcer')
		return true;

	if (ItemClass.default.bIsAnArmor)
		return true;

	return false;
}

static function bool HandlePickupQuery(Pawn Other, Inventory item)
{
	local weapon w;

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
	ClassName="Heavy Weapons Guy"
	ClassNamePlural="Heavy Weapons Guys"
	ShortName="HWGuy"
	DefaultInventory=class'WFS_TestHWGuyInv'
	ExtendedHUD=class'WFS_CTFHUDInfo'
	Health=200
	MaxHealth=300
	Armor=200
	ArmorAbsorption=75
	bNoTranslocator=true
}