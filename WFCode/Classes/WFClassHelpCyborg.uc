//=============================================================================
// WFClassHelpCyborg.
//=============================================================================
class WFClassHelpCyborg extends WFClassHelpHTMLPage;

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
	$				"<h1>[ - Cyborg - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>Offense</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>199</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>120 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Slow</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Impact Hammer, Mini Flak, ASR Launcher, Plasma Gun.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: EMP.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Plasma, Self Destruct.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: display ability menu."
	$			"<br>\"special plasma [small/medium/large]\" -- arm plasma bomb (small, medium, or large)."
	$			"<br>\"special kami\" -- Activate Kamikaze self destruct sequence."
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
	$			"<br>The Cyborg is the key to breaking a strong defense. When it's feet are firmly planted on "
	$			"the ground the Cyborg can lay a small, medium, or large Plasmabomb which explode after ten, "
	$			"twenty, or thirty seconds respectively. The damage and radius of the explosion are dependant "
	$			"on the size of the explosion The Cyborg can also blow itself up using the Kamikaze special "
	$			"ability. Once enabled, a Cyborg will explode after ten seconds, taking out any enemies nearby. "
	$			"The Cyborg cannot lay a Plasmabomb while going Kamikaze however. The Cyborg also carries an EMP "
	$			"grenade which will disable Sentries for 15 seconds and destroys Turret Grenades."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}