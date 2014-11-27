class WFGasStreamPuff extends Projectile;

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
	local WFPlayer WFP;

	if ((Level.NetMode == NM_Client) || (Other == None))
		return;

	if ((Other != Instigator) && Other.bIsPlayer)
	{
		Other.TakeDamage(1*byte(FRand()<0.2), Instigator, HitLocation, vect(0,0,0), 'Gassed');
		if (Other.Health > 0)
		{
			//WFP = WFPlayer(Other);
			//PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
			//bGiveStatus = ((PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusInfected'))
			bGiveStatus = (!class'WFPlayerClassInfo'.static.PawnIsImmuneTo(Other, class'WFStatusInfected'))
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
	InfectOdds=0.33
	speed=650.0
	maxspeed=700.0
	lifespan=0.25
	Texture=texture'g2r_a02'
	sprite=texture'g2r_a02'
	DrawType=DT_SpriteAnimOnce
	Physics=PHYS_Projectile
	CollisionRadius=20
	CollisionHeight=20
	Style=STY_Translucent
	bBounce=True
	RemoteRole=ROLE_None
}