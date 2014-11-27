class WFCustomScoreBoard extends WFScoreBoard;

var int BestScores[32];
var int BestScoresTied[32];
var int BestFrags;
var int BestFragsTied;

var int TotalPing[4];
var int RealPlayerCounts[4];
var string ScoreNames[8];
var texture ScoreTextures[8];
var float IconBlink;
var bool bShowBots;

var float MyScale;
var int AreaWidth, AreaHeight, NameAreaWidth;
var int TopInfoHeight;
var int WinningTeam;

function DrawTeamScores( Canvas Canvas, int TeamNumber )
{
  local int AveragePing;
  local int index;
  local float XL, YL;
  local int YPos, XPos, Top, Scores;
  local int ScoreInc, ScoreAreaWidth;
  local bool bReturnStyleGame;
  local WFCustomHUD MyOwnerHUD;
  local CTFFlag Flag;
  local Texture FlagStatus;
  local Color IconColor;
  local bool bMyFlag;
  local float H1, H2;
  local int MyNameAreaWidth;
  local float MyExtraOff;

  MyOwnerHUD = WFCustomHUD( OwnerHUD );
  Flag = CTFReplicationInfo(OwnerHUD.PlayerOwner.GameReplicationInfo).FlagList[TeamNumber];

  Top = 12 * MyScale;

  if( Flag.Team == OwnerInfo.Team )
  {
    bMyFlag = True;
  }

  if ( Flag.bHome )
  {
    FlagStatus = texture'FlagHome';
    IconColor = TeamColor[Flag.Team];
  }
  else if( Flag.bHeld && WFFlag( Flag ).bReturning )
  {
    FlagStatus = texture'FlagReturn';
    IconColor = WhiteColor;
  }
  else if( Flag.bHeld )
  {
    FlagStatus = texture'FlagCapt';
    IconColor = WhiteColor;
    if( bMyFlag )
    {
      H1 = 1.5 * IconBlink;
      H2 = 1 - H1;
      IconColor = WhiteColor * H2 +
                  ( TeamColor[ TeamNumber ] - WhiteColor ) * H1;
    }
  }
  else
  {
    FlagStatus = texture'FlagDown';
    IconColor = WhiteColor;
    if( bMyFlag )
    {
      H1 = 1.5 * IconBlink;
      H2 = 1 - H1;
      IconColor = WhiteColor * H2 +
                  ( TeamColor[ TeamNumber ] - WhiteColor ) * H1;
    }
  }

  Scores=class'WFGame'.default.INDEX_FlagCarrierDefends;
  bReturnStyleGame = false;
  MyExtraOff = 1.0;
  if ( (WFGameGRI(OwnerGame) != None)
    	&& (WFGameGRI(OwnerGame).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn))
  {
    Scores=class'WFGame'.default.INDEX_FlagReturns;
    bReturnStyleGame = true;
    MyExtraOff = 0.75;
  }

  Canvas.Style = ERenderStyle.STY_Normal;
  Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX * 2 );
  Canvas.StrLen( "0", XL, YL );

  Canvas.SetPos( 16 * MyScale , Top + int( 4 * MyScale ) );
  Canvas.DrawColor = IconColor;
  Canvas.DrawTile( FlagStatus, YL, YL, 0, 0, 32.0, 32.0 );

  Canvas.SetPos( 16 * MyScale + YL, Top + int( 4 * MyScale ) );
  if( WinningTeam == TeamNumber )
  {
    H1 = 1.5 * IconBlink;
    H2 = 1 - H1;
    Canvas.DrawColor = WhiteColor * H2 +
                       ( TeamColor[ TeamNumber ] - WhiteColor ) *
                       ( H1 * 0.5 );
  }
  else
  {
    Canvas.DrawColor = TeamColor[ TeamNumber ];
  }
  Canvas.DrawText( OwnerGame.Teams[ TeamNumber ].TeamName );

  if( RealPlayerCounts[ TeamNumber ] > 0 )
  {
    AveragePing = TotalPing[ TeamNumber ] / RealPlayerCounts[ TeamNumber ];
  }
  else
  {
    AveragePing = 0;
  }

  Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
  Canvas.DrawColor = WhiteColor;
  Canvas.StrLen( "0", XL, YL );
  YPos = Top + XL;
  XPos =  ( 32 + NameAreaWidth ) * MyScale;
  Canvas.SetPos( XPos, YPos);
  Canvas.DrawText( "AVG PING  : "$AveragePing );
  YPos += YL;
  Canvas.SetPos( XPos, YPos);
  Canvas.DrawText( "TTL FRAGS : "$
                   WFTeamInfo( OwnerGame.Teams[ TeamNumber ] ).MiscScoreArray[ class'WFGame'.default.INDEX_Frags ] );

  Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
  Canvas.StrLen( "TTL FRAGS : 0000", XL, YL );
  MyNameAreaWidth = NameAreaWidth * MyScale;

  XPos = MyNameAreaWidth + ( 32 * MyScale ) + XL;
  ScoreAreaWidth = AreaWidth - ( XPos + 16 * MyScale );
  ScoreInc = ScoreAreaWidth / ( Scores + 1 );

  Top = 4 * MyScale;

  for( index = Scores; index >= 0; index-- )
  {
    XPos += ScoreInc;

    Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
    Canvas.StrLen( ScoreNames[ index ], XL, YL );

    Canvas.SetPos(  XPos - XL - ( 4 * MyScale ), Top );
    Canvas.DrawColor = WhiteColor;
    Canvas.DrawText( ScoreNames[ index ] );

    Canvas.SetPos(  XPos - ( 76 * MyScale * MyExtraOff ), Top + YL  );
    if( WinningTeam == TeamNumber )
    {
      IconColor = WhiteColor;
    }
    else
    {
      IconColor = AltTeamColor[ TeamNumber];
    }
    if( index == 0 )
    {
      if( WinningTeam == TeamNumber )
      {
        H1 = 1.5 * IconBlink;
        H2 = 1 - H1;
        IconColor = WhiteColor * H2 +
                    ( TeamColor[ TeamNumber ] - WhiteColor ) * H1;
      }
      else
      {
        IconColor = TeamColor[ TeamNumber];
      }
    }
    MyOwnerHUD.DrawDigits( Canvas,

      WFTeamInfo( OwnerGame.Teams[ TeamNumber ] ).MiscScoreArray[ index ],
      3,
      IconColor,
      MyOwnerHUD.HUDBackgroundColor,
      ERenderStyle.STY_Normal,
      ERenderStyle.STY_Translucent,
      MyScale * MyExtraOff);
  }
}

