//=============================================================================
// WFPlayerClassList.
//=============================================================================
class WFPlayerClassList extends WFPCIList;

function bool HandleRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	local class<WFGrenadeItem> GrenadeClass;
	local class<WFPlayerStatus> StatusClass;
	local class<Weapon> WeaponClass;

	// handle weapon death message
	switch (DamageType)
	{
		case 'WFGrenade': WeaponClass = class'WFGrenadeLauncher'; break;
		case 'WFPlasmaDeath': WeaponClass = class'WFPlasmaDeathMessage'; break;
		case 'WFLaserTripMine': WeaponClass = class'WFLaserTripmineMessage'; break;
		case 'WFLaserInstaGibMine': WeaponClass = class'WFLaserInstagibMineMessage'; break;

		default: WeaponClass = None; break;
	}

	if (WeaponClass != None)
	{
		BroadcastLocalizedMessage(class'WFDeathMessagePlus', 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, WeaponClass);
		return true;
	}

	// handle grenade death message
	switch (DamageType)
	{
		case 'FragGrenade': GrenadeClass = class'WFGrenFrag'; break;
		case 'FlashGrenade': GrenadeClass = class'WFGrenFlash'; break;
		case 'ShockGrenade': GrenadeClass = class'WFGrenShock'; break;
		case 'ConcGrenade': GrenadeClass = class'WFGrenConc'; break;
		case 'TurretGrenade': GrenadeClass = class'WFGrenTurret'; break;
		case 'PlagueGrenade': GrenadeClass = class'WFGrenPlague'; break;
		case 'FlameGrenade': GrenadeClass = class'WFGrenFlame'; break;

		default: GrenadeClass = None; break;
	}

	if (GrenadeClass != None)
	{
		BroadcastLocalizedMessage(class'WFDeathMessagePlus', 10, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, GrenadeClass);
		return true;
	}

	// handle status death message
	switch (DamageType)
	{
		case 'OnFireStatus': StatusClass = class'WFStatusOnFire'; break;
		case 'InfectedStatus': StatusClass = class'WFStatusInfected'; break;
		case 'KamikazeStatus': StatusClass = class'WFStatusKami'; break;

		default: StatusClass = None; break;
	}

	if (StatusClass != None)
	{
		BroadcastLocalizedMessage(class'WFDeathMessagePlus', 11, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, StatusClass);
		return true;
	}

	return false;
}

function bool HandleSuicideMessage(pawn Other, name DamageType, out byte bLogAsSuicide, out byte bIncreaseDeaths, out byte bDecreaseScore)
{
	local class<WFGrenadeItem> GrenadeClass;
	local class<WFPlayerStatus> StatusClass;

	/*switch (DamageType)
	{
		case 'FragGrenade': GrenadeClass = class'WFGrenFrag'; break;
		case 'FlashGrenade': GrenadeClass = class'WFGrenFlash'; break;
		case 'ShockGrenade': GrenadeClass = class'WFGrenShock'; break;
		case 'ConcGrenade': GrenadeClass = class'WFGrenConc'; break;
		case 'TurretGrenade': GrenadeClass = class'WFGrenTurret'; break;
		case 'PlagueGrenade': GrenadeClass = class'WFGrenPlague'; break;
		case 'FlameGrenade': GrenadeClass = class'WFGrenFlame'; break;

		default: GrenadeClass = None; break;
	}

	if (GrenadeClass != None)
	{
		BroadcastLocalizedMessage(class'WFDeathMessagePlus', 10, Other.PlayerReplicationInfo, None, GrenadeClass);
		return true;
	}*/

	switch (DamageType)
	{
		case 'KamikazeStatus':
			StatusClass = class'WFStatusKami';
			bLogAsSuicide = 0;
			bDecreaseScore = 0;
			break;

		default: GrenadeClass = None; break;
	}

	if (StatusClass != None)
	{
		BroadcastLocalizedMessage(class'WFDeathMessagePlus', 11, Other.PlayerReplicationInfo, None, StatusClass);
		return true;
	}

	return false;
}

function bool CanReduceDamageFor(name DamageType)
{
	if ( (DamageType == 'InfectedStatus')
		|| (DamageType == 'Gassed')
		|| (DamageType == 'PlagueGrenade') )
		return false;

	return true;
}

/* Use this to add custom ammo types to a supply pack.
function bool ModifySupplyPack(WFSupplyPack Pack)
{
	if ( Pack.AddAmmoType(class'WFASAmmo', 5)
		|| Pack.AddAmmoType(class'WFChainCannonAmmo', 50) )
		return true;
	return false;
}*/

defaultproperties
{
	PlayerClasses(0)=class'WFRecon'
	PlayerClasses(1)=class'WFDemoMan'
	PlayerClasses(2)=class'WFMarine'
	PlayerClasses(3)=class'WFEngineer'
	PlayerClasses(4)=class'WFGunner'
	PlayerClasses(5)=class'WFInfiltrator'
	PlayerClasses(6)=class'WFCyborg'
	PlayerClasses(7)=class'WFSniper'
	PlayerClasses(8)=class'WFFieldMedic'
	PlayerClasses(9)=class'WFPyrotech'
	NumClasses=10
}