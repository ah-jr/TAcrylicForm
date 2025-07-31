unit GR32_Blurs;

(* BEGIN LICENSE BLOCK *********************************************************
* Version: MPL 1.1                                                             *
*                                                                              *
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with     *
* the License. You may obtain a copy of the License at                         *
* http://www.mozilla.org/MPL/                                                  *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License     *
* for the specific language governing rights and limitations under the         *
* License.                                                                     *
*                                                                              *
* Alternatively, the contents of this file may be used under the terms of the  *
* Free Pascal modified version of the GNU Lesser General Public License        *
* Version 2.1 (the "FPC modified LGPL License"), in which case the provisions  *
* of this license are applicable instead of those above.                       *
* Please see the file LICENSE.txt for additional information concerning this   *
* license.                                                                     *
*                                                                              *
* The Original Code is GR32_Blurs. The Gaussian blur algorithm was inspired    *
* by code published by Mario Klingemann and has been used with his permission. *
* See also http://incubator.quasimondo.com                                     *
*                                                                              *
* Copyright 2012 - Angus Johnson                                               *
*                                                                              *
* Version 5.0 (Last updated 25-Sep-2012)                                       *
*                                                                              *
* END LICENSE BLOCK ***********************************************************)

interface

{$include GR32.inc}

{$message 'The functions in the GR32_Blurs unit are being deprecated in favor of the GR32.Blur unit'}

uses
  {$IFDEF FPC}
    LCLIntf,
  {$ELSE}
    Windows, Types,
  {$ENDIF}
    SysUtils, Classes, Math, GR32, GR32.Blur;

type
  TBlurFunction = procedure(Bitmap32: TBitmap32; Radius: TFloat);
  TBlurFunctionBounds = procedure(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect);
  TBlurFunctionRegion = procedure(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint);

(*

GaussianBlur appears to be based on Mario Klingemann's "stackblur" algorithm which
in turn is a "reinvention" of a simple sliding-accumulator box blur. It performs what
corresponds to a two pass box blur (i.e. a triangle blur).
https://web.archive.org/web/20200811093037/http://incubator.quasimondo.com/processing/fast_blur_deluxe.php
https://underdestruction.com/2004/02/25/stackblur-2004/

*)
procedure GaussianBlur(Bitmap32: TBitmap32; Radius: TFloat); overload; deprecated 'Use Blur32 in GR32.Blur instead';
procedure GaussianBlur(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect); overload; deprecated 'Use Blur32 in GR32.Blur instead';
procedure GaussianBlur(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint); overload; deprecated 'Use Blur32 in GR32.Blur instead';

procedure GaussianBlurGamma(Bitmap32: TBitmap32; Radius: TFloat); overload; deprecated 'Use GammaBlur32 in GR32.Blur instead';
procedure GaussianBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect); overload; deprecated 'Use Blur32 in GR32.Blur instead';
procedure GaussianBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint); overload; deprecated 'Use Blur32 in GR32.Blur instead';

(*

FastBlur: Three pass box blur

*)
procedure FastBlur(Bitmap32: TBitmap32; Radius: TFloat); overload; deprecated 'Use Blur32 in GR32.Blur instead';
procedure FastBlur(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect); overload; deprecated 'Use Blur32 in GR32.Blur instead';
procedure FastBlur(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint); overload; deprecated 'Use Blur32 in GR32.Blur instead';

procedure FastBlurGamma(Bitmap32: TBitmap32; Radius: TFloat); overload; deprecated 'Use GammaBlur32 in GR32.Blur instead';
procedure FastBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect); overload; deprecated 'Use GammaBlur32 in GR32.Blur instead';
procedure FastBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint); overload; deprecated 'Use GammaBlur32 in GR32.Blur instead';

(*

MotionBlur: One-dimensional blur with rotation (rotate, blur horizontal, rotate back)

*)
procedure MotionBlur(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat; Bidirectional: Boolean = True); overload;
procedure MotionBlur(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat; const Bounds: TRect; Bidirectional: Boolean = True); overload;
procedure MotionBlur(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat; const BlurRegion: TArrayOfFloatPoint; Bidirectional: Boolean = True); overload;

procedure MotionBlurGamma(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat; Bidirectional: Boolean = True); overload;
procedure MotionBlurGamma(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat; const Bounds: TRect; Bidirectional: Boolean = True); overload;
procedure MotionBlurGamma(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat; const BlurRegion: TArrayOfFloatPoint; Bidirectional: Boolean = True); overload;

const
  GaussianBlurSimple: array [Boolean] of TBlurFunction = (Blur32, GammaBlur32) deprecated 'This const will be removed. Make a local copy of it instead';
  GaussianBlurBounds: array [Boolean] of TBlurFunctionBounds = (Blur32, GammaBlur32) deprecated 'This const will be removed. Make a local copy of it instead';
  GaussianBlurRegion: array [Boolean] of TBlurFunctionRegion = (Blur32, GammaBlur32) deprecated 'This const will be removed. Make a local copy of it instead';
  FastBlurSimple: array [Boolean] of TBlurFunction = (Blur32, GammaBlur32) deprecated 'This const will be removed. Make a local copy of it instead';
  FastBlurBounds: array [Boolean] of TBlurFunctionBounds = (Blur32, GammaBlur32) deprecated 'This const will be removed. Make a local copy of it instead';
  FastBlurRegion: array [Boolean] of TBlurFunctionRegion = (Blur32, GammaBlur32) deprecated 'This const will be removed. Make a local copy of it instead';

implementation

uses
  GR32_Blend, GR32_Gamma, GR32_Resamplers, GR32_Polygons, GR32_LowLevel,
  GR32_VectorUtils, GR32_Transforms;

type
   TSumRecInt64 = record
     B, G, R, A: Int64;
     Sum: Integer;
   end;

   TSumRecord = record
     B, G, R, A: Integer;
     Sum: Integer;
   end;

const
  ChannelSize = 256; // ie 1 byte for each of A,R,G & B in TColor32
  ChannelSizeMin1 = ChannelSize - 1;

