//=============================================================================
// MV_Settings made by OwYeaW
//=============================================================================
class MV_Settings expands Object config(UTBT_MapVote) perobjectconfig;
//-----------------------------------------------------------------------------
var config string	MapListCacheName;

var config bool		bAllowSpectatorVotes;
var config bool		bAddRatingCategories;
var config int		MidGameVotePercent;
var config int		VoteTimeLimit;
var config int		ScoreBoardDelay;

var config bool		bSwitchToRandomMapAtFailedMapSwitch;
var config bool		bSwitchLevelOnEmptyServer;
var config int		EmptyServerTimeMinutes;
var config bool		bSwitchToRandomMap;
var config string	DefaultMap;
//-----------------------------------------------------------------------------
defaultproperties
{
	MapListCacheName=""

	bAllowSpectatorVotes=false
	bAddRatingCategories=true
	MidGameVotePercent=50
	VoteTimeLimit=60
	ScoreBoardDelay=10

	bSwitchToRandomMapAtFailedMapSwitch=false
	bSwitchLevelOnEmptyServer=true
	EmptyServerTimeMinutes=2
	bSwitchToRandomMap=true
	DefaultMap=""
}