function DrawPlayerLines( Canvas Canvas, int TeamNumber )
{
  local int index, TextHeight, YPos;
  local float XL, YL;
  local bool bDrawLine;
  local int ScaleRightMarigin;

  Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
  Canvas.StrLen( "TEST", XL, YL );
  TextHeight = YL;
  Canvas.Font = MyFonts.GetSmallFont( 400 * MyScale );
  Canvas.StrLen( "TEST", XL, YL );
  TextHeight += YL;

  Canvas.Style = ERenderStyle.STY_Translucent;
  Canvas.DrawColor = TeamColor[ TeamNumber ];

  ScaleRightMarigin = 32;
  YPos = ( 40 * MyScale ) + TopInfoHeight;
  for( index = 0; index < 32; index ++ )
  {
    if( ( Ordered[ index ] != None ) &&
        ( Ordered[ index ].Team == TeamNumber ) &&
        ( ( Ordered[ index ].bIsABot && bShowBots ) ||
            !Ordered[ index ].bIsABot ) )
    {
      if( bDrawLine )
      {
        Canvas.SetPos( 0, YPos );
        Canvas.DrawTile( texture'MsgBack', Canvas.ClipX - ScaleRightMarigin,
                         TextHeight, 0, 0, 8.0, 8.0);
        Canvas.DrawTile( texture'MsgBackEnd', 32, TextHeight,
                         0, 0, 32.0, 8.0);
      }
      bDrawLine = !bDrawLine;
      YPos += TextHeight + 2;
    }
  }
}

function VictoryInfo()
{
  local int index;
  local int BestScore, BestTeam;
  local bool bBestTied;
  local int Caps;

  BestTeam = -1;
  BestScore = -1;
  bBestTied  = False;
  WinningTeam = -1;

  if ( OwnerGame.GameEndedComments != "" )
  {
    for( index =0; index<4; index++ )
    {
      if( WFTeamInfo( OwnerGame.Teams[ index ] ) == None )
      {
        continue;
      }
      Caps = WFTeamInfo( OwnerGame.Teams[ index ] ).MiscScoreArray[ class'WFGame'.default.INDEX_FlagCaps ];
      if( Caps > BestScore )
      {
        BestScore = Caps;
        BestTeam  = index;
      }
      else if( Caps == BestScore )
      {
        bBestTied = true;
      }
    }
    if( !bBestTied && ( BestScore > 0 ) )
    {
      WinningTeam = BestTeam;
    }
  }
}

