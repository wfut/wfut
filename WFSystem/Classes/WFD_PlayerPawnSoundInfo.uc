//=============================================================================
// WFD_PlayerPawnSoundInfo.
//=============================================================================
class WFD_PlayerPawnSoundInfo extends WFD_PawnSoundInfo;

// from Engine.PlayerPawn (UT v4.02)
static function PlayerLanded(pawn Other, vector HitNormal)
{
	if ( Other.Role == ROLE_Authority )
		Other.PlaySound(default.Land, SLOT_Interact, 0.3, false, 800, 1.0);
	if ( PlayerPawn(Other).bUpdating )
		return;
	Other.TakeFallingDamage();
	PlayerPawn(Other).bJustLanded = true;
}

static function DoJump(pawn Other, optional float F )
{
	if ( Other.CarriedDecoration != None )
		return;
	if ( !PlayerPawn(Other).bIsCrouching && (Other.Physics == PHYS_Walking) )
	{
		if ( !PlayerPawn(Other).bUpdating )
			Other.PlayOwnedSound(default.JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Other.Level.Game != None) && (Other.Level.Game.Difficulty > 0) )
			Other.MakeNoise(0.1 * Other.Level.Game.Difficulty);
		Other.PlayInAir();
		if ( PlayerPawn(Other).bCountJumps && (Other.Role == ROLE_Authority) && (Other.Inventory != None) )
			Other.Inventory.OwnerJumped();
		Other.Velocity.Z = Other.JumpZ;
		if ( (Other.Base != Other.Level) && (Other.Base != None) )
			Other.Velocity.Z += Other.Base.Velocity.Z;
		Other.SetPhysics(PHYS_Falling);
	}
}

defaultproperties
{
}