//=============================================================================
// WFS_AutoCannonWeaponInfo.
//
// Can be used to set up the weapon properties of a WFS_PCSystemAutoCannon when its
// TechLevel is changed.
//=============================================================================
class WFS_AutoCannonWeaponInfo expands WFS_PCSystemInfo
	abstract;

// called after each tech level change
static function SetupAmmoLevels(WFS_PCSystemAutoCannon Other, pawn PlayerManager);

// called when the cannon changes tech level
static function TechLevelChanged(WFS_PCSystemAutoCannon Other);

// determine the maximum ammo for this slot
static function int GetMaxSlotAmmo(WFS_PCSystemAutoCannon Other, byte Slot)
{
	if (Other.AmmoTypes[Slot] != none)
		return Other.AmmoTypes[Slot].default.MaxAmmo * ((Other.TechLevel + 1) * 0.5);
}

// get ambient fire sound
static function sound GetAmbientFiringSound(WFS_PCSystemAutoCannon Other)
{
	return None;
}

// return a weapon slot number for an ammo type (-1 if not used for cannon)
static function int FindSlotForAmmo(WFS_PCSystemAutoCannon Other, ammo AmmoType)
{
	local int i;

	for (i=0; i<4; i++)
		if ((Other.AmmoTypes[i] != none) && ((Other.AmmoTypes[i] == AmmoType.class)
			|| (Other.AmmoTypes[i] == AmmoType.default.ParentAmmo)) )
			return i;

	return -1;
}

// used to determine if a player is within range for the current weapon slot
static function bool IsInWeaponRange(WFS_PCSystemAutoCannon Other, actor Target, byte WeaponSlot)
{
	return true;
}

// return false if muzzle flash should not be displayed
static function bool UseMuzzleFlash(WFS_PCSystemAutoCannon Other)
{
	return true;
}

// return true to handle calculating the shoot rotation (called for each weapon slot)
static function bool CalcShootRot(WFS_PCSystemAutoCannon Other, vector ProjStart, out rotator ShootRot)
{
	return false;
}

defaultproperties
{
}