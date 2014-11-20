class WFStockCTFMapData extends WFMapData;

// return true to prevent other map data classes from modifying the map
function bool HandleMapSetupFor(string MapName, WFMapSetupInfo MapSetupClass)
{
	switch (caps(MapName))
	{
		case "CTF-COMMAND":
			RemoveMapInventory();
			SetupMap_01();
			return true;

		case "CTF-FACE":
			RemoveMapInventory();
			SetupMap_02();
			return true;

		case "CTF-NOVEMBER":
			RemoveMapInventory();
			SetupMap_03();
			return true;

		case "CTF-CORET":
			RemoveMapInventory();
			SetupMap_04();
			return true;

		case "CTF-NIVEN":
			RemoveMapInventory();
			SetupMap_05();
			return true;

		case "CTF-LAVAGIANT":
			RemoveMapInventory();
			SetupMap_06();
			return true;

		case "CTF-DREARY":
			RemoveMapInventory();
			SetupMap_07();
			return true;

		case "CTF-ETERNALCAVE":
			RemoveMapInventory();
			SetupMap_08();
			return true;

		case "CTF-GAUNTLET":
			RemoveMapInventory();
			SetupMap_09();
			return true;
	}

	return false; // allow other map data classes to handle map setup
}

// set up CTF-Command
function SetupMap_01()
{
	local Ladder InfoClass;

	// Red base (may want to reposition)
	InfoClass = AddSupplyPackInfo(vect(2080.4,374.8,0.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2273.3,0.13,0.0), 1);
        InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2069.7,-359.15,0.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2183.6,249.5,0.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2230.8,-128,0.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1366.3,89.3,10.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2257.1,128.2,0.0), 1);
        InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2174.5,-236.6,0.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1365.5,-89.6,10.0), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

    // Red midfield
	AddSupplyPackInfo(vect(760.5,87,50), 1);
	AddSupplyPackInfo(vect(763,3,50), 1);
	AddSupplyPackInfo(vect(758,-80,50), 1);

	// Blue base
	InfoClass = AddSupplyPackInfo(vect(543,270,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1012.4,121.1,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(800,-258,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(672,272,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1006.8,-8.7,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(670,-256,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(802,270,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1005.3,-137.8,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(541,-258,688), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	// Blue midfield
	AddSupplyPackInfo(vect(-1874.5,82,0.0), 2);
	AddSupplyPackInfo(vect(-1872,-2.0,0.0), 2);
	AddSupplyPackInfo(vect(-1877,-85,0.0), 2);

	// Neutral
	AddSupplyPackInfo(vect(760.5,87,50));
	AddSupplyPackInfo(vect(763,3,50));
	AddSupplyPackInfo(vect(758,-80,50));
}

// set up CTF-Face
function SetupMap_02()
{
	local Ladder InfoClass;

	// == Red base ==
	// lower level
	InfoClass = AddSupplyPackInfo(vect(6917,-246,-1984), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6917,-95,-1984), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6480,-784,-2000), 1);
        InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	// hiding spot above entrance
	InfoClass = AddSupplyPackInfo(vect(5952,-176,-1376), 1);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// Redeemer perch
	InfoClass = AddSupplyPackInfo(vect(5760,-160,-976), 1);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// Sniper Rifle perch
	InfoClass = AddSupplyPackInfo(vect(5952,-96,-464), 1);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// top level
	InfoClass = AddSupplyPackInfo(vect(6656,-320,1056), 1);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// == Blue base ==
	// lower level
	InfoClass = AddSupplyPackInfo(vect(-1472,80,-2016), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1472,-80,-2016), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1024,624,-2032), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	// hiding spot above entrance
	InfoClass = AddSupplyPackInfo(vect(-752,0.0,-1392), 2);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// Redeemer perch
	InfoClass = AddSupplyPackInfo(vect(-752,0.0,-1392), 2);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// Sniper Rifle perch
	InfoClass = AddSupplyPackInfo(vect(-512,-64,-496), 2);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;

	// top level
	InfoClass = AddSupplyPackInfo(vect(-1232,160,1040), 2);
	Infoclass.Timelimits[3] = 30;
	InfoClass.TimeLimits[1] = 20;


	// == Neutral ==
	// superhealth spot
	InfoClass = AddSupplyPackInfo(vect(2688,-64,-1404));
	InfoClass.Matches = 64;
	InfoClass.Timelimits[2] = 50;
	InfoClass.Timelimits[1] = 50;
}

// set up CTF-November
function SetupMap_03()
{
	local Ladder InfoClass;

	// == Red Base ==
	// long spawn hall
	InfoClass = AddSupplyPackInfo(vect(2353,-118.4,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2358.4,-22.9,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2354,97.8,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2245.5,-129.7,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2250,-21,-183), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2238.7,98.2,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2132.5,-129.7,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2137,-21,-183), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2125.7,98.2,-182.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// boxes area w/superhealth
	InfoClass = AddSupplyPackInfo(vect(1033.5,1129.5,-372.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(992.4,825.7,-372.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(655.8,958.2,-368.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// gunner outpost w/shieldbelt
	InfoClass = AddSupplyPackInfo(vect(-2039.9,1887.6,-268.9), 1);
	InfoClass = AddSupplyPackInfo(vect(-2109.5,1888,-268.9), 1);

	// cul-de-sac near stairs
	InfoClass = AddSupplyPackInfo(vect(-2419.4,-157.3,-400.9), 1);
	InfoClass = AddSupplyPackInfo(vect(-2419.4,-230.3,-400.9), 1);

	// == Blue Base ==
	// hall with escape hole in floor
	InfoClass = AddSupplyPackInfo(vect(-5428.5,-1112.2,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5344,-1112.2,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5232.1,-1112.2,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5143.6,-1112.2,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	InfoClass = AddSupplyPackInfo(vect(-5145.6,-559,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5234.2,-559,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5346,-559,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5430.5,-559,363), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// box in flagroom w/armor
	InfoClass = AddSupplyPackInfo(vect(-6190.3,-1099.8,383), 2);

	// balcony w/shieldbelt
	InfoClass = AddSupplyPackInfo(vect(-4532.4,-228.9,-132.9), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4374.7,-228.9,-132.9), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// main entrance w/flak ammo
	InfoClass = AddSupplyPackInfo(vect(-4912,-1008,-528), 2);
	InfoClass = AddSupplyPackInfo(vect(-4752,-1008,-528), 2);
}

// set up CTF-Coret
function SetupMap_04()
{
	local Ladder InfoClass;

	// == Red Base ==
	// Flak ledge near front door
	InfoClass = AddSupplyPackInfo(vect(-2355.5,7788.2,139.1), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2452.5,7788.2,139.1), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2339,7566.4,139.1), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2434.6,7566.4,139.1), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2351.2,7373.9,139.1), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2435.8,7373.9,139.1), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// small room w/rocket ammo
	InfoClass = AddSupplyPackInfo(vect(383.2,6327.6,75), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(379.8,6332.4,75), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(472.4,6327.6,75), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(475.7,6232.4,75), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// cul-de-sac w/thighpads
	InfoClass = AddSupplyPackInfo(vect(-519.8,4104,-52.9), 1);
	InfoClass = AddSupplyPackInfo(vect(-524.1,3829.5,-52.9), 1);

	// == Blue Base ==
	// Flak ledge near front door
	InfoClass = AddSupplyPackInfo(vect(1890.5,-1059.8,139.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1994.5,-1059.8,139.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1893.4,-849.2,139.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1997.4,-849.2,139.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1892.9,-648.2,139.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1996.9,-648.2,139.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// small room w/rocket ammo
	InfoClass = AddSupplyPackInfo(vect(-817,413.8,107.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-817,479.5,107.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-886,413.8,107.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-886,479.5,107.1), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// cul-de-sac w/thighpads
	InfoClass = AddSupplyPackInfo(vect(68,2607,-52.9), 2);
	InfoClass = AddSupplyPackInfo(vect(68,2906.9,-52.9), 2);
}

// set up CTF-Niven
function SetupMap_05()
{
	local Ladder InfoClass;

	// == Red Base ==
	// flagroom
	InfoClass = AddSupplyPackInfo(vect(1496.8,-966.7,-244.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2189.6,-530,-245), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	// underneath ramp
	InfoClass = AddSupplyPackInfo(vect(83.6,482.4,-244.9), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Blue Base ==
	// flagroom
	InfoClass = AddSupplyPackInfo(vect(-4020.6,664.4,-244.9), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-3273,1064.8,-244.9), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// underneath ramp
	InfoClass = AddSupplyPackInfo(vect(-1934.4,-342.3,-244.9), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Neutral Area ==
	InfoClass = AddSupplyPackInfo(vect(-1326.9,67.9,-724.9));
	InfoClass = AddSupplyPackInfo(vect(-460.2,62.6,-724.9));
}

// set up CTF-LavaGiant
function SetupMap_06()
{
	local Ladder InfoClass;

	// == Red Base ==
	//back left of base (when facing blue base)
	InfoClass = AddSupplyPackInfo(vect(-4878,-596,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4878,-292,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//back right of base (when facing blue base)
	InfoClass = AddSupplyPackInfo(vect(-4889,275,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4889,575,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//sniper spot at front
	InfoClass = AddSupplyPackInfo(vect(-3683,-5,464), 1);

	//inside base ground floor
	InfoClass = AddSupplyPackInfo(vect(-3694,-667,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-3694,663,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4224,-304,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4232,304,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4670,-668,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4670,662,240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Blue Base ==
	//center of base ground level
	InfoClass = AddSupplyPackInfo(vect(5295,880.5,116.5), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5295,1180.5,116.5), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5223,880.5,116.5), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5223,1180.5,116.5), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//nearjump boots
	InfoClass = AddSupplyPackInfo(vect(5920,729,240), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//near green armor (opposite side of jumpboots)
	InfoClass = AddSupplyPackInfo(vect(5908,1557,240), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	//back left (when facing red base)
	InfoClass = AddSupplyPackInfo(vect(6064,1536,112), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6064,1328,112), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//back right (when facing red base)
	InfoClass = AddSupplyPackInfo(vect(6064,713,112), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6064,505,112), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//front sniper windows
	InfoClass = AddSupplyPackInfo(vect(4448,1709,320), 2);
	InfoClass = AddSupplyPackInfo(vect(4448,352,320), 2);

	// == Neutral Area ==
	//lower cavern arch blue
	InfoClass = AddSupplyPackInfo(vect(2304,832,-736));
	InfoClass.Matches = 16;

	InfoClass = AddSupplyPackInfo(vect(2176,704,-736));
	InfoClass.Matches = 16;


	//lower caver arch red
	InfoClass = AddSupplyPackInfo(vect(-1600,112,-720));
	InfoClass.Matches = 16;

	InfoClass = AddSupplyPackInfo(vect(-1488,-64,-720));
	InfoClass.Matches = 16;

}

// set up CTF-Dreary
function SetupMap_07()
{
	local Ladder InfoClass;

	// == Red Base ==
	//entrance to flagroom bottom
	InfoClass = AddSupplyPackInfo(vect(141,304,-22), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(237,304,-22), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//entrance to flagroom top
	InfoClass = AddSupplyPackInfo(vect(142,275,199), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(237,275,199), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;




	// == Blue Base ==
	//upper entrance to flagroom
	InfoClass = AddSupplyPackInfo(vect(239.3,-4883.5,199), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(143.3,-4883.5,199), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//lower entrance to flagroom
	InfoClass = AddSupplyPackInfo(vect(240,-4912.5,-9.0), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(144,-4912.5,-9.0), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Neutral Area ==
	//Upper mid
	InfoClass = AddSupplyPackInfo(vect(96,-2304,240));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(192,-2384,240));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(281,-2298,240));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(192,-2208,240));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//lower mid
	InfoClass = AddSupplyPackInfo(vect(192,-1984,-16));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(192,-2624,-16));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

}

// set up CTF-EternalCave
function SetupMap_08()
{
	local Ladder InfoClass;

	// == Red Base ==
	//back spawnroom
	InfoClass = AddSupplyPackInfo(vect(2016,-5952,-224), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2208,-5936,-197), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2016,-5888,-224), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2144,-5904,-208), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//upper vinecovered hall
	InfoClass = AddSupplyPackInfo(vect(-319,-2119,-80), 1);

	//red aztec hall
	InfoClass = AddSupplyPackInfo(vect(-1008,-1888,-304), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1008,2016,-304), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1024,-2480,-304), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1024,-2608,-304), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Blue Base ==
	//side spawn room
	InfoClass = AddSupplyPackInfo(vect(2272,-656,-336), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2400,-657,-338), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2272,-608,-336), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2400,-607,-339), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//upper vinecovered hall
	InfoClass = AddSupplyPackInfo(vect(-319,-1525,-96), 2);

	//blue aztec hall
	InfoClass = AddSupplyPackInfo(vect(255,-1715,-304), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(256,-1616,-304), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(288,-1168,-304), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(287,-1066,-304), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;
}

// set up CTF-Gauntlet
function SetupMap_09()
{
	local Ladder InfoClass;
	local string AmmoString;

	// == Red Base ==
	//flagroomm spawn area
	InfoClass = AddSupplyPackInfo(vect(-217,-1138,-368), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(80,-1138,-368), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-208,-992,-368), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(80,-992,-368), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//niche outside flagroom door
	InfoClass = AddSupplyPackInfo(vect(1146,726,-240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1031,727,-240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1148,668,-240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1033,669,-240), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//side spawn room
	InfoClass = AddSupplyPackInfo(vect(2257,-1561,-288), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2257,-1689,-288), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2326,-1560,-288), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2321,-1689,-288), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Blue Base ==
	//flagroomm spawn area
	InfoClass = AddSupplyPackInfo(vect(5949,1139,-128), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5701,1139,-128), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5949,1011,-128), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5701,1011,-128), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//niche outside flagroom door
	InfoClass = AddSupplyPackInfo(vect(4731,460,3.0), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4667,460,3.0), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4731,414,3.0), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4667,414,3.0), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	//side spawn room
	InfoClass = AddSupplyPackInfo(vect(2928,1840,-288), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2928,1969,-288), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2864,1840,-288), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2864,1969,-288), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 15;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;


	// == Neutral Area ==
	//lower lava plank (give lots reload_health?)
	InfoClass = AddSupplyPackInfo(vect(3063,-9.6,-528));
	InfoClass.Matches = 64;			// set ITEM_CustomHealth
	InfoClass.Timelimits[1] = 50;
	InfoClass.TimeLimits[2] = 40;	// give 40 health

	//upper level wooden floor
	AmmoString = "AMMO_TYPES?BioAmmo=25,BladeHopper=17,BulletBox=12,FlakAmmo=12,MiniAmmo=25,PAmmo=25,RocketPack=12,ShockCore=12,DefaultAmmoAmount=10";
	InfoClass = AddSupplyPackInfo(vect(2380,112.5,0.0));
	InfoClass.Maps[0] = AmmoString; // give 1/2 usual reasources
	InfoClass.Matches = 16;			// set ITEM_HealthPack

	InfoClass = AddSupplyPackInfo(vect(2384,-121,0.0));
	InfoClass.Maps[0] = AmmoString; // give 1/2 usual reasources
	InfoClass.Matches = 16;			// set ITEM_HealthPack
}

defaultproperties
{
	MapDataText="Stock CTF Map Data"
	SupportedMapsText="CTF-Command, CTF-Coret, CTF-Dreary, CTF-EternalCave, CTF-Face, CTF-Gauntlet, CTF-LavaGiant, CTF-Niven, CTF-November"
	MapDataInfoText="Map data for default UT CTF maps."
}