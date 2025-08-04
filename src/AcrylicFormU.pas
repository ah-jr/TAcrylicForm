unit AcrylicFormU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Imaging.PngImage,
  Vcl.Controls,
  AcrylicTypesU,
  AcrylicPanelU,
  AcrylicControlU;

type
  TAcrylicForm = class(TForm)
    pnlTitleBar      : TAcrylicPanel;
    pnlBackground    : TAcrylicPanel;
    pnlContent       : TAcrylicPanel;
    imgClose         : TImage;
    imgMaximize      : TImage;
    imgMinimize      : TImage;
    imgCloseHover    : TImage;
    imgMaximizeHover : TImage;
    imgMinimizeHover : TImage;

    procedure FormCreate           (Sender: TObject);
    procedure FormPaint            (Sender: TObject);
    procedure imgMaximizeMouseEnter(Sender: TObject);
    procedure imgMaximizeMouseLeave(Sender: TObject);
    procedure imgCloseMouseEnter   (Sender: TObject);
    procedure imgCloseMouseLeave   (Sender: TObject);
    procedure imgMinimizeMouseEnter(Sender: TObject);
    procedure imgMinimizeMouseLeave(Sender: TObject);
    procedure imgCloseClick        (Sender: TObject);
    procedure imgMaximizeClick     (Sender: TObject);
    procedure imgMinimizeClick     (Sender: TObject);

    procedure WMEraseBkgnd   (var Msg: TWmEraseBkgnd);    message WM_ERASEBKGND;
    procedure WMNCMoving     (var Msg: TWMMoving);        message WM_MOVING;
    procedure WMNCSize       (var Msg: TWMSize);          message WM_SIZE;
    procedure WMNCHitTest    (var Msg: TWMNCHitTest);     message WM_NCHITTEST;
    procedure WMNCMouseMove  (var Msg: TWMNCMouseMove);   message WM_NCMOUSEMOVE;
    procedure WMNCLMouseDown (var Msg: TWMNCMButtonDown); message WM_NCLBUTTONDOWN;
    procedure WMNCLMouseUp   (var Msg: TWMNCMButtonUp);   message WM_NCLBUTTONUP;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;

  private
    m_bInitialized           : Boolean;
    m_bResizable             : Boolean;
    m_bWithBorder            : Boolean;
    m_bMaximized             : Boolean;
    m_bDisableBlurWhenSizing : Boolean;

    m_clBlurColor   : TAlphaColor;
    m_clBorderColor : TAlphaColor;
    m_bWithBlur     : Boolean;

    m_nMinHeight    : Integer;
    m_nMinWidth     : Integer;

    m_ptMouseOffset : TPoint;
    m_recSize       : TRect;
    m_fsStyle       : TAcrylicFormStyle;
    m_htClickHit    : Longint;
    m_tmrMouseMove  : TTimer;

    procedure OnMoveOrResize;
    procedure UpdatePositions;

    procedure EnableBlur      (hwndHandle : HWND);
    procedure OnMouseMoveTimer(Sender     : TObject);
    procedure SetBlurColor    (a_clColor  : TAlphaColor);
    procedure SetBorderColor  (a_clColor  : TAlphaColor);
    procedure SetWithBorder   (a_bBorder  : Boolean);
    procedure ToggleBlur      (a_bBlur    : Boolean);

    function  GetWithBlur : Boolean;

  public
    constructor Create(a_cOwner : TComponent); override;
    destructor  Destroy; override;

    property Style : TAcrylicFormStyle read m_fsStyle       write m_fsStyle;

    property DisableBlurWhenSizing : Boolean     read m_bDisableBlurWhenSizing write m_bDisableBlurWhenSizing;
    property WithBlur              : Boolean     read GetWithBlur              write ToggleBlur;
    property WithBorder            : Boolean     read m_bWithBorder            write SetWithBorder;
    property BorderColor           : TAlphaColor read m_clBorderColor          write SetBorderColor;
    property BlurColor             : TAlphaColor read m_clBlurColor            write SetBlurColor;
    property Resizable             : Boolean     read m_bResizable             write m_bResizable;
    property MinWidth              : Integer     read m_nMinWidth              write m_nMinWidth;
    property MinHeight             : Integer     read m_nMinHeight             write m_nMinHeight;

  end;

  AccentPolicy = packed record
    AccentState   : Integer;
    AccentFlags   : Integer;
    GradientColor : Integer;
    AnimationId   : Integer;
  end;

  WindowCompositionAttributeData = packed record
    Attribute  : Cardinal;
    Data       : Pointer;
    SizeOfData : Integer;
  end;

