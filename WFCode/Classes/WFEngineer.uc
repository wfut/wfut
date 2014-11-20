//=============================================================================
// WFEngineer.
//
// Resources:
//  Gets 1/2 the armor value in resource points when collecting armor.
//
//=============================================================================
class WFEngineer extends WFPlayerClassInfo;

// will use hard-coded values later on
var() class<WFS_PCSystemAutoCannon> AutoCannonClass;

var() int CannonUpgradeCost;
var() int CannonBuildCost;
var() int RepairRatio; // how many points an engineer can repair a sentry for each point of resource
var() int MaxRepairAmount; // the maximum amount a sentry can be repaired for each "repair" command

var() int DepotBuildCost;
var() int AlarmBuildCost;

static function bool IsClientSideCommand(string SpecialString)
{
	if (SpecialString == "")
		return true;

	return false;
}

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	local WFS_PCSystemAutoCannon sc, closestSC;
	local Rotator scRot, viewRot;
	local float best, dist;

	if ((Other.Role != ROLE_Authority) && (Type != 'ClientSide'))
		return;

	if ((SpecialString == "") && Other.IsA('WFS_PCSystemPlayer'))
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
	// ========== END OF DEBUG COMMANDS ===========

	if (SpecialString ~= "build")
	{
		if (Other.Base != Other.Level)
			return;

		BuildCannon(Other);
	}
	else if (SpecialString ~= "builddepot")
	{
		if (Other.Base == none)
			return;

		BuildDepot(Other);
	}
	else if (SpecialString ~= "deployalarm")
		DeployAlarm(Other);
	//else if (SpecialString ~= "buildalarm")
	//	BuildAlarm(Other);
	//else if (SpecialString ~= "removealarm")
	//	RemoveAlarm(Other);
	else if (SpecialString ~= "destructdepot")
		DestructDepot(Other);
	else if (SpecialString ~= "destruct")
		DestructCannon(Other);
	//else if (SpecialString != "")
	else if ((SpecialString ~= "addammo") || (SpecialString ~= "repair")
		|| (SpecialString ~= "upgrade") || (Left(SpecialString, 6) ~= "rotate")
		|| (SpecialString ~= "remove"))
	{
		// try to find the closest cannon from the same team as Other
		closestSC = None;
		best = 100.0;
		foreach Other.RadiusActors(class'WFS_PCSystemAutoCannon', sc, 75.0)
		{
			if ((sc != none) && sc.SameTeamAs(Other.PlayerReplicationInfo.Team))
			{
				dist = VSize(sc.Location - Other.Location);
				if ((closestSC == None) || (dist < best))
				{
					best = dist;
					closestSC = sc;
				}
			}
		}
		sc = closestSC;

		// find the players sentry cannon
		if (sc == None)
			sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));

		if (sc == None)
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

		// these can be used on any cannon
		if (SpecialString ~= "addammo")
			AddAmmo(Other, sc);

		if (SpecialString ~= "repair")
			Repair(Other, sc);

		if (SpecialString ~= "upgrade")
			Upgrade(Other, sc);

		if (Left(SpecialString, 6) ~= "rotate")
			Rotate(Other, sc, Right(SpecialString, 1) ~= "l");

		// can only be done on own cannon
		if (SpecialString ~= "remove")
		{
			if (Other == sc.PlayerOwner)
				Remove(Other, sc);
			else
				Other.ClientMessage("Cannot remove another players "$sc.MenuName$".", 'Critical');
		}
	}
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if ( (ItemClass == class'Miniammo') || (ItemClass == class'EClip')
		|| (ItemClass == Class'RocketPack') )
		return true;

	return super.ValidInventoryType(Other, ItemClass);
}

static function bool HandlePickupQuery(Pawn Other, inventory Item)
{
	local weapon w;
	local inventory Inv;

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

	if (Item.bIsAnArmor)
	{
		Inv = Other.FindInventoryType(class'WFEngineerResource');
		if (Inv != None)
			Ammo(Inv).AddAmmo(Item.Charge/2);
	}

	return false;
}

