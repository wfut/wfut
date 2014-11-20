class WFPCIList extends WFS_PCIList
	config(WeaponsFactory);

// Called by a players PlayHit function to allow custom class sets
// to handle damage flash for a specific damage type. Add the flash code
// here and return true to indicate that the damage flash has been handled.
function bool HandleDamageFlash(PlayerPawn Other, float Damage, name DamageType)
{
	local float rnd;

	rnd = FClamp(Damage, 20, 60);
	if (DamageType == 'InfectedStatus')
	{
		Other.ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
		return true;
	}
	else if (DamageType == 'OnFireStatus')
	{
		Other.ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
		return true;
	}

	return false;
}

// Called by a players TakeDamage function to allow prevent armor from reducing
// damage for a specific damage type. Return false if damage caused by
// this damage type shouldn't be reduced by carried armor.
function bool CanReduceDamageFor(name DamageType)
{
	if ( (DamageType == 'InfectedStatus')
		|| (DamageType == 'Gassed') )
		return false;

	return true;
}

// Use this to add custom ammo types to a supply pack.
function bool ModifySupplyPack(WFSupplyPack Pack)
{
	return false;
}

defaultproperties
{
}