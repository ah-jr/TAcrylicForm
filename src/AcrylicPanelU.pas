unit AcrylicPanelU;

interface

uses
  System.Classes,
  AcrylicControlU;

type

  TAcrylicPanel = Class(TAcrylicControl)
  public
    constructor Create(a_cOwner : TComponent); override;
    destructor  Destroy; override;

  published
    property Align;
    property TabOrder;
    property Ghost;
    property BevelOuter;
    property Colored;
    property Color;
    property Bordercolor;
    property WithBorder;
    property BorderRadius;

  end;

procedure Register;

implementation

uses
  AcrylicTypesU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicPanel]);
end;

//==============================================================================
constructor TAcrylicPanel.Create(a_cOwner : TComponent);
begin
  Inherited;
end;

//==============================================================================
destructor TAcrylicPanel.Destroy;
begin
  Inherited;
end;

end.


