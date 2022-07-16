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
  AcrylicTypesU;

type
  TAcrylicButton = Class(TCustomControl)
  private
    m_msMouseState : TMouseState;
    m_pngImage     : TPngImage;
    m_strText      : String;

    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMMouseEnter(var Message: TMessage);      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);      message CM_MOUSELEAVE;

  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

  published
    property Png  : TPngImage read m_pngImage write m_pngImage;
    property Text : String    read m_strText  write m_strText;

    property OnClick;
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
  inherited Create(AOwner);
  Color := clBackground;
  m_msMouseState := msNone;
end;

//==============================================================================
destructor TAcrylicButton.Destroy;
begin
  inherited;

  if m_pngImage <> nil then
    m_pngImage.Free;
end;

//==============================================================================
procedure TAcrylicButton.Paint;
var
  gdiGraphics  : TGPGraphics;
  gdiSolidPen  : TGPPen;
  gdiBrush     : TGPSolidBrush;
  gdiImage     : TGPImage;
  gdiFont      : TGPFont;
  pntText      : TGPPointF;
  recText      : TGPRectF;
  nColor       : Cardinal;
  msStream     : TMemoryStream;
  saAdapter    : TStreamAdapter;
  bmpResult    : TBitmap;
begin
  //////////////////////////////////////////////////////////////////////////////
  // Create bitmap that will contain the final result
  bmpResult := TBitmap.Create;
  bmpResult.SetSize(ClientWidth,ClientHeight);
  bmpResult.Canvas.Brush.Color := clBackground;
  bmpResult.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  //////////////////////////////////////////////////////////////////////////////
  // Setup color and create GDIP objects
  case m_msMouseState of
    msNone    : nColor := MakeColor(100, 0, 0, 0);
    msClicked : nColor := MakeColor(100, 30, 30, 30);
    msHover   : nColor := MakeColor(100, 15, 15, 15);
    else        nColor := MakeColor(100, 0, 0, 0);
  end;

  gdiGraphics := TGPGraphics.Create(bmpResult.Canvas.Handle);
  gdiSolidPen := TGPPen.Create(nColor);
  gdiBrush    := TGPSolidBrush.Create(nColor);
  gdiGraphics.SetSmoothingMode(SmoothingModeNone);
  gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

  //////////////////////////////////////////////////////////////////////////////
  // Draw button
  gdiGraphics.FillRectangle(gdiBrush, 0, 0, ClientWidth, ClientHeight);
  gdiGraphics.DrawRectangle(gdiSolidPen, 0, 0, ClientWidth-1, ClientHeight-1);

  //////////////////////////////////////////////////////////////////////////////
  // Draw text
  if m_strText <> '' then
  begin
    gdiFont := TGPFont.Create('Tahoma', 8, FontStyleRegular);

    pntText.X := 0;
    pntText.Y := 0;
    gdiGraphics.MeasureString(m_strText, -1, gdiFont, pntText, recText);
    pntText.X := Trunc(ClientWidth  - recText.Width) div 2;
    pntText.Y := Trunc(ClientHeight - recText.Height) div 2;

    gdiBrush.SetColor(MakeColor(255, 255, 255, 255));
    gdiGraphics.DrawString(m_strText, -1, gdiFont, pntText, gdiBrush);

    gdiFont.Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Draw icon
  if m_pngImage <> nil then
  begin
    msStream := TMemoryStream.Create;
    m_pngImage.SaveToStream(msStream);

    saAdapter := TStreamAdapter.Create(msStream, soReference);
    gdiImage  := TGPImage.Create(saAdapter);

    gdiGraphics.DrawImage(gdiImage,
                          (ClientWidth  - Trunc(gdiImage.GetWidth))  div 2,
                          (ClientHeight - Trunc(gdiImage.GetHeight)) div 2,
                          gdiImage.GetWidth,
                          gdiImage.GetHeight);

    gdiImage.Free;
    msStream.Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Free objects
  gdiGraphics.Free;
  gdiSolidPen.Free;
  gdiBrush.Free;

  //////////////////////////////////////////////////////////////////////////////
  // Draw result to canvas
  Canvas.Draw(0, 0, bmpResult);
  bmpResult.Free;
end;

//==============================================================================
procedure TAcrylicButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msNone;
  Repaint;
end;

//==============================================================================
procedure TAcrylicButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msClicked;
  Repaint;
end;

//==============================================================================
procedure TAcrylicButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //
end;

//==============================================================================
procedure TAcrylicButton.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  // Do nothing to prevent flicker
end;

//==============================================================================
procedure TAcrylicButton.CMMouseEnter(var Message: TMessage);
begin
  m_msMouseState := msHover;
  Invalidate;
end;

//==============================================================================
procedure TAcrylicButton.CMMouseLeave(var Message: TMessage);
begin
  m_msMouseState := msNone;
  Invalidate;
end;

end.


