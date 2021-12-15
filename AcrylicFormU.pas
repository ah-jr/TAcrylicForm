unit AcrylicFormU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Imaging.pngimage,
  HitTransparentPanel;


type
  TAcrylicForm = class(TForm)
    pnlTitleBar: THitTransparentPanel;
    pnlBackground: THitTransparentPanel;
    pnlContent: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure MouseMove(Sender: TObject);

  private
    m_bInitialized : Boolean;
    imgClose: TImage;
    imgMaximize: TImage;
    imgMinimize: TImage;
    clFormColor : TColor;

    m_pngCloseN    : TPngImage;
    m_pngCloseH    : TPngImage;
    m_pngMaximizeN : TPngImage;
    m_pngMaximizeH : TPngImage;
    m_pngMinimizeN : TPngImage;
    m_pngMinimizeH : TPngImage;

    tmrAcrylicChange: TTimer;

    procedure EnableBlur(hwndHandle: hwnd; nMode: Integer);
    procedure OnAcrylicTimer(Sender: TObject);
    procedure OnMoveOrResize;
    procedure UpdateAuxForms;
    procedure OnCloseImageClick(Sender: TObject);
    procedure SetColor(a_clColor : TColor);

    procedure WMNCMoving(var Msg: TWMMoving); message WM_MOVING;
    procedure WMNCSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;

  protected
    function DoHandleStyleMessage(var Message: TMessage): Boolean; override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;



    property Color : TColor read clFormColor write SetColor;
  end;

  AccentPolicy = packed record
    AccentState: Integer;
    AccentFlags: Integer;
    GradientColor: Integer;
    AnimationId: Integer;
  end;

  WindowCompositionAttributeData = packed record
    Attribute: Cardinal;
    Data: Pointer;
    SizeOfData: Integer;
  end;

var
  MainAcrylicForm: TAcrylicForm;
  SetWindowCompositionAttribute: function(hwnd: hwnd; var Data: WindowCompositionAttributeData): Integer; stdcall;

const
  c_nTitleBarHeight = 50;

implementation

{$R *.dfm}

procedure TAcrylicForm.OnAcrylicTimer(Sender: TObject);
begin
  if not(GetKeyState(VK_LBUTTON) and $8000 <> 0) then
  begin
    EnableBlur(Handle, 4);
    UpdateAuxForms;
  end;
end;

procedure TAcrylicForm.OnCloseImageClick(Sender: TObject);
begin
  Close;
end;

procedure TAcrylicForm.SetColor(a_clColor : TColor);
begin
  clFormColor := a_clColor;
end;

procedure TAcrylicForm.OnMoveOrResize;
begin
  if m_bInitialized then
  begin
    EnableBlur(Handle, 3);

    tmrAcrylicChange.Enabled := False;
    tmrAcrylicChange.Enabled := True;

    UpdateAuxForms;
  end;
end;

constructor TAcrylicForm.Create(AOwner : TComponent);
begin
  m_bInitialized := False;

  m_pngCloseN    := TPngImage.Create;
  m_pngCloseH    := TPngImage.Create;
  m_pngMaximizeN := TPngImage.Create;
  m_pngMaximizeH := TPngImage.Create;
  m_pngMinimizeN := TPngImage.Create;
  m_pngMinimizeH := TPngImage.Create;

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

destructor TAcrylicForm.Destroy;
begin
  inherited;

  m_pngCloseN.Free;
  m_pngCloseH.Free;
  m_pngMaximizeN.Free;
  m_pngMaximizeH.Free;
  m_pngMinimizeN.Free;
  m_pngMinimizeH.Free;

  tmrAcrylicChange.Enabled := False;
  tmrAcrylicChange.Free;
end;

function TAcrylicForm.DoHandleStyleMessage(var Message: TMessage): Boolean;
begin
  if Message.Msg = WM_NCHITTEST then
  begin
    Result := False;
  end
  else
  begin
    Result := inherited;
  end;
end;

