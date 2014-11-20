//=============================================================================
// WFS_TestSniperInv.
//=============================================================================
class WFS_TestSniperInv extends WFS_InventoryInfo;

static function ModifyWeapon(weapon NewWeapon)
{
	if (NewWeapon.class == class'SniperRifle')
		NewWeapon.AmmoType.AmmoAmount = 50;
}

defaultproperties
{
	Weapons(0)=class'SniperRifle'
	Pickups(0)=class'ThighPads'
}