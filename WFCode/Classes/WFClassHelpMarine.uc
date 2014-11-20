//=============================================================================
// WFClassHelpMarine.
//=============================================================================
class WFClassHelpMarine extends WFClassHelpHTMLPage;

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
	$				"<h1>[ - Marine - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>General Purpose</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>150</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>100 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Medium</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Impact Hammer, Mini Flak, Hyperblaster, Rocket Launcher.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: Turret.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>None.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	//$			"<br>\"special\" -- default ability: None"
	$			"<br>None."
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
	$			"<br>The Marine is the perfect all-around offensive/defensive player. His Turret Grenades and "
	$			"Rocket Launcher make the Marine a fine flag defender and the Marine's speed and armor make the "
	$			"class excellent on offense as well. The Marine can deploy up to two Turret Grenades at a time "
	$			"which will hover for a short period and shoot a shockbeam at any enemies within it's range. The "
	$			"Marine can also fire homing rockets using the Rocket Launcher's alternate fire. The downside is "
	$			"that homing rockets only do half the damage of normal rockets."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}