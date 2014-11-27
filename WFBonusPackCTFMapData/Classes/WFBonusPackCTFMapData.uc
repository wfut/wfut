class WFBonusPackCTFMapData extends WFMapData;

// return true to prevent other map data classes from modifying the map
function bool HandleMapSetupFor(string MapName, WFMapSetupInfo MapSetupClass)
{
	switch (caps(MapName))
	{
		case "CTF-ORBITAL":
			RemoveMapInventory();
			SetupMap_01();
			return true;

		case "CTF-CYBROSIS][":
			RemoveMapInventory();
			SetupMap_02();
			return true;
		
		case "CTF-HYDRO16":
			RemoveMapInventory();
			SetupMap_03();
			return true;

		case "CTF-HALLOFGIANTS":
			RemoveMapInventory();
			SetupMap_04();
			return true;

                case "CTF-DARJI16":
			RemoveMapInventory();
			SetupMap_05();
			return true;
			
		case "CTF-NOXION16":
			RemoveMapInventory();
			SetupMap_06();
			return true;
	}

	return false; // allow other map data classes to handle map setup
}


// set up CTF-Orbital
function SetupMap_01()
{
	local Ladder InfoClass;

	// Red flagroom
	InfoClass = AddSupplyPackInfo(vect(-42,33,-101), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(39,33,-101), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;   

	InfoClass = AddSupplyPackInfo(vect(-40,98,-101), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(40,98,-101), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//red flagroom daise

	InfoClass = AddSupplyPackInfo(vect(-230,-1726,-97), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;


	InfoClass = AddSupplyPackInfo(vect(233,-1726,-97), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
//redfoyer hall

//near damage amplifier

	InfoClass = AddSupplyPackInfo(vect(-894,2434,-357), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-896,2250,-357), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//near pulse ammo

	InfoClass = AddSupplyPackInfo(vect(705,2257,-357), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(704,2416,-357), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//sniper roost

	InfoClass = AddSupplyPackInfo(vect(704,2416,-357), 1);
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//MIDFIELD

//upper mid

	InfoClass = AddSupplyPackInfo(vect(-2,4993,-469));
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//near redeemer

	InfoClass = AddSupplyPackInfo(vect(0,5008,156));
	InfoClass.Matches = 64;
	InfoClass.Timelimits[2] = 40;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 40;
	InfoClass.TimeLimits[3] = 20;

//left from red

	InfoClass = AddSupplyPackInfo(vect(944,4989,-677));
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//right from red

	InfoClass = AddSupplyPackInfo(vect(-940,4995,-677));
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//BLUE

//blue flagroom

	InfoClass = AddSupplyPackInfo(vect(-45,9876,-101), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(36,9874,-101), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-43,9939,-101), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(38,9940,-101), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//blue flagroom daise

	InfoClass = AddSupplyPackInfo(vect(235,11715,-97), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;


	InfoClass = AddSupplyPackInfo(vect(-229,11715,-97), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//blue foyer hall

//near damage amp

	InfoClass = AddSupplyPackInfo(vect(-716,7724,-357), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-716,7565,-357), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//near pulse ammo

	InfoClass = AddSupplyPackInfo(vect(888,7548,-357), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(890,7727,-357), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//blue sniper roost

	InfoClass = AddSupplyPackInfo(vect(4,6860,-101), 2);
	InfoClass.TimeLimits[0] = 20;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;
}

//set up CTF-Cybrosis][

function SetupMap_02()
{

	local Ladder InfoClass;

//red base pillar

	InfoClass = AddSupplyPackInfo(vect(2918,214,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2918,134,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2918,-134,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2918,-214,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(3033,-9,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(3113,-8,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(3190,-10,364), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//left of red pillar

	InfoClass = AddSupplyPackInfo(vect(2942,594,412), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2876,595,412), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//right of red pillar

	InfoClass = AddSupplyPackInfo(vect(2878,-611,412), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2944,-612,412), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//lower red base

	InfoClass = AddSupplyPackInfo(vect(3997,67,190), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(3997,-108,190), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4439,-110,190), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4439,65,190), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	


//BLUE
//blue base pillar

	InfoClass = AddSupplyPackInfo(vect(-2920,-223,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2920,-143,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2922,125,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2922,205,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-3037,0,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-3117,0,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-3193,0,364), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//left of blue pillar

	InfoClass = AddSupplyPackInfo(vect(-2943,-602,412), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2877,-604,412), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//right of blue pillar

	InfoClass = AddSupplyPackInfo(vect(-2883,602,412), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2949,602,412), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//lower blue base

	InfoClass = AddSupplyPackInfo(vect(-4000,-80,190), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-400,96,190), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4442,97,190), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-4442,-79,190), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
}


//set up CTF-Hydro16

function SetupMap_03()
{

	local Ladder InfoClass;

//RED
//near red armor

	InfoClass = AddSupplyPackInfo(vect(182,-1665,-131), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(290,-1665,-131), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(384,-1665,-131), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(482,-1665,-131), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(592,-1665,-131), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//near rocket launcher

	InfoClass = AddSupplyPackInfo(vect(1204,-1152,45), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1359,-1152,45), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1279,-1092,45), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1205,-1025,45), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1358,-1025,45), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//red sniper hut

	InfoClass = AddSupplyPackInfo(vect(583,-4724,16), 1);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(583,-4657,16), 1);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(583,-4588,16), 1);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(583,-4511,16), 1);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

//red corner

	InfoClass = AddSupplyPackInfo(vect(-1619,-2557,-197), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1537,-2632,-197), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;


//BLUE
//near armor in blue base

	InfoClass = AddSupplyPackInfo(vect(586,-11395,-131), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(479,-11395,-131), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(385,-11395,-131), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(286,-11395,-131), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(177,-11395,-131), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//near rocket launcher

	InfoClass = AddSupplyPackInfo(vect(-441,-11898,45), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;		

	InfoClass = AddSupplyPackInfo(vect(-596,-11898,45), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-517,-11956,45), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-445,-12024,45), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-597,-12024,45), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//blue sniper hut

	InfoClass = AddSupplyPackInfo(vect(189,-8329,16), 2);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(189,-8396,16), 2);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(189,-8466,16), 2);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(189,-8542,16), 2);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 15;
	InfoClass.TimeLimits[3] = 20;

//blue corner

	InfoClass = AddSupplyPackInfo(vect(2387,-10508,-197), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2306,-10408,-197), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
}

// set up CTF-HallofGiants
function SetupMap_04()
{
	local Ladder InfoClass;

//RED
//above flag

	InfoClass = AddSupplyPackInfo(vect(-8166,1019,3104), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-8166,894,3104), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-8166,767,3104), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-8166,-768,3104), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-8166,-894,3104), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-8166,-1021,3104), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//first tier right

	InfoClass = AddSupplyPackInfo(vect(-5760,1006,1692), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5887,1006,1692), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-6015,1006,1692), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//first tier left

	InfoClass = AddSupplyPackInfo(vect(-6012,-1012,1692), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5884,-1012,1692), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-5756,-1012,1692), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//second tier right

	InfoClass = AddSupplyPackInfo(vect(-2816,1006,2587), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2943,1006,2587), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-3072,1006,2587), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//second tier left

	InfoClass = AddSupplyPackInfo(vect(-3072,-1002,2587), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2943,-1002,2587), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-2816,-1002,2587), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//MIDFIELD
