//=============================================================================
// WFPyrotechInv.
//=============================================================================
class WFPyrotechInv extends WFInventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if ((newWeapon.class == class'WFMiniFlak') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(10);

	if (NewWeapon.class == class'WFNapalmRL')
		NewWeapon.AmmoType.AddAmmo(12);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenFlame')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFMiniFlak'
	Weapons(1)=class'WFFlameThrower'
	Weapons(2)=class'WFNapalmRL'
	Pickups(0)=class'WFGrenFrag'
	Pickups(1)=class'WFGrenFlame'
}