unit AcrylicControlU;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  GR32,
  AcrylicTypesU,
  GDIPOBJ;

type

  TAcrylicControl = Class(TCustomControl)
  private
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCMoving  (var Msg: TWMMoving);     message WM_MOVING;
    procedure WMNCSize    (var Msg: TWMSize);       message WM_SIZE;
    procedure CMMouseEnter(var Msg: TMessage);      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage);      message CM_MOUSELEAVE;
    procedure WMNCHitTest (var Msg: TWMNCHitTest);  message WM_NCHITTEST;

    procedure SetText            (a_strText       : String);
    procedure SetTexts           (a_strTexts      : TStringList);
    procedure SetFont            (a_fFont         : TFont);
    procedure SetAlignment       (a_aAlignment    : TAlignment);
    procedure SetColor           (a_clColor       : TAlphaColor);
    procedure SetFontColor       (a_clFontColor   : TAlphaColor);
    procedure SetBorderColor     (a_clBorderColor : TAlphaColor);
    procedure SetBorderRadius    (a_dBorderRadius : Double);
    procedure SetWithBorder      (a_bWithBorder   : Boolean);
    procedure SetColored         (a_bColored      : Boolean);
    procedure SetTriggerDblClick (a_nDblClick     : Boolean);

  protected
    m_msMouseState  : TMouseState;
    m_strText       : String;
    m_strTexts      : TStringList;
    m_bmpBuffer     : TBitmap32;
    m_bRepaint      : Boolean;
    m_aAlignment    : TAlignment;
    m_clColor       : TAlphaColor;
    m_clFontColor   : TAlphaColor;
    m_clBorderColor : TAlphaColor;
    m_fFont         : TFont;
    m_dBorderRadius : Double;
    m_bWithBorder   : Boolean;
    m_bColored      : Boolean;
    m_bClickable    : Boolean;
    m_bGhost        : Boolean;
    m_nAuxId        : Integer;
    m_gdiGraphics   : TGPGraphics;
    m_gdiSolidPen   : TGPPen;
    m_gdiBrush      : TGPSolidBrush;
    m_gdiFont       : TGPFont;

    procedure InitializeGDI;
    procedure ShutdownGDI;

    procedure Paint; override;
    procedure PaintComponent; virtual;
    procedure PaintBackground;
    procedure PaintText(a_nLeft : Integer = -1; a_nTop : Integer = -1);
    procedure PaintEnabled;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(                      Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(a_cOwner: TComponent); override;
    destructor  Destroy; override;

    procedure Refresh(a_bRepaint : Boolean = False);

  published
    property Text            : String      read m_strText       write SetText;
    property Texts           : TStringList read m_strTexts      write SetTexts;
    property Font            : TFont       read m_fFont         write SetFont;
    property Alignment       : TAlignment  read m_aAlignment    write SetAlignment;
    property Color           : TAlphaColor read m_clColor       write SetColor;
    property FontColor       : TAlphaColor read m_clFontColor   write SetFontColor;
    property BorderColor     : TAlphaColor read m_clBorderColor write SetBorderColor;
    property BorderRadius    : Double      read m_dBorderRadius write SetBorderRadius;
    property WithBorder      : Boolean     read m_bWithBorder   write SetWithBorder;
    property Colored         : Boolean     read m_bColored      write SetColored;
    property Ghost           : Boolean     read m_bGhost        write m_bGhost;
    property TriggerDblClick : Boolean                          write SetTriggerDblClick;
    property Clickable       : Boolean     read m_bClickable    write m_bClickable;
    property AuxId           : Integer     read m_nAuxId        write m_nAuxId;

    property Enabled;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property Hint;
    property ShowHint;
    property Visible;
    property OnMouseWheelUp;
    property OnMouseWheelDown;

  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  Math,
  AcrylicUtilsU,
  GR32_Polygons,
  GR32_VectorUtils,
  GDIPAPI;

//==============================================================================
constructor TAcrylicControl.Create(a_cOwner: TComponent);
begin
  Inherited Create(a_cOwner);

  m_aAlignment    := aCenter;
  m_strText       := Name;

  m_msMouseState  := msNone;
  m_bClickable    := False;
  m_bGhost        := False;
  m_bRepaint      := True;
  m_bWithBorder   := False;
  m_bColored      := False;
  m_fFont         := TFont.Create;
  m_bmpBuffer     := TBitmap32.Create;
  m_strTexts      := TStringList.Create;
  m_nAuxId        := -1;

  m_clFontColor   := c_clCtrlFont;
  m_clColor       := c_clCtrlColor;
  m_clBorderColor := c_clCtrlBorder;
  m_dBorderRadius := 0;

  m_fFont.Name    := 'Tahoma';
  m_fFont.Size    := 8;
  m_fFont.Style   := [];

  m_gdiGraphics   := nil;
  m_gdiSolidPen   := TGPPen.Create(0);
  m_gdiBrush      := TGPSolidBrush.Create(0);

  ControlStyle := ControlStyle - [csDoubleClicks] + [csAcceptsControls];
end;

//==============================================================================
destructor TAcrylicControl.Destroy;
begin
  m_bmpBuffer.Free;
  m_fFont.Free;
  m_gdiSolidPen.Free;
  m_gdiBrush.Free;
  m_strTexts.Free;

  Inherited;
end;

//==============================================================================
procedure TAcrylicControl.SetText(a_strText : String);
begin
  m_strText := a_strText;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetTexts(a_strTexts : TStringList);
begin
  m_strTexts := a_strTexts;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetFont(a_fFont : TFont);
begin
  m_fFont := a_fFont;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetAlignment(a_aAlignment : TAlignment);
begin
  m_aAlignment := a_aAlignment;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetColor(a_clColor : TAlphaColor);
begin
  m_clColor := a_clColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetFontColor(a_clFontColor : TAlphaColor);
begin
  m_clFontColor := a_clFontColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetBorderColor(a_clBorderColor : TAlphaColor);
begin
  m_clBorderColor := a_clBorderColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetBorderRadius(a_dBorderRadius : Double);
begin
  m_dBorderRadius := a_dBorderRadius;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetWithBorder(a_bWithBorder : Boolean);
begin
  m_bWithBorder := a_bWithBorder;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetColored(a_bColored : Boolean);
begin
  m_bColored := a_bColored;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetTriggerDblClick(a_nDblClick : Boolean);
begin
  if a_nDblClick
    then ControlStyle := ControlStyle + [csDoubleClicks]
    else ControlStyle := ControlStyle - [csDoubleClicks];
end;


//==============================================================================
procedure TAcrylicControl.Refresh(a_bRepaint : Boolean = False);
begin
  m_bRepaint := m_bRepaint or a_bRepaint;
  Invalidate;
end;

//==============================================================================
procedure TAcrylicControl.InitializeGDI;
begin
  m_gdiGraphics := TGPGraphics.Create(m_bmpBuffer.Canvas.Handle);
  m_gdiGraphics.SetSmoothingMode(SmoothingModeNone);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);
