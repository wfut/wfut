//=============================================================================
// WFD_TournamentPlayerMeshInfo. (from UT v4.02)
//
// Parent of all Unreal Tournament Mesh animation classes.
//=============================================================================
class WFD_TournamentPlayerMeshInfo extends WFD_PlayerPawnMeshInfo;

//=============================================================================
// Static Animation Functions

// update HUD icons (FIXME: don't update icons on a dedicated server)
static function UpdateIcons(pawn Other)
{
	// don't want to update icons on the server
	if (Other.Level.NetMode == NM_DedicatedServer)
		return;

	//Log("[--Debug--]: UpdateIcons() called for: "$Other);

	if ((TournamentPlayer(Other).StatusDoll != default.StatusDoll) && (default.StatusDoll != none))
		TournamentPlayer(Other).StatusDoll = default.StatusDoll;

	if ((TournamentPlayer(Other).StatusBelt != default.StatusBelt) && (default.StatusBelt != none))
		TournamentPlayer(Other).StatusBelt = default.StatusBelt;
}

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
// static player animation functions

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

static function TweenToRunning(pawn Other, float tweentime)
{
	local vector X,Y,Z, Dir;

	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.bIsWalking)
	{
		Other.TweenToWalking(0.1);
		return;
	}

	GetAxes(Other.Rotation, X,Y,Z);
	Dir = Normal(Other.Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( Dir Dot X < -0.75 )
			Other.PlayAnim('BackRun', 0.9, tweentime);
		else if ( Dir Dot Y > 0 )
			Other.PlayAnim('StrafeR', 0.9, tweentime);
		else
			Other.PlayAnim('StrafeL', 0.9, tweentime);
	}
	else if (Other.Weapon == None)
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

static function PlayRunning(pawn Other)
{
	local vector X,Y,Z, Dir;

	CheckMesh(Other);

	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;

	// determine facing direction
	GetAxes(Other.Rotation, X,Y,Z);
	Dir = Normal(Other.Acceleration);
	if ( (Dir Dot X < 0.75) && (Dir != vect(0,0,0)) )
	{
		// strafing or backing up
		if ( Dir Dot X < -0.75 )
			Other.LoopAnim('BackRun');
		else if ( Dir Dot Y > 0 )
			Other.LoopAnim('StrafeR');
		else
			Other.LoopAnim('StrafeL');
	}
	else if (Other.Weapon == None)
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

static function PlayInAir(pawn Other)
{
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	CheckMesh(Other);

	Other.BaseEyeHeight =  0.7 * Other.Default.BaseEyeHeight;

	if ( (Other.GetAnimGroup(Other.AnimSequence) == 'Landing') && !TournamentPlayer(Other).bLastJumpAlt )
	{
		GetAxes(Other.Rotation, X,Y,Z);
		Dir = Normal(Other.Acceleration);
		f = Dir dot Y;
		if ( f > 0.7 )
			Other.TweenAnim('DodgeL', 0.35);
		else if ( f < -0.7 )
			Other.TweenAnim('DodgeR', 0.35);
		else if ( Dir dot X > 0 )
			Other.TweenAnim('DodgeF', 0.35);
		else
			Other.TweenAnim('DodgeB', 0.35);
		TournamentPlayer(Other).bLastJumpAlt = true;
		return;
	}
	TournamentPlayer(Other).bLastJumpAlt = false;
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

	if ( Other.AnimSequence == 'StrafeL')
		Other.TweenAnim('DodgeR', TweenTime);
	else if ( Other.AnimSequence == 'StrafeR')
		Other.TweenAnim('DodgeL', TweenTime);
	else if ( Other.AnimSequence == 'BackRun')
		Other.TweenAnim('DodgeB', TweenTime);
	else if ( (Other.Weapon == None) || (Other.Weapon.Mass < 20) )
		Other.TweenAnim('JumpSMFR', TweenTime);
	else
		Other.TweenAnim('JumpLGFR', TweenTime);
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

// from BotPack.TournamentMale
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

static function PlayDecap(pawn Other)
{
	local carcass carc;

	CheckMesh(Other);

	Other.PlayAnim('Dead4',, 0.1);

	if ( Other.Level.NetMode != NM_Client )
	{
		carc = Other.Spawn(default.DecapClass,,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		if (carc != None)
		{
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
		Other.TweenAnim('Dead2', tweentime);

}

static function PlayHeadHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'HeadHit') || (Other.AnimSequence == 'Dead4') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('HeadHit', tweentime);
	else
		Other.TweenAnim('Dead4', tweentime);
}

static function PlayLeftHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'LeftHit') || (Other.AnimSequence == 'Dead3') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('LeftHit', tweentime);
	else
		Other.TweenAnim('Dead3', tweentime);
}

static function PlayRightHit(pawn Other, float tweentime)
{
	CheckMesh(Other);

	if ( (Other.AnimSequence == 'RightHit') || (Other.AnimSequence == 'Dead5') )
		Other.TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		Other.TweenAnim('RightHit', tweentime);
	else
		Other.TweenAnim('Dead5', tweentime);
}

static function PlayWaiting(pawn Other)
{
	local name newAnim;

	CheckMesh(Other);

	if ( Other.Mesh == None )
		return;

	if ( PlayerPawn(Other).bIsTyping )
	{
		PlayChatting(Other);
		return;
	}

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

static function PlayChatting(pawn Other)
{
	if ( Other.mesh != None )
		Other.LoopAnim('Chat1', 0.7, 0.25);
}

static function PlayDodge(pawn Other, eDodgeDir DodgeMove)
{
	CheckMesh(Other);

	Other.Velocity.Z = 210;
	if ( DodgeMove == DODGE_Left )
		Other.TweenAnim('DodgeL', 0.25);
	else if ( DodgeMove == DODGE_Right )
		Other.TweenAnim('DodgeR', 0.25);
	else if ( DodgeMove == DODGE_Back )
		Other.TweenAnim('DodgeB', 0.25);
	else
		Other.PlayAnim('Flip', 1.35 * FMax(0.35, Other.Region.Zone.ZoneGravity.Z/Other.Region.Zone.Default.ZoneGravity.Z), 0.06);
}


defaultproperties
{
	bIsMultiSkinned=True
	StatusDoll=Texture'Botpack.Icons.Man'
	StatusBelt=Texture'Botpack.Icons.ManBelt'
    CollisionRadius=17.000000
    CollisionHeight=39.000000
}