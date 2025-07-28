unit AcrylicControlU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  GR32,
  GR32_Polygons,
  GR32_VectorUtils,
  AcrylicTypesU,
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL;

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
    procedure SetBackColor       (a_clBackColor   : TColor);
    procedure SetBorderColor     (a_clBorderColor : TAlphaColor);
    procedure SetCornerRadius    (a_dCornerRadius : Double);
    procedure SetWithBorder      (a_bWithBorder   : Boolean);
    procedure SetWithBackground  (a_bWithBack     : Boolean);
    procedure SetTriggerDblClick (a_nDblClick     : Boolean);


  protected
    m_msMouseState  : TMouseState;
    m_strText       : String;
    m_strTexts      : TStringList;
    m_bmpPaint      : TBitmap;
    m_bRepaint      : Boolean;
    m_aAlignment    : TAlignment;
    m_clColor       : TAlphaColor;
    m_clFontColor   : TAlphaColor;
    m_clBackColor   : TColor;
    m_clBorderColor : TAlphaColor;
    m_clReset       : TAlphaColor;
    m_fFont         : TFont;
    m_dCornerRadius : Double;
    m_bWithBorder   : Boolean;
    m_bWithBack     : Boolean;
    m_bClickable    : Boolean;
    m_bGhost        : Boolean;
    m_bmpBuffer     : TBitmap32;

    m_gdiGraphics   : TGPGraphics;
    m_gdiSolidPen   : TGPPen;
    m_gdiBrush      : TGPSolidBrush;
    m_gdiFont       : TGPFont;


    procedure Paint; override;
    procedure PaintComponent; virtual;
    procedure PaintBackground;
    procedure PaintText(a_nLeft : Integer = -1; a_nTop : Integer = -1);
    procedure PaintEnabled;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure Refresh(a_bForce : Boolean = False);

  published
    property Text            : String      read m_strText       write SetText;
    property Texts           : TStringList read m_strTexts      write SetTexts;
    property Font            : TFont       read m_fFont         write SetFont;
    property Alignment       : TAlignment  read m_aAlignment    write SetAlignment;
    property Color           : TAlphaColor read m_clColor       write SetColor;
    property FontColor       : TAlphaColor read m_clFontColor   write SetFontColor;
    property BackColor       : TColor      read m_clBackColor   write SetBackColor;
    property BorderColor     : TAlphaColor read m_clBorderColor write SetBorderColor;
    property CornerRadius    : Double      read m_dCornerRadius write SetCornerRadius;
    property WithBorder      : Boolean     read m_bWithBorder   write SetWithBorder;
    property WithBackground  : Boolean     read m_bWithBack     write SetWithBackground;
    property Ghost           : Boolean     read m_bGhost        write m_bGhost;
    property TriggerDblClick : Boolean                          write SetTriggerDblClick;
    property Clickable       : Boolean     read m_bClickable    write m_bClickable;

    property Enabled;
    property OnClick;
    property OnDblClick;
    property Hint;
    property ShowHint;
    property Visible;
    property OnMouseWheelUp;
    property OnMouseWheelDown;

  end;

implementation

uses
  Math, AcrylicUtilsU;

//==============================================================================
constructor TAcrylicControl.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  m_aAlignment    := aCenter;
  m_strText       := Name;

  m_msMouseState  := msNone;
  m_bClickable    := False;
  m_bGhost        := False;
  m_bRepaint      := True;
  m_bWithBorder   := True;
  m_bWithBack     := True;
  m_fFont         := TFont.Create;
  m_bmpPaint      := TBitmap.Create;
  m_strTexts      := TStringList.Create;

  m_clFontColor   := c_clCtrlFont;
  m_clColor       := c_clCtrlColor;
  m_clBorderColor := c_clCtrlBorder;
  m_clBackColor   := c_clFormBack;
  m_dCornerRadius := 0;

  m_fFont.Name    := 'Tahoma';
  m_fFont.Size    := 8;
  m_fFont.Style   := [];

  m_bmpBuffer     := TBitmap32.Create;

  m_gdiGraphics   := nil;
  m_gdiSolidPen   := TGPPen.Create(0);
  m_gdiBrush      := TGPSolidBrush.Create(0);

  ControlStyle := ControlStyle - [csDoubleClicks];
end;

//==============================================================================
destructor TAcrylicControl.Destroy;
begin
  m_bmpPaint.Free;
  m_fFont.Free;
  m_gdiSolidPen.Free;
  m_gdiBrush.Free;
  m_strTexts.Free;
  m_bmpBuffer.Free;

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
procedure TAcrylicControl.SetBackColor(a_clBackColor : TColor);
begin
  m_clBackColor := a_clBackColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetBorderColor(a_clBorderColor : TAlphaColor);
begin
  m_clBorderColor := a_clBorderColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetCornerRadius(a_dCornerRadius : Double);
begin
  m_dCornerRadius := a_dCornerRadius;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetWithBorder(a_bWithBorder : Boolean);
