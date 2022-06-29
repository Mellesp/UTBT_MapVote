//=============================================================================
// MV_Client made by OwYeaW
//=============================================================================
class MV_Client expands ReplicationInfo;
//-----------------------------------------------------------------------------
var MV_Mutator	Mut;
var MV_Cache	Cache;
var MV_Cache	ClientCache;
var MV_WRI		WRI;

var int MapCount, CatCount, AnnCount;
var string MD5;
var string	RA_1[256], RA_2[256], RA_3[256], RA_4[256], RA_5[256], RA_6[256], RA_7[256], RA_8[256],
RA_9[256], RA_10[256], RA_11[256], RA_12[256], RA_13[256], RA_14[256], RA_15[256], RA_16[256], CA[128], AA[128];

var float LoadingTime;
var int OriginalClientNetspeed;

var bool bAddRatingCategories;
var bool bReady;
var name CacheNameHolder;

replication
{
	reliable if(Role < ROLE_Authority)
		compareCacheWithServer, finishedLoadingMapList;

	reliable if(Role == ROLE_Authority)
		getClientCache, clientStartCounter, MD5, bAddRatingCategories, bReady,
		RA_1, RA_2, RA_3, RA_4, RA_5, RA_6, RA_7, RA_8, RA_9,
		RA_10, RA_11, RA_12, RA_13, RA_14, RA_15, RA_16, CA, AA;
}
//-----------------------------------------------------------------------------
function Init(MV_Mutator M)
{
	Mut						= M;
	Cache					= M.Cache;
	bAddRatingCategories	= M.Settings.bAddRatingCategories;

	getClientCache(M.Settings.MapListCacheName);
}

simulated function getClientCache(string MapListCacheName)
{
	local int i;
	local string s, ClientMD5;
	local ENetRole tmpRole;
	local Object Obj;

	//----------
	// Hacky way to create a name client side - Thanks Buggie
	tmpRole = Role;
	Role = ROLE_Authority;
	SetPropertyText("CacheNameHolder", MapListCacheName);
	Role = tmpRole;
	//----------

	Obj = new (none, CacheNameHolder) class'Object';
	ClientCache = new (Obj, 'UTBT_MapVote') class'MV_Cache';
	ClientCache.SaveConfig();

	for(i = 0; i < arraycount(ClientCache.Maps); i++)
	{
		if(ClientCache.maps[i] == "")
			break;

		s = s $ ClientCache.maps[i];
	}

	for(i = 0; i < arraycount(ClientCache.Categories); i++)
	{
		if(ClientCache.Categories[i] == "")
			break;

		s = s $ ClientCache.Categories[i];
	}

	s = s $ ClientCache.Announcement;
	ClientMD5 = Class'uHash'.static.MD5(s);

	compareCacheWithServer(ClientMD5, ClientCache.MD5);
}

function compareCacheWithServer(string ClientMD5, string ClientCacheMD5)
{
	if(Cache.MD5 != ClientMD5 || Cache.MD5 != ClientCacheMD5)
	{
		Log("[UTBT]-[MapVote]-[Client needs Maplist update]");
		PlayerPawn(Owner).ClientMessage("[UTBT MapVote] Downloading new Maplist...");
		startMapListReplication();
	}
	else
	{
		Log("[UTBT]-[MapVote]-[Client is up to date]");
		bReady = true;
	}
}

function startMapListReplication()
{
	// saving client original netspeed. setting client netspeed to a minimum value of 25k to increase download speed
	OriginalClientNetspeed = PlayerPawn(Owner).player.CurrentNetSpeed;
	PlayerPawn(Owner).player.CurrentNetSpeed = Min(int(ConsoleCommand("get IpDrv.TcpNetDriver MaxClientRate")), 25000);
	sendNewMapListToClient();
}

