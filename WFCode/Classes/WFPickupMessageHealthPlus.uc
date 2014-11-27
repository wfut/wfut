//
// OptionalObject is an Inventory
//
class WFPickupMessageHealthPlus expands WFPickupMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - 80 - YL - 4;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (OptionalObject != None)
	{
		if (Class<TournamentHealth>(OptionalObject) != None)
			return Class<Inventory>(OptionalObject).Default.PickupMessage$Class<TournamentHealth>(OptionalObject).Default.HealingAmount;
		else
			return Class<Inventory>(OptionalObject).Default.PickupMessage;
	}
}

defaultproperties
{
}
