//=============================================================================
// WFS_TestEngineerInv.
//=============================================================================
class WFS_TestEngineerInv extends WFS_InventoryInfo;

static function ModifyWeapon(weapon newWeapon)
{
	if ((newWeapon.class == class'ShockRifle') && (newWeapon.AmmoType != none))
		newWeapon.AmmoType.AddAmmo(20);
}

defaultproperties
{
	Weapons(0)=class'ShockRifle'
	Pickups(1)=class'EClip'
}
