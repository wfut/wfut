class WFBioRifleGel extends UT_Biogel;

function Timer()
{
	local ut_GreenGelPuff f;

	f = spawn(class'ut_GreenGelPuff',,,Location + SurfaceNormal*8);
	f.numBlobs = numBio;
	if ( numBio > 0 )
		f.SurfaceNormal = SurfaceNormal;
	PlaySound (MiscSound,,3.0*DrawScale);
	if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )
		Base.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

	DamageRadius(damage * Drawscale, FMin(250, DrawScale * 75), MyDamageType, MomentumTransfer * Drawscale, Location);
	Destroy();
}

final function DamageRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local WFStatusInfected s;
	local pawn aPawn;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);

			if ((Victims.bIsPawn) && (Victims != Instigator))
			{
				aPawn = pawn(Victims);
				if (aPawn.bIsPlayer && (aPawn.Health > 0)
					&& (aPawn.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team))
				{
					s = WFStatusInfected(aPawn.FindInventoryType(class'WFStatusInfected'));
					if (s != None)
						s.DamageAmount = s.default.DamageAmount * 2.0;
				}
			}
		}
	}
	bHurtEntry = false;
}
