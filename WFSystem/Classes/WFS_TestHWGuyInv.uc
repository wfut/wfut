//=============================================================================
// WFS_TestHWGuyInv.
//=============================================================================
class WFS_TestHWGuyInv extends WFS_InventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if (NewWeapon.class == class'minigun2')
		NewWeapon.AmmoType.AddAmmo(150);

	if (NewWeapon.class == class'UT_FlakCannon')
		NewWeapon.AmmoType.AddAmmo(20);
}

defaultproperties
{
	Weapons(0)=class'minigun2'
	Weapons(1)=class'UT_FlakCannon'
}
