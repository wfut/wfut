class WFSpawnProtector extends WFPickup;

var WFSpawnProtectorEffect MyEffect;
var float ProtectionTime;

function GiveTo(pawn Other)
{
	super.GiveTo(Other);
	if ((Owner != None) && (Owner == Other))
		InitProtection();
}

function InitProtection()
{
	local byte OwnerTeam;
	if (MyEffect == None)
	{
		OwnerTeam = pawn(Owner).PlayerReplicationInfo.Team;
		if (OwnerTeam == 0)
			MyEffect = spawn(class'WFSpawnProtectorEffectRed', owner,, owner.Location, owner.Rotation);
		else if (OwnerTeam == 1)
			MyEffect = spawn(class'WFSpawnProtectorEffectBlue', owner,, owner.Location, owner.Rotation);
		else if (OwnerTeam == 2)
			MyEffect = spawn(class'WFSpawnProtectorEffectGreen', owner,, owner.Location, owner.Rotation);
		else if (OwnerTeam == 3)
			MyEffect = spawn(class'WFSpawnProtectorEffectGold', owner,, owner.Location, owner.Rotation);

		SetTimer(class'WFGame'.default.SpawnProtectionTime, false);
	}
}

function Destroyed()
{
	if (MyEffect != None)
	{
		MyEffect.Destroy();
		MyEffect = None;
	}
	super.Destroyed();
}

function Timer()
{
	UsedUp();
}

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	if ( (DamageType == 'Fell') || (DamageType == 'Drowned') )
		return Damage;

	return 0; // player is completely invulnerable from damage
}

function WeaponFired(Weapon WeaponUsed)
{
	if (!bDeleteMe)
	{
		SetTimer(0.0, false);
		UsedUp();
	}
}

function GrenadeThrown(WFGrenadeItem GrenadeUsed)
{
	if (!bDeleteMe)
	{
		SetTimer(0.0, false);
		UsedUp();
	}
}

defaultproperties
{
     ProtectionTime=8.000000
     ExpireMessage="Spawn Protection has worn off."
     bDisplayableInv=True
     PickupMessage=""
     PickupViewMesh=LodMesh'Botpack.Armor2M'
     bIsAnArmor=True
     AbsorptionPriority=255
     MaxDesireability=0.000000
     PickupSound=Sound'Botpack.Pickups.ArmorUT'
     Mesh=LodMesh'Botpack.Armor2M'
     AmbientGlow=64
     CollisionHeight=11.000000
}