procedure ResetSumRecord(var SumRecord: TSumRecInt64); overload;
  {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  FillChar(SumRecord, SizeOf(SumRecord), 0);
end;

procedure ResetSumRecord(var SumRecord: TSumRecord); overload;
  {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  FillChar(SumRecord, SizeOf(SumRecord), 0);
end;

function Divide(SumRecord: TSumRecInt64): TSumRecInt64; overload;
  {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  Result.A := SumRecord.A div SumRecord.Sum;
  Result.R := SumRecord.R div SumRecord.Sum;
  Result.G := SumRecord.G div SumRecord.Sum;
  Result.B := SumRecord.B div SumRecord.Sum;
end;

function Divide(SumRecord: TSumRecord): TSumRecord; overload;
  {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  Result.A := SumRecord.A div SumRecord.Sum;
  Result.R := SumRecord.R div SumRecord.Sum;
  Result.G := SumRecord.G div SumRecord.Sum;
  Result.B := SumRecord.B div SumRecord.Sum;
end;

function DivideToColor32(SumRecord: TSumRecInt64): TColor32Entry; overload;
  {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  Result.A := SumRecord.A div SumRecord.Sum;
  Result.R := SumRecord.R div SumRecord.Sum;
  Result.G := SumRecord.G div SumRecord.Sum;
  Result.B := SumRecord.B div SumRecord.Sum;
end;

function DivideToColor32(SumRecord: TSumRecord): TColor32Entry; overload;
  {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  Result.A := SumRecord.A div SumRecord.Sum;
  Result.R := SumRecord.R div SumRecord.Sum;
  Result.G := SumRecord.G div SumRecord.Sum;
  Result.B := SumRecord.B div SumRecord.Sum;
end;


{ GaussianBlur }

{$R-}

procedure GaussianBlur(Bitmap32: TBitmap32; Radius: TFloat);
begin
  GaussianBlur(Bitmap32, Radius, Bitmap32.BoundsRect);
end;

procedure GaussianBlur(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect);
var
  Q, I, J, X, Y, ImageWidth, RowOffset, RadiusI: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixels: PColor32EntryArray;
  RadiusSq, RadiusRevSq, KernelSize: Integer;
  SumRec: TSumRecInt64;
  PreMulArray: array of TColor32Entry;
  SumArray: array of TSumRecInt64;
  GaussLUT: array of array of Cardinal;
begin
  RadiusI := Round(Radius);
  if RadiusI < 1 then
    Exit
  else if RadiusI > 128 then
    RadiusI := 128; // nb: performance degrades exponentially with >> Radius

  // initialize the look-up-table ...
  KernelSize := RadiusI * 2 + 1;
  SetLength(GaussLUT, KernelSize);
  for I := 0 to KernelSize - 1 do
    SetLength(GaussLUT[I], ChannelSize);
  for I := 1 to RadiusI do
  begin
    RadiusRevSq := Round((Radius + 1 - I) * (Radius + 1 - I));
    for J := 0 to ChannelSizeMin1 do
    begin
      GaussLUT[RadiusI - I][J] := RadiusRevSq * J;
      GaussLUT[RadiusI + I][J] := GaussLUT[RadiusI - I][J];
    end;
  end;
  RadiusSq := Round((Radius + 1) * (Radius + 1));
  for J := 0 to ChannelSizeMin1 do
    GaussLUT[RadiusI][J] := RadiusSq * J;

  ImageWidth := Bitmap32.Width;
  SetLength(SumArray, ImageWidth * Bitmap32.Height);

  ImagePixels := PColor32EntryArray(Bitmap32.Bits);
  RecLeft := Max(Bounds.Left, 0);
  RecTop := Max(Bounds.Top, 0);
  RecRight := Min(Bounds.Right, ImageWidth - 1);
  RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

  RowOffset := RecTop * ImageWidth;
  SetLength(PreMulArray, Bitmap32.Width);
  for Y := RecTop to RecBottom do
  begin
    // initialize PreMulArray for the row ...
    Q := (Y * ImageWidth) + RecLeft;
    for X := RecLeft to RecRight do
      with ImagePixels[Q] do
      begin
        PreMulArray[X].A := A;
        PreMulArray[X].R := MulDiv255Table[R, A];
        PreMulArray[X].G := MulDiv255Table[G, A];
        PreMulArray[X].B := MulDiv255Table[B, A];
        Inc(Q);
      end;

    for X := RecLeft to RecRight do
    begin
      ResetSumRecord(SumRec);

      I := Max(X - RadiusI, RecLeft);
      Q := I - (X - RadiusI);
      for I := I to Min(X + RadiusI, RecRight) do
        with PreMulArray[I] do
        begin
          Inc(SumRec.A, GaussLUT[Q][A]);
          Inc(SumRec.R, GaussLUT[Q][R]);
          Inc(SumRec.G, GaussLUT[Q][G]);
          Inc(SumRec.B, GaussLUT[Q][B]);
          Inc(SumRec.Sum, GaussLUT[Q][1]);
          Inc(Q);
        end;
      Q := RowOffset + X;
      SumArray[Q] := Divide(SumRec);
    end;
    Inc(RowOffset, ImageWidth);
  end;

  RowOffset := RecTop * ImageWidth;
  for Y := RecTop to RecBottom do
  begin
    for X := RecLeft to RecRight do
    begin
      ResetSumRecord(SumRec);

      I := Max(Y - RadiusI, RecTop);
      Q := I - (Y - RadiusI);
      for I := I to Min(Y + RadiusI, RecBottom) do
        with SumArray[X + I * ImageWidth] do
        begin
          Inc(SumRec.A, GaussLUT[Q][A]);
          Inc(SumRec.R, GaussLUT[Q][R]);
          Inc(SumRec.G, GaussLUT[Q][G]);
          Inc(SumRec.B, GaussLUT[Q][B]);
          Inc(SumRec.Sum, GaussLUT[Q][1]);
          Inc(Q);
        end;

      with ImagePixels[RowOffset + X] do
      begin
        A := (SumRec.A div SumRec.Sum);
        R := DivMul255Table[A, (SumRec.R div SumRec.Sum)];
        G := DivMul255Table[A, (SumRec.G div SumRec.Sum)];
        B := DivMul255Table[A, (SumRec.B div SumRec.Sum)];
      end;
    end;
    Inc(RowOffset, ImageWidth);
  end;
end;

procedure GaussianBlur(Bitmap32: TBitmap32; Radius: TFloat;
  const BlurRegion: TArrayOfFloatPoint);
var
  Q, I, J, X, Y, ImageWidth, RowOffset, RadiusI: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixels: PColor32EntryArray;
  RadiusSq, RadiusRevSq, KernelSize: Integer;
  SumRec: TSumRecInt64;
  SumArray: array of TSumRecInt64;
  GaussLUT: array of array of Cardinal;
  PreMulArray: array of TColor32Entry;

  Mask: TBitmap32;
  Clr, MaskClr: TColor32Entry;
  Pts: TArrayOfFloatPoint;
  Bounds: TRect;
begin
  with PolygonBounds(BlurRegion) do
    Bounds := Rect(Floor(Left), Floor(Top), Ceil(Right), Ceil(Bottom));
  if Bounds.Left < 0 then Bounds.Left := 0;
  if Bounds.Top < 0 then Bounds.Top := 0;
  if Bounds.Right >= Bitmap32.Width then Bounds.Right := Bitmap32.Width - 1;
  if Bounds.Bottom >= Bitmap32.Height then Bounds.Bottom := Bitmap32.Height - 1;

  RadiusI := round(Radius);
  if (RadiusI < 1) or (Bounds.Right <= Bounds.Left) or (Bounds.Bottom <= Bounds.Top) then
    Exit
  else if RadiusI > 128 then
    RadiusI := 128; // nb: performance degrades exponentially with >> Radius

  Mask := TBitmap32.Create;
  try
    Mask.SetSize(Bounds.Right - Bounds.Left + 1, Bounds.Bottom - Bounds.Top + 1);
    SetLength(Pts, Length(BlurRegion));
    for I := 0 to High(BlurRegion) do
    begin
      Pts[I].X := BlurRegion[I].X - Bounds.Left;
      Pts[I].Y := BlurRegion[I].Y - Bounds.Top;
    end;
    PolygonFS(Mask, Pts, clWhite32);

    // initialize the look-up-table ...
    KernelSize := RadiusI * 2 + 1;
    SetLength(GaussLUT, KernelSize);
    for I := 0 to KernelSize - 1 do
      SetLength(GaussLUT[I], ChannelSize);
    for I := 1 to RadiusI do
    begin
      RadiusRevSq := Round((Radius + 1 - I) * (Radius + 1 - I));
      for J := 0 to ChannelSizeMin1 do
      begin
        GaussLUT[RadiusI - I][J] := RadiusRevSq * J;
        GaussLUT[RadiusI + I][J] := GaussLUT[RadiusI - I][J];
      end;
    end;
    RadiusSq := Round((Radius + 1) * (Radius + 1));
    for J := 0 to ChannelSizeMin1 do
      GaussLUT[RadiusI][J] := RadiusSq * J;

    ImageWidth := Bitmap32.Width;
    SetLength(SumArray, ImageWidth * Bitmap32.Height);

    ImagePixels := PColor32EntryArray(Bitmap32.Bits);
    RecLeft := Max(Bounds.Left, 0);
    RecTop := Max(Bounds.Top, 0);
    RecRight := Min(Bounds.Right, ImageWidth - 1);
    RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

    RowOffset := RecTop * ImageWidth;
    SetLength(PreMulArray, Bitmap32.Width);
    for Y := RecTop to RecBottom do
    begin
      // initialize PreMulArray for the current row ...
      Q := (Y * ImageWidth) + RecLeft;
      for X := RecLeft to RecRight do
        with ImagePixels[Q] do
        begin
          PreMulArray[X].A := A;
          PreMulArray[X].R := MulDiv255Table[R, A];
          PreMulArray[X].G := MulDiv255Table[G, A];
          PreMulArray[X].B := MulDiv255Table[B, A];
          Inc(Q);
        end;

      for X := RecLeft to RecRight do
      begin
        ResetSumRecord(SumRec);

        I := Max(X - RadiusI, RecLeft);
        Q := I - (X - RadiusI);
        for I := I to Min(X + RadiusI, RecRight) do
          with PreMulArray[I] do
          begin
            Inc(SumRec.A, GaussLUT[Q][A]);
            Inc(SumRec.R, GaussLUT[Q][R]);
            Inc(SumRec.G, GaussLUT[Q][G]);
            Inc(SumRec.B, GaussLUT[Q][B]);
            Inc(SumRec.Sum, GaussLUT[Q][1]);
            Inc(Q);
          end;
        Q := RowOffset + X;
        SumArray[Q] := Divide(SumRec);
      end;
      Inc(RowOffset, ImageWidth);
    end;

    RowOffset := RecTop * ImageWidth;
    for Y := RecTop to RecBottom do
    begin
      for X := RecLeft to RecRight do
      begin
        MaskClr.ARGB := Mask.Pixel[X - RecLeft, Y - RecTop];
        if (MaskClr.A = 0) then Continue;

        ResetSumRecord(SumRec);

        I := Max(Y - RadiusI, RecTop);
        Q := I - (Y - RadiusI);
        for I := I to Min(Y + RadiusI, RecBottom) do
          with SumArray[X + I * ImageWidth] do
          begin
            Inc(SumRec.A, GaussLUT[Q][A]);
            Inc(SumRec.R, GaussLUT[Q][R]);
            Inc(SumRec.G, GaussLUT[Q][G]);
            Inc(SumRec.B, GaussLUT[Q][B]);
            Inc(SumRec.Sum, GaussLUT[Q][1]);
            Inc(Q);
          end;

        with ImagePixels[RowOffset + X] do
          if (MaskClr.A < 255) then
          begin
            Clr.A := SumRec.A div SumRec.Sum;
            Clr.R := DivMul255Table[Clr.A, SumRec.R div SumRec.Sum];
            Clr.G := DivMul255Table[Clr.A, SumRec.G div SumRec.Sum];
            Clr.B := DivMul255Table[Clr.A, SumRec.B div SumRec.Sum];
            BlendMemEx(Clr.ARGB, ARGB, MaskClr.A);
          end else
          begin
            A := SumRec.A div SumRec.Sum;
            R := DivMul255Table[A, SumRec.R div SumRec.Sum];
            G := DivMul255Table[A, SumRec.G div SumRec.Sum];
            B := DivMul255Table[A, SumRec.B div SumRec.Sum];
          end;
      end;
      Inc(RowOffset, ImageWidth);
    end;
  finally
    Mask.Free;
  end;
end;

procedure GaussianBlurGamma(Bitmap32: TBitmap32; Radius: TFloat);
begin
  GaussianBlurGamma(Bitmap32, Radius, Bitmap32.BoundsRect);
end;

procedure GaussianBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect);
var
  Q, I, J, X, Y, ImageWidth, RowOffset, RadiusI: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixels: PColor32EntryArray;
  RadiusSq, RadiusRevSq, KernelSize: Integer;
  SumRec: TSumRecInt64;
  PreMulArray: array of TColor32Entry;
  SumArray: array of TSumRecInt64;
  GaussLUT: array of array of Cardinal;
begin
  RadiusI := Round(Radius);
  if RadiusI < 1 then
    Exit
  else if RadiusI > 128 then
    RadiusI := 128; // nb: performance degrades exponentially with >> Radius

  // initialize the look-up-table ...
  KernelSize := RadiusI * 2 + 1;
  SetLength(GaussLUT, KernelSize);
  for I := 0 to KernelSize - 1 do
    SetLength(GaussLUT[I], ChannelSize);
  for I := 1 to RadiusI do
  begin
    RadiusRevSq := Round((Radius + 1 - I) * (Radius + 1 - I));
    for J := 0 to ChannelSizeMin1 do
    begin
      GaussLUT[RadiusI - I][J] := RadiusRevSq * J;
      GaussLUT[RadiusI + I][J] := GaussLUT[RadiusI - I][J];
    end;
  end;
  RadiusSq := Round((Radius + 1) * (Radius + 1));
  for J := 0 to ChannelSizeMin1 do
    GaussLUT[RadiusI][J] := RadiusSq * J;

  ImageWidth := Bitmap32.Width;
  SetLength(SumArray, ImageWidth * Bitmap32.Height);

  ImagePixels := PColor32EntryArray(Bitmap32.Bits);
  RecLeft := Max(Bounds.Left, 0);
  RecTop := Max(Bounds.Top, 0);
  RecRight := Min(Bounds.Right, ImageWidth - 1);
  RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

  RowOffset := RecTop * ImageWidth;
  SetLength(PreMulArray, Bitmap32.Width);
  for Y := RecTop to RecBottom do
  begin
    // initialize PreMulArray for the row ...
    Q := (Y * ImageWidth) + RecLeft;
    for X := RecLeft to RecRight do
      with ImagePixels[Q] do
      begin
        PreMulArray[X].A := A;
        PreMulArray[X].R := MulDiv255Table[GAMMA_DECODING_TABLE[R], A];
        PreMulArray[X].G := MulDiv255Table[GAMMA_DECODING_TABLE[G], A];
        PreMulArray[X].B := MulDiv255Table[GAMMA_DECODING_TABLE[B], A];
        Inc(Q);
      end;

    for X := RecLeft to RecRight do
    begin
      ResetSumRecord(SumRec);

      I := Max(X - RadiusI, RecLeft);
      Q := I - (X - RadiusI);
      for I := I to Min(X + RadiusI, RecRight) do
        with PreMulArray[I] do
        begin
          Inc(SumRec.A, GaussLUT[Q][A]);
          Inc(SumRec.R, GaussLUT[Q][R]);
          Inc(SumRec.G, GaussLUT[Q][G]);
          Inc(SumRec.B, GaussLUT[Q][B]);
          Inc(SumRec.Sum, GaussLUT[Q][1]);
          Inc(Q);
        end;
      Q := RowOffset + X;
      SumArray[Q] := Divide(SumRec);
    end;
    Inc(RowOffset, ImageWidth);
  end;

  RowOffset := RecTop * ImageWidth;
  for Y := RecTop to RecBottom do
  begin
    for X := RecLeft to RecRight do
    begin
      ResetSumRecord(SumRec);

      I := Max(Y - RadiusI, RecTop);
      Q := I - (Y - RadiusI);
      for I := I to Min(Y + RadiusI, RecBottom) do
        with SumArray[X + I * ImageWidth] do
        begin
          Inc(SumRec.A, GaussLUT[Q][A]);
          Inc(SumRec.R, GaussLUT[Q][R]);
          Inc(SumRec.G, GaussLUT[Q][G]);
          Inc(SumRec.B, GaussLUT[Q][B]);
          Inc(SumRec.Sum, GaussLUT[Q][1]);
          Inc(Q);
        end;

      with ImagePixels[RowOffset + X] do
      begin
        A := (SumRec.A div SumRec.Sum);
        R := GAMMA_ENCODING_TABLE[DivMul255Table[A, (SumRec.R div SumRec.Sum)]];
        G := GAMMA_ENCODING_TABLE[DivMul255Table[A, (SumRec.G div SumRec.Sum)]];
        B := GAMMA_ENCODING_TABLE[DivMul255Table[A, (SumRec.B div SumRec.Sum)]];
      end;
    end;
    Inc(RowOffset, ImageWidth);
  end;
end;

procedure GaussianBlurGamma(Bitmap32: TBitmap32; Radius: TFloat;
  const BlurRegion: TArrayOfFloatPoint);
var
  Q, I, J, X, Y, ImageWidth, RowOffset, RadiusI: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixels: PColor32EntryArray;
  RadiusSq, RadiusRevSq, KernelSize: Integer;
  SumRec: TSumRecInt64;
  SumArray: array of TSumRecInt64;
  GaussLUT: array of array of Cardinal;
  PreMulArray: array of TColor32Entry;

  Mask: TBitmap32;
  Clr, MaskClr: TColor32Entry;
  Pts: TArrayOfFloatPoint;
  Bounds: TRect;
begin
  with PolygonBounds(BlurRegion) do
    Bounds := Rect(Floor(Left), Floor(Top), Ceil(Right), Ceil(Bottom));
  if Bounds.Left < 0 then Bounds.Left := 0;
  if Bounds.Top < 0 then Bounds.Top := 0;
  if Bounds.Right >= Bitmap32.Width then Bounds.Right := Bitmap32.Width - 1;
  if Bounds.Bottom >= Bitmap32.Height then Bounds.Bottom := Bitmap32.Height - 1;

  RadiusI := round(Radius);
  if (RadiusI < 1) or (Bounds.Right <= Bounds.Left) or (Bounds.Bottom <= Bounds.Top) then
    Exit
  else if RadiusI > 128 then
    RadiusI := 128; // nb: performance degrades exponentially with >> Radius

  Mask := TBitmap32.Create;
  try
    Mask.SetSize(Bounds.Right - Bounds.Left + 1, Bounds.Bottom - Bounds.Top + 1);
    SetLength(Pts, Length(BlurRegion));
    for I := 0 to High(BlurRegion) do
    begin
      Pts[I].X := BlurRegion[I].X - Bounds.Left;
      Pts[I].Y := BlurRegion[I].Y - Bounds.Top;
    end;
    PolygonFS(Mask, Pts, clWhite32);

    // initialize the look-up-table ...
    KernelSize := RadiusI * 2 + 1;
    SetLength(GaussLUT, KernelSize);
    for I := 0 to KernelSize - 1 do
      SetLength(GaussLUT[I], ChannelSize);
    for I := 1 to RadiusI do
    begin
      RadiusRevSq := Round((Radius + 1 - I) * (Radius + 1 - I));
      for J := 0 to ChannelSizeMin1 do
      begin
        GaussLUT[RadiusI - I][J] := RadiusRevSq * J;
        GaussLUT[RadiusI + I][J] := GaussLUT[RadiusI - I][J];
      end;
    end;
    RadiusSq := Round((Radius + 1) * (Radius + 1));
    for J := 0 to ChannelSizeMin1 do
      GaussLUT[RadiusI][J] := RadiusSq * J;

    ImageWidth := Bitmap32.Width;
    SetLength(SumArray, ImageWidth * Bitmap32.Height);

    ImagePixels := PColor32EntryArray(Bitmap32.Bits);
    RecLeft := Max(Bounds.Left, 0);
    RecTop := Max(Bounds.Top, 0);
    RecRight := Min(Bounds.Right, ImageWidth - 1);
    RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

    RowOffset := RecTop * ImageWidth;
    SetLength(PreMulArray, Bitmap32.Width);
    for Y := RecTop to RecBottom do
    begin
      // initialize PreMulArray for the current row ...
      Q := (Y * ImageWidth) + RecLeft;
      for X := RecLeft to RecRight do
        with ImagePixels[Q] do
        begin
          PreMulArray[X].A := A;
          PreMulArray[X].R := MulDiv255Table[GAMMA_DECODING_TABLE[R], A];
          PreMulArray[X].G := MulDiv255Table[GAMMA_DECODING_TABLE[G], A];
          PreMulArray[X].B := MulDiv255Table[GAMMA_DECODING_TABLE[B], A];
          Inc(Q);
        end;

      for X := RecLeft to RecRight do
      begin
        ResetSumRecord(SumRec);

        I := Max(X - RadiusI, RecLeft);
        Q := I - (X - RadiusI);
        for I := I to Min(X + RadiusI, RecRight) do
          with PreMulArray[I] do
          begin
            Inc(SumRec.A, GaussLUT[Q][A]);
            Inc(SumRec.R, GaussLUT[Q][R]);
            Inc(SumRec.G, GaussLUT[Q][G]);
            Inc(SumRec.B, GaussLUT[Q][B]);
            Inc(SumRec.Sum, GaussLUT[Q][1]);
            Inc(Q);
          end;
        Q := RowOffset + X;
        SumArray[Q] := Divide(SumRec);
      end;
      Inc(RowOffset, ImageWidth);
    end;

    RowOffset := RecTop * ImageWidth;
    for Y := RecTop to RecBottom do
    begin
      for X := RecLeft to RecRight do
      begin
        MaskClr.ARGB := Mask.Pixel[X - RecLeft, Y - RecTop];
        if (MaskClr.A = 0) then Continue;

        ResetSumRecord(SumRec);

        I := Max(Y - RadiusI, RecTop);
        Q := I - (Y - RadiusI);
        for I := I to Min(Y + RadiusI, RecBottom) do
          with SumArray[X + I * ImageWidth] do
          begin
            Inc(SumRec.A, GaussLUT[Q][A]);
            Inc(SumRec.R, GaussLUT[Q][R]);
            Inc(SumRec.G, GaussLUT[Q][G]);
            Inc(SumRec.B, GaussLUT[Q][B]);
            Inc(SumRec.Sum, GaussLUT[Q][1]);
            Inc(Q);
          end;

        with ImagePixels[RowOffset + X] do
          if (MaskClr.A < 255) then
          begin
            Clr.A := SumRec.A div SumRec.Sum;
            Clr.R := GAMMA_ENCODING_TABLE[DivMul255Table[Clr.A, SumRec.R div SumRec.Sum]];
            Clr.G := GAMMA_ENCODING_TABLE[DivMul255Table[Clr.A, SumRec.G div SumRec.Sum]];
            Clr.B := GAMMA_ENCODING_TABLE[DivMul255Table[Clr.A, SumRec.B div SumRec.Sum]];
            BlendMemEx(Clr.ARGB, ARGB, MaskClr.A);
          end else
          begin
            A := SumRec.A div SumRec.Sum;
            R := GAMMA_ENCODING_TABLE[DivMul255Table[A, SumRec.R div SumRec.Sum]];
            G := GAMMA_ENCODING_TABLE[DivMul255Table[A, SumRec.G div SumRec.Sum]];
            B := GAMMA_ENCODING_TABLE[DivMul255Table[A, SumRec.B div SumRec.Sum]];
          end;
      end;
      Inc(RowOffset, ImageWidth);
    end;
  finally
    Mask.Free;
  end;
end;


{ FastBlur }

procedure FastBlur(Bitmap32: TBitmap32; Radius: TFloat);
begin
  FastBlur(Bitmap32, Radius, Bitmap32.BoundsRect);
end;

procedure FastBlur(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect);
var
  LL, RR, TT, BB, XX, YY, I, J, X, Y, RadiusI, Passes: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixel: PColor32Entry;
  SumRec: TSumRecord;
  ImgPixel: PColor32Entry;
  Pixels: array of TColor32Entry;
begin
  if Radius < 1 then
    Exit
  else if Radius > 256 then
    Radius := 256;

  RadiusI := Round(Radius / Sqrt(-2 * Ln(COne255th)));
  if RadiusI < 2 then
  begin
    Passes := Round(Radius);
    RadiusI := 1;
  end else
    Passes := 3;

  RecLeft := Max(Bounds.Left, 0);
  RecTop := Max(Bounds.Top, 0);
  RecRight := Min(Bounds.Right, Bitmap32.Width - 1);
  RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

  SetLength(Pixels, Max(Bitmap32.Width, Bitmap32.Height) + 1);
  // pre-multiply alphas ...
  for Y := RecTop to RecBottom do
  begin
    ImgPixel := PColor32Entry(Bitmap32.ScanLine[Y]);
    Inc(ImgPixel, RecLeft);
    for X := RecLeft to RecRight do
      with ImgPixel^ do
      begin
        R := MulDiv255Table[R, A];
        G := MulDiv255Table[G, A];
        B := MulDiv255Table[B, A];
        Inc(ImgPixel);
      end;
  end;

  for I := 1 to Passes do
  begin

    // horizontal pass...
    for Y := RecTop to RecBottom do
    begin
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
      // fill the Pixels buffer with a copy of the row's pixels ...
      MoveLongword(ImagePixel^, Pixels[RecLeft], RecRight - RecLeft + 1);

      ResetSumRecord(SumRec);

      LL := RecLeft;
      RR := RecLeft + RadiusI;
      if RR > RecRight then RR := RecRight;
      // update first in row ...
      for XX := LL to RR do
        with Pixels[XX] do
        begin
          Inc(SumRec.A, A);
          Inc(SumRec.R, R);
          Inc(SumRec.G, G);
          Inc(SumRec.B, B);
          Inc(SumRec.Sum);
        end;

      ImagePixel^ := DivideToColor32(SumRec);

      // update the remaining pixels in the row ...
      for X := RecLeft + 1 to RecRight do
      begin
        Inc(ImagePixel);
        LL := X - RadiusI - 1;
        RR := X + RadiusI;
        if LL >= RecLeft then
          with Pixels[LL] do
          begin
            Dec(SumRec.A, A);
            Dec(SumRec.R, R);
            Dec(SumRec.G, G);
            Dec(SumRec.B, B);
            Dec(SumRec.Sum);
          end;
        if RR <= RecRight then
          with Pixels[RR] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum);
          end;

        ImagePixel^ := DivideToColor32(SumRec);
      end;
    end;

    // vertical pass...
    for X := RecLeft to RecRight do
    begin
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);
      for J := RecTop to RecBottom do
      begin
        Pixels[J] := ImagePixel^;
        Inc(ImagePixel, Bitmap32.Width);
      end;
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);

      TT := RecTop;
      BB := RecTop + RadiusI;
      if BB > RecBottom then BB := RecBottom;
      ResetSumRecord(SumRec);

      // update first in col ...
      for YY := TT to BB do
        with Pixels[YY] do
        begin
          Inc(SumRec.A, A);
          Inc(SumRec.R, R);
          Inc(SumRec.G, G);
          Inc(SumRec.B, B);
          Inc(SumRec.Sum);
        end;

      ImagePixel^ := DivideToColor32(SumRec);

      // update remainder in col ...
      for Y := RecTop + 1 to RecBottom do
      begin
        Inc(ImagePixel, Bitmap32.Width);
        TT := Y - RadiusI - 1;
        BB := Y + RadiusI;

        if TT >= RecTop then
          with Pixels[TT] do
          begin
            Dec(SumRec.A, A);
            Dec(SumRec.R, R);
            Dec(SumRec.G, G);
            Dec(SumRec.B, B);
            Dec(SumRec.Sum);
          end;
        if BB <= RecBottom then
          with Pixels[BB] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum);
          end;

        ImagePixel^ := DivideToColor32(SumRec);
      end;
    end;
  end;

  // extract alphas ...
  for Y := RecTop to RecBottom do
  begin
    ImgPixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
    for X := RecLeft to RecRight do
    begin
      ImgPixel.R := DivMul255Table[ImgPixel.A, ImgPixel.R];
      ImgPixel.G := DivMul255Table[ImgPixel.A, ImgPixel.G];
      ImgPixel.B := DivMul255Table[ImgPixel.A, ImgPixel.B];
      Inc(ImgPixel);
    end;
  end;
end;

procedure FastBlur(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint);
var
  LL, RR, TT, BB, XX, YY, I, J, X, Y, RadiusI, Passes: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixel: PColor32Entry;
  SumRec: TSumRecord;
  ImgPixel: PColor32Entry;
  Pixels: array of TSumRecord;

  Mask: TBitmap32;
  Clr, MaskClr: TColor32Entry;
  Pts: TArrayOfFloatPoint;
  Bounds: TRect;
begin
  if Radius < 1 then
    Exit
  else if Radius > 256 then
    Radius := 256;

  RadiusI := Round(Radius / Sqrt(-2 * Ln(COne255th)));
  if RadiusI < 2 then
  begin
    Passes := Round(Radius);
    RadiusI := 1;
  end else
    Passes := 3;

  with PolygonBounds(BlurRegion) do
    Bounds := Rect(Floor(Left), Floor(Top), Ceil(Right), Ceil(Bottom));
  if Bounds.Left < 0 then Bounds.Left := 0;
  if Bounds.Top < 0 then Bounds.Top := 0;
  if Bounds.Right >= Bitmap32.Width then Bounds.Right := Bitmap32.Width - 1;
  if Bounds.Bottom >= Bitmap32.Height then Bounds.Bottom := Bitmap32.Height - 1;
  RecLeft := Max(Bounds.Left, 0);
  RecTop := Max(Bounds.Top, 0);
  RecRight := Min(Bounds.Right, Bitmap32.Width - 1);
  RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

  SetLength(Pixels, Max(Bitmap32.Width, Bitmap32.Height) + 1);
  // pre-multiply alphas ...
  for Y := RecTop to RecBottom do
  begin
    ImgPixel := PColor32Entry(Bitmap32.ScanLine[Y]);
    Inc(ImgPixel, RecLeft);
    for X := RecLeft to RecRight do
    begin
      ImgPixel.R := MulDiv255Table[ImgPixel.R, ImgPixel.A];
      ImgPixel.G := MulDiv255Table[ImgPixel.G, ImgPixel.A];
      ImgPixel.B := MulDiv255Table[ImgPixel.B, ImgPixel.A];
      Inc(ImgPixel);
    end;
  end;

  Mask := TBitmap32.Create;
  try
    Mask.SetSize(Bounds.Right - Bounds.Left + 1, Bounds.Bottom - Bounds.Top + 1);
    SetLength(Pts, Length(BlurRegion));
    for I := 0 to High(BlurRegion) do
    begin
      Pts[I].X := BlurRegion[I].X - Bounds.Left;
      Pts[I].Y := BlurRegion[I].Y - Bounds.Top;
    end;
    PolygonFS(Mask, Pts, clWhite32);

    for I := 1 to Passes do
    begin
      // horizontal pass...
      for Y := RecTop to RecBottom do
      begin
        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
        // fill the Pixels buffer with a copy of the row's pixels ...
        for J := RecLeft to RecRight do
        begin
          MaskClr.ARGB := Mask.Pixel[J - RecLeft, Y - RecTop];
          if (MaskClr.A = 0) then
          begin
            Pixels[J].A := 0;
            Pixels[J].R := 0;
            Pixels[J].G := 0;
            Pixels[J].B := 0;
            Pixels[J].Sum := 0;
          end else
          with ImagePixel^ do
          begin
            Pixels[J].A := A;
            Pixels[J].R := R;
            Pixels[J].G := G;
            Pixels[J].B := B;
            Pixels[J].Sum := 1;
          end;
          Inc(ImagePixel);
        end;
        LL := RecLeft;
        RR := RecLeft + RadiusI;
        if RR > RecRight then RR := RecRight;
        ResetSumRecord(SumRec);

        // update first in row ...
        for XX := LL to RR do
          with Pixels[XX] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum, Sum);
          end;

        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
        MaskClr.ARGB := Mask.Pixel[0, Y - RecTop];
        if (MaskClr.A > 0) and (SumRec.Sum > 0) then
          ImagePixel^ := DivideToColor32(SumRec);

        // update the remaining pixels in the row ...
        for X := RecLeft + 1 to RecRight do
        begin
          Inc(ImagePixel);
          LL := X - RadiusI - 1;
          RR := X + RadiusI;
          if LL >= RecLeft then
            with Pixels[LL] do
            begin
              Dec(SumRec.A, A);
              Dec(SumRec.R, R);
              Dec(SumRec.G, G);
              Dec(SumRec.B, B);
              Dec(SumRec.Sum, Sum);
            end;
          if RR <= RecRight then
            with Pixels[RR] do
            begin
              Inc(SumRec.A, A);
              Inc(SumRec.R, R);
              Inc(SumRec.G, G);
              Inc(SumRec.B, B);
              Inc(SumRec.Sum, Sum);
            end;

          MaskClr.ARGB := Mask.Pixel[X - RecLeft, Y - RecTop];
          if (SumRec.Sum > 0) and (MaskClr.A = 255) then
            ImagePixel^ := DivideToColor32(SumRec);
        end;
      end;

      // vertical pass...
      for X := RecLeft to RecRight do
      begin
        // fill the Pixels buffer with a copy of the col's pixels ...
        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);
        for J := RecTop to RecBottom do
        begin
          MaskClr.ARGB := Mask.Pixel[X - RecLeft, J - RecTop];
          if (MaskClr.A = 0) then
          begin
            Pixels[J].A := 0;
            Pixels[J].R := 0;
            Pixels[J].G := 0;
            Pixels[J].B := 0;
            Pixels[J].Sum := 0;
          end else
          with ImagePixel^ do
          begin
            Pixels[J].A := A;
            Pixels[J].R := R;
            Pixels[J].G := G;
            Pixels[J].B := B;
            Pixels[J].Sum := 1;
          end;
          Inc(ImagePixel, Bitmap32.Width);
        end;
        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);

        TT := RecTop;
        BB := RecTop + RadiusI;
        if BB > RecBottom then BB := RecBottom;
        ResetSumRecord(SumRec);

        // update first in col ...
        for YY := TT to BB do
          with Pixels[YY] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum, Sum);
          end;
        MaskClr.ARGB := Mask.Pixel[X - RecLeft, 0];
        if (MaskClr.A > 0) and (SumRec.Sum > 0) then
          ImagePixel^ := DivideToColor32(SumRec);

        // update remainder in col ...
        for Y := RecTop + 1 to RecBottom do
        begin
          Inc(ImagePixel, Bitmap32.Width);
          TT := Y - RadiusI - 1;
          BB := Y + RadiusI;

          if TT >= RecTop then
            with Pixels[TT] do
            begin
              Dec(SumRec.A, A);
              Dec(SumRec.R, R);
              Dec(SumRec.G, G);
              Dec(SumRec.B, B);
              Dec(SumRec.Sum, Sum);
            end;
          if BB <= RecBottom then
            with Pixels[BB] do
            begin
              Inc(SumRec.A, A);
              Inc(SumRec.R, R);
              Inc(SumRec.G, G);
              Inc(SumRec.B, B);
              Inc(SumRec.Sum, Sum);
            end;
          MaskClr.ARGB := Mask.Pixel[X - RecLeft, Y - RecTop];
          if (SumRec.Sum = 0) or (MaskClr.A = 0) then
            // do nothing
          else if (I = Passes) then
          begin
            Clr := DivideToColor32(SumRec);
            BlendMemEx(Clr.ARGB, ImagePixel^.ARGB, MaskClr.A);
          end
          else if (MaskClr.A = 255) then
            ImagePixel^ := DivideToColor32(SumRec);
        end;
      end;
    end;

    // extract alphas ...
    for Y := RecTop to RecBottom do
    begin
      ImgPixel := PColor32Entry(Bitmap32.ScanLine[Y]);
      Inc(ImgPixel, RecLeft);
      for X := RecLeft to RecRight do
      begin
        ImgPixel.R := DivMul255Table[ImgPixel.A, ImgPixel.R];
        ImgPixel.G := DivMul255Table[ImgPixel.A, ImgPixel.G];
        ImgPixel.B := DivMul255Table[ImgPixel.A, ImgPixel.B];
        Inc(ImgPixel);
      end;
    end;
  finally
    Mask.Free;
  end;
