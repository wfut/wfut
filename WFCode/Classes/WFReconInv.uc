//=============================================================================
// WFReconInv.
//=============================================================================
class WFReconInv extends WFInventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	//if ((newWeapon.class == class'WFMiniFlak') && (newWeapon.AmmoType != none))
	//	newWeapon.AmmoType.AddAmmo(10);

	if ((NewWeapon.class == class'WFDoubleEnforcer') && (NewWeapon.AmmoType != None))
		NewWeapon.AmmoType.AddAmmo(50);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenConc')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFReconDefenseUnit'
	//Weapons(1)=class'WFMiniFlak'
	Weapons(1)=class'WFDoubleEnforcer'
	Pickups(0)=class'WFGrenFrag'
	Pickups(1)=class'WFGrenConc'
	Pickups(2)=class'WFThrustPack'
}