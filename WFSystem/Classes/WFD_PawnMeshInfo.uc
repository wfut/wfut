//=============================================================================
// WFD_PawnMeshInfo.
//=============================================================================
class WFD_PawnMeshInfo extends WFD_DPMSMeshInfo;

// update any effects
static function UpdateEffects(pawn Other)
{
	local Inventory sb;
	local Inventory i;

	sb = Other.FindInventoryType(class'ut_shieldbelt');

	if ((sb != none) && (ut_shieldbelt(sb).MyEffect != none) && (ut_shieldbelt(sb).MyEffect.Mesh != default.PlayerMesh))
		ut_shieldbelt(sb).MyEffect.Mesh = default.PlayerMesh;
}

defaultproperties
{
}