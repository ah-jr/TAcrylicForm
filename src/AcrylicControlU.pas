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
  AcrylicTypesU,
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL;

type
  TAcrylicControl = Class(TCustomControl)
  private
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMMouseEnter(var Message: TMessage);      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);      message CM_MOUSELEAVE;

    procedure SetText(a_strText : String);

  protected
    m_msMouseState  : TMouseState;
    m_strText       : String;
    m_bmpPaint      : TBitmap;
    m_bRepaint      : Boolean;
    m_aAlignment    : TAlignment;
    m_clColor       : TAlphaColor;
    m_clFontColor   : TAlphaColor;
    m_clBackColor   : TAlphaColor;
    m_clBorderColor : TAlphaColor;
    m_fFont         : TFont;
    m_bWithBorder   : Boolean;
    m_bWithBack     : Boolean;

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
    property Text           : String      read m_strText       write SetText;
    property Font           : TFont       read m_fFont         write m_fFont;
    property Alignment      : TAlignment  read m_aAlignment    write m_aAlignment;
    property Color          : TAlphaColor read m_clColor       write m_clColor;
    property FontColor      : TAlphaColor read m_clFontColor   write m_clFontColor;
    property BackColor      : TAlphaColor read m_clBackColor   write m_clBackColor;
    property BorderColor    : TAlphaColor read m_clBorderColor write m_clBorderColor;
    property WithBorder     : Boolean     read m_bWithBorder   write m_bWithBorder;
    property WithBackground : Boolean     read m_bWithBack     write m_bWithBack;

    property Enabled;
    property OnClick;
    property OnDblClick;
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
  m_bRepaint      := True;
  m_bWithBorder   := True;
  m_bWithBack     := True;
  m_fFont         := TFont.Create;
  m_bmpPaint      := TBitmap.Create;


  m_clColor       := $FFFFFFFF;
  m_clFontColor   := $FFFFFFFF;
  m_clBackColor   := $640F0F0F;
  m_clBorderColor := $64070707;

  m_fFont.Name    := 'Tahoma';
  m_fFont.Size    := 8;
  m_fFont.Style   := [];

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

  Inherited;
end;

//==============================================================================
procedure TAcrylicControl.SetText(a_strText : String);
begin
  m_strText := a_strText;
  Refresh(True);
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
    m_bmpPaint.Canvas.Brush.Color := clBackground;
    m_bmpPaint.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

    m_gdiGraphics := TGPGraphics.Create(m_bmpPaint.Canvas.Handle);
    m_gdiGraphics.SetSmoothingMode(SmoothingModeNone);
    m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

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
  nColor  : Cardinal;
  recBack : TGPRect;
begin
  nColor := 0;

  if m_bWithBack then
  begin
    if Enabled then
    begin
      case m_msMouseState of
        msNone    : nColor := GdiChangeColor(GdiColor(m_clBackColor), 0,  0,  0,  0);
        msHover   : nColor := GdiChangeColor(GdiColor(m_clBackColor), 0, 15, 15, 15);
        msClicked : nColor := GdiChangeColor(GdiColor(m_clBackColor), 0, 30, 30, 30);
      end;
    end
    else
      nColor := GdiColor(m_clBackColor);

    if m_bWithBorder then
      recBack := MakeRect(1, 1, ClientWidth - 2, ClientHeight - 2)
    else
      recBack := MakeRect(0, 0, ClientWidth, ClientHeight);

    m_gdiBrush.SetColor(nColor);
    m_gdiGraphics.FillRectangle(m_gdiBrush, recBack);
  end;

  if m_bWithBorder then
  begin
    nColor := GdiColor(m_clBorderColor);

    m_gdiSolidPen.SetColor(nColor);
    m_gdiGraphics.DrawRectangle(m_gdiSolidPen, 0, 0, ClientWidth-1, ClientHeight-1);
  end;
end;

//==============================================================================
procedure TAcrylicControl.PaintText(a_nLeft : Integer = -1; a_nTop : Integer = -1);
var
  pntText : TGPPointF;
  recText : TGPRectF;
  gdiFont : TGPFont;
begin
  if Text <> '' then
  begin
    gdiFont := TGPFont.Create(Font.Name, Font.Size, FontStyleRegular);

    pntText.X := 0;
    pntText.Y := 0;

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

    if a_nTop < 0 then
    begin
      pntText.Y := (Trunc(ClientHeight - recText.Height) div 2) + 1;
    end
    else
      pntText.Y := a_nTop;

    m_gdiBrush.SetColor(GdiColor(FontColor));
    m_gdiGraphics.DrawString(Text, -1, gdiFont, pntText, m_gdiBrush);

    gdiFont.Free;
  end;
end;

//==============================================================================
procedure TAcrylicControl.PaintEnabled;
begin
  if not Enabled then
  begin
    m_gdiBrush.SetColor(GdiColor($A0252525));
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
  m_msMouseState := msNone;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msClicked;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //
end;

//==============================================================================
procedure TAcrylicControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  // Do nothing to prevent flickering
end;

//==============================================================================
procedure TAcrylicControl.CMMouseEnter(var Message: TMessage);
begin
  m_msMouseState := msHover;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicControl.CMMouseLeave(var Message: TMessage);
begin
  m_msMouseState := msNone;
  Refresh(True);
end;

end.


