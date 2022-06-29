//=============================================================================
// MV_MainWindow made by OwYeaW
//=============================================================================
class MV_MainWindow expands UWindowDialogClientWindow;
//-----------------------------------------------------------------------------
#exec texture IMPORT NAME=shade				FILE=TEXTURES\shade.BMP				MIPS=OFF
#exec texture IMPORT NAME=UTBT_CursorLink	FILE=TEXTURES\UTBT_CursorLink.PCX	FLAGS=2		MIPS=OFF
#exec TEXTURE IMPORT NAME=NoShot0			FILE=TEXTURES\NoShot0.BMP			FLAGS=2 	MIPS=OFF
#exec TEXTURE IMPORT NAME=NoShot1			FILE=TEXTURES\NoShot1.BMP			FLAGS=2 	MIPS=OFF
#exec TEXTURE IMPORT NAME=NoShot2			FILE=TEXTURES\NoShot2.BMP			FLAGS=2 	MIPS=OFF
#exec OBJ LOAD FILE=TEXTURES\MapVote_Fonts.utx	PACKAGE=UTBT_MapVote_v10
//-----------------------------------------------------------------------------
var 	MV_MapListBox 			MapListBox;
var 	MV_CategoryListBox 		CategoryListBox;
var		MV_LogoWindow			LogoWindow;
var		MV_HTMLTextArea			Announcement;
var 	MV_VoteListBox			VoteListBox;
var 	MV_PlayerListBox		PlayerListBox;

var		MV_TitleLabel			CategoryTitle;
var		MV_HeaderSortLabel		MapListMapNameHeader, MapListMapDiffHeader;
var		MV_HeaderLabel			VoteListMapNameHeader, VoteListVoteCountHeader;
var		MV_HeaderLabel			PlayerListPlayerNameHeader, PlayerListMapNameHeader;
var		MV_VersionLabel			VersionLabel;
var		MV_MapCountLabel		MapCountLabel;

var		MV_MapNameLabel			MapNameLabel;
var		MV_MapInfoLabel			MapAuthorLabel;
var		MV_MapInfoLabel			MapRatingLabel;

var 	MV_Button				ResetCatButton, RandomCatButton, RandomMapButton, VoteMapButton, ChatSendButton, CloseButton;
var 	MV_EditControl	 		SearchMapEditBox, ChatEditBox;

