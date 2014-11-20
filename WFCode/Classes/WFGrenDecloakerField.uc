//=============================================================================
// WFGrenDecloakerField.
//
// This actor is Server-side only.
// De-cloaks all players that come within the EffectRadius.
//=============================================================================
class WFGrenDecloakerField extends Triggers;

var() float DisruptTime;
var() float EffectRange;

var() float BaseEffectTime;
var() float RandomEffectTime;

var byte Team;
var bool bTeamSet;
var float LastEffectTime, NextEffectTime;

function PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(DisruptTime, true);
	LastEffectTime = Level.TimeSeconds;
	NextEffectTime = 5.0;
}

function Timer()
{
	local pawn P;
	local inventory Inv;

	if (CollisionRadius != EffectRange)
	{
		SetCollisionSize(EffectRange, EffectRange);
		CheckTouching();
	}

	if (!bTeamSet) return;

	foreach RadiusActors(class'pawn', P, EffectRange, Location)
	{
		if ( (P != None) && P.bIsPlayer && !SameTeamAs(P) )
			Decloak(P);
	}
}

function Decloak(pawn Other)
{
	local inventory Inv;

	if (Other == None)
		return;

	for (Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory)
	{
		if (Inv.IsA('ut_invisibility'))
			Inv.Charge = 0;
		else if (Inv.IsA('WFCloaker') && Inv.bActive)
		{
			WFCloaker(Inv).ActivateDelay = 0;
			Inv.Activate();
			WFCloaker(Inv).ActivateDelay = 5;
		}
	}
}

function CheckTouching()
{
	local int i;
	for (i=0; i<4; i++)
		if (Touching[i] != None)
			Touch(Touching[4]);
}

function SetTeam(int NewTeam)
{
	bTeamSet = true;
	Team = NewTeam;
}

function bool SameTeamAs(pawn Other)
{
	if (Team == 255)
		return false;
	else if (Team == Other.PlayerReplicationInfo.Team)
		return True;

	return false;
}

function Touch( actor Other )
{
	local pawn P;

	if (!bTeamSet) return;

	P = pawn(Other);
	if ( (P != None) && P.bIsPlayer && !SameTeamAs(P))
		Decloak(P);
}

function Tick(float DeltaTime)
{
	local actor a;
	if ((Level.TimeSeconds - LastEffectTime) >= NextEffectTime)
	{
		a = spawn(class'WFGrenDecloakerFieldEffect',,, Location + 8*vect(0,0,1));
		if (a != None)
		{
			a.SetBase(Owner);
			LastEffectTime = Level.TimeSeconds;
			NextEffectTime = BaseEffectTime + FRand()*RandomEffectTime;
		}
	}
}

defaultproperties
{
	DisruptTime=0.100000
	EffectRange=400.000000
	RemoteRole=ROLE_None
	bStatic=False
	bStasis=False
	bCollideActors=True
	BaseEffectTime=10.0
	RandomEffectTime=0.0
}