function DrawPlayerScores( Canvas Canvas, int TeamNumber )
{
  local int index, score_index;
  local int YPos, XPos;
  local float XL, YL;
  local WF_PRI WFPRI;
  local WF_BotPRI WFBotPRI;
  local string ClassName;
  local string LocationName;
  local color NameColor, OtherColor;
  local int Scores, ScoreInc, ScoreAreaWidth, MyScore, CapsScored;
  local bool bReturnStyleGame;
  local int TextHeight;
  local int MyNameAreaWidth;
	local int Time;
  local int FlagScale;
  local int Scale8, Scale16, Scale32;

  Scale8 = 8 * MyScale;
  Scale16 = Scale8 + Scale8;
  Scale32 = Scale16 + Scale16;

  Scores=4;
  bReturnStyleGame = false;
  if ( (WFGameGRI(OwnerGame) != None)
    	&& (WFGameGRI(OwnerGame).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn))
  {
    Scores=5;
    bReturnStyleGame = true;
  }


  YPos = ( 40 * MyScale ) + TopInfoHeight;
  for( index = 0; index < 32; index ++ )
  {
    if( ( Ordered[ index ] != None ) &&
        ( Ordered[ index ].Team == TeamNumber ) &&
        ( ( Ordered[ index ].bIsABot && bShowBots ) ||
            !Ordered[ index ].bIsABot ) )
    {
		  Time = Max(1, ( Level.TimeSeconds +
                      OwnerHUD.PlayerOwner.PlayerReplicationInfo.StartTime -
                      Ordered[ index ].StartTime)/60);
      Canvas.Font = MyFonts.GetSmallFont( 400 * MyScale );
      Canvas.StrLen( "TEST", XL, YL );
      TextHeight = YL;

      Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale);
      Canvas.StrLen( "TEST", XL, YL );
      TextHeight += YL;
      if( Ordered[ index ].PlayerName == OwnerInfo.PlayerName )
      {
        NameColor = WhiteColor;
        OtherColor = WhiteColor * 0.75;
      }
      else
      {
        NameColor = TeamColor[ TeamNumber ];
        OtherColor = AltTeamColor[ TeamNumber ];
      }

      CapsScored = class'WFTools'.static.GetMiscScore( Ordered[ index ], class'WFGame'.default.INDEX_FlagCaps);

      WFPRI = WF_PRI( Ordered[ index ] );
      if( WFPRI != None )
      {
        ClassName = Caps( WFPRI.ClassName);
      }
      else
      {
        WFBotPRI = WF_BotPRI( Ordered[ index ] );
        if( WFBotPRI != None )
        {
          ClassName = Caps( WFBotPRI.ClassName);
        }
      }
      if ( Ordered[ index ].PlayerLocation != None )
      {
        LocationName = ">" $ Ordered[ index ].PlayerLocation.LocationName;
      }
      else if ( Ordered[ index ].PlayerZone != None )
      {
        Locationname = ">" $ Ordered[ index ].PlayerZone.ZoneName;
      }

      XPos = Scale8;
      if( Ordered[ index ].HasFlag != None )
      {
        XPos = Scale8 + TextHeight + 2;
        Canvas.SetPos( Scale8 , YPos );
        Canvas.DrawColor = TeamColor[ CTFFlag(Ordered[ index ].HasFlag).Team ];
        FlagScale = TextHeight + ( 4 * MyScale );
        if( CTFFlag( Ordered[ index ].HasFlag ).bHeld &&
                 WFFlag( Ordered[ index ].HasFlag ).bReturning )
        {
          Canvas.DrawTile( texture'FlagReturn',
                           FlagScale, FlagScale, 0,0, 32.0, 32.0 );
        }
        else if( CTFFlag( Ordered[ index ].HasFlag ).bHeld )
        {
          Canvas.DrawTile( texture'FlagCapt',
                           FlagScale, FlagScale, 0,0, 32.0, 32.0 );
        }
      }

      Canvas.SetPos( XPos, YPos );
      Canvas.DrawColor = NameColor;
      Canvas.DrawText( Ordered[ index ].PlayerName, False );
      Canvas.DrawColor = OtherColor;

      if( TeamNumber == OwnerInfo.Team )
      {
        Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
        Canvas.DrawText( " - "$ClassName, False );
      }
      Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
      Canvas.DrawText( " - "$Time$" min.", False );

      if( TeamNumber == OwnerInfo.Team )
      {
        Canvas.SetPos( XPos, YPos + YL );
        Canvas.Font = MyFonts.GetSmallFont( 400 * MyScale );
        Canvas.DrawText( LocationName );
      }

      Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
      Canvas.StrLen( "TEST", XL, YL );
      XPos =  ( 32 + NameAreaWidth )* MyScale;
      Canvas.SetPos( XPos, YPos);
      Canvas.DrawColor = OtherColor;
      Canvas.DrawText( "FRAGS   : ", False );
      Canvas.DrawColor = WhiteColor;
      Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
      Canvas.DrawText( class'WFTools'.static.GetMiscScore( Ordered[ index ], class'WFGame'.default.INDEX_Frags ) );
      Canvas.SetPos( XPos, YPos + YL);
      Canvas.DrawColor = OtherColor;
      Canvas.DrawText( "PING : ", False);
      Canvas.DrawColor = WhiteColor;
      Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
      if( Ordered[ index ].bIsABot )
      {
        Canvas.DrawColor = CyanColor;
        Canvas.DrawText( "BOT" );
      }
      else
      {
        Canvas.DrawColor = WhiteColor;
        Canvas.DrawText( Ordered[ index ].Ping );
      }
      Canvas.StrLen( "TEST", XL, YL );
      Canvas.DrawColor = WhiteColor;

      Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
      Canvas.StrLen( "TTL FRAGS : 0000", XL, YL );
      MyNameAreaWidth = NameAreaWidth * MyScale;

      XPos = MyNameAreaWidth + Scale32 + XL;
      ScoreAreaWidth = AreaWidth - ( XPos + Scale16 );
      ScoreInc = ScoreAreaWidth / Scores;

      Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX );
      for( score_index = ( Scores - 1); score_index >= 0; score_index-- )
      {
        XPos += ScoreInc;
        MyScore = class'WFTools'.static.GetMiscScore( Ordered[ index ], score_index );
        if( ( MyScore == BestScores[ TeamNumber * 8 + score_index] ) &&
            ( BestScoresTied[ TeamNumber * 8 + score_index] == 0 ) &&
            ( MyScore > 0 ) )
        {
          Canvas.Style = ERenderStyle.STY_Translucent;
          Canvas.SetPos( XPos - Scale32 , YPos );
          Canvas.DrawColor = GreenColor;
          Canvas.DrawTile( texture'SBOX', Scale32, TextHeight,
                           0, 0, 32.0, 32.0 );
        }
        else if( ( MyScore == BestScores[ TeamNumber * 8 + score_index] ) &&
                 ( BestScoresTied[ TeamNumber * 8 + score_index] > 0 ) &&
                 ( MyScore > 0 ) )
        {
          Canvas.Style = ERenderStyle.STY_Translucent;
          Canvas.SetPos( XPos - Scale32, YPos );
          Canvas.DrawColor = RedColor;
          Canvas.DrawTile( texture'SBOX', Scale32, TextHeight,
                           0, 0, 32.0, 32.0 );
        }
        else
        {
        }
        if( MyScore > 0 )
        {
          Canvas.DrawColor = WhiteColor;
        }
        else
        {
          Canvas.DrawColor = WhiteColor * 0.5;
        }
        Canvas.Style = ERenderStyle.STY_Normal;
        Canvas.StrLen( MyScore, XL, YL );
        Canvas.SetPos( XPos - XL - Scale8, YPos );
        Canvas.DrawText( MyScore );
      }
      YPos += TextHeight + 2;
    }
  }
}

