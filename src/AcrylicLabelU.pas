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

  public
    constructor Create(AOwner: TComponent); override;

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
constructor TAcrylicLabel.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  m_bWithBorder   := False;
  m_bWithBack     := False;
end;

//==============================================================================
procedure TAcrylicLabel.PaintComponent;
begin
  PaintText;
end;

end.


