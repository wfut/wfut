//=============================================================================
// WFD_UnrealIPlayerMeshInfo.
//=============================================================================
class WFD_UnrealIPlayerMeshInfo extends WFD_PlayerPawnMeshInfo;

// update HUD icons (FIXME: don't update icons on a dedicated server)
static function UpdateIcons(pawn Other)
{
	// don't want to update icons on the server
	if (Other.Level.NetMode == NM_DedicatedServer)
		return;

	//Log("UpdateIcons() called for: "$Other);

	if ((TournamentPlayer(Other).StatusDoll != default.StatusDoll) && (default.StatusDoll != none))
		TournamentPlayer(Other).StatusDoll = default.StatusDoll;

	if ((TournamentPlayer(Other).StatusBelt != default.StatusBelt) && (default.StatusBelt != none))
		TournamentPlayer(Other).StatusBelt = default.StatusBelt;
}

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;
	local string MeshName;
	local int i;
	local string TeamColor[4];

	TeamColor[0]="Red";
    TeamColor[1]="Blue";
    TeamColor[2]="Green";
    TeamColor[3]="Yellow";


	//Log("SetMultiSkin(): SkinName: "$SkinName);

	MeshName = SkinActor.GetItemName(string(default.PlayerMesh));

	if( InStr(SkinName, ".") == -1 )
		SkinName = MeshName$"Skins."$SkinName;

	if(TeamNum >=0 && TeamNum <= 3)
		NewSkin = texture(DynamicLoadObject(MeshName$"Skins.T_"$TeamColor[TeamNum], class'Texture'));
	else if( Left(SkinName, Len(MeshName)) ~= MeshName )
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));

	// Set skin
	if ( NewSkin != None )
	{
		//Log("SetMultiSkin(): NewSkin: "$NewSkin);
		SkinActor.Skin = NewSkin;
	}
	//else Log("WARNING: failed to load skin for: "$SkinName);

	// clear MultiSkins
	for (i=0; i<5; i++)
		if (SkinActor.MultiSkins[i] != none)
			SkinActor.MultiSkins[i] = none;
}

static function PlayDodge(pawn Other, eDodgeDir DodgeMove)
{
	CheckMesh(Other);
	PlayDuck(Other);
}

static function PlayChatting(pawn Other)
{
}

static function PlayDecap(pawn Other)
{
	local carcass carc;

	CheckMesh(Other);

	Other.PlayAnim('Dead4',, 0.1);

	if ( Other.Level.NetMode != NM_Client )
	{
		carc = Other.Spawn(default.DecapClass,,, Other.Location + Other.CollisionHeight * vect(0,0,0.8), Other.Rotation + rot(3000,0,16384));
		if (carc != None)
		{
			carc.Initfor(Other);
			carc.Velocity = Other.Velocity + VSize(Other.Velocity) * VRand();
			carc.Velocity.Z = FMax(carc.Velocity.Z, Other.Velocity.Z);
		}
	}
}

defaultproperties
{
	bIsMultiSkinned=False
	VoiceType="BotPack.MaleTwo"
	StatusDoll=Texture'Botpack.Icons.Man'
	StatusBelt=Texture'Botpack.Icons.ManBelt'
    CollisionRadius=17.000000
    CollisionHeight=39.000000
}