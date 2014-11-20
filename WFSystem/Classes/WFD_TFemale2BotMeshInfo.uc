//=============================================================================
// WFD_TFemale2BotMeshInfo.
//=============================================================================
class WFD_TFemale2BotMeshInfo extends WFD_FemaleBotPlusMeshInfo;

defaultproperties
{
	FaceSkin=3
	FixedSkin=2
	TeamSkin2=1
	DefaultFaceName="Rylisa"
	DefaultClass=class'BotPack.TFemale2'
	DefaultSkinName="SGirlSkins.army"
	DefaultPackage="SGirlSkins."
	CarcassClass=Class'Botpack.TFemale2Carcass'
	SelectionMesh="Botpack.SelectionFemale2"
	MenuName="Female Soldier"
	VoiceType="BotPack.VoiceFemaleTwo"
	PlayerMesh=LodMesh'Botpack.SGirl'
	DefaultSoundClass=Class'WFD_TFemale2BotSoundInfo'
}