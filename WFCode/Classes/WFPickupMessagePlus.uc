//
// OptionalObject is an Inventory
//
class WFPickupMessagePlus expands PickupMessagePlus;


static function float GetOffset(int Switch, float YL, float ClipY )
{
  local float Scale;
  
	Scale = ClipY / 600.0;
	
	return ClipY - ( 80 * Scale ) - YL - 4; 
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (OptionalObject != None)
		return Class<Inventory>(OptionalObject).Default.PickupMessage;
}

defaultproperties
{
}
