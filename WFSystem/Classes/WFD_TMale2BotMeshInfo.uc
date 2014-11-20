//=============================================================================
// WFD_TMale2BotMeshInfo.
//=============================================================================
class WFD_TMale2BotMeshInfo extends WFD_MaleBotPlusMeshInfo;

defaultproperties
{
	FaceSkin=3
	FixedSkin=2
	TeamSkin2=1
	DefaultFaceName="Malcom"
	DefaultClass=class'BotPack.TMale2'
	DefaultSkinName="SoldierSkins.blkt"
	DefaultPackage="SoldierSkins."
	SelectionMesh="Botpack.SelectionMale2"
	MenuName="Male Soldier"
	CarcassClass=Class'Botpack.TMale2Carcass'
	PlayerMesh=LodMesh'Botpack.Soldier'
	VoiceType="BotPack.VoiceMaleTwo"
	DefaultSoundClass=Class'WFD_TMale2BotSoundInfo'
}