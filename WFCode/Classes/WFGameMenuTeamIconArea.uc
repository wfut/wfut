class WFGameMenuTeamIconArea extends NotifyWindow;

//var WFPlayerMeshArea MeshWindow;
var WFPlayerMeshClient MeshWindow;
var float Scale, RedScale, BlueScale, GreenScale, GoldScale;
var vector DrawOffset;

function Created()
{
	// mesh window
	//MeshWindow = WFPlayerMeshArea(CreateWindow(class'WFPlayerMeshArea', 0, 0, WinWidth, WinHeight));
	//MeshWindow.SetMeshActorTag('TeamIconActor');

	//MeshWindow = WFPlayerMeshClient(CreateWindow(class'WFPlayerMeshClient', 0, 0, WinWidth, WinHeight));
}

function Paint(canvas C, float X, float Y)
{
	local int Team, MaxTeams;
	local playerpawn p;
	local WFPlayer WFP;
	local WFGameGRI GRI;

	if ((MeshWindow == None) || (MeshWindow.MeshActor == None))
		return;

	p = GetPlayerOwner();

	Team = 255;
	if (p.PlayerReplicationInfo != None)
		Team = p.PlayerReplicationInfo.Team;

	MaxTeams = -1;
	GRI = WFGameGRI(p.GameReplicationInfo);
	if ((GRI != None) && (GRI.MaxTeams >= 2))
		MaxTeams = GRI.MaxTeams;

	WFP = WFPlayer(p);
	if (WFP != None)
	{
		if (!WFP.bJoinedGame && ((MaxTeams < 2) || (Team >= MaxTeams)))
			Team = 255;

		MeshWindow.DrawOffset = DrawOffset;
		MeshWindow.bRotate = True;

		switch(Team)
		{
			case 0:
				MeshWindow.SetNoAnimMesh(mesh'DomR');
				MeshWindow.MeshActor.bMeshEnviromap = true;
				MeshWindow.MeshActor.DrawScale = RedScale*Scale;
				MeshWindow.MeshActor.Texture = texture'RedSkin2';
				break;
			case 1:
				MeshWindow.SetNoAnimMesh(mesh'DomB');
				MeshWindow.MeshActor.bMeshEnviromap = true;
				MeshWindow.MeshActor.DrawScale = BlueScale*Scale;
				MeshWindow.MeshActor.Texture = texture'BlueSkin2';
				break;
			case 2:
				MeshWindow.SetNoAnimMesh(mesh'UDamage');
				MeshWindow.MeshActor.bMeshEnviromap = true;
				MeshWindow.MeshActor.DrawScale = GreenScale*Scale;
				MeshWindow.MeshActor.Texture = texture'UnrealShare.Belt_fx.ShieldBelt.NewGreen';
				break;
			case 3:
				MeshWindow.SetNoAnimMesh(mesh'MercSymbol');
				MeshWindow.MeshActor.bMeshEnviromap = true;
				MeshWindow.MeshActor.DrawScale = GoldScale*Scale;
				MeshWindow.MeshActor.Texture = texture'GoldSkin2';
				break;

			default:
				MeshWindow.SetNoAnimMesh(mesh'DomN');
				MeshWindow.MeshActor.bMeshEnviromap = true;
				MeshWindow.MeshActor.DrawScale = 0.1*Scale;
				MeshWindow.MeshActor.Texture = texture'JDomN0';
				break;
		}
	}
	else MeshWindow.SetNoAnimMesh(None);

	MeshWindow.WinTop = 0;
	MeshWindow.WinLeft = 0;
	if (MeshWindow.WinWidth != WinWidth || MeshWindow.WinHeight != WinHeight)
		MeshWindow.SetSize(WinWidth, WinHeight);
}

defaultproperties
{
	Scale=0.23
	DrawOffset=(X=0,Y=0,Z=0)
	RedScale=0.11
	BlueScale=0.09
	GreenScale=0.4
	GoldScale=0.23
}