//=============================================================================
// MV_VoteListBox made by OwYeaW
//=============================================================================
class MV_VoteListBox expands UWindowListBox;
//-----------------------------------------------------------------------------
var MV_MainWindow	Main;
var MV_ListItem		MouseItem;
var bool			bHover;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();
	Main = MV_MainWindow(ParentWindow);
}
//-----------------------------------------------------------------------------
function Paint(Canvas C, float MouseX, float MouseY)
{
	local MV_ListItem NewMouseItem;

	NewMouseItem = MV_ListItem(GetItemAt(MouseX, MouseY));

	if(NewMouseItem != MouseItem)
	{
		if(MouseItem != None)
			MouseItem.MouseLeave();
		if(NewMouseItem != None)
			NewMouseItem.MouseEnter();
		MouseItem = NewMouseItem;
	}

	Super.Paint(C, MouseX, MouseY);
}

function MouseEnter()
{
	bHover = true;
}

function MouseLeave()
{
	bHover = false;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local float XL, YL;
	local MV_ListItem I;

	I = MV_ListItem(Item);

	if(I.bSelected)
	{
		C.DrawColor = Main.SelectColor;
		DrawStretchedTexture(C, X, Y, W, H - 1, Texture'WhiteTexture');
		C.DrawColor = Main.FontAltColor;
		C.Font = Main.Fonts[Main.F_ListItemBold];
	}
	else if(I.bHover && bHover)
	{
		C.DrawColor = Main.HoverColor;
		C.Style = 4;
		DrawStretchedTexture(C, X, Y, W, H - 1, Texture'WhiteTexture');
		C.Style = 1;
		C.DrawColor = Main.FontColor;
		C.Font = Main.Fonts[Main.F_ListItemBold];
	}
	else
	{
		C.DrawColor = Main.FontColor;
		C.Font = Main.Fonts[Main.F_ListItem];
	}

	ClipText(C, X + 4, Y, I.MapName);
	C.StrLen(I.VoteCount, XL, YL);
	ClipText(C, WinWidth - 32 - (XL/2), Y, I.VoteCount);
}

function SetSelected(float X, float Y)
{
	GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
	Super.SetSelected(X, Y);
}

function KeyDown(int Key, float X, float Y)
{
	ParentWindow.KeyDown(Key, X, Y);
}

function DoubleClickItem(UWindowListBoxItem I)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self, DE_DoubleClick);
}

defaultproperties
{
	ItemHeight=20
	ListClass=Class'MV_ListItem'
}