var 	float 					LastVoteTime;
var		string					UTBTVersionStr;
//-----------------------------------------------------------------------------
var int seg1W, seg2W, seg3W;
var int borderW, divW, divH, divHC, titleH, headerH, footH, buttonH, scrollW;
var int announcementH, mapinfoH, votelistH, playerlistH;
var float AnnouncementPercentWinHeight, MapInfoPercentWinHeight, VoteListPercentWinHeight, PlayerListPercentWinHeight;
//-----------------------------------------------------------------------------
var color FontColor, FontAltColor, SelectColor, SelectAltColor, HoverColor, OwnerColor, VotedColor, GrayColor,
OuterBorderColor, ActiveBorderColor, InactiveBorderColor, YellowHeaderColor, GreenHeaderColor, MapInfoColor;
//-----------------------------------------------------------------------------
var int	VisibleMapCount, TotalMapCount;
var Font Fonts[10];
var MV_WRI WRI;
var Texture MapScreenShot;
var string MapAuthor, MapRating, SelectedMap;
//-----------------------------------------------------------------------------
const F_ListItem		= 0;
const F_ListItemBold	= 1;
const F_Title			= 2;
const F_Header			= 3;
const F_HeaderBold		= 4;
const F_Button			= 5;
const F_Version			= 6;
//-----------------------------------------------------------------------------
function FilterMapListBox()
{
	local string strFind;
	local int i, iOr, iAnd;
	local bool bOr, bAnd, bDone, bFind;
	local MV_ListItem MI, CI, CIor[128], CIand[128];

	if(len(SearchMapEditBox.GetValue()) > 0)
	{
		bFind = true;
		strFind = SearchMapEditBox.GetValue();
	}

	CI = MV_ListItem(CategoryListBox.Items.Next);
	while(CI != None) 
	{
		if(CI.bEnabled)
		{
			bOr = true;
			CIor[iOr++] = CI;
		}
		else if(CI.bEnabledAlt)
		{
			bAnd = true;
			CIand[iAnd++] = CI;
		}

		CI = MV_ListItem(CI.Next);
	}

	if(bOr || bAnd)
	{
		MI = MV_ListItem(MapListBox.Items.Next);
		while(MI != None) 
		{
			MI.bHide = true;
			bDone = false;

			if(bAnd)
			{
				for(i = 0; i < iAnd; i++)
				{
					if(CIand[i].CatRating)
					{
						if(CIand[i].CatIndex == int(MI.MapRating))
						{
							MI.bHide = false;
						}
						else
						{
							MI.bHide = true;
							bDone = true;
							break;
						}
					}
					else
					{
						if(InStr(MI.MapCats, string(CIand[i].CatIndex)$"?") > -1)
						{
							MI.bHide = false;
						}
						else
						{
							MI.bHide = true;
							bDone = true;
							break;
						}
					}
				}
			}

			if(bDone)
			{
				MI = MV_ListItem(MI.Next);
				continue;
			}

			if(bOr)
			{
				for(i = 0; i < iOr; i++)
				{
					if(CIor[i].CatRating)
					{
						if(CIor[i].CatIndex == int(MI.MapRating))
						{
							MI.bHide = false;
							break;
						}
						else
						{
							MI.bHide = true;
						}
					}
					else
					{
						if(InStr(MI.MapCats, string(CIor[i].CatIndex)$"?") > -1)
						{
							MI.bHide = false;
							break;
						}
						else
						{
							MI.bHide = true;
						}
					}
				}
			}

			if(!MI.bHide && bFind)
			{
				if(InStr(Caps(MI.MapName), Caps(strFind)) == -1)
					Mi.bHide = true;
			}

			MI = MV_ListItem(MI.Next);
		}
	}
	else // no filters enabled
	{
		MI = MV_ListItem(MapListBox.Items.Next);
		while(MI != None) 
		{
			MI.bHide = false;

			if(!MI.bHide && bFind)
			{
				if(InStr(Caps(MI.MapName), Caps(strFind)) == -1)
					Mi.bHide = true;
			}
			MI = MV_ListItem(MI.Next);
		}
	}

	VisibleMapCount = MapListBox.MapCount();
	SetMapCountLabel();
}
function SetMapCountLabel()
{
	MapCountLabel.SetText(VisibleMapCount$"/"$TotalMapCount$" maps");
}
function ClearAll()
{
	MapListBox.Items.Clear();
	CategoryListBox.Items.Clear();
	VoteListBox.Items.Clear();
	PlayerListBox.Items.Clear();

	MapListBox.SelectedItem			= None;
	CategoryListBox.SelectedItem	= None;
	VoteListBox.SelectedItem		= None;
	PlayerListBox.SelectedItem		= None;

	TotalMapCount	= 0;
	VisibleMapCount	= 0;
	
	MapCountLabel.SetText("Downloading Maps...");
}
function ClearStatus()
{
	VoteListBox.Items.Clear();
	PlayerListBox.Items.Clear();

	VoteListBox.SelectedItem		= None;
	PlayerListBox.SelectedItem		= None;
}
function AddMap(string MapName, string MapRating, string MapCats)
{
	local MV_ListItem I;

	I = MV_ListItem(MapListBox.Items.Append(class'MV_ListItem'));
	I.MapName		= MapName;
	I.MapRating		= MapRating;
	I.MapCats		= MapCats;
	I.MainWindow	= Self;
}
function AddCategory(string CatName, int CatIndex, bool CatRating)
{
	local MV_ListItem I;

	I = MV_ListItem(CategoryListBox.Items.Append(class'MV_ListItem'));
	I.CatName	= CatName;
	I.CatIndex	= CatIndex;
	I.CatRating	= CatRating;
}
function AddVote(string MapName, int VoteCount)
{
	local MV_ListItem I;

	I = MV_ListItem(VoteListBox.Items.Append(class'MV_ListItem'));
	I.MapName	= MapName;
	I.VoteCount	= VoteCount;
}
function AddPlayer(string PlayerName, bool bVoted, string MapName)
{
	local MV_ListItem I;

	I = MV_ListItem(PlayerListBox.Items.Append(class'MV_ListItem'));
	I.PlayerName	= PlayerName;
	I.bVoted		= bVoted;
	I.MapName		= MapName;
}
//-----------------------------------------------------------------------------
function RootDesign()
{
	local float seg3H;

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;

	//	UTBT: no start-up sound?
	// GetPlayerOwner().PlaySound(sound'WindowOpen', SLOT_Interface);
	LookAndFeel = Root.GetLookAndFeel(Left(Class, InStr(Class, "."))$".MV_LookAndFeel");
	MV_LookAndFeel(LookAndFeel).Main = Self;
	Root.HandCursor.Tex = Texture'UTBT_CursorLink';
	Root.HandCursor.HotX = 9;
	Root.HandCursor.HotY = 0;

	// window sizes
	seg3H = WinHeight - divH*4 - footH;
	announcementH	= seg3H * AnnouncementPercentWinHeight;
	mapinfoH		= seg3H * MapInfoPercentWinHeight;
	votelistH		= seg3H * VoteListPercentWinHeight;
	playerlistH		= seg3H * PlayerListPercentWinHeight;

	UTBTVersionStr = "UTBT MapVote v" $ GetVersionNumber();
	SetupFonts();
}

