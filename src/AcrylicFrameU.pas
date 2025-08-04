unit AcrylicFrameU;

interface

uses
  Winapi.Messages,
  System.Classes,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Imaging.PngImage,
  Vcl.Controls,
  AcrylicPanelU,
  AcrylicLabelU,
  AcrylicControlU;

type

  TAcrylicFrame = Class(TFrame)
    imgClose      : TImage;
    pnlTitle      : TAcrylicPanel;
    lblTitle      : TAcrylicLabel;
    pnlBack       : TAcrylicPanel;
    imgCloseHover : TImage;

    procedure imgCloseMouseEnter (Sender: TObject);
    procedure imgCloseMouseLeave (Sender: TObject);
    procedure imgCloseClick      (Sender: TObject);

  private
    m_bResizable    : Boolean;
    m_bIntersecting : Boolean;
    m_strTitle      : String;

    m_LastX         : Integer;
    m_LastY         : Integer;
    m_LastWidth     : Integer;
    m_LastHeight    : Integer;

    m_nMinHeight    : Integer;
    m_nMinWidth     : Integer;
    m_nMaxHeight    : Integer;
    m_nMaxWidth     : Integer;

    m_pnlBody       : TAcrylicPanel;

    procedure WMNCSize           (var Msg: TWMSize);              message WM_SIZE;
    procedure WMEraseBkgnd       (var Msg: TWmEraseBkgnd);        message WM_ERASEBKGND;
    procedure WMNCHitTest        (var Msg: TWMNCHitTest);         message WM_NCHITTEST;
    procedure WMPaint            (var Msg: TWMPaint);             message WM_PAINT;
    procedure WMWINDOWPOSChanging(Var Msg: TWMWINDOWPOSChanging); message WM_WINDOWPOSChanging;
    procedure WMGetMinMaxInfo    (var Msg: TWMGetMinMaxInfo);     message WM_GETMINMAXINFO;

    procedure UpdatePositions;
    procedure SetTitle(a_strTitle : String);

  public
    constructor Create(a_cOwner : TComponent); override;
    destructor  Destroy; override;

  published
    property Body        : TAcrylicPanel read m_pnlBody       write m_pnlBody;
    property Resizable   : Boolean       read m_bResizable    write m_bResizable;
    property Title       : String        read m_strTitle      write SetTitle;

    property MinWidth    : Integer       read m_nMinWidth     write m_nMinWidth;
    property MinHeight   : Integer       read m_nMinHeight    write m_nMinHeight;
    property MaxWidth    : Integer       read m_nMaxWidth     write m_nMaxWidth;
    property MaxHeight   : Integer       read m_nMaxHeight    write m_nMaxHeight;

    property Visible;
  end;

const
  c_nTitleBarHeight    = 25;
  c_nBorderTriggerSize = 7;
  c_nTopIconWidth      = 24;
  c_nTopIconHeight     = 24;

procedure Register;

implementation

{$R *.dfm}

uses
  Winapi.Windows,
  AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicFrame]);
end;

//==============================================================================
constructor TAcrylicFrame.Create(a_cOwner : TComponent);
begin
  Inherited;

  m_bResizable := True;

  m_pnlBody         := TAcrylicPanel.Create(pnlBack);
  m_pnlBody.Parent  := pnlBack;
  m_pnlBody.Ghost   := True;
  m_pnlBody.Colored := False;

  pnlBack.Colored     := False;
  pnlBack.WithBorder  := True;
  pnlBack.Bordercolor := c_clFrameBorder;

  pnlTitle.Colored    := True;
  pnlTitle.Color      := c_clFrameTitle;

  lblTitle.Colored    := False;

  m_LastX         := 0;
  m_LastY         := 0;
  m_LastWidth     := 1;
  m_LastHeight    := 1;
  m_strTitle      := '';

  m_nMinHeight    := 100;
  m_nMinWidth     := 100;
  m_nMaxHeight    := -1;
  m_nMaxWidth     := -1;

  m_bIntersecting := True;
