unit AcrylicTypesU;

interface

const

  // Default colors:
  c_clCtrlFont     = $FFFFFFFF;
  c_clCtrlColor    = $640F0F0F;
  c_clCtrlBorder   = $34777777;
  c_clCtrlDisabled = $A0252525;

  c_clBlurColor    = $B4202020;
  c_clFormBorder   = $30FFFFFF;
  c_clFrameBorder  = $644A4A4A;
  c_clFrameTitle   = $B0101012;

type
  TMouseState = (msHover,
                 msClicked,
                 msNone);

  TAlignment  = (aCenter,
                 aLeft,
                 aRight);

  TAcrylicFormStyle  = set of (fsClose,
                               fsMinimize,
                               fsMaximize);

  TIntArray = Array of Integer;
  PIntArray = ^TIntArray;

  TSingleArray = Array of Single;
  PSingleArray = ^TSingleArray;

implementation

end.
