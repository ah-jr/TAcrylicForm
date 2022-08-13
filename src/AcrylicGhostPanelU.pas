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
    m_bmpPaint : TBitmap;

    procedure Paint; override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;


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
  DateUtils,
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
  m_bmpPaint    := TBitmap.Create;
end;

//==============================================================================
destructor TAcrylicGhostPanel.Destroy;
begin
  m_bmpPaint.Free;

  Inherited;
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  if m_bGhost then
    Msg.Result := HTTRANSPARENT;
end;

//==============================================================================
procedure TAcrylicGhostPanel.Paint;
var
  gdiGraphics : TGPGraphics;
  gdiBrush    : TGPSolidBrush;
  gdiPen      : TGPPen;
begin
  //////////////////////////////////////////////////////////////////////////////
  ///  Clear Background
  m_bmpPaint.SetSize(ClientWidth, ClientHeight);

  if g_bWithBlur
    then m_bmpPaint.Canvas.Brush.Color := c_clTransparent
    else m_bmpPaint.Canvas.Brush.Color := m_clBackColor;

  m_bmpPaint.Canvas.Pen.Color := m_bmpPaint.Canvas.Brush.Color;
  m_bmpPaint.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  gdiGraphics := TGPGraphics.Create(m_bmpPaint.Canvas.Handle);

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
  Canvas.Draw(0, 0, m_bmpPaint);
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  //
end;

end.


