//=============================================================================
// WFD_TournamentPlayerSoundInfo.
//=============================================================================
class WFD_TournamentPlayerSoundInfo extends WFD_PlayerPawnSoundInfo;

// from BotPack.TournamentPlayer (UT v4.02)
static function DoJump(pawn Other, optional float F )
{
	if ( Other.CarriedDecoration != None )
		return;
	if ( !PlayerPawn(Other).bIsCrouching && (Other.Physics == PHYS_Walking) )
	{
		if ( !PlayerPawn(Other).bUpdating )
			PlayerPawn(Other).PlayOwnedSound(default.JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Other.Level.Game != None) && (Other.Level.Game.Difficulty > 0) )
			Other.MakeNoise(0.1 * Other.Level.Game.Difficulty);
		Other.PlayInAir();
		if ( PlayerPawn(Other).bCountJumps && (Other.Role == ROLE_Authority) && (Other.Inventory != None) )
			Other.Inventory.OwnerJumped();
		if ( PlayerPawn(Other).bIsWalking )
			Other.Velocity.Z = Other.Default.JumpZ;
		else
			Other.Velocity.Z = Other.JumpZ;
		if ( (Other.Base != Other.Level) && (Other.Base != None) )
			Other.Velocity.Z += Other.Base.Velocity.Z;
		Other.SetPhysics(PHYS_Falling);
	}
}

static function PlayDyingSound(pawn Other)
{
	local int rnd;

	if ( Other.HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			Other.PlaySound(default.UWHit1, SLOT_Pain,16,,,Frand()*0.2+0.9);
		else
			Other.PlaySound(default.UWHit2, SLOT_Pain,16,,,Frand()*0.2+0.9);
		return;
	}

	rnd = Rand(6);
	Other.PlaySound(default.Deaths[rnd], SLOT_Talk, 16);
	Other.PlaySound(default.Deaths[rnd], SLOT_Pain, 16);
}

static function FootStepping(pawn Other)
{
	local sound step;
	local float decision;

	if ( Other.FootRegion.Zone.bWaterZone )
	{
		Other.PlaySound(default.WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	decision = FRand();
	if ( decision < 0.34 )
		step = default.Footstep1;
	else if (decision < 0.67 )
		step = default.Footstep2;
	else
		step = default.Footstep3;

	Other.PlaySound(step, SLOT_Interact, 2.2, false, 1000.0, 1.0);
}

static function PlayTakeHitSound(pawn Other, int damage, name damageType, int Mult)
{
	if ( Other.Level.TimeSeconds - Other.LastPainSound < 0.3 )
		return;
	Other.LastPainSound = Other.Level.TimeSeconds;

	if ( Other.HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			Other.PlaySound(default.drown, SLOT_Pain, 12);
		else if ( FRand() < 0.5 )
			Other.PlaySound(default.UWHit1, SLOT_Pain,16,,,Frand()*0.15+0.9);
		else
			Other.PlaySound(default.UWHit2, SLOT_Pain,16,,,Frand()*0.15+0.9);
		return;
	}
	damage *= FRand();

	if (damage < 8)
		Other.PlaySound(default.HitSound1, SLOT_Pain,16,,,Frand()*0.15+0.9);
	else if (damage < 25)
	{
		if (FRand() < 0.5) Other.PlaySound(default.HitSound2, SLOT_Pain,16,,,Frand()*0.15+0.9);
		else Other.PlaySound(default.HitSound3, SLOT_Pain,16,,,Frand()*0.15+0.9);
	}
	else
		Other.PlaySound(default.HitSound4, SLOT_Pain,16,,,Frand()*0.15+0.9);
}

static function Gasp(pawn Other)
{
	if ( Other.Role != ROLE_Authority )
		return;

	if ( Other.PainTime < 2 )
		Other.PlaySound(default.GaspSound, SLOT_Talk, 2.0);
	else
		Other.PlaySound(default.BreathAgain, SLOT_Talk, 2.0);
}

defaultproperties
{
	Land=Sound'UnrealShare.Generic.Land1'
	WaterStep=Sound'UnrealShare.Generic.LSplash'
	Footstep1=Sound'BotPack.FemaleSounds.stone02'
	Footstep2=Sound'BotPack.FemaleSounds.stone04'
	Footstep3=Sound'BotPack.FemaleSounds.stone05'
}