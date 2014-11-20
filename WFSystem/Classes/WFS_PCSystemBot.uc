//=============================================================================
// WFS_PCSystemBot.
// TODO: Need to add AI hooks for the PCI classes, so that the class specific
//       bot AI can be localised there.
//=============================================================================
class WFS_PCSystemBot extends WFD_DPMSBot;

var class<WFS_PlayerClassInfo>		PCInfo;		// the player class info var
var Actor						RelatedActors[8];

var class<WFS_PlayerClassInfo>		BotRestartClass;

var name FreezeTag;
var float FreezeTime;

replication
{
	// needs to be set SERVER SIDE
	reliable if (Role == ROLE_Authority)
		PCInfo;
}

//-----------------------------------------------------------------------------
// --- Basic Bot PCI code ---

// Current PCI bot functions:

// Returns true if bot can actully collect item (ie. item is valid)
// PCInfo.static.BotCanCollectItem(bot aBot, class<inventory> ItemClass)

// --- PCI Notifications ---

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType)
{
	local byte bIgnoreDamage;

	bIgnoreDamage = 0;
	if ((PCInfo != none) && (Role == ROLE_Authority))
		PCInfo.static.PlayerTakeDamage(self, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);

	if (!bool(bIgnoreDamage))
		super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	if (PCInfo != none)
		PCInfo.static.PlayerDied(self, Killer, damageType, HitLocation);

	Super.Died(Killer, damageType, HitLocation);
}

// --- Inventory AI ---
function bool CanCollectInventoryType(class<inventory> ItemClass)
{
	local bool bIsSuperHealth;

	if (PCInfo == None)
		return true;

	if (ClassIsChildOf(ItemClass, class'TournamentHealth'))
	{
		bIsSuperHealth = class<TournamentHealth>(ItemClass).default.bSuperHeal;
		if ( (Health < PCInfo.default.Health)
			|| (bIsSuperHealth && (Health < PCInfo.default.MaxHealth)) )
			return true;
	}

	if (PCInfo.static.ValidInventoryType(self, ItemClass))
		return true;

	return false;
}

function bool CanCollectItem(inventory Item)
{
	if (Item != None)
		return CanCollectInventoryType(Item.Class);

	return false;
}

// Frozen Bot state code.
function FreezeBot(optional float NewFreezeTime, optional name NewFreezeTag)
{
	if (IsInState('Dying') || IsInState('StartUp'))
		return;

	FreezeTime = NewFreezeTime;
	FreezeTag = NewFreezeTag;
	GotoState('Frozen');
}
function UnfreezeBot(optional name UnfreezeTag);

// FIXME: bots are still able to exit state
state Frozen
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange,
	FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, PainTimer,
	AlterDestination, UpdateTactics, SetOrders, FireWeapon, MayFall;

	function BeginState()
	{
		SetTimer(0, false);
		Enemy = None;
		if ( bSniping && (AmbushSpot != None) )
			AmbushSpot.taken = false;
		AmbushSpot = None;
		//PointDied = -1000;
		bFire = 0;
		bAltFire = 0;
		bSniping = false;
		bKamikaze = false;
		bDevious = false;
		bDumbDown = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		SetTimer(FreezeTime, false);
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		MoveTimer = -1;
		MoveTarget = None;
		bCanFire = false;
	}

	function Timer()
	{
		UnfreezeBot('TimerEndFrozenState');
	}

	function FreezeBot(optional float NewFreezeTime, optional name NewFreezeTag)
	{
		if ((TimerRate - TimerCounter) < NewFreezeTime)
		{
			FreezeTag = NewFreezeTag;
			FreezeTime = NewFreezeTime;
			SetTimer(NewFreezeTime, false);
		}
	}

	function Bump(actor Other)
	{
		//Log("-- Bump called from State Frozen!");
	}

	function HitWall(vector HitNormal, actor Wall)
	{
	}

	function SeePlayer(Actor SeenPlayer)
	{
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
	}

	function UnfreezeBot(optional name UnfreezeTag)
	{
		if ( (FreezeTag == '') || (UnfreezeTag == 'TimerEndFrozenState')
			|| (UnfreezeTag == FreezeTag) )
		{
			FreezeTime = 0.0;
			FreezeTag = '';
			WhatToDoNext('','');
		}
	}

}

defaultproperties
{
}
