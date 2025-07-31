unit GR32_Backends_VCL;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1 or LGPL 2.1 with linking exception
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Alternatively, the contents of this file may be used under the terms of the
 * Free Pascal modified version of the GNU Lesser General Public License
 * Version 2.1 (the "FPC modified LGPL License"), in which case the provisions
 * of this license are applicable instead of those above.
 * Please see the file LICENSE.txt for additional information concerning this
 * license.
 *
 * The Original Code is Backend Extension for Graphics32
 *
 * The Initial Developer of the Original Code is
 * Andre Beckedorf - metaException
 * Andre@metaException.de
 *
 * Portions created by the Initial Developer are Copyright (C) 2007-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$include GR32.inc}

uses
  System.SysUtils, System.Classes,
  WinAPI.Windows,
  VCL.Graphics, VCL.Controls,

  GR32,
  GR32_Backends,
  GR32_Backends_Generic,
  GR32.Text.Types,
  GR32_Containers,
  GR32_Paths;

type
  { TGDIBackend }
  { This backend is the default backend on Windows.
    It uses the GDI to manage and provide the buffer and additional
    graphics sub system features. The backing buffer is kept in memory. }

  TGDIBackend = class(TCustomBackend,
      IPaintSupport,
      IBitmapContextSupport,
      IDeviceContextSupport,
      ITextSupport,
      IFontSupport,
      ICanvasSupport,
      ITextToPathSupport,
      ITextToPathSupport2,
      IUpdateRectSupport
    )
  private
    procedure FontChangedHandler(Sender: TObject);
    procedure CanvasChangedHandler(Sender: TObject);
    procedure CanvasChanged;
    procedure FontChanged;
  protected
    FBitmapInfo: TBitmapInfo;
    FBitmapHandle: HBITMAP;
    FHDC: HDC;
    FFont: TFont;
    FCanvas: TCanvas;
    FFontHandle: HFont;
    FMapHandle: THandle;

    FOnFontChange: TNotifyEvent;
    FOnCanvasChange: TNotifyEvent;

    procedure InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean); override;
    procedure FinalizeSurface; override;

    procedure PrepareFileMapping(NewWidth, NewHeight: Integer); virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Changed; override;

    function Empty: Boolean; override;
  public
    { IPaintSupport }
    procedure ImageNeeded;
    procedure CheckPixmap;
    procedure DoPaint(ABuffer: TBitmap32; AInvalidRects: TRectList; ACanvas: TCanvas); overload;
    procedure DoPaint(ABuffer: TBitmap32; const AInvalidRect: TRect; ACanvas: TCanvas); overload;

    { IBitmapContextSupport }
    function GetBitmapInfo: TBitmapInfo;
    function GetBitmapHandle: THandle;

    property BitmapInfo: TBitmapInfo read GetBitmapInfo;
    property BitmapHandle: THandle read GetBitmapHandle;

    { IDeviceContextSupport }
    function GetHandle: HDC;

    procedure Draw(const DstRect, SrcRect: TRect; hSrc: HDC); overload;
    procedure DrawTo(hDst: HDC; DstX, DstY: Integer); overload;
    procedure DrawTo(hDst: HDC; const DstRect, SrcRect: TRect); overload;

    property Handle: HDC read GetHandle;

    { ITextSupport }
    procedure Textout(X, Y: Integer; const Text: string); overload;
    procedure Textout(X, Y: Integer; const ClipRect: TRect; const Text: string); overload;
    procedure Textout(var DstRect: TRect; const Flags: Cardinal; const Text: string); overload;
    function  TextExtent(const Text: string): TSize;

    { IFontSupport }
    function GetOnFontChange: TNotifyEvent;
    procedure SetOnFontChange(Handler: TNotifyEvent);
    function GetFont: TFont;
    procedure SetFont(const Font: TFont);

    procedure UpdateFont;
    property Font: TFont read GetFont write SetFont;
    property OnFontChange: TNotifyEvent read FOnFontChange write FOnFontChange;

    { ITextToPathSupport }
    procedure TextToPath(Path: TCustomPath; const X, Y: TFloat; const Text: string; Flags: Cardinal = 0); overload;
    procedure TextToPath(Path: TCustomPath; const DstRect: TFloatRect; const Text: string; Flags: Cardinal); overload;
    function MeasureText(const DstRect: TFloatRect; const Text: string; Flags: Cardinal): TFloatRect; overload;

    { ITextToPathSupport2 }
    procedure TextToPath(Path: TCustomPath; const X, Y: TFloat; const Text: string; const Layout: TTextLayout); overload;
    procedure TextToPath(Path: TCustomPath; const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout); overload;
    function MeasureText(const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout): TFloatRect; overload;

    { ICanvasSupport }
    function GetCanvasChange: TNotifyEvent;
    procedure SetCanvasChange(Handler: TNotifyEvent);
    function GetCanvas: TCanvas;

    procedure DeleteCanvas;
    function CanvasAllocated: Boolean;

    property Canvas: TCanvas read GetCanvas;
    property OnCanvasChange: TNotifyEvent read GetCanvasChange write SetCanvasChange;

    { IUpdateRectSupport }
    procedure InvalidateRect(AControl: TWinControl; const ARect: TRect);
    procedure GetUpdateRects(AControl: TWinControl; AUpdateRects: TRectList; AReservedCapacity: integer; var AFullUpdate: boolean);

  end;

  { TGDIMMFBackend }
  { Same as TGDIBackend but relies on memory mapped files or mapped swap space
    for the backing buffer. }

  TGDIMMFBackend = class(TGDIBackend)
  private
    FMapFileHandle: THandle;
    FMapIsTemporary: Boolean;
    FMapFileName: string;
  protected
    procedure PrepareFileMapping(NewWidth, NewHeight: Integer); override;
  public
    constructor Create(Owner: TBitmap32; IsTemporary: Boolean = True; const MapFileName: string = ''); virtual;
    destructor Destroy; override;
  end;

  { TGDIMemoryBackend }
  { A backend that keeps the backing buffer entirely in memory and offers
    IPaintSupport without allocating a GDI handle }

  TGDIMemoryBackend = class(TMemoryBackend, IPaintSupport, IDeviceContextSupport)
  private
    procedure DoPaintRect(ABuffer: TBitmap32; ARect: TRect; ACanvas: TCanvas);

    function GetHandle: HDC; // Dummy
  protected
    FBitmapInfo: TBitmapInfo;

    procedure InitializeSurface(NewWidth: Integer; NewHeight: Integer;
      ClearBuffer: Boolean); override;
  public
    constructor Create; override;

    { IPaintSupport }
    procedure ImageNeeded;
    procedure CheckPixmap;
    procedure DoPaint(ABuffer: TBitmap32; AInvalidRects: TRectList; ACanvas: TCanvas); overload;
    procedure DoPaint(ABuffer: TBitmap32; const AInvalidRect: TRect; ACanvas: TCanvas); overload;

    { IDeviceContextSupport }
    procedure Draw(const DstRect, SrcRect: TRect; hSrc: HDC); overload;
    procedure DrawTo(hDst: HDC; DstX, DstY: Integer); overload;
    procedure DrawTo(hDst: HDC; const DstRect, SrcRect: TRect); overload;
  end;

