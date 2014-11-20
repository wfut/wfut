//=============================================================================
// WFD_HumanMeshInfo.
//=============================================================================
class WFD_HumanMeshInfo extends WFD_UnrealIPlayerMeshInfo;

// Note: The WFD_TournamentPlayerMeshInfo PlayLanded function has been used here
static function PlayLanded(pawn Other, float impactVel)
{
	CheckMesh(Other);

	impactVel = impactVel/Other.JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;

	if ( impactVel > 0.17 ) // may need to use passed sound var here
		Other.PlayOwnedSound(WFD_DPMSPlayer(Other).SoundInfo.default.LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( !Other.FootRegion.Zone.bWaterZone && (impactVel > 0.01) ) // and here
		Other.PlayOwnedSound(WFD_DPMSPlayer(Other).SoundInfo.default.Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
	if ( (impactVel > 0.06) || (Other.GetAnimGroup(Other.AnimSequence) == 'Jumping') || (Other.GetAnimGroup(Other.AnimSequence) == 'Ducking') )
	{
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('LandSMFR', 0.12);
		else
			Other.TweenAnim('LandLGFR', 0.12);
	}
	else if ( !Other.IsAnimating() )
	{
		if ( Other.GetAnimGroup(Other.AnimSequence) == 'TakeHit' )
		{
			Other.SetPhysics(PHYS_Walking);
			Other.AnimEnd();
		}
		else
		{
			if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
				Other.TweenAnim('LandSMFR', 0.12);
			else
				Other.TweenAnim('LandLGFR', 0.12);
		}
	}
}

// from UnrealShare.Human (UT v4.02)
static function PlayFiring(pawn Other)
{
	CheckMesh(Other);

	// switch animation sequence mid-stream if needed
	if (Other.AnimSequence == 'RunLG')
		Other.AnimSequence = 'RunLGFR';
	else if (Other.AnimSequence == 'RunSM')
		Other.AnimSequence = 'RunSMFR';
	else if (Other.AnimSequence == 'WalkLG')
		Other.AnimSequence = 'WalkLGFR';
	else if (Other.AnimSequence == 'WalkSM')
		Other.AnimSequence = 'WalkSMFR';
	else if ( Other.AnimSequence == 'JumpSMFR')
		Other.TweenAnim('JumpSMFR', 0.03);
	else if ( Other.AnimSequence == 'JumpLGFR')
		Other.TweenAnim('JumpLGFR', 0.03);
	else if ( (Other.GetAnimGroup(Other.AnimSequence) == 'Waiting') || (Other.GetAnimGroup(Other.AnimSequence) == 'Gesture')
		&& (Other.AnimSequence != 'TreadLG') && (Other.AnimSequence != 'TreadSM') )
	{
		if ( Other.Weapon.Mass < 20 )
			Other.TweenAnim('StillSMFR', 0.02);
		else
			Other.TweenAnim('StillFRRP', 0.02);
	}
}

static function PlayTurning(pawn Other)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.default.BaseEyeHeight;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.PlayAnim('TurnSM', 0.3, 0.3);
	else
		Other.PlayAnim('TurnLG', 0.3, 0.3);
}

static function TweenToWalking(pawn Other, float tweentime)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.TweenAnim('Walk', tweentime);
	else if ( Other.Weapon.bPointing || (Other.CarriedDecoration != None) )
	{
		if (Other.Weapon.Mass < 20)
			Other.TweenAnim('WalkSMFR', tweentime);
		else
			Other.TweenAnim('WalkLGFR', tweentime);
	}
	else
	{
		if (Other.Weapon.Mass < 20)
			Other.TweenAnim('WalkSM', tweentime);
		else
			Other.TweenAnim('WalkLG', tweentime);
	}
}

static function PlayWalking(pawn Other)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.LoopAnim('Walk');
	else if ( Other.Weapon.bPointing || (Other.CarriedDecoration != None) )
	{
		if (Other.Weapon.Mass < 20)
			Other.LoopAnim('WalkSMFR');
		else
			Other.LoopAnim('WalkLGFR');
	}
	else
	{
		if (Other.Weapon.Mass < 20)
			Other.LoopAnim('WalkSM');
		else
			Other.LoopAnim('WalkLG');
	}
}

static function PlayRising(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = 0.4 * Other.Default.BaseEyeHeight;
	Other.TweenAnim('DuckWlkS', 0.7);
}

static function PlayFeignDeath(pawn Other)
{
	local float decision;

	CheckMesh(Other);

	Other.BaseEyeHeight = 0;
	if ( decision < 0.33 )
		Other.TweenAnim('DeathEnd', 0.5);
	else if ( decision < 0.67 )
		Other.TweenAnim('DeathEnd2', 0.5);
	else
		Other.TweenAnim('DeathEnd3', 0.5);
}

static function PlayDuck(pawn Other)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = 0;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('DuckWlkS', 0.25);
	else
		Other.TweenAnim('DuckWlkL', 0.25);
}

