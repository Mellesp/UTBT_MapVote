//=============================================================================
// MV_CategoryListBox made by OwYeaW
//=============================================================================
class MV_CategoryListBox expands UWindowListBox;
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
//-----------------------------------------------------------------------------
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	// local float XL, YL;
	local MV_ListItem I;

	I = MV_ListItem(Item);

	if(I.bEnabled)
	{
		C.DrawColor = Main.SelectColor;
		DrawStretchedTexture(C, X, Y, W, H - 1, Texture'WhiteTexture');
		C.DrawColor = Main.FontAltColor;
		C.Font = Main.Fonts[Main.F_ListItemBold];
	}
	else if(I.bEnabledAlt)
	{
		C.DrawColor = Main.SelectAltColor;
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

	//	UTBT: for centered category names. Do we want this?
	// C.StrLen(I.CatName, XL, YL);
	// ClipText(C, (W-XL)/2, Y, I.CatName);

	ClipText(C, X+4, Y, I.CatName);
}

//-----------------------------------------------------------------------------
function KeyDown(int Key, float X, float Y)
{
	local int i;
	local UWindowListBoxItem ItemPointer;
	local PlayerPawn P;

	P = GetPlayerOwner();

	if(Key == P.EInputKey.IK_MouseWheelDown || Key == P.EInputKey.IK_Down)
	{
		if(SelectedItem != None && SelectedItem.Next != None)
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Next));
			MakeSelectedVisible();
		}
	}

	if(Key == P.EInputKey.IK_MouseWheelUp || Key == P.EInputKey.IK_Up)
	{
		if(SelectedItem != None && SelectedItem.Prev != None && SelectedItem.Sentinel != SelectedItem.Prev)
		{
			SetSelectedItem(UWindowListBoxItem(SelectedItem.Prev));
			MakeSelectedVisible();
		}
	}

	if(Key == P.EInputKey.IK_PageDown)
	{
		if(SelectedItem != None)
		{
			ItemPointer = SelectedItem;
			for(i = 0; i < 7; i++)
			{
				if(ItemPointer.Next == None)
					return;
				ItemPointer = UWindowListBoxItem(ItemPointer.Next);
			}
			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}

	if(Key == P.EInputKey.IK_PageUp)
	{
		if(SelectedItem != None)
		{
			ItemPointer = SelectedItem;
			for(i = 0; i < 7; i++)
			{
				if(ItemPointer.Prev == None || ItemPointer.Prev == SelectedItem.Sentinel)
					return;
				ItemPointer = UWindowListBoxItem(ItemPointer.Prev);
			}
			SetSelectedItem(ItemPointer);
			MakeSelectedVisible();
		}
	}
	ParentWindow.KeyDown(Key, X, Y);
}
//-----------------------------------------------------------------------------
function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	if(NewSelected != None)
	{
		SetSelectedItem(NewSelected);

		MV_ListItem(NewSelected).bEnabled		= !MV_ListItem(NewSelected).bEnabled;
		MV_ListItem(NewSelected).bEnabledAlt	= false;

		MV_MainWindow(ParentWindow).FilterMapListBox();
		GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
	}
}

function RMouseDown(float X, float Y)
{
	Super.RMouseDown(X, Y);
	SetAltSelected(X, Y);
}
//-----------------------------------------------------------------------------
function SetAltSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	if(NewSelected != None)
	{
		SetSelectedItem(NewSelected);

		MV_ListItem(NewSelected).bEnabledAlt	= !MV_ListItem(NewSelected).bEnabledAlt;
		MV_ListItem(NewSelected).bEnabled		= false;

		MV_MainWindow(ParentWindow).FilterMapListBox();
		GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
	}
}

function SelectRandomCat(bool bAlt)
{
	local int i, RandomCat;
	local MV_ListItem CatItem, ShownCatItems[4096];

	for(CatItem = MV_ListItem(Items); CatItem != None; CatItem = MV_ListItem(CatItem.Next))
		if(!CatItem.bEnabled && !CatItem.bEnabledAlt)
			ShownCatItems[i++] = CatItem;

	if(i > 1)
	{
		RandomCat = Rand(i-1) + 1;
		if(ShownCatItems[RandomCat] != None)
		{
			if(bAlt)
			{
				ShownCatItems[RandomCat].bEnabled		= false;
				ShownCatItems[RandomCat].bEnabledAlt	= true;
			}
			else
			{
				ShownCatItems[RandomCat].bEnabled		= true;
				ShownCatItems[RandomCat].bEnabledAlt	= false;
			}

			SetSelectedItem(ShownCatItems[RandomCat]);
			MV_MainWindow(ParentWindow).FilterMapListBox();
			CenterShowSelected();
		}
	}
}

function CenterShowSelected()
{
	local UWindowList CurItem;
	local int i;
	
	VertSB.SetRange(0, Items.CountShown(), int(WinHeight/ItemHeight));

	if(SelectedItem == None)
		return;

	i = 0;
	for(CurItem=Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
		if(CurItem == SelectedItem)
			break;
		if(CurItem.ShowThisItem())
			i++;
	}

	if(VertSB.Pos > i)
		i = Max(0, i - 17);
	else
		i = Min(VertSB.MaxPos + VertSB.MaxVisible, i + 17);
	
	VertSB.Show(i);
}

function ResetCats()
{
	local MV_ListItem CatItem;

	for(CatItem = MV_ListItem(Items); CatItem != None; CatItem = MV_ListItem(CatItem.Next))
	{
		CatItem.bEnabled	= False;
		CatItem.bEnabledAlt	= False;
	}
	MV_MainWindow(ParentWindow).FilterMapListBox();
}

//-----------------------------------------------------------------------------
defaultproperties
{
    ItemHeight=20
    ListClass=Class'MV_ListItem'
}