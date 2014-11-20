//=============================================================================
// WFS_AutoCannonDeathMessage.
//=============================================================================
class WFS_AutoCannonDeathMessage extends DeathMessagePlus;

var localized string OwnerAppend;
var localized string DestroyedString;
var localized string FemaleOwner;
var localized string MaleOwner;

/*
Switch:
	n0 = PRI_1's Cannon killed PRI_2
	n1 = PRI_2's Cannon was destroyed by PRI_1

n = damageType:
	<not yet implemented>
*/


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0: // PRI_1's cannon killed PRI_2
			if (RelatedPRI_1 == none)
				return "";
			if (RelatedPRI_2 == none)
				return "";
			if (class<pawn>(OptionalObject) == none)
				return "";
			if (RelatedPRI_1 != RelatedPRI_2)
				return RelatedPRI_2.PlayerName$class'TournamentGameInfo'.static.PlayerKillMessage('',RelatedPRI_2)$RelatedPRI_1.PlayerName$default.OwnerAppend@class<pawn>(OptionalObject).default.MenuName$".";
			else // suicide
			{
				if (RelatedPRI_1.bIsFemale)
					return RelatedPRI_1.PlayerName@default.KilledString@default.FemaleOwner@class<pawn>(OptionalObject).default.MenuName$".";
				else
					return RelatedPRI_1.PlayerName@default.KilledString@default.MaleOwner@class<pawn>(OptionalObject).default.MenuName$".";
			}
			break;
		case 1: // PRI_1 destroyed PRI_2's cannon
			if (RelatedPRI_1 == none)
				return "";
			if (RelatedPRI_2 == none)
				return "";
			if (class<pawn>(OptionalObject) == none)
				return "";
			return RelatedPRI_1.PlayerName$default.DestroyedString$RelatedPRI_2.PlayerName$default.OwnerAppend@class<pawn>(OptionalObject).default.MenuName$".";
	}
}

static function ClientReceive(
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ((RelatedPRI_1 == P.PlayerReplicationInfo) && (RelatedPRI_1 != RelatedPRI_2))
	{
		// Interdict and send the child message instead.
		if ( TournamentPlayer(P).myHUD != None )
		{
			TournamentPlayer(P).myHUD.LocalizedMessage( Default.ChildMessage, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
			TournamentPlayer(P).myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		}

		if ( Default.bIsConsoleMessage )
		{
			TournamentPlayer(P).Player.Console.AddString(Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ));
		}

		// multi-kill stuff
		if (( RelatedPRI_1 != RelatedPRI_2 ) && ( RelatedPRI_2 != None ))
		{
			if ( (TournamentPlayer(P).Level.TimeSeconds - TournamentPlayer(P).LastKillTime < 3) && (Switch != 1) )
			{
				TournamentPlayer(P).MultiLevel++;
				TournamentPlayer(P).ReceiveLocalizedMessage( class'MultiKillMessage', TournamentPlayer(P).MultiLevel );
			}
			else
				TournamentPlayer(P).MultiLevel = 0;
			TournamentPlayer(P).LastKillTime = TournamentPlayer(P).Level.TimeSeconds;
		}
		else
			TournamentPlayer(P).MultiLevel = 0;
		if ( ChallengeHUD(P.MyHUD) != None )
			ChallengeHUD(P.MyHUD).ScoreTime = TournamentPlayer(P).Level.TimeSeconds;
	}
	else if (RelatedPRI_2 == P.PlayerReplicationInfo)
	{
		TournamentPlayer(P).ReceiveLocalizedMessage( class'WFS_AutoCannonVictimMessage', switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
		Super(LocalMessagePlus).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else
		Super(LocalMessagePlus).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	ChildMessage=class'WFS_AutoCannonKillerMessage'
	OwnerAppend="'s"
	DestroyedString=" destroyed "
	FemaleOwner="her"
	MaleOwner="his"
}