// thanks to Mongo for letting WF use his RA root window quick-load code
class WFRootMenuBar extends UMenuMenuBar;

function Created()
{
	local Class<UWindowPulldownMenu> GameUMenuType;
	local Class<UWindowPulldownMenu> MultiplayerUMenuType;
	local Class<UWindowPulldownMenu> OptionsUMenuType;

	local string GameUMenuName;
	local string MultiplayerUMenuName;
	local string OptionsUMenuName;

	Super(UWindowMenuBar).Created();

	bAlwaysOnTop = True;

	GameItem = AddItem(GameName);
	if(GetLevel().Game != None)
		GameUMenuName = GetLevel().Game.Default.GameUMenuType;
	else
		GameUMenuName = GameUMenuDefault;
	GameUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(GameUMenuName, class'Class'));
	Game = GameItem.CreateMenu(GameUMenuType);

	MultiplayerItem = AddItem(MultiplayerName);
	if(GetLevel().Game != None)
		MultiplayerUMenuName = GetLevel().Game.Default.MultiplayerUMenuType;
	else
		MultiplayerUMenuName = MultiplayerUMenuDefault;
	MultiplayerUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(MultiplayerUMenuName, class'Class'));
	Multiplayer = MultiplayerItem.CreateMenu(MultiplayerUMenuType);

	OptionsItem = AddItem(OptionsName);
	if(GetLevel().Game != None)
		OptionsUMenuName = GetLevel().Game.Default.GameOptionsMenuType;
	else
		OptionsUMenuName = OptionsUMenuDefault;
	OptionsUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(OptionsUMenuName, class'Class'));
	Options = UMenuOptionsMenu(OptionsItem.CreateMenu(OptionsUMenuType));

	StatsItem = AddItem(StatsName);
	Stats = StatsItem.CreateMenu(class'UMenuStatsMenu');

	ToolItem = AddItem(ToolName);
	Tool = ToolItem.CreateMenu(class'UMenuToolsMenu');

	ModItem = AddModItem(ModName);
	Mods = UMenuModMenu(ModItem.CreateMenu(class<UMenuModMenu>(DynamicLoadObject(ModMenuClass, class'class'))));

	HelpItem = AddItem(HelpName);
	Help = HelpItem.CreateMenu(class'UMenuHelpMenu');

	UMenuHelpMenu(Help).Context.bChecked = ShowHelp;
	if (ShowHelp)
	{
		if(UMenuRootWindow(Root) != None)
			if(UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.ShowWindow();
	}

	bShowMenu = True;

	Spacing = 12;
}

function UWindowMenuBarItem AddModItem(string Caption)
{
	local UWindowMenuBarItem I;

	I = UWindowMenuBarItem(Items.Append(class'WFRootModMenuBarItem'));
	I.Owner = Self;
	I.SetCaption(Caption);

	return I;
}


function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (Result == MR_Yes)
	{
		LoadMods();
		Mods.SetupMods(ModItems);
		WFRootModMenuBarItem(ModItem).OkayToLoad = true;
		WFRootModMenuBarItem(ModItem).VerificationBox = None;
		Root.SetMousePos(WFRootModMenuBarItem(ModItem).OrigX, WFRootModMenuBarItem(ModItem).OrigY);
	}
	else if (Result == MR_No)
		WFRootModMenuBarItem(ModItem).VerificationBox = None;
}

defaultproperties
{
}