function sendNewMapListToClient()
{
	local int i, x;
	local string ann;

	MD5 = Cache.MD5;

	// Maps
	for(i = 0; i < ArrayCount(Cache.maps); i++)
	{
		if(Cache.Maps[i] == "")
		{
			MapCount = i;
			break;
		}

		if(i < 256)			RA_1[i]				= Cache.maps[i];
		else if(i < 512)	RA_2[i - 256]		= Cache.maps[i];
		else if(i < 768)	RA_3[i - 512]		= Cache.maps[i];
		else if(i < 1024)	RA_4[i - 768]		= Cache.maps[i];
		else if(i < 1280)	RA_5[i - 1024]		= Cache.maps[i];
		else if(i < 1536)	RA_6[i - 1280]		= Cache.maps[i];
		else if(i < 1792)	RA_7[i - 1536]		= Cache.maps[i];
		else if(i < 2048)	RA_8[i - 1792]		= Cache.maps[i];
		else if(i < 2304)	RA_9[i - 2048]		= Cache.maps[i];
		else if(i < 2560)	RA_10[i - 2304]		= Cache.maps[i];
		else if(i < 2816)	RA_11[i - 2560]		= Cache.maps[i];
		else if(i < 3072)	RA_12[i - 2816]		= Cache.maps[i];
		else if(i < 3328)	RA_13[i - 3072]		= Cache.maps[i];
		else if(i < 3584)	RA_14[i - 3328]		= Cache.maps[i];
		else if(i < 3840)	RA_15[i - 3584]		= Cache.maps[i];
		else				RA_16[i - 3840]		= Cache.maps[i];
	}

	// Cats
	for(i = 0; i < ArrayCount(Cache.Categories); i++)
	{
		if(Cache.Categories[i] == "")
		{
			CatCount = i;
			break;
		}

		CA[i] = Cache.Categories[i];
	}

	// Announcement
	ann = Cache.Announcement;
	while(len(ann) > 256)
	{
		AA[x++] = Left(ann, 256);
		ann = Right(ann, len(ann) - 256);
	}
	AA[x++] = ann;

	AnnCount = x;

	// start checking received data on client
	clientStartCounter(MapCount, CatCount, AnnCount);
}

simulated function clientStartCounter(int MC, int CC, int AC)
{
	MapCount = MC;
	CatCount = CC;
	AnnCount = AC;

	LoadingTime = Level.TimeSeconds;
	SetTimer(0.5, false);
}

