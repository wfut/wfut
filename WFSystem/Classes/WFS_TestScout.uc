//=============================================================================
// WFS_TestScout.
//=============================================================================
class WFS_TestScout extends WFS_TestPCI;

static function ModifyPlayer(pawn Other)
{
	Other.GroundSpeed = Other.default.GroundSpeed * 1.5;
	Other.WaterSpeed = Other.default.WaterSpeed * 1.5;
	Other.AirSpeed = Other.default.AirSpeed * 1.5;
	Other.AccelRate = Other.default.AccelRate * 1.5;
	Other.JumpZ = Other.default.JumpZ * 1.5;
	Other.AirControl = Other.default.AirControl * 1.5;
	Other.Mass = Other.default.Mass * 0.8;
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if (default.DefaultInventory.static.IsDefaultInventory(ItemClass))
		return true;

	if (ItemClass == class'Enforcer')
		return true;

	if (ItemClass == class'miniammo')
		return true;

	if (ItemClass.default.bIsAnArmor)
		return true;

	return false;
}

defaultproperties
{
	ClassName="Scout"
	ClassNamePlural="Scouts"
	Health=80
	Armor=50
	ExtendedHUD=class'WFS_CTFHUDInfo'
	DefaultInventory=class'WFS_TestScoutInv'
}