unit AcrylicGhostPanelU;

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
  Registry,
  DWMApi;

type

  TAcrylicGhostPanel = Class(TPanel)
  private
    m_clBackColor   : TColor;
    m_clColor       : TAlphaColor;
    m_clBorderColor : TAlphaColor;
    m_bGhost        : Boolean;
    m_bColored      : Boolean;
    m_bWithBorder   : Boolean;

    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;

  protected
    procedure Paint; override;

  public
    constructor Create(AOwner : TComponent); override;

  published
    property Ghost       : Boolean      read m_bGhost        write m_bGhost;
    property Colored     : Boolean      read m_bColored      write m_bColored;
    property Color       : TAlphaColor  read m_clColor       write m_clColor;
    property Backcolor   : TColor       read m_clBackColor   write m_clBackColor;
    property Bordercolor : TAlphaColor  read m_clBorderColor write m_clBorderColor;
    property WithBorder  : Boolean      read m_bWithBorder   write m_bWithBorder;
    property Canvas;

  end;

procedure Register;

implementation

uses
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL,
  AcrylicUtilsU,
  AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicGhostPanel]);
end;

//==============================================================================
constructor TAcrylicGhostPanel.Create(AOwner : TComponent);
begin
  Inherited;
  m_clBackColor := c_clFormBack;
  m_clColor     := c_clFormBack;
  m_bColored    := False;
  m_bWithBorder := False;
  m_bGhost      := True;
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;

  if m_bGhost then
    Msg.Result := HTTRANSPARENT;
end;

//==============================================================================
procedure TAcrylicGhostPanel.Paint;
var
  gdiGraphics : TGPGraphics;
  gdiBrush    : TGPSolidBrush;
  gdiPen      : TGPPen;
  bmpPaint    : TBitmap;
begin
  //////////////////////////////////////////////////////////////////////////////
  ///  Clear Background
  bmpPaint := TBitmap.Create;
  bmpPaint.SetSize(ClientWidth, ClientHeight);

  if g_bWithBlur
    then bmpPaint.Canvas.Brush.Color := c_clTransparent
    else bmpPaint.Canvas.Brush.Color := m_clBackColor;

  bmpPaint.Canvas.Pen.Color := bmpPaint.Canvas.Brush.Color;
  bmpPaint.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  gdiGraphics := TGPGraphics.Create(bmpPaint.Canvas.Handle);

  if m_bColored then
  begin
    gdiBrush    := TGPSolidBrush.Create(GdiColor(m_clColor));
    gdiGraphics.FillRectangle(gdiBrush, 0, 0, ClientWidth, ClientHeight);
    gdiBrush.Free;
  end;

  if m_bWithBorder then
  begin
    gdiPen := TGPPen.Create(GdiColor(m_clBorderColor), 1);
    gdiGraphics.DrawRectangle(gdiPen, 0, 0, ClientWidth - 1, ClientHeight - 1);
    gdiPen.Free;
  end;

  gdiGraphics.Free;
  Canvas.Draw(0, 0, bmpPaint);
  bmpPaint.Free;
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  //
end;

end.


