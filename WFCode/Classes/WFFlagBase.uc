//=============================================================================
// WFFlagBase.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// Used to return a flag being carried by a player for the FRS_CarryReturn
// flag return style.
//=============================================================================
class WFFlagBase extends FlagBase;

var() bool bCapFlag; // base can cap a flag when flag not home

var WFMarker BaseMarker;
var WFFlag HomeFlag;

function PostBeginPlay()
{
	LoopAnim('newflag');
}

function Touch(actor Other)
{
	local Pawn aPawn;
	local CTFFlag aFlag;

	if (WFGame(Level.Game).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn)
	{
		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0)
			&& !aPawn.IsInState('FeigningDeath') )
		{
			aFlag = CTFFlag(aPawn.PlayerReplicationInfo.HasFlag);
			if ((aPawn.PlayerReplicationInfo.Team == Team)
				&& (aFlag != None) && (aFlag.Team == Team))
			{
				// the flag was returned by a player
				CTFGame(Level.Game).ScoreFlag(aPawn, aFlag);
				aFlag.SendHome();
			}
		}
	}

	if (bCapFlag && !HomeFlag.bHome && (HomeFlag.CapturePoint == None))
	{
		aPawn = Pawn(Other);
		if ( (aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0)
			&& !aPawn.IsInState('FeigningDeath') )
		{
			aFlag = CTFFlag(aPawn.PlayerReplicationInfo.HasFlag);
			if ((aPawn.PlayerReplicationInfo.Team == Team)
				&& (aFlag != None) && (aFlag.Team != Team))
			{
				// the flag was returned by a player
				CTFGame(Level.Game).ScoreFlag(aPawn, aFlag);
				aFlag.SendHome();
			}
		}
	}
}

defaultproperties
{
     TakenSound=Sound'Botpack.CTF.flagtaken'
     bHidden=False
     //bHidden=True
     bStatic=False
     bNoDelete=False
     bAlwaysRelevant=True
     DrawType=DT_Mesh
     Skin=Texture'Botpack.Skins.JpflagB'
     Mesh=LodMesh'Botpack.newflag'
     DrawScale=1.300000
     SoundRadius=255
     SoundVolume=255
     CollisionRadius=48.000000
     CollisionHeight=30.000000
     bCollideActors=True
}
