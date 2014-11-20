class WFStatusVaccinated extends WFPlayerStatus;

// doesn't do anything, just used to mark that the player cannot
// be infected by WFStatusInfected

var effects MyEffect;

function ServerInitialise()
{
	if (MyEffect == None)
		MyEffect = spawn(class'WFStatusVaccinatedFX', Owner,, Owner.Location);
}

simulated function Destroyed()
{
	CleanUp();
	super.Destroyed();
}

function CleanUp()
{
	if (MyEffect != None)
		MyEffect.Destroy();
}

/*function StatusTick(float DeltaTime)
{
	if (MyEffect != None)
	{
		if (LifeSpan < 20)
			MyEffect.Mesh = Mesh'vaccine';
		else if (LifeSpan < 40)
			MyEffect.Mesh = Mesh'vaccine2';
		else MyEffect.Mesh = Mesh'vaccine3';
	}
}*/

defaultproperties
{
	PickupMessage="You have been vaccinated"
	ExpireMessage="The vaccination has worn off."
	LifeSpan=45.0
}