function RankPlayers( int NumOfPlayers )
{
  local WF_PRI WFPRI;
  local WF_BotPRI WFBotPRI;
  local int index, score_index;

  BestFrags = 0;
  BestFragsTied = 0;
  for( index=0; index<4; index++ )
  {
    for( score_index=0; score_index < 8; score_index++ )
    {
      BestScores[( index * 8 )+score_index] = 0;
      BestScoresTied[( index * 8 )+score_index] = 0;
    }
    TotalPing[ Index ] = 0;
  }

  for( index=0; index < NumOfPlayers; index++)
  {
    if( !Ordered[index].bIsABot )
    {
      TotalPing[ Ordered[index].Team ] += Ordered[index].Ping;
    }

    if( Ordered[index].Score > BestFrags )
    {
      BestFrags = Ordered[index].Score;
    }
    else if( Ordered[index].Score == BestFrags )
    {
      BestFragsTied++;
    }

    WFPRI = WF_PRI( Ordered[index] );
    if( WFPRI != None )
    {
      for( score_index=0; score_index<8; score_index++ )
      {
        if( WFPRI.MiscScoreArray[score_index] >
            BestScores[ ( WFPRI.Team * 8 ) + score_index ] )
        {
          BestScores[ ( WFPRI.Team * 8 ) + score_index ] =
            WFPRI.MiscScoreArray[score_index];
          BestScoresTied[ ( WFPRI.Team * 8 ) + score_index ] = 0;
        }
        else if( WFPRI.MiscScoreArray[score_index] ==
                 BestScores[ ( WFPRI.Team * 8 ) + score_index ] )
        {
          BestScoresTied[( WFPRI.Team * 8 )+score_index]++;
        }
      }
    }
    else
    {
      WFBotPRI = WF_BotPRI( Ordered[index] );
      if( WFBotPRI != None )
      {
        for( score_index=0; score_index<8; score_index++ )
        {
          if( WFBotPRI.MiscScoreArray[score_index] >
              BestScores[ ( WFBotPRI.Team * 8 ) + score_index ] )
          {
            BestScores[ ( WFBotPRI.Team * 8 ) + score_index ] =
            WFBotPRI.MiscScoreArray[score_index];
            BestScoresTied[ ( WFBotPRI.Team * 8 ) + score_index ] = 0;
          }
          else if( WFBotPRI.MiscScoreArray[score_index] ==
                   BestScores[ ( WFBotPRI.Team * 8 ) + score_index ] )
          {
            BestScoresTied[ ( WFBotPRI.Team * 8 ) + score_index ]++;
          }
        }
      }
    }
  }
}

