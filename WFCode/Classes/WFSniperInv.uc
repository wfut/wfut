//=============================================================================
// WFSniperInv.
//=============================================================================
class WFSniperInv extends WFInventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if ((newWeapon.class == class'WFEnforcer') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(25);

	//if ((newWeapon.class == class'WFAutoRifle') && (newWeapon.AmmoType != none))
	//	newWeapon.AmmoType.AddAmmo(25);

	if (NewWeapon.class == class'WFSniperRifle')
		NewWeapon.AmmoType.AddAmmo(10);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFEnforcer'
	//Weapons(1)=class'WFAutoRifle'
	Weapons(1)=class'WFSniperRifle'
	Pickups(0)=class'WFGrenFrag'
}