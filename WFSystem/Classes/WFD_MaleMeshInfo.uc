//=============================================================================
// WFD_MaleMeshInfo.
//=============================================================================
class WFD_MaleMeshInfo extends WFD_HumanMeshInfo;

// may need to override PlayDying here to use UnrealShare.Male function
static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	local carcass carc;

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	TournamentPlayer(Other).PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		Other.PlayAnim('Dead7', 0.7, 0.1);
		return;
	}

	if ( FRand() < 0.15 )
	{
		Other.PlayAnim('Dead2',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Other.Velocity.Z > 250) && (FRand() < 0.7) && !class'GameInfo'.Default.bVeryLowGore)
	{
		if ( (hitLoc.Z > Other.Location.Z) && (FRand() < 0.65) )
		{
			Other.PlayAnim('Dead5',0.7,0.1);
			if ( Other.Level.NetMode != NM_Client )
			{
				carc = Other.Spawn(class'MaleHead',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384) );
				if (carc != None)
				{
					carc.Initfor(Other);
					carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
					PlayerPawn(Other).ViewTarget = carc;
				}
				carc = Other.Spawn(class'CreatureChunks');
				if (carc != None)
				{
					carc.Mesh = mesh'CowBody1';
					carc.Initfor(Other);
					carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
				}
				carc = Other.Spawn(class'Arm1',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384) );
				if (carc != None)
				{
					carc.Initfor(Other);
					carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
				}
			}
		}
		else
			Other.PlayAnim('Dead1', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Other.Location.Z > 0.6 * Other.CollisionHeight))
		 && !class'GameInfo'.Default.bVeryLowGore )
	{
		DamageType = 'Decapitated';
		Other.PlayAnim('Dead4', 0.7, 0.1);
		PlayDecap(Other);
		/*if ( Level.NetMode != NM_Client )
		{
			carc = Spawn(class'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
			if (carc != None)
			{
				carc.Initfor(self);
				carc.Velocity = Velocity + VSize(Velocity) * VRand();
				carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				ViewTarget = carc;
			}
		}*/
		return;
	}

	GetAxes(Other.Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Other.Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	if (Abs(dotp) > 0.71) //then hit in front or back
		Other.PlayAnim('Dead3', 0.7, 0.1);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			Other.PlayAnim('Dead6', 0.7, 0.1);
		else
			Other.PlayAnim('Dead7', 0.7, 0.1);
	}
}

static function PlayGutHit(pawn Other, float tweentime)
{
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
		Other.TweenAnim('Dead2', tweentime);

}

static function PlayHeadHit(pawn Other, float tweentime)
{
	if ( (Other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead3') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('HeadHit', tweentime);
	else
		Other.TweenAnim('Dead3', tweentime);
}

static function PlayLeftHit(pawn Other, float tweentime)
{
	if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead6') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('LeftHit', tweentime);
	else
		Other.TweenAnim('Dead6', tweentime);
}

static function PlayRightHit(pawn Other, float tweentime)
{
	if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead1') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('RightHit', tweentime);
	else
		Other.TweenAnim('Dead1', tweentime);
}

defaultproperties
{
	DecapClass=class'MaleHead'
	CarcassClass=Class'UnrealShare.MaleBody'
	VoicePackMetaClass="BotPack.VoiceMale"
}