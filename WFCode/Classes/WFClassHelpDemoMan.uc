//=============================================================================
// WFClassHelpDemoMan.
//=============================================================================
class WFClassHelpDemoMan extends WFClassHelpHTMLPage;

static function string GetHTML
(
	optional string Options, 		// an optional string of options/information
	optional int SwitchNum, 		// an optional switch number
	optional Object OptionalObject	// an optional object reference
)
{
	local string HTML, TeamColor;

	TeamColor = GetHTMLTeamColor(GetIntOption(Options, "Team", 0));

	HTML = (
		"<BODY BGCOLOR=\"#000000\" LINK=\"#FF0000\" ALINK=\"#FF00FF\">"
	$		"<font color=#"$TeamColor$">"
	$			"<center>"
	$				"<h1>[ - Demoman - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>General Purpose</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>150</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>100 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Medium</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Impact Hammer, Mini Flak, Pipe Bomb Launcher, Grenade Launcher.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: Freeze.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Laser Tripmine.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: display ability menu."
	$			"<br>\"special setmine\" -- depoy tripmine."
	$			"<br>\"special removemine\" -- remove nearest tripmine."
	$		"</font></p>"

	$		"<p><b>Recommended Key Aliases:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>Use these commands with the \"set input &lt;key&gt; &lt;command&gt;\" console command "
	$			"to bind these aliases to a key. The \"gren1\" and \"gren2\" bindings are input buttons "
	$			"and the longer you hold the key down, the further the grenade from that slot will be thrown."
	$			"<br>"
	$			"<br>\"special\" -- default ability"
	$			"<br>\"button gren1\" -- use grenade slot 1"
	$			"<br>\"button gren2\" -- use grenade slot 2"
	$		"</font></p>"

	$		"<p><b>Class Notes:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>The Demoman is adept at setting explosive traps with his Laser Trip Mines, of which he "
	$			"can set up to four at a time. When an enemy crosses the laser, the mine explodes with a large "
	$			"damage radius. The Demoman can also lay up to six pipebombs using the Pipebomb Launcher. By "
	$			"pressing the alternate fire he can detonate them at will. The Demoman also carries a Grenade "
	$			"Launcher which fires powerful grenades and the alternate fire can propel the grenades a very "
	$			"long distance. Great for bombardment."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}