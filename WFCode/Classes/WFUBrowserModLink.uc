class WFUBrowserModLink extends UBrowserGSpyLink;

var string GameType;

// States
state FoundSecretState
{
Begin:
	Enable('Tick');
	SendBufferedData("\\list\\\\gamename\\"$GameName$"\\gametype\\"$GameType$"\\final\\");
	WaitFor("ip\\", 30, NextIP);
}

defaultproperties
{
}
