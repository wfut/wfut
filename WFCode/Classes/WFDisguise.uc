class WFDisguise extends WFPlayerStatus;

var byte DisguiseTeam;
var class<WFS_PlayerClassInfo> DisguisePCI;

var WFS_PCSystemPlayer PlayerOwner;
var WFS_PCSystemBot BotOwner;
var pawn PawnOwner;
var bool bDisguised;

var() float TeamDisguiseTime;

var() float DetectionRate;
var float LastDetectionCheck;

var() bool bUseDetectionChance;
var() float DetectionRange; // dectection range (detection odds increase the closer a player gets)
var() float MinDetectionChance; // the minimum chance of detection (odds at max distance)
var() float MaxDetectionChance; // the maximum chance of detection (odds at min distance)

replication
{
	reliable if (bNetOwner && (Role == ROLE_Authority))
		bDisguised, DisguiseTeam, DisguisePCI;
}

function ServerInitialise()
{
	PlayerOwner = WFS_PCSystemPlayer(Owner);
	PawnOwner = PlayerOwner;
	if (PlayerOwner == none)
	{
		BotOwner = WFS_PCSystemBot(Owner);
		PawnOwner = BotOwner;
	}
}

function ChangeDisguise(byte NewTeam, class<WFS_PlayerClassInfo> NewPCI)
{
	local actor effect;
	local class<actor> EffectClass;
	local bool bChangedClass, bChangedTeam;
	local name TeamName;

	if ((PawnOwner == None) || (PawnOwner.PlayerReplicationInfo.HasFlag != None))
		return;

	if ( (NewTeam == PawnOwner.PlayerReplicationInfo.Team)
			&& (class'WFS_PlayerClassInfo'.static.GetPCIFor(PawnOwner) == NewPCI) )
	{
		RemoveDisguise();
		return;
	}

	//if ((NewTeam != DisguiseTeam) && (TeamDisguiseTime > 0))
	if (NewTeam != DisguiseTeam)
	{
		/*Owner.SetDisplayProperties(ERenderStyle.STY_Translucent,
								   Texture'JDomN0',
								   false,
								   true);*/
		//FreezePlayer();
		//SetTimer(TeamDisguiseTime+0.25, false);
		switch (NewTeam)
		{
			case 0: EffectClass = class'WFDisguiseTeamEffectRed'; break;
			case 1: EffectClass = class'WFDisguiseTeamEffectBlue'; break;
			case 2: EffectClass = class'WFDisguiseTeamEffectGreen'; break;
			case 3: EffectClass = class'WFDisguiseTeamEffectGold'; break;
			default: EffectClass = class'WFDisguiseTeamEffect'; break;
		}
		effect = spawn(EffectClass, Owner,, Owner.Location, Owner.Rotation);
		effect.Mesh = NewPCI.default.MeshInfo.default.PlayerMesh;
		bChangedTeam = true;
	}

	DisguiseTeam = NewTeam;
	if (DisguisePCI != NewPCI)
	{
		bChangedClass = true;
		DisguisePCI = NewPCI;
		class'WFPlayerClassInfo'.static.SetClassName(pawn(Owner), NewPCI.default.ClassName);
	}

	UpdateDPMSInfo();

	if (bChangedClass || bChangedTeam)
	{
		switch(DisguiseTeam)
		{
			case 0: EffectClass = class'WFDisguiseClassEffectRed'; break;
			case 1: EffectClass = class'WFDisguiseClassEffectBlue'; break;
			case 2: EffectClass = class'WFDisguiseClassEffectGreen'; break;
			case 3: EffectClass = class'WFDisguiseClassEffectGold'; break;
			default: EffectClass = class'WFDisguiseClassEffect';
		}
		Spawn(EffectClass, Owner,, Owner.Location, Owner.Rotation);
	}

	if (bChangedClass && pawn(Owner).Weapon.IsA('WFWeapon'))
		WFWeapon(pawn(owner).Weapon).WeaponEvent('DisguiseChanged');

	if (GetStateName() != 'Disguised')
		GotoState('Disguised');
}

