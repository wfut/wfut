class WFNapalmRocket extends RocketMk2;

var() float DamageRadius;

auto state Flying
{
	function BlowUp(vector HitLocation)
	{
		local actor Victims;
		local pawn aPawn;
		local float damageScale, dist;
		local vector dir;
		local WFStatusOnFire s;
		local bool bGiveStatus;
		local class<WFPlayerClassInfo> PCI;

		if( bHurtEntry )
			return;

		bHurtEntry = true;
		foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
		{
			if ((Victims != None) && (Victims != self))
			{
				dir = Victims.Location - HitLocation;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

				Victims.TakeDamage
				(
					damageScale * Damage,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * MomentumTransfer * dir),
					MyDamageType
				);

				aPawn = None;
				bGiveStatus = false;
				if ((Victims.bIsPawn) && (Victims != Instigator))
				{
					aPawn = pawn(Victims);
					if (aPawn.bIsPlayer && (aPawn.Health > 0))
					{
						PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(aPawn));
						bGiveStatus = (PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusOnFire');

						if (bGiveStatus && (aPawn.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team))
						{
							s = WFStatusOnFire(aPawn.FindInventoryType(class'WFStatusOnFire'));
							if (s != None)
								s.OnFireTimeCount = 0;
							else
							{
								s = spawn(class'WFStatusOnFire',,,aPawn.Location);
								s.GiveStatusTo(aPawn, Instigator);
							}
						}
					}
				}
			}
		}
		bHurtEntry = false;
		MakeNoise(1.0);
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local effects e;

		e = spawn(class'UT_SpriteBallExplosion',,,HitLocation + HitNormal*16);
 		e.RemoteRole = ROLE_None;

 		e = spawn(class'WFNapalmExplosion',,, HitLocation + HitNormal*16);
 		e.RemoteRole = ROLE_None;

		BlowUp(HitLocation);

 		Destroy();
	}
}

defaultproperties
{
	Damage=25
	DamageRadius=200.0
	MyDamageType='NapalmRocket'
	MomentumTransfer=40000
	Mesh=LodMesh'WF_Rocket'
	DrawScale=1.0
	Skin=Texture'JWFRocket1'
}