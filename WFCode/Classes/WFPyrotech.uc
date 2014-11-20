//=============================================================================
// WFPyrotech.
//=============================================================================
class WFPyrotech extends WFPlayerClassInfo;

var() float FlameRadius;
var() int FlameDamage;
var() name FlameDamageType;
var() float FlameMomentumTransfer;
var() float FlameStatusScale;

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

	Other.HurtRadius(default.FlameDamage, default.FlameRadius, default.FlameDamageType, default.FlameMomentumTransfer, HitLocation);

	foreach Other.VisibleCollidingActors( class'pawn', aPawn, default.FlameRadius, HitLocation )
	{
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn != Other) && (aPawn.Health > 0))
		{
			bGiveStatus = false;

			PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(aPawn));
			bGiveStatus = (PCI == None) || !PCI.static.IsImmuneTo(class'WFStatusOnFire');

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
	ExtendedHUD=class'WFS_CTFHUDInfo'
	DefaultInventory=class'WFPyrotechInv'
	MeshInfo=class'WFD_TMale1MeshInfo'
	AltMeshInfo=class'WFD_TMale1BotMeshInfo'
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
}