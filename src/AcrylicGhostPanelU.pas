unit AcrylicGhostPanelU;

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
  DWMApi;

type

  TAcrylicGhostPanel = Class(TPanel)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;

  published
    property Canvas;

end;

procedure Register;

implementation

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicGhostPanel]);
end;

//==============================================================================
procedure TAcrylicGhostPanel.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  Msg.Result := HTTRANSPARENT;
end;


end.