//redeemer

	InfoClass = AddSupplyPackInfo(vect(0.39,-3,5215));
	InfoClass.TimeLimits[0] = 30;
	InfoClass.TimeLimits[1] = 50;
	InfoClass.TimeLimits[3] = 50;

//transporter portal

	InfoClass = AddSupplyPackInfo(vect(1,105,159));
	InfoClass.TimeLimits[0] = 10;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1,-7,159));
	InfoClass.TimeLimits[0] = 10;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1,-111,159));
	InfoClass.TimeLimits[0] = 10;
	InfoClass.TimeLimits[1] = 20;
	InfoClass.TimeLimits[3] = 20;

//BLUE
//above flag

	InfoClass = AddSupplyPackInfo(vect(8168,-1019,3104), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(8168,-892,3104), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(8168,-767,3104), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(8168,768,3104), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(8168,896,3104), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(8168,1020,3104), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//first tier right

	InfoClass = AddSupplyPackInfo(vect(6015,1007,1692), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5885,1007,1692), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5758,1007,1962), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//first tier left

	InfoClass = AddSupplyPackInfo(vect(5759,-1007,1692), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5888,-1007,1692), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6015,-1007,1692), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//second tier right

	InfoClass = AddSupplyPackInfo(vect(2816,-1006,2587), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2945,-1006,2587), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(3072,-1006,2587), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

