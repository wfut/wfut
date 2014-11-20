//=============================================================================
// WFD_TournamentFemaleMeshInfo.
//=============================================================================
class WFD_TournamentFemaleMeshInfo extends WFD_TournamentPlayerMeshInfo;

static function PlayRightHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( Other.AnimSequence == 'RightHit')
		Other.TweenAnim('GutHit', tweentime);
	else
		Other.TweenAnim('RightHit', tweentime);
}

static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	local carcass carc;

	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	TournamentPlayer(Other).PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		Other.PlayAnim('Dead3',, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
	{
		PlayDecap(Other);
		return;
	}

	if ( FRand() < 0.15 )
	{
		Other.PlayAnim('Dead7',,0.1);
		return;
	}

	// check for big hit
	if ( (Other.Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( (HitLoc.Z < Other.Location.Z) && !class'GameInfo'.Default.bVeryLowGore && (FRand() < 0.6) )
		{
			Other.PlayAnim('Dead5',,0.05);
			if ( Other.Level.NetMode != NM_Client )
			{
				carc = Other.Spawn(class'CreatureChunks',,, Other.Location - Other.CollisionHeight * vect(0,0,0.5));
				if (carc != None)
				{
					carc.mesh = class'UT_FemaleFoot'.default.mesh;
					carc.Initfor(Other);
					carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
				}
			}
		}
		else
			Other.PlayAnim('Dead2',, 0.1);
		return;
	}

	// check for repeater death
	if ( (Other.Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		Other.PlayAnim('Dead9',, 0.1);
		return;
	}

	if ( (HitLoc.Z - Other.Location.Z > 0.7 * Other.CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap(Other);
		else
			Other.PlayAnim('Dead3',, 0.1);
		return;
	}

	if ( Other.Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		Other.PlayAnim('Dead4',, 0.1);
	else
		Other.PlayAnim('Dead1',, 0.1);
}

// TEST: play decap uses old Unreal player heads with new meshes
static function PlayDecap(pawn Other)
{
	local carcass carc;

	CheckMesh(Other);

	Other.PlayAnim('Dead6',, 0.1);

	if ( Other.Level.NetMode != NM_Client )
	{
		//carc = Other.Spawn(default.DecapClass,,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		carc = Other.Spawn(class'FemaleHead',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		if (carc != None)
		{
			carc.Mesh = default.DecapClass.default.Mesh;
			carc.Initfor(Other);
			carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
		}
	}
}

defaultproperties
{
	bIsFemale=True
	VoicePackMetaClass="BotPack.VoiceFemale"
	DecapClass=class'UT_HeadFemale'
	CarcassClass=Class'Botpack.TFemale1Carcass'
	StatusDoll=Texture'Botpack.Icons.Woman'
	StatusBelt=Texture'Botpack.Icons.WomanBelt'
}