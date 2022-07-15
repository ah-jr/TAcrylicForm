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
  DWMApi;

type

  TAcrylicLabel = Class(TLabel)
  protected
    procedure Paint; override;
end;

procedure Register;

implementation

uses
  GDIPOBJ, GDIPAPI, GDIPUTIL;

//==============================================================================
procedure Register;
begin
  RegisterComponents('AcrylicComponents', [TAcrylicLabel]);
end;

//==============================================================================
procedure TAcrylicLabel.Paint;
var
  gdiGraphics  : TGPGraphics;
  gdiSolidPen  : TGPPen;
  gdiBrush     : TGPSolidBrush;
  gdiFont      : TGPFont;
  pntText      : TGPPointF;
  recText      : TGPRectF;
  nColor       : Cardinal;
  bmpResult    : TBitmap;
begin
  //////////////////////////////////////////////////////////////////////////////
  // Create bitmap that will contain the final result
  bmpResult := TBitmap.Create;
  bmpResult.SetSize(ClientWidth,ClientHeight);
  bmpResult.Canvas.Brush.Color := clBackground;
  bmpResult.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  gdiGraphics := TGPGraphics.Create(bmpResult.Canvas.Handle);
  gdiSolidPen := TGPPen.Create(nColor);
  gdiBrush    := TGPSolidBrush.Create(nColor);
  gdiFont     := TGPFont.Create(Font.Name, Font.Size, FontStyleRegular);
  gdiGraphics.SetSmoothingMode(SmoothingModeNone);
  gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

  //////////////////////////////////////////////////////////////////////////////
  // Draw text
  if Caption <> '' then
  begin
    pntText.X := 0;
    pntText.Y := 0;
    gdiGraphics.MeasureString(Caption, -1, gdiFont, pntText, recText);

    case Alignment of
      taCenter:
      begin
        pntText.X := Trunc(ClientWidth  - recText.Width) div 2;
        pntText.Y := Trunc(ClientHeight - recText.Height) div 2;
      end;

      taLeftJustify:
      begin
        pntText.X := 1;
        pntText.Y := 1;
      end;

      taRightJustify:
      begin
        pntText.X := Trunc(ClientWidth  - recText.Width - 1);
        pntText.Y := Trunc(ClientHeight - recText.Height - 1);
      end;
    end;

    gdiBrush.SetColor(MakeColor(255, 255, 255, 255));
    gdiGraphics.DrawString(Caption, -1, gdiFont, pntText, gdiBrush);

    gdiFont.Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Free objects
  gdiGraphics.Free;
  gdiSolidPen.Free;
  gdiBrush.Free;

  //////////////////////////////////////////////////////////////////////////////
  // Draw result to canvas
  Canvas.Draw(0, 0, bmpResult);
end;


end.


