class WFGrenFreezeCloud extends Projectile;

var() float SpinSpeed;

simulated function PostBeginPlay()
{
	//Velocity = speed * vector(Rotation);
	RandSpin(SpinSpeed);
	SetTimer(0.5, true);
	PlayOwnedSound(SpawnSound);
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
	FreezePlayer(pawn(Other), HitLocation);
}

function FreezePlayer(pawn Other, vector HitLocation)
{
	local bool bGiveStatus, bSameTeam;
	local WFPlayerStatus s;
	local class<WFPlayerClassInfo> PCI;

	if ((Other != Instigator) && Other.bIsPlayer)
	{
		if ((Other != None) && Other.bIsPawn)
		{
			if ((Other.Health > 0) && ((Instigator == None) || (Other.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)))
			{
				PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
				bGiveStatus = (PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusFrozen');
				if (bGiveStatus)
				{
					s = spawn(class'WFStatusFrozen',,, Other.Location);
					s.GiveStatusTo(Other, Instigator);
				}
			}
		}
	}
}

function Timer()
{
	local pawn p;
	foreach VisibleCollidingActors(class'Pawn', p, CollisionRadius)
		if (p != None) FreezePlayer(p, p.Location + normal(location - p.location)*p.CollisionRadius);
}

defaultproperties
{
	SpinSpeed=10000
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'BarrelM'
	Texture=Texture'WFPSmoke1'
	bFixedRotationDir=True
	bNetTemporary=True
	bCollideWorld=False
	bParticles=True
	LifeSpan=5.0
	DrawScale=2.0
	LODBias=0.0
	CollisionRadius=50.0
	CollisionHeight=50.0
	SpawnSound=sound'Vapour'
	bUnlit=True
}