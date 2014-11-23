//=============================================================================
// WFS_PCSArmor.
//
// Used to handle varied levels of maximum armor for a player.
// This is used to set up the starting Armor of a player class based on the PCI
// armor properties. See WFS_PlayerClassInfo for more info.
//
// The Armor properties that are set up by the PCI are:
//
//	name ProtectionType1	  - Protects against DamageType (None if non-armor).
//	name ProtectionType2	  - Secondary protection type (None if non-armor).
//	int  Charge				  - Amount of starting armor.
//	int  MaxCharge			  - Maximum armor amount allowed.
//	int  ArmorAbsorption	  - Percent of damage armor absorbs 0-100.
//
//=============================================================================
class WFS_PCSArmor extends TournamentPickup;

var() int MaxCharge;	// maximum amount the armor can reach

// TODO: not sure that there's much point in supporting a ShieldBelt pickup
function bool HandlePickupQuery( inventory Item )
{
	local inventory S;

	// this situation is unlikely, but support is here for handling a WFS_PCSArmor pickup anyway
	if ( item.class == class )
	{
		S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');
		if (  S==None )
		{
			if ( Charge<Item.Charge )
				Charge = Min(Charge + Item.Charge, MaxCharge);
		}
		else
			Charge = Clamp(S.Default.Charge - S.Charge, Charge, Item.Charge );

		// log the pickup
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));

		// display message
		if ( PickupMessageClass == None )
			Pawn(Owner).ClientMessage(PickupMessage, 'Pickup');
		else
			Pawn(Owner).ReceiveLocalizedMessage( PickupMessageClass, 0, None, None, Self.Class );

		Item.PlaySound(PickupSound,,2.0);
		Item.SetReSpawn();
		return true;
	}

	// add charge if bIsAnArmor
	if (Item.bIsAnArmor)
	{
		S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');
		if (  S==None )
			Charge = Min(Charge + Item.Charge, MaxCharge);
		else
			Charge = Clamp(S.Default.Charge - S.Charge, Charge, Item.Charge );

		// log the pickup
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));

		// display message
		if ( PickupMessageClass == None )
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
		else
			Pawn(Owner).ReceiveLocalizedMessage( Item.PickupMessageClass, 0, None, None, Item.Class );

		Item.PlaySound(Item.PickupSound,,2.0);
		Item.SetReSpawn();
		return true;
	}

	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

// this prevents the armor from being removed from a players inventory when used up
// (it stays in the inventory, but absorbs no damage)
function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	local int ArmorDamage;

	if (Charge == 0)
		return Damage;

	if ( DamageType != 'Drowned' )
		ArmorImpactEffect(HitLocation);
	if( (DamageType!='None') && ((ProtectionType1==DamageType) || (ProtectionType2==DamageType)) )
		return 0;

	if (DamageType=='Drowned') Return Damage;

	ArmorDamage = (Damage * ArmorAbsorption) / 100;
	if( ArmorDamage >= Charge )
	{
		ArmorDamage = Charge;
		Charge -= ArmorDamage;
	}
	else
		Charge -= ArmorDamage;
	return (Damage - ArmorDamage);
}

// negative values will reduce armor
function AddArmor(int Amount)
{
	Charge = Clamp(Charge + Amount, 0, MaxCharge );
}

defaultproperties
{
     bDisplayableInv=True
     PickupMessage="You got the Body Armor."
     ItemName="Body Armor"
     RespawnTime=30.000000
     PickupViewMesh=LodMesh'Botpack.Armor2M'
     Charge=100
     ArmorAbsorption=75
     bIsAnArmor=True
     AbsorptionPriority=7
     MaxDesireability=2.000000
     PickupSound=Sound'Botpack.Pickups.ArmorUT'
     Mesh=LodMesh'Botpack.Armor2M'
     AmbientGlow=64
     CollisionHeight=11.000000
}
