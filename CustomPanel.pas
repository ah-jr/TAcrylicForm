unit CustomPanel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DWMApi, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Registry;

type

  TCustomPanel = Class(TPanel)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;

end;

implementation

procedure TCustomPanel.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  Msg.Result := HTTRANSPARENT;
end;

end.

