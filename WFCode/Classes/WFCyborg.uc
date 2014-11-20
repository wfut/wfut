//=============================================================================
// WFCyborg.
//=============================================================================
class WFCyborg extends WFPlayerClassInfo;

static function ModifyPlayer(pawn Other)
{
	Other.GroundSpeed = Other.default.GroundSpeed * 0.85;
	Other.WaterSpeed = Other.default.WaterSpeed * 0.85;
	Other.AirSpeed = Other.default.AirSpeed * 0.85;
	Other.AccelRate = Other.default.AccelRate * 0.85;
	Other.AirControl = Other.default.AirControl * 0.85;
	Other.Mass = Other.default.Mass * 1.15;
}

static function PlayerTakeDamage(pawn Other, out int Damage, out Pawn instigatedBy,	out vector hitlocation, out vector momentum, out name damageType, out byte bIgnoreDamage)
{
	if (Other.IsInState('Frozen') && (Other.FindInventoryType(class'WFStatusFrozen') == None))
		momentum = vect(0,0,0);

	super.PlayerTakeDamage(Other, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);
}

static function PlayerDied(pawn Other, pawn Killer, name damageType, vector HitLocation)
{
	local WFPlasmaBomb plasma;
	local actor relatedactor;
	local int i;

	// find an active plasma
	for (i=0; i<8; i++)
	{
		relatedactor = GetRelatedActor(Other, i);
		if ((relatedactor != None) && !relatedactor.bDeleteMe
			&& /*relatedactor.IsInState('Arming') &&*/ (plasma == None))
		{
			plasma = WFPlasmaBomb(relatedactor);
			break;
		}
	}

	if (plasma == None)
		return;

	if (Plasma.bArming)
	{
		if (DamageType == 'Suicided')
			plasma.Destroy();
		else if (FRand() < 0.4)
		{
			if (FRand() < 0.5)
				plasma.Destroy();
			else if (FRand() < 0.5)
				plasma.Disrupt();
		}
		if (!plasma.bPlayerDied)
			plasma.bPlayerDied = true;
	}

	// notify plasma that the player died

	/*if (DamageType != 'Suicided')
		plasma.Disrupt();
	else plasma.Destroy();*/
}

static function bool IsClientSideCommand(string SpecialString)
{
	if (SpecialString == "")
		return true;

	return false;
}

static function DoSpecial(pawn Other, string SpecialString, optional name Type)
{
	if ((Other.Role != ROLE_Authority) && (Type != 'ClientSide'))
		return;

	if ((SpecialString == "") && Other.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(Other).ClientDisplayHUDMenu(default.HUDMenu);

	if (InStr(caps(SpecialString), "PLASMA") != -1)
	{
		if (RelatedActorCount(Other, class'WFPlasmaBomb', true) != 0)
		{
			Other.ClientMessage("Plasma already active.", 'CriticalEvent');
			return;
		}

		//if (Other.Base != Other.Level)
		//	return;

		if (Other.IsInState('PlayerSwimming'))
		{
			Other.ClientMessage("Cannot arm plasma while swimming.", 'CriticalEvent');
			return;
		}

		if (Other.FastTrace(Other.Location + vect(0,0,-1)*Other.CollisionHeight*2.0, Other.Location))
		{
			Other.ClientMessage("Cannot arm plasma while falling.", 'CriticalEvent');
			return;
		}
	}

	if (SpecialString ~= "plasma small")
		DropPlasma(Other, 0);
	else if (SpecialString ~= "plasma medium")
		DropPlasma(Other, 1);
	else if (SpecialString ~= "plasma large")
		DropPlasma(Other, 2);

	if (SpecialString ~= "kami")
		ActivateKamikaze(Other);
}

static function ActivateKamiKaze(pawn Other)
{
	local WFStatusKami k;
	if (Other.FindInventoryType(class'WFStatusKami') == None)
	{
		if (IsArmingPlasma(Other))
		{
			Other.ClientMessage("Cannot use Kamikaze when arming plasma.", 'CriticalEvent');
			return;
		}

		k = Other.spawn(class'WFStatusKami',,, Other.Location);
		k.GiveStatusTo(Other, None);
		SendEvent(Other, "kamikaze");
	}
}

static function DropPlasma(pawn Other, int Type)
{
	local class<WFPlasmaBomb> PlasmaClass;
	local WFPlasmaBomb Plasma;
	local string Message;

	if (Other.FindInventoryType(class'WFStatusKami') != None)
	{
		Other.ClientMessage("Cannot arm plasma when Kamikaze active.", 'CriticalEvent');
		return;
	}

	switch (Type)
	{
		case 0:
			PlasmaClass = class'WFPlasmaSmall';
			SendEvent(Other, "s_plasma_arming");
			Message = "Arming Small Plasma.";
			break;
		case 1:
			PlasmaClass = class'WFPlasmaMedium';
			SendEvent(Other, "m_plasma_arming");
			Message = "Arming Medium Plasma.";
			break;
		case 2:
			PlasmaClass = class'WFPlasmaLarge';
			SendEvent(Other, "l_plasma_arming");
			Message = "Arming Large Plasma.";
			break;
	}
	Other.ClientMessage(Message, 'CriticalEvent');
	Plasma = Other.spawn(PlasmaClass, Other,, Other.Location + vect(0,0,16));
	AddRelatedActor(Other, Plasma);
}

static function bool IsArmingPlasma(pawn Other)
{
	local int i;
	local actor RelatedActor;

	for (i=0; i<8; i++)
	{
		RelatedActor = GetRelatedActor(Other, i);
		if ((RelatedActor != None) && RelatedActor.IsA('WFPlasmaBomb') && RelatedActor.IsInState('Arming'))
			return true;
	}

	return false;
}

defaultproperties
{
	ClassName="Cyborg"
	ClassNamePlural="Cyborgs"
	Health=120
	Armor=199
	ArmorAbsorption=75
	DefaultInventory=class'WFCyborgInv'
	MeshInfo=class'WFD_TBossMeshInfo'
	AltMeshInfo=class'WFD_TBossBotMeshInfo'
	ClassDescription="WFCode.WFClassHelpCyborg"
	bNoEnforcer=True
	//bNoTranslocator=True
	TranslocatorAmmoUsed=15
	HUDMenu=class'WFCyborgHUDMenu'
	ClassSkinName="WFSkins.borg"
	ClassFaceName="WFSkins.petey"
	VoiceType="BotPack.VoiceBoss"
}