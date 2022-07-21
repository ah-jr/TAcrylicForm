unit AcrylicTrackU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  GDIPOBJ,
  AcrylicTypesU,
  AcrylicControlU;

type

  TAcrylicTrack = Class(TAcrylicControl)
  private
    m_dPosition       : Double;
    m_nTitleBarHeight : Integer;
    m_bmpData         : TBitmap;
    m_gdiDataPath     : TGPGraphicsPath;
    m_clLineColor     : TAlphaColor;
    m_clTitleColor    : TAlphaColor;
    m_clDataColor     : TAlphaColor;

    procedure SetPosition (a_dPos : Double);
    function  IsPosInRange(a_dPos : Double) : Boolean;

  protected
    procedure PaintComponent; override;
    procedure DrawData;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure SetData(a_pData : PIntArray; a_nSize : Integer);

  published
    property Position       : Double      read m_dPosition       write SetPosition;
    property TitleBarHeight : Integer     read m_nTitleBarHeight write m_nTitleBarHeight;
    property LineColor      : TAlphaColor read m_clLineColor     write m_clLineColor;
    property TitleColor     : TAlphaColor read m_clTitleColor    write m_clTitleColor;
    property DataColor      : TAlphaColor read m_clDataColor     write m_clDataColor;

  end;

  procedure Register;

const
  PATHSIZE   = 10000;
  DATAOFFSET = 5;

implementation

uses
  GDIPAPI,
  GDIPUTIL,
  Math,
  AcrylicUtilsU;

 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicTrack]);
 end;

//==============================================================================
constructor TAcrylicTrack.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  m_gdiDataPath := TGPGraphicsPath.Create;

  m_bmpData             := TBitmap.Create;
  m_bmpData.HandleType  := bmDIB;
  m_bmpData.Alphaformat := afDefined;

  m_clLineColor  := $FF64FFFF;
  m_clTitleColor := $64323232;
  m_clDataColor  := $FFA0B4BE;

  m_nTitleBarHeight := 17;
  m_dPosition       := -1;
end;

//==============================================================================
destructor TAcrylicTrack.Destroy;
begin
  m_bmpData.Free;
  m_gdiDataPath.Free;

  Inherited;
end;

//==============================================================================
procedure TAcrylicTrack.SetPosition(a_dPos : Double);
begin
  if IsPosInRange(m_dPosition) and (not IsPosInRange(a_dPos)) then
    m_bRepaint := True;

  if IsPosInRange(a_dPos) then
  begin
    m_dPosition := a_dPos;
    m_bRepaint  := True;
  end
  else
    m_dPosition := -1;
end;

//==============================================================================
function TAcrylicTrack.IsPosInRange(a_dPos : Double) : Boolean;
begin
  Result := (a_dPos >= 0) and (a_dPos < 1);
end;

//==============================================================================
procedure TAcrylicTrack.SetData(a_pData : PIntArray; a_nSize : Integer);
var
  nTrackIdx    : Integer;
  nFragIdx     : Integer;
  nMax         : Integer;
  nAverage     : Integer;
  nCurrent     : Integer;
  nAmplitude   : Integer;
  nOffset      : Integer;
  bSwitch      : Boolean;
  dTrackRatio  : Double;
  dScreenRatio : Double;
  pntPrev      : TGPPointF;
  pntCurr      : TGPPointF;