end;

procedure FastBlurGamma(Bitmap32: TBitmap32; Radius: TFloat);
begin
  FastBlurGamma(Bitmap32, Radius, Bitmap32.BoundsRect);
end;

procedure FastBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const Bounds: TRect);
var
  LL, RR, TT, BB, XX, YY, I, J, X, Y, RadiusI, Passes: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixel: PColor32Entry;
  SumRec: TSumRecord;
  ImgPixel: PColor32Entry;
  Pixels: array of TColor32Entry;
begin
  if Radius < 1 then
    Exit
  else if Radius > 256 then
    Radius := 256;

  RadiusI := Round(Radius / Sqrt(-2 * Ln(COne255th)));
  if RadiusI < 2 then
  begin
    Passes := Round(Radius);
    RadiusI := 1;
  end else
    Passes := 3;

  RecLeft := Max(Bounds.Left, 0);
  RecTop := Max(Bounds.Top, 0);
  RecRight := Min(Bounds.Right, Bitmap32.Width - 1);
  RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

  SetLength(Pixels, Max(Bitmap32.Width, Bitmap32.Height) + 1);

  // pre-multiply alphas ...
  for Y := RecTop to RecBottom do
  begin
    ImgPixel := PColor32Entry(Bitmap32.ScanLine[Y]);
    Inc(ImgPixel, RecLeft);
    for X := RecLeft to RecRight do
      with ImgPixel^ do
      begin
        R := MulDiv255Table[GAMMA_DECODING_TABLE[R], A];
        G := MulDiv255Table[GAMMA_DECODING_TABLE[G], A];
        B := MulDiv255Table[GAMMA_DECODING_TABLE[B], A];
        Inc(ImgPixel);
      end;
  end;

  for I := 1 to Passes do
  begin

    // horizontal pass...
    for Y := RecTop to RecBottom do
    begin
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
      // fill the Pixels buffer with a copy of the row's pixels ...
      MoveLongword(ImagePixel^, Pixels[RecLeft], RecRight - RecLeft + 1);

      ResetSumRecord(SumRec);

      LL := RecLeft;
      RR := RecLeft + RadiusI;
      if RR > RecRight then RR := RecRight;
      // update first in row ...
      for XX := LL to RR do
        with Pixels[XX] do
        begin
          Inc(SumRec.A, A);
          Inc(SumRec.R, R);
          Inc(SumRec.G, G);
          Inc(SumRec.B, B);
          Inc(SumRec.Sum);
        end;
      ImagePixel^ := DivideToColor32(SumRec);

      // update the remaining pixels in the row ...
      for X := RecLeft + 1 to RecRight do
      begin
        Inc(ImagePixel);
        LL := X - RadiusI - 1;
        RR := X + RadiusI;
        if LL >= RecLeft then
          with Pixels[LL] do
          begin
            Dec(SumRec.A, A);
            Dec(SumRec.R, R);
            Dec(SumRec.G, G);
            Dec(SumRec.B, B);
            Dec(SumRec.Sum);
          end;
        if RR <= RecRight then
          with Pixels[RR] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum);
          end;

        ImagePixel^ := DivideToColor32(SumRec);
      end;
    end;

    // vertical pass...
    for X := RecLeft to RecRight do
    begin
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);
      for J := RecTop to RecBottom do
      begin
        Pixels[J] := ImagePixel^;
        Inc(ImagePixel, Bitmap32.Width);
      end;
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);

      TT := RecTop;
      BB := RecTop + RadiusI;
      if BB > RecBottom then BB := RecBottom;
      ResetSumRecord(SumRec);

      // update first in col ...
      for YY := TT to BB do
        with Pixels[YY] do
        begin
          Inc(SumRec.A, A);
          Inc(SumRec.R, R);
          Inc(SumRec.G, G);
          Inc(SumRec.B, B);
          Inc(SumRec.Sum);
        end;

      ImagePixel^ := DivideToColor32(SumRec);

      // update remainder in col ...
      for Y := RecTop + 1 to RecBottom do
      begin
        Inc(ImagePixel, Bitmap32.Width);
        TT := Y - RadiusI - 1;
        BB := Y + RadiusI;

        if TT >= RecTop then
          with Pixels[TT] do
          begin
            Dec(SumRec.A, A);
            Dec(SumRec.R, R);
            Dec(SumRec.G, G);
            Dec(SumRec.B, B);
            Dec(SumRec.Sum);
          end;
        if BB <= RecBottom then
          with Pixels[BB] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum);
          end;

        ImagePixel^ := DivideToColor32(SumRec);
      end;
    end;
  end;

  // extract alphas ...
  for Y := RecTop to RecBottom do
  begin
    ImgPixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
    for X := RecLeft to RecRight do
    begin
      ImgPixel.R := GAMMA_ENCODING_TABLE[DivMul255Table[ImgPixel.A, ImgPixel.R]];
      ImgPixel.G := GAMMA_ENCODING_TABLE[DivMul255Table[ImgPixel.A, ImgPixel.G]];
      ImgPixel.B := GAMMA_ENCODING_TABLE[DivMul255Table[ImgPixel.A, ImgPixel.B]];
      Inc(ImgPixel);
    end;
  end;
