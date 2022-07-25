unit AcrylicTypesU;

interface

//uses

const

  // Default colors:
  c_clCtrlFont     = $FFFFFFFF;
  c_clCtrlMisc     = $FFFFFFFF;
  c_clCtrlBack     = $640F0F0F;
  c_clCtrlBorder   = $64070707;
  c_clCtrlDisabled = $A0252525;

  c_clFormColor    = $20000000;
  c_clFormBorder   = $30FFFFFF;
  c_clFormBack     = $1F1F1F;
  c_clFormBlur     = $202020;
  c_clTransparent  = $000000;


  c_nDefaultBlur = 180;

type
  TMouseState = (msHover,
                 msClicked,
                 msNone);

  TAlignment  = (aCenter,
                 aLeft,
                 aRight);

  TIntArray = Array of Integer;
  PIntArray = ^TIntArray;

  TSingleArray = Array of Single;
  PSingleArray = ^TSingleArray;

implementation

end.
