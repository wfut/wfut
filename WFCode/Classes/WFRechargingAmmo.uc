// parent class of rechargable ammo types
class WFRechargingAmmo extends TournamentAmmo;

var() float RechargeDelay;

Auto State Idle2
{
	function Timer()
	{
		if( AmmoAmount < MaxAmmo)
			AmmoAmount++;
		if ( AmmoAmount < 10 )
			SetTimer(RechargeDelay, true);
		else
			SetTimer(RechargeDelay * 0.1 * AmmoAmount, true);
	}

	Begin:
		SetTimer(RechargeDelay, true);
}

defaultproperties
{
     AmmoAmount=50
     MaxAmmo=50
     RechargeDelay=1.0
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bCollideActors=False
}