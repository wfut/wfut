class WFS_AutoCannonKillerMessage expands KillerMessagePlus;

var localized string YouDestroyed;
var localized string YouDestroyedTrailer;
var localized string OwnerAppend;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return "";
	if (RelatedPRI_2 == None)
		return "";
	if (RelatedPRI_1 == RelatedPRI_2)
		return "";
	if ((class<pawn>(OptionalObject) == none) && (switch > 0))
		return "";

	switch (Switch)
	{
		case 0:
			if (RelatedPRI_2.PlayerName != "")
				return Default.YouKilled@RelatedPRI_2.PlayerName@Default.YouKilledTrailer;
			break;
		case 1:
			if (RelatedPRI_2.PlayerName != "")
				return Default.YouDestroyed@RelatedPRI_2.PlayerName$default.OwnerAppend@class<pawn>(OptionalObject).default.MenuName@Default.YouDestroyedTrailer;
			break;
	}
}

defaultproperties
{
     YouDestroyed="You destroyed"
     YouDestroyedTrailer="!"
     OwnerAppend="'s"
     FontSize=1
     bIsSpecial=True
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(R=0,G=128)
     YPos=196.000000
     bCenter=True
}
