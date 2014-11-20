//=============================================================================
// WFFieldMedicInv.
//=============================================================================
class WFFieldMedicInv extends WFInventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if (NewWeapon.class == class'WFBiorifle')
		NewWeapon.AmmoType.AddAmmo(25);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenPlague')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFMedKit'
	Weapons(1)=class'WFMachineGun'
	Weapons(2)=class'WFBioRifle'
	Pickups(0)=class'WFAutoDoc'
	Pickups(1)=class'WFGrenFrag'
	Pickups(2)=class'WFGrenPlague'
}