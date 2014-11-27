//=============================================================================
// WFTranslocator.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFTranslocator extends Translocator;

var() float TranslocateDelay;
var() float MaximumRange;
var() int AmmoUsed;
var() float OverHeatTime; // TL overheats if MaxTL translocations done within OverHeatTime
var() byte MaxTL; // number of TLs done within OverHeatTime to overheat translocator
var() float MessageDelay;

var float LastUsed, LastMessage;
var float TLTimes[10]; // buffer of TL usage times

// TODO: Add TL overheating warning (either sound, an icon on HUD, or a message)

function ThrowTarget()
{
	local Vector Start, X,Y,Z;

	if (Level.Game.LocalLog != None)
		Level.Game.LocalLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	if (Level.Game.WorldLog != None)
		Level.Game.WorldLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);

	if ( Owner.IsA('Bot') )
		bBotMoveFire = true;
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	Pawn(Owner).ViewRotation = Pawn(Owner).AdjustToss(TossForce, Start, 0, true, true);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	TTarget = Spawn(class'WFTranslocatorTarget',,, Start);
	if (TTarget!=None)
	{
		bTTargetOut = true;
		TTarget.Master = self;
		if ( Owner.IsA('Bot') )
			TTarget.SetCollisionSize(0,0);
		TTarget.Throw(Pawn(Owner), MaxTossForce, Start);
	}
	else GotoState('Idle');
}

function Translocate()
{
	local vector Dest, Start;
	local Bot B;
	local Pawn P;
	local bool bTLOverHeated;

	if ((TranslocateDelay > 0.0) && (LastUsed > 0.0) && ((Level.TimeSeconds - LastUsed) < TranslocateDelay))
	{
		SendMessage(pawn(Owner), "Translocator is recharging ("$TranslocateDelay$" second delay between uses)");
		return;
	}

	if (AmmoType.AmmoAmount < AmmoUsed)
	{
		SendMessage(pawn(Owner), "Not enough ammo to translocate ("$AmmoUsed$" ammo needed)");
		return;
	}

	bBotMoveFire = false;
	PlayAnim('Thrown', 1.2,0.1);
	Dest = TTarget.Location;
	if ( TTarget.Physics == PHYS_None )
		Dest += vect(0,0,40);

	// check the range of the translocation
	if ( (MaximumRange > 0) && (VSize(Owner.Location - Dest) > MaximumRange) )
	{
		SendMessage(pawn(Owner), "Too far from destination pod");
		return;
	}

	if ( Level.Game.IsA('DeathMatchPlus')
		&& !DeathMatchPlus(Level.Game).AllowTranslocation(Pawn(Owner), Dest) )
		return;

	bTLOverheated = TLFailure();

	Start = Pawn(Owner).Location;
	TTarget.SetCollision(false,false,false);
	if ( Pawn(Owner).SetLocation(Dest) )
	{
		if ( !Owner.Region.Zone.bWaterZone )
			Owner.SetPhysics(PHYS_Falling);
		if ( TTarget.Disrupted() || bTLOverHeated)
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			SpawnEffect(Start, Dest);
			// TODO: add death messaged for TL overheating
			if (bTLOverHeated)
			{
				LastMessage = 0;
				SendMessage(pawn(Owner), "Your Translocator overheated!", true);
				Pawn(Owner).gibbedBy(pawn(Owner));
			}
			else Pawn(Owner).gibbedBy(TTarget.disruptor);
			return;
		}

		if ( !FastTrace(Pawn(Owner).Location, TTarget.Location) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Pawn(Owner).SetLocation(Start);
			Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		}
		else
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Owner.Velocity.X = 0;
			Owner.Velocity.Y = 0;
			B = Bot(Owner);
			if ( B != None )
			{
				if ( TTarget.DesiredTarget.IsA('NavigationPoint') )
					B.MoveTarget = TTarget.DesiredTarget;
				B.bJumpOffPawn = true;
				if ( !Owner.Region.Zone.bWaterZone )
					B.SetFall();
			}
			else
			{
				// bots must re-acquire this player
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( (P.Enemy == Owner) && P.IsA('Bot') )
						Bot(P).LastAcquireTime = Level.TimeSeconds;
			}

			Level.Game.PlayTeleportEffect(Owner, true, true);
			SpawnEffect(Start, Dest);

			TranslocatorUsed();
		}
	}
	else
	{
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	}

	if ( TTarget != None )
	{
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
	}
	bPointing=True;
}

// reduce resources
function TranslocatorUsed()
{
	local int i;
	AmmoType.UseAmmo(AmmoUsed);

	// store the time translocator was fired
	LastUsed = Level.TimeSeconds;

	MaxTL = Clamp(MaxTL, 0, ArrayCount(TLTimes)-1);
	for (i=(MaxTL-1); i>=0; i--)
		TLTimes[i+1] = TLTimes[i];
	TLTimes[0] = LastUsed;
}

function bool TLFailure()
{
	MaxTL = Clamp(MaxTL, 0, ArrayCount(TLTimes)-1);
	//Log("TLTimes[]: "$GetPropertyText("TLTimes"));
	//Log("TLTimes[0]: "$TLTimes[0]);
	//Log("TLTimes[MaxTL-1]: "$TLTimes[MaxTL-1]);
	if ((TLTimes[MaxTL-1] > 0.0) && (TLTimes[0] > 0.0)
		&& ((TLTimes[0] - TLTimes[MaxTL-1]) < OverHeatTime) )
		return true;
	return false;
}

function SendMessage(pawn Other, coerce string Message, optional bool bBeep)
{
	if ( (Other != None) && ((Level.TimeSeconds - LastMessage) > MessageDelay) )
	{
		LastMessage = Level.TimeSeconds;
		Other.ClientMessage(Message, 'CriticalEvent', bBeep);
	}
}

defaultproperties
{
	AmmoName=Class'WFTranslocatorAmmo'
	PickupAmmoCount=50
	AmmoUsed=15
	TranslocateDelay=5
	OverHeatTime=10.000000
	MaxTL=5
	MessageDelay=1.0
	StatusIcon=Texture'WFMedia.WeaponTranslocator'
}
