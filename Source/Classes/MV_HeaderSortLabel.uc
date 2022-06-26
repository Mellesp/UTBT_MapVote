//=============================================================================
// MV_HeaderSortLabel made by OwYeaW
//=============================================================================
class MV_HeaderSortLabel expands UWindowLabelControl;
//-----------------------------------------------------------------------------
var MV_MainWindow	Main;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();
	Main = MV_MainWindow(ParentWindow);
	Cursor = Root.HandCursor;
}
//-----------------------------------------------------------------------------
function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	C.Font = Main.Fonts[Main.F_Title];
	TextSize(C, Text, W, H);
	WinHeight = H+1;

	TextY = (WinHeight - H) / 2;
	switch(Align)
	{
		case TA_Left:
			break;
		case TA_Center:
			TextX = (WinWidth - W)/2;
			break;
		case TA_Right:
			TextX = WinWidth - W;
			break;
	}	
}
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	if(Text != "")
	{
		C.DrawColor = Main.YellowHeaderColor;
		ClipText(C, TextX, TextY, Text);
	}
}
//-----------------------------------------------------------------------------
function Click(float X, float Y)
{
	UWindowDialogClientWindow(ParentWindow).Notify(self, DE_Click);
}