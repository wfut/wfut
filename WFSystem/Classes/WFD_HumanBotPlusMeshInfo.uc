//=============================================================================
// WFD_HumanBotPlusMeshInfo.
//=============================================================================
class WFD_HumanBotPlusMeshInfo extends WFD_BotMeshInfo;

//=============================================================================
// skin functions

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	local string ShortSkinName, FullSkinName, ShortFaceName, FullFaceName;

	FullSkinName  = String(SkinActor.Multiskins[default.FixedSkin]);
	ShortSkinName = SkinActor.GetItemName(FullSkinName);

	FullFaceName = String(SkinActor.Multiskins[default.FaceSkin]);
	ShortFaceName = SkinActor.GetItemName(FullFaceName);

	SkinName = Left(FullSkinName, Len(FullSkinName) - Len(ShortSkinName)) $ Left(ShortSkinName, 4);
	FaceName = Left(FullFaceName, Len(FullFaceName) - Len(ShortFaceName)) $Mid(ShortFaceName, 5);
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	//Log("SetMutliSkin: Params: SkinName: "$SkinName);
	//Log("SetMutliSkin: Params: FaceName: "$FaceName);

	// use the default skin if none specified
	if (SkinName == "")
		SkinName = default.DefaultSkinName;

	// use the default face if none specified
	if (FaceName == "")
		FaceName = default.DefaultFaceName;

	SkinItem = SkinActor.GetItemName(SkinName);
	FaceItem = SkinActor.GetItemName(FaceName);
	SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));
	FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));

	//Log("SetMutliSkin: SkinItem: "$SkinItem);
	//Log("SetMutliSkin: FaceItem: "$FaceItem);
	//Log("SetMutliSkin: SkinPackage: "$SkinPackage);
	//Log("SetMutliSkin: FacePackage: "$FacePackage);

	if(SkinPackage == "")
	{
		SkinPackage=default.DefaultPackage;
		SkinName=SkinPackage$SkinName;
	}
	if(FacePackage == "")
	{
		FacePackage=default.DefaultPackage;
		FaceName=FacePackage$FaceName;
	}

	//Log("SetMutliSkin: SkinName: "$SkinName);
	//Log("SetMutliSkin: FaceName: "$FaceName);

	// Set the fixed skin element.  If it fails, go to default skin & no face.
	if(!SetSkinElement(SkinActor, default.FixedSkin, SkinName$string(default.FixedSkin+1), default.DefaultSkinName$string(default.FixedSkin+1)))
	{
		//Log("SetMultiSkin: Fixed Skin Not Set -- Using default.");
		SkinName = default.DefaultSkinName;
		FaceName = ""; // could set to "default.DefaultFaceName"
	}

	// Set the face - if it fails, set the default skin for that face element.
	SetSkinElement(SkinActor, default.FaceSkin, FacePackage$SkinItem$String(default.FaceSkin+1)$FaceItem, SkinName$String(default.FaceSkin+1));

	// Set the team elements
	if( TeamNum != 255 )
	{
		//Log("SetMultiSkin: Attempting to set Team skin -- Team: "$TeamNum);
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin1+1));
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin2+1));
	}
	else
	{
		SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1), "");
		SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1), "");
	}

	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		//Log("SetMutliSkin: Setting talk texture.");
		if (FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$default.DefaultFaceName, class'Texture'));
	}
}
//=============================================================================
static function PlayTurning(pawn Other)
{
	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.PlayAnim('TurnSM', 0.3, 0.3);
	else
		Other.PlayAnim('TurnLG', 0.3, 0.3);
}

static function PlayVictoryDance(pawn Other)
{
	Other.PlayAnim('Victory1', 0.7);
}

static function PlayWaving(pawn Other)
{
	Other.PlayAnim('Wave', 0.7, 0.2);
}

