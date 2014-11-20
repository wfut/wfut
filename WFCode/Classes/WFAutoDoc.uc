//=============================================================================
// WFAutoDoc.
//=============================================================================
class WFAutoDoc extends TournamentPickup;

var() int HealingDelay;
var() int HealingAmount;
var() bool bRandomAmount;
var() sound HealingSound;

var class<WFS_PlayerClassInfo> OwnerPCI;

state Activated
{
	function Timer()
	{
		local int AddHealth;

		// work out how much health to add
		if (bRandomAmount) AddHealth = Rand(HealingAmount);
		else AddHealth = HealingAmount;

		// use rhe max default health for the owners player class
		if ((OwnerPCI != none) && (pawn(Owner).Health < OwnerPCI.default.Health))
		{
			pawn(Owner).Health = Min(pawn(Owner).Health + AddHealth, OwnerPCI.default.Health);
			if (HealingSound != none)
				Owner.PlaySound(HealingSound, SLOT_Interact, 8);
		}
		// no PCI found for owner, assume 100 for max default health
		else if (pawn(Owner).Health < 100)
		{
			pawn(Owner).Health = Min(pawn(Owner).Health + AddHealth, 100);
			if (HealingSound != none)
				Owner.PlaySound(HealingSound, SLOT_Interact, 8);
		}
	}

Begin:
	OwnerPCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(pawn(Owner));
	SetTimer(HealingDelay, true);
}

defaultproperties
{
	bAutoActivate=true
	bActivatable=True
	HealingDelay=3
	HealingAmount=2
}