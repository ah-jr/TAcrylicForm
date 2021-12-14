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
  Vcl.Imaging.pngimage,
  DWMApi,
  Registry,
  HitTransparentPanel;

function newWndProc(hwnd: hwnd; uMsg: UINT; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;

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
    imgClose: TImage;
    imgMaximize: TImage;
    imgMinimize: TImage;
    clFormColor : TColor;

    tmrAcrylicChange: TTimer;

    procedure EnableBlur(hwndHandle: hwnd; nMode: Integer);
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure OnAcrylicTimer(Sender: TObject);
    procedure UpdateAuxForms;
    procedure OnCloseImageClick(Sender: TObject);
    procedure SetColor(a_clColor : TColor);

  protected
    function DoHandleStyleMessage(var Message: TMessage): Boolean; override;

  public
    destructor Destroy; override;

    procedure ChangeBlurMode(nMode: Integer);
    procedure OnMoveOrResize;

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
  SetWindowCompositionAttribute: function(hwnd: hwnd;
    var Data: WindowCompositionAttributeData): Integer; stdcall;

  OldWindowProc: Pointer = nil;
  NewWindowProc: Pointer = nil;

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
  ChangeBlurMode(3);
  tmrAcrylicChange.Enabled := False;
  tmrAcrylicChange.Enabled := True;

  UpdateAuxForms;
end;

procedure TAcrylicForm.ChangeBlurMode(nMode: Integer);
begin
  EnableBlur(Handle, nMode);
end;

destructor TAcrylicForm.Destroy;
begin
  inherited;
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

  OldWindowProc := Pointer(GetWindowLong(self.Handle, GWL_WNDPROC));
  NewWindowProc := Pointer(SetWindowLong(self.Handle, GWL_WNDPROC,
    Integer(@newWndProc)));



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

  imgClose.Picture.LoadFromFile('images/close-hovered.png');
  imgMaximize.Picture.LoadFromFile('images/maximize.png');
  imgMinimize.Picture.LoadFromFile('images/minimize.png');
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

function newWndProc(hwnd: hwnd; uMsg: UINT; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
begin
  if hwnd = MainAcrylicForm.Handle then
  begin
    case uMsg of
      WM_MOVING, WM_SIZE:
        begin
          MainAcrylicForm.OnMoveOrResize;
        end;
    end;
  end;
  Result := CallWindowProc(OldWindowProc, hwnd, uMsg, wParam, lParam);
end;

end.
