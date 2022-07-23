unit AcrylicScrollBoxU;

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
  DWMApi,
  AcrylicGhostPanelU,
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL;

type

  TAcrylicScrollBox = Class(TAcrylicGhostPanel)
  private
    m_ScrollPanel : TAcrylicGhostPanel;

    procedure WMNCSize(var Message: TWMSize); message WM_SIZE;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;

  protected
    procedure Paint; override;
    procedure Loaded; override;

  public
    constructor Create(AOwner : TComponent); override;
    procedure AddControl(a_Control : TControl);
    procedure Scroll(a_nDist : Integer);

  published
    property ScrollPanel : TAcrylicGhostPanel read m_ScrollPanel write m_ScrollPanel;
    property Color;
    property Canvas;

  end;

const
  c_nScrollBarWidth = 10;

procedure Register;

implementation

uses
  System.UITypes,
  Math,
  AcrylicUtilsU,
  AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicScrollBox]);
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
constructor TAcrylicScrollBox.Create(AOwner : TComponent);
begin
  Inherited;
end;

//==============================================================================
procedure TAcrylicScrollBox.Loaded;
var
  nCtrlIdx : Integer;
begin
  Inherited;

  Self.Ghost := False;

  m_ScrollPanel        := TAcrylicGhostPanel.Create(Self);
  m_ScrollPanel.Parent := Self;
  m_ScrollPanel.Align  := alNone;
  m_ScrollPanel.Left   := 0;
  m_ScrollPanel.Top    := 0;
  m_ScrollPanel.Width  := ClientWidth - c_nScrollBarWidth;
  m_ScrollPanel.Height := ClientHeight;
  m_ScrollPanel.Ghost  := False;

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
  gdiSolidPen : TGPPen;
  gdiBrush    : TGPSolidBrush;
  nHeight     : Integer;
  nStart      : Integer;
begin
  Inherited;

  gdiGraphics := TGPGraphics.Create(Canvas.Handle);
  gdiSolidPen := TGPPen.Create(GdiColor(clWhite), 1);
  gdiBrush    := TGPSolidBrush.Create(GdiColor(clWhite));

  if m_ScrollPanel <> nil then
  begin
    nHeight := Trunc(ClientHeight * (ClientHeight / m_ScrollPanel.Height));

    if m_ScrollPanel.Height > ClientHeight then
    begin
      nStart := Trunc((ClientHeight - nHeight) * (m_ScrollPanel.Top / (ClientHeight - m_ScrollPanel.Height)));
      gdiGraphics.FillRectangle(gdiBrush, m_ScrollPanel.Width, nStart, m_ScrollPanel.Width, nHeight);
    end;
  end;

  gdiGraphics.Free;
  gdiSolidPen.Free;
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

end.


