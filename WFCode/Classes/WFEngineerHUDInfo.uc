//=============================================================================
// WFEngineer.
//=============================================================================
class WFEngineerHUDInfo extends WFHUDInfo;

var() texture CustomIconTexture;

// could make this a general use function and move to WFHUDInfo and WFITSHUDInfo
simulated function DrawStatus(out byte bOverrideFunction, Canvas Canvas)
{
	local bool bHasDoll;
	local float X, Y, StatScale;
	local int IconValue;

	IconValue = GetIconValue();

	if (!OwnerHUD.bHideStatus)
	{
		bHasDoll = !(Canvas.ClipX < 400);
		if (bHasDoll)
			StatScale = OwnerHUD.Scale * OwnerHUD.StatusScale;
	}

	// draw the hud icon
	Canvas.DrawColor = OwnerHUD.HUDColor;
	if ( OwnerHUD.bHideStatus && OwnerHUD.bHideAllWeapons )
	{
		//X = 0.5 * Canvas.ClipX;
		//Y = Canvas.ClipY - 128 * OwnerHUD.Scale;
		X = Canvas.ClipX - 128 * OwnerHUD.Scale;
		Y = 0;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * OwnerHUD.Scale;
		Y = 128 * OwnerHUD.Scale; // Y=0 for armor, Y=64 for health
	}
	Canvas.SetPos(X,Y);
	Canvas.DrawTile(CustomIconTexture, 128*OwnerHUD.Scale, 64*OwnerHUD.Scale, 0, 0, 128.0, 64.0);

	// draw the value for the icon
	Canvas.DrawColor = OwnerHUD.WhiteColor;
	OwnerHUD.DrawBigNum(Canvas, Max(0,IconValue), X + 4 * OwnerHUD.Scale, Y + 16 * OwnerHUD.Scale, 1);
}

function int GetIconValue()
{
	local inventory Inv;

	Inv = OwnerHUD.PawnOwner.FindInventoryType(class'WFEngineerResource');
	if (Inv != None)
		return ammo(Inv).AmmoAmount;

	return -1;
}

defaultproperties
{
	CustomIconTexture=Texture'EngResourceIcon'
}