begin
  m_bWithBorder := a_bWithBorder;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.SetWithBackground(a_bWithBack : Boolean);
begin
  m_bWithBack := a_bWithBack;
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
procedure TAcrylicControl.Refresh(a_bForce : Boolean = False);
begin
  m_bRepaint := m_bRepaint or a_bForce;

  if m_bRepaint then
    Invalidate;
end;

//==============================================================================
procedure TAcrylicControl.Paint;
begin
  if m_bRepaint then
  begin
    ////////////////////////////////////////////////////////////////////////////
    // Create bitmap that will contain the final result
    m_bmpPaint.SetSize(ClientWidth,ClientHeight);

    ////////////////////////////////////////////////////////////////////////////
    // Draw background
    PaintBackground;

    ////////////////////////////////////////////////////////////////////////////
    // Initializes GDI
    m_gdiGraphics := TGPGraphics.Create(m_bmpPaint.Canvas.Handle);
    m_gdiGraphics.SetSmoothingMode(SmoothingModeNone);
    m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

    ////////////////////////////////////////////////////////////////////////////
    // Draw Component
    PaintComponent;
    PaintEnabled;

    m_gdiGraphics.Free;
    m_bRepaint := False;
  end;
  //////////////////////////////////////////////////////////////////////////////
  // Draw result to canvas
  Canvas.Draw(0, 0, m_bmpPaint);
end;

//==============================================================================
procedure TAcrylicControl.PaintBackground;
var
  clColor   : TAlphaColor;
  arrPoints : TArrayOfFloatPoint;
begin
  m_bmpBuffer.SetSize(ClientWidth, ClientHeight);

  if g_bWithBlur
    then m_bmpBuffer.FillRect(0, 0, ClientWidth, ClientHeight, c_clTransparent)
    else m_bmpBuffer.FillRect(0, 0, ClientWidth, ClientHeight, m_clBackColor);

  if m_bWithBack then
  begin
    clColor := 0;

    case m_msMouseState of
      msNone    : clColor := ChangeColor(m_clColor, 0,  0,  0,  0);
      msHover   : clColor := ChangeColor(m_clColor, 0, 25, 25, 25);
      msClicked : clColor := ChangeColor(m_clColor, 0, 40, 40, 40);
    end;

    if m_dCornerRadius <> 0 then
    begin
      arrPoints := RoundRect(FloatRect(0, 0, ClientWidth, ClientHeight), m_dCornerRadius);
      PolygonFS(m_bmpBuffer, arrPoints, clColor);
    end
    else
    begin
      m_bmpBuffer.FillRectTS(0, 0, ClientWidth, ClientHeight, clColor);
    end;
  end;

  if m_bWithBorder then
    m_bmpBuffer.FrameRectTS(0, 0, ClientWidth, ClientHeight, m_clBorderColor);

  m_bmpBuffer.Lock;
  try
    BitBlt(m_bmpPaint.Canvas.Handle, 0, 0, Width, Height, m_bmpBuffer.Handle, 0, 0, SRCCOPY);
  finally
    m_bmpBuffer.Unlock;
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
    ///  One single String:
    if Text <> '' then
    begin
      m_gdiGraphics.MeasureString(Text, -1, gdiFont, pntText, recText);

      if a_nLeft < 0 then
      begin
        case Alignment of
          aCenter: pntText.X := Trunc(ClientWidth  - recText.Width) div 2;
          aLeft:   pntText.X := 1;
          aRight:  pntText.X := Trunc(ClientWidth  - recText.Width - 1);
        end;
      end
      else
        pntText.X := a_nLeft;

      if a_nTop < 0
        then pntText.Y := (Trunc(ClientHeight - recText.Height) div 2) + 1
        else pntText.Y := a_nTop;

      m_gdiGraphics.DrawString(Text, -1, gdiFont, pntText, m_gdiBrush);
    end
    ////////////////////////////////////////////////////////////////////////////
    ///  Multiple Strings:
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
  begin
    m_gdiBrush.SetColor(GdiColor(c_clCtrlDisabled));
    m_gdiGraphics.FillRectangle(m_gdiBrush, 1, 1, ClientWidth-2, ClientHeight-2);
  end;
end;

//==============================================================================
procedure TAcrylicControl.PaintComponent;
begin
  //
end;

//==============================================================================
procedure TAcrylicControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if m_bClickable then
    m_msMouseState := msNone;

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if m_bClickable then
    m_msMouseState := msClicked;

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
  // Do nothing to prevent flickering
end;

//==============================================================================
procedure TAcrylicControl.WMNCMoving(var Msg: TWMMoving);
begin
  inherited;
  Refresh(True);
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
    m_msMouseState := msHover;

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.CMMouseLeave(var Msg: TMessage);
begin
  if m_bClickable then
    m_msMouseState := msNone;

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;

  if m_bGhost then
    Msg.Result := HTTRANSPARENT;
end;

end.