function string GetVersionNumber()
{
	local string PackageName, str;

	PackageName = Left(Class, InStr(Class, "."));
	str = Right(PackageName, Len(PackageName) - Len("UTBT_MapVote_v"));
	str = Left(str, Len(str) - 1) $ "." $ Right(str, 1);

	return str;
}

function SetAnnouncement(string str)
{
	Announcement.SetHTML(str);
}

function Created()
{
	local float X, Y, W, H;

	RootDesign();

	//-------------------------------------------------------------------------------------------
	//	Segment 1
		//	LogoWindow
		X = divW;
		Y = divH;
		W = seg1W;
		H = seg1W;
		LogoWindow = MV_LogoWindow(CreateWindow(class'MV_LogoWindow', X, Y, W, H));

		//	CategoryTitle
		X = divW;
		Y = divH+seg1W+divHC;
		W = seg1W;
		H = titleH;
		CategoryTitle = MV_TitleLabel(CreateControl(class'MV_TitleLabel', X, Y, W, H));
		CategoryTitle.SetText("Categories");
		CategoryTitle.Align = TA_Center;

		//	CategoryListBox
		X = divW;
		Y = divH+seg1W+divHC+titleH;
		W = seg1W;
		H = WinHeight-(divH+seg1W+divHC+titleH)-footH;
		CategoryListBox = MV_CategoryListBox(CreateControl(class'MV_CategoryListBox', X, Y, W, H));
		CategoryListBox.Items.Clear();

		//	ResetCatButton
		X = divW;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = 60;
		H = 24;
		ResetCatButton = MV_Button(CreateControl(class'MV_Button', X, Y, W, H));
		ResetCatButton.DownSound = Sound'Botpack.Click';
		ResetCatButton.Text = "Reset";

		//	RandomCatButton
		X = divW + 68;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = 152;
		H = 24;
		RandomCatButton = MV_Button(CreateControl(class'MV_Button', X, Y, W, H));
		RandomCatButton.DownSound = Sound'Botpack.Click';
		RandomCatButton.Text = "Random Category";

	//-------------------------------------------------------------------------------------------
	//	Segment 2
		//	MapListMapNameHeader
		X = divW + seg1W + divW;
		Y = divH;
		W = 105;	// 105 units for "Map Name"
		H = titleH;
		MapListMapNameHeader = MV_HeaderSortLabel(CreateControl(class'MV_HeaderSortLabel', X, Y, W, H));
		MapListMapNameHeader.SetText("Map Name");
		MapListMapNameHeader.Align = TA_Left;

		//	MapListMapDiffHeader
		X = divW + seg1W + divW + seg2W-scrollW-84;
		Y = divH;
		W = 84;		// 84 units for "Difficulty"
		H = titleH;
		MapListMapDiffHeader = MV_HeaderSortLabel(CreateControl(class'MV_HeaderSortLabel', X, Y, W, H));
		MapListMapDiffHeader.SetText("Difficulty");
		MapListMapDiffHeader.Align = TA_Right;

		//	MapCountLabel
		X = divW + seg1W + divW + seg2W/3;
		Y = divH + (titleH-18)/2;
		W = seg2W/3;
		H = 18;
		MapCountLabel = MV_MapCountLabel(CreateControl(class'MV_MapCountLabel', X, Y, W, H));
		MapCountLabel.SetText("");
		MapCountLabel.Align = TA_Center;
		
		// MaplistBox
		X = divW + seg1W + divW;
		Y = divH+titleH;
		W = seg2W;
		H = WinHeight-(divH+titleH)-footH;
		MapListBox = MV_MapListBox(CreateControl(class'MV_MapListBox', X, Y, W, H));
		MapListBox.Items.Clear();

		//	RandomMapButton
		X = divW + seg1W + divW;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = 128;
		H = 24;
		RandomMapButton = MV_Button(CreateControl(class'MV_Button', X, Y, W, H));
		RandomMapButton.DownSound = Sound'Botpack.Click';
		RandomMapButton.Text = "Random Map";

		//	SearchMapEditBox
		X = divW + seg1W + divW + 128 + 8;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = seg2W-((128+8)*2);
		H = 24;
		SearchMapEditBox = MV_EditControl(CreateControl(class'MV_EditControl', X, Y, W, H));
		SearchMapEditBox.SetText("");

		//	VoteMapButton
		X = divW + seg1W + divW + seg2W - 128;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = 128;
		H = 24;
		VoteMapButton = MV_Button(CreateControl(class'MV_Button', X, Y, W, H));
		VoteMapButton.DownSound = Sound'Botpack.Click';
		VoteMapButton.Text = "Vote";

	//-------------------------------------------------------------------------------------------
	//	Segment 3.A
		//	Announcements
		X = divW + seg1W + divW + seg2W + divW;
		Y = divH;
		W = seg3W;
		H = announcementH;
		Announcement = MV_HTMLTextArea(CreateControl(class'MV_HTMLTextArea', X, Y, W, H));

		//	UTBT Mapvote version label
		X = divW + seg1W + divW + seg2W + divW;
		Y = divH;
		W = seg3W;
		H = 16;
		VersionLabel = MV_VersionLabel(CreateControl(class'MV_VersionLabel', X, Y, W, H));
		VersionLabel.SetText(UTBTVersionStr);
		VersionLabel.Align = TA_Center;

	//-------------------------------------------------------------------------------------------
	//	Segment 3.B
		//	MapNameLabel
		X = divW + seg1W + divW + seg2W + divW + mapinfoH + divW/2;
		Y = divH + announcementH + divH*1.5;
		W = seg3W-(mapinfoH + divW/2);
		H = headerH;
		MapNameLabel = MV_MapNameLabel(CreateControl(class'MV_MapNameLabel', X, Y, W, H));
		MapNameLabel.Align = TA_Left;

		//	MapAuthorLabel
		X = divW + seg1W + divW + seg2W + divW + mapinfoH + divW/2;
		Y = divH + announcementH + divH + divH + headerH;
		W = seg3W-(mapinfoH + divW/2);
		H = headerH;
		MapAuthorLabel = MV_MapInfoLabel(CreateControl(class'MV_MapInfoLabel', X, Y, W, H));
		MapAuthorLabel.Align = TA_Left;

		//	MapRatingLabel
		X = divW + seg1W + divW + seg2W + divW + mapinfoH + divW/2;
		Y = divH + announcementH + divH + divH + headerH + headerH;
		W = seg3W-(mapinfoH + divW/2);
		H = headerH;
		MapRatingLabel = MV_MapInfoLabel(CreateControl(class'MV_MapInfoLabel', X, Y, W, H));
		MapRatingLabel.Align = TA_Left;

	//-------------------------------------------------------------------------------------------
	//	Segment 3.C
		//	VoteListMapNameHeader
		X = divW + seg1W + divW + seg2W + divW;
		Y = divH + announcementH + divH + mapinfoH + divH;
		W = (seg3W-scrollW)/2;
		H = headerH;
		VoteListMapNameHeader = MV_HeaderLabel(CreateControl(class'MV_HeaderLabel', X, Y, W, H));
		VoteListMapNameHeader.SetText("Voted Maps");
		VoteListMapNameHeader.Align = TA_Left;

		//	VoteListVoteCountHeader
		X = divW + seg1W + divW + seg2W + divW + (seg3W-scrollW)/2;
		Y = divH + announcementH + divH + mapinfoH + divH;
		W = (seg3W-scrollW)/2;
		H = headerH;
		VoteListVoteCountHeader = MV_HeaderLabel(CreateControl(class'MV_HeaderLabel', X, Y, W, H));
		VoteListVoteCountHeader.SetText("Votes");
		VoteListVoteCountHeader.Align = TA_Right;

		//	VoteListBox
		X = divW + seg1W + divW + seg2W + divW;
		Y = divH + announcementH + divH + mapinfoH + divH + headerH;
		W = seg3W;
		H = votelistH-headerH;
		VoteListBox = MV_VoteListBox(CreateControl(class'MV_VoteListBox', X, Y, W, H));
		VoteListBox.Items.Clear();

	//-------------------------------------------------------------------------------------------
	//	Segment 3.D
		//	PlayerListPlayerNameHeader
		X = divW + seg1W + divW + seg2W + divW;
		Y = divH + announcementH + divH + mapinfoH + divH + votelistH + divH;
		W = (seg3W-scrollW)/2;
		H = headerH;
		PlayerListPlayerNameHeader = MV_HeaderLabel(CreateControl(class'MV_HeaderLabel', X, Y, W, H));
		PlayerListPlayerNameHeader.SetText("Players");
		PlayerListPlayerNameHeader.Align = TA_Left;

		//	PlayerListMapNameHeader
		X = divW + seg1W + divW + seg2W + divW + (seg3W-scrollW)/2;
		Y = divH + announcementH + divH + mapinfoH + divH + votelistH + divH;
		W = (seg3W-scrollW)/2;
		H = headerH;
		PlayerListMapNameHeader = MV_HeaderLabel(CreateControl(class'MV_HeaderLabel', X, Y, W, H));
		PlayerListMapNameHeader.SetText("Voted");
		PlayerListMapNameHeader.Align = TA_Right;

		//	PlayerListBox
		X = divW + seg1W + divW + seg2W + divW;
		Y = divH + announcementH + divH + mapinfoH + divH + votelistH + divH + headerH;
		W = seg3W;
		H = playerlistH-headerH;
		PlayerListBox = MV_PlayerListBox(CreateControl(class'MV_PlayerListBox', X, Y, W, H));
		PlayerListBox.Items.Clear();

	//-------------------------------------------------------------------------------------------
	//	Segment 3.E
		//	ChatEditBox
		X = divW + seg1W + divW + seg2W + divW;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = seg3W-80-8-80-8;
		H = 24;
		ChatEditBox = MV_EditControl(CreateControl(class'MV_EditControl', X, Y, W, H));
		ChatEditBox.SetText("");
		ChatEditBox.SetHistory(true);

		//	ChatSendButton
		X = divW + seg1W + divW + seg2W + divW + seg3W - 80-8-80;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = 80;
		H = 24;
		ChatSendButton = MV_Button(CreateControl(class'MV_Button', X, Y, W, H));
		ChatSendButton.DownSound = Sound'Botpack.Click';
		ChatSendButton.Text = "Chat";

		//	CloseButton
		X = divW + seg1W + divW + seg2W + divW + seg3W - 80;
		Y = WinHeight - footH + (footH-buttonH)/2;
		W = 80;
		H = 24;
		CloseButton = MV_Button(CreateControl(class'MV_Button', X, Y, W, H));
		CloseButton.DownSound = Sound'Botpack.Click';
		CloseButton.Text = "Close";
	//-------------------------------------------------------------------------------------------
}

