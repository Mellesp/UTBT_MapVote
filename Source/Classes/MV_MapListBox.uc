//=============================================================================
// MV_MapListBox made by OwYeaW
//=============================================================================
class MV_MapListBox expands UWindowListBox;
//-----------------------------------------------------------------------------
var MV_MainWindow	Main;
var string			CurrentMapName;
var MV_ListItem		ListItems[4096];
var MV_ListItem		MouseItem;
var bool			bHover, bAscName, bAscDiff;
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
	C.StrLen(I.MapRating, XL, YL);
	ClipText(C, WinWidth - 32 - (XL/2), Y, I.MapRating);
}
//-----------------------------------------------------------------------------
function KeyDown(int Key, float X, float Y)
{
	local int i;
	local MV_ListItem ListItem;
	local PlayerPawn PP;

	PP = GetPlayerOwner();

	if(Key == PP.EInputKey.IK_MouseWheelDown || Key == PP.EInputKey.IK_Down)
	{
		if(SelectedItem != None && SelectedItem.Next != None)
		{
			ListItem = MV_ListItem(SelectedItem.Next);

			while(ListItem != None)
			{
				if(ListItem.ShowThisItem())
				{
					SetSelectedItem(ListItem);
					MakeSelectedVisible();
					break;
				}
				ListItem = MV_ListItem(ListItem.Next);
			}
		}
	}

	if(Key == PP.EInputKey.IK_MouseWheelUp || Key == PP.EInputKey.IK_Up)
	{
		if(SelectedItem != None && SelectedItem.Prev != None)
		{
			ListItem = MV_ListItem(SelectedItem.Prev);

			while(ListItem != None && ListItem.MapName != "")
			{
				if(ListItem.ShowThisItem())
				{
					SetSelectedItem(ListItem);
					MakeSelectedVisible();
					break;
				}
				ListItem = MV_ListItem(ListItem.Prev);
			}
		}
	}

	if(Key == PP.EInputKey.IK_PageDown)
	{
		if(SelectedItem != None)
		{
			ListItem = MV_ListItem(SelectedItem);
			for(i = 0; i < 15; i++)
			{
				if(ListItem.Next == None)
					return;
				ListItem = MV_ListItem(ListItem.Next);
			}
			SetSelectedItem(ListItem);
			MakeSelectedVisible();
		}
	}

	if(Key == PP.EInputKey.IK_PageUp)
	{
		if(SelectedItem != None)
		{
			ListItem = MV_ListItem(SelectedItem);
			for(i = 0; i < 15; i++)
			{
				if(ListItem.Prev == None || ListItem.Prev == SelectedItem.Sentinel)
					return;
				ListItem = MV_ListItem(ListItem.Prev);
			}
			SetSelectedItem(ListItem);
			MakeSelectedVisible();
		}
	}
	ParentWindow.KeyDown(Key, X, Y);
}
//-----------------------------------------------------------------------------
function DoubleClickItem(UWindowListBoxItem I)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self, DE_DoubleClick);
}

function SelectRandomMap()
{
	local int i, RandomMap;
	local MV_ListItem MapItem, ShownMapItems[4096];

	for(MapItem = MV_ListItem(Items); MapItem != None; MapItem = MV_ListItem(MapItem.Next))
		if(MapItem.ShowThisItem())
			ShownMapItems[i++] = MapItem;

	RandomMap = Rand(i) + 1;
	if(ShownMapItems[RandomMap] != None)
	{
		SetSelectedItem(ShownMapItems[RandomMap]);
		CenterShowSelected();
	} 
}

function Select(int num)
{
	local int i;
	local MV_ListItem MapItem;

	for(MapItem = MV_ListItem(Items); MapItem != None; MapItem = MV_ListItem(MapItem.Next))
		if(MapItem.ShowThisItem())
			if(i++ == num)
				SetSelectedItem(MapItem);
}

function SetSelected(float X, float Y)
{
	GetPlayerOwner().PlaySound(Sound'LittleSelect', SLOT_Interface);
	Super.SetSelected(X, Y);
}

function int MapCount()
{
	return Items.CountShown();
}

function string GetMapRating(string MapName)
{
	local MV_ListItem CurItem;

	CurItem = MV_ListItem(Items.Next);

	while(CurItem != None)
	{
		if(CurItem.MapName == MapName)
			return CurItem.MapRating;

		CurItem = MV_ListItem(CurItem.Next);
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
//-----------------------------------------------------------------------------
function Sorting(bool bName)
{
	local int i, x;
	local MV_ListItem CurItem;

	CurItem = MV_ListItem(Items.Next);

	while(CurItem != None)
	{
		ListItems[i++] = CurItem;
		CurItem = MV_ListItem(CurItem.Next);
	}
	Items.Clear();

	if(bName)
	{
		bAscName = !bAscName;
		SortMapsOnName(0, i-1);
	}
	else
	{
		bAscDiff = !bAscDiff;
		SortMapsOnDiff(0, i-1);
	}

	for(x = 0; x < i; x++)
		Items.AppendItem(ListItems[x]);
}

function SortMapsOnName(int low, int high)
{
	local int i, j;
	local string x;
	local MV_ListItem tmp;

	i = low;
	j = high;
	x = ListItems[(low+high)/2].MapName;

	do
	{
		if(bAscName)
		{
			while(ListItems[i].MapName < x)
				i += 1;
			while(ListItems[j].MapName > x)
				j -= 1;
		}
		else
		{
			while(ListItems[i].MapName > x)
				i += 1;
			while(ListItems[j].MapName < x)
				j -= 1;
		}
		if(i <= j)
		{
			tmp = ListItems[j];
			ListItems[j] = ListItems[i];
			ListItems[i] = tmp;
			
			i += 1;
			j -= 1;
		}
	} until(i > j);

	if(low < j)
		SortMapsOnName(low, j);
	if(i < high)
		SortMapsOnName(i, high);
}

function SortMapsOnDiff(int low, int high)
{
	local int i, j, x;
	local MV_ListItem tmp;

	i = low;
	j = high;
	x = int(ListItems[(low+high)/2].MapRating);

	do
	{
		if(bAscDiff)
		{
			while(int(ListItems[i].MapRating) < x)
				i += 1;
			while(int(ListItems[j].MapRating) > x)
				j -= 1;
		}
		else
		{
			while(int(ListItems[i].MapRating) > x)
				i += 1;
			while(int(ListItems[j].MapRating) < x)
				j -= 1;
		}
		if(i <= j)
		{
			tmp = ListItems[j];
			ListItems[j] = ListItems[i];
			ListItems[i] = tmp;
			
			i += 1;
			j -= 1;
		}
	} until(i > j);

	if(low < j)
		SortMapsOnDiff(low, j);
	if(i < high)
		SortMapsOnDiff(i, high);
}
//-----------------------------------------------------------------------------
defaultproperties
{
	bAscName=true;
	bAscDiff=false;
	ItemHeight=20
	ListClass=class'MV_ListItem'
}