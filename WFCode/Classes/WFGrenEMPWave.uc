class WFGrenEMPWave extends WFPlasmaWave;

var float EMPRange;
var float EMPDisableTime;

simulated function Timer()
{
	local WFS_PCSystemAutoCannon c;
	local WFGrenTurretProj g;
	local pawn P;

	// cause no damage and deactivate sentrys
	foreach VisibleCollidingActors(class'WFS_PCSystemAutoCannon', c, EMPRange, Location)
		if ( (c != None) && ((c.PlayerOwner == None) || (Instigator.PlayerReplicationInfo.Team != c.MyTeam)) )
			c.DisableCannon(EMPDisableTime);

	foreach RadiusActors(class'WFGrenTurretProj', g, EMPRange, Location)
		if ( (g != None) && ((g.Instigator == None) || (Instigator.PlayerReplicationInfo.Team != g.Instigator.PlayerReplicationInfo.Team)) )
		{
			spawn(class'WFDisruptEffect', g,, g.Location, g.Rotation);
			g.SetFall();
		}

	foreach VisibleCollidingActors(class'Pawn', P, EMPRange, Location)
		if ((P != None) && P.bIsPlayer && (P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team))
			ResetChargableAmmo(P, VSize(P.Location - Location));
}

function ResetChargableAmmo(pawn Other, float PawnRange)
{
	local inventory Inv;
	local bool bDrained;

	bDrained = false;
	for (Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory)
		if (Inv.IsA('WFRechargingAmmo'))
		{
			Ammo(Inv).AmmoAmount = 1;
			bDrained = true;
		}

	if (bDrained)
		Other.ClientMessage("EMP wave drained recharging ammo!", 'CriticalEvent');
}

simulated function SpawnEffects()
{
	 local WarExplosion W;

	 PlaySound(Sound'Expl04', SLOT_Interface, 16.0);
	 PlaySound(Sound'Expl04', SLOT_None, 16.0);
	 PlaySound(Sound'Expl04', SLOT_Misc, 16.0);
	 PlaySound(Sound'Expl04', SLOT_Talk, 16.0);
}

defaultproperties
{
	EMPRange=750.0
	EMPDisableTime=10.0
	LifeSpan=1.0
	MultiSkins(1)=Texture'fireeffect3a'
}