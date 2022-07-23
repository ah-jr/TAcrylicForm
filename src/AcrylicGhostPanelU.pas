unit AcrylicGhostPanelU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
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
    m_clColor : TColor;
    m_bGhost  : Boolean;

    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;

  protected
    procedure Paint; override;

  public
    constructor Create(AOwner : TComponent); override;

  published
    property Ghost : Boolean read m_bGhost  write m_bGhost;
    property Color : TColor  read m_clColor write m_clColor;
    property Canvas;

  end;

procedure Register;

implementation

uses
  System.UITypes,
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
  m_clColor := c_clFormBack;
  m_bGhost  := True;
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
  m_bmpPaint : TBitmap;
begin
  m_bmpPaint := Tbitmap.Create;
  m_bmpPaint.SetSize(ClientWidth,ClientHeight);

  if g_bWithBlur
    then m_bmpPaint.Canvas.Brush.Color := c_clTransparent
    else m_bmpPaint.Canvas.Brush.Color := m_clColor;

  m_bmpPaint.Canvas.Pen.Color := m_bmpPaint.Canvas.Brush.Color;
  m_bmpPaint.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  Canvas.Draw(0,0, m_bmpPaint);
  m_bmpPaint.Free;
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  //
end;

end.


