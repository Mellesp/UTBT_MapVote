//=============================================================================
// WindowReplicationInfo. Original made by Mongo and Dr Sin. Edit by OwYeaW
//=============================================================================
class MV_WRI expands ReplicationInfo;

var MV_Mutator		Mut;
var int 			WinLeft, WinTop, WinWidth, WinHeight; 	// Dims of the window
var bool 			DestroyOnClose;                   		// Whether the WRI should destroy itself when the window closes
var MV_MainWindow 	Main;                 					// Client Side Variables, Holds a pointer to the window
var int 			TicksPassed;                         	// Ticks passed since the creation of the uwindows root (counts up to two)
var MV_CLient		Client;
//-----------------------------------------------------------------------------
replication
{
	// Functions that Server calls on the Client
	reliable if(Role == ROLE_Authority)
    	OpenWindow, CloseWindow, ClearStatus, AddPlayer, AddVote, Refresh, Client, ClearAll;

	// Function the Client calls on the Server
	reliable if(Role < ROLE_Authority)
    	DestroyWRI, VoteMapServer, GetStatusUpdate;
}
//-----------------------------------------------------------------------------
// Post(Net)BeginPlay - ��� �������������� �������, ������� ���������� �����, and creates a window on the appropriate machine.
// Intended for the user attempting to create the window

// The OpenWindow should only be called from one place: the owner's machine.
// To detect when we are on the owner's machine, we check the playerpawn's Player var, and their console.
// Since these only exist on the machine for which they are used, 
//   their existence ensures we are running on the owner's machine.
// Once that has been validated, we call OpenWindow.

// The reason for BOTH the PostNetBeginPlay and PostBeginPlay is slightly strange.
// PostBeginPlay is called on the client if it is simulated, but it is before the variables have been replicated
//   Thus, Owner is not replicated yet, and the WRI is unable to spawn the window
// PostNetBeginPlay is called after the variables have been replicated, and so is appropriate
//   It is not called on the server machine (NM_Standalone or NM_Listen) because no variables are replicated to that machine
//   And so, PostBeginPlay is needed for those types of servers
//-----------------------------------------------------------------------------
event PostBeginPlay()
{ 
	Super.PostBeginPlay();
	OpenIfNecessary();
}

//-----------------------------------------------------------------------------
simulated event PostNetBeginPlay()
{
	Super.PostBeginPlay();
	OpenIfNecessary();
}

//-----------------------------------------------------------------------------
simulated function OpenIfNecessary()
{
	local PlayerPawn P;

	if(Owner != None)
	{
		P = PlayerPawn(Owner);
		if(P != None && P.Player != None && P.Player.Console != None)
			OpenWindow();
	}
}

//-----------------------------------------------------------------------------
// OpenWindow - This is a client-side function who's job is to open on the window on the client.
// Intended for the user attempting to create the window

// This first does a lot of checking to make sure the player has a console.
// Then it creates and sets up UWindows if it has not been set up yet.
// This can take a long period of time, but only happens if you join from GameSpy.
//   (eg: connect to a server without using the uwindows stuff to do it)
// Then it sets up bQuickKeyEnable so that the menu/status bar don't show up.
// And finally, says to launch the window two ticks from the call to OpenWindow.
// If the Root could have been created this tick, then it does not contain the height and width
//   vars that are necessary to position the window correctly.
//-----------------------------------------------------------------------------
simulated function bool OpenWindow()
{
	local PlayerPawn P;
	local WindowConsole C;

	P = PlayerPawn(Owner);
	if(P == None)
	{
		log("#### -- Attempted to open a window on something other than a PlayerPawn");
		DestroyWRI();
		return false;
	}

	C = WindowConsole(P.Player.Console);
	if(C == None)
	{
		Log("#### -- No Console");
		DestroyWRI();
		return false;
	}

	// Tell the console to create the root
	if(!C.bCreatedRoot || C.Root == None)
		C.CreateRootWindow(None);

	// Hide the status and menu bars and all other windows, so that our window alone will show
	C.bQuickKeyEnable = true;
	// �������� ���� �� 2 �������
	C.LaunchUWindow();

	// tell tick() to create the window in 2 ticks from now, to allow time to get the uwindow size set up
	TicksPassed = 1;
	return true;
}

//-----------------------------------------------------------------------------
// Tick - Counts down ticks in TickPassed until they hit 0, at which point it really creates the window
// Also destroys the WRI when they close the window if DestroyOnClose == true
// Intended for the user attempting to create the window, or close the window

// See the description for OpenWindow for the reasoning behind this Tick.
// After two ticks, it creates the window in the base Root, and sets it up to work with bQuickKeyEnable.

// This also calls DestroyWRI if the WRI is setup to DestroyOnClose, and the window is closed
//-----------------------------------------------------------------------------
simulated function Tick(float DeltaTime)
{
	if(Owner == None)
		Destroy();

	if(TicksPassed != 0)
	{
		if(TicksPassed++ == 2)
		{
			if(SetupWindow())
			{
				if(Client.bReady)
					loadData();
				else
					ClearAll();
			}
			// Reset TicksPassed to 0
			TicksPassed = 0;
		}
	}

	if(DestroyOnClose && Main != None && !Main.bWindowVisible)
		DestroyWRI();
}

