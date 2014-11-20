//=============================================================================
// WFHUDInfo.
//=============================================================================
class WFHUDInfo extends WFS_HUDInfo;

var CTFFlag MyFlag;
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

simulated function PostRender( out byte bDisableFunction, canvas Canvas )
{
	local int X, Y, i;
	local CTFFlag Flag;
	local bool bAlt;

	Super.PostRender( bDisableFunction, Canvas );

	if ( (OwnerHUD.PlayerOwner == None) || (OwnerHUD.PawnOwner == None) || (OwnerHUD.PlayerOwner.GameReplicationInfo == None)
		|| ((OwnerHUD.PlayerOwner.bShowMenu || OwnerHUD.PlayerOwner.bShowScores) && (Canvas.ClipX < 640)) )
		return;

	Canvas.Style = Style;
	if( !OwnerHUD.bHideHUD && !OwnerHUD.bHideTeamInfo )
	{
		X = Canvas.ClipX - 70 * OwnerHUD.Scale;
		Y = Canvas.ClipY - 350 * OwnerHUD.Scale;

		for ( i=0; i<4; i++ )
		{
			Flag = CTFReplicationInfo(OwnerHUD.PlayerOwner.GameReplicationInfo).FlagList[i];
			if ( Flag != None )
			{
				Canvas.DrawColor = OwnerHUD.TeamColor[Flag.Team];
				Canvas.SetPos(X,Y);

				if ((OwnerHUD.PawnOwner != None) && (Flag.Team == OwnerHUD.PawnOwner.PlayerReplicationInfo.Team))
					MyFlag = Flag;
				if ( Flag.bHome )
					Canvas.DrawIcon(texture'I_Home', OwnerHUD.Scale * 2);
				else if ( Flag.bHeld && WFFlag(Flag).bReturning ) // flag is being returned
					Canvas.DrawIcon(texture'I_Returning', OwnerHUD.Scale * 2);
				else if ( Flag.bHeld )
					Canvas.DrawIcon(texture'I_Capt', OwnerHUD.Scale * 2);
				else
					Canvas.DrawIcon(texture'I_Down', OwnerHUD.Scale * 2);
			}
			Y -= 150 * OwnerHUD.Scale;
		}
	}
}

simulated function DrawTeam(out byte bDisableFunction, Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	bDisableFunction = 1;
	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.DrawColor = OwnerHUD.TeamColor[TI.TeamIndex];
		OwnerHUD.DrawBigNum(Canvas, int(TI.Score), Canvas.ClipX - 144 * OwnerHUD.Scale, Canvas.ClipY - 336 * OwnerHUD.Scale - (150 * OwnerHUD.Scale * TI.TeamIndex), 1);
	}
}

function DLog(coerce string S)
{
	if ((Level.TimeSeconds - LastLog) > 0.5)
		Log(S);
}

defaultproperties
{
     ServerInfoClass=Class'Botpack.ServerInfoCTF'
}