end;

procedure FastBlurGamma(Bitmap32: TBitmap32; Radius: TFloat; const BlurRegion: TArrayOfFloatPoint);
var
  LL, RR, TT, BB, XX, YY, I, J, X, Y, RadiusI, Passes: Integer;
  RecLeft, RecTop, RecRight, RecBottom: Integer;
  ImagePixel: PColor32Entry;
  SumRec: TSumRecord;
  ImgPixel: PColor32Entry;
  Pixels: array of TSumRecord;

  Mask: TBitmap32;
  Clr, MaskClr: TColor32Entry;
  Pts: TArrayOfFloatPoint;
  Bounds: TRect;
begin
  if Radius < 1 then
    Exit
  else if Radius > 256 then
    Radius := 256;

  RadiusI := Round(Radius / Sqrt(-2 * Ln(COne255th)));
  if RadiusI < 2 then
  begin
    Passes := Round(Radius);
    RadiusI := 1;
  end else
    Passes := 3;

  with PolygonBounds(BlurRegion) do
    Bounds := Rect(Floor(Left), Floor(Top), Ceil(Right), Ceil(Bottom));
  if Bounds.Left < 0 then Bounds.Left := 0;
  if Bounds.Top < 0 then Bounds.Top := 0;
  if Bounds.Right >= Bitmap32.Width then Bounds.Right := Bitmap32.Width - 1;
  if Bounds.Bottom >= Bitmap32.Height then Bounds.Bottom := Bitmap32.Height - 1;
  RecLeft := Max(Bounds.Left, 0);
  RecTop := Max(Bounds.Top, 0);
  RecRight := Min(Bounds.Right, Bitmap32.Width - 1);
  RecBottom := Min(Bounds.Bottom, Bitmap32.Height - 1);

  SetLength(Pixels, Max(Bitmap32.Width, Bitmap32.Height) + 1);

  // pre-multiply alphas ...
  for Y := RecTop to RecBottom do
  begin
    ImgPixel := PColor32Entry(Bitmap32.ScanLine[Y]);
    Inc(ImgPixel, RecLeft);
    for X := RecLeft to RecRight do
    begin
      ImgPixel.R := MulDiv255Table[GAMMA_DECODING_TABLE[ImgPixel.R], ImgPixel.A];
      ImgPixel.G := MulDiv255Table[GAMMA_DECODING_TABLE[ImgPixel.G], ImgPixel.A];
      ImgPixel.B := MulDiv255Table[GAMMA_DECODING_TABLE[ImgPixel.B], ImgPixel.A];
      Inc(ImgPixel);
    end;
  end;

  Mask := TBitmap32.Create;
  try
    Mask.SetSize(Bounds.Right - Bounds.Left + 1, Bounds.Bottom - Bounds.Top + 1);
    SetLength(Pts, Length(BlurRegion));
    for I := 0 to High(BlurRegion) do
    begin
      Pts[I].X := BlurRegion[I].X - Bounds.Left;
      Pts[I].Y := BlurRegion[I].Y - Bounds.Top;
    end;
    PolygonFS(Mask, Pts, clWhite32);

    for I := 1 to Passes do
    begin
      // horizontal pass...
      for Y := RecTop to RecBottom do
      begin
        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
        // fill the Pixels buffer with a copy of the row's pixels ...
        for J := RecLeft to RecRight do
        begin
          MaskClr.ARGB := Mask.Pixel[J - RecLeft, Y - RecTop];
          if (MaskClr.A = 0) then
          begin
            Pixels[J].A := 0;
            Pixels[J].R := 0;
            Pixels[J].G := 0;
            Pixels[J].B := 0;
            Pixels[J].Sum := 0;
          end else
          with ImagePixel^ do
          begin
            Pixels[J].A := A;
            Pixels[J].R := R;
            Pixels[J].G := G;
            Pixels[J].B := B;
            Pixels[J].Sum := 1;
          end;
          Inc(ImagePixel);
        end;
        LL := RecLeft;
        RR := RecLeft + RadiusI;
        if RR > RecRight then RR := RecRight;
        ResetSumRecord(SumRec);

        // update first in row ...
        for XX := LL to RR do
          with Pixels[XX] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum, Sum);
          end;

        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y][RecLeft]);
        MaskClr.ARGB := Mask.Pixel[0, Y - RecTop];
        if (MaskClr.A > 0) and (SumRec.Sum > 0) then
          ImagePixel^ := DivideToColor32(SumRec);

        // update the remaining pixels in the row ...
        for X := RecLeft + 1 to RecRight do
        begin
          Inc(ImagePixel);
          LL := X - RadiusI - 1;
          RR := X + RadiusI;
          if LL >= RecLeft then
            with Pixels[LL] do
            begin
              Dec(SumRec.A, A);
              Dec(SumRec.R, R);
              Dec(SumRec.G, G);
              Dec(SumRec.B, B);
              Dec(SumRec.Sum, Sum);
            end;
          if RR <= RecRight then
            with Pixels[RR] do
            begin
              Inc(SumRec.A, A);
              Inc(SumRec.R, R);
              Inc(SumRec.G, G);
              Inc(SumRec.B, B);
              Inc(SumRec.Sum, Sum);
            end;

          MaskClr.ARGB := Mask.Pixel[X - RecLeft, Y - RecTop];
          if (SumRec.Sum > 0) and (MaskClr.A = 255) then
            ImagePixel^ := DivideToColor32(SumRec);
        end;
      end;

      // vertical pass...
      for X := RecLeft to RecRight do
      begin
        // fill the Pixels buffer with a copy of the col's pixels ...
        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);
        for J := RecTop to RecBottom do
        begin
          MaskClr.ARGB := Mask.Pixel[X - RecLeft, J - RecTop];
          if (MaskClr.A = 0) then
          begin
            Pixels[J].A := 0;
            Pixels[J].R := 0;
            Pixels[J].G := 0;
            Pixels[J].B := 0;
            Pixels[J].Sum := 0;
          end else
          with ImagePixel^ do
          begin
            Pixels[J].A := A;
            Pixels[J].R := R;
            Pixels[J].G := G;
            Pixels[J].B := B;
            Pixels[J].Sum := 1;
          end;
          Inc(ImagePixel, Bitmap32.Width);
        end;
        ImagePixel := PColor32Entry(@Bitmap32.ScanLine[RecTop][X]);

        TT := RecTop;
        BB := RecTop + RadiusI;
        if BB > RecBottom then BB := RecBottom;
        ResetSumRecord(SumRec);

        // update first in col ...
        for YY := TT to BB do
          with Pixels[YY] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum, Sum);
          end;
        MaskClr.ARGB := Mask.Pixel[X - RecLeft, 0];
        if (MaskClr.A > 0) and (SumRec.Sum > 0) then
          ImagePixel^ := DivideToColor32(SumRec);

        // update remainder in col ...
        for Y := RecTop + 1 to RecBottom do
        begin
          Inc(ImagePixel, Bitmap32.Width);
          TT := Y - RadiusI - 1;
          BB := Y + RadiusI;

          if TT >= RecTop then
            with Pixels[TT] do
            begin
              Dec(SumRec.A, A);
              Dec(SumRec.R, R);
              Dec(SumRec.G, G);
              Dec(SumRec.B, B);
              Dec(SumRec.Sum, Sum);
            end;
          if BB <= RecBottom then
            with Pixels[BB] do
            begin
              Inc(SumRec.A, A);
              Inc(SumRec.R, R);
              Inc(SumRec.G, G);
              Inc(SumRec.B, B);
              Inc(SumRec.Sum, Sum);
            end;
          MaskClr.ARGB := Mask.Pixel[X - RecLeft, Y - RecTop];
          if (SumRec.Sum = 0) or (MaskClr.A = 0) then
            // do nothing
          else if (I = Passes) then
          begin
            Clr := DivideToColor32(SumRec);
            BlendMemEx(Clr.ARGB, ImagePixel^.ARGB, MaskClr.A);
          end
          else if (MaskClr.A = 255) then
            ImagePixel^ := DivideToColor32(SumRec);
        end;
      end;
    end;

    // extract alphas ...
    for Y := RecTop to RecBottom do
    begin
      ImgPixel := PColor32Entry(Bitmap32.ScanLine[Y]);
      Inc(ImgPixel, RecLeft);
      for X := RecLeft to RecRight do
      begin
        ImgPixel.R := GAMMA_ENCODING_TABLE[DivMul255Table[ImgPixel.A, ImgPixel.R]];
        ImgPixel.G := GAMMA_ENCODING_TABLE[DivMul255Table[ImgPixel.A, ImgPixel.G]];
        ImgPixel.B := GAMMA_ENCODING_TABLE[DivMul255Table[ImgPixel.A, ImgPixel.B]];
        Inc(ImgPixel);
      end;
    end;
  finally
    Mask.Free;
  end;
