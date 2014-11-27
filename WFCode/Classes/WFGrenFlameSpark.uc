class WFGrenFlameSpark extends Projectile;

var() float DamageRadius;

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	Super.PostBeginPlay();

	PlayOwnedSound(SpawnSound);
	if ( Role == ROLE_Authority )
	{
		Velocity = vector(Rotation)*Speed;
		Velocity.z += 200 - 100*FRand();
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
	Spawn(Class'BallExplosion',,, Location);
	Destroy();
}

function BlowUp(vector HitLocation)
{
	local actor Victims;
	local pawn aPawn;
	local float damageScale, dist;
	local vector dir;
	local WFStatusOnFire s;
	local bool bGiveStatus;
	local class<WFPlayerClassInfo> PCI;
	local WFPlayer WFP;

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
					//WFP = WFPlayer(aPawn);
					//PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(aPawn));
					//bGiveStatus = (PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusOnFire');
					bGiveStatus = !class'WFPlayerClassInfo'.static.PawnIsImmuneTo(aPawn, class'WFStatusOnFire');

					if (bGiveStatus && (aPawn.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team))
					{
						s = WFStatusOnFire(aPawn.FindInventoryType(class'WFStatusOnFire'));
						if (s != None)
							s.OnFireTimeCount = 0;
						else
						{
							s = spawn(class'WFStatusOnFire',,,aPawn.Location);
							s.GiveStatusTo(aPawn, Instigator, 2.0);
						}
					}
				}
			}
		}
	}
	bHurtEntry = false;
	MakeNoise(1.0);
}

defaultproperties
{
	Speed=100
	DamageRadius=200
	Mass=10
	Damage=30
	SpawnSound=Sound'UnrealShare.Pickups.flares1'
	Physics=PHYS_Falling
	DrawType=DT_Sprite
	RemoteRole=ROLE_SimulatedProxy
	//Texture=Texture'Flakmuz'
	//DrawScale=0.05
	Texture=Texture'UnrealShare.Effects.T_PBurst'
	DrawScale=0.5
	SpriteProjForward=16.0
	Style=STY_Translucent
	MyDamageType=FlameGrenade
	bNetTemporary=True
	bBounce=True
	AmbientSound=sound'flarel1'
	LightBrightness=199
	LightHue=25
	LightSaturation=89
	LightRadius=33
}