static function TweenToWaiting(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.IsInState('PlayerSwimming')) || (Other.Physics == PHYS_Swimming) )
	{
		Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('TreadSM', tweentime);
		else
			Other.TweenAnim('TreadLG', tweentime);
	}
	else
	{
		Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('StillSMFR', tweentime);
		else
			Other.TweenAnim('StillFRRP', tweentime);
	}
}

static function PlayRecoil(pawn Other, float Rate)
{
	CheckMesh(Other);

	if ( Other.Weapon.bRapidFire )
	{
		if ( !Other.IsAnimating() && (Other.Physics == PHYS_Walking) )
			Other.LoopAnim('StillFRRP', 0.02);
	}
	else if ( Other.AnimSequence == 'StillSmFr')
		Other.PlayAnim('StillSmFr', Rate, 0.02);
	else if ( (Other.AnimSequence == 'StillLgFr') || (Other.AnimSequence == 'StillFrRp') )
		Other.PlayAnim('StillLgFr', Rate, 0.02);
}

static function PlayWeaponSwitch(pawn Other, Weapon NewWeapon)
{
	CheckMesh(Other);

	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
	{
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (Other.AnimSequence == 'RunSM') || (Other.AnimSequence == 'RunSMFR') )
				Other.AnimSequence = 'RunLG';
			else if ( (Other.AnimSequence == 'WalkSM') || (Other.AnimSequence == 'WalkSMFR') )
				Other.AnimSequence = 'WalkLG';
		 	else if ( Other.AnimSequence == 'JumpSMFR')
		 		Other.AnimSequence = 'JumpLGFR';
			else if ( Other.AnimSequence == 'DuckWlkL')
				Other.AnimSequence = 'DuckWlkS';
		 	else if ( Other.AnimSequence == 'StillSMFR')
		 		Other.AnimSequence = 'StillFRRP';
			else if ( Other.AnimSequence == 'AimDnSm')
				Other.AnimSequence = 'AimDnLg';
			else if ( Other.AnimSequence == 'AimUpSm')
				Other.AnimSequence = 'AimUpLg';
		 }
	}
	else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
	{
		if ( (Other.AnimSequence == 'RunLG') || (Other.AnimSequence == 'RunLGFR') )
			Other.AnimSequence = 'RunSM';
		else if ( (Other.AnimSequence == 'WalkLG') || (Other.AnimSequence == 'WalkLGFR') )
			Other.AnimSequence = 'WalkSM';
	 	else if ( Other.AnimSequence == 'JumpLGFR')
	 		Other.AnimSequence = 'JumpSMFR';
		else if ( Other.AnimSequence == 'DuckWlkS')
			Other.AnimSequence = 'DuckWlkL';
	 	else if (Other.AnimSequence == 'StillFRRP')
	 		Other.AnimSequence = 'StillSMFR';
		else if ( Other.AnimSequence == 'AimDnLg')
			Other.AnimSequence = 'AimDnSm';
		else if ( Other.AnimSequence == 'AimUpLg')
			Other.AnimSequence = 'AimUpSm';
	}
}

static function PlaySwimming(pawn Other)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
	if ((Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.LoopAnim('SwimSM');
	else
		Other.LoopAnim('SwimLG');
}

static function TweenToSwimming(pawn Other, float tweentime)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
	if ((Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('SwimSM',tweentime);
	else
		Other.TweenAnim('SwimLG',tweentime);
}

static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	local carcass carc;

	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	TournamentPlayer(Other).PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		Other.PlayAnim('Dead1', 0.7, 0.1);
		return;
	}

	if ( FRand() < 0.15 )
	{
		Other.PlayAnim('Dead3',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Other.Velocity.Z > 250) && (FRand() < 0.7) )
	{
		Other.PlayAnim('Dead2', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Other.Location.Z > 0.6 * Other.CollisionHeight))
		 && !class'GameInfo'.Default.bVeryLowGore )
	{
		DamageType = 'Decapitated';
		PlayDecap(Other);
		/*if ( Level.NetMode != NM_Client )
		{
			carc = Spawn(class'FemaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
			if (carc != None)
			{
				carc.Initfor(self);
				carc.Velocity = Velocity + VSize(Velocity) * VRand();
				carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				ViewTarget = carc;
			}
		}*/
		Other.PlayAnim('Dead6', 0.7, 0.1);
		return;
	}


	if ( FRand() < 0.15)
	{
		Other.PlayAnim('Dead1', 0.7, 0.1);
		return;
	}

	Other.GetAxes(Other.Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Other.Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	/* check for repeater death
	if ( (Other.Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
	{
		Other.PlayAnim(default.Dead9,, 0.1);
		return;
	}*/

	if (Abs(dotp) > 0.71) //then hit in front or back
		Other.PlayAnim('Dead4', 0.7, 0.1);
	else
	{
		dotp = HitVec dot Y;
		if ( (dotp > 0.0) && !class'GameInfo'.Default.bVeryLowGore )
		{
			Other.PlayAnim('Dead7', 0.7, 0.1);
			Other.Spawn(class'Arm1',,, Other.Location);
			if (carc != None)
			{
				carc.Initfor(Other);
				carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
				carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
			}
		}
		else
			Other.PlayAnim('Dead5', 0.7, 0.1);
	}
}