static function PlayerTakeDamage(pawn Other, out int Damage, out Pawn instigatedBy,	out vector hitlocation, out vector momentum, out name damageType, out byte bIgnoreDamage)
{
	local actor sc, Depot;

	sc = FindRelatedActorClass(Other, default.AutoCannonClass);
	if (sc != none)
		if (sc.IsInState('Building') || sc.IsInState('Removing') || sc.IsInState('ChangingTechLevel'))
			Momentum = vect(0,0,0);

	Depot = FindRelatedActorClass(Other, class'WFSupplyDepot');
	if (Depot != none)
		if (Depot.IsInState('Building'))
			Momentum = vect(0,0,0);

	super.PlayerTakeDamage(Other, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);
}

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	local WFS_PCSystemAutoCannon sc;
	local WFSupplyDepot Depot;

	sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
	if (sc != none)
	{
		if (sc.IsInState('Building') || sc.IsInState('Removing'))
		{
			sc.PlayExplode(vect(0,0,0), vect(0,0,0));
			sc.Destroy();
		}

		// TODO: should the new techlevel be aborted or should the sentry be destroyed?
		if (sc.IsInState('ChangingTechLevel') && (sc.TechLevel != sc.NewTechLevel))
			sc.GotoState('Idle'); // abort the upgrade
	}

	Depot = WFSupplyDepot(FindRelatedActorClass(Other, class'WFSupplyDepot'));
	if ((Depot != none) && Depot.IsInState('Building'))
	{
		Depot.PlayExplode();
		Depot.Destroy();
	}
}

// -- custom functions --
static function BuildDepot(pawn Other)
{
	local WFSupplyDepot depot;
	local rotator buildRot, viewRot;
	local vector buildLoc;
	local inventory Inv;

	if (RelatedActorCount(Other, class'WFSupplyDepot') != 0)
	{
		Other.ClientMessage("Only one supply depot allowed.", 'Critical');
		return;
	}

	Inv = Other.FindInventoryType(class'WFEngineerResource');
	if ((Inv != None) && (Ammo(Inv).AmmoAmount < default.DepotBuildCost))
	{
		Other.ClientMessage("Not enough resources to build"@class'WFSupplyDepot'.default.MenuName@"(need"@default.DepotBuildCost-Ammo(Inv).AmmoAmount@"more resources).", 'Critical');
		return;
	}

	buildRot.Yaw = Other.Rotation.Yaw;
	viewRot.Yaw = Other.ViewRotation.Yaw;
	buildLoc = Other.Location + (72 * Vector(viewRot)) + (vect(0,0,1) * 15) - vect(0,0,32);

	// check that area is clear
	if (!CheckBuildLocation(buildLoc, 'Depot'))
		return;

	Depot = Other.Spawn(class'WFSupplyDepot', Other,, buildLoc, buildRot);
	if (Depot == none)
	{
		Other.ClientMessage("Not enough room to build here.", 'Critical');
		return;
	}

	if (Inv != None)
		Ammo(Inv).UseAmmo(default.DepotBuildCost);

	Depot.SetTeam(Other.PlayerReplicationInfo.Team);
	Depot.SetPlayerOwner(Other);
	SendEvent(Other, "s_depot_deployed");
	AddRelatedActor(Other, Depot);
}

static function DestructDepot(pawn Other)
{
	local WFSupplyDepot Depot;

	Depot = WFSupplyDepot(FindRelatedActorClass(Other, class'WFSupplyDepot'));
	if (Depot == None)
	{
		Other.ClientMessage("No supply depot found.", 'Critical');
		return;
	}

	Depot.SelfDestruct();
}

static function BuildAlarm(pawn Other)
{
	local WFAlarm alarm;
	local vector dir;
	local inventory Inv;

	if (RelatedActorCount(Other, class'WFAlarm') != 0)
	{
		Other.ClientMessage("You can only build one alarm.", 'Critical');
		return;
	}

	Inv = Other.FindInventoryType(class'WFEngineerResource');
	if ((Inv != None) && (Ammo(Inv).AmmoAmount < default.AlarmBuildCost))
	{
		Other.ClientMessage("Not enough resources to build alarm (need"@default.DepotBuildCost-Ammo(Inv).AmmoAmount@"more resources).", 'Critical');
		return;
	}

	dir = vector(Other.ViewRotation);
	dir.z = dir.Z + 0.35 * (1 - Abs(dir.Z));

	alarm = Other.spawn(class'WFAlarm',,, Other.Location, Other.Rotation);
	alarm.OwnerTeam = Other.PlayerReplicationInfo.Team;
	alarm.Velocity = 500.0 * Normal(dir);

	if (Inv != None)
		Ammo(Inv).UseAmmo(default.AlarmBuildCost);

	AddRelatedActor(Other, alarm);
}

static function DeployAlarm(pawn Other)
{
	local WFAlarm Alarm;
	local vector dir;

	Alarm = WFAlarm(FindRelatedActorClass(Other, class'WFAlarm'));
	if ((Alarm != None) && !Alarm.bCanRemove)
	{
		Other.ClientMessage("Cannot re-deploy an alarm within 2 seconds of deploying on a surface or wall.", 'Critical');
		return;
	}

	if (Alarm != None)
	{
		RemoveRelatedActor(Other, alarm);
		Alarm.Destroy();
		Alarm = None;
	}

	dir = vector(Other.ViewRotation);
	dir.z = dir.Z + 0.35 * (1 - Abs(dir.Z));

	alarm = Other.spawn(class'WFAlarm',,, Other.Location, Other.Rotation);
	alarm.OwnerTeam = Other.PlayerReplicationInfo.Team;
	alarm.Velocity = 500.0 * Normal(dir);

	AddRelatedActor(Other, alarm);
}

