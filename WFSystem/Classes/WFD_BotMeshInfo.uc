//=============================================================================
// WFD_BotMeshInfo.
//=============================================================================
class WFD_BotMeshInfo extends WFD_PawnMeshInfo;

static function BotPlayDodge(pawn Other, bool bDuckLeft);
static function FastInAir(pawn Other);
static function PlayChallenge(pawn Other);
static function PlayLookAround(pawn Other);
static function PlayVictoryDance(pawn Other);
static function PlayWaving(pawn Other);
static function TweenToFighter(pawn Other, float tweentime);

defaultproperties
{
}
