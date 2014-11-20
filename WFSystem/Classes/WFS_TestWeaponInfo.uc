//=============================================================================
// WFS_TestWeaponInfo.
//=============================================================================
class WFS_TestWeaponInfo expands WFS_AutoCannonWeaponInfo;

// called when the cannon changes tech level
static function TechLevelChanged(WFS_PCSystemAutoCannon Other)
{
	if (Other.TechLevel >= 0)
	{
		Other.SlotDamage[0] = 9;
		Other.SlotDamage[1] = 1000;
		Other.RefireRate[0] = 0.1;
		Other.RefireRate[1] = 5.0;
		Other.FireSounds[1] = Sound'UnrealShare.ASMD.TazerFire';
		Other.bAlwaysHit[1] = 1;
		Other.AmmoTypes[0] = class'Miniammo';
		Other.AmmoTypes[1] = class'ShockCore';
		Other.DamageVariation[0] = 6;
		Other.AmmoUsed[0] = 1;
		Other.AmmoUsed[1] = 1;

		// set up starting ammo
		if (Other.AmmoAmount[0] < 100) Other.AmmoAmount[0] = 100;
		if (Other.AmmoAmount[1] < 15) Other.AmmoAmount[1] = 15;
	}

	if (Other.TechLevel >= 1)
	{
		Other.AmmoUsed[2] = 1;
		Other.RefireRate[2] = 0.25;
		Other.FireSounds[2] = Sound'UnrealI.BioRifle.GelShot';
		Other.ProjectileClass[2] = Class'Botpack.UT_BioGel';
		Other.AmmoTypes[2] = class'Botpack.bioammo';
		Other.bLeadTargetForSlot[2] = 1;
		if (Other.AmmoAmount[2] < 25) Other.AmmoAmount[2] = 25;
	}

	if (Other.TechLevel >= 2)
	{
		Other.AmmoUsed[3] = 1;
		Other.RefireRate[3] = 2.0;
		Other.FireSounds[3] = Sound'UnrealShare.flak.Explode1';
		Other.ProjectileClass[3] = class'Botpack.flakslug';
		Other.AmmoTypes[3] = Class'Botpack.flakammo';
		Other.bLeadTargetForSlot[3] = 1;
		if (Other.AmmoAmount[3] < 25) Other.AmmoAmount[3] = 25;
	}
}

// get ambient fire sound
static function sound GetAmbientFiringSound(WFS_PCSystemAutoCannon Other)
{
	if ((Other.Enemy == None) && (Other.Target == None))
		return None;

	if (Other.AmmoAmount[0] > 0)
	{
		if (Other.TechLevel > 0) return Class'Minigun2'.Default.AltFireSound;
		else return Class'Minigun2'.Default.FireSound;
	}

	return None;
}

static function bool IsInWeaponRange(WFS_PCSystemAutoCannon Other, actor Target, byte WeaponSlot)
{
	local float EnemyDist;
	local vector EnemyDir;

	if (Target == none)
		return false;

	if ((WeaponSlot == 2) && (Other.TechLevel > 1))
	{
		EnemyDir = Target.Location - Other.Location;
		EnemyDist = VSize(EnemyDir);
		if ( EnemyDist > 1400 )
			return false;
	}

	if ((WeaponSlot == 3) && (Other.TechLevel > 2))
	{
		EnemyDir = Target.Location - Other.Location;
		EnemyDist = VSize(EnemyDir);
		if ( EnemyDist > 1500 )
			return false;
	}

	return true;
}

// return false if muzzle flash should not be displayed
static function bool UseMuzzleFlash(WFS_PCSystemAutoCannon Other)
{
	if ((Other.Enemy == None) && (Other.Target == None))
		return false;

	if (Other.AmmoAmount[0] <= 0)
		return false;

	return true;
}

defaultproperties
{
}