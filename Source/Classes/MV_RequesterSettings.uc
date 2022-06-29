//=============================================================================
// MV_RequesterSettings made by OwYeaW
//=============================================================================
class MV_RequesterSettings expands Object config(UTBT_MapVote) perobjectconfig;
//-----------------------------------------------------------------------------
var config string	HostAddress;
var config string	Update_URI;
var config string	Announcement_URI;
var config string	MapList_URI;
var config string	Categories_URI;
var config int		MapListCheckUpdateIntervalSeconds;
var config string	LastMapListUpdate;
//-----------------------------------------------------------------------------
defaultproperties
{
	HostAddress=""
	Update_URI=""
	Announcement_URI=""
	MapList_URI=""
	Categories_URI=""
	MapListCheckUpdateIntervalSeconds=60
	LastMapListUpdate=""
}