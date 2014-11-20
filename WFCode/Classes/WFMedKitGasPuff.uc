class WFMedKitGasPuff extends Projectile;

var() float InfectOdds;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(0.5, true);
	Velocity = vector(Rotation)*FMin((Speed + FRand()*100), MaxSpeed);
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

	if ((Role != ROLE_Authority) || (Other == None))
		return;

	if ((Other != Instigator) && Other.bIsPlayer)
	{
		Other.TakeDamage(5, Instigator, HitLocation, vect(0,0,0), 'Gassed');
		if (Other.Health > 0)
		{
			PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
			bGiveStatus = ((PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusInfected'))
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
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-1.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);
	if ( speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
	InfectOdds=0.5
	speed=500.0
	maxspeed=700.0
	lifespan=1.0
	Texture=texture'g2r_a02'
	sprite=texture'g2r_a02'
	DrawType=DT_SpriteAnimOnce
	Physics=PHYS_Projectile
	CollisionRadius=20
	CollisionHeight=20
	Style=STY_Translucent
	bBounce=True
	RemoteRole=ROLE_SimulatedProxy
}