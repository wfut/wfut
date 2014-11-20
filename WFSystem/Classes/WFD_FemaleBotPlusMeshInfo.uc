//=============================================================================
// WFD_FemaleBotPlusMeshInfo.
//=============================================================================
class WFD_FemaleBotPlusMeshInfo extends WFD_HumanBotPlusMeshInfo;

static function PlayRightHit(pawn Other, float tweentime)
{
	if ( Other.AnimSequence == 'RightHit' )
		Other.TweenAnim('GutHit', tweentime);
	else
		Other.TweenAnim('RightHit', tweentime);
}

static function PlayChallenge(pawn Other)
{
	Other.TweenToWaiting(0.17);
}

static function PlayVictoryDance(pawn Other)
{
	local float decision;

	decision = FRand();

	if ( decision < 0.25 )
		Other.PlayAnim('Victory1',0.7, 0.2);
	else if ( decision < 0.5 )
		Other.PlayAnim('Thrust',0.7, 0.2);
	else if ( decision < 0.75 )
		Other.PlayAnim('Taunt1',0.7, 0.2);
	else
		Other.TweenAnim('Taunt1', 0.2);
}

static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	local carcass carc;

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	WFD_DPMSBot(Other).PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		Other.PlayAnim('Dead3',, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') && !Other.Level.Game.bVeryLowGore )
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
		if ( (HitLoc.Z < Other.Location.Z) && !Other.Level.Game.bVeryLowGore && (FRand() < 0.6) )
		{
			Other.PlayAnim('Dead5',,0.05);
			if ( Other.Level.NetMode != NM_Client )
			{
				carc = Other.Spawn(class 'UT_FemaleFoot',,, Other.Location - Other.CollisionHeight * vect(0,0,0.5));
				if (carc != None)
				{
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

	if ( (HitLoc.Z - Other.Location.Z > 0.7 * Other.CollisionHeight) && !Other.Level.Game.bVeryLowGore )
	{
		if ( FRand() < 0.5 )
			PlayDecap(Other);
		else
			Other.PlayAnim('Dead3',, 0.1);
		return;
	}

	//then hit in front or back
	if ( FRand() < 0.5 )
		Other.PlayAnim('Dead4',, 0.1);
	else
		Other.PlayAnim('Dead1',, 0.1);
}

static function PlayDecap(pawn Other)
{
	local carcass carc;

	Other.PlayAnim('Dead6',, 0.1);
	if ( Other.Level.NetMode != NM_Client )
	{
		carc = Other.Spawn(class 'UT_HeadFemale',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384) );
		if (carc != None)
		{
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