implementation

uses
  System.Math,
  System.Types,
  GR32.Text.Win;

var
  StockFont: HFONT;

{ TGDIBackend }

constructor TGDIBackend.Create;
begin
  inherited;

  FBitmapInfo := Default(TBitmapInfo);
  FBitmapInfo.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  FBitmapInfo.bmiHeader.biPlanes := 1;
  FBitmapInfo.bmiHeader.biBitCount := 32;
  FBitmapInfo.bmiHeader.biCompression := BI_RGB;

  FMapHandle := 0;

  FFont := TFont.Create;
  FFont.OnChange := FontChangedHandler;
  FFont.OwnerCriticalSection := @FLock;
end;

destructor TGDIBackend.Destroy;
begin
  DeleteCanvas;
  FFont.Free;

  inherited;
end;

procedure TGDIBackend.InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean);
begin
  FBitmapInfo.bmiHeader.biWidth := NewWidth;
  FBitmapInfo.bmiHeader.biHeight := -NewHeight; // Bottom-up DIB
  FBitmapInfo.bmiHeader.biSizeImage := NewWidth * NewHeight * SizeOf(SizeOf(TRGBQuad));

  PrepareFileMapping(NewWidth, NewHeight);

  FBitmapHandle := CreateDIBSection(0, FBitmapInfo, DIB_RGB_COLORS, Pointer(FBits), FMapHandle, 0);

  if FBits = nil then
    raise EBackend.Create(RCStrCannotAllocateDIBHandle);

  FHDC := CreateCompatibleDC(0);
  if FHDC = 0 then
  begin
    DeleteObject(FBitmapHandle);
    FBitmapHandle := 0;
    FBits := nil;
    raise EBackend.Create(RCStrCannotCreateCompatibleDC);
  end;

  if SelectObject(FHDC, FBitmapHandle) = 0 then
  begin
    DeleteDC(FHDC);
    DeleteObject(FBitmapHandle);
    FHDC := 0;
    FBitmapHandle := 0;
    FBits := nil;
    raise EBackend.Create(RCStrCannotSelectAnObjectIntoDC);
  end;