function LoadedData()
{
	ActiveWindow	= SearchMapEditBox;
	TotalMapCount	= MapListBox.MapCount();
	VisibleMapCount	= TotalMapCount;
	
	SetMapCountLabel();
}
//-----------------------------------------------------------------------------
function bool AllowVote()
{
	// anti vote spam (0.25 seconds vote cooldown)
	if(GetPlayerOwner().Level.TimeSeconds > LastVoteTime - 0.25)
	{
		LastVoteTime = GetPlayerOwner().Level.TimeSeconds;
		return true;
	}
	return false;
}
//-----------------------------------------------------------------------------
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
		case DE_Change:
			switch(C)
			{
				case SearchMapEditBox:
					FilterMapListBox();
					if(VisibleMapCount == 1)
						MapListBox.Select(1);
				break;
			}
		break;

		case DE_DoubleClick:
			switch(C)
			{
				case MapListBox:
					if(MapListBox.SelectedItem != None)
						if(AllowVote())
							WRI.VoteMap(MV_ListItem(MapListBox.SelectedItem).MapName);
				break;

				case VoteListBox:
					if(VoteListBox.SelectedItem != None)
						if(AllowVote())
							WRI.VoteMap(MV_ListItem(VoteListBox.SelectedItem).MapName);
				break;

				case PlayerListBox:
					if(PlayerListBox.SelectedItem != None)
						if(AllowVote())
							if(MV_ListItem(PlayerListBox.SelectedItem).MapName != "")
								WRI.VoteMap(MV_ListItem(PlayerListBox.SelectedItem).MapName);
				break;
			}
		break;

		case DE_Click:
			switch(C)
			{
				case MapListMapDiffHeader:
					MapListBox.Sorting(false);
				break;
			
				case MapListMapNameHeader:
					MapListBox.Sorting(true);
				break;

				case CloseButton:
					Close();
				break;
				
				case VoteMapButton:
					if(SelectedMap != "" && AllowVote())
						WRI.VoteMap(SelectedMap);
				break;

				case ChatSendButton:
					if(ChatEditBox.GetValue() != "")
					{
						GetPlayerOwner().ConsoleCommand("SAY "$ ChatEditBox.GetValue());
						ChatEditBox.SetValue("");
					}
				break;

				case RandomMapButton:
					MapListBox.SelectRandomMap();
				break;

				case RandomCatButton:
					CategoryListBox.SelectRandomCat(false);
				break;

				case ResetCatButton:
					CategoryListBox.ResetCats();
				break;

				case MapListBox:
					if(MapListBox.SelectedItem != None)
					{
						GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
						if(MV_ListItem(MapListBox.SelectedItem).MapName != "")
							SelectMap(MV_ListItem(MapListBox.SelectedItem).MapName);
						DeSelect(VoteListBox);
						DeSelect(PlayerListBox);
					}
				break;

				case VoteListBox:
					if(VoteListBox.SelectedItem != None)
					{
						GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
						if(MV_ListItem(VoteListBox.SelectedItem).MapName != "")
							SelectMap(MV_ListItem(VoteListBox.SelectedItem).MapName);
						DeSelect(MapListBox);
						DeSelect(PlayerListBox);
					}
				break;

				case PlayerListBox:
					if(PlayerListBox.SelectedItem != None)
					{
						GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
						if(MV_ListItem(PlayerListBox.SelectedItem).MapName != "")
							SelectMap(MV_ListItem(PlayerListBox.SelectedItem).MapName);
						DeSelect(MapListBox);
						DeSelect(VoteListBox);
					}
				break;
			}
		break;

		case DE_RClick:
			switch(C)
			{
				case RandomCatButton:
					CategoryListBox.SelectRandomCat(true);
				break;
			}

		case DE_EnterPressed:
			switch(C) 
			{
				case ChatEditBox:
					if(ChatEditBox.GetValue() != "")
					{
						GetPlayerOwner().ConsoleCommand("SAY "$ ChatEditBox.GetValue());
						ChatEditBox.SetValue("");
						ChatEditBox.FocusOtherWindow(ChatSendButton);
					}
				break;

				case SearchMapEditBox:
					if(MapListBox.SelectedItem != None)
					{
						GetPlayerOwner().PlaySound(Sound'Botpack.Click', SLOT_Interface);
						MapListBox.DoubleClickItem(MapListBox.SelectedItem);
					}
				break;
			}
		break;
	}
}

