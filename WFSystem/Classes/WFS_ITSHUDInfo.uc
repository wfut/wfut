//=============================================================================
// WFS_ITSHUDInfo. (ITSHUD render extension)
//=============================================================================
//==========================================================================================
// ITSHUD--Integrated Targeting System
//
// Authors:	Mac and Mek
//
// Thanks to:	GreenMarine, Steve Polge, and Tim Sweeny (EpicGames) for all their help and
//				patience.
//
//				Adam Alpern (Naliwood Productions), for devising the idea to use a single
//				pixel and drawing primatives  for the brackets (thereby avoiding pixel loss
//				from scaling).  This will be included in 1.1REL
//
// This basically finds pawns that a player can see, and figures out x,y Canvas coordinates that
// allow you to overlay text/images on top of those pawns.
//
// 1.1 NOTES:
// ----------------
//
// Ok, 1st off I'd like to thank Adam Alpern again for allowing me to integrate his drawing primatives
// into ITSHUD.  It gives it a great deal more functionality.  Before, I just used one texture for a bracket,
// but there were several problems with that.  1st and foremost, the bracket was REALLY thick when the targets
// were up close, and when the brackets got scaled down a lot for distance targets, you'd occaisonally parts of it
// (scaling down loses pixels).  The solution we are using here is to use a single pixel texture as a pen.  You can
// use the primatives to draw lines, rectangles, etc.  To give you an idea of how much better this works, I used to use
// a 64x64 texture, but that only was usable at a range of 1330 Unreal Units or less.  Using the primatives, I've got it to
// work beautifully at a range of 4000 UU's, and could perhaps work even farther.
//
// Granted, this isn't always going to be what you want to do.  I left the old texture based code in there, but commented
// out.  Still, I recommend Adam's approach whenever possible.  For some reason, it also seems faster, at least on
// my p2-266 voodoo 1 machine.  ITSHUD was always smooth, but *occaissionally* would hitch the video.  This might be simply
// because Glide handles drawing a small texture lots of times better than drawing a larger texture more times.  Who knows :)
//
// I haven't documented Adam's code too much.  I don't have time quite yet :p  but I'll eventually get around to it.  Once I
// document it, I'll release the version (probably 1.1.5) in conjunction with updating the webpage.  I *DEFINITELY* want people
// to be able to understand the concept of what's going on here.  It was *way* too annoying to find good info on this on the Net.
// 1st time I haven't been able to find ANYTHING of use after about 2 weeks of searching.  Go figure.
//
// One more thing:  I've added a few primatives.  They might suck.  If so, deal with it :p  Seriously, they're UNDER DEVELOPMENT.
//
// 1.0 NOTES:
// ----------------
//
//		1)  Commenting style.  Things commented just by // are simply documentation.  Things
//			that have
//			// TODO:  as their main line point out to you where you might make extensions/changes
//			to the code to customize it.
//
//		2)  Texture size.  Scaling textures at a distance requires a bit of trial and error.
//
//				DistanceScale = HeightOfTexture * 10 / Distance * (90/ FieldOfViewAngle)
//
//			worked pretty nicely (when using textures instead of primatives.  As noted below, a
//			64x64 texture seems to scale down pretty well up to a distance of 1330 Unreal Units.
//
//		3)	fX and fY.  Once these are calculated, they represent the coordinates of the center
//			of the targeted pawn.  If you want to draw a texture over the pawn, you'll need to
//			offset fX and fY by 1/2 the width and height respectively, since textures are drawn
//			from the upper left hand corner.
//
//		4)  Text.  When drawing text, there is a "wordwrap" bug.  For instance, the distance info
//			wraps the to right of the screen when your target is *just* within sight on the left.
//			Tim:  It would be REALLY nice if we could turn this off with a parameter... perhaps
//			we're already able to, but I haven't been able to figure it out :p
//
//		4)  Math.  I'll eventually have some nice graphics, etc. on the webpage for ITSHUD
//			explaining the math behind it all.  It'll take some time though...
//
//===========================================================================================
class WFS_ITSHUDInfo extends WFS_HUDInfo;

var(ITSHUD)  float ITS_Range;		// range of the HUD sensor system.  be sensible when using this.
									// If you have a small texture, at a far distance it does NOT scale
									// well.  64x64 texture scales well to a distance of 1330 (observational data)