end;

function TGDIBackend.MeasureText(const DstRect: TFloatRect; const Text: string; Flags: Cardinal): TFloatRect;
begin
  Result := TextToolsWin.MeasureText(FFont.Handle, DstRect, Text, Flags);
end;

procedure TGDIBackend.FinalizeSurface;
begin
  if FHDC <> 0 then
    DeleteDC(FHDC);
  FHDC := 0;

  if FBitmapHandle <> 0 then
    DeleteObject(FBitmapHandle);
  FBitmapHandle := 0;

  FBits := nil;
end;

procedure TGDIBackend.DeleteCanvas;
begin
  if (FCanvas <> nil) then
  begin
    FCanvas.Handle := 0;
    FCanvas.Free;
    FCanvas := nil;
  end;
end;

procedure TGDIBackend.PrepareFileMapping(NewWidth, NewHeight: Integer);
begin
  // to be implemented by descendants
end;

procedure TGDIBackend.Changed;
begin
  if FCanvas <> nil then
    FCanvas.Handle := Self.Handle;

  inherited;
end;

procedure TGDIBackend.CanvasChanged;
begin
  if Assigned(FOnCanvasChange) then
    FOnCanvasChange(Self);
end;

procedure TGDIBackend.FontChanged;
begin
  if Assigned(FOnFontChange) then
    FOnFontChange(Self);
end;

function TGDIBackend.TextExtent(const Text: string): TSize;
var
  DC: HDC;
  OldFont: HGDIOBJ;
begin
  UpdateFont;
  Result.cX := 0;
  Result.cY := 0;
  if Handle <> 0 then
    WinAPI.Windows.GetTextExtentPoint32(Handle, PChar(Text), Length(Text), Result)
  else
  begin
    StockBitmap.Canvas.Lock;
    try
      DC := StockBitmap.Canvas.Handle;
      OldFont := SelectObject(DC, Font.Handle);
      WinAPI.Windows.GetTextExtentPoint32(DC, PChar(Text), Length(Text), Result);
      SelectObject(DC, OldFont);
    finally
      StockBitmap.Canvas.Unlock;
    end;
  end;
end;

procedure TGDIBackend.Textout(X, Y: Integer; const Text: string);
var
  Extent: TSize;
  ClipRect: TRect;
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
  begin
    if FOwner.Clipping then
    begin
      ClipRect := FOwner.ClipRect;
      ExtTextOut(Handle, X, Y, ETO_CLIPPED, @ClipRect, PChar(Text), Length(Text), nil);
    end else
      ExtTextOut(Handle, X, Y, 0, nil, PChar(Text), Length(Text), nil);
  end;

  Extent := TextExtent(Text);
  FOwner.Changed(MakeRect(X, Y, X + Extent.cx + 1, Y + Extent.cy + 1));
end;

