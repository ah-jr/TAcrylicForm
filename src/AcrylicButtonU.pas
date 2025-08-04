unit AcrylicButtonU;

interface

uses
  System.Classes,
  Vcl.Imaging.PngImage,
  AcrylicControlU;

type

  TAcrylicButton = Class(TAcrylicControl)
  private
    procedure SetPNG(a_pngPNG : TPngImage);

  protected
    m_pngImage : TPngImage;
    procedure PaintComponent; override;

  public
    constructor Create(a_cOwner: TComponent); override;
    destructor  Destroy; override;

  published
    property Png : TPngImage read m_pngImage write SetPNG;

  end;

  procedure Register;

implementation

uses
  System.SysUtils,
  AcrylicTypesU,
  GDIPOBJ;

//==============================================================================
 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicButton]);
 end;

//==============================================================================
constructor TAcrylicButton.Create(a_cOwner: TComponent);
begin
  Inherited Create(a_cOwner);

  m_pngImage    := nil;
  m_bClickable  := True;
  m_bWithBorder := True;
  m_bColored    := True;
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
  InitializeGDI;
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

  ShutdownGDI;
end;

end.