end;

//==============================================================================
destructor TAcrylicFrame.Destroy;
begin
  Inherited;
end;

//==============================================================================
procedure TAcrylicFrame.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
begin
  //
end;

//==============================================================================
procedure TAcrylicFrame.WMPaint(var Msg: TWMPaint);
var
  PS : TPaintStruct;
begin
  BeginPaint(Handle, PS);
  EndPaint(Handle, PS);
end;

//==============================================================================
procedure TAcrylicFrame.WMNCSize(var Msg: TWMSize);
begin
  UpdatePositions;
end;

//==============================================================================
procedure TAcrylicFrame.WMNCHitTest(var Msg: TWMNCHitTest);
const
  c_nSpan = 7;
var
  ScreenPt: TPoint;
  nBorder: Integer;
begin
  nBorder := BorderWidth + 2;
  ScreenPt := ScreenToClient(Point(Msg.Xpos, Msg.Ypos));
  Inherited;

  Msg.Result := HTCLIENT;

  if m_bResizable then
  begin
    if (ScreenPt.X < c_nSpan) and (ScreenPt.Y < c_nSpan) then
      Msg.Result := HTTOPLEFT
    else if (ScreenPt.X < c_nSpan) and (ScreenPt.Y >= Height - c_nSpan - nBorder)
    then
      Msg.Result := HTBOTTOMLEFT
    else if (ScreenPt.X >= Width - c_nSpan - nBorder) and (ScreenPt.Y < c_nSpan)
    then
      Msg.Result := HTTOPRIGHT
    else if (ScreenPt.X >= Width - c_nSpan - nBorder) and
      (ScreenPt.Y >= Height - c_nSpan - nBorder) then
      Msg.Result := HTBOTTOMRIGHT
    else if (ScreenPt.X < c_nSpan) then
      Msg.Result := HTLEFT
    else if (ScreenPt.Y < c_nSpan) then
      Msg.Result := HTTOP
    else if (ScreenPt.X >= Width - c_nSpan - nBorder) then
      Msg.Result := HTRIGHT
    else if (ScreenPt.Y >= Height - c_nSpan - nBorder) then
      Msg.Result := HTBOTTOM;
  end;

  if (ScreenPt.Y <= c_nTitleBarHeight) and (Msg.Result = HTCLIENT) then
    Msg.Result := HTCAPTION;

  if (GetAsyncKeyState(VK_LBUTTON) and $8000) <> 0 then
    BringToFront;
end;

procedure TAcrylicFrame.WMWINDOWPOSChanging(Var Msg: TWMWINDOWPOSChanging);
var
  recParent   : TRect;
  recFrame    : TRect;
  recInter    : TRect;
  pnlParent   : TAcrylicPanel;
  nIndex      : Integer;
  ctrlControl : TAcrylicFrame;
const
  c_nDistThreshold = 40;