simulated function loadData()
{
	local int i, posM, posR;
	local string str, mapName, mapRating, mapCats;
	local bool bHasRating;

	if(Level.Netmode != NM_Client)
		return;
	
	//	Add maps
	for(i = 0; i < ArrayCount(Client.ClientCache.Maps); i++)
	{
		bHasRating = false;

		str = Client.ClientCache.Maps[i];
		if(str == "")
			break;

		posM = InStr(str, "*");
		if(posM > 0)
		{
			bHasRating = true;
			mapName = Left(str, posM);
		}

		posR = InStr(str, "|");
		if(posR > 0)
		{
			if(!bHasRating)
			{
				mapName = Left(str, posR);
				mapRating = "X";
			}
			else
			{
				mapRating = Mid(str, posM + 1, posR - posM - 1);
			}
			mapCats = Right(str, len(str) - posR - 1);
		}

		Main.AddMap(mapName, mapRating, mapCats);
	}

	// Add Cats
	if(Client.bAddRatingCategories)
	{
		for(i = 10; i >= 0; i--)
			Main.AddCategory("Rating "$i, i, true);
	}

	for(i = 0; i < ArrayCount(Client.ClientCache.Categories); i++)
	{
		str = Client.ClientCache.Categories[i];
		if(str == "")
			break;
		Main.AddCategory(str, i, false);
	}

	// Add Announcement
	Main.SetAnnouncement(Client.ClientCache.Announcement);

	GetStatusUpdate();
	Main.LoadedData();
}

//-----------------------------------------------------------------------------
simulated function bool SetupWindow()
{
	local WindowConsole C;

	C = WindowConsole(PlayerPawn(Owner).Player.Console);
	Main = MV_MainWindow(C.Root.CreateWindow(class'MV_MainWindow', WinLeft, WinTop, WinWidth, WinHeight));
	if(Main == None)
	{
		Log("#### -- CreateWindow Failed");
		DestroyWRI();
		return false;
	}

	if(C.bShowConsole)
		C.HideConsole();

	// Make it show even when everything else is hidden through bQuickKeyEnable
	Main.bLeaveOnScreen = true;
	// Show the window
	Main.ShowWindow();
	Main.WRI = Self;

	return true;
}

//-----------------------------------------------------------------------------
// CloseWindow -- This is a client side function that can be used to close the window.
// Intended for the user attempting to create the window

// Undoes the bQuickKeyEnable stuff just in case
// Then turns off the Uwindow mode, and closes the window.
//-----------------------------------------------------------------------------
simulated function CloseWindow()
{
	local WindowConsole C;

	if(Level.Netmode != NM_Client)
		return;

	C = WindowConsole(PlayerPawn(Owner).Player.Console);
	C.bQuickKeyEnable = False;
	C.CloseUWindow();
	if(Main != None)
		Main.Close();
}

// ==========================================================================
// These functions happen on the server side
// ==========================================================================
// DestoryWRI - Gets rid of the WRI and cleans up.
// Intended for the server or authority, which *could* be the user that had the window (in a listen server or standalone game)
// DestoryWRI - izbavliaetsia ot WRI i ochishet pamiat naverno..
// prednaznacheno dlia servera ili avtority, kotorim mog bit polzovatel imeushii okno( listen server ili odinochnaia igra)

// Should be called from the client when the user closes the window.
// Subclasses should override it and do any last minute processing of the data here.
// vizivaetsia klienton pri zakritii okna
// tipa na etoi note oknu pizdec )
//-----------------------------------------------------------------------------
function DestroyWRI()
{
	if(DestroyOnClose)
		Destroy();
}

// ==========================================================================
// Vote functions
// ==========================================================================
simulated function VoteMap(string mapname)
{
	VoteMapServer(mapname);
}

function VoteMapServer(string mapname)
{
	Mut.VoteMap(PlayerPawn(Owner), mapname);
}

function GetStatusUpdate()
{
	Mut.updateWRI(Self);
}

simulated function ClearStatus()
{
	if(Main != None)
		Main.ClearStatus();
}

simulated function AddPlayer(string PlayerName, bool bVoted, string MapName)
{
	if(Main != None)
		Main.AddPlayer(PlayerName, bVoted, MapName);
}

simulated function AddVote(string MapName, int VoteCount)
{
	if(Main != None)
		Main.AddVote(MapName, VoteCount);
}

simulated function Refresh()
{
	loadData();
}

simulated function ClearAll()
{
	if(Main != None)
		Main.ClearAll();
}
//-----------------------------------------------------------------------------
// Make sure any changes to the WindowClass get replicated in the first Tick of it's lifetime
// Ahead of everything else (UT uses a max of 3)
// Use SimulatedProxy so that the Tick() calls are executed
//-----------------------------------------------------------------------------
defaultproperties
{
	DestroyOnClose=true
	RemoteRole=ROLE_SimulatedProxy
	WinWidth=1280
	WinHeight=800
}