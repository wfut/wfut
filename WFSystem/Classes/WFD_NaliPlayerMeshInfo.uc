//=============================================================================
// WFD_NaliPlayerMeshInfo.
//=============================================================================
class WFD_NaliPlayerMeshInfo extends WFD_UnrealIPlayerMeshInfo;

static function PlayTurning(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	Other.PlayAnim('Turn', 0.3, 0.3);
}

static function TweenToWalking(pawn Other, float tweentime)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.TweenAnim('Walk', tweentime);
	else if ( Other.Weapon.bPointing || (Other.CarriedDecoration != None) )
		Other.TweenAnim('WalkFire', tweentime);
	else
		Other.TweenAnim('Walk', tweentime);
}

static function TweenToRunning(pawn Other, float tweentime)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.bIsWalking)
		Other.TweenToWalking(0.1);
	else if (Other.Weapon == None)
		Other.PlayAnim('Run', 1, tweentime);
	else if ( Other.Weapon.bPointing )
		Other.PlayAnim('RunFire', 1, tweentime);
	else
		Other.PlayAnim('Run', 1, tweentime);
}

static function PlayWalking(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.LoopAnim('Walk');
	else if ( Other.Weapon.bPointing || (Other.CarriedDecoration != None) )
		Other.LoopAnim('WalkFire');
	else
		Other.LoopAnim('Walk');
}

static function PlayRunning(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	if (Other.Weapon == None)
		Other.LoopAnim('Run');
	else if ( Other.Weapon.bPointing )
		Other.LoopAnim('RunFire');
	else
		Other.LoopAnim('Run');
}

static function PlayRising(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = 0.4 * Other.Default.BaseEyeHeight;
	Other.TweenAnim('DuckWalk', 0.7);
}

static function PlayFeignDeath(pawn Other)
{
	local float decision;

	CheckMesh(Other);
	Other.BaseEyeHeight = 0;
	//Other.PlayAnim('Levitate', 0.3, 1.0);
	Other.PlayAnim('Dead2', 0.7, 1.0);
}

