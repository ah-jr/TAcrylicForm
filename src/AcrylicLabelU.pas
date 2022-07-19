unit AcrylicLabelU;

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
  DWMApi,
  AcrylicUtilsU,
  AcrylicControlU;

type

  TAcrylicLabel = Class(TAcrylicControl)
  protected
    procedure PaintComponent; override;

end;

procedure Register;

implementation

uses
  GDIPOBJ, GDIPAPI, GDIPUTIL, AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicLabel]);
end;

//==============================================================================
procedure TAcrylicLabel.PaintComponent;
begin
  PaintBackground;
  PaintText;
end;

end.