var
  MainAcrylicForm: TAcrylicForm;

  SetWindowCompositionAttribute: function(hwnd: HWND; var Data: WindowCompositionAttributeData): Integer; stdcall;

const
  c_nTitleBarHeight    = 50;
  c_nTopIconWidth      = 46;
  c_nTopIconHeight     = 32;
  c_nBorderTriggerSize = 7;
  c_nPollingRateInHz   = 120;

procedure Register;

implementation

uses
  Vcl.Dialogs,
  AcrylicUtilsU;

{$R *.dfm}

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicForm]);
end;

//==============================================================================
procedure TAcrylicForm.OnMouseMoveTimer(Sender: TObject);
var
  ptMouse    : TPoint;
  nRight     : Integer;
  nBottom    : Integer;
  recBounds  : TRect;
  recOld     : TRect;
begin
  if not(GetKeyState(VK_LBUTTON) and $8000 <> 0) then
  begin
    m_htClickHit := HTNOWHERE;
    m_tmrMouseMove.Enabled := False;
  end
  else
  begin
    GetCursorPos(ptMouse);
    nRight  := Width + Left;
    nBottom := Height + Top;

    recOld.Left   := Left;
    recOld.Top    := Top;
    recOld.Width  := Width;
    recOld.Height := Height;

    case m_htClickHit of
      HTCAPTION:
        begin
          recBounds.Left   := ptMouse.X - m_ptMouseOffset.X;
          recBounds.Top    := ptMouse.Y - m_ptMouseOffset.Y;
          recBounds.Width  := Width;
          recBounds.Height := Height;
        end;

      HTTOPLEFT:
        begin
          recBounds.Left   := ptMouse.X;
          recBounds.Top    := ptMouse.Y;
          recBounds.Width  := nRight  - ptMouse.X;
          recBounds.Height := nBottom - ptMouse.Y;
        end;

      HTTOP:
        begin
          recBounds.Left   := Left;
          recBounds.Top    := ptMouse.Y;
          recBounds.Width  := Width;
          recBounds.Height := nBottom - ptMouse.Y;
        end;

      HTTOPRIGHT:
        begin
          recBounds.Left   := Left;
          recBounds.Top    := ptMouse.Y;
          recBounds.Width  := ptMouse.X - Left;
          recBounds.Height := nBottom - ptMouse.Y;
        end;

      HTRIGHT:
        begin
          recBounds.Left   := Left;
          recBounds.Top    := Top;
          recBounds.Width  := ptMouse.X - Left;
          recBounds.Height := Height;
        end;

      HTBOTTOMRIGHT:
        begin
          recBounds.Left   := Left;
          recBounds.Top    := Top;
          recBounds.Width  := ptMouse.X - Left;
          recBounds.Height := ptMouse.Y - Top;
        end;

      HTBOTTOM:
        begin
          recBounds.Left   := Left;
          recBounds.Top    := Top;
          recBounds.Width  := Width;
          recBounds.Height := ptMouse.Y - Top;
        end;

      HTBOTTOMLEFT:
        begin
          recBounds.Left   := ptMouse.X;
          recBounds.Top    := Top;
          recBounds.Width  := nRight - ptMouse.X;
          recBounds.Height := ptMouse.Y - Top;
        end;

      HTLEFT:
        begin
          recBounds.Left   := ptMouse.X;
          recBounds.Top    := Top;
          recBounds.Width  := nRight - ptMouse.X;
          recBounds.Height := Height;
        end;
    end;

    if (recBounds.Width < m_nMinWidth) then
    begin
      if recBounds.Left <> recOld.Left then
        recBounds.Left := recOld.Right - m_nMinWidth;

      recBounds.Width := m_nMinWidth;
    end;

    if (recBounds.Height < m_nMinHeight) then
    begin
      if recBounds.Top <> recOld.Top then
        recBounds.Top := recOld.Bottom - m_nMinHeight;

      recBounds.Height := m_nMinHeight;
    end;

    SetBounds(recBounds.Left, recBounds.Top, recBounds.Width, recBounds.Height);
  end;
