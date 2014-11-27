class WFCustomTeamSayMessagePlus extends WFTeamSayMessagePlus;

var() color TeamColor[4];
var() color AltTeamColor[4];
var color WhiteColor;

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
	local color MsgColor, TextColor;
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;
	local string ClassName;
	local float OneXL, OneYL;
	local int X, Y;
	local int MsgClipX, MsgClipY, MsgOriginX, MsgOriginY;

  if (RelatedPRI_1 == None)
	{
    return;
	}

	Canvas.StrLen("0", OneXL, OneYL);

	X = Canvas.CurX;
	Y = Canvas.CurY;

	TextColor = Default.CyanColor;
	MsgColor = Default.WhiteColor;
	WFPRI = WF_PRI( RelatedPRI_1 );
	if( WFPRI != None )
	{
	  TextColor = Default.TeamColor[ WFPRI.Team ];
	  MsgColor = Default.TeamColor[ WFPRI.Team ];
		ClassName = WFPRI.ClassName;
	}
	else
	{
	  WFBotPRI = WF_BotPRI( RelatedPRI_1 );
		if( WFBotPRI != None )
		{
	    TextColor = Default.TeamColor[ WFBotPRI.Team ];
			MsgColor = Default.TeamColor[ WFBotPRI.Team ];
		  ClassName = WFBotPRI.ClassName;
		}
	}

  Canvas.DrawColor = TextColor;
	Canvas.Style = ERenderStyle.STY_Translucent;

  Canvas.SetPos( X, Y + 1 );
  Canvas.DrawTile( texture'MsgBall', OneYL , OneYL, 0, 0, 8.0, 8.0);

  Canvas.SetPos( X, Y );
  Canvas.DrawTile( texture'MsgBack', Canvas.ClipX - 32, OneYL+2, 0, 0, 8.0, 8.0);
  Canvas.DrawTile( texture'MsgBackEnd', 32, OneYL+2, 0, 0, 32.0, 8.0);

  Canvas.SetPos( X + OneYL + OneYL, Y+1 );
	Canvas.Style = ERenderStyle.STY_Normal;

	Canvas.DrawColor = Default.WhiteColor;
  Canvas.DrawText( RelatedPRI_1.PlayerName, False );

	Canvas.CurY = Y;
	Canvas.DrawColor = Default.WhiteColor;
  Canvas.DrawText( " - ", False );

	Canvas.CurY = Y;
	Canvas.DrawColor = Default.WhiteColor;
  Canvas.DrawText( ClassName, False );

  if ( RelatedPRI_1.PlayerLocation != None )
	{
    LocationName = RelatedPRI_1.PlayerLocation.LocationName;
	}
  else if ( RelatedPRI_1.PlayerZone != None )
	{
    Locationname = RelatedPRI_1.PlayerZone.ZoneName;
	}
  if (LocationName != "")
  {
	  Canvas.CurY = Y;
	  Canvas.DrawColor = Default.WhiteColor;
    Canvas.DrawText( " - ", False );

	  Canvas.CurY = Y;
	  Canvas.DrawColor = Default.WhiteColor;
    Canvas.DrawText( LocationName, False );
  }
  Canvas.DrawColor = MsgColor;

	MsgOriginX = OneXL * 5;
	MsgOriginY =  Y + OneYL + 2;
	MsgClipX = XL;
	MsgClipY = YL;

  Canvas.SetOrigin( MsgOriginX, MsgOriginY );
	Canvas.SetClip( MsgClipX, MsgClipY );
  Canvas.SetPos( 0, 0 );
	
  Canvas.DrawText( MessageString );
}

static function string AssembleString(
  HUD myHUD,
  optional int Switch,
  optional PlayerReplicationInfo RelatedPRI_1,
  optional String MessageString )
{
	return MessageString;
}

defaultproperties
{
     TeamColor(0)=(R=255)
     TeamColor(1)=(G=128,B=255)
     TeamColor(2)=(G=255)
     TeamColor(3)=(R=255,G=255)
     AltTeamColor(0)=(R=200)
     AltTeamColor(1)=(G=94,B=187)
     AltTeamColor(2)=(G=128)
     AltTeamColor(3)=(R=255,G=255,B=128)
     WhiteColor=(R=255,G=255,B=255)
}
