class WFPipeBombList extends WFS_PCSystemInfo;

var() int MaxPipeBombs;
var int NumPipeBombs;
//var WFPipeBomb PipeBombList[10];
var WFPipeBomb FirstPipeBomb;
var WFPipeBombLauncher PBL;

function DetPipes()
{
	if (FirstPipeBomb != None)
	{
		FirstPipeBomb.DetonateAll();
		FirstPipeBomb = None;
	}

	NumPipeBombs = 0;
	if (PBL != None)
		PBL.NumPipeBombs = 0;
}

function AddPipeBomb(WFPipeBomb NewPipeBomb)
{
	local WFPipeBomb pb;

	if (NewPipeBomb == None)
		return;

	NewPipeBomb.List = self;
	if (FirstPipeBomb == None)
		FirstPipeBomb = NewPipeBomb;
	else
	{
		NewPipeBomb.NextBomb = FirstPipeBomb;
		FirstPipeBomb = NewPipeBomb;
	}

	NumPipeBombs++;
	if (NumPipeBombs > MaxPipeBombs)
	{
		DetonateOldest();
		NumPipeBombs = MaxPipeBombs;
	}
	if (PBL != None)
		PBL.NumPipeBombs = NumPipeBombs;
}

function DetonateOldest()
{
	local WFPipeBomb pb, lastpb;

	if (FirstPipeBomb == None)
		return;

	if (FirstPipeBomb.NextBomb == None)
	{
		FirstPipeBomb.Detonate();
		FirstPipeBomb = None;
		NumPipeBombs--;
		if (PBL != None)
			PBL.NumPipeBombs = NumPipeBombs;
		return;
	}

	lastpb = FirstPipeBomb;
	for (pb=FirstPipeBomb.NextBomb; pb!=None; pb=pb.NextBomb)
	{
		if (pb.NextBomb == None)
		{
			pb.Detonate();
			if (lastpb != None)
				lastpb.NextBomb = None;
			NumPipeBombs--;
			if (PBL != None)
				PBL.NumPipeBombs = NumPipeBombs;
			break;
		}
		lastpb = pb;
	}
}

function RemovePipeBomb(WFPipeBomb OldPipeBomb)
{
	local WFPipeBomb pb, lastpb;
	local bool bRemoved;

	if ((FirstPipeBomb == None) || (OldPipeBomb == None))
		return;

	bRemoved = false;
	if (OldPipeBomb == FirstPipeBomb)
	{
		pb = FirstPipeBomb.NextBomb;
		FirstPipeBomb.NextBomb = None;
		FirstPipeBomb = pb;
		bRemoved = true;
	}
	else
	{
		for (pb=FirstPipeBomb; pb!=None; pb=pb.NextBomb)
		{
			if (pb == OldPipeBomb)
			{
				pb = OldPipeBomb.NextBomb;
				if (lastpb != None)
					lastpb.NextBomb = pb;
				bRemoved = true;
				break;
			}
			lastpb = pb;
		}
	}

	if (bRemoved)
	{
		NumPipeBombs--;
		if (PBL != None)
			PBL.NumPipeBombs = NumPipeBombs;
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

