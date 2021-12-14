unit AcrylicFormU;

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
  DWMApi,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  Registry,
  CustomPanel,
  AuxForm1,
  System.Types;

  function newWndProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

type
  TAcrylicForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    pnlWorkingArea : TCustomPanel;
    pnlTitleBar    : TCustomPanel;

    AuxFormLeft  : TAuxForm1;
    AuxFormRight : TAuxForm1;

    CloseImage : TImage;
    MaximizeImage : TImage;
    MinimizeImage : TImage;

    tmrAcrylicChange : TTimer;

    procedure EnableBlur(hwndHandle : HWND; nMode : Integer);
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure OnAcrylicTimer(Sender: TObject);
    procedure UpdateAuxForms;
    procedure OnCloseImageClick(Sender : TObject);

  public
    destructor Destroy; override;

    procedure ChangeBlurMode(nMode : Integer);
    procedure OnMoveOrResize;

    property AcrylicTimer : TTimer read tmrAcrylicChange write tmrAcrylicChange;

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
  SetWindowCompositionAttribute:function (hWnd: HWND; var data: WindowCompositionAttributeData):integer; stdcall;

  OldWindowProc: Pointer = nil;
  NewWindowProc: Pointer = nil;

  OldPanelProc: Pointer = nil;
  NewPanelProc: Pointer = nil;

implementation

{$R *.dfm}

procedure TAcrylicForm.OnAcrylicTimer(Sender: TObject);
begin
  if not (GetKeyState(VK_LBUTTON) and $8000 <> 0) then
  begin
    EnableBlur(Handle, 4);
    UpdateAuxForms;
  end;
end;

procedure TAcrylicForm.OnCloseImageClick(Sender: TObject);
begin
  Close;
end;

procedure TAcrylicForm.OnMoveOrResize;
begin
  pnlWorkingArea.Left := 0;
  pnlWorkingArea.Top := 0;
  pnlWorkingArea.Width := Width;
  pnlWorkingArea.Height := Height;

  ChangeBlurMode(3);
  AcrylicTimer.Enabled := False;
  AcrylicTimer.Enabled := True;

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

procedure TAcrylicForm.EnableBlur(hwndHandle : HWND; nMode : Integer);
const
  WCA_ACCENT_POLICY = 19;
  ACCENT_ENABLE_BLURBEHIND = 3;
  ACCENT_ENABLE_ACRYLICBLURBEHIND = 4;
var
  dwm10: THandle;
  data: WindowCompositionAttributeData;
  accent: AccentPolicy;
  clColor : TColor;
  blurAmount : Byte;
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
    @SetWindowCompositionAttribute := GetProcAddress(dwm10, 'SetWindowCompositionAttribute');
    if @SetWindowCompositionAttribute <> nil then
    begin
      accent.AccentState := nMode;
      accent.AccentFlags := 2;
      accent.GradientColor := (blurAmount SHL 24) or clColor;
      data.Attribute := WCA_ACCENT_POLICY;
      data.SizeOfData := SizeOf(accent);
      data.Data := @accent;
      SetWindowCompositionAttribute(hwndHandle, data);
    end
    else
    begin
      ShowMessage('Not found Windows 10 SetWindowCompositionAttribute in user32.dll');
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

  OldWindowProc:= Pointer(GetWindowLong(self.Handle, GWL_WNDPROC));
  NewWindowProc:= Pointer(SetWindowLong(self.Handle, GWL_WNDPROC, Integer(@newWndProc)));


  pnlWorkingArea := TCustomPanel.Create(Self);
  pnlWorkingArea.Parent := Self;
  pnlWorkingArea.Left := 0;
  pnlWorkingArea.Top := 0;
  pnlWorkingArea.Width := Width;
  pnlWorkingArea.Height := Height;

  tmrAcrylicChange := TTimer.Create(Self);
  tmrAcrylicChange.Interval := 10;
  tmrAcrylicChange.OnTimer  := OnAcrylicTimer;
  tmrAcrylicChange.Enabled  := True;

  AuxFormLeft         := TAuxForm1.Create(pnlWorkingArea);
  AuxFormRight        := TAuxForm1.Create(pnlWorkingArea);
  AuxFormLeft.Parent  := pnlWorkingArea;
  AuxFormRight.Parent := pnlWorkingArea;

  AuxFormLeft.AlphaBlendValue  := 10;
  AuxFormRight.AlphaBlendValue := 0;

  pnlTitleBar := TCustomPanel.Create(AuxFormRight);
  pnlTitleBar.Parent := AuxFormRight;
  pnlTitleBar.BevelOuter := bvNone;

  CloseImage    := TImage.Create(Self);
  MaximizeImage := TImage.Create(Self);
  MinimizeImage := TImage.Create(Self);

  CloseImage.Parent := Self;
  MaximizeImage.Parent := Self;
  MinimizeImage.Parent := Self;

  CloseImage.OnClick := OnCloseImageClick;

  CloseImage.Picture.LoadFromFile('images/close-hovered.png');
  MaximizeImage.Picture.LoadFromFile('images/maximize.png');
  MinimizeImage.Picture.LoadFromFile('images/minimize.png');
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

