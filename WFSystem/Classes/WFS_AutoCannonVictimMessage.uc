class WFS_AutoCannonVictimMessage expands VictimMessage;

var localized string YourOwn;
var localized string OwnerString;
var localized string OwnerAppend;
var localized string WasDestroyedBy;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return "";
	if (class<pawn>(optionalobject) == none)
		return "";

	switch (switch)
	{
		case 0:
			if ((RelatedPRI_1.PlayerName != "") && (RelatedPRI_1 != RelatedPRI_2))
				return Default.YouWereKilledBy@RelatedPRI_1.PlayerName$default.OwnerAppend@class<pawn>(OptionalObject).default.MenuName$Default.KilledByTrailer;
			if (RelatedPRI_1 == RelatedPRI_2)
				return Default.YouWereKilledBy$default.YourOwn$class<pawn>(OptionalObject).default.MenuName$Default.KilledByTrailer;
			break;
		case 1:
			if (RelatedPRI_1.PlayerName != "")
				return default.OwnerString@class<pawn>(optionalobject).default.MenuName@default.WasDestroyedBy@RelatedPRI_1.PlayerName;
			break;
	}
}

defaultproperties
{
     YouWereKilledBy="You were killed by"
     YourOwn=" your "
     OwnerString="Your"
     WasDestroyedBy="was destroyed by"
     OwnerAppend="'s"
     KilledByTrailer="!"
     FontSize=1
     bIsSpecial=True
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(G=0,B=0)
     YPos=196.000000
     bCenter=True
}
