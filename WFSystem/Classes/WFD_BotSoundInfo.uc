//=============================================================================
// WFD_BotSoundInfo.
//=============================================================================
class WFD_BotSoundInfo extends WFD_PawnSoundInfo;

static function PlayFootStep(pawn Other)
{
	local sound step;
	local float decision;

	if ( Other.FootRegion.Zone.bWaterZone )
	{
		Other.PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1500.0, 1.0);
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

static function PlayTakeHitSound(pawn Other, int damage, name damageType, int Mult)
{
	if ( Other.Level.TimeSeconds - Other.LastPainSound < 0.25 )
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
		Other.PlaySound(default.HitSound1, SLOT_Pain,16,,,Frand()*0.2+0.9);
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
	if ( Other.PainTime < 2 )
		Other.PlaySound(default.GaspSound, SLOT_Talk, 2.0);
	else
		Other.PlaySound(default.BreathAgain, SLOT_Talk, 2.0);
}

defaultproperties
{
}