function Timer()
{
	//Owner.SetDefaultDisplayProperties();
}

function UpdateDPMSInfo()
{
	local class<WFD_DPMSMeshInfo> MI;

	if (PlayerOwner != None)
	{
		// update the WFD_DPMSMeshInfo
		MI = DisguisePCI.default.MeshInfo;
		PlayerOwner.MeshInfo = DisguisePCI.default.MeshInfo;
		PlayerOwner.Mesh = MI.default.PlayerMesh;
		// update the WFD_DPMSSoundInfo
		if (DisguisePCI.default.SoundInfo != None)
			PlayerOwner.SoundInfo = DisguisePCI.default.SoundInfo;
		else PlayerOwner.SoundInfo = MI.default.DefaultSoundClass;
	}
	else if (BotOwner != None)
	{
	// update the WFD_DPMSMeshInfo
		MI = DisguisePCI.default.AltMeshInfo;
		BotOwner.MeshInfo = DisguisePCI.default.AltMeshInfo;
		BotOwner.Mesh = MI.default.PlayerMesh;
		// update the WFD_DPMSSoundInfo
		if (DisguisePCI.default.SoundInfo != None)
			BotOwner.SoundInfo = DisguisePCI.default.SoundInfo;
		else BotOwner.SoundInfo = MI.default.DefaultSoundClass;
	}

	MI.static.SetMultiSkin(
				pawn(Owner),
				DisguisePCI.default.ClassSkinName,
				DisguisePCI.default.ClassFaceName,
				DisguiseTeam
			);
}

