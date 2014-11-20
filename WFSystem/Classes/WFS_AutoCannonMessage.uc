//=============================================================================
// WFS_AutoCannonMessage.
//=============================================================================
class WFS_AutoCannonMessage extends LocalMessagePlus;

/*
Switch:
	n0 = Cannon killed other
	n1 = Cannon destroyed by killer
	n2 = Low ammo
	n3 = Low health

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
			return RelatedPRI_2.PlayerName$class'TournamentGameInfo'.static.PlayerKillMessage('',RelatedPRI_2)$RelatedPRI_1.PlayerName$"'s "$class<pawn>(OptionalObject).default.MenuName$".";
			break;
		case 1: // PRI_1 destroyed PRI_2's cannon
			if (RelatedPRI_1 == none)
				return "";
			if (RelatedPRI_2 == none)
				return "";
			if (class<pawn>(OptionalObject) == none)
				return "";
			return RelatedPRI_1.PlayerName$" destroyed "$RelatedPRI_2.PlayerName$"'s "$class<pawn>(OptionalObject).default.MenuName$".";
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
	if (RelatedPRI_1 == P.PlayerReplicationInfo)
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
		TournamentPlayer(P).ReceiveLocalizedMessage( class'WFS_AutoCannonVictimMessage', 0, RelatedPRI_1 );
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	ChildMessage=class'KillerMessagePlus'
}