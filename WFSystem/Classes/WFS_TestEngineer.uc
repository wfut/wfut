//=============================================================================
// WFS_TestEngineer.
//=============================================================================
class WFS_TestEngineer extends WFS_TestPCI;

var() class<WFS_PCSystemAutoCannon> AutoCannonClass;
var() class<WFS_AutoCannonWeaponInfo> WeaponInfoClass;

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	local WFS_PCSystemAutoCannon sc;
	local Rotator scRot, viewRot;

	if (Other.Role != ROLE_Authority)
		return;

	if (SpecialString == "")
		WFS_PCSystemPlayer(Other).ClientDisplayHUDMenu(default.HUDMenu);

	// ========== DEBUG COMMANDS ===========
	if (SpecialString ~= "debuginfo")
	{
		sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
		if (sc == none) return;
		Other.ClientMessage(
				"CANNON_INFO:"@
				"Health: "$sc.Health@
				", State: "$sc.GetStateName()@
				", Enemy: "$sc.Enemy@
				", Target: "$sc.Target
				, 'Critical');
		return;
	}

	if (SpecialString ~= "debugenemy")
	{
		sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
		if (sc == none) return;
		Other.ClientMessage(
				"CANNON_ENEMY_INFO:"@
				"Enemy: "$sc.Enemy@
				", Health: "$sc.Enemy.Health@
				", State: "$sc.Enemy.GetStateName()@
				", Distance: "$VSize(sc.Enemy.Location - sc.Location)@
				", IsVisible: "$sc.IsVisibleTarget(sc.Enemy)
				, 'Critical');
		return;
	}

	if (SpecialString ~= "debugtarget")
	{
		sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
		if (sc == none) return;
		Other.ClientMessage(
				"CANNON_TARGET_INFO:"@
				"Target: "$sc.Target@
				", Health: "$pawn(sc.Target).Health@
				", State: "$sc.Target.GetStateName()@
				", Distance: "$VSize(sc.Target.Location - sc.Location)@
				", IsVisible: "$sc.IsVisibleTarget(sc.Target)
				, 'Critical');
		return;
	}

	if (SpecialString ~= "debugammo")
	{
		sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
		if (sc == none) return;
		Other.ClientMessage(
				"CANNON_AMMO_INFO:"@
				"AmmoAmount[0]: "$sc.AmmoAmount[0]@
				", AmmoAmount[1]: "$sc.AmmoAmount[1]@
				", AmmoAmount[2]: "$sc.AmmoAmount[2]@
				", AmmoAmount[3]: "$sc.AmmoAmount[3]
				, 'Critical');
		return;
	}
	// =====================================

	if (SpecialString ~= "build")
	{
		// TODO: add some kind of ammo/resource management here
		if (Other.Base == none)
			return;

		if (RelatedActorCount(Other, default.AutoCannonClass) == 0)
		{
			scRot.Yaw = Other.Rotation.Yaw;
			viewRot.Yaw = Other.ViewRotation.Yaw;
			sc = Other.Spawn(default.AutoCannonClass, Other,, Other.Location + (72 * Vector(viewRot)) + (vect(0,0,1) * 15) - vect(0,0,32), scRot);
			if (sc == none)
			{
				Other.ClientMessage("Not enough room to build here.", 'Critical');
				return;
			}
			sc.SetPhysics(PHYS_Falling);
			sc.SetPlayerOwner(Other);
			sc.SetTeam(Other.PlayerReplicationInfo.Team);
			sc.SetWeaponInfo(default.WeaponInfoClass);
			AddRelatedActor(Other, sc);
		}
		else
			Other.ClientMessage("Only one sentry cannon allowed.", 'Critical');
	}
	else if (SpecialString ~= "destruct")
	{
		// find the players sentry cannon
		sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
		if (sc == none)
		{
			Other.ClientMessage("No sentry cannon found.", 'Critical');
			return;
		}

		Destruct(Other, sc);
	}
	else if (SpecialString != "")
	{
		// find the players sentry cannon
		sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
		if (sc == none)
		{
			Other.ClientMessage("No sentry cannon found.", 'Critical');
			return;
		}
		// check if within range
		if (VSize(sc.Location - Other.Location) >= 75)
		{
			Other.ClientMessage("Too far away from cannon.", 'Critical');
			return;
		}

		if (SpecialString ~= "addammo")
			AddAmmo(Other, sc);

		if (SpecialString ~= "repair")
			Repair(Other, sc);

		if (SpecialString ~= "remove")
			Remove(Other, sc);

		if (SpecialString ~= "upgrade")
			Upgrade(Other, sc);
	}
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if (default.DefaultInventory.static.IsDefaultInventory(ItemClass))
		return true;

	if (ItemClass == class'Enforcer')
		return true;

	if (ClassIsChildOf(ItemClass, class'Ammo'))
		return true;

	if (ItemClass.default.bIsAnArmor)
		return true;

	return false;
}

