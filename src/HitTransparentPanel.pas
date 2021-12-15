unit HitTransparentPanel;

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

  THitTransparentPanel = Class(TPanel)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TEST', [THitTransparentPanel]);
end;

procedure THitTransparentPanel.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  Msg.Result := HTTRANSPARENT;
end;



end.


