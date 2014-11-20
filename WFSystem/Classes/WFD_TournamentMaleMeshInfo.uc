//=============================================================================
// WFD_TournamentMaleMeshInfo.
//=============================================================================
class WFD_TournamentMaleMeshInfo extends WFD_TournamentPlayerMeshInfo;

// From BotPack.TournamentMale (UT v4.02)
static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	TournamentPlayer(Other).PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		Other.PlayAnim('Dead8',, 0.1);
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
		Other.PlayAnim('Dead2',,0.1);
		return;
	}

	// check for big hit
	if ( (Other.Velocity.Z > 250) && (FRand() < 0.75) )
	{
		if ( FRand() < 0.5 )
			Other.PlayAnim('Dead1',,0.1);
		else
			Other.PlayAnim('Dead11',, 0.1);
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
			Other.PlayAnim('Dead7',, 0.1);
		return;
	}

	if ( Other.Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
		Other.PlayAnim('Dead3',, 0.1);
	else
		Other.PlayAnim('Dead8',, 0.1);
}

// TEST: play decap uses old Unreal player heads with new meshes
static function PlayDecap(pawn Other)
{
	local carcass carc;

	CheckMesh(Other);

	Other.PlayAnim('Dead4',, 0.1);

	if ( Other.Level.NetMode != NM_Client )
	{
		//carc = Other.Spawn(default.DecapClass,,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		carc = Other.Spawn(class'MaleHead',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		if (carc != None)
		{
			carc.Mesh = default.DecapClass.default.mesh; // <- to get round net bug
			carc.Initfor(Other);
			carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
		}
	}
}

static function PlayGutHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'GutHit') || (Other.AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			Other.TweenAnim('LeftHit', tweentime);
		else
			Other.TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		Other.TweenAnim('GutHit', tweentime);
	else
		Other.TweenAnim('Dead8', tweentime);

}

static function PlayHeadHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead7') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('HeadHit', tweentime);
	else
		Other.TweenAnim('Dead7', tweentime);
}

static function PlayLeftHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead9') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('LeftHit', tweentime);
	else
		Other.TweenAnim('Dead9', tweentime);
}

static function PlayRightHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead1') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('RightHit', tweentime);
	else
		Other.TweenAnim('Dead1', tweentime);
}

defaultproperties
{
	VoicePackMetaClass="BotPack.VoiceMale"
	DecapClass=class'UT_HeadMale'
}