procedure TGDIBackend.Textout(X, Y: Integer; const ClipRect: TRect; const Text: string);
var
  Extent: TSize;
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
    ExtTextOut(Handle, X, Y, ETO_CLIPPED, @ClipRect, PChar(Text), Length(Text), nil);

  Extent := TextExtent(Text);
  FOwner.Changed(MakeRect(X, Y, X + Extent.cx + 1, Y + Extent.cy + 1));
end;

procedure TGDIBackend.TextToPath(Path: TCustomPath; const X, Y: TFloat; const Text: string; Flags: Cardinal);
var
  R: TFloatRect;
begin
  R := FloatRect(X, Y, X, Y);
  TextToolsWin.TextToPath(FFont.Handle, Path, R, Text, Flags);
end;

procedure TGDIBackend.TextToPath(Path: TCustomPath; const DstRect: TFloatRect; const Text: string; Flags: Cardinal);
begin
  TextToolsWin.TextToPath(FFont.Handle, Path, DstRect, Text, Flags);
end;

procedure TGDIBackend.TextToPath(Path: TCustomPath; const X, Y: TFloat; const Text: string; const Layout: TTextLayout);
var
  R: TFloatRect;
begin
  R := FloatRect(X, Y, X, Y);
  TextToolsWin.TextToPath(FFont.Handle, Path, R, Text, Layout);
end;

procedure TGDIBackend.TextToPath(Path: TCustomPath; const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout);
begin
  TextToolsWin.TextToPath(FFont.Handle, Path, DstRect, Text, Layout);
end;

function TGDIBackend.MeasureText(const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout): TFloatRect;
begin
  TextToolsWin.MeasureText(FFont.Handle, DstRect, Text, Layout);
end;


procedure TGDIBackend.UpdateFont;
begin
  if (FFontHandle = 0) and (Handle <> 0) then
  begin
    SelectObject(Handle, Font.Handle);
    SetTextColor(Handle, ColorToRGB(Font.Color));
    SetBkMode(Handle, WinAPI.Windows.TRANSPARENT);
    FFontHandle := Font.Handle;
  end
  else
  begin
    SelectObject(Handle, FFontHandle);
    SetTextColor(Handle, ColorToRGB(Font.Color));
    SetBkMode(Handle, WinAPI.Windows.TRANSPARENT);
  end;
end;

procedure TGDIBackend.Textout(var DstRect: TRect; const Flags: Cardinal; const Text: string);
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
    DrawText(Handle, PChar(Text), Length(Text), DstRect, Flags);

  FOwner.Changed(DstRect);
end;

procedure TGDIBackend.DrawTo(hDst: HDC; DstX, DstY: Integer);
begin
  StretchDIBits(
    hDst, DstX, DstY, FOwner.Width, FOwner.Height,
    0, 0, FOwner.Width, FOwner.Height, Bits, FBitmapInfo, DIB_RGB_COLORS, SRCCOPY);
end;

procedure TGDIBackend.DrawTo(hDst: HDC; const DstRect, SrcRect: TRect);
begin
  StretchBlt(
    hDst,
    DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top, Handle,
    SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);
end;

function TGDIBackend.GetBitmapHandle: THandle;
begin
  Result := FBitmapHandle;
end;

function TGDIBackend.GetBitmapInfo: TBitmapInfo;
begin
  Result := FBitmapInfo;
end;

function TGDIBackend.GetCanvas: TCanvas;
begin
  if (FCanvas = nil) then
  begin
    FCanvas := TCanvas.Create;
    FCanvas.Handle := Handle;
    FCanvas.OnChange := CanvasChangedHandler;
  end;
  Result := FCanvas;
end;

function TGDIBackend.GetCanvasChange: TNotifyEvent;
begin
  Result := FOnCanvasChange;
end;

function TGDIBackend.GetFont: TFont;
begin
  Result := FFont;
end;

function TGDIBackend.GetHandle: HDC;
begin
  Result := FHDC;
end;

function TGDIBackend.GetOnFontChange: TNotifyEvent;
begin
  Result := FOnFontChange;
end;

procedure TGDIBackend.InvalidateRect(AControl: TWinControl; const ARect: TRect);
begin
  if (AControl.HandleAllocated) then
    WinAPI.Windows.InvalidateRect(AControl.Handle, @ARect, False);
