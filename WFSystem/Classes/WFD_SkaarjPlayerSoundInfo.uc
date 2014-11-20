//=============================================================================
// WFD_SkaarjPlayerSoundInfo.
//=============================================================================
class WFD_SkaarjPlayerSoundInfo extends WFD_UnrealIPlayerSoundInfo;

static function PlaySpecial(pawn Other, name Type)
{
	switch(Type)
	{
		case 'WalkStep':
			WalkStep(Other);
			break;
		case 'RunStep':
			RunStep(Other);
			break;
	}
}

// sound functions
static function WalkStep(pawn Other)
{
	local sound step;
	local float decision;

	if ( Other.Role < ROLE_Authority )
		return;
	if ( Other.FootRegion.Zone.bWaterZone )
	{
		Other.PlaySound(sound'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	Other.PlaySound(default.Footstep1, SLOT_Interact, 0.1, false, 800.0, 1.0);
}

static function RunStep(pawn Other)
{
	local sound step;
	local float decision;

	if ( Other.Role < ROLE_Authority )
		return;
	if ( Other.FootRegion.Zone.bWaterZone )
	{
		Other.PlaySound(sound'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	Other.PlaySound(default.Footstep1, SLOT_Interact, 0.7, false, 800.0, 1.0);
}

defaultproperties
{
     drown=Sound'UnrealI.SKPDrown1'
     breathagain=Sound'UnrealI.SKPGasp1'
     Footstep1=Sound'UnrealShare.walkC'
     Footstep2=Sound'UnrealShare.walkC'
     Footstep3=Sound'UnrealShare.walkC'
     HitSound3=Sound'UnrealI.SKPInjur3'
     HitSound4=Sound'UnrealI.SKPInjur4'
     Die2=Sound'UnrealI.SKPDeath2'
     Die3=Sound'UnrealI.SKPDeath3'
     Die4=Sound'UnrealI.SKPDeath3'
     GaspSound=Sound'UnrealI.SKPGasp1'
     UWHit1=Sound'UnrealShare.MUWHit1'
     UWHit2=Sound'UnrealShare.MUWHit2'
     LandGrunt=Sound'UnrealI.Land1SK'
     JumpSound=Sound'UnrealI.SKPJump1'
     HitSound1=Sound'UnrealI.SKPInjur1'
     HitSound2=Sound'UnrealI.SKPInjur2'
     Die=Sound'UnrealI.SKPDeath1'
}