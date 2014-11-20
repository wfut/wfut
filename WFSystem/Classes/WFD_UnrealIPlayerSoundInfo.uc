//=============================================================================
// WFD_UnrealIPlayerSoundInfo.
//=============================================================================
class WFD_UnrealIPlayerSoundInfo extends WFD_PlayerPawnSoundInfo;

// from UnrealShare.UnrealiPlayer (UT v4.02)
static function PlayDyingSound(pawn Other)
{
	local float rnd;

	if ( Other.HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			Other.PlaySound(default.UWHit1, SLOT_Pain,,,,Frand()*0.2+0.9);
		else
			Other.PlaySound(default.UWHit2, SLOT_Pain,,,,Frand()*0.2+0.9);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		Other.PlaySound(default.Die, SLOT_Talk);
	else if (rnd < 0.5)
		Other.PlaySound(default.Die2, SLOT_Talk);
	else if (rnd < 0.75)
		Other.PlaySound(default.Die3, SLOT_Talk);
	else
		Other.PlaySound(default.Die4, SLOT_Talk);
}

// used BotPack.TournamentPlayer sound volumes for sound
static function PlayTakeHitSound(pawn Other, int damage, name damageType, int Mult)
{
	if ( Other.Level.TimeSeconds - Other.LastPainSound < 0.3 )
		return;
	Other.LastPainSound = Other.Level.TimeSeconds;

	if ( Other.HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			Other.PlaySound(default.drown, SLOT_Pain, 12);//1.5
		else if ( FRand() < 0.5 )
			Other.PlaySound(default.UWHit1, SLOT_Pain,16,,,Frand()*0.15+0.9);//2.0
		else
			Other.PlaySound(default.UWHit2, SLOT_Pain,16,,,Frand()*0.15+0.9);//2.0
		return;
	}
	damage *= FRand();

	if (damage < 8)
		Other.PlaySound(default.HitSound1, SLOT_Pain,16,,,Frand()*0.15+0.9);//2.0
	else if (damage < 25)
	{
		if (FRand() < 0.5) Other.PlaySound(default.HitSound2, SLOT_Pain,16,,,Frand()*0.15+0.9);//2.0
		else Other.PlaySound(default.HitSound3, SLOT_Pain,16,,,Frand()*0.15+0.9);//2.0
	}
	else
		Other.PlaySound(default.HitSound4, SLOT_Pain,16,,,Frand()*0.15+0.9);//2.0
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

static function FootStepping(pawn Other)
{
	PlayFootStep(Other);
}

static function PlayFootStep(pawn Other)
{
	local sound step;
	local float decision;

	if ( !PlayerPawn(Other).bIsWalking && (Other.Level.Game != None) && (Other.Level.Game.Difficulty > 1) && ((Other.Weapon == None) || !Other.Weapon.bPointing) )
		Other.MakeNoise(0.05 * Other.Level.Game.Difficulty);
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

	if ( PlayerPawn(Other).bIsWalking )
		Other.PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else
		Other.PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

defaultproperties
{
	Land=Sound'UnrealShare.Generic.Land1'
	WaterStep=Sound'UnrealShare.Generic.LSplash'
	Footstep1=Sound'FemaleSounds.stone02'
	Footstep2=Sound'FemaleSounds.stone04'
	Footstep3=Sound'FemaleSounds.stone05'
}