// from Adam Alpern of Naliwood Productions.  All following code from Adam will be
// denoted by A.A.
var const color COLOR_Black;
var const color COLOR_White;
var const color COLOR_Red;
var const color COLOR_Cyan;
var const color COLOR_Orange;

var const color COLOR_Green;
var const color COLOR_PaleGreen;
var const color COLOR_DarkGreen;

var const color COLOR_Blue;
var const color COLOR_PaleBlue;
var const color COLOR_DarkBlue;

var const color COLOR_Yellow;
var const color COLOR_PaleYellow;
var const color COLOR_DarkYellow;

enum Direction {
  DIR_Up,
  DIR_Down,
  DIR_Left,
  DIR_Right
};

var int PenWidth;
var int PenHeight;

// internal
var Direction tickDirection;

// Colors for the targeting display
var config color TargetingColor;
//********************
// end A.A.
//********************

simulated function PostRender(out byte bDisableFunction, canvas Canvas)
{
	super.PostRender(bDisableFunction, Canvas);
	OwnerHUD.HUDSetup(Canvas);
	DrawITSInfo(Canvas);
}

simulated function DrawITSInfo(canvas Canvas)
{
	local Pawn p;
	local PlayerPawn player;
	local vector vecPawnView;
	local float fX;
	local float fY;
	local float RangeToTarget;
	local float DistanceScale;

	local vector X, Y, Z;

	player = PlayerPawn(OwnerHUD.Owner);
	GetAxes(player.ViewRotation, X, Y, Z);

	foreach RadiusActors(Class'Pawn', p, ITS_Range, player.Location)
	{
	  // Get a vector from the player to the pawn
	  vecPawnView = p.Location - player.Location - (player.EyeHeight * vect(0,0,1));

	  //***********************************************************************************
	  // TODO:  make test more comprehensive.  Don't allow flys or carcasses for instance.
	  //***********************************************************************************
	  if(IsValidTarget(vecPawnView, X, p))  // note that vecPawnView Dot X > 0 ensures that the target is in front of you.
	  {
		// range to the pawn
	  	RangeToTarget = VSize(p.Location - player.Location);

		//************************************************************
		// TODO:  replace '640' with '10 * HeightOfTexture'
		//************************************************************
	  	DistanceScale = (640 / RangeToTarget) * 90 / player.FOVAngle;


		//************************************************************
		//From Tim (9/27/98):
		//
		//	Xscreen = Xresolution/2 + Xworld * Zprojection / Zworld
		//	Yscreen = Yresolution/2 + Yworld * Zprojection / Zworld
 		//
		//	Zprojection = Xresolution * arctan(FieldOfViewAngle) / 2
		//
		//*************************************************************

		//**************************************************************************
		// Mac (9/30/98):  Hmm.  Figured it out.  Looks like Tim just made 3 minor
		// little goofs in his email to me, which I didn't adequately analyze.
		//
		// Here is the CORRECT equation for Zprojection:
		//
		//     Zprojection = (Xresolution / 2) / ( tan(FieldOfViewAngle / 2) )
		//
		//**************************************************************************

		// TODO:  replace '(32 * DistanceScale)' with '(HeightOfTexture / 2 * DistanceScale)'
		fX = (Canvas.ClipX / 2) + ((vecPawnView Dot Y)) * ((Canvas.ClipX / 2) / tan(player.FOVAngle * Pi / 360)) / (vecPawnView Dot X);
		fY = (Canvas.ClipY / 2) + (-(vecPawnView Dot Z)) * ((Canvas.ClipX / 2) / tan(player.FOVAngle * Pi / 360)) / (vecPawnView Dot X);

		// draw stuff!
		DrawTargetInfo(Canvas, fX, fY, DistanceScale, RangeToTarget, p);
	  }
	}
}


//*****************************************************************************************
// TODO:  extend this function to perform the test to see if you want to really draw stuff
// over the pawn, i.e. can you see him, is he on your team, etc...
//*****************************************************************************************
function bool IsValidTarget(vector vecPawnView, vector X, Pawn target)
{
	// note that vecPawnView Dot X > 0 ensures that the target is in front of you.
	if (!(pawn(OwnerHUD.owner).cansee(target)))
	  return false;

	return (target != Pawn(OwnerHUD.Owner)) && ((vecPawnView Dot X) > 0);
}