end;

procedure TGDIBackend.GetUpdateRects(AControl: TWinControl; AUpdateRects: TRectList; AReservedCapacity: integer; var AFullUpdate: boolean);
var
  RegionType: integer;
  UpdateRegion: HRGN;
  RegionSize: integer;
  RegionData: PRgnData;
  r: TRect;
  i: integer;
begin
  UpdateRegion := CreateRectRgn(0,0,0,0);
  try
    RegionType := GetUpdateRgn(AControl.Handle, UpdateRegion, False);

    case RegionType of

      COMPLEXREGION:
        begin
          RegionSize := GetRegionData(UpdateRegion, 0, nil);

          if (RegionSize > 0) then
          begin
            GetMem(RegionData, RegionSize);
            try
              {$IFOPT C+} // ST: IF ASSERTIONS ON
              RegionSize :=
              {$ENDIF}
              GetRegionData(UpdateRegion, RegionSize, RegionData);
              Assert(RegionSize <> 0);

              // Final count is known so set capacity to avoid reallocation
              AUpdateRects.Capacity := Max(AUpdateRects.Capacity, AUpdateRects.Count + AReservedCapacity + integer(RegionData.rdh.nCount));

              for i := 0 to RegionData.rdh.nCount-1 do
                AUpdateRects.Add(PPolyRects(@RegionData.Buffer)[i]);
            finally
              FreeMem(RegionData);
            end;
          end;
        end;

      NULLREGION:
        AFullUpdate := True;

      SIMPLEREGION:
        begin
          GetUpdateRect(AControl.Handle, r, False);
          if (GR32.EqualRect(r, AControl.ClientRect)) then
            AFullUpdate := True
          else
          begin
            AUpdateRects.Capacity := Max(AUpdateRects.Capacity, AUpdateRects.Count + AReservedCapacity + 1);
            AUpdateRects.Add(r);
          end;
        end

    else
      // Error - Ignore it
      AFullUpdate := True
    end;
  finally
    DeleteObject(UpdateRegion);
  end;
end;

procedure TGDIBackend.SetCanvasChange(Handler: TNotifyEvent);
begin
  FOnCanvasChange := Handler;
end;

procedure TGDIBackend.SetFont(const Font: TFont);
begin
  FFont.Assign(Font);
  FontChanged;
end;

procedure TGDIBackend.SetOnFontChange(Handler: TNotifyEvent);
begin
  FOnFontChange := Handler;
end;

procedure TGDIBackend.Draw(const DstRect, SrcRect: TRect; hSrc: HDC);
begin
  if FOwner.Empty then
    Exit;

  if not FOwner.MeasuringMode then
    StretchBlt(Handle, DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left,
      DstRect.Bottom - DstRect.Top, hSrc, SrcRect.Left, SrcRect.Top,
      SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);

  FOwner.Changed(DstRect);
end;

function TGDIBackend.CanvasAllocated: Boolean;
begin
  Result := Assigned(FCanvas);
end;

function TGDIBackend.Empty: Boolean;
begin
  Result := FBitmapHandle = 0;
end;

procedure TGDIBackend.FontChangedHandler(Sender: TObject);
begin
  if FFontHandle <> 0 then
  begin
    if Handle <> 0 then
      SelectObject(Handle, StockFont);
    FFontHandle := 0;
  end;

  FontChanged;
end;

procedure TGDIBackend.CanvasChangedHandler(Sender: TObject);
begin
  CanvasChanged;
end;

{ IPaintSupport }

procedure TGDIBackend.ImageNeeded;
begin

end;

procedure TGDIBackend.CheckPixmap;
begin

end;

procedure TGDIBackend.DoPaint(ABuffer: TBitmap32; AInvalidRects: TRectList; ACanvas: TCanvas);
var
  i: Integer;
  CanvasHandle: HDC;
  BufferHandle: HDC;
begin
  CanvasHandle := ACanvas.Handle;
  BufferHandle := ABuffer.Handle;
  for i := 0 to AInvalidRects.Count - 1 do
    with AInvalidRects[i]^ do
      BitBlt(CanvasHandle, Left, Top, Right - Left, Bottom - Top, BufferHandle, Left, Top, SRCCOPY);
