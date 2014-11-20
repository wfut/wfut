//=============================================================================
// WFEngineerInv.
//=============================================================================
class WFEngineerInv extends WFInventoryInfo;

static function ModifyWeapon(weapon newWeapon)
{
	if ((newWeapon.class == class'WFMiniFlak') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(10);

	if ((newWeapon.class == class'WFTeslaCoil') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(25);

	if ((newWeapon.class == class'WFRailGun') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(10);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenShock')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFRoboticHand'
	Weapons(1)=class'WFTeslaCoil'
	Weapons(2)=class'WFRailGun'
	Pickups(0)=class'WFEngineerResource'
	Pickups(1)=class'WFGrenFrag'
	Pickups(2)=class'WFGrenShock'
}