begin
  if Parent is TAcrylicPanel then
  begin
    pnlParent := Parent as TAcrylicPanel;

    with Msg.Windowpos^ do
    Begin
      if (Flags and SWP_NOMOVE) = 0 Then
      begin
        ////////////////////////////////////////////////////////////////////////
        ///  Check if intersects desktop borders
        Winapi.Windows.GetClientrect(pnlParent.Handle, recParent);

        if x < 0 then
          x := 0;

        if y < 0 then
          y := 0;

        if (x + cx) > recParent.Right then
          x := recParent.Right - cx;

        if (y + cy) > recParent.Bottom then
          y := recParent.Bottom - cy;

        ////////////////////////////////////////////////////////////////////////
        ///  Check if intersects other frames
        for nIndex := 0 to pnlParent.ControlCount - 1 do
        begin
          if pnlParent.Controls[nIndex] is TAcrylicFrame then
          begin
            ctrlControl := (pnlParent.Controls[nIndex] as TAcrylicFrame);

            if not (ctrlControl = Self) then
            begin
              Winapi.Windows.GetWindowrect(ctrlControl.Handle, recFrame);
              MapWindowPoints(HWND_DESKTOP, pnlParent.Handle, recFrame, 2);

              if IntersectRect(recInter, TRect.Create(x, y, x + cx, y + cy), recFrame) then
              begin
                if not m_bIntersecting and not
                   ((recInter.Height > c_nDistThreshold) and
                    (recInter.Width  > c_nDistThreshold)) then
                begin
                  if (m_LastWidth + m_LastX = recFrame.Left) or (m_LastX = recFrame.Right) then
                  begin
                    x  := m_LastX;
                    cx := m_LastWidth;
                  end
                  else if (m_LastHeight + m_LastY = recFrame.Top) or (m_LastY = recFrame.Bottom) then
                  begin
                    y  := m_LastY;
                    cy := m_LastHeight;
                  end
                  else
                  begin
                    x  := m_LastX;
                    y  := m_LastY;
                    cx := m_LastWidth;
                    cy := m_LastHeight;
                  end;
                end
                else
                  m_bIntersecting := True;
              end
              else
                m_bIntersecting := False;
            end;
          end;
        end;
        m_LastWidth  := cx;
        m_LastHeight := cy;
        m_LastX      := x;
        m_LastY      := y;
      end;
    end;
  end;

  Inherited;
end;

//==============================================================================
procedure TAcrylicFrame.UpdatePositions;
begin
  pnlBack.Left      := 0;
  pnlBack.Top       := 0;
  pnlBack.Width     := ClientWidth;
  pnlBack.Height    := ClientHeight;

  m_pnlBody.Left    := c_nBorderTriggerSize;
  m_pnlBody.Top     := c_nTitleBarHeight;
  m_pnlBody.Width   := ClientWidth  - 2 * c_nBorderTriggerSize;
  m_pnlBody.Height  := ClientHeight - c_nTitleBarHeight - c_nBorderTriggerSize;

  pnlTitle.Left     := 1;
  pnlTitle.Top      := 1;
  pnlTitle.Width    := Width - 2;

  imgClose.Width       := c_nTopIconWidth;
  imgClose.Height      := c_nTopIconHeight;
  imgClose.Left        := pnlTitle.Width - c_nTopIconWidth;
  imgClose.Top         := 0;

  imgCloseHover.Width  := c_nTopIconWidth;
  imgCloseHover.Height := c_nTopIconHeight;
  imgCloseHover.Left   := pnlTitle.Width - c_nTopIconWidth;
  imgCloseHover.Top    := 0;

  lblTitle.Width    := imgClose.Left - 5;
end;

//==============================================================================
procedure TAcrylicFrame.SetTitle(a_strTitle : String);
begin
  m_strTitle := a_strTitle;
  lblTitle.Text := m_strTitle;
end;

//==============================================================================
procedure TAcrylicFrame.imgCloseClick(Sender: TObject);
begin
  Visible := False;
end;

//==============================================================================
procedure TAcrylicFrame.imgCloseMouseEnter(Sender: TObject);
begin
  imgClose.Visible      := False;
  imgCloseHover.Visible := True;
end;

//==============================================================================
procedure TAcrylicFrame.imgCloseMouseLeave(Sender: TObject);
begin
  imgClose.Visible      := True;
  imgCloseHover.Visible := False;
end;

//==============================================================================
procedure TAcrylicFrame.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
var
  MinMaxInfo : PMinMaxInfo;
begin
  inherited;
  MinMaxInfo := Msg.MinMaxInfo;

  if m_nMaxWidth > 0 then
    MinMaxInfo^.ptMaxTrackSize.X := m_nMaxWidth;

  if m_nMaxHeight > 0 then
    MinMaxInfo^.ptMaxTrackSize.Y := m_nMaxHeight;

  if m_nMinWidth > 0 then
    MinMaxInfo^.ptMinTrackSize.X := m_nMinWidth;

  if m_nMinHeight > 0 then
    MinMaxInfo^.ptMinTrackSize.Y := m_nMinHeight;
end;

end.


