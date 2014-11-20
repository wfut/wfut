//=============================================================================
// WFSniper.
//=============================================================================
class WFSniper extends WFPlayerClassInfo;

defaultproperties
{
	ClassName="Sniper"
	ClassNamePlural="Snipers"
	Health=100
	Armor=25
	DefaultInventory=class'WFSniperInv'
	MeshInfo=class'WFD_TMale2MeshInfo'
	AltMeshInfo=class'WFD_TMale2BotMeshInfo'
	bNoTranslocator=false
	ClassDescription="WFCode.WFClassHelpSniper"
	TranslocatorAmmoUsed=10
	bNoEnforcer=True
	VoiceType="BotPack.VoiceMaleTwo"
	ClassSkinName="WFSkins.snip"
	ClassFaceName="WFSkins.bevis"
}