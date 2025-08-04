unit AcrylicScrollBoxU;

interface

uses
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  AcrylicPanelU;

type

  TAcrylicScrollBox = Class(TAcrylicPanel)
  private
    m_ScrollPanel   : TAcrylicPanel;
    m_clScrollColor : TAlphaColor;
    m_dLastTop      : Integer;
    m_nLastY        : Integer;

    procedure WMNCSize(var Message: TWMSize); message WM_SIZE;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;

  protected
    procedure PaintComponent; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create     (a_cOwner   : TComponent); override;
    procedure   AddControl (a_cControl : TControl);
    procedure   Scroll     (a_nDist    : Integer);

  published
    property ScrollPanel : TAcrylicPanel read m_ScrollPanel   write m_ScrollPanel;
    property ScrollColor : TAlphaColor   read m_clScrollColor write m_clScrollColor;

    property Color;
    property Canvas;
    property Colored;

  end;

const
  c_nScrollBarWidth = 10;

procedure Register;

implementation

uses
  Winapi.Windows,
  Math,
  AcrylicUtilsU,
  AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicScrollBox]);
end;

//==============================================================================
constructor TAcrylicScrollBox.Create(a_cOwner : TComponent);
begin
  Inherited;

  m_bGhost        := False;
  m_dLastTop      := 0;
  m_nLastY        := 0;
  m_bWithBorder   := False;
  m_clScrollColor := ToAlphaColor(clWhite);
  m_bClickable    := True;

  Self.Ghost := False;

  m_ScrollPanel           := TAcrylicPanel.Create(Self);
  m_ScrollPanel.Parent    := Self;
  m_ScrollPanel.Align     := alNone;
  m_ScrollPanel.Left      := 0;
  m_ScrollPanel.Top       := 0;
  m_ScrollPanel.Width     := Width - c_nScrollBarWidth;
  m_ScrollPanel.Height    := Height;
  m_ScrollPanel.Ghost     := False;
  m_ScrollPanel.Colored   := Colored;
  m_ScrollPanel.Color     := Color;
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

  if m_ScrollPanel <> nil then
  begin
    m_ScrollPanel.Left   := 0;
    m_ScrollPanel.Top    := 0;
    m_ScrollPanel.Width  := ClientWidth - c_nScrollBarWidth;
  end;
end;

//==============================================================================
procedure TAcrylicScrollBox.PaintComponent;
var
  nHeight     : Integer;
  nStart      : Integer;
begin
  //////////////////////////////////////////////////////////////////////////////
  ///  Paint ScrollBar
  if m_ScrollPanel <> nil then
  begin
    nHeight := Trunc(ClientHeight * (ClientHeight / m_ScrollPanel.Height));

    if m_ScrollPanel.Height > ClientHeight then
    begin
      nStart := Trunc((ClientHeight - nHeight) * (m_ScrollPanel.Top / (ClientHeight - m_ScrollPanel.Height)));
      m_bmpBuffer.FillRectT(m_ScrollPanel.Width,
                           nStart,
                           m_ScrollPanel.Width + c_nScrollBarWidth,
                           nStart + nHeight,
                           m_clScrollColor);
    end;
  end;
end;

//==============================================================================
procedure TAcrylicScrollBox.AddControl(a_cControl : TControl);
begin
  if a_cControl <> nil then
  begin
    m_ScrollPanel.Height := Max(m_ScrollPanel.Height, a_cControl.Top + a_cControl.Height);
    a_cControl.Parent := m_ScrollPanel;
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

end.


