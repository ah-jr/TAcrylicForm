unit AcrylicUtilsU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.UITypes,
  System.SysUtils,
  VCL.Graphics,
  Vcl.Controls,
  Math,
  GDIPAPI,
  AcrylicControlU;

  function  BoolToInt(a_bBool : Boolean) : Integer;
  function  ToAlphaColor(a_clColor : TColor) : TAlphaColor;
  function  ToColor(a_clColor : TAlphaColor) : TColor;
  function  GdiColor(a_clColor : TAlphaColor) : Cardinal; overload;
  function  GdiColor(a_clColor : TColor) : Cardinal; overload;
  function  GdiColor(a_clColor : TColor; a_nAlpha : Byte) : Cardinal; overload;
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

var
  // Blur state can be accessed globally via this variable
  g_bWithBlur : Boolean = False;

implementation

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
  Child: TControl;
begin
  for nIndex := 0 to Parent.ControlCount - 1 do
  begin
    Child := Parent.Controls[nIndex];

    if Child is TAcrylicControl then
      (Child as TAcrylicControl).Refresh(True);

    if Child is TWinControl then
      RefreshAcrylicControls(TWinControl(Child));
  end;
end;

//==============================================================================
function SupportBlur: Boolean;
begin
  Result := TOSVersion.Name = 'Windows 10';
end;

end.
