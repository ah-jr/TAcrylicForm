unit AcrylicUtilsU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.UITypes,
  VCL.Graphics,
  Math,
  GDIPAPI;

  function BoolToInt(a_bBool : Boolean) : Integer;
  function GdiColor(a_clColor : TAlphaColor) : Cardinal;
  function GdiChangeColor(a_clColor : TAlphaColor; a_byteAlpha, a_byteRed, a_byteGreen, a_byteBlue : Byte) : Cardinal;

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
function GdiColor(a_clColor : TAlphaColor) : Cardinal;
begin
  Result := MakeColor(GetAlpha(a_clColor),
                      GetRed  (a_clColor),
                      GetGreen(a_clColor),
                      GetBlue (a_clColor));
end;

//==============================================================================
function GdiChangeColor(a_clColor : TAlphaColor; a_byteAlpha, a_byteRed, a_byteGreen, a_byteBlue : Byte) : Cardinal;
begin
  Result := MakeColor(Min(Max(GetAlpha(a_clColor) + a_byteAlpha, 0), 255),
                      Min(Max(GetRed  (a_clColor) + a_byteRed,   0), 255),
                      Min(Max(GetGreen(a_clColor) + a_byteGreen, 0), 255),
                      Min(Max(GetBlue (a_clColor) + a_byteBlue,  0), 255));
end;

end.
