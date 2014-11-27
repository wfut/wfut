class WFRocketLauncher extends WFWeapon;

var Actor LockedTarget, NewTarget, OldTarget;
var bool bPendingLock;
var bool bNoHomingRockets;

simulated function PostRender( canvas Canvas )
{
	local float XScale;

	Super.PostRender(Canvas);
	bOwnsCrossHair = bLockedOn;
	if ( bOwnsCrossHair )
	{
		// if locked on, draw special crosshair
		XScale = FMax(1.0, Canvas.ClipX/640.0);
		Canvas.SetPos(0.5 * (Canvas.ClipX - Texture'Crosshair6'.USize * XScale), 0.5 * (Canvas.ClipY - Texture'Crosshair6'.VSize * XScale));
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'Crosshair6', 1.0);
		Canvas.Style = 1;
	}
}

simulated function PlayFiring()
{
	PlayOwnedSound(class'RocketMk2'.Default.SpawnSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire', 0.25, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(class'RocketMk2'.Default.SpawnSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire', 0.25, 0.05);
}


function Fire( float Value )
{
	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('NormalFire');
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		NotifyFired();
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		FireRocket(true);
	}
}

function AltFire( float Value )
{
	local WFSeekingRocket r;

	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		GotoState('AltFiring');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		NotifyFired();
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		FireRocket();
	}
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	TweenAnim('Still', 0.5);
}


// client states
state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

// server states
state NormalFire
{
	function AnimEnd()
	{
		Finish();
	}
}

state AltFiring
{
	function AnimEnd()
	{
		Finish();
	}
}

// ==============================================================================


function Actor CheckTarget()
{
	local Actor ETarget;
	local Vector Start, X,Y,Z;
	local float bestDist, bestAim;
	local Pawn PawnOwner;
	local rotator AimRot;
	local int diff;

	if (bNoHomingRockets)
		return None;

	PawnOwner = Pawn(Owner);
	bPointing = false;
	if ( Owner.IsA('PlayerPawn') )
	{
		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		bestAim = 0.93;
		ETarget = PawnOwner.PickTarget(bestAim, bestDist, X, Start);
	}
	else if ( PawnOwner.Enemy == None )
		return None;
	else if ( Owner.IsA('Bot') && Bot(Owner).bNovice )
		return None;
	else if ( VSize(PawnOwner.Enemy.Location - PawnOwner.Location) < 2000 )
	{
		Start = Owner.Location + CalcDrawOffset() + FireOffset.Z * vect(0,0,1);
		AimRot = rotator(PawnOwner.Enemy.Location - Start);
		diff = abs((AimRot.Yaw & 65535) - (PawnOwner.Rotation.Yaw & 65535));
		if ( (diff > 7200) && (diff < 58335) )
			return None;
		// check if can hold lock
		if ( !bPendingLock ) //not already locked
		{
			AimRot = rotator(PawnOwner.Enemy.Location + (3 - PawnOwner.Skill) * 0.3 * PawnOwner.Enemy.Velocity - Start);
			diff = abs((AimRot.Yaw & 65535) - (PawnOwner.Rotation.Yaw & 65535));
			if ( (diff > 16000) && (diff < 49535) )
				return None;
		}

		// check line of sight
		ETarget = Trace(X,Y, PawnOwner.Enemy.Location, Start, false);
		if ( ETarget != None )
			return None;

		return PawnOwner.Enemy;
	}
	bPointing = (ETarget != None);
	Return ETarget;
}

state Idle
{
	function Timer()
	{
		NewTarget = CheckTarget();
		if ( NewTarget == OldTarget )
		{
			LockedTarget = NewTarget;
			If (LockedTarget != None)
			{
				bLockedOn=True;
				Owner.MakeNoise(Pawn(Owner).SoundDampening);
				Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening);
				if ( (Pawn(LockedTarget) != None) && (FRand() < 0.7) )
					Pawn(LockedTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));
				if ( bPendingLock )
				{
					OldTarget = NewTarget;
					FireRocket(Pawn(Owner).bFire != 0);
					Pawn(Owner).bFire = 0;
					Pawn(Owner).bAltFire = 0;
					return;
				}
			}
		}
		else if( (OldTarget != None) && (NewTarget == None) )
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,Pawn(Owner).SoundDampening);
			bLockedOn = False;
		}
		else
		{
			LockedTarget = None;
			bLockedOn = False;
		}
		OldTarget = NewTarget;
		bPendingLock = false;
	}