//********************************************************************
// TODO:  extend this function to draw whatever you want over a pawn.
//********************************************************************
function DrawTargetInfo(Canvas canvas, float screenX, float screenY, float DistanceScale, float RangeToTarget, Pawn target)
{
	// draw range to target info
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.Font = Canvas.SmallFont;
	Canvas.DrawColor.r = 235;
	Canvas.DrawColor.g = 235;
	Canvas.DrawColor.b = 235;

	//*****************************************
	// TODO:  change '64' to 'HeightOfTexture'
	//*****************************************
	Canvas.SetPos(screenX - (target.collisionradius/2 * DistanceScale), screenY + (target.collisionheight/2 * DistanceScale) + 2);
	Canvas.DrawText(int(RangeToTarget) $ "u", false);


	//**********************
	// draw the target icon
	//**********************
	Canvas.DrawColor.r = 0;
	Canvas.DrawColor.g = 195;
	Canvas.DrawColor.b = 0;

	//***************************************************************
	// example of how to use a texture instead of drawing primatives
	//***************************************************************
	// Canvas.SetPos(screenX - (32 * DistanceScale), screenY - (32 * DistanceScale));
	// Canvas.DrawIcon(texture'GreenBracket', DistanceScale);

	//******************************************
	// example of how to use drawing primatives
	//******************************************
	Canvas.DrawColor = TargetingColor;
	Canvas.SetPos(screenX - (target.collisionradius/2  * DistanceScale), screenY - (target.collisionheight/2* DistanceScale));
	ITSDrawBracket(Canvas, target.collisionradius * DistanceScale, target.collisionheight * DistanceScale, 16 * DistanceScale);

//	Canvas.DrawColor = COLOR_Yellow;
//	Canvas.SetPos(screenX, screenY);

	// This command draws an arc from 0 to 360 degrees (a full circle), with a step value
	// of 2 degrees, and uses scaling.  On my 512x[whatever] Voodoo display, this gives the
	// best solid circle with respect to processing time.  Any smaller of an increment doesn't
	// give you a good enough improvment for the added running time cost.
//	ITSDrawArc(canvas, 20, 0, (360 * PI / 180), (2 * PI / 180), true, DistanceScale);

	// reset the drawing style -- IMPORTANT (i think...)
	Canvas.Style = 1;
}

// ------------------------------------------------------------------------------------
// A.A -------> Drawing Primitives (Mac:  note, I changed some names for sake of ease.)
// ------------------------------------------------------------------------------------

// Draw a vertical line
final simulated function ITSDrawVertical(Canvas canvas, float column, float height)
{

    Canvas.SetPos(column, Canvas.CurY);
    Canvas.DrawRect(Texture'ITS_Pen', PenWidth, height);
}

// Draw a horizontal line
final simulated function ITSDrawHorizontal(Canvas canvas, float row, float width)
{
    Canvas.SetPos(Canvas.CurX, row);
    Canvas.DrawRect(Texture'ITS_Pen', width, PenHeight);
}

final simulated function ITSDrawLine(Canvas canvas, Direction direction, float size)
{
    local float X, Y;
    // Save current position
    X = canvas.CurX;
    Y = canvas.CurY;
    switch (direction) {
      case DIR_Up:
	  canvas.SetPos(X, Y - size);
	  canvas.DrawRect(Texture'ITS_Pen', PenWidth, size);
	  break;
      case DIR_Down:
	  canvas.DrawRect(Texture'ITS_Pen', PenWidth, size);
	  break;
      case DIR_Left:
	  canvas.SetPos(X - size, Y);
	  canvas.DrawRect(Texture'ITS_Pen', size, PenHeight);
	  break;
      case DIR_Right:
	  canvas.DrawRect(Texture'ITS_Pen', size, PenHeight);
	  break;
    }
    // Restore position
    canvas.SetPos(X, Y);
}

