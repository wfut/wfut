//=============================================================================
// WFD_PawnSoundInfo.
//=============================================================================
class WFD_PawnSoundInfo extends WFD_DPMSSoundInfo;

// From Engine.Pawn
static function FootZoneChange(pawn Other, ZoneInfo newFootZone)
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local float splashSize;
	local actor splash;

	if ( Other.Level.NetMode == NM_Client )
		return;

	if ( Other.Level.TimeSeconds - Other.SplashTime > 0.25 )
	{
		Other.SplashTime = Other.Level.TimeSeconds;
		if (Other.Physics == PHYS_Falling)
			Other.MakeNoise(1.0);
		else
			Other.MakeNoise(0.3);
		if ( Other.FootRegion.Zone.bWaterZone )
		{
			if ( !newFootZone.bWaterZone && (Other.Role==ROLE_Authority) )
			{
				if ( Other.FootRegion.Zone.ExitSound != None )
					Other.PlaySound(Other.FootRegion.Zone.ExitSound, SLOT_Interact, 1);
				if ( Other.FootRegion.Zone.ExitActor != None )
					Other.Spawn(Other.FootRegion.Zone.ExitActor,,,Other.Location - Other.CollisionHeight * vect(0,0,1));
			}
		}
		else if ( newFootZone.bWaterZone && (Other.Role==ROLE_Authority) )
		{
			splashSize = FClamp(0.000025 * Other.Mass * (300 - 0.5 * FMax(-500, Other.Velocity.Z)), 1.0, 4.0 );
			if ( newFootZone.EntrySound != None )
			{
				HitActor = Other.Trace(HitLocation, HitNormal,
						Other.Location - (Other.CollisionHeight + 40) * vect(0,0,0.8), Other.Location - Other.CollisionHeight * vect(0,0,0.8), false);
				if ( HitActor == None )
					Other.PlaySound(newFootZone.EntrySound, SLOT_Misc, 2 * splashSize);
				else
					Other.PlaySound(default.WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize);
			}
			if( newFootZone.EntryActor != None )
			{
				splash = Other.Spawn(newFootZone.EntryActor,,,Other.Location - Other.CollisionHeight * vect(0,0,1));
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
			//log("Feet entering water");
		}
	}

	if (Other.FootRegion.Zone.bPainZone)
	{
		if ( !newFootZone.bPainZone && !Other.HeadRegion.Zone.bWaterZone )
			Other.PainTime = -1.0;
	}
	else if (newFootZone.bPainZone)
		Other.PainTime = 0.01;
}

static function PlayTakeHitSound(pawn Other, int Damage, name damageType, int Mult)
{
	if ( Other.Level.TimeSeconds - Other.LastPainSound < 0.25 )
		return;

	if (default.HitSound1 == None) return;
	Other.LastPainSound = Other.Level.TimeSeconds;
	if (FRand() < 0.5)
		Other.PlaySound(default.HitSound1, SLOT_Pain, FMax(Mult * Other.TransientSoundVolume, Mult * 2.0));
	else
		Other.PlaySound(default.HitSound2, SLOT_Pain, FMax(Mult * Other.TransientSoundVolume, Mult * 2.0));
}

defaultproperties
{
}