end;


{ MotionBlur }

procedure MotionBlur(Bitmap32: TBitmap32;
  Dist, AngleDeg: TFloat; Bidirectional: Boolean = True);
begin
  MotionBlur(Bitmap32, Dist, AngleDeg, Rectangle(Bitmap32.BoundsRect), Bidirectional);
end;

procedure MotionBlur(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat;
  const Bounds: TRect; Bidirectional: Boolean = True);
begin
  MotionBlur(Bitmap32, Dist, AngleDeg, Rectangle(Bounds), Bidirectional);
end;

procedure MotionBlur(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat;
  const BlurRegion: TArrayOfFloatPoint; Bidirectional: Boolean = True);
var
  LL, RR, XX, I, X, Y, RadiusI, Passes: Integer;
  ImagePixel, ImagePixel2, ImagePixel3: PColor32Entry;
  SumRec: TSumRecord;
  Pixels: array of TSumRecord;
  Mask: TBitmap32;
  Clr, MaskClr: TColor32Entry;
  Pts: TArrayOfFloatPoint;
  Bounds: TRect;
  Dx, Dy: Double;
  Affine: TAffineTransformation;
  BmpCutout: TBitmap32;
  BmpRotated: TBitmap32;
  FloatBounds: TFloatRect;
begin
  if Dist < 1 then
    Exit
  else if Dist > 256 then
    Dist := 256;

  RadiusI := Round(Sqrt(-Dist * Dist / (2 * Ln(COne255th))));
  if RadiusI < 2 then
  begin
    Passes := Round(Dist);
    RadiusI := 1;
  end else
    Passes := 3;


  Bounds := MakeRect(PolygonBounds(BlurRegion), rrOutside);
  Bounds.Intersect(Rect(0, 0, Bitmap32.Width-1, Bitmap32.Height-1));

  Affine := TAffineTransformation.Create;
  BmpCutout := TBitmap32.Create;
  BmpRotated := TBitmap32.Create;
  BmpRotated.Resampler := TLinearResampler.Create(BmpRotated);
  Mask := TBitmap32.Create;
  try
    // copy the region to be blurred into the BmpCutout image buffer ...
    BmpCutout.SetSize(Bounds.Right - Bounds.Left, Bounds.Bottom - Bounds.Top);
    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y + Bounds.Top][Bounds.Left]);
      ImagePixel2 := PColor32Entry(BmpCutout.ScanLine[Y]);
      MoveLongword(ImagePixel^, ImagePixel2^, BmpCutout.Width);
    end;

    // pre-multiply alphas in BmpCutout ...
    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(BmpCutout.ScanLine[Y]);
      for X := 0 to BmpCutout.Width - 1 do
      begin
        ImagePixel.R := MulDiv255Table[ImagePixel.R, ImagePixel.A];
        ImagePixel.G := MulDiv255Table[ImagePixel.G, ImagePixel.A];
        ImagePixel.B := MulDiv255Table[ImagePixel.B, ImagePixel.A];
        Inc(ImagePixel);
      end;
    end;

    // Rotate BmpCutout into BmpRotated ...
    Affine.SrcRect := FloatRect(BmpCutout.BoundsRect);
    Affine.Rotate(180 - AngleDeg);
    FloatBounds := Affine.GetTransformedBounds;
    Mask.SetSize(Round(FloatBounds.Width) + 1, Round(FloatBounds.Height) + 1);
    BmpRotated.SetSize(Mask.Width, Mask.Height);
    Dx := FloatBounds.Left; Dy := FloatBounds.Top;
    Affine.Translate(-Dx, -Dy);
    Transform(BmpRotated, BmpCutout, Affine);

    // Create a rotated mask ...
    Affine.Clear;
    Affine.Translate(-Bounds.Left, -Bounds.Top);
    Affine.SrcRect := FloatRect(BmpCutout.BoundsRect);
    Affine.Rotate(180 - AngleDeg);
    Affine.Translate(-Dx, -Dy);
    Pts := TransformPolygon(BlurRegion, Affine);
    PolygonFS(Mask, Pts, clWhite32);
    SetLength(Pixels, BmpRotated.Width);

    // Now blur horizontally the rotated image ...
    for I := 1 to Passes do
      // Horizontal blur only ...
      for Y := 0 to BmpRotated.Height - 1 do
      begin
        ImagePixel := PColor32Entry(BmpRotated.ScanLine[Y]);
        // fill the Pixels buffer with a copy of the row's pixels ...
        for X := 0 to BmpRotated.Width - 1 do
        begin
          MaskClr.ARGB := Mask.Pixel[X, Y];
          if (MaskClr.A = 0) then
          begin
            Pixels[X].A := 0;
            Pixels[X].R := 0;
            Pixels[X].G := 0;
            Pixels[X].B := 0;
            Pixels[X].Sum := 0;
          end else
          with ImagePixel^ do
          begin
            Pixels[X].A := A;
            Pixels[X].R := R;
            Pixels[X].G := G;
            Pixels[X].B := B;
            Pixels[X].Sum := 1;
          end;
          Inc(ImagePixel);
        end;

        LL := 0;
        RR := RadiusI;
        if RR >= BmpRotated.Width then
          RR := BmpRotated.Width - 1;
        ResetSumRecord(SumRec);

        // update first in row ...
        for XX := LL to RR do
          with Pixels[XX] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum, Sum);
          end;

        ImagePixel := PColor32Entry(BmpRotated.ScanLine[Y]);
        MaskClr.ARGB := Mask.Pixel[0, Y];
        if (MaskClr.A > 0) and (SumRec.Sum > 0) then
          ImagePixel^ := DivideToColor32(SumRec);

        // update the remaining pixels in the row ...
        for X := 1 to BmpRotated.Width - 1 do
        begin
          Inc(ImagePixel);
          if Bidirectional then
            LL := X - RadiusI - 1
          else
            LL := X - 1;
          RR := X + RadiusI;
          if LL >= 0 then
            with Pixels[LL] do
            begin
              Dec(SumRec.A, A);
              Dec(SumRec.R, R);
              Dec(SumRec.G, G);
              Dec(SumRec.B, B);
              Dec(SumRec.Sum, Sum);
            end;

          if RR < BmpRotated.Width then
            with Pixels[RR] do
            begin
              Inc(SumRec.A, A);
              Inc(SumRec.R, R);
              Inc(SumRec.G, G);
              Inc(SumRec.B, B);
              Inc(SumRec.Sum, Sum);
            end;

          MaskClr.ARGB := Mask.Pixel[X, Y];

          if (SumRec.Sum = 0) or (MaskClr.A = 0) then
            Continue
          else
          if (I = Passes) then
          begin
            Clr := DivideToColor32(SumRec);
            BlendMemEx(Clr.ARGB, ImagePixel^.ARGB, MaskClr.A);
          end else
          if (MaskClr.A = 255) then
            ImagePixel^ := DivideToColor32(SumRec);
        end;
      end;

    // un-rotate the now blurred image back into BmpCutout ...
    Affine.Clear;
    Affine.SrcRect := FloatRect(BmpRotated.BoundsRect);
    Affine.Translate(Dx, Dy);
    Affine.Rotate(AngleDeg + 180);
    Transform(BmpCutout, BmpRotated, Affine);

    // extract alphas ...
    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(BmpCutout.ScanLine[Y]);
      for X := 0 to BmpCutout.Width - 1 do
      begin
        ImagePixel.R := DivMul255Table[ImagePixel.A, ImagePixel.R];
        ImagePixel.G := DivMul255Table[ImagePixel.A, ImagePixel.G];
        ImagePixel.B := DivMul255Table[ImagePixel.A, ImagePixel.B];
        Inc(ImagePixel);
      end;
    end;

    // Create an un-rotated mask and copy masked pixels from BmpCutout
    // back to the original image (Bitmap32) ...
    Mask.SetSize(BmpCutout.Width, BmpCutout.Height);
    Pts := TranslatePolygon(BlurRegion, -Bounds.Left, -Bounds.Top);
    PolygonFS(Mask, Pts, clWhite32);

    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(BmpCutout.ScanLine[Y]);
      ImagePixel2 := PColor32Entry(Mask.ScanLine[Y]);
      ImagePixel3 := PColor32Entry(@Bitmap32.ScanLine[Y + Bounds.Top][Bounds.Left]);
      for X := 0 to BmpCutout.Width - 1 do
      begin
        if ImagePixel2.A > 0 then
          ImagePixel3.ARGB := ImagePixel.ARGB;
        Inc(ImagePixel);
        Inc(ImagePixel2);
        Inc(ImagePixel3);
      end;
    end;

  finally
    Affine.Free;
    BmpCutout.Free;
    BmpRotated.Free;
    Mask.Free;
  end;
