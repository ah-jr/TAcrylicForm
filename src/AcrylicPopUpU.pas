unit AcrylicPopUpU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  Registry,
  DWMApi,
  AcrylicGhostPanelU,
  AcrylicTypesU,
  AcrylicLabelU,
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL;

type
  TPopUpItem = record
    Text   : String;
    //Image  :
    Action : TPopUpItemEvent;
  end;

  TAcrylicPopUp = Class(TAcrylicGhostPanel)
  private
    m_lstItems : TList<TAcrylicLabel>;

  protected
    procedure Paint; override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;

    procedure AddItem(a_puiItem : TPopUpItem);
    procedure ClearItems;

    procedure PopUp(a_nLeft : Integer; a_nTop : Integer);
    procedure Hide;

  published
    property BackColor;
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
  GR32,
  GR32_Backends,
  Math,
  AcrylicUtilsU;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicPopUp]);
end;

//==============================================================================
constructor TAcrylicPopUp.Create(AOwner : TComponent);
begin
  Inherited;

  WithBorder := True;
  Visible    := False;

  BorderColor := c_clLavaOrange;

  m_lstItems := TList<TAcrylicLabel>.Create;

  Width := c_nMinWidth;
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
  AlLabel : TAcrylicLabel;
begin
  AlLabel        := TAcrylicLabel.Create(Self);
  AlLabel.Parent := Self;
  AlLabel.Left   := c_nBorderSize;
  AlLabel.Top    := c_nBorderSize + m_lstItems.Count * c_nItemHeight;
  AlLabel.Width  := Width - 2*c_nBorderSize;
  AlLabel.Height := c_nItemHeight;
  AlLabel.Text   := a_puiItem.Text;

  m_lstItems.Add(AlLabel);
end;

//==============================================================================
procedure TAcrylicPopUp.ClearItems;
var
  AlLabel : TAcrylicLabel;
begin
  for AlLabel in m_lstItems do
    FreeAndNil(AlLabel);

  m_lstItems.Clear;
end;

//==============================================================================
procedure TAcrylicPopUp.PopUp(a_nLeft : Integer; a_nTop : Integer);
var
  nMaxWidth : Integer;
  AlLabel   : TAcrylicLabel;
begin
  Left := a_nLeft;
  Top  := a_nTop;

  nMaxWidth := c_nMinWidth;
  for AlLabel in m_lstItems do
    nMaxWidth := Max(c_nMinWidth, AlLabel.Width + 2*c_nBorderSize);

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
var
  nIndex : Integer;
begin
  Inherited;
end;

end.


