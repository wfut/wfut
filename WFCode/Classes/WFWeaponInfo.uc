//=============================================================================
// WFWeaponInfo.
//=============================================================================
class WFWeaponInfo expands WFS_AutoCannonWeaponInfo;

var() float CannonRange;

// called when the cannon changes tech level
static function TechLevelChanged(WFS_PCSystemAutoCannon Other)
{
	if (Other.TechLevel >= 0)
	{
		Other.SlotDamage[0] = 9;
		Other.RefireRate[0] = 0.1;
		Other.AmmoTypes[0] = class'Miniammo';
		Other.DamageVariation[0] = 6;
		Other.AmmoUsed[0] = 1;
	}

	if (Other.TechLevel >= 1)
	{
		Other.SlotDamage[0] = 14;
		Other.RefireRate[0] = 0.1;
		Other.AmmoTypes[0] = class'Miniammo';
		Other.DamageVariation[0] = 11;
		Other.AmmoUsed[0] = 1;
	}

	if (Other.TechLevel >= 2)
	{
		Other.AmmoUsed[1] = 1;
		Other.RefireRate[1] = 2.0;
		Other.FireSounds[1] = Sound'UnrealShare.Eightball.Ignite';
		Other.ProjectileClass[1] = class'WFRocketMk2';
		Other.AmmoTypes[1] = Class'RocketPack';
		Other.bLeadTargetForSlot[1] = 1;
	}
}

// called after each tech level change
static function SetupAmmoLevels(WFS_PCSystemAutoCannon Other, pawn PlayerManager)
{
	local inventory item;
	local ammo AmmoType;
	local int amount, AddAmount[4], weaponslot, i;
	local string AmmoMessage, AmmoName;

	// set up the ammo levels for the two WFCannon weapon slots
	AddAmount[0] = 50; // miniammo amount
	if (Other.TechLevel == 2)
		AddAmount[1] = 10; // rocketpack amount


	for (item = PlayerManager.Inventory; item != none; item = item.Inventory)
	{
		if ((item != none) && item.IsA('Ammo'))
		{
			AmmoType = ammo(item);
			weaponslot = Other.FindSlotForAmmo(AmmoType);
			if (weaponslot >= 0)
			{
				if (AmmoType.AmmoAmount >= AddAmount[weaponslot])
					amount = AddAmount[weaponslot];
				else amount = AmmoType.AmmoAmount;
				Other.IncreaseAmmo(weaponslot, amount);
				AmmoType.UseAmmo(amount);
			}
		}
	}

	if (PlayerManager.Weapon.AmmoType.AmmoAmount == 0)
		PlayerManager.SwitchToBestWeapon();
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

	if (VSize(Other.Location - Target.Location) > default.CannonRange)
		return false;

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

/*static function bool CalcShootRot(WFS_PCSystemAutoCannon Other, vector ProjStart, out rotator ShootRot)
{
	// no aiming error
	ShootRot = rotator(Other.Enemy.Location - ProjStart);
	Other.DesiredRotation = ShootRot;

	return true;
}*/

defaultproperties
{
	CannonRange=1500.0
}