function DeSelect(UWindowListBox W)
{
	if(W.SelectedItem != None)
	{
		W.SelectedItem.bSelected = false;
		W.SelectedItem = None;
	}
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;

	//	Background
	C.Style = 4;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'shade');
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'shade');
	C.Style = 1;

	//	Outer borders
	C.DrawColor = OuterBorderColor;
	DrawStretchedTexture(C, 0, 	0, 					WinWidth, 	borderW, 	Texture'WhiteTexture');
	DrawStretchedTexture(C, 0, 	WinHeight-borderW, 	WinWidth, 	borderW, 	Texture'WhiteTexture');
	DrawStretchedTexture(C, 0, 	0, 					borderW, 	WinHeight,	Texture'WhiteTexture');
	DrawStretchedTexture(C, WinWidth-borderW, 	0,	borderW, 	WinHeight, 	Texture'WhiteTexture');

	//	MapInfo
	C.DrawColor = FontColor;
	X = divW + seg1W + divW + seg2W + divW;
	Y = divH + announcementH + divH;
	W = mapinfoH;
	H = mapinfoH;
	DrawStretchedTexture(C, X, Y, W, H, MapScreenShot);

	if(SelectedMap != "")
	{
		MapNameLabel.SetText(SelectedMap);
		MapAuthorLabel.SetText(MapAuthor);
		MapRatingLabel.SetText(MapRating);
	}

	//	Seg1.A	Logo
	X = divW - (divW/3);
	Y = divH - (divH/3);
	W = seg1W + (divW/1.5);
	H = seg1W + (divH/3);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);

	//	Seg1.B	Categories
	X = divW - (divW/3);
	Y = divH+seg1W+divHC - (divH/3);
	W = seg1W + (divW/1.5);
	H = WinHeight - Y - footH + (divH/3);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);

	//	Seg2	Maplist
	X = divW + seg1W + divW - (divW/3);
	Y = divH - (divH/3);
	W = seg2W + (divW/1.5);
	H = WinHeight - Y - footH + (divH/3);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);

	//	Seg3.A	Announcements
	X = divW + seg1W + divW + seg2W + divW - (divW/3);
	Y = divH - (divH/3);
	W = seg3W + (divW/1.5);
	H = announcementH + (divH/1.5);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);

	//	Seg3.B	MapInfo
	X = divW + seg1W + divW + seg2W + divW - (divW/3);
	Y = divH + announcementH + divH - (divH/3);
	W = seg3W + (divW/1.5);
	H = mapinfoH + (divH/1.5);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);

	//	Seg3.C	VoteList
	X = divW + seg1W + divW + seg2W + divW - (divW/3);
	Y = divH + announcementH + divH + mapinfoH + divH - (divH/3);
	W = seg3W + (divW/1.5);
	H = votelistH + (divH/1.5);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);

	//	Seg3.D	PlayerList
	X = divW + seg1W + divW + seg2W + divW - (divW/3);
	Y = divH + announcementH + divH + mapinfoH + divH + votelistH + divH - (divH/3);
	W = seg3W + (divW/1.5);
	H = WinHeight - Y - footH + (divH/3);
	DrawSquareBorder(C, MouseX, MouseY, X, Y, W, H, 2);
}

