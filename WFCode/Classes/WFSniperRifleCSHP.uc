//=============================================================================
// WFSniperRifle.
//
// CSHP compatible version of the WFSniperRifle.
//=============================================================================
class WFSniperRifleCSHP extends SniperRifle;

var int NumFire;
var name FireAnims[5];
var vector OwnerLocation;
var float StillTime, StillStart;
var float FirstCreated;

var float HeadHeightCoef, HeadAngleDot, SteepAngleDot, SideAngleDot;

var float RDUPierceCoef;

function SetSwitchPriority(pawn Other)
{
	return;
}

simulated function PlayFiring()
{
	local int r;

	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	//PlayAnim(FireAnims[Rand(5)],0.5 + 0.5 * FireAdjust, 0.05);
	PlayAnim(FireAnims[Rand(5)],0.25 + 0.25 * FireAdjust, 0.05);

	if ( (PlayerPawn(Owner) != None)
		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
		bMuzzleFlash++;
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;
	local float speed;

	// should really go in Fire()..
	NotifyFired();

	PawnOwner = Pawn(Owner);

	// less accurate if players speed is greater than 250.0
	//speed = VSize(PawnOwner.Velocity);
	//if (speed > 250.0)
	//	Accuracy = 0.95;

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + PawnOwner.Eyeheight * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000 * X);
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

function NotifyFired()
{
	local inventory Item;

	for (Item = pawn(Owner).Inventory; Item!=None; Item = Item.Inventory)
		if (WFPickup(Item) != None)
			WFPickup(Item).WeaponFired(self);
}

simulated function bool ClientAltFire( float Value )
{
	GotoState('Zooming');
	return true;
}

function AltFire( float Value )
{
	ClientAltFire(Value);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local WFReconDefenseUnit RDU;
	local float HitZ;

	s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 2.0;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}
	if (Other == Level)
		Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( Other.bIsPawn )
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
		// FIXME: add a better headshot check here
		if ( Other.bIsPawn && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
		{
			// 80% - 100% of collision height is a headshot
			// 35% - 80% is a body hit
			// 0% - 35% is a legshot

			// can peirce RDU shield
			RDU = WFReconDefenseUnit(pawn(Other).Weapon);
			if (RDU != None)
				RDU.ShieldPierced(RDUPierceCoef);

			HitZ = HitLocation.Z - Other.Location.Z + Other.CollisionHeight;
			if ( (HitZ >= 0.80 * 2*Other.CollisionHeight) && (VSize(Owner.Velocity) < 250.0) )
			//if (IsHeadShot(pawn(Other), HitLocation, HitNormal, X))
			{
				//Pawn(Owner).ClientMessage("Headshot!", 'CriticalEvent', true);
				Other.TakeDamage(150, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
			}
			else if (HitZ >= 0.35 * 2*Other.CollisionHeight)
				Other.TakeDamage(75, Pawn(Owner), HitLocation, 35000 * X, MyDamageType);
			else
			{
				// legshot
				Other.TakeDamage(25, Pawn(Owner), HitLocation, 35000 * X, MyDamageType);
				/*if ((FRand() < 0.5) && (VSize(Owner.Velocity) < 250.0))*/
					GiveLegshot(pawn(Other));
			}
		}
		else
			Other.TakeDamage(75,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);

		/*if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
			&& (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
			Other.TakeDamage(125, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
		else
			Other.TakeDamage(75,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);*/
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

// Need a reliable headshot check, this only works assuming the head stays roughly at the centre
// of the players collision cylinder, and since most of the time it doesn't this is currently useless
function bool IsHeadShot(pawn Other, vector HitLocation, vector HitNormal, vector ShotDirection)
{
	local vector hitoffset, X, Y, Z, headnormal;
	local float dotproduct;

	if (Other == None)
		return false;

	hitoffset = HitLocation - Other.Location;
	// is shot offset above waist height?
	Log("---");
	Log("IsHeadShot(): HitLocation: "$HitLocation);
	Log("IsHeadShot(): HitNormal: "$HitNormal);
	Log("IsHeadShot(): HitOffset: "$hitoffset);
	if (hitoffset.Z > 0.0)
	{
		// is shot at about head height?
		// head height taken to be above
		if (HitLocation.Z >= (Other.Location.Z + Other.CollisionHeight*HeadHeightCoef))
		{
			GetAxes(Other.ViewRotation, X, Y, Z);
			Log("IsHeadShot(): shot was at head height");
			// check the angle (eg. can't get a headshot by shooting upwards through shoulders)
			if ( (ShotDirection dot Z) < SteepAngleDot ) // shooting upward at steep angle
			{
				// shot was from front or behind within ~75.0 degrees of front/back
				// so likely had clear sight of head for the shot
				Log("IsHeadShot(): steep angled shot ("$hitnormal dot Z$")");
				if ( abs(ShotDirection dot X) < SideAngleDot )
				{
					Log("IsHeadShot(): shot was from side: "$hitnormal dot X);
					return false;
				}
			}
			// head takes up about 1/3 space on shoulders looking downward
			// so shot only valid if not too far to left/right of cylinder
			// compare angle between direction normal from centre of collision
			// cylinder at eyeheight and direction of the hit normal
			// if dotproduct is > 0.5 its a headshot
			Log("IsHeadShot(): unobstructed angle for shot");
			headnormal = normal(HitLocation - Other.Location - vect(0,0,1)*Other.EyeHeight);
			dotproduct = ((-ShotDirection) dot headnormal);
			Log("IsHeadShot(): head angle check: "$dotproduct$"   -ShotDirection: "$-ShotDirection$"   headnormal: "$headnormal);
			if ( dotproduct > HeadAngleDot )
			{
				Log("IsHeadShot(): angle valid for headshot");
				return true;
			}
		}
	}
	Log("IsHeadShot(): not a head shot");

	return false;
}

function GiveLegshot(pawn Other)
{
	local WFPlayerStatus s;
	local class<WFPlayerClassInfo> PCI;
	local bool bGiveStatus;

	if ((Other == None) || (Other.Health <= 0) || ((Other.PlayerReplicationInfo != None)
		&& (Other.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)))
		return;

	PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
	bGiveStatus = !class'WFPlayerClassInfo'.static.PawnIsImmuneTo(Other, class'WFStatusLegDamage');
	if (bGiveStatus)
	{
		s = WFStatusLegDamage(Other.FindInventoryType(class'WFStatusLegDamage'));
		if (s == None)
		{
			s = spawn(class'WFStatusLegDamage',,, Other.Location);
			s.GiveStatusTo(Other, Instigator);
		}
	}
}

///////////////////////////////////////////////////////
state Zooming
{
	simulated function BeginState()
	{
		super.BeginState();
		if (Role == ROLE_Authority)
			Owner.bAlwaysRelevant = true;
	}

	simulated function EndState()
	{
		super.EndState();
		if (Role == ROLE_Authority)
			Owner.bAlwaysRelevant = false;
	}
}

///////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim('Still',1.0, 0.05);
}

function Destroyed()
{
	if ((Owner != None) && (Role == ROLE_Authority))
		Owner.bAlwaysRelevant = false;
	super.Destroyed();
}

defaultproperties
{
     FireAnims(0)=Fire
     FireAnims(1)=Fire2
     FireAnims(2)=Fire3
     FireAnims(3)=Fire4
     FireAnims(4)=Fire5
     HeadHeightCoef=0.600000
     HeadAngleDot=0.500000
     SteepAngleDot=-0.650000
     SideAngleDot=0.250000
     RDUPierceCoef=0.500000
     WeaponDescription="Classification: Long Range Ballistic"
     bCanThrow=False
     AutoSwitchPriority=3
     InventoryGroup=3
     StatusIcon=Texture'WFMedia.WeaponSniperRifle'
}
