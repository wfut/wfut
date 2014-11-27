//=============================================================================
// WFPyrotech.
//=============================================================================
class WFPyrotech extends WFPlayerClassInfo;

var() float FlameRadius;
var() int FlameDamage;
var() name FlameDamageType;
var() float FlameMomentumTransfer;
var() float FlameStatusScale;

static function ModifyPlayer(pawn Other)
{
	local float SpeedScaling;

	if (DeathMatchPlus(Other.Level.Game).bMegaSpeed)
		SpeedScaling = 1.4;
	else SpeedScaling = 1.0;

	Other.GroundSpeed = (Other.default.GroundSpeed * SpeedScaling) * 1.1;
	Other.WaterSpeed = (Other.default.WaterSpeed * SpeedScaling) * 1.1;
	Other.AirSpeed = (Other.default.AirSpeed * SpeedScaling) * 1.1;
	Other.AccelRate = (Other.default.AccelRate * SpeedScaling) * 1.1;
	Other.Mass = Other.default.Mass * 0.9;
}

static function bool IsImmuneTo(class<WFPlayerStatus> StatusClass)
{
	if (StatusClass == class'WFStatusOnFire')
		return true;

	return false;
}

// flaming gib
static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	if ((Killer != None) || (DamageType == 'Fell'))
	{
		Other.spawn(class'UT_SpriteBallExplosion',,,Other.Location);
		Other.spawn(class'WFNapalmExplosion',,,Other.Location);
		BlowUp(Other, Other.Location);
	}
}

static function BlowUp(pawn Other, vector HitLocation)
{
	local pawn aPawn;
	local WFStatusOnFire s;
	local bool bGiveStatus;
	local class<WFPlayerClassInfo> PCI;
	local WFPlayer WFP;

	Other.HurtRadius(default.FlameDamage, default.FlameRadius, default.FlameDamageType, default.FlameMomentumTransfer, HitLocation);

	foreach Other.VisibleCollidingActors( class'pawn', aPawn, default.FlameRadius, HitLocation )
	{
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn != Other) && (aPawn.Health > 0))
		{
			bGiveStatus = false;

			//WFP = WFPlayer(aPawn);
			//PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(aPawn));
			//bGiveStatus = (PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusOnFire');
			bGiveStatus = !class'WFPlayerClassInfo'.static.PawnIsImmuneTo(aPawn, class'WFStatusOnFire');

			if (bGiveStatus && (aPawn.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team))
			{
				s = WFStatusOnFire(aPawn.FindInventoryType(class'WFStatusOnFire'));
				if (s != None)
					s.OnFireTimeCount = 0;
				else
				{
					s = Other.spawn(class'WFStatusOnFire',,,aPawn.Location);
					s.GiveStatusTo(aPawn, Other, default.FlameStatusScale);
				}
			}
		}
	}
}

defaultproperties
{
	ClassName="Pyrotech"
	ClassNamePlural="Pyrotechs"
	Health=100
	Armor=100
	DefaultInventory=class'WFPyrotechInv'
	ClassDescription="WFCode.WFClassHelpPyrotech"
	bNoEnforcer=True
	//bNoTranslocator=True
	FlameDamage=20
	FlameRadius=250
	FlameMomentumTransfer=25000
	FlameDamageType=FlamingGib
	FlameStatusScale=2.0
	ClassSkinName="WFSkins.pyro"
	ClassFaceName="WFSkins.sygot"
	VoiceType="BotPack.VoiceMaleOne"
    MeshInfo=Class'WFCode.WFPyrotechMeshInfo'
    AltMeshInfo=Class'WFCode.WFPyrotechBotMeshInfo'
}
