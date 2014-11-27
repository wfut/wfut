class WFFlagRunnerKillMessage expands LocalMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY - 2*YL;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	return "You killed "$RelatedPRI_1.TeamName$"'s flag runner!";
}

static simulated function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	P.ClientPlaySound(sound'UnrealShare.Beep',, true);
}

defaultproperties
{
     bIsSpecial=True
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(G=0,B=0)
     YPos=196.000000
     bCenter=True
}