end;

procedure TGDIBackend.DoPaint(ABuffer: TBitmap32; const AInvalidRect: TRect; ACanvas: TCanvas);
begin
  BitBlt(ACanvas.Handle, AInvalidRect.Left, AInvalidRect.Top, AInvalidRect.Width, AInvalidRect.Height,
    ABuffer.Handle, AInvalidRect.Left, AInvalidRect.Top, SRCCOPY);
end;


{ TGDIMMFBackend }

constructor TGDIMMFBackend.Create(Owner: TBitmap32; IsTemporary: Boolean = True; const MapFileName: string = '');
begin
  FMapFileName := MapFileName;
  FMapIsTemporary := IsTemporary;
  TMMFBackend.InitializeFileMapping(FMapHandle, FMapFileHandle, FMapFileName);
  inherited Create(Owner);
end;

destructor TGDIMMFBackend.Destroy;
begin
  TMMFBackend.DeinitializeFileMapping(FMapHandle, FMapFileHandle, FMapFileName);
  inherited;
end;

procedure TGDIMMFBackend.PrepareFileMapping(NewWidth, NewHeight: Integer);
begin
  TMMFBackend.CreateFileMapping(FMapHandle, FMapFileHandle, FMapFileName, FMapIsTemporary, NewWidth, NewHeight);
end;


{ TGDIMemoryBackend }

constructor TGDIMemoryBackend.Create;
begin
  inherited;

  FBitmapInfo := Default(TBitmapInfo);

  FBitmapInfo.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  FBitmapInfo.bmiHeader.biPlanes := 1;
  FBitmapInfo.bmiHeader.biBitCount := 32;
  FBitmapInfo.bmiHeader.biCompression := BI_RGB;
  FBitmapInfo.bmiHeader.biXPelsPerMeter := 96;
  FBitmapInfo.bmiHeader.biYPelsPerMeter := 96;
end;

procedure TGDIMemoryBackend.InitializeSurface(NewWidth, NewHeight: Integer;
  ClearBuffer: Boolean);
begin
  inherited;

  FBitmapInfo.bmiHeader.biWidth := NewWidth;
  FBitmapInfo.bmiHeader.biHeight := -NewHeight; // Bottom-up DIB
end;

procedure TGDIMemoryBackend.ImageNeeded;
begin

end;

procedure TGDIMemoryBackend.CheckPixmap;
begin

end;

procedure TGDIMemoryBackend.DoPaint(ABuffer: TBitmap32; AInvalidRects: TRectList; ACanvas: TCanvas);
var
  i : Integer;
begin
  for i := 0 to AInvalidRects.Count - 1 do
    DoPaintRect(ABuffer, AInvalidRects[i]^, ACanvas);
end;

procedure TGDIMemoryBackend.DoPaint(ABuffer: TBitmap32; const AInvalidRect: TRect; ACanvas: TCanvas);
begin
  DoPaintRect(ABuffer, AInvalidRect, ACanvas);
end;


procedure TGDIMemoryBackend.DoPaintRect(ABuffer: TBitmap32; ARect: TRect; ACanvas: TCanvas);
var
  Bitmap        : HBITMAP;
  DeviceContext : HDC;
  Buffer        : Pointer;
  OldObject     : HGDIOBJ;
begin
  if SetDIBitsToDevice(ACanvas.Handle, ARect.Left, ARect.Top, ARect.Right -
    ARect.Left, ARect.Bottom - ARect.Top, ARect.Left, ARect.Top, 0,
    ARect.Bottom - ARect.Top, ABuffer.Bits, FBitmapInfo, DIB_RGB_COLORS) <> 0 then
    exit;

  // create compatible device context
  DeviceContext := CreateCompatibleDC(ACanvas.Handle);

  if DeviceContext = 0 then
    exit;
  try

    Bitmap := CreateDIBSection(DeviceContext, FBitmapInfo, DIB_RGB_COLORS, Buffer, 0, 0);

    if Bitmap = 0 then
      raise EBackend.Create(RCStrCannotCreateCompatibleDC);

    OldObject := SelectObject(DeviceContext, Bitmap);
    try

      Move(ABuffer.Bits^, Buffer^, FBitmapInfo.bmiHeader.biWidth * FBitmapInfo.bmiHeader.biHeight * SizeOf(SizeOf(TRGBQuad)));
      BitBlt(ACanvas.Handle, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, DeviceContext, 0, 0, SRCCOPY);

    finally
      if OldObject <> 0 then
        SelectObject(DeviceContext, OldObject);
      DeleteObject(Bitmap);
    end;

  finally
    DeleteDC(DeviceContext);
  end;