simulated function Timer()
{
	local int i, loadedMaps, loadedCats, loadedAnns;
	local string TimeStr;

	for(i = 0; i < 256 && RA_1[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_2[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_3[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_4[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_5[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_6[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_7[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_8[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_9[i] != "" ; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_10[i] != ""; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_11[i] != ""; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_12[i] != ""; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_13[i] != ""; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_14[i] != ""; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_15[i] != ""; i++) loadedMaps++;
	for(i = 0; i < 256 && RA_16[i] != ""; i++) loadedMaps++;
	for(i = 0; i < ArrayCount(CA) && CA[i] != ""; i++) loadedCats++;
	for(i = 0; i < ArrayCount(AA) && AA[i] != ""; i++) loadedAnns++;

	if(loadedMaps != MapCount || loadedCats != CatCount || loadedAnns != AnnCount)
	{
		TimeStr = string((Level.TimeSeconds - LoadingTime));
		TimeStr = Left(TimeStr, InStr(TimeStr, ".") + 2);
		Log("[UTBT]-[MapVote]-[Loading Maplist Data] ["$loadedMaps$"/"$MapCount$" maps] ["$loadedCats$"/"$CatCount$" categories] ["$TimeStr$" seconds]");
		SetTimer(0.1, false);
		return;
	}
	else
	{
		TimeStr = string((Level.TimeSeconds - LoadingTime));
		TimeStr = Left(TimeStr, InStr(TimeStr, ".") + 2);
		Log("[UTBT]-[MapVote]-[Finished loading Data] ["$loadedMaps$"/"$MapCount$" maps] ["$loadedCats$"/"$CatCount$" categories] ["$TimeStr$" seconds]");
		writeClientCache();
		finishedLoadingMapList();
	}
}

function finishedLoadingMapList()
{
	local int i;

	// reset client netspeed to its original value
	PlayerPawn(Owner).player.CurrentNetSpeed = OriginalClientNetspeed;
	PlayerPawn(Owner).ClientMessage("[UTBT MapVote] Download finished!");
	bReady = true;
	refreshWRI();

	// clean up replication arrays
	for(i = 0; i < arraycount(RA_1); i++)
	{
		RA_1[i] = "";
		RA_2[i] = "";
		RA_3[i] = "";
		RA_4[i] = "";
		RA_5[i] = "";
		RA_6[i] = "";
		RA_7[i] = "";
		RA_8[i] = "";
		RA_9[i] = "";
		RA_10[i] = "";
		RA_11[i] = "";
		RA_12[i] = "";
		RA_13[i] = "";
		RA_14[i] = "";
		RA_15[i] = "";
		RA_16[i] = "";

		if(i < 128)
		{
			CA[i] = "";
			AA[i] = "";
		}
	}
}

function refreshWRI()
{
	if(WRI != None)
		WRI.Refresh();
}

simulated function writeClientCache()
{
	local int i;
	local string announcement;

	// first clean up the arrays
	for(i = 0; i < arraycount(ClientCache.Maps); i++)
		ClientCache.maps[i] = "";

	for(i = 0; i < arraycount(ClientCache.Categories); i++)
		ClientCache.Categories[i] = "";

	// now fill up the arrays with data
	// Maps
	for(i = 0; i < arraycount(ClientCache.Maps); i++)
	{
		if(i < 256)			ClientCache.maps[i] = RA_1[i];
		else if(i < 512)	ClientCache.maps[i] = RA_2[i - 256];
		else if(i < 768)	ClientCache.maps[i] = RA_3[i - 512];
		else if(i < 1024)	ClientCache.maps[i] = RA_4[i - 768];
		else if(i < 1280)	ClientCache.maps[i] = RA_5[i - 1024];
		else if(i < 1536)	ClientCache.maps[i] = RA_6[i - 1280];
		else if(i < 1792)	ClientCache.maps[i] = RA_7[i - 1536];
		else if(i < 2048)	ClientCache.maps[i] = RA_8[i - 1792];
		else if(i < 2304)	ClientCache.maps[i] = RA_9[i - 2048];
		else if(i < 2560)	ClientCache.maps[i] = RA_10[i - 2304];
		else if(i < 2816)	ClientCache.maps[i] = RA_11[i - 2560];
		else if(i < 3072)	ClientCache.maps[i] = RA_12[i - 2816];
		else if(i < 3328)	ClientCache.maps[i] = RA_13[i - 3072];
		else if(i < 3584)	ClientCache.maps[i] = RA_14[i - 3328];
		else if(i < 3840)	ClientCache.maps[i] = RA_15[i - 3584];
		else				ClientCache.maps[i] = RA_16[i - 3840];
	}

	// Cats
	for(i = 0; i < ArrayCount(CA); i++)
	{
		if(CA[i] == "")
			break;

		ClientCache.Categories[i] = CA[i];
	}

	// Announcement
	for(i = 0; i < ArrayCount(AA); i++)
	{
		if(CA[i] == "")
			break;

		announcement = announcement $ AA[i];
	}

	ClientCache.MD5 = MD5;
	ClientCache.Announcement = announcement;
	ClientCache.SaveConfig();
}

function Tick(float DeltaTime)
{
	if(Owner == None)
		Destroy();
}

function Update()
{
	if(Cache.MD5 != MD5)
	{
		startMapListReplication();
		bReady = false;
	}
	else
	{
		bReady = true;
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=60
	bReady=false
}