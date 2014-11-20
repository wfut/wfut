class WFUBrowserWindowTab expands UTBrowserServerListWindow;

defaultproperties
{
     ServerListTitle="Weapons Factory"
     //ListFactories(0)="WFGameMenu.UBrowserModFact,GameType=WFGame,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
     ListFactories(0)="WFCode.WFUBrowserModFact,GameType=WFGame,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"
}