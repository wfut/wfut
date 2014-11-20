=====================
WFUT Development Code
=====================

Updated: 22-12-2000

This code is the current precompiled state of the WFUT source code.

NOTE: Make sure that you also download and install the latest version of the 
      WFUT skin package, otherwise the custom skins will not be displayed.

Installation:
-------------
1) Delete WF*.* from your UT\System folder.
2) Extract all the files to the UT\System folder.

Setting up WFUT to use the WFUT Player Classes:
----------------------------------------------
1) Start up UT normally
2) Open the game window (either start practice session, or start mutliplayer game)
3) Select "Weapons Factory" as the game category
4) Select the "Setting" tab
5) Click on the "Configure Classes" button
6) Select "WF Dev. classes" for each team

Starting a WFUT game:
--------------------
1) Make sure you have set up the player classes (see above)
2) Set up the game using the "Rules" and "Settings" tabs

If you are planning on doing some network testing of the code, make sure you add
these lines to the ServerPackages list in UnrealTournament.ini:

ServerPackages=WFUTSkins
ServerPackages=WFMedia
ServerPackages=WFData
ServerPackages=WFSystem
ServerPackages=WFCode
ServerPackages=WFWeapons
ServerPackages=WFPlayerClasses


Recommended key aliases:
========================
Use these commands with the "set input <key> <command>" console command to bind these 
aliases to a key. The "gren1" and "gren2" bindings are input buttons and the longer you 
hold the key down, the further the grenade from that slot will be thrown.

"special"                     - to bind to the default ability for the player classes
"button Gren1"                - binds <key> to grenade slot 1
"button Gren1"                - binds <key> to grenade slot 2

You can access all the class specific abilities through the "special" command, so its
possible to play WFUT with only 3 key bindings.

Example key bindings:

set input r special           - Binds 'r' to default class ability.
set input f button gren 1     - Binds 'f' to grenade slot 1.


Chat macros
===========
WFUT supports chat macros (coded by ca). Chat macros can be used to auto-insert text when 
sending message, eg: if you had 100 health and your location was Red Base, then sending the 
message: "I'm at %L with %H health" would appear as: "I'm at Red Base with 100 health".

Here is a list of the currently supported chat macros:

%N - player name
%L - player location
%S - player status (health/armor)
%C - player class
%H - player health
%A - player armor
%B - buddies, lists friendly players within radius
%W - player weapon
%T - test code
%% - print the '%' character


Custom Flag Skins:
==================
The flag textures can be customised selecting the "Settings" tab of the Weapons Factory
new game setup menu and clicking on the "Customise Flags" button.

You can create a flag skin pack by creating the new flag skin(s) and name the package
"WFFlag<name>.utx" where <name> should be a unique name identifying the skin package.
For the flag menu to detect the new skin, you must create a file called "WFFlag<name>.int"
and add an Object line for each of the skins in the package:

[Public]
Object=(Name=WFFlag<name>.<skin name>,Class=Texture,Description="My team flag")

It might be a good idea to include the colour of the flag in the Description field
but its not necessary. It just saves viewing the skin to determine its colour.


Currently supported commands:
=============================

Game commands:
--------------
SetClass <classname>     	- Change the player class to <classname>
                        	  Will display the class menu of no class name specified.
                        	  If used during play, it will set the class that you will
                          	  start as after respawning.

ChangeClass <classname>		- (Same as SetClass)

Special <command>	        - execute a player class command (default command for the current
                         	  player class is used if <command> not specified)

ClassHelp 	             	- displays a help dialog for the current player class

Team [red|blue|green|gold]	- change team

SetTeamPassword <password>  - sets the team password that'll be used when changing teams
                              (only used when team passwords are enabled)

DropAmmo <amount>           - drop <amount> ammo from selected weapon, if no amount is
                              specified, then the default amount for the ammo type is used



Player class commands:
----------------------
--- Engineer ---
special                  - (default command) display build menu
special build            - build a sentry
special remove           - remove your sentry (can't remove another players)
special addammo          - add ammo to a nearby sentry
special repair           - repair a nearby sentry
special upgrade          - upgrade a nearby sentry
special RotateL          - rotate a sentry left
special RotateR          - rotate a sentry right
special destruct         - self destruct cannon
special builddepot       - build supply depot
special destructdepot    - supply depot self destruct
special deployalarm      - deploy alarm

--- Infiltrator ---
special                  - (default command) display disguise menu
special cloak            - activate/deactivate cloaking device
special disguise [...]   - disguise command

--- Recon ---
special                  - (default command) use thrust pack
special thrust           - use thrust pack

--- Field Medic ---
special                  - (default command) display menu

--- Gunner ---
special                  - (default command) display menu
special setmine          - deploy instagib laser tripmine
special removemine       - remove instagib laser tripmine

--- Cyborg ---
special                  - (default command) display menu

--- Demoman ---
special                  - (default command) display menu
special setmine          - deploy laser tripmine
special removemine       - remove laser tripmine


Debug commands*:
----------------
FireTest                 - Test out the "On Fire" condition
FrozenTest               - Test out the "Frozen" condition
TranqTest                - Test out the "Tranquilised" condition
InfectTest               - Test out the "Infected" condition
ConcTest                 - Test out the "Concussed" condition
BlindedTest              - Test out the "Blinded" condition

ClearConstFog            - Reset the current ConstantGlowFog vector
ConstGlow                - Display the current value of the constant glow fog

DefaultState             - Send player to the default player state (usually 'PlayerWalking')
GetState                 - Display the current state name
SetState <name>          - Change the player state to <name>

GetPlayerPhysics         - Displays the players current physics
SetPlayerPhysics         - Changes the players physics

* not active in public release

NOTE: All above commands can be bound to keys as explained above.