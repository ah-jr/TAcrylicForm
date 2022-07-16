unit AcrylicTrackU;

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
  TAcrylicTrack = Class(TCustomControl)
  private
    m_msMouseState : TMouseState;
    m_arrData      : TSingleArray;
    m_strText      : String;
    m_dPosition    : Double;

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

    procedure SetData(a_pData : PIntArray; a_nSize : Integer);

  published
    property Text     : String    read m_strText   write m_strText;
    property Position : Double    read m_dPosition write m_dPosition;

    property OnClick;

end;

  procedure Register;

implementation

uses
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL,
  Math;

 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicTrack]);
 end;

//==============================================================================
constructor TAcrylicTrack.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Color          := clBackground;
  m_dPosition    := -1;
  m_msMouseState := msNone;
end;

//==============================================================================
destructor TAcrylicTrack.Destroy;
begin
  inherited;
end;

//==============================================================================
procedure TAcrylicTrack.SetData(a_pData : PIntArray; a_nSize : Integer);
var
  nIndex : Integer;
  nIndex2 : Integer;
  nRatio : Integer;
  nMax   : Integer;
  dRes   : Single;
  dRes2   : Single;
begin
  SetLength(m_arrData, 2*(ClientWidth - 10));
  nRatio := Trunc(2 * a_nSize/Length(m_arrData));
  nMax   := 0;

  for nIndex := 0 to a_nSize - 1 do
  begin
    nMax := Max(nMax, Abs(TIntArray(a_pData^)[nIndex]));
  end;

  for nIndex := 0 to (Length(m_arrData) div 2) - 1 do
  begin
    dRes := -1000000000;
    dRes2 := 1000000000;
    for nIndex2 := 0 to nRatio - 1 do
    begin
      dRes  := Max(dRes,  TIntArray(a_pData^)[nIndex*nRatio + nIndex2]);
      dRes2 := Min(dRes2, TIntArray(a_pData^)[nIndex*nRatio + nIndex2]);
    end;

    m_arrData[2*nIndex] := dRes / nMax;
    m_arrData[2*nIndex+1] := dRes2 / nMax;
  end;
end;

//==============================================================================
procedure TAcrylicTrack.Paint;
var
  gdiGraphics  : TGPGraphics;
  gdiSolidPen  : TGPPen;
  gdiBrush     : TGPSolidBrush;
  gdiDataPath  : TGPGraphicsPath;
  gdiFont      : TGPFont;
  pntText      : TGPPointF;
  nColor       : Cardinal;
  bmpResult    : TBitmap;
  nIndex       : Integer;

  small, big, last : Single;
  switch : boolean;
  amplitude : Integer;
  offset:Integer;
  nPos    : Integer;
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
  // Draw background and titlebar
  gdiGraphics.FillRectangle(gdiBrush, 0, 0, ClientWidth, ClientHeight);

  //////////////////////////////////////////////////////////////////////////////
  // Draw data
  gdiGraphics.SetSmoothingMode(SmoothingModeHighQuality);
  gdiGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);

  gdiSolidPen.SetColor(MakeColor(255, 160, 180, 190));
  gdiSolidPen.SetWidth(1);

  gdiDataPath := TGPGraphicsPath.Create;
  last := 0;

  for nIndex := 0 to (Length(m_arrData) div 2) - 1 do
  begin
    amplitude := Trunc(0.9 * ((ClientHeight - 18) div 2));
    offset := (ClientHeight + 18) div 2;

    small := Min((amplitude*m_arrData[2*nIndex + 1] + offset),
                 (amplitude*m_arrData[2*nIndex    ] + offset));

    big   := Max((amplitude*m_arrData[2*nIndex + 1] + offset),
                 (amplitude*m_arrData[2*nIndex    ] + offset));


    switch := abs(big - last) < abs(small - last);

    if not switch then
    begin
      gdiDataPath.AddLine((nIndex + 5),
                          big,
                          (nIndex + 5),
                          small);

      last := small;
    end
    else
    begin
      gdiDataPath.AddLine((nIndex + 5),
                          small,
                          (nIndex + 5),
                          big);

      last := big;
    end;
  end;

  gdiGraphics.DrawPath(gdiSolidPen, gdiDataPath);

  //////////////////////////////////////////////////////////////////////////////
  // Draw position line
  if m_dPosition > 0 then

    gdiGraphics.SetSmoothingMode(SmoothingModeNone);
    gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

    gdiSolidPen.SetWidth(1);
    gdiSolidPen.SetColor(MakeColor(255, 100, 255, 255));

    nPos := Trunc(m_dPosition * (ClientWidth - 10)) + 5;

    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    gdiSolidPen.SetColor(MakeColor(100, 100, 255, 255));
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    gdiSolidPen.SetColor(MakeColor(50, 100, 255, 255));
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    gdiSolidPen.SetColor(MakeColor(30, 100, 255, 255));
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    gdiSolidPen.SetColor(MakeColor(10, 100, 255, 255));
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    gdiGraphics.DrawLine(gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

  //////////////////////////////////////////////////////////////////////////////
  // Draw titlebar and border
  gdiBrush.SetColor(MakeColor(100, 50, 50, 50));
  gdiGraphics.FillRectangle(gdiBrush, 0, 0, ClientWidth, 18);
  gdiSolidPen.SetColor(nColor);
  gdiSolidPen.SetWidth(1);
  gdiGraphics.DrawRectangle(gdiSolidPen, 0, 0, ClientWidth-1, ClientHeight-1);

  //////////////////////////////////////////////////////////////////////////////
  // Draw text
  if m_strText <> '' then
  begin
    gdiFont := TGPFont.Create('Tahoma', 8, FontStyleRegular);

    pntText.X := 3;
    pntText.Y := 3;

    gdiBrush.SetColor(MakeColor(255, 255, 255, 255));
    gdiGraphics.DrawString(m_strText, -1, gdiFont, pntText, gdiBrush);

    gdiFont.Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Free objects
  gdiDataPath.Free;
  gdiGraphics.Free;
  gdiSolidPen.Free;
  gdiBrush.Free;

  //////////////////////////////////////////////////////////////////////////////
  // Draw result to canvas
  Canvas.Draw(0, 0, bmpResult);
  bmpResult.Free;
end;

//==============================================================================
procedure TAcrylicTrack.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msNone;
  Repaint;
end;

//==============================================================================
procedure TAcrylicTrack.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  m_msMouseState := msClicked;
  Repaint;
end;

//==============================================================================
procedure TAcrylicTrack.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  //
end;

//==============================================================================
procedure TAcrylicTrack.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  // Do nothing to prevent flicker
end;

//==============================================================================
procedure TAcrylicTrack.CMMouseEnter(var Message: TMessage);
begin
  m_msMouseState := msHover;
  Invalidate;
end;

//==============================================================================
procedure TAcrylicTrack.CMMouseLeave(var Message: TMessage);
begin
  m_msMouseState := msNone;
  Invalidate;
end;

end.


