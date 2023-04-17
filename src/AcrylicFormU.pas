unit AcrylicFormU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Imaging.pngimage,
  AcrylicTypesU,
  AcrylicGhostPanelU;

{$R ..\res\icons.res}

type
  TAcrylicForm = class(TForm)
    pnlTitleBar   : TAcrylicGhostPanel;
    pnlBackground : TAcrylicGhostPanel;
    pnlContent    : TPanel;
    imgClose      : TImage;
    imgMaximize   : TImage;
    imgMinimize   : TImage;
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

    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;


  private
    m_bInitialized  : Boolean;
    m_clBlurColor   : TColor;
    m_clBackColor   : TColor;
    m_clBorderColor : TAlphaColor;
    m_btBlurAmount  : Byte;
    m_bResizable    : Boolean;
    m_bWithBorder   : Boolean;
    m_bMaximized    : Boolean;

    m_nMinHeight    : Integer;
    m_nMinWidth     : Integer;
    m_nMaxHeight    : Integer;
    m_nMaxWidth     : Integer;

    m_recSize       : TRect;
    m_fsStyle       : TAcrylicFormStyle;

    m_pngCloseN     : TPngImage;
    m_pngCloseH     : TPngImage;
    m_pngMaximizeN  : TPngImage;
    m_pngMaximizeH  : TPngImage;
    m_pngMinimizeN  : TPngImage;
    m_pngMinimizeH  : TPngImage;

    m_tmrAcrylicChange: TTimer;

    procedure OnMoveOrResize;
    procedure UpdatePositions;

    procedure EnableBlur    (hwndHandle : HWND; nMode: Integer);
    procedure OnAcrylicTimer(Sender     : TObject);
    procedure SetColor      (a_clColor  : TColor);
    procedure SetBlurAmount (a_btAmount : Byte);
    procedure ToggleBlur    (a_bBlur    : Boolean);

    function  GetWithBlur : Boolean;

    procedure PaintBackground;
    procedure PaintBorder;

    procedure WMNCMoving     (var Msg: TWMMoving);        message WM_MOVING;
    procedure WMNCSize       (var Msg: TWMSize);          message WM_SIZE;
    procedure WMNCHitTest    (var Msg: TWMNCHitTest);     message WM_NCHITTEST;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;

  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;

    property Style : TAcrylicFormStyle read m_fsStyle       write m_fsStyle;

    property WithBlur    : Boolean     read GetWithBlur     write ToggleBlur;
    property WithBorder  : Boolean     read m_bWithBorder   write m_bWithBorder;
    property BorderColor : TAlphaColor read m_clBorderColor write m_clBorderColor;
    property BackColor   : TColor      read m_clBackColor   write m_clBackColor;
    property BlurColor   : TColor      read m_clBlurColor   write SetColor;
    property BlurAmount  : Byte        read m_btBlurAmount  write SetBlurAmount;
    property Resizable   : Boolean     read m_bResizable    write m_bResizable;
    property MinWidth    : Integer     read m_nMinWidth     write m_nMinWidth;
    property MinHeight   : Integer     read m_nMinHeight    write m_nMinHeight;
    property MaxWidth    : Integer     read m_nMaxWidth     write m_nMaxWidth;
    property MaxHeight   : Integer     read m_nMaxHeight    write m_nMaxHeight;

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

procedure Register;

implementation

uses
  GDIPAPI,
  GDIPUTIL,
  GDIPOBJ,
  AcrylicUtilsU;

{$R *.dfm}

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicForm]);
end;

//==============================================================================
procedure TAcrylicForm.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  //
end;

//==============================================================================
procedure TAcrylicForm.OnAcrylicTimer(Sender: TObject);
begin
  if not(GetKeyState(VK_LBUTTON) and $8000 <> 0) then
  begin
    EnableBlur(Handle, 4);
    UpdatePositions;

    m_tmrAcrylicChange.Enabled  := False;
  end;
end;

//==============================================================================
procedure TAcrylicForm.SetColor(a_clColor : TColor);
begin
  m_clBlurColor := a_clColor;
  EnableBlur(Handle, 4);
end;

//==============================================================================
procedure TAcrylicForm.SetBlurAmount(a_btAmount : Byte);
begin
  m_btBlurAmount := a_btAmount;
  EnableBlur(Handle, 4);
end;