static function PlayDying(pawn Other, name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;

	CheckMesh(Other);
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
	WFD_DPMSPlayer(Other).PlayDyingSound();

	if ( FRand() < 0.15 )
	{
		Other.PlayAnim('Dead',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Other.Velocity.Z > 250) && (FRand() < 0.7) )
	{
		Other.PlayAnim('Dead4', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') || (HitLoc.Z - Other.Location.Z > 0.6 * Other.CollisionHeight) )
	{
		DamageType = 'Decapitated';
		Other.PlayAnim('Dead3', 0.7, 0.1);
		if (!class'GameInfo'.default.bVeryLowGore)
			PlayDecap(Other);
		return;
	}

	Other.GetAxes(Other.Rotation,X,Y,Z);
	HitVec = Normal(HitLoc - Other.Location);
	dotp = HitVec dot Y;
	if (dotp > 0.0)
		Other.PlayAnim('Dead', 0.7, 0.1);
	else
		Other.PlayAnim('Dead2', 0.7, 0.1);
}

//FIXME - add death first frames as alternate takehit anims!!!

static function PlayGutHit(pawn Other, float tweentime)
{
	CheckMesh(Other);
	if ( Other.AnimSequence == 'GutHit' )
	{
		if (FRand() < 0.5)
			Other.TweenAnim('LeftHit', tweentime);
		else
			Other.TweenAnim('RightHit', tweentime);
	}
	else
		Other.TweenAnim('GutHit', tweentime);
}

static function PlayHeadHit(pawn Other, float tweentime)
{
	CheckMesh(Other);
	if ( Other.AnimSequence == 'HeadHit' )
		Other.TweenAnim('GutHit', tweentime);
	else
		Other.TweenAnim('HeadHit', tweentime);
}

static function PlayLeftHit(pawn Other, float tweentime)
{
	CheckMesh(Other);
	if ( Other.AnimSequence == 'LeftHit' )
		Other.TweenAnim('GutHit', tweentime);
	else
		Other.TweenAnim('LeftHit', tweentime);
}

static function PlayRightHit(pawn Other, float tweentime)
{
	CheckMesh(Other);
	if ( Other.AnimSequence == 'RightHit' )
		Other.TweenAnim('GutHit', tweentime);
	else
		Other.TweenAnim('RightHit', tweentime);
}

static function PlayLanded(pawn Other, float impactVel)
{
	CheckMesh(Other);
	impactVel = impactVel/Other.JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	Other.BaseEyeHeight = Other.Default.BaseEyeHeight;

	if ( Other.Role == ROLE_Authority )
	{
		if ( impactVel > 0.17 )
			Other.PlaySound(WFD_DPMSPlayer(Other).SoundInfo.default.LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
		if ( !Other.FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
			Other.PlaySound(WFD_DPMSPlayer(Other).SoundInfo.default.Land, SLOT_Interact, FClamp(4.5 * impactVel,0.5,6), false, 1000, 1.0);
	}

	if ( (Other.GetAnimGroup(Other.AnimSequence) == 'Dodge') && Other.IsAnimating() )
		return;
	if ( (impactVel > 0.06) || (Other.GetAnimGroup(Other.AnimSequence) == 'Jumping') )
		Other.TweenAnim('Landed', 0.12);
	else if ( !Other.IsAnimating() )
	{
		if ( Other.GetAnimGroup(Other.AnimSequence) == 'TakeHit' )
			Other.AnimEnd();
		else
			Other.TweenAnim('Landed', 0.12);
	}
}

static function PlayInAir(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight =  Other.Default.BaseEyeHeight;
	Other.TweenAnim('RunFire', 0.4);
}

static function PlayDuck(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = 0;
	Other.TweenAnim('DuckWalk', 0.25);
}

static function PlayCrawling(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = 0;
	Other.LoopAnim('DuckWalk');
}

static function TweenToWaiting(pawn Other, float tweentime)
{
	CheckMesh(Other);
	if( Other.IsInState('PlayerSwimming') || Other.Physics==PHYS_Swimming )
	{
		Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
		Other.TweenAnim('Tread', tweentime);
	}
	else
	{
		Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
		Other.TweenAnim('StilFire', tweentime);
	}
}

static function PlayWaiting(pawn Other)
{
	local name newAnim;

	CheckMesh(Other);
	if( Other.IsInState('PlayerSwimming') || (Other.Physics==PHYS_Swimming) )
	{
		Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
		Other.LoopAnim('Tread');
	}
	else
	{
		Other.BaseEyeHeight = Other.Default.BaseEyeHeight;
		if ( (Other.Weapon != None) && Other.Weapon.bPointing )
			Other.TweenAnim('StilFire', 0.3);
		else
		{
			if ( FRand() < 0.2 )
				newAnim = 'Cough';
			else if ( FRand() < 0.3 )
				newAnim = 'Sweat';
			else
				newAnim = 'Breath';

			if ( Other.AnimSequence == newAnim )
				Other.LoopAnim(newAnim, 0.3 + 0.7 * FRand());
			else
				Other.PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
		}
	}
}

static function PlayFiring(pawn Other)
{
	// switch animation sequence mid-stream if needed
	CheckMesh(Other);
	if (Other.AnimSequence == 'Run')
		Other.AnimSequence = 'RunFire';
	else if (Other.AnimSequence == 'Walk')
		Other.AnimSequence = 'WalkFire';
	else if ( (Other.GetAnimGroup(Other.AnimSequence) != 'Attack')
			&& (Other.GetAnimGroup(Other.AnimSequence) != 'MovingAttack')
			&& (Other.GetAnimGroup(Other.AnimSequence) != 'Dodge')
			&& (Other.AnimSequence != 'Swim') )
		Other.TweenAnim('StilFire', 0.02);
}

static function PlayWeaponSwitch(pawn Other, Weapon NewWeapon)
{
}

static function PlaySwimming(pawn Other)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
	Other.LoopAnim('Swim');
}

static function TweenToSwimming(pawn Other, float tweentime)
{
	CheckMesh(Other);
	Other.BaseEyeHeight = 0.7 * Other.Default.BaseEyeHeight;
	Other.TweenAnim('Swim',tweentime);
}

static function SwimAnimUpdate(pawn Other, bool bNotForward)
{
	CheckMesh(Other);
	if ( !PlayerPawn(Other).bAnimTransition && (Other.GetAnimGroup(Other.AnimSequence) != 'Gesture') && (Other.AnimSequence != 'Swim') )
		Other.TweenToSwimming(0.1);
}

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;
	local string MeshName;
	local int i;
	local string TeamColor[4];

	TeamColor[0]="Red";
    TeamColor[1]="Blue";
    TeamColor[2]="Green";
    TeamColor[3]="Yellow";


	//Log("SetMultiSkin(): SkinName: "$SkinName);

	MeshName = SkinActor.GetItemName(string(default.PlayerMesh));

	if( InStr(SkinName, ".") == -1 )
		SkinName = MeshName$"Skins."$SkinName;

	if (TeamNum >=0 && TeamNum <= 3)
		NewSkin = texture(DynamicLoadObject(MeshName$"Skins.T_"$TeamColor[TeamNum], class'Texture'));
	else if( Left(SkinName, Len(MeshName)) ~= MeshName )
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));

	if ( (NewSkin == none) && ((TeamNum >=0 && TeamNum <= 3) || (SkinActor.Skin != none)) )
		NewSkin = texture(DynamicLoadObject(default.DefaultSkinName, class'Texture'));

	// Set skin
	if ( NewSkin != None )
		SkinActor.Skin = NewSkin;

	// clear MultiSkins
	for (i=0; i<5; i++)
		if (SkinActor.MultiSkins[i] != none)
			SkinActor.MultiSkins[i] = none;
}

static function PlayDecap(pawn Other)
{
	local carcass carc;

	if ( Other.Level.NetMode != NM_Client )
	{
		carc = Other.Spawn(class'CreatureChunks',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		if (carc != None)
		{
			carc.Mesh = mesh'NaliHead';
			carc.Initfor(Other);
			carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
		}
	}
}

defaultproperties
{
     CarcassClass=Class'UnrealShare.NaliCarcass'
     DefaultSkinName="UnrealShare.JNali1"
     PlayerMesh=LodMesh'UnrealI.Nali2'
     DefaultSoundClass=class'WFD_NaliPlayerSoundInfo'
     CollisionRadius=24.000000
     CollisionHeight=48.000000
}
