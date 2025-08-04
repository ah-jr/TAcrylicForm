unit AcrylicUtilsU;

interface

uses
  System.UITypes,
  Vcl.Controls;

function  BoolToInt   (a_bBool   : Boolean)                 : Integer;
function  ToAlphaColor(a_clColor : TColor)                  : TAlphaColor;
function  ToColor     (a_clColor : TAlphaColor)             : TColor;
function  ARGBtoABGR  (a_clColor: TAlphaColor)              : Cardinal;
function  GdiColor    (a_clColor : TAlphaColor)             : Cardinal; overload;
function  GdiColor    (a_clColor : TColor)                  : Cardinal; overload;
function  GdiColor    (a_clColor : TColor; a_nAlpha : Byte) : Cardinal; overload;

function  GdiChangeColor(a_clColor   : TAlphaColor;
                         a_byteAlpha : SmallInt = 0;
                         a_byteRed   : SmallInt = 0;
                         a_byteGreen : SmallInt = 0;
                         a_byteBlue  : SmallInt = 0) : Cardinal;

function  ChangeColor(a_clColor   : TAlphaColor;
                      a_byteAlpha : SmallInt = 0;
                      a_byteRed   : SmallInt = 0;
                      a_byteGreen : SmallInt = 0;
                      a_byteBlue  : SmallInt = 0) : TAlphaColor;

procedure RefreshAcrylicControls(Parent: TWinControl);
function  SupportBlur: Boolean;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  Math,
  GDIPAPI,
  AcrylicControlU;

//==============================================================================
function BoolToInt(a_bBool : Boolean) : Integer;
begin
  if a_bBool then
    Result := 1
  else
    Result := 0;
end;

//==============================================================================
function ToAlphaColor(a_clColor : TColor) : TAlphaColor;
begin
  Result := MakeColor(255,
                      GetRed  (a_clColor),
                      GetGreen(a_clColor),
                      GetBlue (a_clColor));
end;

//==============================================================================
function ToColor(a_clColor : TAlphaColor) : TColor;
begin
  Result := RGB(GetRed  (a_clColor),
                GetGreen(a_clColor),
                GetBlue (a_clColor));
end;

//==============================================================================
function ARGBtoABGR(a_clColor: TAlphaColor): Cardinal;
var
  bA, bR, bG, bB: Byte;
begin
  bA := (a_clColor shr 24) and $FF;
  bR := (a_clColor shr 16) and $FF;
  bG := (a_clColor shr 8)  and $FF;
  bB :=  a_clColor and $FF;

  Result := (bA shl 24) or (bB shl 16) or (bG shl 8) or bR;
end;

//==============================================================================
function GdiColor(a_clColor : TAlphaColor) : Cardinal;
begin
  Result := MakeColor(GetAlpha(a_clColor),
                      GetRed  (a_clColor),
                      GetGreen(a_clColor),
                      GetBlue (a_clColor));
end;

//==============================================================================
function GdiColor(a_clColor : TColor): Cardinal;
begin
  Result := MakeColor(255,
                      GetRed  (a_clColor),
                      GetGreen(a_clColor),
                      GetBlue (a_clColor));
end;

//==============================================================================
function GdiColor(a_clColor : TColor; a_nAlpha : Byte): Cardinal;
begin
  Result := MakeColor(a_nAlpha,
                      GetRed  (a_clColor),
                      GetGreen(a_clColor),
                      GetBlue (a_clColor));
end;

//==============================================================================
function GdiChangeColor(a_clColor   : TAlphaColor;
                        a_byteAlpha : SmallInt = 0;
                        a_byteRed   : SmallInt = 0;
                        a_byteGreen : SmallInt = 0;
                        a_byteBlue  : SmallInt = 0) : Cardinal;
begin
  Result := MakeColor(Min(Max(GetAlpha(a_clColor) + a_byteAlpha, 0), 255),
                      Min(Max(GetRed  (a_clColor) + a_byteRed,   0), 255),
                      Min(Max(GetGreen(a_clColor) + a_byteGreen, 0), 255),
                      Min(Max(GetBlue (a_clColor) + a_byteBlue,  0), 255));
end;

//==============================================================================
function ChangeColor(a_clColor   : TAlphaColor;
                     a_byteAlpha : SmallInt = 0;
                     a_byteRed   : SmallInt = 0;
                     a_byteGreen : SmallInt = 0;
                     a_byteBlue  : SmallInt = 0) : TAlphaColor;
begin
  Result := MakeColor(Min(Max(GetAlpha(a_clColor) + a_byteAlpha, 0), 255),
                      Min(Max(GetRed  (a_clColor) + a_byteRed,   0), 255),
                      Min(Max(GetGreen(a_clColor) + a_byteGreen, 0), 255),
                      Min(Max(GetBlue (a_clColor) + a_byteBlue,  0), 255));
end;

//==============================================================================
procedure RefreshAcrylicControls(Parent: TWinControl);
var
  nIndex: Integer;
  cChild: TControl;
begin
  for nIndex := 0 to Parent.ControlCount - 1 do
  begin
    cChild := Parent.Controls[nIndex];

    if cChild is TAcrylicControl then
      (cChild as TAcrylicControl).Refresh(True);

    if cChild is TWinControl then
      RefreshAcrylicControls(TWinControl(cChild));
  end;
end;

//==============================================================================
function SupportBlur: Boolean;
begin
  Result := (TOSVersion.Name = 'Windows 10') or (TOSVersion.Name = 'Windows 11');
end;

end.
