//=============================================================================
// WFInfected.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFStatusInfected extends WFStatusConcussed;

var() int InfectionTime;

var() int DamageAmount;
var() name DamageType;
var() bool bRandomDamage;
var() int DamageTime; // amount of time between damage

var() bool bInfectOtherPlayers;
var() float InfectRange;
var() int RandInfectTime;
var() int RandInfectTimeAdd;
var() float InfectChance; // chance of infecting players within range (0.0 - 1.0)

var int InfectionTimeLeft;
var int InfectTimeLeft;
var int DamageTimeLeft;

function ServerInitialise()
{
	InfectionTime *= ScaleFactor;
	DamageAmount *= ScaleFactor;

	InfectionTimeLeft = InfectionTime;
	DamageTimeLeft = DamageTime;

	bInfectOtherPlayers = (InfectRange > 0) && (InfectChance > 0.0);

	SetTimer(1.0, true);
}

function Timer()
{
	local int Damage;
	local pawn aPawn;

	if (Owner == None)
	{
		SetTimer(0.0, false);
		Destroy();
		return;
	}

	if (InfectionTime > 0)
	{
		InfectionTimeLeft--;
		if (InfectionTimeLeft <=0)
		{
			SetTimer(0.0, false);
			UsedUp();
			return;
		}
	}

	if (DamageTime > 0)
	{
		DamageTimeLeft--;
		if (DamageTimeLeft == 0)
		{
			if (bRandomDamage) Damage = Rand(Damage)+1;
			else Damage = DamageAmount;
			Owner.TakeDamage(Damage, StatusInstigator, vect(0,0,0), vect(0,0,0), DamageType);
			DamageTimeLeft = DamageTime;
		}
	}

	if (bInfectOtherPlayers && (RandInfectTime > 0))
	{
		InfectTimeLeft--;
		//InfectTouchingPlayers();
		if (InfectTimeLeft <= 0)
		{
			//Log(self.name$": Timer(): Infecting players within range.");
			foreach VisibleCollidingActors(class'Pawn', aPawn, InfectRange, Owner.Location, true)
				if ((aPawn != None) && aPawn.bIsPlayer && (FRand() <= InfectChance))
					InfectPlayer(aPawn);
			spawn(class'UT_GreenGelPuff',,, Owner.Location);
			InfectTimeLeft = Rand(RandInfectTime) + RandInfectTimeAdd;
		}
	}
}

function InfectPlayer(pawn Other)
{
	local inventory Inv;
	local WFPlayerStatus S;
	local class<WFPlayerClassInfo> PCI;

	//Log(self.name$": Infecting player: "$Other$" (StatusInstigator: "$StatusInstigator$")");

	// don't infect players on the same team that caused the status
	if (Team == Other.PlayerReplicationInfo.Team)
		return;

	// don't infect players that are immune to this status type
	PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
	if ((PCI != None) && PCI.static.IsImmuneTo(Class))
		return;

	// don't infect players that already have it
	Inv = Other.FindInventoryType(Class);
	if (Inv != None)
		return;

	S = spawn(Class, StatusInstigator,, Other.Location, Other.Rotation);
	S.GiveStatusTo(Other, StatusInstigator);
}

function InfectTouchingPlayers()
{
	local int i;
	local pawn aPawn;
	for (i=0; i<4; i++)
	{
		if (Touching[i] != None)
		{
			aPawn = pawn(Touching[i]);
			if (aPawn != None)
				InfectPlayer(aPawn);
		}
	}
}

defaultproperties
{
	PickupMessage="You have been infected!"
	ExpireMessage="The infection has worn off."
	InfectionTime=80.000000
	DamageTime=2
	DamageAmount=5
	RandInfectTime=12
	RandInfectTimeAdd=4
	InfectChance=0.500000
	InfectRange=150.000000
	DamageType=InfectedStatus
	PlayerViewSway=(Pitch=100,Yaw=100,Roll=100)
	bConstantPitch=True
	bConstantYaw=True
	bConstantRoll=True
	FOVTime=0.000000
	StatusID=3
	StatusType="Infected"
	DeathMessage="%o was killed by %k's infectious disease."
}