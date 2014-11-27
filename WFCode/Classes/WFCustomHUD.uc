//=============================================================================
// WFCustomHUD
// Author: spoon (jwalstra@spoonserver.com)
//=============================================================================

class WFCustomHUD extends WFHUD;

var color HUDBackgroundColor, GreyColor;
var bool bShowHUDInfo;
var config bool bShowHistory; // ob1: moved this to be a config var
var config bool bWeaponIcons, bGrenadeIcons;
var int MaxNumOfMsgs, MaxNumOfLocalMsgs, MaxNumOfEvntMsgs, DefaultNumOfMsgs;
var float MyHUDScale, MyWeaponScale, MyStatusScale, MyOpacity, MyOpacityScale;
var float MsgOpacityScale;
var byte MySolidStyle;
var HUDLocalizedMessage ShortMessageQueue[25];
var HUDLocalizedMessage EvntMessageQueue[10];
var HUDLocalizedMessage LocalMessages[10];

var Texture ModulatedMsgTexture[3];
var Texture NormalMsgTexture[3];

var bool bCursor;
var int MinNumOfMsgs;
var int MinNumOfEvntMsgs;
var config int ShowNumOfMsgs;
var config int ShowNumOfEvntMsgs;
var config float MsgScale;
var bool bMsgScaleChanged;
var config float MiscMsgScale;
var config bool bShowClock;

enum EPanel
{
  // texture 1
  PRight,
  PLeft,
  PMiddle,
	Middle,

  // texture 2
	TopRight,
	TopLeft,
	BottomRight,
	BottomLeft,

  // texture 3
  Right,
  Bottom,
  Left,
  Top
};

exec function ToggleHistory()
{
  bShowHistory = !bShowHistory;
  SaveConfig();
}

exec function ToggleHUDInfo()
{
  bShowHUDInfo = !bShowHUDInfo;
}

exec function ToggleClock()
{
  bShowClock = !bShowClock;
  SaveConfig();
}

exec function ToggleWeaponIcons()
{
  bWeaponIcons = !bWeaponIcons;
  SaveConfig();
}

exec function ToggleGrenadeIcons()
{
  bGrenadeIcons = !bGrenadeIcons;
  SaveConfig();
}

simulated function ShowHUDInfo( Canvas Canvas )
{
  Canvas.Font = Canvas.SmallFont;
  Canvas.SetPos( 0,120 );
  Canvas.DrawColor = WhiteColor;
  Canvas.DrawText( "MyHUDScale = "$MyHUDScale, true );
  Canvas.DrawText( "MyWeaponScale = "$MyWeaponScale, true );
  Canvas.DrawText( "MyStatusScale = "$MyStatusScale, true );
  Canvas.DrawText( "MyOpacity = "$MyOpacity, true );
  Canvas.DrawText( "MyOpacityScale = "$MyOpacityScale, true );
  Canvas.DrawText( "MySolidStyle = "$MySolidStyle, true );
  Canvas.DrawColor = HUDColor;
  Canvas.DrawText( "HUDColor", true );
  Canvas.DrawColor = BaseColor;
  Canvas.DrawText( "BaseColor", true );
  Canvas.DrawColor = WhiteColor;
  Canvas.DrawText( "MessageFadeTime = "$MessageFadeTime, true );
  Canvas.DrawText( "MsgOpacityScale = "$MsgOpacityScale, true );
  Canvas.DrawText( "HUDScale = "$HUDScale, true );
  Canvas.DrawText( "WeaponScale = "$WeaponScale, true );
  Canvas.DrawText( "StatusScale = "$StatusScale, true );
  Canvas.DrawText( "Opacity = "$Opacity, true );
}


exec function SetNumMsgs( int NumLines )
{
  if( NumLines > MaxNumOfMsgs )
  {
    NumLines = MaxNumOfMsgs;
  }
  if( NumLines < MinNumOfMsgs )
  {
    NumLines = MinNumOfMsgs;
  }
  ShowNumOfMsgs = NumLines;
  SaveConfig();
}

exec function SetMsgScale( float Scale )
{
  if( Scale > 0 )
  {
    MsgScale = Scale;
    SaveConfig();
    bMsgScaleChanged = true;
  }
}

exec function SetMiscMsgScale( float Scale )
{
  if( Scale > 0 )
  {
    MiscMsgScale = Scale;
    SaveConfig();
  }
}


exec function SetNumEvntMsgs( int NumLines )
{
  if( NumLines > MaxNumOfEvntMsgs )
  {
    NumLines = MaxNumOfEvntMsgs;
  }
  if( NumLines < MinNumOfEvntMsgs )
  {
    NumLines = MinNumOfEvntMsgs;
  }
  ShowNumOfEvntMsgs = NumLines;
  SaveConfig();
}

simulated function DrawPanel( Canvas         Canvas,
                    byte           Type,
                    byte           Style,
                    int            XL,
                    int            YL,
                    color          Color,
										int						 Opacity,
                    optional float Scale,
                    optional bool  bNoScale )
{
  local byte OldStyle;
  local texture PanelTexture;
  local int YIndex, XIndex;
	local int index;
	local bool MyNoSmooth;

  OldStyle = Canvas.Style;
  Canvas.Style = Style;

  if( Scale == 0 )
  {
	  Scale = MyHUDScale;
  }

  // Calculate the offset into the texture

  index = Type / 4;
  YIndex = ( Type - ( index * 4 ) ) * 64;


	// bah, i messed up how the texture work. I have to invert the
	// opacity
	Opacity = 17 - Opacity;
  if( Opacity > 8 )
  {
    Opacity -= 8;
    YIndex += 32;
  }
	Opacity -= 1;
  XIndex = Opacity * 32;

  if( Style == ERenderStyle.STY_Modulated )
  {
	  PanelTexture = ModulatedMsgTexture[ index ];
  }
  else
  {
    if( MyOpacityScale < 1.0 )
    {
      Canvas.Style = ERenderStyle.STY_Translucent;
    }
    PanelTexture = NormalMsgTexture[ index ];
    Canvas.DrawColor = Color * MyOpacityScale;
  }

  if( !bNoScale )
  {
  	XL = int( XL * Scale + 0.5);
  	YL = int( YL * Scale + 0.5);
  }

  MyNoSmooth = Canvas.bNoSmooth;
	Canvas.bNoSmooth = True;
  Canvas.DrawTile( PanelTexture, XL, YL, XIndex, YIndex, 32.0, 32.0 );
	Canvas.bNoSmooth = MyNoSmooth;

  Canvas.Style = OldStyle;
}

