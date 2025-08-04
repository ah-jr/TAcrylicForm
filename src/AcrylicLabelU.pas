unit AcrylicLabelU;

interface

uses
  System.Classes,
  AcrylicControlU;

type

  TAcrylicLabel = Class(TAcrylicControl)
  public
    constructor Create(a_cOwner: TComponent); override;

  protected
    procedure PaintComponent; override;

  end;

procedure Register;

implementation

uses
  GDIPAPI;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicLabel]);
end;

//==============================================================================
constructor TAcrylicLabel.Create(a_cOwner: TComponent);
begin
  Inherited;
end;

//==============================================================================
procedure TAcrylicLabel.PaintComponent;
begin
  InitializeGDI;
  PaintText;
  ShutdownGDI;
end;

end.


