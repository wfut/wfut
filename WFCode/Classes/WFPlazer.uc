//=============================================================================
// WFPlazer.
// Plasma Lazer Cannon. Written by Yoda.
// Rescripted by Ob1.
//=============================================================================
class WFPlazer expands WFWeapon;

var projectile ProjA;    // Var for primary fire projectiles
var float Angle, Count;  //
var int Zoff;            // Additional Fire offset for projetiles.
var bool bDown;

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
		GotoState ('NormalFire');
		bPointing=True;
		bCanClientFire = true;
		ClientFire( value );
	}
}

function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.AmmoAmount > 1)
	{
		GotoState ('AltFireSwitchDown');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire( value );
	}
}

simulated function PlayFiring()
{
	PlayAnim('Fire', 1.8, 0.0 );
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(sound'PLazer_AltFire01');
	PlayAnim('altfire', 1.25, 0.0 );
}

// mesh notify events
simulated function TopBarrel();
simulated function BottomBarrel();

////////////////////////////////////////////////////////
state NormalFire
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Vector Start, X,Y,Z;
		local int Yoffs;

		Yoffs = FireOffSet.Y;
		FireOffSet.Y = FireOffSet.Y + 10;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	        AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		Start.Z = Start.Z + Zoff;
		FireOffSet.Y = Yoffs;
		return Spawn(ProjClass,,, Start,AdjustedAim);
	}

	function TopBarrel()
	{
		PlayOwnedSound(sound'PLazer_Fire01');
		Zoff = 3;
		ProjA = ProjectileFire( ProjectileClass, 50, True );
	}

	function BottomBarrel()
	{
		PlayOwnedSound(sound'PLazer_Fire01');
		Zoff = -10; // This time fire a bit more down, (other muzzle)
		ProjA = ProjectileFire( ProjectileClass, 50, True );
	}

	function AnimEnd()
	{
		Finish();
	}
}

state ClientFiring
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function TopBarrel()
	{
		PlayOwnedSound(sound'PLazer_Fire01');
	}

	simulated function BottomBarrel()
	{
		PlayOwnedSound(sound'PLazer_Fire01');
	}
}


////////////////////////////////////////////////////////
state AltFiring
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function BeginState()
	{
		if (AmmoType.UseAmmo(2))
		{
			ProjA = ProjectileFire(class'WFPLazerAltBlast',50,True);
			PlayAltFiring();
		}
		else
			GotoState('AltFireSwitchUp');
	}

	function Projectile ProjectileAltFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Vector Start, X,Y,Z;
		local int Yoffs;

		Yoffs = FireOffSet.Y;
		FireOffSet.Y += 15;
		FireOffSet.X += 5;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	        AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		Start.Z = Start.Z + Zoff;
		FireOffSet.Y = Yoffs;

		return Spawn(ProjClass,,, Start,AdjustedAim);
	}

	function AnimEnd()
	{
		if (AmmoType.UseAmmo(2))
		{
			if ( Pawn(Owner).bAltFire == 0 )
				GotoState('AltFireSwitchUp');
			else
			{
				ProjA = ProjectileFire(class'WFPLazerAltBlast',50,True);
				PlayAltFiring();
			}
		}
		else
			GotoState('AltFireSwitchUp');
	}
}

simulated function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 1)) )
	{
		if ( (PlayerPawn(Owner) != None)
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();
		if ( Role < ROLE_Authority )
			GotoState('ClientAltFireSwitchDown');
		return true;
	}
	return false;
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function BeginState()
	{
		PlayAltFiring();
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 1)) )
		{
			GotoState('ClientAltFireSwitchUp');
		}
		else if ( !bCanClientFire )
			GotoState('ClientAltFireSwitchUp');
		else if ( Pawn(Owner).bAltFire != 0 )
			PlayAltFiring();
		else
			GotoState('ClientAltFireSwitchUp');
	}
}

function Finish()
{
	local Pawn PawnOwner;
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( !WeaponActive() || ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ((PawnOwner.bFire!=0) || bForce)
		Global.Fire(0);
	else if ( ((PawnOwner.bAltFire!=0) || bForceAlt) && (AmmoType.AmmoAmount > 1))
		Global.AltFire(0);
	else
		GotoState('Idle');
}

////////////////////////////////////////////////////////
state AltFireSwitchUp
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function BeginState()
	{
		PlaySwitchUp();
	}

	function AnimEnd()
	{
		Finish();
	}
}

state ClientAltFireSwitchUp
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}
	simulated function BeginState()
	{
		PlaySwitchUp();
	}
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

simulated function PlaySwitchUp()
{
	PlayAnim('TurnBack',2.0,0.0);
}

////////////////////////////////////////////////////////
state AltFireSwitchDown
{
	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function BeginState()
	{
		PlaySwitchDown();
	}

	function AnimEnd()
	{
		GotoState('AltFiring');
	}
}

state ClientAltFireSwitchDown
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}
	simulated function BeginState()
	{
		PlaySwitchDown();
	}

	simulated function AnimEnd()
	{
		GotoState('ClientAltFiring');
	}
}

simulated function PlaySwitchDown()
{
	PlayAnim('Turn', 2.0, 0.0);
}

////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	LoopAnim('Idle', 1.0);
}

simulated function TweenToStill()
{
	TweenAnim('Idle', 0.1);
}

defaultproperties
{
     PickupAmmoCount=25
     bRapidFire=True
     ProjectileClass=Class'WFPLazerBlast'
     AltProjectileClass=Class'Botpack.ShockProj'
     AltFireSound=Sound'UnrealShare.ASMD.TazerAltFire'
     NameColor=(R=0)
     AIRating=0.650000
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the Plasma Lazer Cannon."
     ItemName="Lazer"
     //PlayerViewOffset=(X=10.000000,Y=-7.000000,Z=-8.000000)
     PlayerViewOffset=(X=2.900000,Y=-2.000000,Z=-2.200000)
     PlayerViewMesh=LodMesh'WFPlazer'
     //PlayerViewScale=0.350000
     PlayerViewScale=0.1
     PickupViewMesh=LodMesh'WFPlazer'
     PickupViewScale=0.500000
     ThirdPersonMesh=LodMesh'WFPlazer'
     ThirdPersonScale=0.500000
     StatusIcon=Texture'IconLazer'
     Icon=Texture'UseLazer'
     Mesh=LodMesh'WFPlazer'
     bNoSmooth=False
     CollisionHeight=15.000000
     AmmoName=Class'PAmmo'
}
