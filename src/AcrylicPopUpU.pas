unit AcrylicPopUpU;

interface

uses
  System.Classes,
  System.Generics.Collections,
  AcrylicPanelU,
  AcrylicLabelU;

type

  TPopUpItemEvent  = procedure of object;

  TPopUpItem = record
    Text   : String;
    Action : TPopUpItemEvent;
  end;

  TAcrylicPopUp = Class(TAcrylicPanel)
  private
    m_lstItems : TList<TAcrylicLabel>;

  protected
    procedure Paint; override;

  public
    constructor Create(a_cOwner : TComponent); override;
    destructor  Destroy; override;

    procedure AddItem(a_puiItem : TPopUpItem);
    procedure ClearItems;

    procedure PopUp(a_nLeft : Integer; a_nTop : Integer);
    procedure Hide;

  published
    property Color;
    property Canvas;
    property Colored;

  end;

const
  c_nTextLeft   = 10;
  c_nMinWidth   = 50;
  c_nItemHeight = 20;
  c_nBorderSize = 5;

procedure Register;

implementation

uses
  System.SysUtils,
  AcrylicTypesU,
  GR32,
  Math;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicPopUp]);
end;

//==============================================================================
constructor TAcrylicPopUp.Create(a_cOwner : TComponent);
begin
  Inherited;

  WithBorder  := True;
  Visible     := False;

  m_lstItems := TList<TAcrylicLabel>.Create;

  Width  := c_nMinWidth;
  Height := 0;
end;

//==============================================================================
destructor TAcrylicPopUp.Destroy;
begin
  FreeAndNil(m_lstItems);

  Inherited;
end;

//==============================================================================
procedure TAcrylicPopUp.AddItem(a_puiItem : TPopUpItem);
var
  alLabel : TAcrylicLabel;
begin
  alLabel        := TAcrylicLabel.Create(Self);
  alLabel.Parent := Self;
  alLabel.Left   := c_nBorderSize;
  alLabel.Top    := c_nBorderSize + m_lstItems.Count * c_nItemHeight;
  alLabel.Width  := Width - 2*c_nBorderSize;
  alLabel.Height := c_nItemHeight;
  alLabel.Text   := a_puiItem.Text;
  alLabel.Clickable := True;

  m_lstItems.Add(alLabel);
end;

//==============================================================================
procedure TAcrylicPopUp.ClearItems;
var
  alLabel : TAcrylicLabel;
begin
  for alLabel in m_lstItems do
    FreeAndNil(alLabel);

  m_lstItems.Clear;
end;

//==============================================================================
procedure TAcrylicPopUp.PopUp(a_nLeft : Integer; a_nTop : Integer);
var
  nMaxWidth : Integer;
  alLabel   : TAcrylicLabel;
begin
  Left := a_nLeft;
  Top  := a_nTop;

  nMaxWidth := c_nMinWidth;
  for alLabel in m_lstItems do
    nMaxWidth := Max(c_nMinWidth, alLabel.Width + 2*c_nBorderSize);

  Width  := nMaxWidth;
  Height := m_lstItems.Count * c_nItemHeight + 2*c_nBorderSize;

  if m_lstItems.Count > 0 then
    Visible := True;

  BringToFront;
end;

//==============================================================================
procedure TAcrylicPopUp.Hide;
begin
  Visible := False;
end;

//==============================================================================
procedure TAcrylicPopUp.Paint;
begin
  Inherited;
end;

end.


