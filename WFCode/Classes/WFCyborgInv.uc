//=============================================================================
// WFCyborgInv.
//=============================================================================
class WFCyborgInv extends WFInventoryInfo;

static function ModifyWeapon(weapon newWeapon)
{
	if ((newWeapon.class == class'WFMiniFlak') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(10);

	if ((newWeapon.class == class'WFPlazer') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(50);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenEMP')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFMiniFlak'
	Weapons(1)=class'WFASRocketLauncher'
	Weapons(2)=class'WFPlazer'
	Pickups(0)=class'WFGrenFrag'
	Pickups(1)=class'WFGrenEMP'
}