static function RemoveAlarm(pawn Other)
{
	local WFAlarm Alarm;

	Alarm = WFAlarm(FindRelatedActorClass(Other, class'WFAlarm'));
	if (Alarm == None)
	{
		Other.ClientMessage("No alarm to remove.", 'Critical');
		return;
	}

	if (!Alarm.bCanRemove)
	{
		Other.ClientMessage("Cannot remove alarm within 2 seconds of deploying on a surface or wall.", 'Critical');
		return;
	}

	RemoveRelatedActor(Other, Alarm);
	Alarm.Destroy();
}

// increase ammo for each ammo type (default is 25 for each ammo type)
static function AddAmmo(pawn Other, WFS_PCSystemAutoCannon sc, optional int AddAmount)
{
	local inventory item;
	local ammo AmmoType;
	local int amount, weaponslot, i;
	local string AmmoMessage, AmmoName;

	if (AddAmount == 0) AddAmount = 25;

	for (item = Other.Inventory; item != none; item = item.Inventory)
	{
		if ((item != none) && item.IsA('Ammo'))
		{
			AmmoType = ammo(item);
			weaponslot = sc.FindSlotForAmmo(AmmoType);
			if (weaponslot >= 0)
			{
				if (AmmoType.AmmoAmount >= AddAmount) amount = AddAmount;
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
		if (sc.AmmoTypes[i] != none)
		{
			if ((i > 0) && (i < 3))
				AmmoMessage = AmmoMessage $ ", ";
			AmmoName = sc.AmmoTypes[i].default.ItemName;
			if (AmmoName == "")
				AmmoName = Other.GetItemName(string(sc.AmmoTypes[i]));
			AmmoMessage = AmmoMessage $ AmmoName $": "$sc.AmmoAmount[i];
		}
		//else AmmoMessage = AmmoMessage $"Weapon Slot "$i$": "$sc.AmmoAmount[i];
	}

	Other.ClientMessage("Cannon Ammo Levels: "$AmmoMessage, 'Critical');
}

// Uses available resources to repair the sentry, repair 1*RepairRatio health
// for 1 resource point. Cannot repair more than MaxRepairAmount points per repair
// command if MaxRepairAmount is greater than 0.
static function Repair(pawn Other, WFS_PCSystemAutoCannon sc)
{
	local inventory Inv;
	local int RepairAmount;

	RepairAmount = 50;
	Inv = Other.FindInventoryType(class'WFEngineerResource');
	if (Inv != None)
	{
		RepairAmount = Min(sc.MaxHealth[sc.TechLevel] - sc.Health, Ammo(Inv).AmmoAmount*default.RepairRatio);
		if (default.MaxRepairAmount > 0)
			RepairAmount = Min(RepairAmount, default.MaxRepairAmount);
		Ammo(Inv).UseAmmo(RepairAmount/default.RepairRatio);
	}

	sc.Repair(RepairAmount);
	Other.ClientMessage("Health of "$sc.MenuName$" is now at: "$sc.health, 'Critical');
}

static function BuildCannon(pawn Other)
{
	local WFS_PCSystemAutoCannon sc;
	local Rotator scRot, viewRot;
	local vector buildLoc;
	local inventory Inv;

	if (RelatedActorCount(Other, default.AutoCannonClass) != 0)
	{
		Other.ClientMessage("Only one sentry cannon allowed.", 'Critical');
		return;
	}

	Inv = Other.FindInventoryType(class'WFEngineerResource');
	if ((Inv != None) && (Ammo(Inv).AmmoAmount < default.CannonBuildCost))
	{
		Other.ClientMessage("Not enough resources to build"@default.AutoCannonClass.default.MenuName@"(need"@default.CannonBuildCost-Ammo(Inv).AmmoAmount@"more resources).", 'Critical');
		return;
	}

	scRot.Yaw = Other.Rotation.Yaw;
	viewRot.Yaw = Other.ViewRotation.Yaw;
	buildLoc = Other.Location + (72 * Vector(viewRot)) + (vect(0,0,1) * 15) - vect(0,0,32);

	// check that area is clear
	if (!CheckBuildLocation(buildLoc, 'Cannon'))
		return;

	sc = Other.Spawn(default.AutoCannonClass, Other,, buildLoc, scRot);
	if (sc == none)
	{
		Other.ClientMessage("Not enough room to build here.", 'Critical');
		return;
	}

	if (Inv != None)
		Ammo(Inv).UseAmmo(default.CannonBuildCost);

	sc.SetPhysics(PHYS_Falling);
	sc.SetPlayerOwner(Other);
	sc.SetTeam(Other.PlayerReplicationInfo.Team);
	SendEvent(Other, "cannon_deployed");
	AddRelatedActor(Other, sc);
}

static function bool CheckBuildLocation(vector BuildLoc, name BuildType)
{
	return true;
}

static function Upgrade(pawn Other, WFS_PCSystemAutoCannon sc)
{
	local inventory Inv;

	if (sc.TechLevel == sc.MaxTechLevel-1)
	{
		Other.ClientMessage(sc.MenuName@"already at maximum level.", 'Critical');
		return;
	}

	Inv = Other.FindInventoryType(class'WFEngineerResource');
	if ((Inv != None) && (Ammo(Inv).AmmoAmount < default.CannonUpgradeCost))
	{
		Other.ClientMessage("Not enough resources to upgrade"@sc.MenuName@"(need"@default.CannonUpgradeCost-Ammo(Inv).AmmoAmount@"more resources).", 'Critical');
		return;
	}

	if (Inv != None)
		Ammo(Inv).UseAmmo(default.CannonUpgradeCost);

	sc.IncreaseTechLevel(Other);
	SendEvent(Other, "cannon_upgraded"); // maybe add level?
	Other.ClientMessage("Upgrading"@sc.MenuName@"to level "$sc.techlevel+2$" ...", 'Critical');
}

static function DestructCannon(pawn Other)
{
	local WFS_PCSystemAutoCannon sc;

	// find the players sentry cannon
	sc = WFS_PCSystemAutoCannon(FindRelatedActorClass(Other, default.AutoCannonClass));
	if (sc == none)
	{
		Other.ClientMessage("No sentry cannon found.", 'Critical');
		return;
	}

	sc.SelfDestruct();
}

// the player recieves 1/2 the resources used to build the cannon
static function Remove(pawn Other, WFS_PCSystemAutoCannon sc)
{
	local inventory Inv;
	local ammo AmmoType;
	local int i;

	// add resources
	Inv = Other.FindInventoryType(class'WFEngineerResource');
	if (Inv != None)
		Ammo(Inv).AddAmmo(default.CannonBuildCost*0.5 + default.CannonUpgradeCost*0.5*sc.TechLevel);

	// recover any ammo left in the cannon
	for (i=0; i<4; i++)
	{
		if ((sc.AmmoTypes[i] != None) && (sc.AmmoAmount[i] > 0))
		{
			AmmoType = Ammo(Other.FindInventoryType(sc.AmmoTypes[i]));
			if (AmmoType == None)
			{
				AmmoType = Other.spawn(sc.AmmoTypes[i]);
				Other.AddInventory(AmmoType);
				AmmoType.BecomeItem();
				AmmoType.GotoState('Idle2');
				AmmoType.AmmoAmount = Min(sc.AmmoAmount[i], AmmoType.MaxAmmo);
			}
			else
				AmmoType.AmmoAmount = Min(AmmoType.AmmoAmount + sc.AmmoAmount[i], AmmoType.MaxAmmo);
		}
	}

	sc.RemoveCannon();
}

// rotate the cannon 45 degrees
static function Rotate(pawn Other, WFS_PCSystemAutoCannon sc, optional bool bRotateLeft)
{
	local rotator NewRotation;

	// calculate the new rotation (8192 == 45 degrees)
	if (!bRotateLeft)
		NewRotation = sc.Rotation + rot(0,8192,0);
	else
		NewRotation = sc.Rotation - rot(0,8192,0);

	// rotate the cannon
	sc.SetCannonRotation(NewRotation);
}

defaultproperties
{
	ClassName="Engineer"
	ClassNamePlural="Engineers"
	Health=100
	Armor=75
	HUDMenu=class'WFEngineerHUDMenu'
	ExtendedHUD=class'WFEngineerHUDInfo'
	DefaultInventory=class'WFEngineerInv'
	AutoCannonClass=class'WFAutoCannon'
	//bNoTranslocator=True
	bNoImpactHammer=True
	bNoEnforcer=True
	MeshInfo=class'WFD_TMale1MeshInfo'
	AltMeshInfo=class'WFD_TMale1BotMeshInfo'
	CannonBuildCost=100
	CannonUpgradeCost=100
	AlarmBuildCost=25
	DepotBuildCost=50
	RepairRatio=2
	ClassDescription="WFCode.WFClassHelpEngineer"
	ClassSkinName="WFSkins.engy"
	ClassFaceName="WFSkins.arto"
	bDisplayArmorID=True
	VoiceType="BotPack.VoiceMaleOne"
}