//=============================================================================
// MV_EditControl made by OwYeaW
//=============================================================================
class MV_EditControl expands UWindowEditControl;
//-----------------------------------------------------------------------------
var	MV_MainWindow	Main;
var	float			EditBoxHeight;
//-----------------------------------------------------------------------------
function Created()
{
	Super(UWindowDialogControl).Created();
	Main = MV_MainWindow(ParentWindow);
	
	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, WinWidth, WinHeight)); 
	EditBox.NotifyOwner = Self;
	EditBox.bSelectOnFocus = True;

	EditBoxWidth	= WinWidth;
	EditBoxHeight	= WinHeight;
	SetFont(3);

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}
//-----------------------------------------------------------------------------
function BeforePaint(Canvas C, float X, float Y)
{
	Super(UWindowDialogControl).BeforePaint(C, X, Y);
	MV_LookAndFeel(LookAndFeel).MV_Editbox_SetupSizes(Self, C);
}