//==============================================================================
procedure TAcrylicForm.ToggleBlur(a_bBlur : Boolean);
begin
  g_bWithBlur := a_bBlur and SupportBlur;

  EnableBlur(Handle, 4);
  Invalidate;

  RefreshAcrylicControls(Self);
end;

//==============================================================================
function TAcrylicForm.GetWithBlur : Boolean;
begin
  Result := g_bWithBlur;
end;

//==============================================================================
procedure TAcrylicForm.OnMoveOrResize;
begin
  if m_bInitialized then
  begin
    EnableBlur(Handle, 3);

    m_tmrAcrylicChange.Enabled := False;
    m_tmrAcrylicChange.Enabled := True;

    UpdatePositions;
  end;
end;

//==============================================================================
constructor TAcrylicForm.Create(AOwner : TComponent);
begin
  m_bInitialized := False;
  g_bWithBlur    := SupportBlur;

  m_tmrAcrylicChange          := TTimer.Create(self);
  m_tmrAcrylicChange.Interval := 10;
  m_tmrAcrylicChange.OnTimer  := OnAcrylicTimer;
  m_tmrAcrylicChange.Enabled  := True;

  m_pngCloseN     := TPngImage.Create;
  m_pngCloseH     := TPngImage.Create;
  m_pngMaximizeN  := TPngImage.Create;
  m_pngMaximizeH  := TPngImage.Create;
  m_pngMinimizeN  := TPngImage.Create;
  m_pngMinimizeH  := TPngImage.Create;

  m_clBlurColor   := c_clFormBlur;
  m_clBorderColor := c_clFormBorder;
  m_clBackColor   := c_clFormBack;
  m_btBlurAmount  := c_nDefaultBlur;

  m_bResizable    := True;
  m_bWithBorder   := True;
  m_bMaximized    := False;

  m_recSize       := TRect.Create(Left,Top,Width,Height);
  m_fsStyle       := [fsClose, fsMinimize, fsMaximize];

  m_nMinHeight    := 100;
  m_nMinWidth     := 100;

  m_nMaxHeight    := -1;
  m_nMaxWidth     := -1;

  try
    m_pngCloseN.LoadFromResourceName   (HInstance, 'close_normal');
    m_pngCloseH.LoadFromResourceName   (HInstance, 'close_hover');
    m_pngMaximizeN.LoadFromResourceName(HInstance, 'maximize_normal');
    m_pngMaximizeH.LoadFromResourceName(HInstance, 'maximize_hover');
    m_pngMinimizeN.LoadFromResourceName(HInstance, 'minimize_normal');
    m_pngMinimizeH.LoadFromResourceName(HInstance, 'minimize_hover');
  except

  end;

  inherited;
end;

//==============================================================================
destructor TAcrylicForm.Destroy;
begin
  m_pngCloseN.Free;
  m_pngCloseH.Free;
  m_pngMaximizeN.Free;
  m_pngMaximizeH.Free;
  m_pngMinimizeN.Free;
  m_pngMinimizeH.Free;

  m_tmrAcrylicChange.Enabled := False;
  m_tmrAcrylicChange.Free;

  inherited;
end;

//==============================================================================
procedure TAcrylicForm.FormCreate(Sender: TObject);
begin
  BorderStyle := bsNone;
  BorderIcons := [biSystemMenu, biMinimize];
  EnableBlur(Handle, 4);

  pnlContent.Align := alNone;

  // Load Icons:
  try
    imgClose.Picture.Graphic    := m_pngCloseN;
    imgMaximize.Picture.Graphic := m_pngMaximizeN;
    imgMinimize.Picture.Graphic := m_pngMinimizeN;
  except
  end;

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
end;

//==============================================================================
procedure TAcrylicForm.FormPaint(Sender: TObject);
begin
  PaintBackground;
  PaintBorder;
end;

//==============================================================================
procedure TAcrylicForm.PaintBackground;
var
  gdiGraphics   : TGPGraphics;
  gdiSolidBrush : TGPSolidBrush;
begin
  if not WithBlur then
  begin
    gdiGraphics   := TGPGraphics.Create(Canvas.Handle);
    gdiSolidBrush := TGPSolidBrush.Create(GdiColor(m_clBackColor));

    gdiGraphics.FillRectangle(gdiSolidBrush, 1, 1, ClientWidth - 1, ClientHeight - 1);

    gdiGraphics.Free;
    gdiSolidBrush.Free;
  end;
end;

