class WFNapalmGrenade extends WFS_PCSGrenadeProj;

var() float DamageRadius;

simulated function PostBeginPlay()
{
	local vector X, Y, Z;

	super(Projectile).PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
		RandSpin(50000);
		bCanHitOwner = False;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = True;
			Disable('Tick');
			Velocity=0.6*Velocity;
		}
	}
}

simulated function Explosion(vector HitLocation)
{
	local effects e;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
  		e = spawn(class'UT_SpriteBallExplosion',,,HitLocation);
		e.RemoteRole = ROLE_None;
  		e = spawn(class'WFNapalmExplosion',,,HitLocation);
		e.RemoteRole = ROLE_None;
	}
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

defaultproperties
{
	DamageRadius=200.0
	Damage=30.0
	AnimSequence=WingIn
	Mesh=LodMesh'Botpack.UTGrenade'
	DrawScale=0.75
	MyDamageType='NapalmGrenade'
	MomentumTransfer=20000
	Mesh=LodMesh'WF_Rocket'
	Skin=Texture'JWFRocket1'
}