static function bool HandlePickupQuery(Pawn Other, inventory Item)
{
	local weapon w;

	if (Item.IsA('Enforcer'))
	{
		w = weapon(Other.FindInventoryType(class'Enforcer'));
		if ((w != none) && (w.AmmoType != none))
		{
			w.AmmoType.AddAmmo(weapon(Item).PickupAmmoCount);
			Item.PlaySound(item.PickupSound);
			Item.SetRespawn();
		}

		return true;
	}
}

static function PlayerTakeDamage(pawn Other, out int Damage, out Pawn instigatedBy,	out vector hitlocation, out vector momentum, out name damageType, out byte bIgnoreDamage)
{
	local WFS_PCSystemAutoCannon sc;

	sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
	if (sc != none)
	{
		if (sc.IsInState('Building') || sc.IsInState('Removing'))
		{
			Momentum = vect(0,0,0);
		}
	}
}

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	local WFS_PCSystemAutoCannon sc;

	sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
	if (sc != none)
	{
		if (sc.IsInState('Building') || sc.IsInState('Removing'))
		{
			sc.PlayExplode(vect(0,0,0), vect(0,0,0));
			sc.Destroy();
		}
	}
}

// -- custom functions --
// increase ammo by 25 for each ammo type
static function AddAmmo(pawn Other, WFS_PCSystemAutoCannon sc)
{
	local inventory item;
	local ammo AmmoType;
	local int amount, weaponslot, i;
	local string AmmoMessage;

	for (item = Other.Inventory; item != none; item = item.Inventory)
	{
		if ((item != none) && item.IsA('Ammo'))
		{
			AmmoType = ammo(item);
			weaponslot = sc.FindSlotForAmmo(AmmoType);
			if (weaponslot >= 0)
			{
				if (AmmoType.AmmoAmount >= 25) amount = 25;
				else amount = AmmoType.AmmoAmount;
				sc.IncreaseAmmo(weaponslot, amount);
				AmmoType.UseAmmo(amount);
			}
		}
	}

	if (Other.Weapon.AmmoType.AmmoAmount == 0)
		Other.SwitchToBestWeapon();

	for (i=0; i<4; i++)
	{
		if ((i > 0) && (i < 3))
			AmmoMessage = AmmoMessage $ ", ";
		if (sc.AmmoTypes[i] != none)
			AmmoMessage = AmmoMessage $sc.AmmoTypes[i].default.ItemName$": "$sc.AmmoAmount[i];
		else AmmoMessage = AmmoMessage $"Weapon Slot "$i$": "$sc.AmmoAmount[i];
	}

	Other.ClientMessage("AMMO LEVELS ARE: "$AmmoMessage, 'Critical');
}

static function Repair(pawn Other, WFS_PCSystemAutoCannon sc)
{
	// TODO: add some kind of ammo/resource management here
	sc.Repair(50);
	Other.ClientMessage("Health of "$sc.MenuName$" is now at: "$sc.health, 'Critical');
}

static function Upgrade(pawn Other, WFS_PCSystemAutoCannon sc)
{
	// TODO: add some kind of ammo/resource management here
	sc.IncreaseTechLevel();
	Other.ClientMessage(sc.MenuName@"upgraded to level "$sc.techlevel, 'Critical');
}

static function Destruct(pawn Other, WFS_PCSystemAutoCannon sc)
{
	sc.SelfDestruct();
}

static function Remove(pawn Other, WFS_PCSystemAutoCannon sc)
{
	// TODO: add some kind of ammo/resource management here
	sc.RemoveCannon();
}

defaultproperties
{
	ClassName="Engineer"
	ClassNamePlural="Engineers"
	Armor=50
	HUDMenu=class'WFS_TestEngineerHUDMenu'
	//ExtendedHUD=class'WFS_TestEngineerHUDInfo'
	ExtendedHUD=class'WFS_CTFITSHUDInfo'
	DefaultInventory=class'WFS_TestEngineerInv'
	AutoCannonClass=class'WFS_PCSystemAutoCannon'
	WeaponInfoClass=class'WFS_TestWeaponInfo'
}