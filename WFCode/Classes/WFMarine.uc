//=============================================================================
// WFMarine.
//=============================================================================
class WFMarine extends WFPlayerClassInfo;

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	local WFGrenTurretProj g;

	// remove any active Turret Grenades
	foreach Other.AllActors(class'WFGrenTurretProj', g)
	{
		if ((g != None) && !g.bDeleteMe && (g.Instigator == Other))
			g.SetFall();
	}
}

defaultproperties
{
	ClassName="Marine"
	ClassNamePlural="Marines"
	Health=100
	Armor=150
	ArmorAbsorption=75
	DefaultInventory=class'WFMarineInv'
	MeshInfo=class'WFD_TMale2MeshInfo'
	AltMeshInfo=class'WFD_TMale2BotMeshInfo'
	ClassDescription="WFCode.WFClassHelpMarine"
	bNoEnforcer=True
	ClassSkinName="WFSkins.mari"
	ClassFaceName="WFSkins.gondor"
	VoiceType="BotPack.VoiceMaleTwo"
	//bNoTranslocator=True
}