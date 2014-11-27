class WFNapalmRL extends WFWeapon;

simulated function PlayFiring()
{
	PlayOwnedSound(class'RocketMk2'.Default.SpawnSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire1', 0.30, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(class'UT_EightBall'.Default.AltFireSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire1', 0.30, 0.05);
}

simulated function PlayReloading()
{
	Owner.PlayOwnedSound(class'UT_EightBall'.Default.CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
	PlayAnim('Load1',, 0.05);
}


// server firing code
state NormalFire
{
	function AnimEnd()
	{
		PlayReloading();
		GotoState('Reloading');
	}
}

state AltFiring
{
	function AnimEnd()
	{
		PlayReloading();
		GotoState('Reloading');
	}
}

state Reloading
{
	function ForceFire() { bForceFire = true; }
	function ForceAltFire() { bForceAltFire = true; }
	function Fire(float F) { }
	function AltFire(float F) { }

	function AnimEnd()
	{
		Finish();
	}
}

// client firing code
state ClientFiring
{
	simulated function AnimEnd()
	{
		PlayReloading();
		GotoState('ClientReloading');
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		PlayReloading();
		GotoState('ClientReloading');
	}
}

state ClientReloading
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

defaultproperties
{
	ProjectileClass=class'WFNapalmRocket'
	AltProjectileClass=class'WFNapalmGrenade'
	WeaponDescription="Classification: Heavy Ballistic\n\nPrimary Fire: Slow moving but deadly rockets are fired at opponents. Trigger can be held down to load up to six rockets at a time, which can be fired at once.\n\nSecondary Fire: Grenades are lobbed from the barrel. Secondary trigger can be held as well to load up to six grenades.\n\nTechniques: Keeping this weapon pointed at an opponent will cause it to lock on, and while the gun is locked the next rocket fired will be a homing rocket.  Because the Rocket Launcher can load up multiple rockets, it fires when you release the fire button.  If you prefer, it can be configured to fire a rocket as soon as you press fire button down, at the expense of the multiple rocket load-up feature.  This is set in the Input Options menu."
	AmmoName=Class'Botpack.RocketPack'
	PickupAmmoCount=6
	bWarnTarget=True
	bAltWarnTarget=True
	bSplashDamage=True
	bRecommendSplashDamage=True
	FiringSpeed=1.000000
	FireOffset=(X=10.000000,Y=-5.000000,Z=-8.800000)
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
	PickupMessage="You got the Napalm Rocket Launcher."
	ItemName="Napalm Rocket Launcher"
	PlayerViewOffset=(X=2.400000,Y=-1.000000,Z=-2.200000)
	PlayerViewMesh=LodMesh'Botpack.Eightm'
	PlayerViewScale=2.000000
	BobDamping=0.975000
	PickupViewMesh=LodMesh'Botpack.Eight2Pick'
	ThirdPersonMesh=LodMesh'Botpack.EightHand'
	StatusIcon=Texture'WFMedia.WeaponNapalmRocketLauncher'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.Use8ball'
	Mesh=LodMesh'Botpack.Eight2Pick'
	bNoSmooth=False
	CollisionHeight=10.000000
}