end;

//==============================================================================
procedure TAcrylicForm.SetWithBorder(a_bBorder : Boolean);
begin
  m_bWithBorder := a_bBorder;
  pnlBackground.WithBorder := m_bWithBorder;
end;

//==============================================================================
procedure TAcrylicForm.SetBlurColor(a_clColor : TAlphaColor);
begin
  m_clBlurColor := a_clColor;
  EnableBlur(Handle);
  Invalidate;

  RefreshAcrylicControls(Self);
end;

//==============================================================================
procedure TAcrylicForm.SetBorderColor(a_clColor : TAlphaColor);
begin
  m_clBorderColor := a_clColor;
  pnlBackground.BorderColor := m_clBorderColor;
end;

//==============================================================================
procedure TAcrylicForm.ToggleBlur(a_bBlur : Boolean);
begin
  m_bWithBlur := a_bBlur and SupportBlur;

  EnableBlur(Handle);
  Invalidate;

  RefreshAcrylicControls(Self);
end;

//==============================================================================
function TAcrylicForm.GetWithBlur : Boolean;
begin
  Result := m_bWithBlur;
end;

//==============================================================================
procedure TAcrylicForm.OnMoveOrResize;
begin
  UpdatePositions;
end;

//==============================================================================
constructor TAcrylicForm.Create(a_cOwner : TComponent);
begin
  m_bInitialized           := False;
  m_bWithBlur              := SupportBlur;
  m_bDisableBlurWhenSizing := False;

  m_tmrMouseMove          := TTimer.Create(self);
  m_tmrMouseMove.Interval := 1000 div c_nPollingRateInHz;
  m_tmrMouseMove.OnTimer  := OnMouseMoveTimer;
  m_tmrMouseMove.Enabled  := False;

  m_clBlurColor   := c_clBlurColor;
  m_clBorderColor := c_clFormBorder;

  m_bResizable    := True;
  m_bWithBorder   := True;
  m_bMaximized    := False;

  m_recSize       := TRect.Create(Left,Top,Width,Height);
  m_fsStyle       := [fsClose, fsMinimize, fsMaximize];

  m_nMinHeight    := 400;
  m_nMinWidth     := 400;

  inherited;

  pnlBackground.Align       := alNone;
  pnlBackground.WithBorder  := m_bWithBorder;
  pnlBackground.BorderColor := m_clBorderColor;
end;

//==============================================================================
destructor TAcrylicForm.Destroy;
begin
  m_tmrMouseMove.Enabled := False;
  m_tmrMouseMove.Free;

  inherited;
end;

//==============================================================================
procedure TAcrylicForm.FormCreate(Sender: TObject);
begin
  BorderStyle := bsNone;
  BorderIcons := [biSystemMenu, biMinimize];
  EnableBlur(Handle);

  pnlContent.Align := alNone;
  pnlTitleBar.Align := alNone;

  if WithBlur then
  begin
    GlassFrame.Enabled      := True;
    GlassFrame.SheetOfGlass := True;

    GlassFrame.Left   := -1;
    GlassFrame.Right  := -1;
    GlassFrame.Top    := -1;
    GlassFrame.Bottom := -1;
  end;

  imgClose.Visible    := fsClose    in m_fsStyle;
  imgMaximize.Visible := fsMaximize in m_fsStyle;
  imgMinimize.Visible := fsMinimize in m_fsStyle;

  m_bInitialized := True;

  UpdatePositions;
end;

//==============================================================================
procedure TAcrylicForm.FormPaint(Sender: TObject);
begin
  // Do nothing
end;

//==============================================================================
procedure TAcrylicForm.UpdatePositions;
var
  nIconCount : Integer;
