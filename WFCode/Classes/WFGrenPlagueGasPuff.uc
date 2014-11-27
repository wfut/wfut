class WFGrenPlagueGasPuff extends Projectile;

var() float SpinSpeed;
var() float InfectOdds;

simulated function PostBeginPlay()
{
	Velocity = speed * vector(Rotation);
	RandSpin(SpinSpeed);
	SetTimer(0.5, true);
	PlayOwnedSound(SpawnSound);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	CauseDamage(pawn(Other), HitLocation);
}

function CauseDamage(pawn Other, vector HitLocation)
{
	local class<WFPlayerClassInfo> PCI;
	local WFStatusInfected s;
	local bool bGiveStatus;
	local WFPlayer WFP;

	if ((Other == None) || (Role != ROLE_Authority))
		return;

	if ((Other != Instigator) && Other.bIsPlayer)
	{
		Other.TakeDamage(Damage, Instigator, HitLocation, vect(0,0,0), 'PlagueGrenade');
		if (Other.Health > 0)
		{
			//WFP = WFPlayer(Other);
			//PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
			//bGiveStatus = ((PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusInfected'))
			bGiveStatus = !class'WFPlayerClassInfo'.static.PawnIsImmuneTo(Other, class'WFStatusInfected')
				&& (Other.FindInventoryType(class'WFStatusVaccinated') == None);
			bGiveStatus = bGiveStatus && (Other.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team);
			if (bGiveStatus && (FRand() <= InfectOdds))
			{
				s = WFStatusInfected(Other.FindInventoryType(class'WFStatusInfected'));
				if (s == None)
				{
					s = spawn(class'WFStatusInfected',,, Other.Location);
					s.GiveStatusTo(Other, Instigator);
				}
				else s.InfectionTimeLeft = s.InfectionTime;
			}
		}
	}
}

function Timer()
{
	local pawn p;
	foreach VisibleCollidingActors(class'Pawn', p, CollisionRadius)
		if (p != None) CauseDamage(p, p.Location + normal(location - p.location)*p.CollisionRadius);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity = 0.9*(( Velocity dot HitNormal ) * HitNormal * (-1.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);
	if ( speed < 20 )
		bBounce = False;
}

defaultproperties
{
	Damage=1
	InfectOdds=0.25
	Speed=50
	MaxSpeed=75
	SpinSpeed=10000
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'BarrelM'
	Texture=Texture'G3R_a09'
	bFixedRotationDir=True
	bNetTemporary=True
	bParticles=True
	LifeSpan=5.0
	DrawScale=2.0
	LODBias=0.0
	CollisionRadius=30.0
	CollisionHeight=30.0
	SpawnSound=sound'Vapour'
}
