//=============================================================================
// WFRecon.
//=============================================================================
class WFRecon extends WFPlayerClassInfo;

static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if ((ItemClass == class'miniammo') || (ItemClass == class'EClip'))
		return true;

	return super.ValidInventoryType(Other, ItemClass);
}

static function ModifyPlayer(pawn Other)
{
	local float SpeedScaling;

	if (DeathMatchPlus(Other.Level.Game).bMegaSpeed)
		SpeedScaling = 1.4;
	else SpeedScaling = 1.0;

	Other.GroundSpeed = (Other.default.GroundSpeed * SpeedScaling) * 1.2;
	Other.WaterSpeed = (Other.default.WaterSpeed * SpeedScaling) * 1.2;
	Other.AirSpeed = (Other.default.AirSpeed * SpeedScaling) * 1.2;
	Other.AccelRate = (Other.default.AccelRate * SpeedScaling) * 1.2;
	Other.Mass = Other.default.Mass * 0.8;
}

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	local inventory Item;

	if (SpecialString == "")
		SpecialString = "thrust";

	if (SpecialString ~= "thrust")
	{
		Item = Other.FindInventoryType(class'WFThrustPack');
		if (Item != None)
			Item.Use(Other);
	}
}

defaultproperties
{
	ClassName="Recon"
	ClassNamePlural="Recon"
	Health=75
	MaxHealth=150
	Armor=50
	bNoTranslocator=false
	ExtendedHUD=class'WFReconHUDInfo'
	DefaultInventory=class'WFReconInv'
	MeshInfo=class'WFD_TFemale1MeshInfo'
	AltMeshInfo=class'WFD_TFemale1BotMeshInfo'
	ClassDescription="WFCode.WFClassHelpRecon"
	bNoImpactHammer=True
	TranslocatorAmmoUsed=5
	bNoEnforcer=True
	ClassSkinName="WFSkins.recn"
	ClassFaceName="WFSkins.Iris"
	VoiceType="BotPack.VoiceFemaleTwo"
}