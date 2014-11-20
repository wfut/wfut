class WFTeslaChainParent extends WFTeslaHit;

var() class<WFTeslaChainBoltChild> ChainBoltClass;
var WFTeslaChainBoltChild Beams[10];
var actor Targets[10];
var() float Range;
var() byte MaxBeams;

function PostBeginPlay()
{
	//Log(name$".PostBeginPlay(): "$Level.TimeSeconds);
	SetTimer(0.25, true);
}

function Timer()
{
	local actor a;
	//Log("Timer(): called...");

	// TODO: change to class'Pawn', or use Level.PawnList
	foreach RadiusActors(class'actor', a, Range)
		if ((a != None) && ValidTarget(a) && !IsATarget(a)) FireAt(a);
}

function SetMaxBeams(byte NewMaxBeams)
{
	MaxBeams = Clamp(NewMaxBeams, 1, ArrayCount(Beams));
}

function FireAt(actor Other)
{
	local int i;

	//Log("Firing at: "$Other);

	for (i=0; i<MaxBeams; i++)
		if ((Beams[i] == None) || Beams[i].bDeleteMe)
		{
			Beams[i] = spawn(ChainBoltClass, self,, Location);
			Beams[i].BeamTarget = Other;
			Beams[i].ChainParent = self;
			Targets[i] = Other;
			return;
		}
}

function bool IsATarget(actor Other)
{
	local int i;

	for (i=0; i<MaxBeams; i++)
		if (Targets[i] == Other)
			return true;

	return false;
}

function bool ValidTarget(actor Other)
{
	//Log("ValidActor test for: "$Other);
	if (Other.RemoteRole == ROLE_None)
		return false; // don't target non-replicated actors

	if (!Other.IsA('Carcass') && !Other.IsA('Pawn'))
		return false;

	if (!FastTrace(Other.Location, Location))
		return false;

	if ((Other == Owner) || (Other == Instigator) || Other.bHidden)
		return false;

	if (Other.bIsPawn && (pawn(Other).Health <= 0))
		return false;

	return true;
}

function bool OutOfRange(actor Other)
{
	local int i;

	for (i=0; i<MaxBeams; i++)
		if (Targets[i] == Other)
		{
			Targets[i] = None;
			Beams[i].Destroy();
			return true;
		}

	return false;
}

function Destroyed()
{
	local int i;

	//Log(name$".Destroyed(): "$Level.TimeSeconds);

	for (i=0; i<ArrayCount(Beams); i++)
		if (Beams[i] != None)
			Beams[i].Destroy();

	super.Destroyed();
}

defaultproperties
{
	//Physics=PHYS_Trailer
	Range=400
	MaxBeams=4
	SoundRadius=12
	SoundVolume=255
	ChainBoltClass=class'WFTeslaChainBoltChild'
}