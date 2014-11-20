//=============================================================================
// WFDemoManInv.
//=============================================================================
class WFDemoManInv extends WFInventoryInfo;

static function ModifyWeapon(weapon newWeapon)
{
	if ((newWeapon.class == class'WFMiniFlak') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(10);

	if ((newWeapon.class == class'WFPipeBombLauncher') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(12);

	if ((newWeapon.class == class'WFGrenadeLauncher') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(12);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades
	if (NewPickup.class == class'WFGrenFreeze')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFMiniFlak'
	Weapons(1)=class'WFPipeBombLauncher'
	Weapons(2)=class'WFGrenadeLauncher'
	Pickups(0)=class'WFGrenFrag'
	Pickups(1)=class'WFGrenFreeze'
}