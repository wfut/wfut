//=============================================================================
// WFAutoCannon.
//=============================================================================
class WFAutoCannon extends WFS_PCSystemAutoCannon;

function PlayActivate()
{
	PlayAnim(AnimSequence, 2.0);
	PlaySound(ActivateSound, SLOT_None, 2.0);
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	NDamage *= 0.75; // reduce damage from any source
	if (DamageType == 'OnFireStatus')
		NDamage *= 0.5;
	if (DamageType == 'Corroded')
		NDamage *= 0.2;
	super.TakeDamage(NDamage, instigatedBy, hitlocation, momentum, damageType);
}

function bool IsValidTarget(actor Other)
{
	local pawn P;
	if ((Other != None) && (Other.IsA('Pawn')))
	{
		P = pawn(Other);
		if (P.IsInState('Waiting') || P.IsInState('PCSpectating') || P.IsInState('RefereeMode')
			|| (P.Health <= 0) || P.bHidden || !IsVisibleTarget(P)
			|| (P.Mesh == none) || !P.bCollideActors)
				return false;

        if ( ((P.PlayerReplicationInfo != none) && (SameTeamAs(P.PlayerReplicationInfo.Team))
        	|| ( !class'WFCloaker'.static.IsHalfCloaked(P) && (class'WFDisguise'.static.IsDisguised(P.PlayerReplicationInfo))
        		|| TargetIsCloaked(P)) ) )
				return false;

		if (Other.IsA('WFS_PCSystemAutoCannon') && SameTeamAs(WFS_PCSystemAutoCannon(Other).MyTeam))
			return false;
	}

	if (Other == self)
	{
		Log(self.name$".IsValidTarget(): New target was self!!");
		return false;
	}

	return true;
}

// returns true if player is cloaked
function bool TargetIsCloaked(pawn Other)
{
	return (Other.bMeshEnviroMap && (Other.Texture == FireTexture'Unrealshare.Belt_fx.Invis'));
}

state DisabledState
{
ignores SeePlayer, EnemyNotVisible, IncreaseTechLevel, DecreaseTechLevel;

	function BeginState()
	{
		Timer();
	}

	function DisableCannon(float Delay)
	{
		DisableTime = Delay;
		GotoState('DisabledState', 'Disabled');
	}

	function Timer()
	{
		local effects e;
		if (!IsAnimating())
		{
			e = spawn(class'WFDisruptEffect', self);
			if (e != None)
			{
				e.Mesh = Mesh;
				e.PrePivot = PrePivot;
			}
		}
		e = spawn(class'WFDisruptEffect', GunBase);
		if (e != None) e.Mesh = GunBase.Mesh;
		SetTimer(1.0 + FRand()*2.5, false);
	}

	function EndState()
	{
		SetTimer(0.0, false);
	}

Begin:
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
Disabled:
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	if (DisableTime > 0.0)
		Sleep(DisableTime);
	GotoState(NextState);
}

defaultproperties
{
	MaxHealth(0)=220
	MaxHealth(1)=270
	MaxHealth(2)=325
	MaxTechLevel=3
	BuildTime=2.500000
	RemoveTime=2.500000
	TechLevelDelay=2.500000
	FovAngle=180.000000
	WeaponInfo=class'WFWeaponInfo'
	HUDMenuClass=class'WFCannonHUDMenu'
	bUseTeamSkins=true
	GunBaseClass=class'WFGrBase'
	FovAngle=220.000000
	bAlwaysRelevant=True
}
