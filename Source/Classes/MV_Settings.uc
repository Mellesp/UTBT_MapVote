//=============================================================================
// MV_Settings made by OwYeaW
//=============================================================================
class MV_Settings expands Object config(UTBT_MapVote) perobjectconfig;

var config string	HostAddress;
var config string	Update_URI;
var config string	Announcement_URI;
var config string	MapList_URI;
var config string	Categories_URI;

var config int		MapListCheckUpdateIntervalSeconds;
var config bool		bAllowSpectatorVotes;
var config bool		bAddRatingCategories;
var config name		MapListCacheName;

var config int		MidGameVotePercent;
var config int		VoteTimeLimit;
var config int		ScoreBoardDelay;

var config bool		bSwitchToRandomMapAtFailedMapSwitch;
var config bool		bSwitchLevelOnEmptyServer;
var config int		EmptyServerTimeMinutes;
var config bool		bSwitchToRandomMap;
var config string	DefaultMap;

defaultproperties
{
	HostAddress="soupy.utbt.net"
	Update_URI="/update.ini"
	Announcement_URI="/announcement.ini"
	MapList_URI="/maplist.ini"
	Categories_URI="/categories.ini"
	MapListCacheName="SummerRush"
	MapListCheckUpdateIntervalSeconds=60
	bAllowSpectatorVotes=true
	bAddRatingCategories=true

	ScoreBoardDelay=10
	VoteTimeLimit=60
	MidGameVotePercent=50

	bSwitchToRandomMapAtFailedMapSwitch=false
	bSwitchLevelOnEmptyServer=true
	EmptyServerTimeMinutes=1
	bSwitchToRandomMap=true
	DefaultMap="CTF-BT-MaverickCB"
}