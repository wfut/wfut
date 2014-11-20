class WFRDUAmmo extends WFRechargingAmmo;

var() int RechargeRate;

var bool bRecharge;

auto state Idle2
{
	function Timer()
	{
		local WFReconDefenseUnit WFRDU;
		if (bRecharge)
			AmmoAmount = Min(MaxAmmo, AmmoAmount + RechargeRate);
		else if (bActive && !UseAmmo(class'WFReconDefenseUnit'.default.PlasmaEnergyRate))
		{
			WFRDU = WFReconDefenseUnit(Pawn(Owner).FindInventoryType(class'WFReconDefenseUnit'));
			if (WFRDU != None)
				WFRDU.NotEnoughAmmo();
			bActive = false;
			bRecharge = true;
		}
	}

Begin:
	SetTimer(RechargeDelay, true);
}

defaultproperties
{
	AmmoAmount=50
	MaxAmmo=50
	RechargeDelay=1
	RechargeRate=5
	bRecharge=True
}