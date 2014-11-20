//=============================================================================
// WFD_DPMSBot.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFD_DPMSBot extends Bot;

var class<WFD_BotMeshInfo> MeshInfo;
var class<WFD_DPMSSoundInfo> SoundInfo;

replication
{
	reliable if (Role == ROLE_Authority)
		MeshInfo, SoundInfo;
}

//=============================================================================
// Misc functions.

function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(MeshInfo.default.CarcassClass);
	if ( carc != None )
		carc.Initfor(self);

	return carc;
}

function SpawnGibbedCarcass()
{
	local carcass carc;

	carc = Spawn(MeshInfo.default.CarcassClass);
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
	}
}

//=============================================================================
// Skin functions.

static function GetMultiSkin( Actor SkinActor, out string SkinName, out string FaceName )
{
	local class<WFD_DPMSMeshInfo> MeshInfoClass;

	MeshInfoClass = WFD_DPMSBot(SkinActor).MeshInfo;

	if (MeshInfoClass == none)
		return;

	MeshInfoClass.static.GetMultiSkin(SkinActor, SkinName, FaceName);
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local class<WFD_DPMSMeshInfo> MeshInfoClass;

	MeshInfoClass = WFD_DPMSBot(SkinActor).MeshInfo;

	if (MeshInfoClass == none)
		return;

	MeshInfoClass.static.SetMultiSkin(SkinActor, SkinName, FaceName, TeamNum);
}

//=============================================================================
// Sound Playing Functions (all overridden to use SoundInfo class for sounds)

// Engine.Pawn
event FootZoneChange(ZoneInfo newFootZone)
{
	if (SoundInfo != none)
		SoundInfo.static.FootZoneChange(self, newFootZone);
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	SoundInfo.static.PlayTakeHitSound(self, damage, damageType, Mult);
}

// Botpack.Bot
simulated function PlayFootStep()
{
	SoundInfo.static.PlayFootStep(self);
}

function PlayDyingSound()
{
	SoundInfo.static.PlayDyingSound(self);
}

function Gasp()
{
	SoundInfo.static.Gasp(self);
}

function TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	if ( Region.Zone.bWaterZone || (Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) )
		return;

	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location + 240 * duckDir, Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Location + 240 * duckDir, Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Location) > 150) );
	}
	if ( !bSuccess )
		return;

	if ( HitActor == None )
		HitLocation = Location + 240 * duckDir;

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MaxStepHeight * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return;

	SetFall();
	Velocity = duckDir * 400;
	Velocity.Z = 160;
	PlayDodge(bDuckLeft);
	PlaySound(SoundInfo.default.JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	SetPhysics(PHYS_Falling);
	if ( (Weapon != None) && Weapon.bSplashDamage
		&& ((bFire != 0) || (bAltFire != 0)) && (Enemy != None)
		&& !FastTrace(Enemy.Location, HitLocation)
		&& FastTrace(Enemy.Location, Location) )
	{
		bFire = 0;
		bAltFire = 0;
	}
	GotoState('FallingState','Ducking');
}

state FallingState
{
	function adjustJump()
	{
		local float velZ;
		local vector FullVel;

		velZ = Velocity.Z;
		FullVel = Normal(Velocity) * GroundSpeed;
		Acceleration = vect(0,0,0);
		If (Location.Z > Destination.Z + CollisionHeight + 2 * MaxStepHeight)
		{
			Velocity = FullVel;
			Velocity.Z = velZ;
			Velocity = EAdjustJump();
			Velocity.Z = 0;
			if ( VSize(Velocity) < 0.9 * GroundSpeed )
			{
				Velocity.Z = velZ;
				return;
			}
		}

		PlaySound(default.JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		Velocity = FullVel;
		Velocity.Z = Default.JumpZ + velZ;
		Velocity = EAdjustJump();
	}
}

//=============================================================================
// Animation Playing Functions

function PlayTurning()
{
	MeshInfo.static.PlayTurning(self);
}

function PlayVictoryDance()
{
	MeshInfo.static.PlayVictoryDance(self);
}

function PlayWaving()
{
	MeshInfo.static.PlayWaving(self);
}

function TweenToWalking(float tweentime)
{
	MeshInfo.static.TweenToWalking(self, tweentime);
}

function TweenToRunning(float tweentime)
{
	MeshInfo.static.TweenToRunning(self, tweentime);
}

function PlayWalking()
{
	MeshInfo.static.PlayWalking(self);
}

function PlayRunning()
{
	MeshInfo.static.PlayRunning(self);
}

function PlayRising()
{
	MeshInfo.static.PlayRising(self);
}

function PlayFeignDeath()
{
	MeshInfo.static.PlayFeignDeath(self);
}

function PlayDying(name DamageType, vector HitLoc)
{
	MeshInfo.static.PlayDying(self, DamageType, HitLoc);
}

function PlayGutHit(float tweentime)
{
	MeshInfo.static.PlayGutHit(self, tweentime);
}

function PlayHeadHit(float tweentime)
{
	MeshInfo.static.PlayHeadHit(self, tweentime);
}

function PlayLeftHit(float tweentime)
{
	MeshInfo.static.PlayLeftHit(self, tweentime);
}

function PlayRightHit(float tweentime)
{
	MeshInfo.static.PlayRightHit(self, tweentime);
}

function PlayLanded(float impactVel)
{
	MeshInfo.static.PlayLanded(self, impactVel);
}

function FastInAir()
{
	MeshInfo.static.FastInAir(self);
}

function PlayInAir()
{
	MeshInfo.static.PlayInAir(self);
}

function PlayDodge(bool bDuckLeft)
{
	MeshInfo.static.BotPlayDodge(self, bDuckLeft);
}

function PlayDuck()
{
	MeshInfo.static.PlayDuck(self);
}

function PlayCrawling()
{
	MeshInfo.static.PlayCrawling(self);
}

function TweenToWaiting(float tweentime)
{
	MeshInfo.static.TweenToWaiting(self, tweentime);
}

function TweenToFighter(float tweentime)
{
	MeshInfo.static.TweenToFighter(self, tweentime);
}

function PlayChallenge()
{
	MeshInfo.static.PlayChallenge(self);
}

function PlayLookAround()
{
	MeshInfo.static.PlayLookAround(self);
}

function PlayWaiting()
{
	MeshInfo.static.PlayWaiting(self);
}

function PlayRecoil(float Rate)
{
	MeshInfo.static.PlayRecoil(self, Rate);
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	MeshInfo.static.PlayWeaponSwitch(self, NewWeapon);
}

function PlaySwimming()
{
	MeshInfo.static.PlaySwimming(self);
}

function TweenToSwimming(float tweentime)
{
	MeshInfo.static.TweenToSwimming(self, tweentime);
}

defaultproperties
{
     bIsHuman=True
}