function SortScores(int N)
{
  local int I, J, Max;
  local PlayerReplicationInfo TempPRI;

  for ( I=0; I<N-1; I++ )
  {
    Max = I;
    for ( J=I+1; J<N; J++ )
    {
      // humans come before bots
      if( !Ordered[J].bIsABot && Ordered[Max].bIsABot )
      {
        Max = J;
      }
      // max is a human, and this is a bot, do nothing
      else if( Ordered[J].bIsABot && !Ordered[Max].bIsABot )
      {
        continue;
      }
      // at this point it's eithr human vs human or bot vs bot
      else
      {
        // go off of the start time
        if ( Ordered[J].StartTime < Ordered[Max].StartTime )
        {
          Max = J;
        }
        // if started at the same time, go off of player id
        else if ( ( Ordered[J].StartTime == Ordered[Max].StartTime ) &&
                  ( Ordered[J].PlayerID < Ordered[Max].PlayerID ) )
        {
          Max = J;
        }
      }
    }

    TempPRI = Ordered[Max];
    Ordered[Max] = Ordered[I];
    Ordered[I] = TempPRI;
  }
}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount, index, score_index;
	local float LoopCountTeam[4];
	local float XL, YL;
	local int PlayerCounts[4];
	local int LongLists[4];
	local int BottomSlot[4];
	local font CanvasFont;
	local bool bCompressed;
	local float r;
  local int Offset, YOffset, XStart;
  local int NumberOfTeams;
  local int OldClipX, OldClipY;
  local int YPos, XPos;
  local int AreaXStart, AreaYStart, ScoreInc, Scores;
  local int MyNameAreaWidth, NameAreaHeight, ScoreAreaWidth;
  local int Scale8, Scale16, Scale24, Scale32, Scale48;
  local int Scale64, Scale80;
  local int TopHeightScale, NameHeightScale;
  local bool bOldNoSmooth;
  local bool bIsWinningTeam;


  OldClipX = Canvas.ClipX;
  OldClipY = Canvas.ClipY;
  bOldNoSmooth = Canvas.bNoSmooth;

  Canvas.bNoSmooth = True;

  MyScale = Canvas.ClipX / 800.0;
  AreaWidth  = Canvas.ClipX - ( 32 * MyScale );
  AreaXStart = ( Canvas.ClipX / 2 ) - ( AreaWidth / 2 );
  MyNameAreaWidth = NameAreaWidth * MyScale;
  TopInfoHeight = 16;
  TopHeightScale = int( 16 * MyScale + 0.5 );

  Scale8 = int( 8 * MyScale + 0.5 );
  Scale16 = Scale8 + Scale8;
  Scale24 = Scale16 + Scale8;
  Scale32 = Scale24 + Scale8;
  Scale48 = Scale32 + Scale16;
  Scale64 = Scale48 + Scale16;
  Scale80 = Scale64 + Scale16;

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);

  for( index=0; index<4; index++ )
  {
    RealPlayerCounts[index]=0;
  }

	for ( index=0; index<32; index++ )
	{
		Ordered[index] = None;
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[index] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[index];
			if ( (!PRI.bIsSpectator || PRI.bWaitingPlayer) && (PRI.Team < 4) )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				PlayerCounts[PRI.Team]++;
        if( !PRI.bIsABot )
        {
          RealPlayerCounts[PRI.Team]++;
        }
			}
		}
	}

  NumberOfTeams = 0;
  for( index=0; index<4; index++ )
  {
    if( PlayerCounts[index]>0 )
    {
      NumberOfTeams++;
    }
  }

	SortScores( PlayerCount );
  RankPlayers( PlayerCount );
  VictoryInfo();

  if( NumberOfTeams > 0 )
  {

    AreaYStart = Scale32;
    AreaHeight = ( ( Canvas.ClipY - Scale64 ) / NumberOfTeams );
    NameAreaHeight = AreaHeight - ( TopInfoHeight * MyScale ) - Scale64;
    Canvas.Font = MyFonts.GetSmallFont( 512 * MyScale );
    Canvas.SetPos(0,0);
    Canvas.StrLen( "TTL FRAGS : 0000", XL, YL );

    Scores=4;
    if ( (WFGameGRI(OwnerGame) != None)
    	&& (WFGameGRI(OwnerGame).FlagReturnStyle == class'WFGame'.default.FRS_CarryReturn))
    {
      Scores=5;
    }

    for( index=0; index<NumberOfTeams; index++)
	  {
      bIsWinningTeam = ( WinningTeam == index );

      Canvas.SetOrigin( AreaXStart, index * AreaHeight + AreaYStart );
      Canvas.SetClip( AreaWidth, AreaHeight );
      Canvas.DrawColor = TeamColor[ index ];

      DrawPlayerLines( Canvas, index );

      Canvas.Style = ERenderStyle.STY_Modulated;

      YPos = Scale8;
      Canvas.SetPos(0,YPos);
      Canvas.DrawTile( texture'MSB1', Scale16, Scale16, 0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB2', MyNameAreaWidth + XL + Scale16,
                       Scale16, 0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos(0,YPos);
        Canvas.DrawTile( texture'MWB1', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MWB2', MyNameAreaWidth + XL + Scale16,
                         Scale16, 0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += Scale16;
      Canvas.SetPos(0, YPos);
      Canvas.DrawTile( texture'MSB4', Scale16, TopHeightScale,
                       0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB5', MyNameAreaWidth + XL + Scale16,
                       TopHeightScale, 0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos(0, YPos);
        Canvas.DrawTile( texture'MWB4', Scale16, TopHeightScale,
                         0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += TopHeightScale;
      Canvas.SetPos(0, YPos);
      Canvas.DrawTile( texture'MSB4', Scale16, Scale16, 0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB5', MyNameAreaWidth, Scale16,
                       0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB6', Scale16, Scale16, 0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB7', XL , Scale16, 0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos(0, YPos);
        Canvas.DrawTile( texture'MWB4', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.CurX += MyNameAreaWidth;
        Canvas.DrawTile( texture'MWB6', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MWB7', XL , Scale16, 0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += Scale16;
      Canvas.SetPos(0, YPos);
      Canvas.DrawTile( texture'MSB4', Scale16, NameAreaHeight,
                       0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB5', MyNameAreaWidth, NameAreaHeight,
                       0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB9', Scale16, NameAreaHeight,
                       0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB10', XL, NameAreaHeight, 0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos(0, YPos);
        Canvas.DrawTile( texture'MWB4', Scale16, NameAreaHeight,
                       0, 0, 16.0, 16.0 );
        Canvas.CurX += MyNameAreaWidth;
        Canvas.DrawTile( texture'MWB9', Scale16, NameAreaHeight,
                         0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += NameAreaHeight;
      Canvas.SetPos(0, YPos);
      Canvas.DrawTile( texture'MSB12', Scale16, Scale16, 0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB13', MyNameAreaWidth, Scale16,
                       0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB14', Scale16, Scale16, 0, 0, 16.0, 16.0 );
      Canvas.DrawTile( texture'MSB15', XL, Scale16, 0, 0, 16.0, 16.0 );
      XPos = Canvas.CurX;


      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos(0, YPos);
        Canvas.DrawTile( texture'MWB12', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MWB13', MyNameAreaWidth, Scale16,
                         0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MWB14', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      ScoreAreaWidth = AreaWidth - ( XPos + Scale16 );
      ScoreInc = ScoreAreaWidth / Scores;
      for( score_index=0; score_index<Scores; score_index++ )
      {
        YPos =  Scale8;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MSB2', Scale16, Scale16, 0, 0, 16.0, 16.0 );

        if( bIsWinningTeam )
        {
          Canvas.Style = ERenderStyle.STY_Translucent;
          Canvas.SetPos( XPos, YPos);
          Canvas.DrawTile( texture'MWB2', Scale16, Scale16, 0, 0, 16.0, 16.0 );
          Canvas.Style = ERenderStyle.STY_Modulated;
        }

        YPos += Scale16;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MSB5', Scale16, TopHeightScale,
                         0, 0, 16.0, 16.0 );

        YPos += TopHeightScale;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MSB7', Scale16, Scale16, 0, 0, 16.0, 16.0 );

        if( bIsWinningTeam )
        {
          Canvas.Style = ERenderStyle.STY_Translucent;
          Canvas.SetPos( XPos, YPos);
          Canvas.DrawTile( texture'MWB7', Scale16, Scale16, 0, 0, 16.0, 16.0 );
          Canvas.Style = ERenderStyle.STY_Modulated;
        }

        YPos += Scale16;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MSB10', Scale16, NameAreaHeight,
                         0, 0, 16.0, 16.0 );

        YPos += NameAreaHeight;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MSB15', Scale16, Scale16, 0, 0, 16.0, 16.0 );

        YPos = 0;
        Canvas.SetPos( XPos + Scale16, YPos);
        Canvas.DrawTile( texture'MSBA1', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA2', ScoreInc - Scale48 ,
                         Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA3', Scale16, Scale16, 0, 0, 16.0, 16.0 );

        YPos +=  Scale16;
        Canvas.SetPos( XPos + Scale16, YPos);
        Canvas.DrawTile( texture'MSBA4', Scale16,
                         TopHeightScale + Scale8, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA5', ScoreInc - Scale48 ,
                         TopHeightScale + Scale8, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA6', Scale16,
                         TopHeightScale + Scale8, 0, 0, 16.0, 16.0 );

        YPos += TopHeightScale + Scale8;
        Canvas.SetPos( XPos + Scale16, YPos);
        Canvas.DrawTile( texture'MSBA7', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA8', ScoreInc - Scale80,
                         Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA9', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA5', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA6', Scale16, Scale16, 0, 0, 16.0, 16.0 );


        YPos +=  Scale16;
        Canvas.SetPos( XPos + Scale16, YPos);
        Canvas.DrawTile( texture'MSB10', ScoreInc - Scale64,
                         Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA10', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA13', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA6', Scale16, Scale16, 0, 0, 16.0, 16.0 );

        YPos +=  Scale16;
        Canvas.SetPos( XPos + Scale16, YPos);

        Canvas.DrawTile( texture'MSB10', ScoreInc - Scale48,
                         NameAreaHeight - Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA4', Scale16, NameAreaHeight - Scale16,
                         0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA6', Scale16, NameAreaHeight - Scale16,
                         0, 0, 16.0, 16.0 );

        YPos += ( NameAreaHeight - Scale16 );
        Canvas.SetPos( XPos + Scale16, YPos);
        Canvas.DrawTile( texture'MSB15', ScoreInc - Scale48,
                         Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA14', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.DrawTile( texture'MSBA12', Scale16, Scale16, 0, 0, 16.0, 16.0 );

        XPos = Canvas.CurX;
      }

      YPos = Scale8;
      Canvas.SetPos( XPos, YPos);
      Canvas.DrawTile( texture'MSB3', Scale16, Scale16, 0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MWB3', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += Scale16;
      Canvas.SetPos( XPos, YPos);
      Canvas.DrawTile( texture'MSB17', Scale16, TopHeightScale,
                       0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MWB17', Scale16, TopHeightScale,
                         0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += TopHeightScale;
      Canvas.SetPos( XPos, YPos);
      Canvas.DrawTile( texture'MSB8', Scale16, Scale16, 0, 0, 16.0, 16.0 );

      if( bIsWinningTeam )
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        Canvas.SetPos( XPos, YPos);
        Canvas.DrawTile( texture'MWB8', Scale16, Scale16, 0, 0, 16.0, 16.0 );
        Canvas.Style = ERenderStyle.STY_Modulated;
      }

      YPos += Scale16;
      Canvas.SetPos( XPos, YPos);
      Canvas.DrawTile( texture'MSB11', Scale16, NameAreaHeight,
                       0, 0, 16.0, 16.0 );

      YPos += NameAreaHeight;
      Canvas.SetPos( XPos, YPos);
      Canvas.DrawTile( texture'MSB16', Scale16, Scale16, 0, 0, 16.0, 16.0 );

      DrawTeamScores( Canvas, index );
      DrawPlayerScores( Canvas, index );
	  }

  }

  Canvas.SetClip( OldClipX, OldClipY );
  Canvas.SetOrigin( 0, 0 );

	if ( !(Level.GetPropertyText("bLowRes") ~= "True") )
	{
		DrawTrailer(Canvas);
	}

  Canvas.bNoSmooth = bOldNoSmooth;
}

function DrawTrailer( Canvas Canvas )
{
  local int Width, Start;
  local WFCustomHUD MyOwnerHUD;
  local float XL, YL;
  local TournamentGameReplicationInfo TGRI;
  local string Message;
  local int Seconds, Minutes, Hours;
  local float H1, H2;

  MyOwnerHUD = WFCustomHUD( OwnerHUD );

  Width = Canvas.ClipX - ( 32 * MyScale + 0.5 );
  Start = ( Canvas.ClipX / 2 ) - ( Width / 2 );
  Canvas.SetPos( Start, Canvas.ClipY - ( 32 * MyScale ) );
  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PLeft,
                        ERenderStyle.STY_Modulated,
                        32,
                        32,
                        WhiteColor,
                        8,
                        MyScale );
  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PMiddle,
                        ERenderStyle.STY_Modulated,
                        ( Width - ( 64 * MyScale ) ) / MyScale,
                        32,
                        WhiteColor,
                        8,
                        MyScale );
  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PRight,
                        ERenderStyle.STY_Modulated,
                        32,
                        32,
                        WhiteColor,
                        8,
                        MyScale );
  Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );
  if ( OwnerGame.GameEndedComments != "" )
  {
    Canvas.DrawColor = WhiteColor;
    Canvas.StrLen( OwnerGame.GameEndedComments, XL, YL );
    Canvas.SetPos( ( Canvas.ClipX / 2 ) - ( XL/ 2 ),
                 Canvas.ClipY - ( 30 * MyScale ) );
    Canvas.DrawText( OwnerGame.GameEndedComments );
  }
  else
  {
    TGRI = TournamentGameReplicationInfo( OwnerHUD.PlayerOwner.GameReplicationInfo);
    if ( TGRI == None )
    {
      return;
    }


    Canvas.DrawColor = GreenColor;
    Canvas.SetPos(  Start + ( 32 * MyScale ),
                    Canvas.ClipY - ( 30 * MyScale ) );
    Canvas.DrawText( "CAP LIMIT : ", False);
    Canvas.CurY = Canvas.ClipY - ( 30 * MyScale );
    Canvas.DrawColor = WhiteColor;
    if ( TGRI.GoalTeamScore > 0 )
    {
      Canvas.DrawText( TGRI.GoalTeamScore );
    }
    else
    {
      Canvas.DrawText( "NA" );
    }

    Canvas.DrawColor = GreenColor;
    Canvas.StrLen( "TIME LIMIT : 00:00", XL, YL );
    Canvas.SetPos(  ( Canvas.ClipX / 2 ) - ( XL / 2 ),
                    Canvas.ClipY - ( 30 * MyScale ) );
    Canvas.DrawText( "TIME LIMIT : ", False );
    Canvas.CurY = Canvas.ClipY - ( 30 * MyScale );
    Canvas.DrawColor = WhiteColor;
    if ( TGRI.TimeLimit > 0 )
    {
      Canvas.DrawText( TGRI.TimeLimit$":00" );

      Canvas.DrawColor = GreenColor;
      Canvas.StrLen( "TIME LEFT : 00:00", XL, YL );
      Canvas.SetPos( Canvas.ClipX - Start  - XL - ( 32 * MyScale ),
                     Canvas.ClipY - ( 30 * MyScale ) );
      Canvas.DrawText( "TIME LEFT : ", False );
      Canvas.CurY = Canvas.ClipY - ( 30 * MyScale );
      if ( OwnerHUD.PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
      {
      	H1 = 1.5 * IconBlink;
        H2 = 1 - H1;
        Canvas.DrawColor = RedColor * H2 +
                    ( BlueColor - WhiteColor ) * H1;
        Canvas.DrawText( "SDOT!" );
      }
      else
      {
        Minutes = OwnerHUD.PlayerOwner.GameReplicationInfo.RemainingTime/60;
        Seconds = OwnerHUD.PlayerOwner.GameReplicationInfo.RemainingTime % 60;
        if( Minutes < 1 )
        {
          Canvas.DrawColor = RedColor;
        }
        else
        {
          Canvas.DrawColor = WhiteColor;
        }
        Canvas.DrawText( TwoDigitString(Minutes)$":"$TwoDigitString(Seconds) );
      }
    }
    else
    {
      Canvas.DrawText( "NA" );

      Canvas.DrawColor = GreenColor;
      Canvas.StrLen( "ELP. TIME : 00:00:00", XL, YL );
      Canvas.SetPos( Canvas.ClipX - Start  - XL - ( 32 * MyScale ),
                     Canvas.ClipY - ( 30 * MyScale ) );
      Canvas.DrawText( "ELP. TIME : ", False );
      Canvas.CurY = Canvas.ClipY - ( 30 * MyScale );
      Canvas.DrawColor = WhiteColor;

      Seconds = OwnerHUD.PlayerOwner.GameReplicationInfo.ElapsedTime;
      Minutes = Seconds / 60;
      Hours   = Minutes / 60;
      Seconds = Seconds - (Minutes * 60);
      Minutes = Minutes - (Hours * 60);
      Canvas.DrawText( TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds) );
    }
  }
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

defaultproperties
{
     ScoreNames(0)="CAPS"
     ScoreNames(1)="DEFENDS"
     ScoreNames(2)="FC KILLS"
     ScoreNames(3)="FC DEFENDS"
     ScoreNames(4)="RETURNS"
     bShowBots=True
     NameAreaWidth=200
}
