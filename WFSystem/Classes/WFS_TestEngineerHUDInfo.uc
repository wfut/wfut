//=============================================================================
// WFS_TestEngineerHUDInfo.
//=============================================================================
class WFS_TestEngineerHUDInfo extends WFS_ITSHUDInfo;

var WFS_PCSystemAutoCannon IdentifySentry;

simulated function bool TraceIdentify(out byte bDisableFunction, canvas Canvas)
{
/*	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	bDisableFunction = 1;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * 1000.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( Pawn(Other) != None )
	{
		if ( Pawn(Other).bIsPlayer && !Other.bHidden )
		{
			IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
			IdentifyFadeTime = 3.0;
		}

		if (Other.IsA('WFS_PCSystemAutoCannon'))
		{
			IdentifySentry = WFS_PCSystemAutoCannon(Other);
			IdentifyFadeTime = 3.0;
		}
	}
	else if ( (Other != None) && SpecialIdentify(Canvas, Other) )
		return false;

	if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || IdentifyTarget.bFeigningDeath )
		return false;

	return true;*/
}

simulated function bool DrawIdentifyInfo(out byte bDisablefunction, canvas Canvas)
{
	super.DrawIdentifyInfo(bDisablefunction, Canvas);
/*	local float XL, YL, XOffset, X1;
	local Pawn P;

	bDisableFunction = 1;

	if ( !OwnerHUD.TraceIdentify(Canvas))
		return false;

	if( OwnerHUD.IdentifyTarget.PlayerName != "" )
	{
		Canvas.Font = OwnerHUD.MyFonts.GetBigFont(Canvas.ClipX);
		OwnerHUD.DrawTwoColorID(Canvas,OwnerHUD.IdentifyName, OwnerHUD.IdentifyTarget.PlayerName, Canvas.ClipY - 256 * OwnerHUD.Scale);
	}

	Canvas.StrLen("TEST", XL, YL);
	if( OwnerHUD.PawnOwner.PlayerReplicationInfo.Team == OwnerHUD.IdentifyTarget.Team )
	{
		P = Pawn(OwnerHUD.IdentifyTarget.Owner);
		Canvas.Font = OwnerHUD.MyFonts.GetSmallFont(Canvas.ClipX);
		if ( P != None )
			OwnerHUD.DrawTwoColorID(Canvas,OwnerHUD.IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * OwnerHUD.Scale) + 1.5 * YL);
	}
	return true;*/
}

defaultproperties
{
}