function DrawSquareBorder(Canvas C, float MouseX, float MouseY, float X, float Y, float W, float H, float S)
{
	local Texture T;

	if(MouseX >= X
	&& MouseX <= X + W
	&& MouseY >= Y
	&& MouseY <= Y + H)
	{
		C.DrawColor = ActiveBorderColor;
		T = Texture'WhiteTexture';
	}
	else
	{
		C.DrawColor = InactiveBorderColor;
		T = Texture'shade';
	}

	DrawStretchedTexture(C, X, 		Y,		W, 	S,	T);		//	UP
	DrawStretchedTexture(C, X, 		Y,		S, 	H,	T);		//	LEFT
	DrawStretchedTexture(C, X, 		Y+H-S,	W, 	S,	T);		//	DOWN
	DrawStretchedTexture(C, X+W-S, 	Y,		S, 	H,	T);		//	RIGHT
}

function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn PP;

	PP = GetPlayerOwner();

	// ENTER -> Vote Map
	if(Key == PP.EInputKey.IK_Enter)
	{
		if(SelectedMap != "" && AllowVote())
		{
			GetPlayerOwner().PlaySound(Sound'Botpack.Click', SLOT_Interface);
			WRI.VoteMap(SelectedMap);
		}
	}

	// TAB -> ChatEditBox
	if(Key == PP.EInputKey.IK_Tab)
	{
		if(ActiveWindow == SearchMapEditBox)
			ActiveWindow = MapListBox;
		else
			ActiveWindow = SearchMapEditBox;
	}

	// T -> ChatEditBox
	if(Key == PP.EInputKey.IK_T)
		ActiveWindow = ChatEditBox;

    ParentWindow.KeyDown(Key,X,Y);
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(W, H);
	SetupFonts();
}

