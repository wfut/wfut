class WFPyrotechBotMeshInfo extends WFD_TMale1BotMeshInfo;

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	// use the default skin if none specified
	if (SkinName == "")
	{
		SkinName = default.DefaultSkinName;
		super.SetMultiSkin(SkinActor, SkinName, FaceName, TeamNum);
		return;
	}

	SkinItem = SkinActor.GetItemName(SkinName);
	FaceItem = SkinActor.GetItemName(FaceName);
	SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));
	FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));

	// Set the team elements
	if( TeamNum != 255 )
	{
		// whole skin changes for different teams
		SetSkinElement(SkinActor, 0, SkinName$"1T_"$String(TeamNum), SkinName$"1");
		SetSkinElement(SkinActor, 1, SkinName$"2T_"$String(TeamNum), SkinName$"2");
		SetSkinElement(SkinActor, 2, SkinName$"3T_"$String(TeamNum), SkinName$"3");
		SetSkinElement(SkinActor, 3, SkinName$"4T_"$String(TeamNum), SkinName$"4");

	}
	else
	{
		// default to the TMale1 skin
		super.SetMultiSkin(SkinActor, default.DefaultSkinName, default.DefaultFaceName, TeamNum);
		return;
	}

	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		//Log("SetMutliSkin: Setting talk texture.");
		if (FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$default.DefaultFaceName, class'Texture'));
	}
}

defaultproperties
{
}
