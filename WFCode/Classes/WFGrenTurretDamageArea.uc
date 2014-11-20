class WFGrenTurretDamageArea extends Decoration;

var WFGrenTurretProj MyGren;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if ((MyGren != None) && (MyGren.Health > 0))
		MyGren.GrenTakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bProjTarget=True
	bCollideActors=True
	bBlockActors=False
	bBlockPlayers=False
	CollisionRadius=8
	CollisionHeight=8
	Physics=PHYS_Trailer
	bStatic=False
}