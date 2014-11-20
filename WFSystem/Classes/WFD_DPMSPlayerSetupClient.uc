//=============================================================================
// WFD_DPMSPlayerSetupClient.
// Used to set up DPMS player skins and meshes properly.
//=============================================================================
class WFD_DPMSPlayerSetupClient extends UTPlayerSetupClient;

function Created()
{
	super.Created();
	if (GetPlayerOwner().IsA('WFD_DPMSPlayer'))
		NewPlayerClass = WFD_DPMSPlayer(GetPlayerOwner()).MeshInfo.default.DefaultClass;
}

function LoadCurrent()
{
	local string Voice, OverrideClassName;
	local class<PlayerPawn> OverrideClass;
	local string SN, FN;

	Voice = "";
	NameEdit.SetValue(GetPlayerOwner().PlayerReplicationInfo.PlayerName);
	TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(string(GetPlayerOwner().PlayerReplicationInfo.Team)), 0));
	if(GetLevel().Game != None && GetLevel().Game.IsA('UTIntro') || GetPlayerOwner().IsA('Commander') || GetPlayerOwner().IsA('Spectator'))
	{
		SN = GetPlayerOwner().GetDefaultURL("Skin");
		FN = GetPlayerOwner().GetDefaultURL("Face");
		ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(GetPlayerOwner().GetDefaultURL("Class"), True), 0));
		Voice = GetPlayerOwner().GetDefaultURL("Voice");
	}
	else
	{
		if (GetPlayerOwner().IsA('WFD_DPMSPlayer'))
			ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(string(WFD_DPMSPlayer(GetPlayerOwner()).MeshInfo.default.DefaultClass), True), 0));
		else
			ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(string(GetPlayerOwner().Class), True), 0));
		GetPlayerOwner().static.GetMultiSkin(GetPlayerOwner(), SN, FN);
	}
	SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(SN, True), 0));
	FaceCombo.SetSelectedIndex(Max(FaceCombo.FindItemIndex2(FN, True), 0));

	if(Voice == "")
		Voice = string(GetPlayerOwner().PlayerReplicationInfo.VoiceType);

	IterateVoices();
	VoicePackCombo.SetSelectedIndex(Max(VoicePackCombo.FindItemIndex2(Voice, True), 0));

	OverrideClassName = GetPlayerOwner().GetDefaultURL("OverrideClass");
	if(OverrideClassName != "")
		OverrideClass = class<PlayerPawn>(DynamicLoadObject(OverrideClassName, class'Class'));

	SpectatorCheck.bChecked = (OverrideClass != None && ClassIsChildOf(OverrideClass, class'CHSpectator'));
/*	CommanderCheck.bChecked = (OverrideClass != None && ClassIsChildOf(OverrideClass, class'Commander'));*/
}

function UseSelected()
{
	local int NewTeam;
	local class<playerpawn> playerclass;

	if (Initialized)
	{
		GetPlayerOwner().UpdateURL("Class", ClassCombo.GetValue2(), True);
		GetPlayerOwner().UpdateURL("Skin", SkinCombo.GetValue2(), True);
		GetPlayerOwner().UpdateURL("Face", FaceCombo.GetValue2(), True);
		GetPlayerOwner().UpdateURL("Team", TeamCombo.GetValue2(), True);

		NewTeam = Int(TeamCombo.GetValue2());

		PlayerClass = class<PlayerPawn>(DynamicLoadObject(ClassCombo.GetValue2(), class'Class'));
		if ((PlayerClass != none) && (PlayerClass.default.Mesh != GetPlayerOwner().Mesh))
		{
			if (GetPlayerOwner().IsA('WFD_DPMSPlayer'))
			{
				WFD_DPMSPlayer(GetPlayerOwner()).ServerChangeMeshClass(PlayerClass);
				GetPlayerOwner().ServerChangeSkin(SkinCombo.GetValue2(), FaceCombo.GetValue2(), NewTeam);
			}
		}
		else if ( (PlayerClass != none) && (PlayerClass.default.Mesh == GetPlayerOwner().Mesh) )
			GetPlayerOwner().ServerChangeSkin(SkinCombo.GetValue2(), FaceCombo.GetValue2(), NewTeam);

		if( GetPlayerOwner().PlayerReplicationInfo.Team != NewTeam )
			GetPlayerOwner().ChangeTeam(NewTeam);
	}

	MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	NewPlayerClass.static.SetMultiSkin(MeshWindow.MeshActor, SkinCombo.GetValue2(), FaceCombo.GetValue2(), Int(TeamCombo.GetValue2()));
}