end;

procedure MotionBlurGamma(Bitmap32: TBitmap32;
  Dist, AngleDeg: TFloat; Bidirectional: Boolean = True);
begin
  MotionBlurGamma(Bitmap32, Dist, AngleDeg, Rectangle(Bitmap32.BoundsRect), Bidirectional);
end;

procedure MotionBlurGamma(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat;
  const Bounds: TRect; Bidirectional: Boolean = True);
begin
  MotionBlurGamma(Bitmap32, Dist, AngleDeg, Rectangle(Bounds), Bidirectional);
end;

procedure MotionBlurGamma(Bitmap32: TBitmap32; Dist, AngleDeg: TFloat;
  const BlurRegion: TArrayOfFloatPoint; Bidirectional: Boolean = True);
var
  LL, RR, XX, I, X, Y, RadiusI, Passes: Integer;
  ImagePixel, ImagePixel2, ImagePixel3: PColor32Entry;
  SumRec: TSumRecord;
  Pixels: array of TSumRecord;
  Mask: TBitmap32;
  Clr, MaskClr: TColor32Entry;
  Pts: TArrayOfFloatPoint;
  Bounds: TRect;
  Dx, Dy: Double;
  Affine: TAffineTransformation;
  BmpCutout: TBitmap32;
  BmpRotated: TBitmap32;
  FloatBounds: TFloatRect;
