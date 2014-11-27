//=============================================================================
// WFHUDInfo.
//=============================================================================
class WFCustomHUDInfo extends WFHUDInfo;

//var WFCustomHUD     OwnerHUD;   // hud owner

var CTFFlag MyFlag;
var color WhiteColor, DigitBackground, RedColor, BlueColor;
var float IconBlink;
var float LastLog;

function OwnerHUDTimer(out byte bDisableFunction)
{
	Super.OwnerHUDTimer(bDisableFunction);

	if ( (OwnerHUD == None) || (OwnerHUD.PlayerOwner == None) || (OwnerHUD.PawnOwner == None) )
		return;
	if ((OwnerHUD.PawnOwner != None) && (OwnerHUD.PawnOwner.PlayerReplicationInfo.HasFlag != None))
		OwnerHUD.PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 0 );
	if ( (MyFlag != None) && !MyFlag.bHome && !WFFlag(MyFlag).bReturning)
		OwnerHUD.PlayerOwner.ReceiveLocalizedMessage( class'CTFMessage2', 1 );
}

function string TwoDigitString(int Num)
{
  if ( Num < 10 )
    return "0"$Num;
  else
    return string(Num);
}

simulated function Tick(float DeltaTime)
{
  local int i;

  Super.Tick(DeltaTime);

	IconBlink += DeltaTime;
	if ( IconBlink >= 0.5)
  {
	  IconBlink = 0.0;
	}
}

