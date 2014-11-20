//=============================================================================
// WFSupplyDepot.
//
// TODO: possibly add an option to gradually increase the amount of ammo in the
//       pack over time.
//=============================================================================
class WFSupplyDepot extends StationaryPawn;

var() float BuildTime;
var() float ChargeTime;

var() class<ammo> AmmoTypes[16];
var() float AmmoAmounts[16];
var() float ResourceAmount;
var() float ArmorAmount;
const MAX_TYPES = 16;

var() bool bGradualCharge;
var() int MinChargeTime; // the minimum charge reached before creating a supply pack

var() texture TeamSkins[4];
var() texture TeamFireTextures[4];

var pawn PlayerOwner;
var byte OwnerTeam;

var WFSupplyDepotBackpack AmmoPack;
var int ChargeTimeLeft;

auto state Building
{
Begin:
	if (BuildTime > 0.0)
	{
		bHidden = true;
		FreezePlayer(PlayerOwner);
		Sleep(BuildTime/2.0);
		bHidden = false;
		Sleep(BuildTime/2.0);
		UnfreezePlayer(PlayerOwner);
	}
	GotoState('Charging');
}

function SetPlayerOwner(pawn NewOwner)
{
	PlayerOwner = NewOwner;
	SetOwner(NewOwner);
}

function FreezePlayer(pawn Other)
{
	if (Other == None)
		return;

	if (Other.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(Other).FreezePlayer(BuildTime, 'BuildingSupplyDepot');
}

function UnfreezePlayer(pawn Other)
{
	if (Other == None)
		return;

	if (Other.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(Other).UnfreezePlayer('BuildingSupplyDepot');
}

function SetTeam(int TeamNum)
{
	OwnerTeam = TeamNum;
	MultiSkins[1] = TeamSkins[OwnerTeam];
	MultiSkins[2] = TeamFireTextures[OwnerTeam];
}

function bool SameTeamAs(int TeamNum)
{
	if (TeamNum == OwnerTeam)
		return true;

	return false;
}

// TODO: damage sound and destroy message for supply depot
function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	local int actualDamage;

	if ( Role < ROLE_Authority )
		return;

	MakeNoise(1.0);
	actualDamage = Level.Game.ReduceDamage(NDamage, DamageType, self, instigatedBy);
	Health -= actualDamage;

	if (Health <= 0)
	{
		PlayExplode();
		Destroy();
	}
}

function Recharge();

state Charging
{
	function BeginState()
	{
		if (bGradualCharge)
		{
			ChargeTimeLeft = ChargeTime;
			SetTimer(1.0, true);
		}
		else
			SetTimer(ChargeTime, false);
	}

	function Timer()
	{
		CreateAmmo();

		if (bGradualCharge) ChargeTimeLeft--;

		if (!bGradualCharge || (ChargeTimeLeft <= 0))
			GotoState('Idle');
	}

	function Recharge()
	{
		if (bGradualCharge)
			ChargeTimeLeft = ChargeTime;
	}
}

// Idle state
state Idle
{
	function Recharge() { GotoState('Charging'); }
}

function CreateAmmo()
{
	if (AmmoPack == None)
	{
		AmmoPack = spawn(class'WFSupplyDepotBackpack',,, Location + vect(0,0,1) * 32.0);
		AmmoPack.OwnerDepot = self;
		SetupAmmoTypes();
	}

	AddAmmoToPack();
	if ( !bGradualCharge || (MinChargeTime <= (ChargeTime - ChargeTimeLeft)) )
		AmmoPack.ShowPack();
}

function SetupAmmoTypes()
{
	local int i;
	for (i=0; i<MAX_TYPES; i++)
		AmmoPack.AmmoTypes[i] = AmmoTypes[i];
}

function AddAmmoToPack()
{
	local int i;

	// add ammo
	for (i=0; i<16; i++)
	{
		if ((AmmoTypes[i] != None) && (AmmoAmounts[i] > 0))
		{
			if (bGradualCharge) AmmoPack.AmmoAmounts[i] += AmmoAmounts[i]/ChargeTime;
			else AmmoPack.AmmoAmounts[i] = AmmoAmounts[i];
		}
	}

	// add armor
	if (ArmorAmount > 0)
	{
		if (bGradualCharge) AmmoPack.ArmorAmount += ArmorAmount/ChargeTime;
		else AmmoPack.ArmorAmount = ArmorAmount;
	}

	// add resources
	if (ResourceAmount > 0)
	{
		if (bGradualCharge) AmmoPack.ResourceAmount += ResourceAmount/ChargeTime;
		else AmmoPack.ResourceAmount = ResourceAmount;
	}
}

function SelfDestruct()
{
	PlayExplode();
	HurtRadius(200, 400, '', 87000, Location);
	Destroy();
}

function PlayExplode()
{
	spawn(class'ut_spriteballexplosion',,, Location + vect(0,0,1) * 16);
}

function Destroyed()
{
	super.Destroyed();
	if (AmmoPack != None) AmmoPack.Destroy();
}

function Carcass SpawnCarcass()
{
	return None;
}

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	return true;
}

defaultproperties
{
     SightRadius=0.000000
     FovAngle=90.000000
     Health=75
     MenuName="Supply Depot"
     NameArticle="a "
     RemoteRole=ROLE_SimulatedProxy
     CollisionRadius=28.000000
     CollisionHeight=5.000000
     bBlockActors=false
     bBlockPlayers=false
     Physics=PHYS_Falling
     //AnimSequence=Flat
     //Mesh=LodMesh'MiniBlob'
     Mesh=LodMesh'WF_Depot'
     //DrawScale=1.575000
     DrawScale=1.0
     BuildTime=1.250000
     ChargeTime=10.000000
     MinChargeTime=2
     TeamSkins(0)=texture'WF_SupplyDepotRed'
     TeamSkins(1)=texture'WF_SupplyDepotBlue'
     TeamSkins(2)=texture'WF_SupplyDepotGreen'
     TeamSkins(3)=texture'WF_SupplyDepotYellow'
     TeamFireTextures(0)=FireTexture'dtop_red'
     TeamFireTextures(1)=FireTexture'UnrealShare.ShaneFX.top3'
     TeamFireTextures(2)=FireTexture'dtop_green'
     TeamFireTextures(3)=FireTexture'dtop_gold'
     AmmoTypes(0)=class'BioAmmo'
     AmmoTypes(1)=class'BladeHopper'
     AmmoTypes(2)=class'BulletBox'
     AmmoTypes(3)=class'FlakAmmo'
     AmmoTypes(4)=class'MiniAmmo'
     AmmoTypes(5)=class'PAmmo'
     AmmoTypes(6)=class'RocketPack'
     AmmoTypes(7)=class'ShockCore'
     AmmoTypes(8)=class'WarheadAmmo'
     AmmoTypes(9)=class'WFASAmmo'
     AmmoTypes(10)=class'WFChainCannonAmmo'
     AmmoAmounts(0)=50
     AmmoAmounts(1)=35
     AmmoAmounts(2)=25
     AmmoAmounts(3)=25
     AmmoAmounts(4)=50
     AmmoAmounts(5)=50
     AmmoAmounts(6)=24
     AmmoAmounts(7)=25
     AmmoAmounts(8)=1
     AmmoAmounts(9)=5
     AmmoAmounts(10)=50
     ResourceAmount=50
     ArmorAmount=100
     AnimSequence=Depot
     //PrePivot=(X=7.0,Y=36.0)
}