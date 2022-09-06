unit AcrylicTypesU;

interface

//uses

const

  // Default colors:
  c_clCtrlFont     = $FFFFFFFF;
  c_clCtrlMisc     = $FFFFFFFF;
  c_clCtrlColor    = $640F0F0F;
  c_clCtrlBorder   = $34777777;
  c_clCtrlDisabled = $A0252525;

  c_clFormColor    = $20000000;
  c_clFormBorder   = $30FFFFFF;
  c_clFormBack     = $1F1F1F;
  c_clFormBlur     = $202020;
  c_clTransparent  = $000000;

  c_clSeaBlue      = $FF64FFFF;
  c_clLavaOrange   = $FFFF8B64;


  c_nDefaultBlur = 180;

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

  TPopUpItemEvent  = procedure of object;

implementation

end.