begin
  pnlBackground.Left    := 0;
  pnlBackground.Top     := 0;
  pnlBackground.Width   := ClientWidth;
  pnlBackground.Height  := ClientHeight;

  pnlTitleBar.Left   := 1;
  pnlTitleBar.Top    := 1;
  pnlTitleBar.Width  := pnlBackground.Width - 2;
  pnlTitleBar.Height := c_nTitleBarHeight;

  pnlContent.Left    := c_nBorderTriggerSize;
  pnlContent.Top     := pnlTitleBar.Height;
  pnlContent.Width   := pnlBackground.Width  - 2 * c_nBorderTriggerSize;
  pnlContent.Height  := pnlBackground.Height - pnlTitleBar.Height - c_nBorderTriggerSize;

  nIconCount := 1;

  imgClose.Width       := c_nTopIconWidth;
  imgClose.Height      := c_nTopIconHeight;
  imgClose.Left        := Width - nIconCount * c_nTopIconWidth - 1;
  imgClose.Top         := 1;
  imgCloseHover.Width  := imgClose.Width;
  imgCloseHover.Height := imgClose.Height;
  imgCloseHover.Left   := imgClose.Left;
  imgCloseHover.Top    := imgClose.Top;

  if fsClose in m_fsStyle then
    Inc(nIconCount);

  imgMaximize.Width       := imgClose.Width;
  imgMaximize.Height      := imgClose.Height;
  imgMaximize.Left        := Width - nIconCount * c_nTopIconWidth;
  imgMaximize.Top         := imgClose.Top;
  imgMaximizeHover.Width  := imgMaximize.Width;
  imgMaximizeHover.Height := imgMaximize.Height;
  imgMaximizeHover.Left   := imgMaximize.Left;
  imgMaximizeHover.Top    := imgMaximize.Top;

  if fsMaximize in m_fsStyle then
    Inc(nIconCount);

  imgMinimize.Width       := imgClose.Width;
  imgMinimize.Height      := imgClose.Height;
  imgMinimize.Left        := Width - nIconCount * c_nTopIconWidth;
  imgMinimize.Top         := imgClose.Top;
  imgMinimizeHover.Width  := imgMinimize.Width;
  imgMinimizeHover.Height := imgMinimize.Height;
  imgMinimizeHover.Left   := imgMinimize.Left;
  imgMinimizeHover.Top    := imgMinimize.Top;
end;

//==============================================================================
procedure TAcrylicForm.EnableBlur(hwndHandle: HWND);
const
  WCA_ACCENT_POLICY                 = 19;
  ACCENT_ENABLE_GRADIENT            = 1;
  ACCENT_ENABLE_TRANSPARENTGRADIENT = 2;
  ACCENT_ENABLE_BLURBEHIND          = 3;
  ACCENT_ENABLE_ACRYLICBLURBEHIND   = 4;
var
  DWM10      : THandle;
  Data       : WindowCompositionAttributeData;
  Accent     : AccentPolicy;
  nMode      : Integer;
begin
  if not WithBlur
    then nMode := ACCENT_ENABLE_GRADIENT
    else nMode := ACCENT_ENABLE_ACRYLICBLURBEHIND;

  DWM10 := LoadLibrary('user32.dll');

  try
    @SetWindowCompositionAttribute := GetProcAddress(DWM10, 'SetWindowCompositionAttribute');
    if @SetWindowCompositionAttribute <> nil then
    begin
      Accent.AccentState   := nMode;
      Accent.AccentFlags   := 2;
      Accent.GradientColor := ARGBtoABGR(m_clBlurColor);

      Data.Attribute  := WCA_ACCENT_POLICY;
      Data.SizeOfData := SizeOf(Accent);
      Data.Data       := @Accent;

      SetWindowCompositionAttribute(hwndHandle, Data);
    end
    else
    begin
      ShowMessage
        ('Not found Windows 10 SetWindowCompositionAttribute in user32.dll');
    end;
  finally
    FreeLibrary(DWM10);
    Repaint;
  end;
end;

//==============================================================================
//
//  Object Events
//
//==============================================================================
procedure TAcrylicForm.imgCloseClick(Sender: TObject);
begin
  Close;
end;