begin
  if Dist < 1 then
    Exit
  else if Dist > 256 then
    Dist := 256;

  RadiusI := Round(Sqrt(-Dist * Dist / (2 * Ln(COne255th))));
  if RadiusI < 2 then
  begin
    Passes := Round(Dist);
    RadiusI := 1;
  end else
    Passes := 3;


  Bounds := MakeRect(PolygonBounds(BlurRegion), rrOutside);
  Bounds.Intersect(Rect(0, 0, Bitmap32.Width-1, Bitmap32.Height-1));

  Affine := TAffineTransformation.Create;
  BmpCutout := TBitmap32.Create;
  BmpRotated := TBitmap32.Create;
  BmpRotated.Resampler := TLinearResampler.Create(BmpRotated);
  Mask := TBitmap32.Create;
  try
    // copy the region to be blurred into the BmpCutout image buffer ...
    BmpCutout.SetSize(Bounds.Right - Bounds.Left, Bounds.Bottom - Bounds.Top);
    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(@Bitmap32.ScanLine[Y + Bounds.Top][Bounds.Left]);
      ImagePixel2 := PColor32Entry(BmpCutout.ScanLine[Y]);
      MoveLongword(ImagePixel^, ImagePixel2^, BmpCutout.Width);
    end;

    // pre-multiply alphas in BmpCutout ...
    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(BmpCutout.ScanLine[Y]);
      for X := 0 to BmpCutout.Width - 1 do
      begin
        ImagePixel.R := MulDiv255Table[GAMMA_DECODING_TABLE[ImagePixel.R], ImagePixel.A];
        ImagePixel.G := MulDiv255Table[GAMMA_DECODING_TABLE[ImagePixel.G], ImagePixel.A];
        ImagePixel.B := MulDiv255Table[GAMMA_DECODING_TABLE[ImagePixel.B], ImagePixel.A];
        Inc(ImagePixel);
      end;
    end;

    // Rotate BmpCutout into BmpRotated ...
    Affine.SrcRect := FloatRect(BmpCutout.BoundsRect);
    Affine.Rotate(180 - AngleDeg);

    FloatBounds := Affine.GetTransformedBounds;
    Mask.SetSize(Round(FloatBounds.Width) + 1, Round(FloatBounds.Height) + 1);
    BmpRotated.SetSize(Mask.Width, Mask.Height);
    Dx := FloatBounds.Left; Dy := FloatBounds.Top;
    Affine.Translate(-Dx, -Dy);
    Transform(BmpRotated, BmpCutout, Affine);

    // Create a rotated mask ...
    Affine.Clear;
    Affine.Translate(-Bounds.Left, -Bounds.Top);
    Affine.SrcRect := FloatRect(BmpCutout.BoundsRect);
    Affine.Rotate(180 - AngleDeg);
    Affine.Translate(-Dx, -Dy);
    Pts := TransformPolygon(BlurRegion, Affine);
    PolygonFS(Mask, Pts, clWhite32);
    SetLength(Pixels, BmpRotated.Width);

    // Now blur horizontally the rotated image ...
    for I := 1 to Passes do
      // Horizontal blur only ...
      for Y := 0 to BmpRotated.Height - 1 do
      begin
        ImagePixel := PColor32Entry(BmpRotated.ScanLine[Y]);
        // fill the Pixels buffer with a copy of the row's pixels ...
        for X := 0 to BmpRotated.Width - 1 do
        begin
          MaskClr.ARGB := Mask.Pixel[X, Y];
          if (MaskClr.A = 0) then
          begin
            Pixels[X].A := 0;
            Pixels[X].R := 0;
            Pixels[X].G := 0;
            Pixels[X].B := 0;
            Pixels[X].Sum := 0;
          end else
          with ImagePixel^ do
          begin
            Pixels[X].A := A;
            Pixels[X].R := R;
            Pixels[X].G := G;
            Pixels[X].B := B;
            Pixels[X].Sum := 1;
          end;
          Inc(ImagePixel);
        end;

        LL := 0;
        RR := RadiusI;
        if RR >= BmpRotated.Width then RR := BmpRotated.Width - 1;
        ResetSumRecord(SumRec);

        // update first in row ...
        for XX := LL to RR do
          with Pixels[XX] do
          begin
            Inc(SumRec.A, A);
            Inc(SumRec.R, R);
            Inc(SumRec.G, G);
            Inc(SumRec.B, B);
            Inc(SumRec.Sum, Sum);
          end;

        ImagePixel := PColor32Entry(BmpRotated.ScanLine[Y]);
        MaskClr.ARGB := Mask.Pixel[0, Y];
        if (MaskClr.A > 0) and (SumRec.Sum > 0) then
          ImagePixel^ := DivideToColor32(SumRec);

        // update the remaining pixels in the row ...
        for X := 1 to BmpRotated.Width - 1 do
        begin
          Inc(ImagePixel);
          if Bidirectional then
            LL := X - RadiusI - 1
          else
            LL := X - 1;
          RR := X + RadiusI;
          if LL >= 0 then
            with Pixels[LL] do
            begin
              Dec(SumRec.A, A);
              Dec(SumRec.R, R);
              Dec(SumRec.G, G);
              Dec(SumRec.B, B);
              Dec(SumRec.Sum, Sum);
            end;

          if RR < BmpRotated.Width then
            with Pixels[RR] do
            begin
              Inc(SumRec.A, A);
              Inc(SumRec.R, R);
              Inc(SumRec.G, G);
              Inc(SumRec.B, B);
              Inc(SumRec.Sum, Sum);
            end;

          MaskClr.ARGB := Mask.Pixel[X, Y];

          if (SumRec.Sum = 0) or (MaskClr.A = 0) then
            Continue
          else
          if (I = Passes) then
          begin
            Clr := DivideToColor32(SumRec);
            BlendMemEx(Clr.ARGB, ImagePixel^.ARGB, MaskClr.A);
          end else
          if (MaskClr.A = 255) then
            ImagePixel^ := DivideToColor32(SumRec);
        end;
      end;

    // un-rotate the now blurred image back into BmpCutout ...
    Affine.Clear;
    Affine.SrcRect := FloatRect(BmpRotated.BoundsRect);
    Affine.Translate(Dx, Dy);
    Affine.Rotate(AngleDeg + 180);
    Transform(BmpCutout, BmpRotated, Affine);

    // extract alphas ...
    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(BmpCutout.ScanLine[Y]);
      for X := 0 to BmpCutout.Width - 1 do
      begin
        ImagePixel.R := GAMMA_ENCODING_TABLE[DivMul255Table[ImagePixel.A, ImagePixel.R]];
        ImagePixel.G := GAMMA_ENCODING_TABLE[DivMul255Table[ImagePixel.A, ImagePixel.G]];
        ImagePixel.B := GAMMA_ENCODING_TABLE[DivMul255Table[ImagePixel.A, ImagePixel.B]];
        Inc(ImagePixel);
      end;
    end;

    // Create an un-rotated mask and copy masked pixels from BmpCutout
    // back to the original image (Bitmap32) ...
    Mask.SetSize(BmpCutout.Width, BmpCutout.Height);
    Pts := TranslatePolygon(BlurRegion, -Bounds.Left, -Bounds.Top);
    PolygonFS(Mask, Pts, clWhite32);

    for Y := 0 to BmpCutout.Height - 1 do
    begin
      ImagePixel := PColor32Entry(BmpCutout.ScanLine[Y]);
      ImagePixel2 := PColor32Entry(Mask.ScanLine[Y]);
      ImagePixel3 := PColor32Entry(@Bitmap32.ScanLine[Y + Bounds.Top][Bounds.Left]);
      for X := 0 to BmpCutout.Width - 1 do
      begin
        if ImagePixel2.A > 0 then
          ImagePixel3.ARGB := ImagePixel.ARGB;
        Inc(ImagePixel);
        Inc(ImagePixel2);
        Inc(ImagePixel3);
      end;
    end;

  finally
    Affine.Free;
    BmpCutout.Free;
    BmpRotated.Free;
    Mask.Free;
  end;
end;

end.