// By default, the tick is drawn to the right of a vertical line, and
// below a horizontal line. When the optional reverseTick argument is
// true, this is reversed, with vertical ticks on the left side, and
// horizontal ticks above.
final simulated function ITSDrawTickedLine(canvas canvas,
				    Direction direction,
				    float size,
				    float tickSize,
				    float tickInterval,
				    int nTicks,
				    optional bool reverseTick)
{
    local float X, Y;
    local int i, n;

    n = ++nTicks;

    // Save current position
    X = canvas.CurX;
    Y = canvas.CurY;

    switch (direction) {
      case DIR_Up:
      case DIR_Down:
	  if (reverseTick)
	      tickDirection = DIR_Left;
	  else
	      tickDirection = DIR_Right;
	  break;
      case DIR_Left:
      case DIR_Right:
	  if (reverseTick)
	      tickDirection = DIR_Up;
	  else
	      tickDirection = DIR_Down;
	  break;
    }

    ITSDrawLine(canvas, direction, size);

    switch (direction) {
      case DIR_Up:
	  for (i = 0; i <= n; i++) {
	      ITSDrawLine(canvas, tickDirection, tickSize);
	      canvas.SetPos(X, Y - (i * tickInterval));
	  }
	  break;
      case DIR_Down:
	  for (i = 0; i <= n; i++) {
	      ITSDrawLine(canvas, tickDirection, tickSize);
	      canvas.SetPos(X, Y + (i * tickInterval));
	  }
	  break;
      case DIR_Left:
	  for (i = 0; i <= n; i++) {
	      ITSDrawLine(canvas, tickDirection, tickSize);
	      canvas.SetPos(X - (i * tickInterval), Y);
	  }
	  break;
      case DIR_Right:
	  for (i = 0; i <= n; i++) {
	      ITSDrawLine(canvas, tickDirection, tickSize);
	      canvas.SetPos(X + (i * tickInterval), Y);
	  }
	  break;
    }

    // Restore position
    canvas.SetPos(X, Y);
}

// Draw a rect given the absolute coords of the corners
final simulated function ITSDrawRectAbsolute(Canvas canvas, float top,
						float left, float bottom, float right)
{
    local float CurX, CurY;
    CurX = canvas.CurX;
    CurY = canvas.CurY;
    canvas.SetPos(left, top);
    ITSDrawLine(canvas, DIR_Right, right - left);
    ITSDrawLine(canvas, DIR_Down, bottom - top);
    canvas.SetPos(right, bottom);
    ITSDrawLine(canvas, DIR_Left, right - left);
    ITSDrawLine(canvas, DIR_Up, bottom - top);
    canvas.SetPos(CurX, CurY);
}

// Draws a rect at the current position, given height and width
final simulated function ITSDrawRect(canvas canvas, float width, float height)
{
    local float X, Y;
    X = canvas.CurX;
    Y = canvas.CurY;
    canvas.DrawRect(Texture'ITS_Pen', PenWidth, height);
    canvas.DrawRect(Texture'ITS_Pen', width, PenHeight);
    canvas.SetPos(X + width, Y);
    canvas.DrawRect(Texture'ITS_Pen', PenWidth, height);
    canvas.SetPos(X, Y + height);
    canvas.DrawRect(Texture'ITS_Pen', width+1, PenHeight);
    canvas.SetPos(X, Y);
}

final simulated function ITSFillRect(canvas canvas, texture tex, float width, float height)
{
    local float X, Y;
    X = canvas.CurX;
    Y = canvas.CurY;
    canvas.DrawRect(tex, width, height);
    canvas.SetPos(X, Y);
}

final simulated function ITSTileRect(canvas canvas, texture tex, float width, float height, float texture_width, float texture_height)
{
    local float X, Y;
    X = canvas.CurX;
    Y = canvas.CurY;
    canvas.DrawTile(tex, width, height, 0, 0, texture_width, texture_height);
    canvas.SetPos(X, Y);
}

final simulated function ITSDrawBracket(canvas canvas, float width, float height, float bracket_size)
{
    local float X, Y;
    X = canvas.CurX;
    Y = canvas.CurY;

    ITSDrawLine(canvas, DIR_Right, bracket_size);
    ITSDrawLine(canvas, DIR_Down, bracket_size);
    canvas.SetPos(X + width, Y);
    ITSDrawLine(canvas, DIR_Left, bracket_size);
    ITSDrawLine(canvas, DIR_Down, bracket_size);
    canvas.SetPos(X + width, Y + height);
    ITSDrawLine(canvas, DIR_Up, bracket_size);
    ITSDrawLine(canvas, DIR_Left, bracket_size);
    canvas.SetPos(X, Y + height);
    ITSDrawLine(canvas, DIR_Right, bracket_size);
    ITSDrawLine(canvas, DIR_Up, bracket_size);

    canvas.SetPos(X, Y);
}

