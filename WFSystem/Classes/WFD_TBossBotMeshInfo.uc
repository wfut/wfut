//=============================================================================
// WFD_TBossBotMeshInfo.
//=============================================================================
class WFD_TBossBotMeshInfo extends WFD_MaleBotPlusMeshInfo;

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
	local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

	MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

	//Log("SetMutliSkin: Params: SkinName: "$SkinName);
	//Log("SetMutliSkin: Params: FaceName: "$FaceName);

	// use the default skin if none specified
	if (SkinName == "")
		SkinName = "BossSkins.boss";

	if (FaceName == "")
		FaceName = "Xan";

	SkinItem = SkinActor.GetItemName(SkinName);
	FaceItem = SkinActor.GetItemName(FaceName);
	SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));
	FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));

	//Log("SetMutliSkin: SkinItem: "$SkinItem);
	//Log("SetMutliSkin: FaceItem: "$FaceItem);
	//Log("SetMutliSkin: SkinPackage: "$SkinPackage);
	//Log("SetMutliSkin: FacePackage: "$FacePackage);

	if(SkinPackage == "")
	{
		SkinPackage="BossSkins.";
		SkinName=SkinPackage$SkinName;
	}
	if(FacePackage == "")
	{
		FacePackage="BossSkins.";
		FaceName=FacePackage$FaceName;
	}

	//Log("SetMutliSkin: SkinName: "$SkinName);
	//Log("SetMutliSkin: FaceName: "$FaceName);

	if( TeamNum != 255 )
	{
		//Log("SetMultiSkin: Attempting to set Team skin -- Team: "$TeamNum);
		if(!SetSkinElement(SkinActor, 0, SkinName$"1T_"$String(TeamNum), ""))
		{
			if(!SetSkinElement(SkinActor, 0, SkinName$"1", ""))
			{
				SetSkinElement(SkinActor, 0, "BossSkins.boss1T_"$String(TeamNum), "BossSkins.boss1");
				SkinName="BossSkins.boss";
			}
		}
		SetSkinElement(SkinActor, 1, SkinName$"2T_"$String(TeamNum), SkinName$"2");
		SetSkinElement(SkinActor, 2, SkinName$"3T_"$String(TeamNum), SkinName$"3");
		SetSkinElement(SkinActor, 3, SkinName$"4T_"$String(TeamNum), SkinName$"4");
	}
	else
	{
		if(!SetSkinElement(SkinActor, 0, SkinName$"1", "BossSkins.boss1"))
			SkinName="BossSkins.boss";

		SetSkinElement(SkinActor, 1, SkinName$"2", "");
		SetSkinElement(SkinActor, 2, SkinName$"3", "");
		SetSkinElement(SkinActor, 3, SkinName$"4", "");
	}

	// Set the talktexture
	if(Pawn(SkinActor) != None)
	{
		//Log("SetMutliSkin: Setting talk texture.");
		if (FaceName != "")
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
		else
			Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5Xan", class'Texture'));
	}
}

// TEST: play decap uses old Unreal player heads with new meshes
static function PlayDecap(pawn Other)
{
	local carcass carc;

	CheckMesh(Other);

	Other.PlayAnim('Dead4',, 0.1);

	if ( Other.Level.NetMode != NM_Client )
	{
		//carc = Other.Spawn(default.DecapClass,,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		carc = Other.Spawn(class'MaleHead',,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		if (carc != None)
		{
			carc.Mesh = default.DecapClass.default.mesh;
			carc.Initfor(Other);
			carc.DrawScale = 0.220000;
			carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
		}
	}
}

defaultproperties
{
     FaceSkin=1
     DefaultFaceName="Xan"
     DefaultClass=class'BotPack.TBoss'
     StatusDoll=Texture'Botpack.Icons.BossDoll'
     StatusBelt=Texture'Botpack.Icons.BossBelt'
     DecapClass=class'UT_BossHead'
     SelectionMesh="Botpack.SelectionBoss"
     DefaultPackage="BossSkins."
     DefaultSkinName="BossSkins.boss"
     VoicePackMetaClass="BotPack.VoiceBoss"
     MenuName="Boss"
     CarcassClass=Class'Botpack.TBossCarcass'
     VoiceType="BotPack.VoiceBoss"
     PlayerMesh=LodMesh'Botpack.Boss'
     DefaultSoundClass=Class'WFD_TBossBotSoundInfo'
}