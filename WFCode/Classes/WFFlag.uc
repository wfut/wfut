//=============================================================================
// WFFlag.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// TODO: Add support for an alternate cap point for flags (might have to use
//       a WFMarker for the bot navigation code).
//=============================================================================
class WFFlag extends CTFFlag;

var bool bReturning; // the flag is being carried back by a player
var WFMarker CapturePoint; // the place where the flag is taken for a cap

var pawn IgnoreTouch;
var float IgnoreTime;
var() float IgnoreDelay;

replication
{
	reliable if (Role == ROLE_Authority)
		bReturning;
}

function Drop(vector newVel)
{
	if (IgnoreDelay > 0.0)
	{
		IgnoreTouch = Holder;
		IgnoreTime = IgnoreDelay;
	}
	super.Drop(newVel);
}

state Dropped
{
	function BeginState()
	{
		local float ReturnTime;
		LightEffect = LE_NonIncidence;
		// might need to remove this CarryReturn check
		if (WFGame(Level.Game).FlagReturnStyle != class'WFGame'.default.FRS_CarryReturn)
		{
			ReturnTime = WFGame(Level.Game).FlagReturnTime;
			if ((ReturnTime <= 0.0) && (WFGame(Level.Game).FlagReturnStyle == class'WFGame'.default.FRS_DelayReturn))
				ReturnTime = 25.0;
			SetTimer(ReturnTime, false);
		}
		else SetTimer(0.0, false);
		bCollideWorld = true;
		bKnownLocation = false;
		bHidden = false;
	}

	function Touch(Actor Other)
	{
		local CTFFlag aFlag;
		local Pawn aPawn;
		local NavigationPoint N;
		local int num, i;

		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0)
			&& !aPawn.IsInState('FeigningDeath') && CanTouchFlag(aPawn))
		{
			// don't let a player collect a flag if already carrying one
			if ((aPawn.PlayerReplicationInfo.HasFlag != None)
				&& (WFGame(Level.Game).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn))
				return;

			aPawn.MoveTimer = -1;
			if (aPawn.PlayerReplicationInfo.Team == Team)
			{
				if (WFGame(Level.Game).FlagReturnStyle == class'WFGame'.default.FRS_TouchReturn)
				{
					// returned flag
					CTFGame(Level.Game).ScoreFlag(aPawn, self);
					SendHome();
					return;
				}
				else if (WFGame(Level.Game).FlagReturnStyle == class'WFGame'.default.FRS_DelayReturn)
				{
					if (aPawn.IsA('Bot'))
						Bot(aPawn).AlternatePath = None;
					return; // can't touch flag to return it for FRS_DelayReturn
				}
				else if (WFGame(Level.Game).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn)
				{
					bReturning = true;
					Holder = aPawn;
					Holder.PlayerReplicationInfo.HasFlag = self;
					SetHolderLighting();
					if ( Holder.IsA('Bot') )
					{
						Bot(Holder).AlternatePath = None;
						Holder.SendTeamMessage(None, 'OTHER', 8, 10);
					}
					else if ( Holder.IsA('TournamentPlayer') && TournamentPlayer(Holder).bAutoTaunt )
						Holder.SendTeamMessage(None, 'OTHER', 8, 10);

					// send flag collected event
					class'WFPlayerClassInfo'.static.SendEvent(pawn(Other), "flag_pickedup_own");

					BroadcastLocalizedMessage( class'CTFMessage', 4, Holder.PlayerReplicationInfo, None, CTFGame(Level.Game).Teams[Team] );
					if (Level.Game.WorldLog != None)
						Level.Game.WorldLog.LogSpecialEvent("flag_pickedup", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
					if (Level.Game.LocalLog != None)
						Level.Game.LocalLog.LogSpecialEvent("flag_pickedup", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
					GotoState('Held');
					return;
				}
			}
			else
			{
				Holder = aPawn;
				Holder.PlayerReplicationInfo.HasFlag = self;
				SetHolderLighting();
				if ( Holder.IsA('Bot') )
				{
					Bot(Holder).AlternatePath = None;
					Holder.SendTeamMessage(None, 'OTHER', 2, 10);
				}
				else if ( Holder.IsA('TournamentPlayer') && TournamentPlayer(Holder).bAutoTaunt )
					Holder.SendTeamMessage(None, 'OTHER', 2, 10);

				// send flag collected event
				class'WFPlayerClassInfo'.static.SendEvent(pawn(Other), "flag_pickedup");
			}
			BroadcastLocalizedMessage( class'CTFMessage', 4, Holder.PlayerReplicationInfo, None, CTFGame(Level.Game).Teams[Team] );
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("flag_pickedup", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("flag_pickedup", Holder.PlayerReplicationInfo.PlayerID, CTFGame(Level.Game).Teams[Team].TeamIndex);
			GotoState('Held');
		}
	}
}

state Held
{
	function BeginState()
	{
		bHeld = true;
		if (!bReturning && (Team == Holder.PlayerReplicationInfo.Team))
			bReturning = true;
		bCollideWorld = false;
		bKnownLocation = false;
		if (!bReturning)
			HomeBase.PlayAlarm();
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		SetTimer(10.0, true);
	}

	function EndState()
	{
		bHeld = false;
		bReturning = false;
	}
}

auto state Home
{
	function Touch(actor Other)
	{
		local pawn aPawn;
		local CTFFlag aFlag;

		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer )
		{
			if (!CanTouchFlag(aPawn))
				return;

			// don't let a player collect a flag if already carrying one
			if ( (aPawn.PlayerReplicationInfo.Team != Team) && (aPawn.PlayerReplicationInfo.HasFlag != None) )
				return;

			// flag must be capped at the CapturePoint if one exists
			if ( (CapturePoint != None) && (aPawn.PlayerReplicationInfo.Team == Team)
				&& (aPawn.PlayerReplicationInfo.HasFlag != None) )
					return;
		}

		super.Touch(Other);
	}
}

function bool CanTouchFlag(pawn Other)
{
	if (Other != None)
	{
		if (Other == IgnoreTouch)
			return false;

		if (Other.IsA('WFPlayer'))
			return !WFPlayer(Other).bFlagTouchDisabled;
		else if (Other.IsA('WFBot'))
			return !WFBot(Other).bFlagTouchDisabled;
	}

	return true;
}

function Tick(float DeltaTime)
{
	if (IgnoreTouch != None)
	{
		IgnoreTime -= DeltaTime;
		if (IgnoreTime <= 0.0)
		{
			IgnoreTouch = None;
			IgnoreTime = 0.0;
		}
	}
	super.Tick(DeltaTime);
}

defaultproperties
{
	IgnoreDelay=1.5
}