simulated function DrawDigits( Canvas         Canvas,
                     int            Value,
                     int            NumDigits,
                     color          Foreground,
                     color          Background,
                     byte           ForegroundStyle,
                     byte           BackgroundStyle,
                     optional float Scale,
                     optional bool bFlash)
{
  local string       Str;
  local int          loop, index;
  local string       Digit;
  local texture      DigitTexture;
  local byte         Style;
  local int          StrLen;
	local int          X, Y;
	local float H1, H2;

	if( Scale == 0 )
	{
	  Scale = MyHUDScale;
	}

  // Preserve the current style
  Style = Canvas.Style;

  Str = string( Value );
  StrLen = Len( Str );

  index = 0;

	X = Canvas.CurX;
	Y = Canvas.CurY;
  for( loop = NumDigits; loop>= 1; loop-- )
  {
    Canvas.Style = BackgroundStyle;
    Canvas.CurX = X;
    Canvas.CurY = Y;
    Canvas.DrawColor = Background;
    Canvas.DrawTile( Texture'DigitBlank', 24 * Scale, 32 *Scale,
		                 0, 0, 24.0, 32.0);

    if( loop <= StrLen )
    {
      Canvas.SetPos( X, Y );
      if (bFlash)
      {
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = BaseColor * H2 + (Foreground - BaseColor) * H1;
	  }
      else Canvas.DrawColor = Foreground;
      Canvas.Style = ForegroundStyle;

      Digit = Mid( Str, index, 1 );

      switch( Digit )
      {
        case "0" :
          DigitTexture = texture'DigitZero';
          break;
        case "1" :
          DigitTexture = texture'DigitOne';
          break;
        case "2" :
          DigitTexture = texture'DigitTwo';
          break;
        case "3" :
          DigitTexture = texture'DigitThree';
          break;
        case "4" :
          DigitTexture = texture'DigitFour';
          break;
        case "5" :
          DigitTexture = texture'DigitFive';
          break;
        case "6" :
          DigitTexture = texture'DigitSix';
          break;
        case "7" :
          DigitTexture = texture'DigitSeven';
          break;
        case "8" :
          DigitTexture = texture'DigitEight';
          break;
        case "9" :
          DigitTexture = texture'DigitNine';
          break;
        default:
          DigitTexture = texture'DigitBlank';
          break;
      }
      Canvas.DrawTile( DigitTexture, 24 * Scale, 32 * Scale,
			                 0, 0, 24.0, 32.0);
      index++;
    }
    X += 24 * Scale;
  }

  // Return style to the type before all of the above happen
  Canvas.Style = Style;
}

simulated function DrawStatus( Canvas Canvas )
{
  local float        H1, H2;
  local int          Armor;
  local byte         Style;
  local color        MyColor;
  local texture      DigitTexure;

  local byte         bDisableFunction;

	if( MyStatusScale < 1.0 )
	{
	  Canvas.bNoSmooth = False;
	}
  // Preserve the current style
  Style = Canvas.Style;

  Armor = GetArmorValue( Pawn( Owner ) );

  Canvas.SetPos( Canvas.ClipX - ( 128 * MyStatusScale ), 0 );
  DrawPanel( Canvas, EPanel.PLeft, ERenderStyle.STY_Modulated,
             32, 32, HUDColor, MyOpacity, MyStatusScale );
  DrawPanel( Canvas, EPanel.PMiddle, ERenderStyle.STY_Modulated,
             96, 32, HUDColor, MyOpacity, MyStatusScale );

  if ( PawnOwner.Health < 25 )
  {
    H1 = 1.5 * TutIconBlink;
    H2 = 1 - H1;
    MyColor = BaseColor * H2 + (HUDColor - BaseColor) * H1;
  }
  else
  {
    MyColor = HUDColor;
  }
  Canvas.DrawColor = MyColor;
  Canvas.Style = MySolidStyle;

  Canvas.SetPos( Canvas.ClipX - ( 110 * MyStatusScale ), 0 );
  Canvas.DrawTile( Texture'HealthIcon', 32 * MyStatusScale, 32 * MyStatusScale,
	                 0, 0, 32, 32);


  Canvas.SetPos( Canvas.ClipX - ( 72 * MyStatusScale ), 0 );
  DrawDigits( Canvas,
              Max( 0, Pawn( Owner ).Health ),
              3,
              MyColor,
              HUDBackgroundColor,
              MySolidStyle,
              ERenderStyle.STY_Translucent,
							MyStatusScale);

  Canvas.SetPos( Canvas.ClipX - ( 128 * MyStatusScale ), 34 * MyStatusScale );
  DrawPanel( Canvas, EPanel.PLeft, ERenderStyle.STY_Modulated,
             32, 32, HUDColor, MyOpacity, MyStatusScale );
  DrawPanel( Canvas, EPanel.PMiddle, ERenderStyle.STY_Modulated,
             96, 32, HUDColor, MyOpacity, MyStatusScale );

  if ( Armor < 25 )
  {
    H1 = 1.5 * TutIconBlink;
    H2 = 1 - H1;
    MyColor = BaseColor * H2 + (HUDColor - BaseColor) * H1;
  }
  else
  {
    MyColor= HUDColor;
  }
  Canvas.DrawColor = MyColor;
  Canvas.Style = MySolidStyle;

	Canvas.SetPos( Canvas.ClipX - ( 110 * MyStatusScale ), 34 * MyStatusScale );
  Canvas.DrawTile( Texture'ArmourIcon', 32 * MyStatusScale, 32 * MyStatusScale,
	                 0, 0, 32, 32);

	Canvas.SetPos( Canvas.ClipX - ( 72 * MyStatusScale ), 34 * MyStatusScale );
  DrawDigits( Canvas,
              Max( 0, Armor ),
              3,
              MyColor,
              HUDBackgroundColor,
              MySolidStyle,
              ERenderStyle.STY_Translucent,
							MyStatusScale);

  // Return style to the type before all of the above happen
  Canvas.Style = Style;

  // --- ExtendedHUD code ---


  if( ExtendedHUD != none )
  {
    ExtendedHUD.DrawStatus( bDisableFunction, Canvas );
    if ( bool( bDisableFunction ) )
      return;
  }

	//-------------------------

}

simulated function HUDSetup(canvas canvas)
{
  local int FontSize;

  bResChanged = (Canvas.ClipX != OldClipX);
  OldClipX = Canvas.ClipX;

  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner.ViewTarget == None )
    PawnOwner = PlayerOwner;
  else if ( PlayerOwner.ViewTarget.bIsPawn )
    PawnOwner = Pawn(PlayerOwner.ViewTarget);
  else
    PawnOwner = PlayerOwner;

  // Setup the way we want to draw all HUD elements
  Canvas.Reset();
  Canvas.SpaceX=0;

  FontSize = Min(3, HUDScale * Canvas.ClipX/500);
  Scale = (HUDScale * Canvas.ClipX)/800.0;


  // Make sure message scale is not below zero
  if( MsgScale <= 0.0 )
  {
    MsgScale = 1.0;
    SaveConfig();
  }
  if( MiscMsgScale <= 0.0 )
  {
    MiscMsgScale = 1.0;
    SaveConfig();
  }

  if ( bUseTeamColor && ( PawnOwner.PlayerReplicationInfo != None ) )
  {
    if (PawnOwner.PlayerReplicationInfo.Team < 4)
    	HUDColor = TeamColor[PawnOwner.PlayerReplicationInfo.Team];
    else
		HUDColor = WhiteColor;
    SolidHUDColor = HUDColor;
    if ( Level.bHighDetailMode )
		{
      HUDColor = Opacity * 0.0625 * HUDColor;
	  }
   }
	else
	{
      SolidHUDColor = FavoriteHUDColor * 15.9;
	  HUDColor = SolidHUDColor;
	}

  MyOpacity = Opacity;
	MySolidStyle = ERenderStyle.STY_Normal;
	BaseColor = WhiteColor;
	MyOpacityScale = 1.0;
  if( Opacity < 8 )
  {
    MyOpacityScale = Opacity / 8.0;
		MySolidStyle = ERenderStyle.STY_Translucent;
		HUDColor = SolidHUDColor * MyOpacityScale;
	  BaseColor = WhiteColor * MyOpacityScale;
  }

  bLowRes = ( Canvas.ClipX <= 512 );
	MyHUDScale = Scale;
	if( MyHUDScale < 0.60 )
	{
	  MyHUDScale = 0.60;
	}
	MyWeaponScale = MyHUDScale * WeaponScale;
	if( MyWeaponScale < 0.60 )
	{
	  MyWeaponScale = 0.60;
	}
	MyStatusScale = MyHUDScale * StatusScale;
	if( MyStatusScale < 0.60 )
	{
	  MyStatusScale = 0.60;
	}
}