//==============================================================================
procedure TAcrylicForm.imgMaximizeClick(Sender: TObject);
begin
  m_bMaximized := not m_bMaximized;

  if m_bMaximized then
  begin
    m_recSize := TRect.Create(Left, Top, Left + Width, Top + Height);

    with Screen.WorkAreaRect do
      SetBounds(Left, Top, Right - Left, Bottom - Top);
  end
  else
  begin
    with m_recSize do
      SetBounds(Left, Top, Right - Left, Bottom - Top);
  end;
end;

//==============================================================================
procedure TAcrylicForm.imgMinimizeClick(Sender: TObject);
begin
  Application.Minimize;
end;

//==============================================================================
procedure TAcrylicForm.imgCloseMouseEnter(Sender: TObject);
begin
  imgClose.Visible      := False;
  imgCloseHover.Visible := True;
end;

//==============================================================================
procedure TAcrylicForm.imgCloseMouseLeave(Sender: TObject);
begin
  imgClose.Visible      := True;
  imgCloseHover.Visible := False;
end;

//==============================================================================
procedure TAcrylicForm.imgMaximizeMouseEnter(Sender: TObject);
begin
  imgMaximize.Visible      := False;
  imgMaximizeHover.Visible := True;
end;

//==============================================================================
procedure TAcrylicForm.imgMaximizeMouseLeave(Sender: TObject);
begin
  imgMaximize.Visible      := True;
  imgMaximizeHover.Visible := False;
end;

//==============================================================================
procedure TAcrylicForm.imgMinimizeMouseEnter(Sender: TObject);
begin
  imgMinimize.Visible      := False;
  imgMinimizeHover.Visible := True;
end;

//==============================================================================
procedure TAcrylicForm.imgMinimizeMouseLeave(Sender: TObject);
begin
  imgMinimize.Visible      := True;
  imgMinimizeHover.Visible := False;
end;

//==============================================================================
//
//  System Messages
//
//==============================================================================
procedure TAcrylicForm.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
begin
  //
end;

//==============================================================================
procedure TAcrylicForm.WMNCMoving(var Msg: TWMMoving);
begin
  inherited;
end;

//==============================================================================
procedure TAcrylicForm.WMNCSize(var Msg: TWMSize);
begin
  inherited;
  OnMoveOrResize;
end;

//==============================================================================
procedure TAcrylicForm.WMNCMouseMove(var Msg: TWMNCMouseMove);
begin
  //
end;

//==============================================================================
procedure TAcrylicForm.WMNCLMouseDown(var Msg: TWMNCMButtonDown);
begin
  if m_bDisableBlurWhenSizing then
  begin
    WithBlur := False;
    Inherited;
    WithBlur := True;
  end
  else
  begin
    SetForegroundWindow(Handle);

    m_tmrMouseMove.Enabled := True;
    m_htClickHit           := Msg.HitTest;
    m_ptMouseOffset        := ScreenToClient(Point(Msg.XCursor, Msg.YCursor));
  end;
end;

//==============================================================================
procedure TAcrylicForm.WMNCLMouseUp(var Msg: TWMNCMButtonUp);
begin
  m_htClickHit := HTNOWHERE;
end;

//==============================================================================
procedure TAcrylicForm.WMNCHitTest(var Msg: TWMNCHitTest);
const
  c_nSpan = 7;
var
  ScreenPt: TPoint;
  nBorder: Integer;

begin
  nBorder := BorderWidth + 2;
  ScreenPt := ScreenToClient(Point(Msg.Xpos, Msg.Ypos));
  inherited;

  Msg.Result := HTCLIENT;

  if (WindowState = wsNormal) then
  begin
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
        Msg.Result := HTBOTTOM
    end;

    if (ScreenPt.Y <= c_nTitleBarHeight) and (Msg.Result = HTCLIENT) then
      Msg.Result := HTCAPTION;
  end;
end;

//==============================================================================
procedure TAcrylicForm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
var
  MinMaxInfo : PMinMaxInfo;
begin
  inherited;
  MinMaxInfo := Msg.MinMaxInfo;

  MinMaxInfo^.ptMinTrackSize.X := m_nMinWidth;
  MinMaxInfo^.ptMinTrackSize.Y := m_nMinHeight;
end;

//==============================================================================
end.
