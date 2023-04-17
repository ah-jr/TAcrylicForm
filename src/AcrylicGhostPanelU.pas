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
  GR32,
  Registry,
  DWMApi;

type

  TAcrylicGhostPanel = Class(TPanel)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;

  protected
    m_bmpBuffer     : TBitmap32;
    m_clBackColor   : TColor;
    m_clColor       : TAlphaColor;
    m_clBorderColor : TAlphaColor;
    m_bGhost        : Boolean;
    m_bColored      : Boolean;
    m_bWithBorder   : Boolean;

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
  GR32_Backends,
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
  m_clColor     := c_clFormColor;
  m_bColored    := False;
  m_bWithBorder := False;
  m_bGhost      := True;
  m_bmpBuffer   := TBitmap32.Create;
end;

//==============================================================================
destructor TAcrylicGhostPanel.Destroy;
begin
  m_bmpBuffer.Free;

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
begin
  m_bmpBuffer.SetSize(ClientWidth, ClientHeight);

  if g_bWithBlur
    then m_bmpBuffer.FillRect(0, 0, ClientWidth, ClientHeight, c_clTransparent)
    else m_bmpBuffer.FillRect(0, 0, ClientWidth, ClientHeight, m_clBackColor);

  if m_bColored then
    m_bmpBuffer.FillRectTS(0, 0, ClientWidth, ClientHeight, m_clColor);

  if m_bWithBorder then
    m_bmpBuffer.FrameRectTS(0, 0, ClientWidth, ClientHeight, m_clBorderColor);

  m_bmpBuffer.Lock;
  try
    BitBlt(Canvas.Handle, 0, 0, Width, Height, m_bmpBuffer.Handle, 0, 0, SRCCOPY);
  finally
    m_bmpBuffer.Unlock;
  end;
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  //
end;

end.


