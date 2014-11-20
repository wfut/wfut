//=============================================================================
// WFInfiltratorInv.
//=============================================================================
class WFInfiltratorInv extends WFInventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if ((newWeapon.class == class'WFInfiltratorEnforcer') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(25);
}

static function ModifyPickup(pickup NewPickup)
{
	if (NewPickup.class == class'WFGrenFrag')
		NewPickup.NumCopies = 1; // start with 2 grenades

	if (NewPickup.class == class'WFGrenFlash')
		NewPickup.NumCopies = 1; // start with 2 grenades
}

defaultproperties
{
	Weapons(0)=class'WFTaser'
	Weapons(1)=class'WFInfiltratorEnforcer'
	Pickups(0)=class'WFCloaker'
	Pickups(1)=class'WFDisguise'
	Pickups(2)=class'WFGrenFrag'
	Pickups(3)=class'WFGrenFlash'
	//ickups(1)=class'WFWallGrenade'
}