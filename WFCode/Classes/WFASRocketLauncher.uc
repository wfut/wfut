class WFASRocketLauncher extends WFWeapon;

simulated function PlayFiring()
{
	PlayAnim( 'Fire', 0.255 );
	PlayOwnedSound(FireSound, SLOT_None,4.0*Pawn(Owner).SoundDampening);
}

simulated function PlayAltFiring()
{
	PlayAnim( 'Fire', 0.1275 );
	PlayOwnedSound(FireSound, SLOT_None,4.0*Pawn(Owner).SoundDampening);
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local Pawn P;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) || !P.Enemy.IsA('TeamCannon'))
		return AIRating;

	return 1.0;
}

function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;

	PlayerViewOffset.Y = Default.PlayerViewOffset.Y;
	PlayerViewOffset.X = Default.PlayerViewOffset.X;
	PlayerViewOffset.Z = Default.PlayerViewOffset.Z;

	PlayerViewOffset *= 100; //scale since network passes vector components as ints
}

defaultproperties
{
     //WeaponDescription="Classification: Thermonuclear Device\n\nPrimary Fire: Launches a huge yet slow moving missile that, upon striking a solid surface, will explode and send out a gigantic shock wave, instantly pulverizing anyone or anything within its colossal radius, including yourself.\n\nSecondary Fire: Take control of the missile and fly it anywhere.  You can press the primary fire button to explode the missile early.\n\nTechniques: Remember that while this rocket is being piloted you are a sitting duck.  If an opponent manages to hit your incoming Redeemer missile while it's in the air, the missile will explode harmlessly."
     InstFlash=-0.400000
     InstFog=(X=950.000000,Y=650.000000,Z=290.000000)
     AmmoName=Class'WFASAmmo'
     ReloadCount=1
     PickupAmmoCount=5
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bSpecialIcon=True
     FiringSpeed=1.000000
     FireOffset=(X=18.000000,Z=-10.000000)
     ProjectileClass=Class'WFASHomingRocket'
     AltProjectileClass=Class'WFASRocket'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.200000
     RefireRate=0.250000
     AltRefireRate=0.250000
     FireSound=Sound'Botpack.Redeemer.WarheadShot'
     SelectSound=Sound'Botpack.Redeemer.WarheadPickup'
     DeathMessage="%o was vaporized by %k's %w!!"
     NameColor=(G=128,B=128)
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got the ASRL."
     ItemName="Anti-Sentry Rocket Launcher"
     RespawnTime=60.000000
     //PlayerViewOffset=(X=1.800000,Y=1.000000,Z=-1.890000)
     PlayerViewOffset=(X=2.250000,Y=1.250000,Z=-2.050000)
     PlayerViewMesh=LodMesh'Botpack.WarHead'
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.WHPick'
     ThirdPersonMesh=LodMesh'Botpack.WHHand'
     StatusIcon=Texture'Botpack.Icons.UseWarH'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseWarH'
     Mesh=LodMesh'Botpack.WHPick'
     bNoSmooth=False
     CollisionRadius=45.000000
     CollisionHeight=23.000000
}