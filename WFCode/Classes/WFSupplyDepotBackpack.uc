class WFSupplyDepotBackpack extends WFBackpack;

var WFSupplyDepot OwnerDepot;
var byte OwnerTeam;

function ShowPack();

function SetRespawn()
{
	ResetAmmo();
	bHidden = true;
	if (OwnerDepot != None)
		OwnerDepot.Recharge();
	GotoState('Idle');
}

function ResetAmmo()
{
	local int i;

	for (i=0; i<ArrayCount(AmmoAmounts); i++)
		AmmoAmounts[i] = 0;

	ResourceAmount = 0;
	ArmorAmount = 0;
}

auto state Idle
{
	function ShowPack() { GotoState('PrePickup'); }
}

state PrePickup
{
Begin:
	Sleep( PlayRespawnEffect() );
	GotoState('Pickup');
}

function float PlayRespawnEffect()
{
	spawn(class'EnhancedRespawn', self,, Location);
	return 0.0;
}

defaultproperties
{
	bHidden=True
	Style=STY_Translucent
	OwnerTeam=255
	bToggleSteadyFlash=False
	bAmbientGlow=True
	PickupMessage="You picked up a Supply Pack."
	ItemName="Supply Pack"
	bUnlit=True
	bAddGrenadeAmmo=True
	bAllGrenadeTypes=True
	NumGrenades=2
}