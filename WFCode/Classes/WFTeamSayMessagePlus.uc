class WFTeamSayMessagePlus extends TeamSayMessagePlus;

// fixed a text spacing bug with team messages
static function RenderComplexMessage(
	Canvas Canvas,
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return;

	Canvas.DrawColor = Default.GreenColor;
	Canvas.DrawText( RelatedPRI_1.PlayerName$" ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	if ( RelatedPRI_1.PlayerLocation != None )
		LocationName = RelatedPRI_1.PlayerLocation.LocationName;
	else if ( RelatedPRI_1.PlayerZone != None )
		Locationname = RelatedPRI_1.PlayerZone.ZoneName;

	if (LocationName != "")
	{
		Canvas.DrawColor = Default.CyanColor;
		Canvas.DrawText( " ("$LocationName$"): ", False ); // added space after ":"
	}
	else
		Canvas.DrawText( ": ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.DrawColor = Default.LightGreenColor;
	Canvas.DrawText( MessageString, False );
}

defaultproperties
{
}