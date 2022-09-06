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
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL;

type
  TPopUpItem = record
    Text   : String;
    //Image  :
    Action : TPopUpItemEvent;
  end;


  TAcrylicPopUpU = Class(TAcrylicGhostPanel)
  private
    m_lstItems : TList<TPopUpItem>;

  protected
    procedure Paint; override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;

    procedure AddItem(a_puiItem : TPopUpItem);
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
  c_nMinWidth   = 100;
  c_nItemHeight = 30;

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
  RegisterComponents('AcrylicComponents', [TAcrylicPopUpU]);
end;

//==============================================================================
constructor TAcrylicPopUpU.Create(AOwner : TComponent);
begin
  WithBorder := True;
  Visible    := False;

  m_lstItems := TList<TPopUpItem>.Create;

  Width := c_nMinWidth;
  Height := 10;
end;

//==============================================================================
destructor TAcrylicPopUpU.Destroy;
begin
  FreeAndNil(m_lstItems);

  Inherited;
end;

//==============================================================================
procedure TAcrylicPopUpU.AddItem(a_puiItem : TPopUpItem);
begin
  m_lstItems.Add(a_puiItem);
end;

//==============================================================================
procedure TAcrylicPopUpU.PopUp(a_nLeft : Integer; a_nTop : Integer);
begin
  Left := a_nLeft;
  Top  := a_nTop;

  Width := c_nMinWidth;
  Height := m_lstItems.Count * c_nItemHeight;

  if m_lstItems.Count > 0 then
    Visible := True;
end;

//==============================================================================
procedure TAcrylicPopUpU.Hide;
begin
  Visible := False;
end;

//==============================================================================
procedure TAcrylicPopUpU.Paint;
var
  nIndex : Integer;
begin
  Inherited;

  for nIndex := 0 to m_lstItems.Count - 1 do
  begin
    Canvas.TextOut(c_nTextLeft, nIndex*c_nItemHeight, m_lstItems.Items[nIndex].Text);
  end;
end;

end.


