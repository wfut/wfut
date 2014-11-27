class WFHealingDepot extends StationaryPawn;

var() float HealingRate;
var() int HealingAmount;

var() sound HealingSound;

var() string CureStatusTypes[16];

var() float MoveDelay;
var float LastMoved;

var() texture TeamSkinsBody[4];
var() texture TeamSkinsTop[4];

var WFHealingDepotEffect MyEffect;
var vector EffectOffset;

var pawn PlayerOwner;
var int Team;

replication
{
	reliable if (Role == ROLE_Authority)
		MyEffect;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(HealingRate, true);
	spawn(class'EnhancedRespawn', self,, Location);
	if (Role == ROLE_Authority)
		MyEffect = spawn(class'WFHealingDepotEffect', self,, Location + EffectOffset);
}

simulated function Tick(float DeltaTime)
{
	if ((MyEffect != None) && (MyEffect.Location != Location + EffectOffset))
		MyEffect.SetLocation(Location + EffectOffset);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if (Health <= 0)
		return;

	if ((instigatedBy != None) && (instigatedBy.PlayerReplicationInfo.Team == Team))
		return;

	Health -= Damage;
	if (Health <= 0)
		Explode();
}

function Explode()
{
	spawn(class'ut_SpriteBallExplosion',,, Location + vect(0,0,16));
	if (PlayerOwner != None)
		PlayerOwner.ClientMessage("Your Healing Depot was destroyed!", 'CriticalEvent');
	Destroy();
}

function Timer()
{
	local pawn p;
	//local bool bHealing;
	local int i;
	local float best, dist;

	//bHealing = false;

	best = 100;
	p = None;
	for (i=0; i<4; i++)
	{
		if ((Touching[i] != None) && Touching[i].bIsPawn)
		{
			dist = VSize(Touching[i].Location - Location);
			if ( (p == None) || ((dist <= CollisionRadius) && (dist < best)) )
			{
				best = dist;
				p = pawn(Touching[i]);
			}
		}
	}

	//bHealing = (p != None);
	HealPlayer(p);

	//if (bHealing) AmbientSound = HealingSound;
	//else AmbientSound = None;
}

function HealPlayer(pawn Other)
{
	local effects e;
	local int MaxHealth;

	if (ValidTarget(Other))
	{
		MaxHealth = GetMaxHealthFor(Other);
		if (Other.Health < MaxHealth)
		{
			Other.Health = Min(Other.Health + HealingAmount, MaxHealth);
			e = Spawn(class'WFMedKitHealEffect', Other,, Other.Location);
			e.Mesh = Other.Mesh;
		}
		CurePlayer(Other);
	}
}

function bool ValidTarget(pawn Other)
{
	if ( (Other != None) && Other.bIsPlayer && (Other.Health > 0)
		&& (Other.PlayerReplicationInfo.Team == Team) )
		return true;

	return false;
}

function CurePlayer(pawn Other)
{
	local WFPlayerStatus Status;
	local inventory Item, NextItem;
	local int num;
	local bool bCuredStatus;
	local effects e;

	Item = Other.Inventory;
	NextItem = None;
	bCuredStatus = false;
	while (Item != None)
	{
		NextItem = Item.Inventory;
		Status = WFPlayerStatus(Item);
		if ((Status != None) && CanCure(Status.StatusType))
		{
			bCuredStatus = true;
			Status.Destroy();
		}
		Item = NextItem;
	}

	if (bCuredStatus)
	{
		e = Spawn(class'WFMedKitHealEffect', Other,, Other.Location);
		e.Mesh = Other.Mesh;
	}
}

function bool CanCure(string StatusType)
{
	local int i;
	for (i=0; i<16; i++)
		if (StatusType ~= CureStatusTypes[i])
			return true;

	return false;
}

function bool MoveDepot(vector NewLocation)
{
	local effects e;
	local vector OldLocation;

	if ((Level.TimeSeconds - LastMoved) < MoveDelay)
		return false;

	OldLocation = Location;
	if (SetLocation(NewLocation))
	{
		e = spawn(class'TranslocOutEffect', self,, OldLocation);
		e.Mesh = Mesh;

		e = spawn(class'EnhancedRespawn', self,, Location);
		e.Mesh = Mesh;

		LastMoved = Level.TimeSeconds;
		return true;
	}

	return false;
}

function RemoveDepot()
{
	local effects e;
	e = spawn(class'TranslocOutEffect', self,, Location);
	e.Mesh = Mesh;
	Destroy();
}

function int GetMaxHealthFor(pawn Other)
{
	local class<WFS_PlayerClassInfo> PCI;

	PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
	if (PCI != None)
		return PCI.default.Health;

	return Other.default.Health;
}

function SetTeam(int NewTeam)
{
	Team = NewTeam;
	MultiSkins[1] = TeamSkinsBody[NewTeam];
	MultiSkins[2] = TeamSkinsTop[NewTeam];
	if (MyEffect != None)
		MyEffect.SetTeam(NewTeam);
}

function SetPlayerOwner(pawn Other)
{
	PlayerOwner = Other;
}

function Destroyed()
{
	if (MyEffect != None)
		MyEffect.Destroy();
	super.Destroyed();
}

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	return true;
}

defaultproperties
{
	HealingRate=1.0
	MoveDelay=2.5
	HealingAmount=20
	Health=75
	RemoteRole=ROLE_SimulatedProxy
	bBlockActors=false
	bBlockPlayers=false
	Physics=PHYS_Falling
	Mesh=LodMesh'WF_Depot'
	CureStatusTypes(0)="Infected"
	CureStatusTypes(1)="Concussed"
	CureStatusTypes(2)="Blinded"
	CureStatusTypes(3)="Tranquilised"
	CureStatusTypes(4)="Leg damage"
	TeamSkinsBody(0)=Texture'WF_HDepotBodyRed'
	TeamSkinsBody(1)=Texture'WF_HDepotBodyBlue'
	TeamSkinsBody(2)=Texture'WF_HDepotBodyGreen'
	TeamSkinsBody(3)=Texture'WF_HDepotBodyGold'
	TeamSkinsTop(0)=Texture'WF_HDepotTopRed'
	TeamSkinsTop(1)=Texture'WF_HDepotTopBlue'
	TeamSkinsTop(2)=Texture'WF_HDepotTopGreen'
	TeamSkinsTop(3)=Texture'WF_HDepotTopGold'
	CollisionRadius=28.000000
	CollisionHeight=2.500000
	EffectOffset=(Z=35.0)
	AnimSequence=Depot
}