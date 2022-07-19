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
  AcrylicTypesU,
  AcrylicControlU;

type

  TAcrylicTrack = Class(TAcrylicControl)
  private
    m_arrData      : TSingleArray;
    m_dPosition    : Double;

    procedure SetPosition (a_dPos : Double);
    function  IsPosInRange(a_dPos : Double) : Boolean;

  protected
    procedure PaintComponent; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure SetData(a_pData : PIntArray; a_nSize : Integer);

  published
    property Position : Double read m_dPosition write SetPosition;

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

  m_dPosition    := -1;
end;

//==============================================================================
destructor TAcrylicTrack.Destroy;
begin
  inherited;
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
procedure TAcrylicTrack.PaintComponent;
var
  gdiDataPath  : TGPGraphicsPath;
  gdiFont      : TGPFont;
  pntText      : TGPPointF;
  nColor       : Cardinal;
  nIndex       : Integer;

  small, big, last : Single;
  switch : boolean;
  amplitude : Integer;
  offset:Integer;
  nPos    : Integer;
begin
  //////////////////////////////////////////////////////////////////////////////
  // Setup color and create GDIP objects
  case m_msMouseState of
    msNone    : nColor := MakeColor(100, 0, 0, 0);
    msClicked : nColor := MakeColor(100, 30, 30, 30);
    msHover   : nColor := MakeColor(100, 15, 15, 15);
    else        nColor := MakeColor(100, 0, 0, 0);
  end;

  m_gdiSolidPen.SetColor(nColor);
  m_gdiBrush.SetColor(nColor);

  //////////////////////////////////////////////////////////////////////////////
  // Draw background
  m_gdiGraphics.FillRectangle(m_gdiBrush, 0, 0, ClientWidth, ClientHeight);

  //////////////////////////////////////////////////////////////////////////////
  // Draw data
  m_gdiGraphics.SetSmoothingMode(SmoothingModeHighQuality);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);

  m_gdiSolidPen.SetColor(MakeColor(255, 160, 180, 190));
  m_gdiSolidPen.SetWidth(1);

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

  m_gdiGraphics.DrawPath(m_gdiSolidPen, gdiDataPath);

  //////////////////////////////////////////////////////////////////////////////
  // Draw position line
  if m_dPosition >= 0 then
  begin
    m_gdiGraphics.SetSmoothingMode(SmoothingModeNone);
    m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);

    m_gdiSolidPen.SetWidth(1);
    m_gdiSolidPen.SetColor(MakeColor(255, 100, 255, 255));

    nPos := Trunc(m_dPosition * (ClientWidth - 10)) + 5;

    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    m_gdiSolidPen.SetColor(MakeColor(100, 100, 255, 255));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    m_gdiSolidPen.SetColor(MakeColor(50, 100, 255, 255));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    m_gdiSolidPen.SetColor(MakeColor(30, 100, 255, 255));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);

    dec(nPos);
    m_gdiSolidPen.SetColor(MakeColor(10, 100, 255, 255));
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
    m_gdiGraphics.DrawLine(m_gdiSolidPen, nPos, 18, nPos, ClientHeight-1);
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Draw titlebar and border
  m_gdiBrush.SetColor(MakeColor(100, 50, 50, 50));
  m_gdiGraphics.FillRectangle(m_gdiBrush, 0, 0, ClientWidth, 18);
  m_gdiSolidPen.SetColor(nColor);
  m_gdiSolidPen.SetWidth(1);
  m_gdiGraphics.DrawRectangle(m_gdiSolidPen, 0, 0, ClientWidth-1, ClientHeight-1);

  //////////////////////////////////////////////////////////////////////////////
  // Draw text
  if m_strText <> '' then
  begin
    gdiFont := TGPFont.Create(Font.Name, Font.Size, FontStyleRegular);

    pntText.X := 3;
    pntText.Y := 3;

    m_gdiBrush.SetColor(MakeColor(255, 255, 255, 255));
    m_gdiGraphics.DrawString(m_strText, -1, gdiFont, pntText, m_gdiBrush);

    gdiFont.Free;
  end;

  //////////////////////////////////////////////////////////////////////////////
  // Free objects
  gdiDataPath.Free;
end;

end.


