//=============================================================================
// MV_ListItem made by OwYeaW
//=============================================================================
class MV_ListItem expands UWindowListBoxItem;

//	General
var		bool			bHover;
var		bool			bhide;
var		MV_MainWindow	MainWindow;
//	MapListBox
var 	string			MapName;
var 	string			MapRating;
var 	string			MapCats;
//	CategoryListBox
var 	string			CatName;
var 	int				CatIndex;
var 	bool			CatRating;
var 	bool			bEnabled;
var 	bool			bEnabledAlt;
//	VoteListBox
var 	int				VoteCount;
//	PlayerListBox
var 	string			PlayerName;
var		bool			bVoted;

function MouseEnter()
{
	bHover = true;
}

function MouseLeave()
{
	bHover = false;
}

function bool ShowThisItem()
{
	return !bhide;
}

function int Compare(UWindowList T, UWindowList B)
{
	return 0;
}