final simulated function ITSDrawGrid(canvas canvas, float width, float height,
			      float HSpacing, float VSpacing, color grid_color)
{
    local int nH, nV, i;
    local float CurX, CurY;
    local color saved_color;

    // Save position and pen color
    CurX = canvas.CurX;
    CurY = canvas.CurY;
    saved_color = canvas.DrawColor;

    ITSDrawRect(canvas, width, height);

    nH = width / HSpacing;
    nV = height / VSpacing;

    canvas.DrawColor = grid_color;
    // Draw vertical bars
    canvas.SetPos(CurX, CurY + 1);
    for (i = 1; i < nH; i++) {
	canvas.SetPos(CurX + (i * HSpacing), CurY + 1);
	ITSDrawLine(canvas, DIR_Down, height - 1);
    }
    // Draw horizontal bars
    canvas.SetPos(CurX + 1, CurY);
    for (i = 1; i < nV; i++) {
	canvas.SetPos(CurX + 1, CurY + (i * HSpacing));
	ITSDrawLine(canvas, DIR_Right, width - 1);
    }

    // Restore position and pen color
    canvas.SetPos(CurX, CurY);
    canvas.DrawColor = saved_color;
}

// end A.A.

//*************************************************
// Mac's contributions to the drawing primatives.
//*************************************************

//---------------------------------
// Draws an arc (part of a circle).
//
// Note:  to convert from degrees to radians, multiply by (PI / 180).  Also, this is a *slow* function.
//			I can't wait to convert it to DLL code.
//
// canvas = the canvas, duh....
// radius = the radius of the "circle"
// startAngle = that, times the radius, gives you the starting point of the arc.
//				Measured in RADIANS!
// endAngle = that, times the radius, gives you the ending point of the arc.
//				Measured in RADIANS!
// deltaTheta = an arc is just a series of points.  the smaller this is, the greater
//				"resolution" your arc will have.  If it is big, you'll only draw a few pixels.
//				Measured in RADIANS!
// useScaling = (optional) scale all calculations for distance
// DistanceScale = (optional) the scaling factor
//----------------------------------
final simulated function ITSDrawArc(canvas canvas, float radius,
									float startAngle, float endAngle, float deltaTheta,
									optional bool useScaling, optional float DistanceScale)
{
	local float oldX, oldY, theta, X, Y;
    oldX = canvas.CurX;
    oldY = canvas.CurY;

    if(useScaling)
    {
    	radius = radius * DistanceScale;
    	deltaTheta = deltaTheta / DistanceScale;
    }

    for(theta = startAngle; theta <= endAngle; theta += deltaTheta)
    {
    	X = radius * cos(theta);
    	Y = radius * sin(theta);

    	canvas.CurX += X;
    	canvas.CurY -= Y;	// y orientation of screen has 0 at top, ClipY at bottom (which is positive)
   		Canvas.DrawRect(Texture'ITS_Pen', PenWidth, PenHeight);

   		// need to reset position to center of circle.
	    canvas.SetPos(oldX, oldY);
    }

    // reset everything
    canvas.SetPos(oldX, oldY);
}

defaultproperties
{
     ITS_Range=4000.000000
     COLOR_White=(R=255,G=255,B=255)
     COLOR_Red=(R=255)
     COLOR_Cyan=(G=255,B=255)
     COLOR_Orange=(R=255,G=102)
     COLOR_Green=(G=255)
     COLOR_PaleGreen=(R=140,G=192,B=108)
     COLOR_DarkGreen=(G=64)
     COLOR_Blue=(B=255)
     COLOR_PaleBlue=(R=142,G=205,B=240)
     COLOR_DarkBlue=(B=64)
     COLOR_Yellow=(R=255,G=255)
     COLOR_PaleYellow=(R=255,G=240,B=158)
     COLOR_DarkYellow=(R=64,G=64)
     PenWidth=1
     PenHeight=1
     TargetingColor=(G=255)
}
