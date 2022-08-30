unit AcrylicFrameU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.UITypes,
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
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL,
  AcrylicGhostPanelU,
  AcrylicControlU,
  AcrylicLabelU;

type

  TAcrylicFrame = Class(TFrame)
    imgClose: TImage;
    pnlTitle: TAcrylicGhostPanel;
    lblTitle: TAcrylicLabel;
    pnlBack : TAcrylicGhostPanel;

    procedure imgCloseMouseEnter   (Sender: TObject);
    procedure imgCloseMouseLeave   (Sender: TObject);
    procedure imgCloseClick        (Sender: TObject);

  private
    m_Canvas        : TCanvas;
    m_bResizable    : Boolean;
    m_bWithBorder   : Boolean;
    m_bColored      : Boolean;
    m_bIntersecting : Boolean;
    m_clBackColor   : TColor;
    m_strTitle      : String;

    m_LastX         : Integer;
    m_LastY         : Integer;
    m_LastWidth     : Integer;
    m_LastHeight    : Integer;

    m_pngCloseN     : TPngImage;
    m_pngCloseH     : TPngImage;

    m_pnlBody       : TAcrylicGhostPanel;

    procedure WMNCSize           (var Msg: TWMSize);              message WM_SIZE;
    procedure WMEraseBkgnd       (var Msg: TWmEraseBkgnd);        message WM_ERASEBKGND;
    procedure WMNCHitTest        (var Msg: TWMNCHitTest);         message WM_NCHITTEST;
    procedure WMPaint            (var Msg: TWMPaint);             message WM_PAINT;
    procedure WMWINDOWPOSChanging(Var Msg: TWMWINDOWPOSChanging); message WM_WINDOWPOSChanging;

    procedure UpdatePositions;
    procedure SetTitle(a_strTitle : String);

  protected
    //

  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;

  published
    property Body : TAcrylicGhostPanel read m_pnlBody       write m_pnlBody;
    property Canvas      : TCanvas     read m_Canvas        write m_Canvas;
    property WithBorder  : Boolean     read m_bWithBorder   write m_bWithBorder;
    property Colored     : Boolean     read m_bColored      write m_bColored;
    property BackColor   : TColor      read m_clBackColor   write m_clBackColor;
    property Resisable   : Boolean     read m_bResizable    write m_bResizable;
    property Title       : String      read m_strTitle      write SetTitle;

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
  System.Types,
  AcrylicUtilsU,
  AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicFrame]);
end;

//==============================================================================
constructor TAcrylicFrame.Create(AOwner : TComponent);
begin
  Inherited;
  m_Canvas     := TCanvas.Create;
  m_bResizable := True;

  m_bWithBorder := True;
  m_bColored    := True;
  m_clBackColor := c_clFormBack;

  m_pnlBody         := TAcrylicghostPanel.Create(pnlBack);
  m_pnlBody.Parent  := pnlBack;
  m_pnlBody.Ghost   := True;
  m_pnlBody.Colored := True;
  m_pnlBody.Color   := c_clFormColor;

  pnlBack.Colored     := False;
  pnlBack.WithBorder  := True;
  pnlBack.Bordercolor := c_clFormBorder;

  m_LastX         := 0;
  m_LastY         := 0;
  m_LastWidth     := 1;
  m_LastHeight    := 1;
  m_strTitle      := '';

  m_bIntersecting := True;

  m_pngCloseN     := TPngImage.Create;
  m_pngCloseH     := TPngImage.Create;

  try
    m_pngCloseN.LoadFromResourceName(HInstance, 'close_normal_mini');
    m_pngCloseH.LoadFromResourceName(HInstance, 'close_hover_mini');

    imgClose.Picture.Graphic := m_pngCloseN;
  except

  end;
end;

//==============================================================================
destructor TAcrylicFrame.Destroy;
begin
  m_pngCloseN.Free;
  m_pngCloseH.Free;

  m_Canvas.Free;
  Inherited;
end;

//==============================================================================
procedure TAcrylicFrame.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
begin
  //
end;

//==============================================================================
procedure TAcrylicFrame.WMPaint(var Msg: TWMPaint);
begin
  PaintHandler(Msg);
end;

//==============================================================================
procedure TAcrylicFrame.WMNCSize(var Msg: TWMSize);
begin
  BringToFront;
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
  pnlParent   : TAcrylicGhostPanel;
  nIndex      : Integer;
  ctrlControl : TAcrylicFrame;
const
  c_nDistThreshold = 40;
begin
  if Parent is TAcrylicGhostPanel then
  begin
    pnlParent := Parent as TAcrylicGhostPanel;

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
        for nIndex := 0 to pnlParent.ComponentCount - 1 do
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
                  x  := m_LastX;
                  y  := m_LastY;
                  cx := m_LastWidth;
                  cy := m_LastHeight;
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

  imgClose.Width    := c_nTopIconWidth;
  imgClose.Height   := c_nTopIconHeight;
  imgClose.Left     := pnlTitle.Width - c_nTopIconWidth;
  imgClose.Top      := 0;

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
  imgClose.Picture.Graphic := m_pngCloseH;
end;

//==============================================================================
procedure TAcrylicFrame.imgCloseMouseLeave(Sender: TObject);
begin
  imgClose.Picture.Graphic := m_pngCloseN;
end;

end.