procedure TAcrylicForm.EnableBlur(hwndHandle: hwnd; nMode: Integer);
const
  WCA_ACCENT_POLICY = 19;
  ACCENT_ENABLE_BLURBEHIND = 3;
  ACCENT_ENABLE_ACRYLICBLURBEHIND = 4;
var
  dwm10: THandle;
  Data: WindowCompositionAttributeData;
  accent: AccentPolicy;
  clColor: TColor;
  blurAmount: Byte;
begin
  dwm10 := LoadLibrary('user32.dll');

  if nMode = 3 then
  begin
    clColor := $252525;
    blurAmount := 235;
  end
  else
  begin
    clColor := $202020;
    blurAmount := 200;
  end;

  try
    @SetWindowCompositionAttribute :=
      GetProcAddress(dwm10, 'SetWindowCompositionAttribute');
    if @SetWindowCompositionAttribute <> nil then
    begin
      accent.AccentState := nMode;
      accent.AccentFlags := 2;
      accent.GradientColor := (blurAmount SHL 24) or clColor;
      Data.Attribute := WCA_ACCENT_POLICY;
      Data.SizeOfData := SizeOf(accent);
      Data.Data := @accent;
      SetWindowCompositionAttribute(hwndHandle, Data);
    end
    else
    begin
      ShowMessage
        ('Not found Windows 10 SetWindowCompositionAttribute in user32.dll');
    end;
  finally
    FreeLibrary(dwm10);
  end;
end;

procedure TAcrylicForm.FormCreate(Sender: TObject);
begin
  BorderStyle := bsNone;
  BorderIcons := [biSystemMenu, biMinimize];



  EnableBlur(Handle, 4);


  tmrAcrylicChange := TTimer.Create(self);
  tmrAcrylicChange.Interval := 10;
  tmrAcrylicChange.OnTimer := OnAcrylicTimer;
  tmrAcrylicChange.Enabled := True;

  imgClose := TImage.Create(pnlTitleBar);
  imgMaximize := TImage.Create(pnlTitleBar);
  imgMinimize := TImage.Create(pnlTitleBar);

  imgClose.Parent := pnlTitleBar;
  imgMaximize.Parent := pnlTitleBar;
  imgMinimize.Parent := pnlTitleBar;

  imgClose.OnClick := OnCloseImageClick;


  //////////////////////////////////////////////////////////////////////////////
  ///  Load Icons:
  try
    imgClose.Picture.Graphic    := m_pngCloseN;
    imgMaximize.Picture.Graphic := m_pngMaximizeN;
    imgMinimize.Picture.Graphic := m_pngMinimizeN;
  except
  end;

  m_bInitialized := True;
end;

procedure TAcrylicForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  EnableBlur(Handle, 3);

  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
  end;
end;

procedure TAcrylicForm.MouseMove(Sender: TObject);
begin
  //
end;

procedure TAcrylicForm.UpdateAuxForms;
begin
  imgClose.Width := 46;
  imgClose.Height := 32;
  imgClose.Left := Width - 47;
  imgClose.Top := 0;

  imgMaximize.Width := imgClose.Width;
  imgMaximize.Height := imgClose.Height;
  imgMaximize.Left := imgClose.Left - 46;
  imgMaximize.Top := imgClose.Top;

  imgMinimize.Width := imgClose.Width;
  imgMinimize.Height := imgClose.Height;
  imgMinimize.Left := imgMaximize.Left - 46;
  imgMinimize.Top := imgClose.Top;
end;

procedure TAcrylicForm.WMNCMoving(var Msg: TWMMoving);
begin
  inherited;
  OnMoveOrResize;
end;

procedure TAcrylicForm.WMNCSize(var Msg: TWMSize);
begin
  inherited;
  OnMoveOrResize;
end;

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

  if (WindowState = wsNormal) then
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
    else if (ScreenPt.Y <= c_nTitleBarHeight) then
      Msg.Result := HTCAPTION;
  end;

  tmrAcrylicChange.Enabled := False;
  tmrAcrylicChange.Enabled := True;
end;

end.
