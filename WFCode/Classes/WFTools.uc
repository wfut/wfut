class WFTools extends Info;

// don't instantiate, just call functions statically
// eg. class'WFTools'.static.SetMiscScore(PRI, 0, 1);

// gets value of specified misc score array
static function int GetMiscScore(PlayerReplicationInfo PRI, int Index)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;

	WFPRI = WF_PRI(PRI);
	if (WFPRI != None)
		return WFPRI.MiscScoreArray[Index];
	else
	{
		WFBotPRI = WF_BotPRI(PRI);
		if (WFBotPRI != None)
			return WFBotPRI.MiscScoreArray[Index];
	}

	// doh, wasn't a valid PRI
	return 0;
}

// sets value of specified misc score array
static function SetMiscScore(PlayerReplicationInfo PRI, int Index, int Value)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;

	WFPRI = WF_PRI(PRI);
	if (WFPRI != None)
		WFPRI.MiscScoreArray[Index] = Value;
	else
	{
		WFBotPRI = WF_BotPRI(PRI);
		if (WFBotPRI != None)
			WFBotPRI.MiscScoreArray[Index] = Value;
	}
}

// adds value to specified misc score array
static function AdjustMiscScore(PlayerReplicationInfo PRI, int Index, int Value)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;

	WFPRI = WF_PRI(PRI);
	if (WFPRI != None)
		WFPRI.MiscScoreArray[Index] += Value;
	else
	{
		WFBotPRI = WF_BotPRI(PRI);
		if (WFBotPRI != None)
			WFBotPRI.MiscScoreArray[Index] += Value;
	}
}

// gets the flag holder's PRI for the specified flag
static function PlayerReplicationInfo GetHolderPRIForFlag(CTFFlag aFlag)
{
	local PlayerReplicationInfo PRI;

	if (aFlag == None)
		return None;

	PRI = None;
	foreach aFlag.allactors(class'PlayerReplicationInfo', PRI)
		if ((PRI != None) && (PRI.HasFlag == aFlag))
			break;

	return PRI;
}

// returns scaling coefs relative to 1024x768
static function GetScalingCoefs(Canvas C, out float ScaleX, out float ScaleY)
{
	ScaleX = (C.SizeX+1)/1024.0;
	ScaleY = (C.SizeY+1)/768.0;
}

defaultproperties
{
}
