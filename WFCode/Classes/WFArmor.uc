class WFArmor extends WFS_PCSArmor;

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

		UpdateCharge();

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

		UpdateCharge();

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

	UpdateCharge();

	return (Damage - ArmorDamage);
}

function UpdateCharge()
{
	local WFBot aBot;
	local WFPlayer aPlayer;

	aPlayer = WFPlayer(Owner);
	if (aPlayer != None)
		aPlayer.Armor = Charge;
	else
	{
		aBot = WFBot(Owner);
		if (aBot != None)
			aBot.Armor = Charge;
	}
}

defaultproperties
{
}