function SetupFonts()
{
	if(Root.GUIScale == 3)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma35", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB35", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma40", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma40", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB40", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma37", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma30", class'Font'));
	}
	else if(Root.GUIScale == 2.75)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma32", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB32", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma40", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma40", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB40", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma35", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma27", class'Font'));
	}
	else if(Root.GUIScale == 2.5)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma30", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB30", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma40", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma37", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB37", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma32", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma25", class'Font'));
	}
	else if(Root.GUIScale == 2.25)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma27", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB27", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma37", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma35", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB35", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma30", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma22", class'Font'));
	}
	else if(Root.GUIScale == 2)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma25", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB25", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma35", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma32", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB32", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma27", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma20", class'Font'));
	}
	else if(Root.GUIScale == 1.75)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma22", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB22", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma32", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma30", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB30", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma25", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma17", class'Font'));
	}
	else if(Root.GUIScale == 1.5)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma20", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB20", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma30", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma27", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB27", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma22", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma15", class'Font'));
	}
	else if(Root.GUIScale == 1.25)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma17", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB17", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma27", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma25", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB25", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma20", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma12", class'Font'));
	}
	else if(Root.GUIScale == 1)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma15", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB15", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma22", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma20", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB20", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma17", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma10", class'Font'));
	}
	else if(Fonts[F_ListItem] == none
	|| Fonts[F_ListItemBold] == none
	|| Fonts[F_Title] == none
	|| Fonts[F_Header] == none
	|| Fonts[F_HeaderBold] == none
	|| Fonts[F_Button] == none
	|| Fonts[F_Version] == none)
	{
		Fonts[F_ListItem]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma15", class'Font'));
		Fonts[F_ListItemBold]	= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB15", class'Font'));
		Fonts[F_Title]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma22", class'Font'));
		Fonts[F_Header]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma20", class'Font'));
		Fonts[F_HeaderBold]		= Font(DynamicLoadObject("UTBT_MapVote_v10.TahomaB20", class'Font'));
		Fonts[F_Button]			= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma17", class'Font'));
		Fonts[F_Version]		= Font(DynamicLoadObject("UTBT_MapVote_v10.Tahoma10", class'Font'));
	}
}