//==============================================================================
procedure TAcrylicForm.PaintBorder;
var
  gdiGraphics : TGPGraphics;
  gdiSolidPen : TGPPen;
begin
  if m_bWithBorder then
  begin
    gdiGraphics := TGPGraphics.Create(Canvas.Handle);
    gdiSolidPen := TGPPen.Create(GdiColor(m_clBorderColor), 1);

    gdiGraphics.DrawRectangle(gdiSolidPen, 0, 0, ClientWidth - 1, ClientHeight - 1);

    gdiGraphics.Free;
    gdiSolidPen.Free;
  end;
end;

//==============================================================================
procedure TAcrylicForm.UpdatePositions;
var
  nIconCount : Integer;
begin
  pnlBackground.Left    := 1;
  pnlBackground.Top     := 1;
  pnlBackground.Width   := ClientWidth  - 2;
  pnlBackground.Height  := ClientHeight - 2;

  pnlContent.Left    := c_nBorderTriggerSize;
  pnlContent.Top     := pnlTitleBar.Height;
  pnlContent.Width   := ClientWidth  - 2 * c_nBorderTriggerSize;
  pnlContent.Height  := ClientHeight - pnlTitleBar.Height - c_nBorderTriggerSize;

  nIconCount := 1;

  imgClose.Width     := c_nTopIconWidth;
  imgClose.Height    := c_nTopIconHeight;
  imgClose.Left      := Width - nIconCount * c_nTopIconWidth;
  imgClose.Top       := 0;

  if imgClose.Visible then
    Inc(nIconCount);

  imgMaximize.Width  := imgClose.Width;
  imgMaximize.Height := imgClose.Height;
  imgMaximize.Left   := Width - nIconCount * c_nTopIconWidth;
  imgMaximize.Top    := imgClose.Top;

  if imgMaximize.Visible then
    Inc(nIconCount);

  imgMinimize.Width  := imgClose.Width;
  imgMinimize.Height := imgClose.Height;
  imgMinimize.Left   := Width - nIconCount * c_nTopIconWidth;
  imgMinimize.Top    := imgClose.Top;
end;

//==============================================================================
procedure TAcrylicForm.EnableBlur(hwndHandle: HWND; nMode: Integer);
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
  nBlurLevel : Integer;
begin
  if not WithBlur then
    nMode := 1;

  nBlurLevel := m_btBlurAmount;

  DWM10 := LoadLibrary('user32.dll');

  try
    @SetWindowCompositionAttribute := GetProcAddress(DWM10, 'SetWindowCompositionAttribute');
    if @SetWindowCompositionAttribute <> nil then
    begin
      Accent.AccentState   := nMode;
      Accent.AccentFlags   := 2;
      Accent.GradientColor := (nBlurLevel SHL 24) or m_clBlurColor;

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
  imgClose.Picture.Graphic := m_pngCloseH;
end;

//==============================================================================
procedure TAcrylicForm.imgCloseMouseLeave(Sender: TObject);
begin
  imgClose.Picture.Graphic := m_pngCloseN;
end;

//==============================================================================
procedure TAcrylicForm.imgMaximizeMouseEnter(Sender: TObject);
begin
  imgMaximize.Picture.Graphic := m_pngMaximizeH;
end;

//==============================================================================
procedure TAcrylicForm.imgMaximizeMouseLeave(Sender: TObject);
begin
  imgMaximize.Picture.Graphic := m_pngMaximizeN;
end;

//==============================================================================

procedure TAcrylicForm.imgMinimizeMouseEnter(Sender: TObject);
begin
  imgMinimize.Picture.Graphic := m_pngMinimizeH;
end;

//==============================================================================
procedure TAcrylicForm.imgMinimizeMouseLeave(Sender: TObject);
begin
  imgMinimize.Picture.Graphic := m_pngMinimizeN;
end;

//==============================================================================
//
//  System Messages
//
//==============================================================================
procedure TAcrylicForm.WMNCMoving(var Msg: TWMMoving);
begin
  inherited;
  OnMoveOrResize;
end;

//==============================================================================
procedure TAcrylicForm.WMNCSize(var Msg: TWMSize);
begin
  inherited;
  OnMoveOrResize;
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

  m_tmrAcrylicChange.Enabled := False;
  m_tmrAcrylicChange.Enabled := True;
end;

//==============================================================================
procedure TAcrylicForm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
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

//==============================================================================
end.