procedure TAcrylicForm.UpdateAuxForms;
begin
  if not AuxFormLeft.Visible then
    AuxFormLeft.Show;
  AuxFormLeft.Left   := 1;
  AuxFormLeft.Top    := 1;
  AuxFormLeft.Height := Height - AuxFormLeft.Top - 2;
  AuxFormLeft.Width  := 200;

  if not AuxFormRight.Visible then
    AuxFormRight.Show;

  AuxFormRight.Left   := AuxFormLeft.Width + 1;
  AuxFormRight.Top    := 1;
  AuxFormRight.Height := Height - AuxFormLeft.Top - 2;
  AuxFormRight.Width  := Width - AuxFormLeft.Left - 2;


  pnlTitleBar.Left := 0;
  pnlTitleBar.Top := 0;
  pnlTitleBar.Width := AuxFormRight.Width;
  pnlTitleBar.Height := 50;

  CloseImage.Width     := 46;
  CloseImage.Height    := 32;
  CloseImage.Left      := Width - 46;
  CloseImage.Top       := 1;

  MaximizeImage.Width  := 46;
  MaximizeImage.Height := 32;
  MaximizeImage.Left      := CloseImage.Left - 46;
  MaximizeImage.Top       := 1;

  MinimizeImage.Width  := 46;
  MinimizeImage.Height := 32;
  MinimizeImage.Left      := MaximizeImage.Left - 46;
  MinimizeImage.Top       := 1;

end;

procedure TAcrylicForm.WMNCHitTest(var Msg: TWMNCHitTest);
const
  c_nSpan = 7;
var
  ScreenPt: TPoint;
  nBorder : Integer;
begin
  nBorder := BorderWidth + 2;
  ScreenPt := ScreenToClient(Point(Msg.Xpos, Msg.Ypos));
  inherited;

  if (WindowState = wsNormal) then
    begin
      if (ScreenPt.x < c_nSpan) and (ScreenPt.y < c_nSpan) then
        Msg.Result := HTTOPLEFT
      else if (ScreenPt.x < c_nSpan) and (ScreenPt.y >= Height - c_nSpan - nBorder) then
        Msg.Result := HTBOTTOMLEFT
      else if (ScreenPt.x >= Width - c_nSpan - nBorder) and (ScreenPt.y < c_nSpan) then
        Msg.Result := HTTOPRIGHT
      else if (ScreenPt.x >= Width - c_nSpan - nBorder) and (ScreenPt.y >= Height - c_nSpan - nBorder) then
        Msg.Result := HTBOTTOMRIGHT
      else if (ScreenPt.x < c_nSpan) then
        Msg.Result := HTLEFT
      else if (ScreenPt.y < c_nSpan) then
        Msg.Result := HTTOP
      else if (ScreenPt.x >= Width - c_nSpan - nBorder) then
        Msg.Result := HTRIGHT
      else if (ScreenPt.y >= Height - c_nSpan - nBorder) then
        Msg.Result := HTBOTTOM
      else if (ScreenPt.y <= pnlTitleBar.Height) then
         Msg.Result := HTCAPTION;
    end;

  tmrAcrylicChange.Enabled := False;
  tmrAcrylicChange.Enabled := True;
end;

function newWndProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
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

