//=============================================================================
// WFD_MaleOneSoundInfo.
//=============================================================================
class WFD_MaleOneSoundInfo extends WFD_MaleSoundInfo;

static function PlaySpecial(pawn Other, name Type)
{
	if (Type == 'MetalStep')
		PlayMetalStep(Other);
}

static function PlayMetalStep(pawn Other)
{
	local sound step;
	local float decision;

	if ( !Other.bIsWalking && (Other.Level.Game != None) && (Other.Level.Game.Difficulty > 1) && ((Other.Weapon == None) || !Other.Weapon.bPointing) )
		Other.MakeNoise(0.05 * Other.Level.Game.Difficulty);
	if ( Other.FootRegion.Zone.bWaterZone )
	{
		Other.PlaySound(sound'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	decision = FRand();
	if ( decision < 0.34 )
		step = sound'MetWalk1';
	else if (decision < 0.67 )
		step = sound'MetWalk2';
	else
		step = sound'MetWalk3';

	if ( Other.bIsWalking )
		Other.PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else
		Other.PlaySound(step, SLOT_Interact, 1, false, 800.0, 1.0);
}

defaultproperties
{
}