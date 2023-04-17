unit AcrylicButtonU;

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
  AcrylicControlU,
  AcrylicTypesU;

type
  TAcrylicButton = Class(TAcrylicControl)
  private
    m_pngImage : TPngImage;

    procedure SetPNG(a_pngPNG : TPngImage);

  protected
    procedure PaintComponent; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

  published
    property Png : TPngImage read m_pngImage write SetPNG;

  end;

  procedure Register;

implementation

uses
  GDIPOBJ, GDIPAPI, GDIPUTIL;

 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicButton]);
 end;

//==============================================================================
constructor TAcrylicButton.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  m_pngImage := nil;

  m_bClickable := True;
end;

//==============================================================================
destructor TAcrylicButton.Destroy;
begin
  if m_pngImage <> nil then
    m_pngImage.Free;

  Inherited;
end;

//==============================================================================
procedure TAcrylicButton.SetPNG(a_pngPNG : TPngImage);
begin
  if m_pngImage <> nil then
    FreeAndNil(m_pngImage);

  m_pngImage := a_pngPNG
end;

//==============================================================================
procedure TAcrylicButton.PaintComponent;
var
  gdiImage  : TGPImage;
  msStream  : TMemoryStream;
  saAdapter : TStreamAdapter;
begin
  PaintText;

  //////////////////////////////////////////////////////////////////////////////
  // Draw icon
  if m_pngImage <> nil then
  begin
    msStream := TMemoryStream.Create;
    m_pngImage.SaveToStream(msStream);

    saAdapter := TStreamAdapter.Create(msStream, soReference);
    gdiImage  := TGPImage.Create(saAdapter);

    m_gdiGraphics.DrawImage(gdiImage,
                            (ClientWidth  - Trunc(gdiImage.GetWidth))  div 2,
                            (ClientHeight - Trunc(gdiImage.GetHeight)) div 2,
                            gdiImage.GetWidth,
                            gdiImage.GetHeight);

    gdiImage.Free;
    msStream.Free;
  end;
end;

end.