static function TweenToWalking(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( Other.Physics == PHYS_Swimming )
	{
		if ( (vector(Other.Rotation) Dot Other.Acceleration) > 0 )
			Other.TweenToSwimming(tweentime);
		else
			Other.TweenToWaiting(tweentime);
	}

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.TweenAnim('Walk', tweentime);
	else if ( Other.Weapon.bPointing )
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

static function TweenToRunning(pawn Other, float tweentime)
{
	local name newAnim;

	CheckMesh(Other);

	if ( Other.Physics == PHYS_Swimming )
	{
		if ( (vector(Other.Rotation) Dot Other.Acceleration) > 0 )
			Other.TweenToSwimming(tweentime);
		else
			Other.TweenToWaiting(tweentime);
		return;
	}

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;

	if (Other.Weapon == None)
		newAnim = 'RunSM';
	else if ( Other.Weapon.bPointing )
	{
		if (Other.Weapon.Mass < 20)
			newAnim = 'RunSMFR';
		else
			newAnim = 'RunLGFR';
	}
	else
	{
		if (Other.Weapon.Mass < 20)
			newAnim = 'RunSM';
		else
			newAnim = 'RunLG';
	}

	if ( (newAnim == Other.AnimSequence) && (Other.Acceleration != vect(0,0,0)) && Other.IsAnimating() )
		return;
	Other.TweenAnim(newAnim, tweentime);
}

static function PlayWalking(pawn Other)
{
	CheckMesh(Other);

	if ( Other.Physics == PHYS_Swimming )
	{
		if ( (vector(Other.Rotation) Dot Other.Acceleration) > 0 )
			WFD_DPMSBot(Other).PlaySwimming();
		else
			Other.PlayWaiting();
		return;
	}

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.LoopAnim('Walk');
	else if ( Other.Weapon.bPointing )
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

static function PlayRunning(pawn Other)
{
	local float strafeMag;
	local vector Focus2D, Loc2D, Dest2D;
	local vector lookDir, moveDir, Y;
	local name NewAnim;

	CheckMesh(Other);

	if ( Other.Physics == PHYS_Swimming )
	{
		if ( (vector(Other.Rotation) Dot Other.Acceleration) > 0 )
			WFD_DPMSBot(Other).PlaySwimming();
		else
			Other.PlayWaiting();
		return;
	}
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;

	if ( Other.bAdvancedTactics && !Bot(Other).bNoTact )
	{
		if ( Bot(Other).bTacticalDir )
			Other.LoopAnim('StrafeL');
		else
			Other.LoopAnim('StrafeR');
		return;
	}
	else if ( Other.Focus != Other.Destination )
	{
		// check for strafe or backup
		Focus2D = Other.Focus;
		Focus2D.Z = 0;
		Loc2D = Other.Location;
		Loc2D.Z = 0;
		Dest2D = Other.Destination;
		Dest2D.Z = 0;
		lookDir = Normal(Focus2D - Loc2D);
		moveDir = Normal(Dest2D - Loc2D);
		strafeMag = lookDir dot moveDir;
		if ( strafeMag < 0.75 )
		{
			if ( strafeMag < -0.75 )
				Other.LoopAnim('BackRun');
			else
			{
				Y = (lookDir Cross vect(0,0,1));
				if ((Y Dot (Dest2D - Loc2D)) > 0)
					Other.LoopAnim('StrafeL');
				else
					Other.LoopAnim('StrafeR');
			}
			return;
		}
	}

	if (Other.Weapon == None)
		newAnim = 'RunSM';
	else if ( Other.Weapon.bPointing )
	{
		if (Other.Weapon.Mass < 20)
			newAnim = 'RunSMFR';
		else
			newAnim = 'RunLGFR';
	}
	else
	{
		if (Other.Weapon.Mass < 20)
			newAnim = 'RunSM';
		else
			newAnim = 'RunLG';
	}
	if ( (newAnim == Other.AnimSequence) && Other.IsAnimating() )
		return;

	Other.LoopAnim(NewAnim);
}

static function PlayRising(pawn Other)
{
	Other.BaseEyeHeight = 0.4 * Other.Default.BaseEyeHeight;
	Other.TweenAnim('DuckWlkS', 0.7);
}

static function PlayFeignDeath(pawn Other)
{
	local float decision;

	Other.BaseEyeHeight = 0;
	if ( decision < 0.33 )
		Other.TweenAnim('DeathEnd', 0.5);
	else if ( decision < 0.67 )
		Other.TweenAnim('DeathEnd2', 0.5);
	else
		Other.TweenAnim('DeathEnd3', 0.5);
}

static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	local carcass carc;

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	Bot(Other).PlayDyingSound();
	Other.PlayAnim('Dead3',0.7,0.1);
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

// *** This function also plays sound ***
static function PlayLanded(pawn Other, float impactVel)
{
	impactVel = impactVel/Other.JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		Other.PlaySound(WFD_DPMSBot(Other).SoundInfo.default.LandGrunt, SLOT_Talk, FMin(4, 5 * impactVel),false,1600,FRand()*0.4+0.8);
	if ( !Other.FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		Other.PlaySound(WFD_DPMSBot(Other).SoundInfo.default.Land, SLOT_Interact, FClamp(4 * impactVel,0.2,4.5), false,1600, 1.0);

	if ( (impactVel > 0.06) || (Other.GetAnimGroup(Other.AnimSequence) == 'Jumping') )
	{
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('LandSMFR', 0.12);
		else
			Other.TweenAnim('LandLGFR', 0.12);
	}
	else if ( !Other.IsAnimating() )
	{
		if ( Other.GetAnimGroup(Other.AnimSequence) == 'TakeHit' )
			Other.AnimEnd();
		else
		{
			if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
				Other.TweenAnim('LandSMFR', 0.12);
			else
				Other.TweenAnim('LandLGFR', 0.12);
		}
	}
}

static function FastInAir(pawn Other)
{
	local float TweenTime;

	Other.BaseEyeHeight =  0.7 * Other.Default.BaseEyeHeight;
	if ( Other.GetAnimGroup(Other.AnimSequence) == 'Jumping' )
	{
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('DuckWlkS', 1);
		else
			Other.TweenAnim('DuckWlkL', 1);
		return;
	}
	else if ( Other.GetAnimGroup(Other.AnimSequence) == 'Ducking' )
		TweenTime = 1;
	else
		TweenTime = 0.3;

	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('JumpSMFR', TweenTime);
	else
		Other.TweenAnim('JumpLGFR', TweenTime);
}

static function PlayInAir(pawn Other)
{
	local float TweenTime;

	Other.BaseEyeHeight =  0.7 * Other.Default.BaseEyeHeight;
	if ( Other.GetAnimGroup(Other.AnimSequence) == 'Jumping' )
	{
		if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('DuckWlkS', 2);
		else
			Other.TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( Other.GetAnimGroup(Other.AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('JumpSMFR', TweenTime);
	else
		Other.TweenAnim('JumpLGFR', TweenTime);
}

static function BotPlayDodge(pawn Other, bool bDuckLeft)
{
	if ( bDuckLeft )
		Other.TweenAnim('DodgeL', 0.25);
	else
		Other.TweenAnim('DodgeR', 0.25);
}

static function PlayDuck(pawn Other)
{
	Other.BaseEyeHeight = 0;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('DuckWlkS', 0.25);
	else
		Other.TweenAnim('DuckWlkL', 0.25);
}

static function PlayCrawling(pawn Other)
{
	//log("Play duck");
	Other.BaseEyeHeight = 0;
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.LoopAnim('DuckWlkS');
	else
		Other.LoopAnim('DuckWlkL');
}

static function TweenToWaiting(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( Other.Physics == PHYS_Swimming )
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
		if ( Other.Enemy != None )
			Bot(Other).ViewRotation = Rotator(Other.Enemy.Location - Other.Location);
		else
		{
			if ( Other.GetAnimGroup(Other.AnimSequence) == 'Waiting' )
				return;
			Bot(Other).ViewRotation.Pitch = 0;
		}
		Bot(Other).ViewRotation.Pitch = Bot(Other).ViewRotation.Pitch & 65535;
		If ( (Bot(Other).ViewRotation.Pitch > Other.RotationRate.Pitch)
			&& (Bot(Other).ViewRotation.Pitch < 65536 - Other.RotationRate.Pitch) )
		{
			If (Bot(Other).ViewRotation.Pitch < 32768)
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
		else if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
			Other.TweenAnim('StillSMFR', tweentime);
		else
			Other.TweenAnim('StillFRRP', tweentime);
	}
}

static function TweenToFighter(pawn Other, float tweentime)
{
	Other.TweenToWaiting(tweentime);
}


static function PlayChallenge(pawn Other)
{
	Other.TweenToWaiting(0.17);
}

static function PlayLookAround(pawn Other)
{
	Other.LoopAnim('Look', 0.3 + 0.7 * FRand(), 0.1);
}

static function PlayWaiting(pawn Other)
{
	local name newAnim;

	CheckMesh(Other);

	if (Other.GetStateName() == 'ImpactJumping')
	{
		Other.TweenAnim('AimDnLg', 0.3);
		return;
	}

	if ( Other.Physics == PHYS_Swimming )
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
		if ( (Other.Weapon != None) && Other.Weapon.bPointing )
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
			if ( Other.Level.Game.bTeamGame
				&& ((FRand() < 0.04)
					|| ((Other.AnimSequence == 'Chat1') && (FRand() < 0.75))) )
			{
				newAnim = 'Chat1';
			}
			else if ( FRand() < 0.1 )
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
					if ( (FRand() < 0.75) && ((Other.AnimSequence == 'Breath1') || (Other.AnimSequence == 'Breath2')) )
						newAnim = Other.AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1';
					else
						newAnim = 'Breath2';
				}
				else
				{
					if ( (FRand() < 0.75) && ((Other.AnimSequence == 'Breath1L') || (Other.AnimSequence == 'Breath2L')) )
						newAnim = Other.AnimSequence;
					else if ( FRand() < 0.5 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}

				if ( Other.AnimSequence == newAnim )
					Other.LoopAnim(newAnim, 0.4 + 0.4 * FRand());
				else
					Other.PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
			}
		}
	}
}

static function PlayRecoil(pawn Other, float Rate)
{
	if ( Other.Weapon.bRapidFire )
	{
		if ( (Other.Weapon.AmmoType != None) && (Other.Weapon.AmmoType.AmmoAmount < 2) )
			Other.TweenAnim('StillFRRP', 0.1);
		else if ( !Other.IsAnimating() && (Other.Physics == PHYS_Walking) )
			Other.LoopAnim('StillFRRP', 0.02);
	}
	else if ( Other.AnimSequence == 'StillSmFr' )
		Other.PlayAnim('StillSmFr', Rate, 0.02);
	else if ( (Other.AnimSequence == 'StillLgFr') || (Other.AnimSequence == 'StillFrRp') )
		Other.PlayAnim('StillLgFr', Rate, 0.02);
}

static function PlayFiring(pawn Other)
{
	// switch animation sequence mid-stream if needed
	if ( Other.GetAnimGroup(Other.AnimSequence) == 'MovingFire' )
		return;
	else if (Other.AnimSequence == 'RunLG')
		Other.AnimSequence = 'RunLGFR';
	else if (Other.AnimSequence == 'RunSM')
		Other.AnimSequence = 'RunSMFR';
	else if (Other.AnimSequence == 'WalkLG')
		Other.AnimSequence = 'WalkLGFR';
	else if (Other.AnimSequence == 'WalkSM')
		Other.AnimSequence = 'WalkSMFR';
	else if ( Other.AnimSequence == 'JumpSMFR' )
		Other.TweenAnim('JumpSMFR', 0.03);
	else if ( Other.AnimSequence == 'JumpLGFR' )
		Other.TweenAnim('JumpLGFR', 0.03);
	else if ( (Other.GetAnimGroup(Other.AnimSequence) == 'Waiting') || (Other.GetAnimGroup(Other.AnimSequence) == 'Gesture')
		&& (Other.AnimSequence != 'TreadLG') && (Other.AnimSequence != 'TreadSM') )
	{
		if ( Other.Weapon.Mass < 20 )
			Other.TweenAnim('StillSMFR', 0.02);
		else if ( !Other.Weapon.bRapidFire || (Other.AnimSequence != 'StillFRRP') )
			Other.TweenAnim('StillFRRP', 0.02);
		else if ( !Other.IsAnimating() )
			Other.LoopAnim('StillFRRP');
	}
}

static function PlayWeaponSwitch(pawn Other, Weapon NewWeapon)
{
	if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
	{
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (Other.AnimSequence == 'RunSM') || (Other.AnimSequence == 'RunSMFR') )
				Other.AnimSequence = 'RunLG';
			else if ( (Other.AnimSequence == 'WalkSM') || (Other.AnimSequence == 'WalkSMFR') )
				Other.AnimSequence = 'WalkLG';
		 	else if ( Other.AnimSequence == 'JumpSMFR' )
		 		Other.AnimSequence = 'JumpLGFR';
			else if ( Other.AnimSequence == 'DuckWlkL' )
				Other.AnimSequence = 'DuckWlkS';
		 	else if ( Other.AnimSequence == 'StillSMFR' )
		 		Other.AnimSequence = 'StillFRRP';
			else if ( Other.AnimSequence == 'AimDnSm' )
				Other.AnimSequence = 'AimDnLg';
			else if ( Other.AnimSequence == 'AimUpSm' )
				Other.AnimSequence = 'AimUpLg';
		 }
	}
	else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
	{
		if ( (Other.AnimSequence == 'RunLG') || (Other.AnimSequence == 'RunLGFR') )
			Other.AnimSequence = 'RunSM';
		else if ( (Other.AnimSequence == 'WalkLG') || (Other.AnimSequence == 'WalkLGFR') )
			Other.AnimSequence = 'WalkSM';
	 	else if ( Other.AnimSequence == 'JumpLGFR' )
	 		Other.AnimSequence = 'JumpSMFR';
		else if ( Other.AnimSequence == 'DuckWlkS' )
			Other.AnimSequence = 'DuckWlkL';
	 	else if (Other.AnimSequence == 'StillFRRP')
	 		Other.AnimSequence = 'StillSMFR';
		else if ( Other.AnimSequence == 'AimDnLg' )
			Other.AnimSequence = 'AimDnSm';
		else if ( Other.AnimSequence == 'AimUpLg' )
			Other.AnimSequence = 'AimUpSm';
	}
}

static function PlaySwimming(pawn Other)
{
	Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
	if ((Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.LoopAnim('SwimSM');
	else
		Other.LoopAnim('SwimLG');
}

static function TweenToSwimming(pawn Other, float tweentime)
{
	Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
	if ((Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('SwimSM',tweentime);
	else
		Other.TweenAnim('SwimLG',tweentime);
}

/* used GetStateName() in Global.PlayWaiting()
State ImpactJumping
{
	function PlayWaiting()
	{
		TweenAnim('AimDnLg', 0.3);
	}
}*/

defaultproperties
{
	bIsMultiSkinned=True
	StatusDoll=Texture'Botpack.Icons.Man'
	StatusBelt=Texture'Botpack.Icons.ManBelt'
    CollisionRadius=17.000000
    CollisionHeight=39.000000
}