end;

//==============================================================================
procedure TAcrylicControl.ShutdownGDI;
begin
  FreeAndNil(m_gdiGraphics);
end;

//==============================================================================
procedure TAcrylicControl.Paint;
begin
  if m_bRepaint then
  begin
    ////////////////////////////////////////////////////////////////////////////
    // Ser buffer size
    m_bmpBuffer.SetSize(Width, Height);

    ////////////////////////////////////////////////////////////////////////////
    // Draw background
    PaintBackground;

    ////////////////////////////////////////////////////////////////////////////
    // Draw Component
    PaintComponent;
    PaintEnabled;

    m_bRepaint := False;
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Draw result to canvas
  Canvas.Lock;
  try
    BitBlt(Canvas.Handle, 0, 0, Width, Height, m_bmpBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    Canvas.Unlock;
  end;
end;

//==============================================================================
procedure TAcrylicControl.PaintBackground;
var
  clColor   : TAlphaColor;
  arrPoints : TArrayOfFloatPoint;
begin
  //////////////////////////////////////////////////////////////////////////////
  // Erase background
  m_bmpBuffer.FillRect(0, 0, Width, Height, $0);

  //////////////////////////////////////////////////////////////////////////////
  // Replicates parent's background color
  if (Parent <> nil) and (Parent is TAcrylicControl) then
    m_bmpBuffer.FillRectTS(0, 0, Width, Height, TAcrylicControl(Parent).Color);

  if m_dBorderRadius <> 0 then
    arrPoints := RoundRect(FloatRect(0.5, 0.5, Width - 0.5, Height - 0.5), m_dBorderRadius);

  //////////////////////////////////////////////////////////////////////////////
  // Paints own background
  if m_bColored then
  begin
    clColor := 0;

    case m_msMouseState of
      msNone    : clColor := ChangeColor(m_clColor, 0,  0,  0,  0);
      msHover   : clColor := ChangeColor(m_clColor, 0, 25, 25, 25);
      msClicked : clColor := ChangeColor(m_clColor, 0, 40, 40, 40);
    end;

    if m_dBorderRadius <> 0
      then PolygonFS(m_bmpBuffer, arrPoints, clColor)
      else m_bmpBuffer.FillRectTS(0, 0, Width, Height, clColor);
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Paints the borders
  if m_bWithBorder then
  begin
    if m_dBorderRadius <> 0
      then PolylineFS(m_bmpBuffer, arrPoints, m_clBorderColor, True)
      else m_bmpBuffer.FrameRectTS(0, 0, Width, Height, m_clBorderColor);
  end;
end;

//==============================================================================
procedure TAcrylicControl.PaintText(a_nLeft : Integer = -1; a_nTop : Integer = -1);
var
  pntText : TGPPointF;
  recText : TGPRectF;
  gdiFont : TGPFont;
  fsStyle : TFontStyle;
  nStrIdx : Integer;
const
  c_nLineBreakGap = 1;
begin
  assert(m_gdiGraphics <> nil);

  if (Text <> '') or (Texts.Count > 0) then
  begin
    if fsBold in Font.Style
      then fsStyle := FontStyleBold
      else fsStyle := FontStyleRegular;

    m_gdiBrush.SetColor(GdiColor(FontColor));
    gdiFont := TGPFont.Create(Font.Name, Font.Size, fsStyle);
    pntText.X := 0;
    pntText.Y := 0;

    ////////////////////////////////////////////////////////////////////////////
    ///  One single String
    if Text <> '' then
    begin
      m_gdiGraphics.MeasureString(Text, -1, gdiFont, pntText, recText);

      if a_nLeft < 0 then
      begin
        case Alignment of
          aCenter: pntText.X := Trunc(Width  - recText.Width) div 2;
          aLeft:   pntText.X := 1;
          aRight:  pntText.X := Trunc(Width  - recText.Width - 1);
        end;
      end
      else
        pntText.X := a_nLeft;

      if a_nTop < 0
        then pntText.Y := (Trunc(Height - recText.Height) div 2) + 1
        else pntText.Y := a_nTop;

      m_gdiGraphics.DrawString(Text, -1, gdiFont, pntText, m_gdiBrush);
    end
    ////////////////////////////////////////////////////////////////////////////
    ///  Multiple Strings
    else if Texts.Count > 0 then
    begin
      m_gdiGraphics.MeasureString(Texts[0], -1, gdiFont, pntText, recText);

      for nStrIdx := 0 to Texts.Count - 1 do
      begin
        pntText.X := 1;
        pntText.Y := (recText.Height + c_nLineBreakGap) * nStrIdx;

        m_gdiGraphics.DrawString(Texts[nStrIdx], -1, gdiFont, pntText, m_gdiBrush);
      end;
    end;

    gdiFont.Free;
  end;
end;

//==============================================================================
procedure TAcrylicControl.PaintEnabled;
begin
  if not Enabled then
    m_bmpBuffer.FillRectTS(0, 0, Width, Height, c_clCtrlDisabled);
end;

//==============================================================================
procedure TAcrylicControl.PaintComponent;
begin
  // The derived component should override this procedure if needed.
end;

//==============================================================================
procedure TAcrylicControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if m_bClickable then
    m_msMouseState := msNone;

  if Assigned(OnMouseUp) then
    OnMouseUp(Self, Button, Shift, X, Y);

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if m_bClickable then
    m_msMouseState := msClicked;

  if Assigned(OnMouseDown) then
    OnMouseDown(Self, Button, Shift, X, Y);

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //
end;

//==============================================================================
procedure TAcrylicControl.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  // Do nothing to prevent flickering.
end;

//==============================================================================
procedure TAcrylicControl.WMNCMoving(var Msg: TWMMoving);
begin
  inherited;
  Refresh;
end;

//==============================================================================
procedure TAcrylicControl.WMNCSize(var Msg: TWMSize);
begin
  inherited;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.CMMouseEnter(var Msg: TMessage);
begin
  if m_bClickable then
  begin
    m_msMouseState := msHover;
    Refresh(True);
  end;
end;

//==============================================================================
procedure TAcrylicControl.CMMouseLeave(var Msg: TMessage);
begin
  if m_bClickable then
  begin
    m_msMouseState := msNone;
    Refresh(True);
  end;
end;

//==============================================================================
procedure TAcrylicControl.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;

  if m_bGhost then
    Msg.Result := HTTRANSPARENT;
end;

end.