simulated function PostRender(canvas Canvas)
{
  local float XL, YL, XPos, YPos, FadeValue;
  local string Message;
  local int M, i, j, k, XOverflow, RightMargin;
  local byte bDisableFunction;

  HUDSetup(canvas);

  if (ExtendedHUD != none)
    ExtendedHUD.PostRender(bDisableFunction, Canvas);

  // render the HUD menu
  if (HUDMenu != none)
    HUDMenu.DisplayMenu(Canvas);

  if ( (PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
    return;


  if ( bShowInfo )
  {
    ServerInfo.RenderInfo( Canvas );
    return;
  }

  Canvas.DrawColor = BaseColor;

  if ( PlayerOwner.bShowScores || bForceScores )
  {
    if ( (PlayerOwner.Scoring == None) && (PlayerOwner.ScoringType != None) )
      PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
    if ( PlayerOwner.Scoring != None )
    {
      PlayerOwner.Scoring.OwnerHUD = self;
      PlayerOwner.Scoring.ShowScores(Canvas);
      if ( PlayerOwner.Player.Console.bTyping )
        DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
      return;
    }
  }

  Canvas.Style = MySolidStyle;

  if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) )
  {
    Canvas.DrawColor = BaseColor;
    PawnOwner.Weapon.PostRender(Canvas);
    if ( !PawnOwner.Weapon.bOwnsCrossHair )
      DrawCrossHair(Canvas, 0,0 );
  }

  if ( (PawnOwner != Owner) && PawnOwner.bIsPlayer )
  {
    Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
    Canvas.bCenter = true;
		Canvas.Style = MySolidStyle;
		Canvas.DrawColor = CyanColor * TutIconBlink;
		Canvas.SetPos(4, Canvas.ClipY - 96 * Scale);
		Canvas.DrawText( LiveFeed$PawnOwner.PlayerReplicationInfo.PlayerName, true );
		Canvas.bCenter = false;
		Canvas.DrawColor = BaseColor;
		Canvas.Style = Style;
	}

	if ( bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}
	if ( (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) &&
	     !bHideCenterMessages )
	{
		DisplayProgressMessage(Canvas);
	}

  // Display MOTD
  if ( MOTDFadeOutTime > 0.0 )
	{
		DrawMOTD(Canvas);
	}

	if( !bHideHUD )
	{
		if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator )
		{
			DrawStatus(Canvas);

			if ( !bHideAllWeapons )
			{
				DrawWeaponsAndGrenades(Canvas, RightMargin);
			}
		}

		if ( PawnOwner == PlayerOwner )
		{
			DrawIdentifyInfo(Canvas);
		}

		if ( HUDMutator != None )
		{
			HUDMutator.PostRender(Canvas);
		}

		if ( (PlayerOwner.GameReplicationInfo != None) &&
		     (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) )
		{
			if ( TimeMessageClass == None )
			{
				TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

				if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300) &&
				     (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
				{
					LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
					if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
					{
						bTimeValid = ( bTimeValid ||
						               (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );
						if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
						{
						  TellTime(5);
						}
						else if ( bTimeValid &&
						          PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
						{
							TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
						}
	    		}
					else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
					{
						M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
						TellTime(5 - M);
					}
				}
			}
		}

		if ( PlayerOwner.Player.Console.bTyping )
		{
			DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
		}
  }
  DrawMsgArea( Canvas );
	if( !bLowRes && !bHideCenterMessages )
	{
    DrawEvntMsgArea( Canvas, RightMargin );
  }
  if ( !bHideCenterMessages )
  {
    DrawLocalMsgArea( Canvas );
  }
  if( bShowHUDInfo )
  {
    ShowHUDInfo( Canvas );
  }
}

simulated function DrawWeaponsAndGrenades(Canvas Canvas, out int RightMargin)
{
  local Weapon W, WeaponSlot[11];
  local WFGrenadeItem G, GrenadeSlot[4];
  local inventory Inv;
  local Texture WeaponIcon, GrenadeIcon;
  local int index, weapon_index, grenade_index;
  local float XL, YL, X, Y;
  local color TextColor, IconColor;
  local string GrenadeStatus;
  local byte Style;

  local int LongestWeaponName, LongestGrenadeName;
	local int WeaponStart, WeaponLeftMargin, WeaponIconLength, WeaponRightMargin;
	local int WeaponIconStart, WeaponTextStart, WeaponAreaLength;
	local int GrenadeStart, GrenadeLeftMargin, GrenadeIconLength;
	local int GrenadeRightMargin, GrenadeIconStart;
	local int GrenadeTextStart, GrenadeAreaLength;
  local bool bThrowing;

  LongestWeaponName = 0;
  LongestGrenadeName = 0;

  Canvas.Font = MyFonts.GetSmallFont( 640 * MyWeaponScale );
	Canvas.SetPos( 0, 0 );

	if( MyWeaponScale < 1.0 )
	{
    Canvas.bNoSmooth = False;
	}

  index = 0;
  weapon_index = 0;
  grenade_index = 0;
  for ( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
  {
    if ( Inv.IsA('Weapon') )
    {
      W = Weapon(Inv);
      WeaponSlot[weapon_index] = W;
      Canvas.StrLen( Caps( WeaponSlot[weapon_index].ItemName ), XL, YL);
      if( XL > LongestWeaponName )
      {
        LongestWeaponName = XL;
      }
      weapon_index++;
    }
    if ( Inv.IsA('WFGrenadeItem') )
    {
      G = WFGrenadeItem( Inv );
      GrenadeSlot[grenade_index] = G;
      Canvas.StrLen( Caps( GrenadeSlot[grenade_index].ItemName ), XL, YL);
      if( XL > LongestGrenadeName )
      {
        LongestGrenadeName = XL;
      }
      grenade_index++;
    }
    index++;
    if ( index > 100 )
    {
      break; // can occasionally get temporary loops in netplay
    }
  }

  //Canvas.Font = Canvas.SmallFont;

	WeaponStart = 0;
	WeaponLeftMargin = ( 8 * MyWeaponScale );
	WeaponIconLength  = 0;
	WeaponRightMargin = 0;
	if( bWeaponIcons && !bLowRes )
	{
	  WeaponIconStart  = WeaponStart + WeaponLeftMargin;
	  WeaponIconLength = ( 32 * MyWeaponScale );
	  WeaponRightMargin = ( 8 * MyWeaponScale );
	}
  WeaponTextStart = WeaponStart + WeaponLeftMargin + WeaponIconLength +
	                  WeaponRightMargin;
	WeaponAreaLength = WeaponStart + WeaponLeftMargin + WeaponIconLength +
	                    WeaponRightMargin + LongestWeaponName -
											( 16 * MyWeaponScale );

	GrenadeStart = WeaponAreaLength + ( 48 * MyWeaponScale );
	GrenadeLeftMargin = ( 16 * MyWeaponScale );
	GrenadeIconLength = 0;
	GrenadeRightMargin = 0;
	if( bGrenadeIcons  && !bLowRes )
	{
		GrenadeIconStart =  GrenadeStart + GrenadeLeftMargin;
	  GrenadeIconLength = ( 32 * MyWeaponScale );
		GrenadeRightMargin = ( 8 * MyWeaponScale );
	}
	GrenadeTextStart = GrenadeStart + GrenadeLeftMargin + GrenadeIconLength +
	                   GrenadeRightMargin;
  GrenadeAreaLength = GrenadeIconLength + GrenadeRightMargin +
	                    LongestGrenadeName - ( 16 * MyWeaponScale );

	RightMargin = GrenadeTextStart + LongestGrenadeName + ( 32 * MyWeaponScale );

	Y = Canvas.ClipY - ( 36 * weapon_index * MyWeaponScale );

  for ( index=0; index<weapon_index; index++ )
  {
    if( WeaponSlot[index].ItemName != "" )
    {
      if( PawnOwner.Weapon == WeaponSlot[index] )
      {
        IconColor = BaseColor;
        Style = ERenderStyle.STY_Translucent;
      }
      else
      {
        IconColor = HUDColor;
        Style = ERenderStyle.STY_Modulated;
      }
      // Unscale X since DrawPanel will rescale it
      Canvas.SetPos( WeaponStart, Y);
      DrawPanel( Canvas, EPanel.PMiddle, Style,
			           WeaponAreaLength / MyWeaponScale, 32,
								 HUDColor, MyOpacity, MyWeaponScale );
      DrawPanel( Canvas, EPanel.PRight, Style, 32, 32,
			           HUDColor, MyOpacity, MyWeaponScale );

      if( (WeaponSlot[index].AmmoType == None)
      	  || (WeaponSlot[index].AmmoType.AmmoAmount > 0) )
      {
        TextColor = BaseColor;
      }
      else
      {
        TextColor = GreyColor;
        IconColor = GreyColor;
      }
      Canvas.Style = MySolidStyle;

      if( bWeaponIcons && !bLowRes )
			{
        Canvas.DrawColor = IconColor;
        // my little hack
        WeaponIcon = WeaponSlot[index].StatusIcon;
        if( WeaponSlot[index].ItemName == "Impact Hammer" )
        {
          WeaponIcon = texture'WeaponImpactHammer';
        }
        Canvas.SetPos( WeaponIconStart, Y);
        Canvas.DrawTile( WeaponIcon, 32 * MyWeaponScale , 32 * MyWeaponScale,
                         0, 0, 32.0, 32.0);
			}

      Canvas.DrawColor = TextColor;
      Canvas.SetPos( WeaponTextStart, Y + ( 4 * MyWeaponScale ) );
      Canvas.DrawText( Caps( WeaponSlot[index].ItemName ) );
      if((WeaponSlot[index].AmmoType != None) && (WeaponSlot[index].AmmoType.MaxAmmo > 0))
      {
        Canvas.SetPos( WeaponTextStart, Y + YL + ( 4 * MyWeaponScale ) );
        Canvas.DrawText( Caps( WeaponSlot[index].AmmoType.AmmoAmount$"/"$WeaponSlot[index].AmmoType.MaxAmmo ) );
      }
    }

    Y += ( 36 * MyWeaponScale );
  }

	Y = Canvas.ClipY - ( 36 * grenade_index * MyWeaponScale );

  for( index=0; index<grenade_index; index++ )
  {
    bThrowing = false;
    switch( grenade_index - index )
    {
      case 1 :
        if ((PlayerOwner == PawnOwner) && WFPlayer(PlayerOwner).bGren1)
          bThrowing = true;
        break;
      case 2 :
        if ((PlayerOwner == PawnOwner) && WFPlayer(PlayerOwner).bGren2)
          bThrowing = true;
        break;
      case 3 :
        if ((PlayerOwner == PawnOwner) && WFPlayer(PlayerOwner).bGren3)
          bThrowing = true;
        break;
      case 4 :
        if ((PlayerOwner == PawnOwner) && WFPlayer(PlayerOwner).bGren4)
          bThrowing = true;
        break;
    }

    if( bThrowing )
    {
      Style = ERenderStyle.STY_Translucent;
      IconColor = BaseColor;
      TextColor = BaseColor;
    }
    else if( GrenadeSlot[index].NumCopies < 0 )
    {
      IconColor = GreyColor;
      TextColor = GreyColor;
      Style = ERenderStyle.STY_Modulated;
    }
    else
    {
      Style = ERenderStyle.STY_Modulated;
      TextColor = BaseColor;
      IconColor = HUDColor;
    }

    Canvas.SetPos( GrenadeStart, Y );
    DrawPanel( Canvas, EPanel.PLeft, Style,
               32, 32, HUDColor, MyOpacity, MyWeaponScale );
    // Unscale X since DrawPanel will rescale it
    DrawPanel( Canvas, EPanel.PMiddle, Style,
               ( GrenadeAreaLength / MyWeaponScale ), 32,
							 HUDColor, MyOpacity, MyWeaponScale );
    DrawPanel( Canvas, EPanel.PRight, Style,
               32, 32, HUDColor, MyOpacity, MyWeaponScale );

    Canvas.Style = MySolidStyle;
		if( bGrenadeIcons && !bLowRes )
		{
      if( GrenadeSlot[index].StatusIcon != None )
      {
        Canvas.DrawColor = IconColor;
        Canvas.SetPos( GrenadeIconStart, Y);
        GrenadeIcon = GrenadeSlot[index].StatusIcon;
        Canvas.DrawTile( GrenadeIcon, 32 * MyWeaponScale, 32 * MyWeaponScale,
                         0, 0, 32.0, 32.0);
      }
    }

    Canvas.SetPos( GrenadeTextStart, Y +( 4 * MyWeaponScale ) );
    Canvas.DrawColor = TextColor;
    Canvas.DrawText( Caps( GrenadeSlot[index].ItemName ) );
    Canvas.SetPos( GrenadeTextStart, Y + YL + ( 4 * MyWeaponScale ) );
    Canvas.DrawText( GrenadeSlot[index].NumCopies+1 );

    Y += ( 36 * MyWeaponScale );
  }
}

simulated function bool DrawSpeechArea( Canvas Canvas, float XL, float YL )
{
  local byte Style;
  local int MsgBoxHeight;
	local int NormalClipX, X;
	local float MyMsgOpacityScale;

  Style = Canvas.Style;

	MyMsgOpacityScale = MsgOpacityScale;
	if( bShowHistory )
	{
	  MyMsgOpacityScale = 1.0;
	}

	NormalClipX =   Canvas.ClipX - 32;
  MsgBoxHeight = Canvas.ClipY - 32;

  Canvas.SetPos( XL, YL );
  DrawPanel( Canvas, EPanel.Middle, ERenderStyle.STY_Modulated,
	           NormalClipX, MsgBoxHeight,
						 HUDColor, MyOpacity * MyMsgOpacityScale, MyHUDScale, True );
  DrawPanel( Canvas, EPanel.Right, ERenderStyle.STY_Modulated, 32,
	           MsgBoxHeight, HUDColor, MyOpacity * MyMsgOpacityScale,
						 MyHUDScale, True );
  Canvas.SetPos( XL, MsgBoxHeight );
  DrawPanel( Canvas, EPanel.Bottom, ERenderStyle.STY_Modulated,
	           NormalClipX, 32,
						 HUDColor, MyOpacity * MyMsgOpacityScale, MyHUDScale, True );
  DrawPanel( Canvas, EPanel.BottomRight, ERenderStyle.STY_Modulated,
             32, 32,
             HUDColor, MyOpacity * MyMsgOpacityScale, MyHUDScale, True );

  // Return style to the type before all of the above happen
  Canvas.Style = Style;

}

simulated function DrawLocalMsgArea( Canvas Canvas )
{
  local int i, NumberOfLines, CharPerLine,X,Y,XL,YL;
  local float FadeValue;
  local float TXL, TYL;
  local int MessageLength;
  local int YPos;

  for (i=0; i<MaxNumOfLocalMsgs; i++)
  {
    if (LocalMessages[i].Message != None)
    {
      if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
      {
        Canvas.Style = ERenderStyle.STY_Translucent;
        FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
        if (FadeValue > 0.0)
        {
          if ( bResChanged || (LocalMessages[i].XL == 0) )
          {
            if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
              LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
            else // ==2
              LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
            Canvas.Font = LocalMessages[i].StringFont;
            Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
            LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
          }
          Canvas.Font = LocalMessages[i].StringFont;
          Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
          Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
          Canvas.DrawText( LocalMessages[i].StringMessage, False );
        }
      }
      else
      {
        if ( bResChanged || (LocalMessages[i].XL == 0) )
        {
          if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
            LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
          else // == 2
            LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
          Canvas.Font = LocalMessages[i].StringFont;
          Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
          LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
        }
        Canvas.Font = LocalMessages[i].StringFont;
        Canvas.Style = MySolidStyle;
        Canvas.DrawColor = LocalMessages[i].DrawColor;
        Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
        Canvas.DrawText( LocalMessages[i].StringMessage, False );
      }
    }
  }
}

simulated function DrawMsgArea( Canvas Canvas )
{
  local int i, NumberOfLines, CharPerLine, X, Y;
  local float XL, YL;
  local float OneXL, OneYL;
  local float FadeValue;
  local int MessageLength;
  local int YPos;
  local int OldClipX, OldClipY;

  local int AreaClipX, AreaClipY, MsgClipX, MsgClipY;
  local int AreaOriginX, AreaOriginY, MsgOriginX, MsgOriginY;
	local int NumOfMsgPerScale;

	if( ( MessageFadeTime == 0.0) && !bShowHistory )
	{
	  return;
	}

  OldClipX = Canvas.ClipX;
  OldClipY = Canvas.ClipY;

  Canvas.Font = MyFonts.GetSmallFont( 600 * MyHUDScale * MsgScale );
  Canvas.StrLen("0", OneXL, OneYL);

  AreaClipX = Canvas.ClipX - ( 192 * MyStatusScale );

  MsgOriginX = OneXL * 5; //indent 5 letter for start of messageA
  MsgOriginY = 0;
  MsgClipX = AreaClipX - ( OneXL * 10 ); //round off 5 letters before end of area
  MsgClipY = Canvas.ClipY; // This clip can be as large as it needs, only
                           // used for find the height of the text latter.

  if( !bShowHistory )
  {
    AreaClipY = ( OneYL * 2 + 3 ) * 4  + ( 8 * MyHUDScale );
  }
  else
  {
    AreaClipY = ( OneYL * 2 + 3 ) * ShowNumOfMsgs + ( 8 * MyHUDScale );
  }

  AreaOriginX = 0;
  AreaOriginY = 0;
  Canvas.SetOrigin( AreaOriginX, AreaOriginY );
  Canvas.SetClip( AreaClipX, AreaClipY );

  if ( !PlayerOwner.bShowScores &&
       !bForceScores &&
       !PawnOwner.PlayerReplicationInfo.bIsSpectator &&
			 ( bShowHistory || MsgOpacityScale > 0.0 ) )
  {
    Canvas.SetOrigin( 0, 0 );
    DrawSpeechArea( Canvas, 0, 0 );
  }

  YPos = AreaClipY - ( 8 * MyHUDScale );

  for( i=0; i< MaxNumOfMsgs; i++ )
  {
    if ( ShortMessageQueue[i].Message != None )
    {
      if ( bResChanged ||
           ( ShortMessageQueue[i].XL == 0 ) ||
           bMsgScaleChanged )
      {
        Canvas.SetOrigin( MsgOriginX, MsgOriginY );
        Canvas.SetClip( MsgClipX, MsgClipY );
        Canvas.SetPos( 0, 0);
        Canvas.StrLen( ShortMessageQueue[i].Message.Static.AssembleString(
                       self,
                       ShortMessageQueue[i].Switch,
                       ShortMessageQueue[i].RelatedPRI,
                       ShortMessageQueue[i].StringMessage ), XL, YL );

        ShortMessageQueue[i].XL = MsgClipX;
        ShortMessageQueue[i].YL = YL;
      }
      YPos -= ( ShortMessageQueue[i].YL + OneYL + 2 );
      if ( YPos < AreaOriginY )
      {
        break;
      }
      Canvas.SetOrigin( AreaOriginX, AreaOriginY );
      Canvas.SetClip( AreaClipX, AreaClipY );
      Canvas.SetPos( AreaOriginX, YPos);

      ShortMessageQueue[i].Message.Static.RenderComplexMessage(
          Canvas,
          ShortMessageQueue[i].XL,
          ShortMessageQueue[i].YL,
          ShortMessageQueue[i].StringMessage,
          ShortMessageQueue[i].Switch,
          ShortMessageQueue[i].RelatedPRI,
          None,
          ShortMessageQueue[i].OptionalObject
          );
    }
  }
  Canvas.SetOrigin( 0, 0 );
  Canvas.SetClip( OldClipX, OldClipY );
  bMsgScaleChanged = false;
}


simulated function DrawEvntMsgArea( Canvas Canvas, int RightMargin )
{
  local int index;
  local float XL, YL, TextFade;
  local int MessageLength, ScoreWidth;
  local int YPos;
  local int OldClipX, OldClipy;
	local int MsgClipX, MsgClipY;
	local int MsgOriginX, MsgOriginY;

  if( bHideHUD )
  {
    return;
  }

  OldClipX = Canvas.ClipX;
  OldClipY = Canvas.ClipY;

  Canvas.Font = MyFonts.GetSmallFont( 640 * MyHUDScale );
  Canvas.StrLen("0", XL, YL);

	ScoreWidth = ( XL * 14 ) + ( 32 * MyHUDScale );

  Canvas.Font = MyFonts.GetSmallFont( 512 * MyHUDScale * MiscMsgScale );
  Canvas.StrLen("T", XL, YL);

	MsgOriginX = RightMargin + ( 16 * MyHUDScale );
	MsgOriginY = OldClipY - ( YL * ShowNumOfEvntMsgs );

	MsgClipX = OldClipX - ScoreWidth - MsgOriginX;
	MsgClipY = OldClipY - MsgOriginY;

  if( MsgClipX < 50 )
  {
    return;
  }

  Canvas.SetOrigin( MsgOriginX, MsgOriginY );
  Canvas.SetClip( MsgClipX, MsgClipY );

  YPos = 0;

  TextFade = 1;
  for( index=0; index < MaxNumOfEvntMsgs; index++ )
  {
    if ( EvntMessageQueue[index].Message != None )
    {
      Canvas.SetPos( 0, 0);
	    if( EvntMessageQueue[index].Message.Default.bComplexString )
		  {
        Canvas.StrLen( EvntMessageQueue[index].Message.Static.AssembleString(
                       self,
                       EvntMessageQueue[index].Switch,
                       EvntMessageQueue[index].RelatedPRI,
                       EvntMessageQueue[index].StringMessage ), XL, YL );
          EvntMessageQueue[index].XL = XL;
          EvntMessageQueue[index].YL = YL;
		  }
		  else
		  {
        Canvas.StrLen( EvntMessageQueue[index].StringMessage, XL, YL );
        EvntMessageQueue[index].XL = XL;
        EvntMessageQueue[index].YL = YL;
			}
      Canvas.SetPos( 0, YPos);
      YPos +=  EvntMessageQueue[index]. YL;
      if( YPos > MsgClipY )
      {
        break;
      }
      Canvas.DrawColor = BaseColor * TextFade;
      TextFade -= 1.0 / ShowNumOfEvntMsgs;
      if ( EvntMessageQueue[index].Message.Default.bComplexString )
      {

        EvntMessageQueue[index].Message.Static.RenderComplexMessage(
                       Canvas,
                       EvntMessageQueue[index].XL,
                       EvntMessageQueue[index].YL,
                       EvntMessageQueue[index].StringMessage,
                       EvntMessageQueue[index].Switch,
                       EvntMessageQueue[index].RelatedPRI,
                       None,
                       EvntMessageQueue[index].OptionalObject );
      }
			else
			{
        Canvas.DrawText(EvntMessageQueue[index].StringMessage, False);
			}
    }
  }
  Canvas.SetClip( OldClipX, OldClipY );
  Canvas.SetOrigin( 0, 0);
}

simulated function EvntMessage( PlayerReplicationInfo PRI,
                                 coerce string Msg,
                                 name MsgType )
{
  local int index;
  local Class<LocalMessage> MessageClass;
  local int LastEvntMsgIndex;

  LastEvntMsgIndex = MaxNumOfEvntMsgs - 1;

  MessageClass = class'RedSayMessagePlus';

  for( index = LastEvntMsgIndex; index >= 0; index--)
  {
    if ( EvntMessageQueue[index].Message == None )
    {
      // Add the message here.
      EvntMessageQueue[index].Message = MessageClass;
      EvntMessageQueue[index].Switch = 0;
      EvntMessageQueue[index].RelatedPRI = PRI;
      EvntMessageQueue[index].OptionalObject = None;
      EvntMessageQueue[index].DrawColor = HUDColor;
      EvntMessageQueue[index].EndOfLife = MessageClass.Default.Lifetime +
                                           Level.TimeSeconds;
      if ( MessageClass.Default.bComplexString )
      {
        EvntMessageQueue[index].StringMessage = Msg;
      }
      else
      {
        EvntMessageQueue[index].StringMessage =
          MessageClass.Static.AssembleString(self,0,PRI,Msg);
      }
      return;
    }
  }

  // No empty slots.  Force a message out.
  for( index =  LastEvntMsgIndex - 1; index >= 0;  index-- )
  {
    CopyMessage( EvntMessageQueue[index+1], EvntMessageQueue[index] );
  }

  EvntMessageQueue[0].Message = MessageClass;
  EvntMessageQueue[0].Switch = 0;
  EvntMessageQueue[0].RelatedPRI = PRI;
  EvntMessageQueue[0].OptionalObject = None;
  EvntMessageQueue[0].EndOfLife =
    MessageClass.Default.Lifetime + Level.TimeSeconds;
   if ( MessageClass.Default.bComplexString )
   {
     EvntMessageQueue[0].StringMessage = Msg;
   }
   else
   {
     EvntMessageQueue[0].StringMessage =
       MessageClass.Static.AssembleString( self, 0, PRI,Msg );
   }
}

simulated function Message( PlayerReplicationInfo PRI,
                            coerce string Msg,
                            name MsgType )
{
  local int index;
  local Class<LocalMessage> MessageClass;
  local int LastMsgIndex;

  LastMsgIndex = MaxNumOfMsgs - 1;

  switch (MsgType)
  {
    case 'Say':
      MessageClass = class'WFCustomSayMessagePlus';
      break;
    case 'TeamSay':
      MessageClass = class'WFCustomTeamSayMessagePlus';
      break;
    case 'CriticalEvnt':
      MessageClass = class'CriticalStringPlus';
      LocalizedMessage( MessageClass, 0, None, None, None, Msg );
      return;
    case 'DeathMessage':
    case 'Pickup':
    default:
      MessageClass = class'RedSayMessagePlus';
      EvntMessage( PRI, Msg, MsgType );
      return;
  }

  for( index = LastMsgIndex; index >= 0 ; index--)
  {
    if ( ShortMessageQueue[index].Message == None )
    {
      // Add the message here.
      ShortMessageQueue[index].Message = MessageClass;
      ShortMessageQueue[index].Switch = 0;
      ShortMessageQueue[index].RelatedPRI = PRI;
      ShortMessageQueue[index].OptionalObject = None;
      ShortMessageQueue[index].EndOfLife = MessageClass.Default.Lifetime +
                                           Level.TimeSeconds;
      if ( MessageClass.Default.bComplexString )
      {
        ShortMessageQueue[index].StringMessage = Msg;
      }
      else
      {
        ShortMessageQueue[index].StringMessage =
          MessageClass.Static.AssembleString(self,0,PRI,Msg);
      }
			MessageFadeTime += 6.0;
      return;
    }
  }

  // No empty slots.  Force a message out.
  for( index =  LastMsgIndex - 1; index >= 0;  index-- )
  {
    CopyMessage( ShortMessageQueue[index+1], ShortMessageQueue[index] );
  }

	MessageFadeTime += 6.0;
  ShortMessageQueue[0].Message = MessageClass;
  ShortMessageQueue[0].Switch = 0;
  ShortMessageQueue[0].RelatedPRI = PRI;
  ShortMessageQueue[0].OptionalObject = None;
  ShortMessageQueue[0].EndOfLife = MessageClass.Default.Lifetime +
                                   Level.TimeSeconds;
  if ( MessageClass.Default.bComplexString )
  {
    ShortMessageQueue[0].StringMessage = Msg;
  }
  else
  {
    ShortMessageQueue[0].StringMessage =
      MessageClass.Static.AssembleString( self, 0, PRI,Msg );
  }
}

simulated function LocalizedMessage( class<LocalMessage> Message,
                                     optional int Switch,
                                     optional PlayerReplicationInfo RelatedPRI_1,
                                     optional PlayerReplicationInfo RelatedPRI_2,
                                     optional Object OptionalObject,
                                     optional String CriticalString )
{
  local int index;
  local int LastEvntMsgIndex;
  local int LastLocalMsgIndex;

  if ( ClassIsChildOf( Message, class'PickupMessagePlus' ) )
  {
    Message = class'WFPickupMessagePlus';
    PickupTime = Level.TimeSeconds;
  }

  if ( !Message.Default.bIsSpecial )
  {
    LastEvntMsgIndex = MaxNumOfEvntMsgs - 1;

    // Find an empty slot.
    for( index = 0; index < MaxNumOfEvntMsgs; index++)
    {
      if ( EvntMessageQueue[index].Message == None )
      {
        EvntMessageQueue[index].Message = Message;
        EvntMessageQueue[index].Switch = Switch;
        EvntMessageQueue[index].RelatedPRI = RelatedPRI_1;
        EvntMessageQueue[index].OptionalObject = OptionalObject;
        EvntMessageQueue[index].EndOfLife = Message.Default.Lifetime +
                                             Level.TimeSeconds;
        if ( Message.Default.bComplexString )
         {
          EvntMessageQueue[index].StringMessage = CriticalString;
        }
        else
        {
          EvntMessageQueue[index].StringMessage =
            Message.Static.GetString( Switch,
                                      RelatedPRI_1,
                                      RelatedPRI_2,
                                      OptionalObject );
        }
        return;
      }
    }

    // No empty slots.  Force a message out.
    for( index =  LastEvntMsgIndex - 1; index >= 0;  index-- )
    {
      CopyMessage( EvntMessageQueue[index+1], EvntMessageQueue[index] );
    }

    EvntMessageQueue[0].Message = Message;
    EvntMessageQueue[0].Switch = Switch;
    EvntMessageQueue[0].RelatedPRI = RelatedPRI_1;
    EvntMessageQueue[0].OptionalObject = OptionalObject;
    EvntMessageQueue[0].EndOfLife = Message.Default.Lifetime +
                                    Level.TimeSeconds;
    if ( Message.Default.bComplexString )
    {
      EvntMessageQueue[0].StringMessage = CriticalString;
    }
    else
    {
      EvntMessageQueue[0].StringMessage =
        Message.Static.GetString( Switch,
                                  RelatedPRI_1,
                                  RelatedPRI_2,
                                  OptionalObject );
    }
  }
  else
  {
    LastLocalMsgIndex = MaxNumOfLocalMsgs - 1;

    if( CriticalString == "" )
    {
      CriticalString = Message.Static.GetString( Switch,
                                                 RelatedPRI_1,
                                                 RelatedPRI_2,
                                                 OptionalObject );
    }
    if( Message.Default.bIsUnique )
    {
      for( index = 0; index < MaxNumOfLocalMsgs; index++ )
      {
        if( LocalMessages[index].Message != None )
        {
          if( ( LocalMessages[index].Message == Message ) ||
              ( LocalMessages[index].Message.Static.GetOffset(

              LocalMessages[index].Switch,
              24,
              640 ) == Message.Static.GetOffset( Switch, 24, 640 ) ) )
          {
            LocalMessages[index].Message = Message;
            LocalMessages[index].Switch = Switch;
            LocalMessages[index].RelatedPRI = RelatedPRI_1;
            LocalMessages[index].OptionalObject = OptionalObject;
            LocalMessages[index].LifeTime = Message.Default.Lifetime;
            LocalMessages[index].EndOfLife = Message.Default.Lifetime +
                                             Level.TimeSeconds;
            LocalMessages[index].StringMessage = CriticalString;
            LocalMessages[index].DrawColor =
              Message.Static.GetColor( Switch, RelatedPRI_1, RelatedPRI_2 );
            LocalMessages[index].XL = 0;
            return;
          }
        }
      }
    }
    for( index = 0; index < MaxNumOfLocalMsgs; index++ )
    {
      if (LocalMessages[index].Message == None)
      {
        LocalMessages[index].Message = Message;
        LocalMessages[index].Switch = Switch;
        LocalMessages[index].RelatedPRI = RelatedPRI_1;
        LocalMessages[index].OptionalObject = OptionalObject;
        LocalMessages[index].EndOfLife = Message.Default.Lifetime +
                                         Level.TimeSeconds;
        LocalMessages[index].StringMessage = CriticalString;
        LocalMessages[index].DrawColor =
          Message.Static.GetColor( Switch, RelatedPRI_1, RelatedPRI_2 );
        LocalMessages[index].LifeTime = Message.Default.Lifetime;
        LocalMessages[index].XL = 0;
        return;
      }
    }
    // No empty slots.  Force a message out.
    for( index=0; index < LastLocalMsgIndex; index++ )
    {
      CopyMessage( LocalMessages[index], LocalMessages[index+1] );
    }

    LocalMessages[LastLocalMsgIndex].Message = Message;
    LocalMessages[LastLocalMsgIndex].Switch = Switch;
    LocalMessages[LastLocalMsgIndex].RelatedPRI = RelatedPRI_1;
    LocalMessages[LastLocalMsgIndex].OptionalObject = OptionalObject;
    LocalMessages[LastLocalMsgIndex].EndOfLife = Message.Default.Lifetime +
                                                 Level.TimeSeconds;
    LocalMessages[LastLocalMsgIndex].StringMessage = CriticalString;
    LocalMessages[LastLocalMsgIndex].DrawColor =
      Message.Static.GetColor( Switch, RelatedPRI_1, RelatedPRI_2 );
    LocalMessages[LastLocalMsgIndex].LifeTime = Message.Default.Lifetime;
    LocalMessages[LastLocalMsgIndex].XL = 0;
    return;
  }
}

simulated function Tick(float DeltaTime)
{
  local int i;

  Super.Tick(DeltaTime);

  IdentifyFadeTime = FMax(0.0, IdentifyFadeTime - DeltaTime);
  MOTDFadeOutTime = FMax(0.0, MOTDFadeOutTime - DeltaTime * 55);

  TutIconBlink += DeltaTime;
  if (TutIconBlink >= 0.5)
    TutIconBlink = 0.0;

  if ( bDrawMessageArea )
  {
	  if( MessageFadeTime > 24.0 )
		{
		  MessageFadeTime = 24.0;
		}
	  if( MessageFadeTime > 0.0 )
		{
	    MessageFadeTime -= DeltaTime;
		  if( MessageFadeTime < 2.0 )
		  {
		    MsgOpacityScale = MessageFadeTime / 2.0;
		  }
			else
			{
			  MsgOpacityScale = 1.0;
			}

		}
  }
}

simulated function Timer()
{
  local int i, j;
  local int LastLocalMsg;

  LastLocalMsg = MaxNumOfLocalMsgs - 1;

  // Age all localized messages.
  for (i=0; i<MaxNumOfLocalMsgs; i++)
  {
    // Purge expired messages.
    if ( (LocalMessages[i].Message != None) && (Level.TimeSeconds >= LocalMessages[i].EndOfLife) )
      ClearMessage(LocalMessages[i]);
  }

  // Clean empty slots.
  for (i=0; i< LastLocalMsg; i++)
  {
    if ( LocalMessages[i].Message == None )
    {
      CopyMessage(LocalMessages[i],LocalMessages[i+1]);
      ClearMessage(LocalMessages[i+1]);
    }
  }
  bCursor = !bCursor;
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
  local string TypingPrompt;
  local float XL, YL;
  local float XL2, YL2;
  local float YOffset, XOffset, NewClipX, NewClipY;
  local float OldClipX, OldClipY, OldOrgX, OldOrgY;
	local int MyHeightPerMessage;
  local float MyScale, TextScale;
  local int CursorLocation;

  OldClipX = Canvas.ClipX;
  OldClipY = Canvas.ClipY;
  OldOrgX = Canvas.OrgX;
  OldOrgY = Canvas.OrgY;

  MyScale = MyHUDScale;
  if( MyScale < 1.0 )
  {
    MyScale = 1.0;
  }

  Canvas.Font = MyFonts.GetSmallFont( 600 * MyHUDScale * MsgScale );
  Canvas.StrLen("T", XL, YL);
	MyHeightPerMessage = YL * 2 + 3;

  XOffset = 0;
  NewClipX = Canvas.ClipX - ( 192 * MyStatusScale );
  if( bShowHistory == false )
  {
    YOffset = ( DefaultNumOfMsgs * MyHeightPerMessage ) + ( 32 * MyHUDScale );
  }
  else
  {
    YOffset = ( ShowNumOfMsgs * MyHeightPerMessage ) + ( 32 * MyHUDScale );
    if( YOffset > ( OldClipY * 0.75 ) )
    {
      bShowHistory = false;
      YOffset = ( DefaultNumOfMsgs * MyHeightPerMessage ) + ( 32 * MyHUDScale );
    }
  }
  TypingPrompt = Console.TypedStr;

  Canvas.SetOrigin(XOffset, YOffset);
  Canvas.SetClip( NewClipX, Canvas.ClipY );

  Canvas.Font = MyFonts.GetMediumFont( Canvas.ClipX * MyScale );
  Canvas.StrLen( "T", XL, YL );
  Canvas.StrLen( ">>>"$TypingPrompt$"_", XL2, YL2 );
  TextScale = YL2 / YL;

  NewClipY = 32 * MyScale + ( YL2 - YL );
  Canvas.SetClip( NewClipX, NewClipY );
  Canvas.SetPos( 0, 0 );
  DrawPanel( Canvas, EPanel.PMiddle, ERenderStyle.STY_Modulated,
             int( ( Canvas.ClipX - 32 ) / MyScale ),
             32 + ( YL2 - YL ) / MyScale,
						 HUDColor, MyOpacity, MyScale );
  DrawPanel( Canvas, EPanel.PRight, ERenderStyle.STY_Modulated,
             32, 32 + ( YL2 - YL ) / MyScale, HUDColor, MyOpacity, MyScale );

  Canvas.SetPos( 0, ( NewClipY / 2 ) - ( YL2 / 2 ) );
  Canvas.DrawColor = BaseColor;
  Canvas.DrawText( ">>>", false );

  Canvas.SetPos( Canvas.CurX, ( NewClipY / 2 ) - ( YL2 / 2 ) );
  Canvas.DrawColor = HUDColor;
  Canvas.DrawText( TypingPrompt, false );

  if( bCursor )
  {
    Canvas.DrawColor = BaseColor;
    Canvas.SetPos( Canvas.CurX, ( NewClipY / 2 ) - ( YL2 / 2 ) + (YL2 - YL) );
    Canvas.DrawText( "_", false );
  }

  Canvas.SetOrigin( OldOrgX, OldOrgY );
  Canvas.SetClip( OldClipX, OldClipY );
}

exec function GrowHUD()
{
  if ( bHideHUD )
    bHideHud = false;
  else if ( bHideAmmo )
    bHideAmmo = false;
  else if ( bHideFrags )
    bHideFrags = false;
  else if ( bHideTeamInfo )
    bHideTeamInfo = false;
  else if ( bHideAllWeapons )
    bHideAllWeapons = false;
  else if ( bHideStatus )
    bHideStatus = false;
  else
    WeaponScale = 1.0;

  SaveConfig();
}

exec function ShrinkHUD()
{
  if ( !bLowRes && (WeaponScale * HUDScale > 0.8) )
    WeaponScale = 0.8/HUDScale;
  else if ( !bHideStatus )
    bHideStatus = true;
  else if ( !bHideAllWeapons )
    bHideAllWeapons = true;
  else if ( !bHideTeamInfo )
    bHideTeamInfo = true;
  else if ( !bHideFrags )
    bHideFrags = true;
  else if ( !bHideAmmo )
    bHideAmmo = true;
  else
    bHideHud = true;

  SaveConfig();
}

defaultproperties
{
     HUDBackgroundColor=(R=32,G=32,B=32)
     GreyColor=(R=64,G=64,B=64)
     bWeaponIcons=True
     bGrenadeIcons=True
     MaxNumOfMsgs=25
     MaxNumOfLocalMsgs=10
     MaxNumOfEvntMsgs=10
     DefaultNumOfMsgs=4
     MyHUDScale=1.000000
     MsgOpacityScale=1.000000
     ModulatedMsgTexture(0)=Texture'WFMedia.ModulatedPanelOne'
     ModulatedMsgTexture(1)=Texture'WFMedia.ModulatedPanelTwo'
     ModulatedMsgTexture(2)=Texture'WFMedia.ModulatedPanelThree'
     NormalMsgTexture(0)=Texture'WFMedia.NormalPanelOne'
     NormalMsgTexture(1)=Texture'WFMedia.NormalPanelTwo'
     NormalMsgTexture(2)=Texture'WFMedia.NormalPanelThree'
     MinNumOfMsgs=1
     MinNumOfEvntMsgs=1
     ShowNumOfMsgs=4
     ShowNumOfEvntMsgs=6
     MsgScale=1.000000
     MiscMsgScale=1.000000
     ExtendedHUDClass=Class'WFCode.WFCustomHUDInfo'
}