// TODO:
//    - replicated the flag return rules somehow
simulated function DrawScore( canvas Canvas )
{
	local WFCustomHUD MyOwnerHUD;
	local WF_PRI MyWF_PRI;
  local int index, Frags;
	local float XL, YL;
	local float TextLength;
  local float MyTop, MyLeft, MyLength, MyHeight;
  local int Scale16, Scale32, Scale48, Scale64;
  local TournamentGameReplicationInfo TGRI;
  local int Minutes, Seconds;
  local float H1, H2;
  local bool bOldSmooth;

	MyOwnerHUD = WFCustomHUD( OwnerHUD );
	if (myOwnerHUD == None)
		return; // no point going any further if this is none..

  Scale16 = 16 * MyOwnerHUD.MyHUDScale + 0.5;
  Scale32 = Scale16 + Scale16;
  Scale48 = Scale32 + Scale16;
  Scale64 = Scale32 + Scale32;

	if( !OwnerHUD.bHideHUD && !OwnerHUD.bHideFrags )
	{
  	if ( MyOwnerHUD.PawnOwner.PlayerReplicationInfo == None )
    {
      return;
    }
    MyWF_PRI = WF_PRI(MyOwnerHUD.PawnOwner.PlayerReplicationInfo);

      TGRI = TournamentGameReplicationInfo( OwnerHUD.PlayerOwner.GameReplicationInfo);

    index = 5;
    if( (WFGameGRI(TGRI) != None) && (WFGameGRI(TGRI).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn))
    {
      index = 6;
    }

    Canvas.Font = OwnerHUD.MyFonts.GetSmallFont( 640 * MyOwnerHUD.MyHUDScale );
    Canvas.StrLen("0", XL, YL);
    TextLength = 16 * XL;
    Canvas.StrLen("000", XL, YL);
	  Canvas.DrawColor = MyOwnerHUD.BaseColor;

    MyLeft = Canvas.ClipX - ( TextLength + Scale32 );
    if( MyOwnerHUD.PlayerOwner.bBadConnectionAlert &&
        ( MyOwnerHUD.PlayerOwner.Level.TimeSeconds > 5) )
    {
      MyTop = Canvas.ClipY - ( YL * index ) - Scale64;
    }
    else
    {
      MyTop = Canvas.ClipY - ( YL * index ) - Scale16;
    }


    if( MyOwnerHUD.bShowClock )
    {
      if( ( TGRI != None ) &&
          ( TGRI.TimeLimit > 0 ) )
      {
        Canvas.Font = OwnerHUD.MyFonts.GetHugeFont( 0.75 * Canvas.ClipX * MyOwnerHUD.MyHUDScale);
        Canvas.SetPos( MyLeft, MyTop - Scale48 );
			  MyOwnerHUD.DrawPanel( Canvas,
				                    MyOwnerHUD.EPanel.PLeft,
                            ERenderStyle.STY_Modulated, 32, 32, WhiteColor,
							          		MyOwnerHUD.MyOpacity,
									          MyOwnerHUD.MyHUDScale );
			  MyOwnerHUD.DrawPanel( Canvas,
				                    MyOwnerHUD.EPanel.PMiddle,
                            ERenderStyle.STY_Modulated,
                            ( Canvas.ClipX - Canvas.CurX ) / MyOwnerHUD.MyHUDScale + 0.5,
                            32, WhiteColor,
							          		MyOwnerHUD.MyOpacity,
									          MyOwnerHUD.MyHUDScale );
        if ( OwnerHUD.PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
        {
          Canvas.StrLen( "TL : SDOT!", XL, YL );
          Canvas.SetPos( Canvas.ClipX - XL, MyTop - Scale32 - (YL/2) );
          Canvas.DrawColor = OwnerHUD.BaseColor;
          Canvas.DrawText( "TL : ", false );
          Canvas.SetPos( Canvas.CurX, MyTop - Scale32 - (YL/2) );
          H1 = 1.5 * IconBlink;
          H2 = 1 - H1;
          Canvas.DrawColor = OwnerHUD.BaseColor * H2 +
                      ( OwnerHUD.HUDColor - WhiteColor ) * H1;
          Canvas.DrawText( "SDOT!" );
        }
        else
        {
          Minutes = OwnerHUD.PlayerOwner.GameReplicationInfo.RemainingTime/60;
          Seconds = OwnerHUD.PlayerOwner.GameReplicationInfo.RemainingTime % 60;
          Canvas.StrLen( "TL : "$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), XL, YL );
          Canvas.SetPos( Canvas.ClipX - XL, MyTop - Scale32 - (YL/2) );
          Canvas.DrawColor = OwnerHUD.BaseColor;
          Canvas.DrawText( "TL : ", false );
          Canvas.SetPos( Canvas.CurX, MyTop - Scale32 - (YL/2) );

          if( Minutes < 1 )
          {
            H1 = 1.5 * IconBlink;
            H2 = 1 - H1;
            Canvas.DrawColor = OwnerHUD.BaseColor * H2 +
                      ( OwnerHUD.HUDColor - WhiteColor ) * H1;

          }
          else
          {
            Canvas.DrawColor = OwnerHUD.BaseColor;
          }
          Canvas.DrawText( TwoDigitString(Minutes)$":"$TwoDigitString(Seconds) );
        }
      }
    }



    Canvas.Font = OwnerHUD.MyFonts.GetSmallFont( 640 * MyOwnerHUD.MyHUDScale );
    Canvas.StrLen("000", XL, YL);

    Canvas.SetPos( MyLeft, MyTop );
	  MyOwnerHUD.DrawPanel( Canvas,
			                    MyOwnerHUD.EPanel.TopLeft,
                          ERenderStyle.STY_Modulated, 32, 32, WhiteColor,
  					          		MyOwnerHUD.MyOpacity,
								          MyOwnerHUD.MyHUDScale,
                          True );
	  MyOwnerHUD.DrawPanel( Canvas,
			                    MyOwnerHUD.EPanel.Top,
                          ERenderStyle.STY_Modulated,
                          Canvas.ClipX - Canvas.CurX, 32,
                          WhiteColor,
  					          		MyOwnerHUD.MyOpacity,
								          MyOwnerHUD.MyHUDScale,
                          True );
    Canvas.SetPos( MyLeft, MyTop + 32 );
	  MyOwnerHUD.DrawPanel( Canvas,
			                    MyOwnerHUD.EPanel.Left,
                          ERenderStyle.STY_Modulated, 32,
                          Canvas.ClipY - Canvas.CurY,
                          WhiteColor,
  					          		MyOwnerHUD.MyOpacity,
								          MyOwnerHUD.MyHUDScale,
                          True );
	  MyOwnerHUD.DrawPanel( Canvas,
			                    MyOwnerHUD.EPanel.Middle,
                          ERenderStyle.STY_Modulated,
                          Canvas.ClipX - Canvas.CurX,
                          Canvas.ClipY - Canvas.CurY,
                          WhiteColor,
  					          		MyOwnerHUD.MyOpacity,
								          MyOwnerHUD.MyHUDScale,
                          True );

    if( MyOwnerHUD.PlayerOwner.bBadConnectionAlert &&
        ( MyOwnerHUD.PlayerOwner.Level.TimeSeconds > 5) )
    {
	  bOldSmooth = Canvas.bNoSmooth;
	  Canvas.bNoSmooth = false;
	  Canvas.DrawColor = RedColor;
      Canvas.SetPos( ( Canvas.ClipX + MyLeft ) / 2 - 32, MyTop + 8 );
      Canvas.DrawTile( texture'PLIcon', Scale64, Scale32,
                       0, 0, 64.0, 32.0 );
	  Canvas.bNoSmooth = bOldSmooth;
    }

	  Canvas.DrawColor = MyOwnerHUD.BaseColor;
    //frags

    Canvas.SetPos( Canvas.ClipX - TextLength , Canvas.ClipY - ( YL * index ) );
	  Canvas.DrawText( "FRAGS" );
    Canvas.SetPos( Canvas.ClipX -  XL , Canvas.ClipY - ( YL * index ) );
	  Frags = int( MyWF_PRI.Score );
	  Canvas.DrawText( Frags );
    index--;

	  //caps

    Canvas.SetPos( Canvas.ClipX - TextLength , Canvas.ClipY - ( YL * index ) );
	  Canvas.DrawText( "CAPS" );
    Canvas.SetPos( Canvas.ClipX - XL , Canvas.ClipY - ( YL * index ));
	  Canvas.DrawText(
      class'WFTools'.static.GetMiscScore( MyWF_PRI,
                  class'WFGame'.default.INDEX_FlagCaps) );
    index--;

	  //defends

    Canvas.SetPos( Canvas.ClipX - TextLength , Canvas.ClipY - ( YL * index ) );
	  Canvas.DrawText( "DEFENDS" );
    Canvas.SetPos( Canvas.ClipX - XL, Canvas.ClipY - ( YL * index ));
	  Canvas.DrawText(
      class'WFTools'.static.GetMiscScore( MyWF_PRI,
                  class'WFGame'.default.INDEX_FlagDefends) );
    index--;

	  //fc kills

    Canvas.SetPos( Canvas.ClipX - TextLength , Canvas.ClipY - ( YL * index ) );
	  Canvas.DrawText( "FC KILLS" );
    Canvas.SetPos( Canvas.ClipX - XL, Canvas.ClipY - ( YL * index ));
	  Canvas.DrawText(
      class'WFTools'.static.GetMiscScore( MyWF_PRI,
                  class'WFGame'.default.INDEX_FlagCarrierKills) );
    index--;

	  //fc defends

    Canvas.SetPos( Canvas.ClipX - TextLength , Canvas.ClipY - ( YL * index ) );
	  Canvas.DrawText( "FC DEFENDS" );
    Canvas.SetPos( Canvas.ClipX - XL, Canvas.ClipY - ( YL * index ));
	  Canvas.DrawText(
      class'WFTools'.static.GetMiscScore( MyWF_PRI,
                  class'WFGame'.default.INDEX_FlagCarrierDefends) );
    index--;

    //only display RETURNS if that type of flag return is being used.
    if( (WFGameGRI(TGRI) != None) && (WFGameGRI(TGRI).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn))
    {
	    //flag returns

      Canvas.SetPos( Canvas.ClipX - TextLength , Canvas.ClipY - ( YL * index )  );
	    Canvas.DrawText( "RETURNS" );
      Canvas.SetPos( Canvas.ClipX - XL, Canvas.ClipY - ( YL * index ) );
	    Canvas.DrawText(
        class'WFTools'.static.GetMiscScore( MyWF_PRI,
                    class'WFGame'.default.INDEX_FlagReturns) );
    }
	}
}