Begin:
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	bPointing=False;
	if (AmmoType.AmmoAmount<=0)
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	PlayIdleAnim();
	OldTarget = CheckTarget();
	SetTimer(1.25,True);
	LockedTarget = None;
	bLockedOn = False;
PendingLock:
	if ( bPendingLock )
		bPointing = true;
	if ( TimerRate <= 0 )
		SetTimer(1.0, true);
}


function FireRocket(optional bool bFirePrimary)
{
	local vector FireLocation, StartLoc, X,Y,Z;
	local rotator FireRot, RandRot;
	local rocketmk2 r;
	local UT_SeekingRocket s;
	local pawn BestTarget, PawnOwner;
	local PlayerPawn PlayerOwner;

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
	PawnOwner.PlayRecoil(FiringSpeed);
	PlayerOwner = PlayerPawn(Owner);

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartLoc = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

	AdjustedAim = PawnOwner.AdjustAim(ProjectileSpeed, StartLoc, AimError, True, bWarnTarget);

	if ( PlayerOwner != None )
		AdjustedAim = PawnOwner.ViewRotation;

	Owner.MakeNoise(PawnOwner.SoundDampening);
	if ( LockedTarget != None )
	{
		BestTarget = Pawn(CheckTarget());
		if ( (LockedTarget!=None) && (LockedTarget != BestTarget) )
		{
			LockedTarget = None;
			bLockedOn=False;
		}
	}
	else
		BestTarget = None;
	bPendingLock = false;
	bPointing = true;
	FireRot = AdjustedAim;
	FireLocation = StartLoc;

	if (bFirePrimary)
	{
		if ( LockedTarget != None )
		{
			s = Spawn( class 'ut_SeekingRocket',, '', FireLocation,FireRot);
			s.Seeking = LockedTarget;
		}
		else spawn( ProjectileClass,, '', FireLocation,FireRot);
	}
	else
	{
		if ( LockedTarget != None )
		{
			s = Spawn( class 'WFFastSeekingRocket',, '', FireLocation,FireRot);
			s.Seeking = LockedTarget;
		}
		else spawn( AltProjectileClass,, '', FireLocation,FireRot);
	}
}

defaultproperties
{
     //UT_EightBall properties
     WeaponDescription="Classification: Heavy Ballistic\n\nPrimary Fire: Slow moving but deadly rockets are fired at opponents. Trigger can be held down to load up to six rockets at a time, which can be fired at once.\n\nSecondary Fire: Grenades are lobbed from the barrel. Secondary trigger can be held as well to load up to six grenades.\n\nTechniques: Keeping this weapon pointed at an opponent will cause it to lock on, and while the gun is locked the next rocket fired will be a homing rocket.  Because the Rocket Launcher can load up multiple rockets, it fires when you release the fire button.  If you prefer, it can be configured to fire a rocket as soon as you press fire button down, at the expense of the multiple rocket load-up feature.  This is set in the Input Options menu."
     AmmoName=Class'Botpack.RocketPack'
     PickupAmmoCount=6
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.800000)
     ProjectileClass=Class'WFRocket'
     AltProjectileClass=Class'WFFastRocket'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.750000
     RefireRate=0.250000
     AltRefireRate=0.250000
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     CockingSound=Sound'UnrealShare.Eightball.Loading'
     SelectSound=Sound'UnrealShare.Eightball.Selecting'
     Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
     Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
     Misc3Sound=Sound'UnrealShare.Eightball.BarrelMove'
     DeathMessage="%o was smacked down by %k's %w."
     NameColor=(G=0,B=0)
     //AutoSwitchPriority=9
     //InventoryGroup=9
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the Rocket Launcher."
     ItemName="Rocket Launcher"
     PlayerViewOffset=(X=3.00000,Y=-2.55000,Z=-3.000000)
     PlayerViewMesh=LodMesh'WFMedia.rocketlauncher'
     PlayerViewScale=.2500000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.Eight2Pick'
     ThirdPersonMesh=LodMesh'WFMedia.rlthird'
     ThirdPersonScale=1
     StatusIcon=Texture'WFMedia.WeaponRocketLaucher'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.Use8ball'
     Mesh=LodMesh'Botpack.Eight2Pick'
     bNoSmooth=False
     CollisionHeight=10.000000
     Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
     Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
     bNoHomingRockets=True
}