end;

procedure TGDIMemoryBackend.Draw(const DstRect, SrcRect: TRect; hSrc: HDC);
begin
  if FOwner.Empty then Exit;

  if not FOwner.MeasuringMode then
    raise EBackend.Create('Not supported!');

  FOwner.Changed(DstRect);
end;

procedure TGDIMemoryBackend.DrawTo(hDst: HDC; DstX, DstY: Integer);
var
  Bitmap        : HBITMAP;
  DeviceContext : HDC;
  Buffer        : Pointer;
  OldObject     : HGDIOBJ;
begin
  if SetDIBitsToDevice(hDst, DstX, DstY, FOwner.Width, FOwner.Height, 0, 0, 0,
    FOwner.Height, FBits, FBitmapInfo, DIB_RGB_COLORS) <> 0 then
    exit;

  // create compatible device context
  DeviceContext := CreateCompatibleDC(hDst);
  if DeviceContext = 0 then
    exit;
  try
    Bitmap := CreateDIBSection(DeviceContext, FBitmapInfo, DIB_RGB_COLORS, Buffer, 0, 0);

    if Bitmap = 0 then
      raise EBackend.Create(RCStrCannotCreateCompatibleDC);

    OldObject := SelectObject(DeviceContext, Bitmap);
    try

      Move(FBits^, Buffer^, FBitmapInfo.bmiHeader.biWidth * FBitmapInfo.bmiHeader.biHeight * SizeOf(TRGBQuad));
      BitBlt(hDst, DstX, DstY, FOwner.Width, FOwner.Height, DeviceContext, 0, 0, SRCCOPY);

    finally
      if OldObject <> 0 then
        SelectObject(DeviceContext, OldObject);
      DeleteObject(Bitmap);
    end;

  finally
    DeleteDC(DeviceContext);
  end;
end;

procedure TGDIMemoryBackend.DrawTo(hDst: HDC;
  const DstRect, SrcRect: TRect);
var
  Bitmap        : HBITMAP;
  DeviceContext : HDC;
  Buffer        : Pointer;
  OldObject     : HGDIOBJ;
begin
  if SetDIBitsToDevice(hDst, DstRect.Left, DstRect.Top,
    DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top, SrcRect.Left,
    SrcRect.Top, 0, SrcRect.Bottom - SrcRect.Top, FBits, FBitmapInfo,
    DIB_RGB_COLORS) <> 0 then
    exit;

  // create compatible device context
  DeviceContext := CreateCompatibleDC(hDst);
  if DeviceContext = 0 then
    raise EBackend.Create(RCStrCannotCreateCompatibleDC);
  try
    Bitmap := CreateDIBSection(DeviceContext, FBitmapInfo, DIB_RGB_COLORS, Buffer, 0, 0);

    if Bitmap = 0 then
      exit;

    OldObject := SelectObject(DeviceContext, Bitmap);
    try

      Move(FBits^, Buffer^, FBitmapInfo.bmiHeader.biWidth * FBitmapInfo.bmiHeader.biHeight * SizeOf(TRGBQuad));
      BitBlt(hDst, DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top, DeviceContext, 0, 0, SRCCOPY);

    finally
      if OldObject <> 0 then
        SelectObject(DeviceContext, OldObject);
      DeleteObject(Bitmap);
    end;

  finally
    DeleteDC(DeviceContext);
  end;
end;

function TGDIMemoryBackend.GetHandle: HDC;
begin
  Result := 0;
end;

initialization
  StockFont := GetStockObject(SYSTEM_FONT);

finalization

end.
