//=============================================================================
// WFClassHelpEngineer.
//=============================================================================
class WFClassHelpEngineer extends WFClassHelpHTMLPage;

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
	$				"<h1>[ - Engineer - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>Support</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>75</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>100 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Medium</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Robotic Hand, Mini Flak, Tesla Coil, Rail Gun.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: Shock.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Sentry Cannon, Supply Depot, Alarm.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: display build menu."
	$			"<br>\"special build\" -- build sentry cannon."
	$			"<br>\"special remove\" -- remove sentry cannon (can only remove own cannon)."
	$			"<br>\"special upgrade\" -- upgrade cannon."
	$			"<br>\"special addammo\" -- add ammo to cannon."
	$			"<br>\"special repair\" -- repair cannon."
	$			"<br>\"special rotateL\" -- rotate cannon 45° left."
	$			"<br>\"special rotateR\" -- rotate cannon 45° right."
	$			"<br>\"special destruct\" -- self destruct cannon."
	$			"<br>\"special builddepot\" -- build supply depot."
	$			"<br>\"special destructdepot\" -- self destruct supply depot."
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
	$			"<br>Collect armor and backpacks to gain resources for building. Build and maintain an automatic cannon "
	$			"to defend key areas in your base, and build a supply depot to help your team mates resupply themselves."
	$			"<br>"
	$			"<br>The amount of resources carried is displayed in the top-right of the HUD (just below health) and the "
	$			"maximum resources that you can carry is 150. When collecting armor you recieve 1/2 the armor value in resources. "
	$			"It costs 100 resources to build a cannon, 80 to build a supply depot, and no resources to deploy an Alarm."
	$		"</font></p>"
	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}