function FreezePlayer()
{
	if (Owner.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(Owner).FreezePlayer(TeamDisguiseTime, 'Disguising');
}

function UnfreezePlayer()
{
	if (Owner.GetStateName() == 'Frozen')
	{
		if (Owner.IsA('WFS_PCSystemPlayer'))
			WFS_PCSystemPlayer(Owner).UnfreezePlayer('Disguising');
	}
}

function RemoveDisguise(optional bool bNoMessage)
{
	if (!bDisguised)
		return;
	MakeNoise(1.0);

	// reset player mesh, etc.
	DisguisePCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(pawn(Owner));
	DisguiseTeam = pawn(Owner).PlayerReplicationInfo.Team;
	class'WFPlayerClassInfo'.static.SetClassName(pawn(Owner), DisguisePCI.default.ClassName);
	UpdateDPMSInfo();

	if (!bNoMessage && (PawnOwner != None))
		PawnOwner.ClientMessage(ExpireMessage, 'CriticalEvent');

	Spawn(class'WFDisguiseClassEffect', Owner,, Owner.Location, Owner.Rotation);
	//Owner.SetDefaultDisplayProperties();

	UnfreezePlayer();

	if (pawn(owner).Weapon.IsA('WFWeapon'))
		WFWeapon(pawn(owner).Weapon).WeaponEvent('DisguiseRemoved');

	GotoState('Idle2');
}

function SetStatusFlag()
{
	if (bDisguised)
		super.SetStatusFlag();
}

function ClearStatusFlag()
{
	if (bDisguised)
		super.ClearStatusFlag();
}

function GiveTo(pawn Other)
{
	super.GiveTo(Other);
	if (Other != none)
	{
		DisguiseTeam = Other.PlayerReplicationInfo.Team;
		DisguisePCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(Other);
		//bDisguised = false;
	}
}

state Disguised
{
	function BeginState()
	{
		bDisguised = true;
		SetStatusFlag();
	}

	simulated function StatusTick(float DeltaTime)
	{
		// remove status if player fires weapon or collects flag
		if (bPreInitialised && (Role == ROLE_Authority))
		{
			if ((PawnOwner != None) && (PawnOwner.PlayerReplicationInfo.HasFlag != None))
				RemoveDisguise();

			if (Owner.GetStateName() != 'Frozen')
			{
				if ((PlayerOwner != None) && !ValidWeaponType(PlayerOwner.Weapon) && (PlayerOwner.bFire!=0 || PlayerOwner.bAltFire!=0))
					RemoveDisguise();
				else if ((BotOwner != None) && !ValidWeaponType(PlayerOwner.Weapon) && (BotOwner.bFire!=0 || BotOwner.bAltFire!=0))
					RemoveDisguise();
			}

			// don't make detection check if cloaked
			if (pawn(Owner).Visibility <= 10)
				return;

			// check to see if player has been detected by an enemy player
			if ((Level.TimeSeconds - LastDetectionCheck) > DetectionRate)
			{
				LastDetectionCheck = Level.TimeSeconds;
				CheckForDetection();
			}
		}
	}

	function WeaponFired(Weapon WeaponUsed) { if (!ValidWeaponType(WeaponUsed)) RemoveDisguise(); }
	function GrenadeThrown(WFGrenadeItem GrenadeUsed) { RemoveDisguise(); }

	function EndState()
	{
		ClearStatusFlag();
		bDisguised = false;
	}
}

function WeaponFired(Weapon WeaponUsed);
function GrenadeThrown(WFGrenadeItem GrenadeUsed);

function Destroyed()
{
	if (bDisguised)
		ClearStatusFlag();
	super.Destroyed();
}

function bool ValidWeaponType(weapon CurrentWeapon)
{
	if ((CurrentWeapon != None)
		&& (CurrentWeapon.IsA('Translocator')
		|| CurrentWeapon.IsA('WFTaser')) )
		return true;

	return false;
}

// check to see if owner was detected by an enemy player
function CheckForDetection()
{
	local pawn p;
	local class<WFS_PlayerClassInfo> OtherPCI, OwnerPCI;
	local bool bDetected;
	local float Dist, DetScale, DetChance;

	OwnerPCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(pawn(Owner));
	foreach VisibleCollidingActors(class'Pawn', p, DetectionRange, Owner.Location, true)
		if ((p != none) && p.bIsPlayer && (p.PlayerReplicationInfo.Team != pawn(Owner).PlayerReplicationInfo.Team))
		{
			OtherPCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(p);
			if (OtherPCI == OwnerPCI)
			{
				bDetected = true; // auto detection
				//Log("-- Auto detected by: "$p$" (PCI: "$OtherPCI.name$")");
			}
			else if (bUseDetectionChance)
			{
				//Log("-- Making detection check for: "$p$" (PCI: "$OtherPCI.name$")");
				Dist = VSize(p.Location - Owner.Location);
				//Log("Dist: "$Dist);
				DetScale = 1 - FMax(0,(Dist - Owner.CollisionRadius)/(DetectionRange - Owner.CollisionRadius));
				//Log("DetScale: "$DetScale);
				DetChance =  MinDetectionChance + ((MaxDetectionChance - MinDetectionChance)*DetScale);
				//Log("DetChance: "$DetChance);
				bDetected = FRand() <= FClamp(DetChance, MinDetectionChance, MaxDetectionChance);
				//Log("bDetected: "$bDetected);
			}

			if (bDetected)
			{
				RemoveDisguise(true);
				if (PawnOwner != None)
					PawnOwner.ClientMessage("You have been detected!", 'CriticalEvent');
				MakeNoise(1.0);
			}
		}
}

static function bool IsDisguised(PlayerReplicationInfo OtherPRI)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;

	if (OtherPRI == None)
		return false;

	WFPRI = WF_PRI(OtherPRI);
	if (WFPRI != None)
		return bool(WFPRI.StatusFlags & WFPRI.PS_Disguised);
	else
	{
		WFBotPRI = WF_BotPRI(OtherPRI);
		if (WFBotPRI != None)
			return bool(WFBotPRI.StatusFlags & WFBotPRI.PS_Disguised);
	}

	return false;
}

defaultproperties
{
	ExpireMessage="Disguise has been removed."
	DisguiseTeam=255
	StatusID=8
	TeamDisguiseTime=5.0
	DetectionRange=150.0
	MinDetectionChance=0.01
	MaxDetectionChance=0.10
	DetectionRate=0.5
	bUseDetectionChance=False
}