simulated function DrawFlag( canvas Canvas )
{
	local int X, Y, i, Width, UseWidth;
	local CTFFlag Flag;
	local float XL, YL, H1, H2;
	local bool bAlt;
	local texture FlagStatus, BackingLeft, Backing;
	local byte Style;
	local TournamentGameReplicationInfo GRI;
	local color BoxColor, IconColor;
	local int LongestName, LongestLocation, Longest;
	local string LocationName;
	local WFCustomHUD MyOwnerHUD;
	local Pawn Holder;
	local PlayerReplicationInfo HolderPRI;

	MyOwnerHUD = WFCustomHUD( OwnerHUD );

	GRI = TournamentGameReplicationInfo(OwnerHUD.PlayerOwner.GameReplicationInfo);

	if( GRI == None )
	{
	  return;
	}

	LongestName = 0;
	LongestLocation = 0;

	if ( ( OwnerHUD.PlayerOwner == None ) ||
	     ( OwnerHUD.PawnOwner == None ) ||
			 ( OwnerHUD.PlayerOwner.GameReplicationInfo == None ) ||
			 ( ( OwnerHUD.PlayerOwner.bShowMenu ||
			     OwnerHUD.PlayerOwner.bShowScores ) &&
				 ( Canvas.ClipX < 640 ) ) )
	{
		return;
	}

	if( MyOwnerHUD.MyHUDScale < 1.0 )
	{
	  Canvas.bNoSmooth = False;
	}


	Canvas.Font = OwnerHUD.MyFonts.GetSmallFont( 640 * MyOwnerHUD.MyHUDScale );

  for ( i=0; i<4; i++ )
  {
   	Flag = CTFReplicationInfo(GRI).FlagList[i];

	  if (Flag != None)
	  {
		  HolderPRI = class'WFTools'.static.GetHolderPRIForFlag(Flag);
		  if( Flag.bHeld && (HolderPRI != None))
		  {
				if( ( OwnerHUD.PawnOwner != None) &&
					( HolderPRI.Team == OwnerHUD.PawnOwner.PlayerReplicationInfo.Team ) )
				{
					if ( HolderPRI.PlayerLocation != None )
					{
						LocationName = HolderPRI.PlayerLocation.LocationName;
					}
					else if ( HolderPRI.PlayerZone != None )
					{
					  LocationName = HolderPRI.PlayerZone.ZoneName;
					}
					Canvas.StrLen( Caps( LocationName ), XL, YL );
					if( XL > LongestLocation )
					{
					  LongestLocation = XL;
					}
				}
			  Canvas.StrLen( Caps( HolderPRI.PlayerName ), XL, YL );
			  if( XL > LongestName )
			  {
  				LongestName = XL;
			  }
			}
		}
	}

	Longest = LongestName;
	if( LongestLocation > Longest )
	{
	  Longest = LongestLocation;
	}

	Width = Longest + ( 16 * MyOwnerHUD.MyHUDScale );

	if( !OwnerHUD.bHideHUD && !OwnerHUD.bHideTeamInfo )
	{
		Y = 108 * MyOwnerHUD.MyStatusScale;

		for ( i=0; i<4; i++ )
		{
			Flag = CTFReplicationInfo(GRI).FlagList[i];

			if ( Flag != None )
			{
				if ( ( OwnerHUD.PawnOwner != None) &&
				     ( Flag.Team == OwnerHUD.PawnOwner.PlayerReplicationInfo.Team ) )
				{
					MyFlag = Flag;
				}

     		HolderPRI = class'WFTools'.static.GetHolderPRIForFlag(Flag);
				if ( Flag.bHome )
				{
				  	FlagStatus = texture'FlagHome';
					Style = ERenderStyle.STY_Modulated;
			  		IconColor = OwnerHUD.TeamColor[Flag.Team];
					UseWidth =  16 * MyOwnerHUD.MyHUDScale;
			  	}
				else if( Flag.bHeld && WFFlag( Flag ).bReturning )
				{
					FlagStatus = texture'FlagReturn';
					Style = ERenderStyle.STY_Translucent;
					BoxColor = OwnerHUD.AltTeamColor[Flag.Team];
					IconColor = MyOwnerHUD.BaseColor;
					UseWidth = Width;
				}
				else if( Flag.bHeld )
				{
					FlagStatus = texture'FlagCapt';
					Style = ERenderStyle.STY_Translucent;
					BoxColor = OwnerHUD.AltTeamColor[Flag.Team];
					UseWidth = Width;
					IconColor = MyOwnerHUD.BaseColor;
					if( MyFlag == Flag )
					{
						H1 = 1.5 * IconBlink;
						H2 = 1 - H1;
						IconColor = MyOwnerHUD.BaseColor * H2 +
										( OwnerHUD.TeamColor[Flag.Team] - MyOwnerHUD.BaseColor )
													* H1;
					}
				}
				else
				{
				  FlagStatus = texture'FlagDown';
					Style = ERenderStyle.STY_Translucent;
					BoxColor = OwnerHUD.AltTeamColor[Flag.Team];
					UseWidth = 16 * MyOwnerHUD.MyHUDScale;
			    IconColor = MyOwnerHUD.BaseColor;
					if( MyFlag == Flag )
					{
			      H1 = 1.5 * IconBlink;
				    H2 = 1 - H1;
				    IconColor = MyOwnerHUD.BaseColor * H2 +
						            ( OwnerHUD.TeamColor[Flag.Team] - MyOwnerHUD.BaseColor )
												* H1;
					}
				}

		    X = Canvas.ClipX - ( 80 * MyOwnerHUD.MyHUDScale + UseWidth );

				Canvas.SetPos(X,Y);
			  MyOwnerHUD.DrawPanel( Canvas,
				                    MyOwnerHUD.EPanel.PLeft,
                            Style, 32, 32, BoxColor,
							          		MyOwnerHUD.MyOpacity,
									          MyOwnerHUD.MyHUDScale );
			  MyOwnerHUD.DrawPanel( Canvas,
				                    MyOwnerHUD.EPanel.PMiddle,
                            Style,
                            ( Canvas.ClipX - Canvas.CurX ) / MyOwnerHUD.MyHUDScale + 0.5,
                            32, BoxColor,
							          		MyOwnerHUD.MyOpacity,
									          MyOwnerHUD.MyHUDScale );

	      Canvas.Style = MyOwnerHUD.MySolidStyle;
				Canvas.SetPos( Canvas.ClipX - ( 76 * MyOwnerHUD.MyHUDScale ),
				               Y + ( 4 * MyOwnerHUD.MyHUDScale ));
				Canvas.DrawColor = IconColor;
				Canvas.DrawTile( FlagStatus, 32 * MyOwnerHUD.MyHUDScale,
				                             32 * MyOwnerHUD.MyHUDScale,
																		 0, 0, 31.0, 31.0);

				if( Flag.bHeld )
				{
					Canvas.DrawColor = MyOwnerHUD.BaseColor;

				  Canvas.SetPos( X + ( 8 * MyOwnerHUD.MyHUDScale ),
					               Y + ( 4 * MyOwnerHUD.MyHUDScale ) );
					Canvas.DrawText( Caps( HolderPRI.PlayerName ) );
					if( ( HolderPRI.Team == OwnerHUD.PawnOwner.PlayerReplicationInfo.Team ) &&
              ( LocationName != "" ) )
					{
				    Canvas.SetPos( X + ( 8 * MyOwnerHUD.MyHUDScale ),
						               Y + YL + ( 4 * MyOwnerHUD.MyHUDScale ) );
					  Canvas.DrawText( ">"$ Caps( LocationName ) );
				  }
				}

				Canvas.SetPos( Canvas.ClipX - ( 48 * MyOwnerHUD.MyHUDScale ), Y );
        MyOwnerHUD.DrawDigits( Canvas,
	                             GRI.Teams[i].Score,
								               2,
								               IconColor,
										 				   MyOwnerHUD.HUDBackgroundColor,
										    		   MyOwnerHUD.MySolidStyle,
											  		   ERenderStyle.STY_Translucent );

			}
			Y += ( 36 * MyOwnerHUD.MyHUDScale );
		}
	}
	Canvas.bNoSmooth = True;
}

simulated function PostRender( out byte bDisableFunction, canvas Canvas )
{
  if( !OwnerHUD.PlayerOwner.bShowMenu && !OwnerHUD.PlayerOwner.bShowScores )
	{
    DrawFlag( Canvas );
	  DrawScore( Canvas );
	}
}

simulated function DrawTeam(out byte bDisableFunction, Canvas Canvas, TeamInfo TI)
{
}

function DLog(coerce string S)
{
	if ((Level.TimeSeconds - LastLog) > 0.5)
		Log(S);
}

defaultproperties
{
     WhiteColor=(R=255,G=255,B=255)
     DigitBackground=(R=32,G=32,B=32)
     RedColor=(R=255)
     BlueColor=(B=255)
}