//second tier left

	InfoClass = AddSupplyPackInfo(vect(3072,1001,2587), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2945,1001,2587), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2816,1001,2587), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

}

// set up CTF-Darji16
function SetupMap_05()
{
	local Ladder InfoClass;

	//RED BASE
	//bottom of stairwell
	InfoClass = AddSupplyPackInfo(vect(3010,-445,925), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2928,-445,925), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//top of stairwell
	InfoClass = AddSupplyPackInfo(vect(3008,-604,1405), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(3008,-524,1405), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//midfield alcove

	InfoClass = AddSupplyPackInfo(vect(4203,-306,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4203,-418,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

        //rocket launcher near flag

	InfoClass = AddSupplyPackInfo(vect(4954,-2385,1051), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5034,-2465,1051), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//platform ledge near RL

	InfoClass = AddSupplyPackInfo(vect(4923,-1737,1115), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(4923,-1826,1115), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//both sides of main entrance

	InfoClass = AddSupplyPackInfo(vect(5034,-1079,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5034,-1586,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//raised floor near staircase
	InfoClass = AddSupplyPackInfo(vect(5114,-798,123), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5259,-799,123), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//ledge near pipe entrance

	InfoClass = AddSupplyPackInfo(vect(5339,-707,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(5275,-707,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	

	//ledge above small entrance

	InfoClass = AddSupplyPackInfo(vect(6420,-1603,667), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6420,-1730,667), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//right of entrance to flag area

	InfoClass = AddSupplyPackInfo(vect(6826,-2244,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(6826,-2340,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//across from entrance to flag area

	InfoClass = AddSupplyPackInfo(vect(7387,-596,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(7323,-596,923), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//BLUE BASE

	//bottom of stairwell
	InfoClass = AddSupplyPackInfo(vect(2368,-1856,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2448,-1856,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//top of stairwell
	InfoClass = AddSupplyPackInfo(vect(2368,-1696,1403), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(2368,-1776,1403), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//midfield alcove

	InfoClass = AddSupplyPackInfo(vect(1168,-1984,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(1168,-1872,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

        //rocket launcher near flag

	InfoClass = AddSupplyPackInfo(vect(416,80,1051), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(336,160,1051), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//platform ledge near RL

	InfoClass = AddSupplyPackInfo(vect(450,-560,1115), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(450,-464,1115), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//both sides of main entrance

	InfoClass = AddSupplyPackInfo(vect(336,-1211,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(336,-704,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//raised floor near staircase
	InfoClass = AddSupplyPackInfo(vect(256,-1492,123), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(112,-1492,123), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//ledge near pipe entrance

	InfoClass = AddSupplyPackInfo(vect(96,-1584,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(32,-1584,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	

	//ledge above small entrance

	InfoClass = AddSupplyPackInfo(vect(-1047,-720,667), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1047,-593,667), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//right of entrance to flag area

	InfoClass = AddSupplyPackInfo(vect(-1456,-48,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1456,48,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	//across from entrance to flag area

	InfoClass = AddSupplyPackInfo(vect(-2016,-1696,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;

	InfoClass = AddSupplyPackInfo(vect(-1952,-1696,923), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	}
	
// set up CTF-Noxion16
function SetupMap_06()
{
	local Ladder InfoClass;
	
	//RED BASE
	
	//red flagroom
	
        InfoClass = AddSupplyPackInfo(vect(-7952,64,-164), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//bottom of stairwell
	InfoClass = AddSupplyPackInfo(vect(-6592,1264,-1252), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-6592,1151,-1252), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//third floor of stairwell
	
	InfoClass = AddSupplyPackInfo(vect(-6478,304,-740), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-6318,304,-740), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//second floor of stairwell
	
	InfoClass = AddSupplyPackInfo(vect(-6073,1735,-996), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-6217,1735,-996), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//foyer behind column
	
	InfoClass = AddSupplyPackInfo(vect(-5952,128,-228), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-5952,16,-228), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//back entracne foyer
	
	InfoClass = AddSupplyPackInfo(vect(-5952,-1216,-404), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-5952,-1107,-404), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//bottom base entrance
	
	InfoClass = AddSupplyPackInfo(vect(-5024,320,-1252), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
		
	InfoClass = AddSupplyPackInfo(vect(-5024,64,-1252), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//near back RL
	
	InfoClass = AddSupplyPackInfo(vect(-4528,-576,-484), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
			
	InfoClass = AddSupplyPackInfo(vect(-4832,-576,-484), 1);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//top gunner pillbox ammo only
	
	InfoClass = AddSupplyPackInfo(vect(-3648,-464,-228), 1);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	
	//BLUE BASE
	
	//blue flagroom
		
	InfoClass = AddSupplyPackInfo(vect(1808,-7,-164), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
		
	//bottom of stairwell
	InfoClass = AddSupplyPackInfo(vect(443,-1208,-1252), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
		
	InfoClass = AddSupplyPackInfo(vect(443,-1095,-1252), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
		
	//third floor of stairwell
		
	InfoClass = AddSupplyPackInfo(vect(198,-247,-740), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
		
	InfoClass = AddSupplyPackInfo(vect(38,-247,-740), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//second floor of stairwell
	
	InfoClass = AddSupplyPackInfo(vect(-203,-1672,-996), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-59,-1672,-996), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//foyer behind column
	
	InfoClass = AddSupplyPackInfo(vect(-191,-56,-228), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-191,55,-228), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//back entrance foyer
	
	InfoClass = AddSupplyPackInfo(vect(-186,1274,-404), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	InfoClass = AddSupplyPackInfo(vect(-186,1165,-404), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//bottom base entrance
	
	InfoClass = AddSupplyPackInfo(vect(-1120,-258,-1252), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
		
	InfoClass = AddSupplyPackInfo(vect(-1120,-2,-1252), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//near back RL
	
	InfoClass = AddSupplyPackInfo(vect(-1623,639,-484), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
			
	InfoClass = AddSupplyPackInfo(vect(-1320,638,-484), 2);
	InfoClass.Matches = 16;
	InfoClass.TimeLimits[0] = 5;
	InfoClass.TimeLimits[1] = 25;
	InfoClass.TimeLimits[3] = 20;
	
	//top gunner pillbox ammo only
	
	InfoClass = AddSupplyPackInfo(vect(-2511,-558,-228), 2);
	InfoClass.Matches = 0;
	InfoClass.TimeLimits[0] = 5;
	
	}
	
	

defaultproperties
{
     SupportedMapsText="CTF-Orbital, CTF-Cybrosis][, CTF-Hydro16, CTF-HallofGiants, CTF-Darji16, CTF-Noxion16"
     MapDataText="Bonus Pack CTF Map Data"
     MapDataInfoText="Map data for all Bonus Pack CTF maps."
}