static function PlayRunning(pawn Other)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.LoopAnim('RunSM');
	else if ( Other.Weapon.bPointing )
	{
		if (Other.Weapon.Mass < 20)
			Other.LoopAnim('RunSMFR');
		else
			Other.LoopAnim('RunLGFR');
	}
	else
	{
		if (Other.Weapon.Mass < 20)
			Other.LoopAnim('RunSM');
		else
			Other.LoopAnim('RunLG');
	}
}

static function TweenToRunning(pawn Other, float tweentime)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.bIsWalking)
	{
		Other.TweenToWalking(0.1);
		return;
	}

	if (Other.Weapon == None)
		Other.PlayAnim('RunSM', 0.9, tweentime);
	else if ( Other.Weapon.bPointing )
	{
		if (Other.Weapon.Mass < 20)
			Other.PlayAnim('RunSMFR', 0.9, tweentime);
		else
			Other.PlayAnim('RunLGFR', 0.9, tweentime);
	}
	else
	{
		if (Other.Weapon.Mass < 20)
			Other.PlayAnim('RunSM', 0.9, tweentime);
		else
			Other.PlayAnim('RunLG', 0.9, tweentime);
	}
}

static function PlayWaiting(pawn Other)
{
	local name newAnim;

	CheckMesh(Other);

	if ( (Other.IsInState('PlayerSwimming')) || (Other.Physics == PHYS_Swimming) )
	{
		Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.LoopAnim('TreadSM');
		else
			Other.LoopAnim('TreadLG');
	}
	else
	{
		Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
		Other.ViewRotation.Pitch = Other.ViewRotation.Pitch & 65535;
		If ( (Other.ViewRotation.Pitch > Other.RotationRate.Pitch)
			&& (Other.ViewRotation.Pitch < 65536 - Other.RotationRate.Pitch) )
		{
			If (Other.ViewRotation.Pitch < 32768)
			{
				if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
					Other.TweenAnim('AimUpSm', 0.3);
				else
					Other.TweenAnim('AimUpLg', 0.3);
			}
			else
			{
				if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
					Other.TweenAnim('AimDnSm', 0.3);
				else
					Other.TweenAnim('AimDnLg', 0.3);
			}
		}
		else if ( (Other.Weapon != None) && Other.Weapon.bPointing )
		{
			if ( Other.Weapon.bRapidFire && ((Other.bFire != 0) || (Other.bAltFire != 0)) )
				Other.LoopAnim('StillFRRP');
			else if ( Other.Weapon.Mass < 20 )
				Other.TweenAnim('StillSMFR', 0.3);
			else
				Other.TweenAnim('StillFRRP', 0.3);
		}
		else
		{
			if ( FRand() < 0.1 )
			{
				if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
					Other.PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
				else
					Other.PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
			}
			else
			{
				if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
				{
					if ( Other.Health > 50 )
						newAnim = 'Breath1';
					else
						newAnim = 'Breath2';
				}
				else
				{
					if ( Other.Health > 50 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}

				if ( Other.AnimSequence == newAnim )
					Other.LoopAnim(newAnim, 0.3 + 0.7 * FRand());
				else
					Other.PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
			}
		}
	}
}

static function PlayDodge(pawn Other, eDodgeDir DodgeMove)
{
	CheckMesh(Other);
	PlayDuck(Other);
}

static function PlayInAir(pawn Other)
{
	Other.BaseEyeHeight =  0.7 * Other.Default.BaseEyeHeight;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('JumpSMFR', 0.8);
	else
		Other.TweenAnim('JumpLGFR', 0.8);
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
	if ( (Other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead4') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('HeadHit', tweentime);
	else
		Other.TweenAnim('Dead4', tweentime);
}

static function PlayLeftHit(pawn Other, float tweentime)
{
	if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead3') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('LeftHit', tweentime);
	else
		Other.TweenAnim('Dead3', tweentime);
}

static function PlayRightHit(pawn Other, float tweentime)
{
	if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead5') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('RightHit', tweentime);
	else
		Other.TweenAnim('Dead5', tweentime);
}

// moved here in release 2
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

static function PlayCrawling(pawn Other)
{
	CheckMesh(Other);

	//log("Play duck");
	Other.BaseEyeHeight = 0;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.LoopAnim('DuckWlkS');
	else
		Other.LoopAnim('DuckWlkL');
}

defaultproperties
{
	DecapClass=Class'FemaleHead'
}