begin
  m_gdiDataPath.Reset;

  dScreenRatio := (ClientWidth - 2 * DATAOFFSET) / PATHSIZE;
  dTrackRatio  := a_nSize / PATHSIZE;
  nAmplitude   := (ClientHeight - m_nTitleBarHeight - 3) div 2;
  nOffset      := (ClientHeight + m_nTitleBarHeight) div 2;
  nMax         := 1;
  pntPrev.X    := DATAOFFSET;
  pntPrev.Y    := nOffset;
  bSwitch      := True;

  for nTrackIdx := 0 to a_nSize - 1 do
    nMax := Max(nMax, Abs(TIntArray(a_pData^)[nTrackIdx]));

  //////////////////////////////////////////////////////////////////////////////
  // Narrow down data to fit in the PATHSIZE
  for nTrackIdx := 0 to PATHSIZE - 1 do
  begin
    nFragIdx := 0;

    if bSwitch then
      nAverage :=  MaxInt
    else
      nAverage := -MaxInt;

    while nFragIdx < dTrackRatio do
    begin
      //////////////////////////////////////////////////////////////////////////
      // Get the largest value in the samples covered
      nCurrent := TIntArray(a_pData^)[Round(nTrackIdx * dTrackRatio) + nFragIdx];

      if bSwitch then
        nAverage := Min(nCurrent, nAverage)
      else
        nAverage := Max(nCurrent, nAverage);

      Inc(nFragIdx);
    end;

    pntCurr.X := nTrackIdx * dScreenRatio + DATAOFFSET;
    pntCurr.Y := nAmplitude * (nAverage/nMax) + nOffset;

    m_gdiDataPath.AddLine(pntPrev, pntCurr);

    pntPrev.X := pntCurr.X;
    pntPrev.Y := pntCurr.Y;

    bSwitch := not bSwitch;
  end;

  DrawData;
end;

//==============================================================================
procedure TAcrylicTrack.DrawData;
var
  gdiGraphics   : TGPGraphics;
  gdiSolidPen   : TGPPen;
begin
  m_bmpData.SetSize(ClientWidth,ClientHeight);
  m_bmpData.Canvas.Brush.Color := $00000000;
  m_bmpData.Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);

  //////////////////////////////////////////////////////////////////////////////
  // Draw data
  gdiGraphics := TGPGraphics.Create(m_bmpData.Canvas.Handle);
  gdiGraphics.SetSmoothingMode(SmoothingModeHighQuality);
  gdiGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);

  gdiSolidPen := TGPPen.Create(0);
  gdiSolidPen.SetLineJoin(LineJoinRound);
  gdiSolidPen.SetColor(m_clDataColor);
  gdiSolidPen.SetWidth(1.6);

  gdiGraphics.DrawPath(gdiSolidPen, m_gdiDataPath);
  gdiGraphics.Free;

  Canvas.Draw(0, 0, m_bmpPaint);
end;

//==============================================================================
procedure TAcrylicTrack.PaintComponent;
var
  nPos : Integer;
begin
  //////////////////////////////////////////////////////////////////////////////
  // Draw background
  PaintBackground;

  //////////////////////////////////////////////////////////////////////////////
  // Draw data
  m_bmpPaint.canvas.Draw(0, 0, m_bmpData);

  //////////////////////////////////////////////////////////////////////////////
  // Draw position line
  if m_dPosition >= 0 then
  begin
    m_gdiGraphics.SetSmoothingMode(SmoothingModeNone);
    m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

    m_gdiSolidPen.SetWidth(1);

    nPos := Trunc(m_dPosition * (ClientWidth - 2 * DATAOFFSET)) + DATAOFFSET;

    m_gdiSolidPen.SetColor(GdiChangeColor(m_clLineColor, 0));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos,     m_nTitleBarHeight, nPos,     ClientHeight-1);

    m_gdiSolidPen.SetColor(GdiChangeColor(m_clLineColor, -100));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos - 1, m_nTitleBarHeight, nPos - 1, ClientHeight-1);

    m_gdiSolidPen.SetColor(GdiChangeColor(m_clLineColor, -150));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos - 2, m_nTitleBarHeight, nPos - 2, ClientHeight-1);

    m_gdiSolidPen.SetColor(GdiChangeColor(m_clLineColor, -200));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos - 3, m_nTitleBarHeight, nPos - 3, ClientHeight-1);

    m_gdiSolidPen.SetColor(GdiChangeColor(m_clLineColor, -230));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos - 4, m_nTitleBarHeight, nPos - 4, ClientHeight-1);
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Draw titlebar and special border
  m_gdiBrush.SetColor(m_clTitleColor);
  m_gdiGraphics.FillRectangle(m_gdiBrush, 1, 1, ClientWidth - 2, m_nTitleBarHeight);

  if m_dPosition >= 0 then
  begin
    m_gdiSolidPen.SetColor(GdiColor(m_clLineColor));
    m_gdiSolidPen.SetWidth(1);
    m_gdiGraphics.DrawRectangle(m_gdiSolidPen, 0, 0, ClientWidth-1, ClientHeight-1);
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Draw Text
  PaintText(3, 2);
end;

end.


