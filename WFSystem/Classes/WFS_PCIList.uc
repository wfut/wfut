//=============================================================================
// WFS_PCIList.
// Contains information about the player classes available for a team.
// This class is set up by the game class before the game begins.
//=============================================================================
class WFS_PCIList extends WFS_PCSystemInfo;

var() class<WFS_PlayerClassInfo> PlayerClasses[16]; // list of player classes
var() int NumClasses; // the number of classes in the list
var string PlayerClassNames[16]; // replicated class name strings

var() config int MaxPlayers[16]; // max number of players for each class type
var int PlayerCounts[16]; // number of players as each class type

const MAX_CLASSES = 16;

var int Team; // the team this list belongs to (internal)

replication
{
	reliable if (Role == ROLE_Authority)
		PlayerCounts, MaxPlayers, PlayerClassNames;

	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		PlayerClasses, Team;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	NumClasses = Clamp(NumClasses, 0, MAX_CLASSES);
	SetupNames();
}

function SetupNames()
{
	local int i;
	for (i=0; i<MAX_CLASSES; i++)
		if (PlayerClasses[i] != None)
			PlayerClassNames[i] = PlayerClasses[i].default.ClassName;
}

simulated function class<WFS_PlayerClassInfo> GetClassByClassName(string ClassName)
{
	local int i;

	for (i=0; i<NumClasses; i++)
	{
		if (PlayerClasses[i] != none)
		{
			// test each player class for a match
			if ( (caps(PlayerClasses[i].default.ClassName) == caps(ClassName))
				|| (caps(string(PlayerClasses[i].Name)) == caps(ClassName))
				|| (caps(PlayerClasses[i].default.ShortName) == caps(ClassName)))
			{
				// match found, return the player class
				return PlayerClasses[i];
			}
		}
	}

	return none;
}

simulated function int GetIndexOfClass(class<WFS_PlayerClassInfo> PCI)
{
	local int i;

	for (i=0; i<NumClasses; i++)
	{
		if (PlayerClasses[i] != none)
		{
			if (PlayerClasses[i] == PCI)
				return i;
		}
	}

	return -1;
}

function PlayerChangedClass(class<WFS_PlayerClassInfo> OldPCI, class<WFS_PlayerClassInfo> NewPCI)
{
	local int Index;

	if (OldPCI != none)
	{
		Index = GetIndexOfClass(OldPCI);
		if (Index != -1)
			PlayerCounts[Index]--;
	}

	if (NewPCI != none)
	{
		Index = GetIndexOfClass(NewPCI);
		if (Index != -1)
			PlayerCounts[Index]++;
	}
}

simulated function bool CanChangeToClass(class<WFS_PlayerClassInfo> NewPCI)
{
	local int i, Index;

	Index = GetIndexOfClass(NewPCI);

	if (Index != -1)
	{
		if (MaxPlayers[Index] > 0)
			return (PlayerCounts[Index] < MaxPlayers[Index]);
		else if (MaxPlayers[Index] == 0)
			return true;
	}

	return false;
}

// handle regular death message for player
function bool HandleRegularDeathMessage(pawn Killer, pawn Other, name DamageType)
{
	return false;
}

// Handle suicide message for player.
//   use bLogAsSuicide = 0 to prevent the suicide from being stat logged
//   use bIncreaseDeaths = 0 to prevent the players deaths from being incremented
//   use bDecreaseScore = 0 to prevent the players score from being decreased
function bool HandleSuicideMessage(pawn Other, name DamageType, out byte bLogAsSuicide, out byte bIncreaseDeaths, out byte bDecreaseScore)
{
	return false;
}

defaultproperties
{
     bAlwaysRelevant=True
}
