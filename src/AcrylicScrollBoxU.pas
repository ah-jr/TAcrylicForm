unit AcrylicScrollBoxU;

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
  DWMApi,
  AcrylicGhostPanelU,
  AcrylicTypesU,
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL;

type

  TAcrylicScrollBox = Class(TAcrylicGhostPanel)
  private
    m_ScrollPanel   : TAcrylicGhostPanel;
    m_msMouseState  : TMouseState;
    m_clScrollColor : TAlphaColor;
    m_dLastTop      : Integer;
    m_nLastY        : Integer;

    procedure WMNCSize(var Message: TWMSize); message WM_SIZE;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;

  protected
    procedure Paint; override;
    procedure Loaded; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner : TComponent); override;
    procedure AddControl(a_Control : TControl);
    procedure Scroll(a_nDist : Integer);

  published
    property ScrollPanel : TAcrylicGhostPanel read m_ScrollPanel   write m_ScrollPanel;
    property ScrollColor : TAlphaColor        read m_clScrollColor write m_clScrollColor;

    property BackColor;
    property Color;
    property Canvas;
    property Colored;

  end;

const
  c_nScrollBarWidth = 10;

procedure Register;

implementation

uses
  Math,
  AcrylicUtilsU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicScrollBox]);
end;

//==============================================================================
constructor TAcrylicScrollBox.Create(AOwner : TComponent);
begin
  Inherited;

  m_dLastTop := 0;
  m_nLastY   := 0;

  m_clScrollColor := ToAlphaColor(clWhite);
  Color           := c_clFormColor;

  m_msMouseState  := msNone;
end;

//==============================================================================
procedure TAcrylicScrollBox.CMMouseWheel(var Message: TCMMouseWheel);
begin
  Inherited;

  if (m_ScrollPanel.Height > ClientHeight) and
     (GetKeyState(VK_SHIFT) >= 0) then
  begin
    if Message.WheelDelta > 0 then
      m_ScrollPanel.Top := Min(0, m_ScrollPanel.Top + 10);

    if Message.WheelDelta < 0 then
      m_ScrollPanel.Top := Max(ClientHeight - m_ScrollPanel.Height, m_ScrollPanel.Top - 10);

    Invalidate;
  end;
end;

//==============================================================================
procedure TAcrylicScrollBox.WMNCSize(var Message: TWMSize);
begin
  Inherited;

  m_ScrollPanel.Left   := 0;
  m_ScrollPanel.Top    := 0;
  m_ScrollPanel.Width  := ClientWidth - c_nScrollBarWidth;
end;

//==============================================================================
procedure TAcrylicScrollBox.Loaded;
var
  nCtrlIdx : Integer;
begin
  Inherited;

  Self.Ghost := False;

  m_ScrollPanel         := TAcrylicGhostPanel.Create(Self);
  m_ScrollPanel.Parent  := Self;
  m_ScrollPanel.Align   := alNone;
  m_ScrollPanel.Left    := 0;
  m_ScrollPanel.Top     := 0;
  m_ScrollPanel.Width   := ClientWidth - c_nScrollBarWidth;
  m_ScrollPanel.Height  := ClientHeight;
  m_ScrollPanel.Ghost   := False;
  m_ScrollPanel.Colored := Colored;
  m_ScrollPanel.Color   := Color;

  for nCtrlIdx := 0 to ControlCount - 2 do
  begin
    m_ScrollPanel.Height := Max(m_ScrollPanel.Height, Controls[nCtrlIdx].Top + Controls[nCtrlIdx].Height);

    Controls[nCtrlIdx].Parent := m_ScrollPanel;
  end;
end;

//==============================================================================
procedure TAcrylicScrollBox.Paint;
var
  gdiGraphics : TGPGraphics;
  gdiBrush    : TGPSolidBrush;
  nHeight     : Integer;
  nStart      : Integer;
  bmpPaint    : TBitmap;
begin
  //////////////////////////////////////////////////////////////////////////////
  ///  Clear Background
  bmpPaint := TBitmap.Create;
  bmpPaint.SetSize(ClientWidth, ClientHeight);

  if g_bWithBlur
    then bmpPaint.Canvas.Brush.Color := c_clTransparent
    else bmpPaint.Canvas.Brush.Color := c_clFormBack;

  bmpPaint.Canvas.Pen.Color := bmpPaint.Canvas.Brush.Color;
  bmpPaint.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  gdiGraphics := TGPGraphics.Create(bmpPaint.Canvas.Handle);
  gdiBrush    := TGPSolidBrush.Create(GdiColor(m_clScrollColor));

  if Colored then
  begin
    gdiBrush.SetColor(GdiColor(Color));
    gdiGraphics.FillRectangle(gdiBrush, 0, 0, ClientWidth, ClientHeight);
  end;

  //////////////////////////////////////////////////////////////////////////////
  ///  Paint ScrollBar
  if m_ScrollPanel <> nil then
  begin
    gdiBrush.SetColor(GdiColor(m_clScrollColor));

    nHeight := Trunc(ClientHeight * (ClientHeight / m_ScrollPanel.Height));

    if m_ScrollPanel.Height > ClientHeight then
    begin
      nStart := Trunc((ClientHeight - nHeight) * (m_ScrollPanel.Top / (ClientHeight - m_ScrollPanel.Height)));
      gdiGraphics.FillRectangle(gdiBrush, m_ScrollPanel.Width, nStart, c_nScrollBarWidth, nHeight);
    end;
  end;

  Canvas.Draw(0, 0, bmpPaint);

  gdiGraphics.Free;
  gdiBrush.Free;
end;

//==============================================================================
procedure TAcrylicScrollBox.AddControl(a_Control : TControl);
begin
  if a_Control <> nil then
  begin
    m_ScrollPanel.Height := Max(m_ScrollPanel.Height, a_Control.Top + a_Control.Height);
    a_Control.Parent := m_ScrollPanel;
  end;

  Invalidate;
end;

//==============================================================================
procedure TAcrylicScrollBox.Scroll(a_nDist : Integer);
begin
  if a_nDist > 0 then
    m_ScrollPanel.Top := Min(0, m_ScrollPanel.Top + a_nDist);

  if a_nDist < 0 then
    m_ScrollPanel.Top := Max(ClientHeight - m_ScrollPanel.Height, m_ScrollPanel.Top + a_nDist);

  Invalidate;
end;

//==============================================================================
procedure TAcrylicScrollBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  nNew : Integer;
  nMin : Integer;
begin
  if m_msMouseState = msClicked then
  begin
    nMin := ClientHeight - m_ScrollPanel.Height;
    nNew := Trunc((m_ScrollPanel.Height/ClientHeight) * (Y - m_nLastY));

    m_ScrollPanel.Top := Min(0, Max(nMin, m_dLastTop - nNew));
  end
  else
  begin
    m_dLastTop   := m_ScrollPanel.Top;
    m_nLastY     := Y;
  end;

  Invalidate;
end;

//==============================================================================
procedure TAcrylicScrollBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msNone;
end;

//==============================================================================
procedure TAcrylicScrollBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msClicked;
end;

end.


