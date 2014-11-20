class WFPipeBombList extends WFS_PCSystemInfo;

var() int MaxPipeBombs;
var int NumPipeBombs;
var WFPipeBomb PipeBombList[10];
var WFPipeBombLauncher PBL;

function DetPipes()
{
	local int i;
	for (i=0; i<NumPipeBombs; i++)
		if (PipeBombList[i] != None)
		{
			PipeBombList[i].Detonate();
			PipeBombList[i] = None;
		}
	NumPipeBombs = 0;
	if (PBL != None)
		PBL.NumPipeBombs = 0;
}

function AddPipeBomb(WFPipeBomb NewPipeBomb)
{
	local int i;
	local WFPipeBomb b;

	if (NewPipeBomb == None)
		return;

	if (NumPipeBombs == MaxPipeBombs)
	{
		if (PipeBombList[0] != None)
			PipeBombList[0].Detonate();

		for (i=0; i<NumPipeBombs; i++)
		{
			if (i == NumPipeBombs-1)
				PipeBombList[i] = NewPipeBomb;
			else PipeBombList[i] = PipeBombList[i+1];
		}
	}
	else
	{
		NumPipeBombs++;
		PipeBombList[NumPipeBombs-1] = NewPipeBomb;
	}

	if (PBL != None)
		PBL.NumPipeBombs = NumPipeBombs;
}

function RemovePipeBomb(WFPipeBomb OldPipeBomb)
{
	local int i, j;
	for (i=0; i<NumPipeBombs; i++)
	{
		if (PipeBombList[i] == OldPipeBomb)
		{
			PipeBombList[i] = None;
			for (j=i; j<NumPipeBombs; j++)
			{
				if (j == NumPipeBombs-1)
					PipeBombList[j] = None;
				else PipeBombList[j] = PipeBombList[j+1];
			}
			NumPipeBombs--;
			if (PBL != None)
				PBL.NumPipeBombs = NumPipeBombs;
			break;
		}
	}
}

function Destroyed()
{
	DetPipes();
}

defaultproperties
{
	MaxPipeBombs=8
}

