//=============================================================================
// WFGunnerInv.
//=============================================================================
class WFGunnerInv extends WFInventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if (NewWeapon.class == class'WFChainCannon')
		NewWeapon.AmmoType.AddAmmo(50);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenDecloaker')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFEnforcer'
	Weapons(1)=class'WFminigun2'
	Weapons(2)=class'WFChainCannon'
	Pickups(0)=class'WFGrenFrag'
	Pickups(1)=class'WFGrenDecloaker'
}
