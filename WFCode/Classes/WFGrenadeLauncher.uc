//============================================================
// WFGrenadeLauncher.
//
// Primary -- Shoot grenade.
// Secondary -- Shoot grenade with increased speed and distance.
//============================================================
class WFGrenadeLauncher extends WFWeapon;

// animation
simulated function PlayFiring()
{
	PlayOwnedSound(class'UT_EightBall'.Default.AltFireSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire1', 0.45, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(class'UT_EightBall'.Default.AltFireSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire1', 0.30, 0.05);
}

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if (AnimSequence == 'Load1')
		PlayAnim('Idle', 0.1, 0.0);
	else
		TweenAnim('Idle', 0.5);
}

simulated function PlayLoading()
{
	if ( Owner == None )
		return;
	Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
	PlayAnim('Load1',, 0.05);
}

// client states
state ClientFiring
{
	simulated function AnimEnd()
	{
		PlayLoading();
		GotoState('ClientReload');
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		PlayLoading();
		GotoState('ClientReload');
	}
}

state ClientReload
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
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

// server states
state NormalFire
{
	function AnimEnd()
	{
		PlayLoading();
		GotoState('Reload');
	}
}

state AltFiring
{
	function AnimEnd()
	{
		PlayLoading();
		GotoState('Reload');
	}
}

state Reload
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function bool SplashJump()
	{
		return false;
	}

	function AnimEnd()
	{
		Finish();
	}
Begin:
}

defaultproperties
{
     WeaponDescription="Classification: Heavy Ballistic"
     AmmoName=Class'Botpack.RocketPack'
     PickupAmmoCount=6
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=30.000000,Y=-5.000000,Z=-12.0)
     ProjectileClass=Class'WFGrenade'
     //AltProjectileClass=Class'WFFastGrenade'
     AltProjectileClass=Class'WFMortarGrenade'
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
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the Grenade Launcher."
     ItemName="Grenade Launcher"
     PlayerViewOffset=(X=2.500000,Y=-1.300000,Z=-2.00000 Yaw=-32)
     PlayerViewMesh=LodMesh'WFMedia.gl'
     PlayerViewScale=.15
     BobDamping=0.975000
     PickupViewMesh=LodMesh'WFMedia.grenpick'
     ThirdPersonMesh=LodMesh'WFMedia.grenthird'
     ThirdPersonScale=.75
     StatusIcon=Texture'Botpack.Icons.Use8ball'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.Use8ball'
     Mesh=LodMesh'WFMedia.grenpick'
     bNoSmooth=False
     CollisionHeight=10.000000
}