function SelectMap(string MapName)
{
	local LevelSummary L;

	L = LevelSummary(DynamicLoadObject(MapName $ ".LevelSummary", class'LevelSummary', true));
	if(L != None)
	{
		MapScreenShot = Texture(DynamicLoadObject(MapName $ ".Screenshot", class'Texture', true));

		if(MapScreenShot == None)
			MapScreenShot = Texture'NoShot1';

		if(L.Author == "")
			MapAuthor = "Author: N/A";
		else
			MapAuthor = "Author: " $ L.Author;
	}
	else
	{
		MapAuthor = "Download Required";
		MapScreenShot = Texture'NoShot2';
	}

	MapRating = "Difficulty Rating: " $ MapListBox.GetMapRating(MapName);
	SelectedMap = MapName;
}

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if(WRI == None || WRI.Client == None)
		Close();
}

defaultproperties
{
	borderW=3
	seg1W=228
	seg2W=480
	seg3W=500
	divW=18
	divH=18
	divHC=12
	titleH=32
	buttonH=24
	headerH=28
	footH=52
	scrollW=12
	AnnouncementPercentWinHeight=0.40
	MapInfoPercentWinHeight=0.15
	VoteListPercentWinHeight=0.20
	PlayerListPercentWinHeight=0.25
	FontColor=(R=255,G=255,B=255)
	FontAltColor=(R=0,G=0,B=0)
	SelectColor=(R=0,G=96,B=96)
	SelectAltColor=(R=96,G=0,B=64)
	HoverColor=(R=4,G=4,B=4)
	OwnerColor=(R=255,G=255,B=100,A=0)
	VotedColor=(R=100,G=255,B=100,A=0)
	OuterBorderColor=(R=64,G=64,B=64,A=0)
	ActiveBorderColor=(R=0,G=64,B=96,A=0)
	InactiveBorderColor=(R=20,G=128,B=255,A=0)
	YellowHeaderColor=(R=255,G=255,B=100,A=0)
	GreenHeaderColor=(R=100,G=255,B=100,A=0)
	MapInfoColor=(R=100,G=255,B=100,A=0)
	GrayColor=(R=64,G=64,B=64,A=0)
	MapScreenShot=Texture'NoShot0'
}