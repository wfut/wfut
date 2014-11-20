//=============================================================================
// WFD_PlayerPawnMeshInfo.
//=============================================================================
class WFD_PlayerPawnMeshInfo extends WFD_PawnMeshInfo;

// from Engine.PlayerPawn (UT v4.02)

static function SwimAnimUpdate(pawn Other, bool bNotForward)
{
	CheckMesh(Other);

	if ( !PlayerPawn(Other).bAnimTransition && (Other.GetAnimGroup(Other.AnimSequence) != 'Gesture') )
	{
		if ( bNotForward )
	 	{
		 	 if ( Other.GetAnimGroup(Other.AnimSequence) != 'Waiting' )
				Other.TweenToWaiting(0.1);
		}
		else if ( Other.GetAnimGroup(Other.AnimSequence) == 'Waiting' )
			Other.TweenToSwimming(0.1);
	}
}

// PlayerWalking.AnimEnd
static function WalkingAnimEnd(pawn Other)
{
	local name MyAnimGroup;

	CheckMesh(Other);

	PlayerPawn(Other).bAnimTransition = false;
	if (Other.Physics == PHYS_Walking)
	{
		if (PlayerPawn(Other).bIsCrouching)
		{
			if ( !PlayerPawn(Other).bIsTurning && ((Other.Velocity.X * Other.Velocity.X + Other.Velocity.Y * Other.Velocity.Y) < 1000) )
				PlayDuck(Other);
			else
				PlayCrawling(Other);
		}
		else
		{
			MyAnimGroup = Other.GetAnimGroup(Other.AnimSequence);
			if ((Other.Velocity.X * Other.Velocity.X + Other.Velocity.Y * Other.Velocity.Y) < 1000)
			{
				if ( MyAnimGroup == 'Waiting' )
					PlayWaiting(Other);
				else
				{
					PlayerPawn(Other).bAnimTransition = true;
					TweenToWaiting(Other,0.2);
				}
			}
			else if (Other.bIsWalking)
			{
				if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
				{
					TweenToWalking(Other,0.1);
					PlayerPawn(Other).bAnimTransition = true;
				}
				else
					PlayWalking(Other);
			}
			else
			{
				if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
				{
					PlayerPawn(Other).bAnimTransition = true;
					TweenToRunning(Other,0.1);
				}
				else
					PlayRunning(Other);
			}
		}
	}
	else
		PlayInAir(Other);
}

// Origionally the Dodge() function in the Engine.PlayerPawn 'PlayerWalking' state
// called by the WalkingProcessMove function (above)
static function Dodge(pawn Other, eDodgeDir DodgeMove)
{
	local vector X,Y,Z;

	if ( PlayerPawn(Other).bIsCrouching || (Other.Physics != PHYS_Walking) )
		return;

	GetAxes(Other.Rotation,X,Y,Z);
	if (DodgeMove == DODGE_Forward)
		Other.Velocity = 1.5*Other.GroundSpeed*X + (Other.Velocity Dot Y)*Y;
	else if (DodgeMove == DODGE_Back)
		Other.Velocity = -1.5*Other.GroundSpeed*X + (Other.Velocity Dot Y)*Y;
	else if (DodgeMove == DODGE_Left)
		Other.Velocity = 1.5*Other.GroundSpeed*Y + (Other.Velocity Dot X)*X;
	else if (DodgeMove == DODGE_Right)
		Other.Velocity = -1.5*Other.GroundSpeed*Y + (Other.Velocity Dot X)*X;

	Other.Velocity.Z = 160;
	Other.PlayOwnedSound(WFD_DPMSPlayer(Other).SoundInfo.default.JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	PlayerPawn(Other).PlayDodge(DodgeMove);
	PlayerPawn(Other).DodgeDir = DODGE_Active;
	Other.SetPhysics(PHYS_Falling);
}

// PlayerSwimming.AnimEnd
static function SwimAnimEnd(pawn Other)
{
	local vector X,Y,Z;

	CheckMesh(Other);

	GetAxes(Other.Rotation, X,Y,Z);
	if ( (Other.Acceleration Dot X) <= 0 )
	{
		if ( Other.GetAnimGroup(Other.AnimSequence) == 'TakeHit' )
		{
			PlayerPawn(Other).bAnimTransition = true;
			Other.TweenToWaiting(0.2);
		}
		else
			Other.PlayWaiting();
	}
	else
	{
		if ( Other.GetAnimGroup(Other.AnimSequence) == 'TakeHit' )
		{
			PlayerPawn(Other).bAnimTransition = true;
			Other.TweenToSwimming(0.2);
		}
		else
			//Other.PlaySwimming();
			PlaySwimming(Other);
	}
}

defaultproperties
{
}