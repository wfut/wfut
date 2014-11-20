//=============================================================================
// WFClassHelpGunner.
//=============================================================================
class WFClassHelpGunner extends WFClassHelpHTMLPage;

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
	$				"<h1>[ - Gunner - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>Defense</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>199</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>120 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Slow</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Impact Hammer, Enforcer, Minigun, Chain Cannon.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: Decloaker.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Instagib Laser Tripmine, Alarm.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: None"
	$			"<br>\"special setmine\" -- depoy instagib tripmine."
	$			"<br>\"special removemine\" -- remove instagib tripmine."
	$			"<br>\"special deployalarm\" -- deploy alarm."
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
	$			"<br>The Gunner is a major backbone to a good defense. The Chaincannon dishes out extreme damage "
	$			"at the cost of quickly depleting ammo. The Gunner's Instagib Laser Defense will shoot a shockbeam "
	$			"that guarentees a kill if an enemy crosses it but only lasts for five shots. The Gunner also "
	$			"carries the Decloaking Grenade which depletes a cloaked Infiltrator's energy to zero when an "
	$			"Infiltrator is within it's radius of effect. The Gunner can also deploy an alarm to warn of "
	$			"incoming enemies."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}