﻿unit GR32_Resamplers;

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
 * The Original Code is Graphics32
 *
 * The Initial Developers of the Original Code is
 * Mattias Andersson <mattias@centaurix.com>
 * (parts of this unit were taken from GR32_Transforms.pas by Alex A. Denisov)
 *
 * Many of the filters here were adapted from:
 * - "Interpolated Bitmap Resampling using filters"
 *   Anders Melander, 1997
 * which in turn was based on:
 * - "General Filtered Image Rescaling"
 *   Dale Schumacher
 *   Graphics Gems III, Academic Press, Inc.
 *   1 July 1992
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2009
 * the Initial Developer. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$include GR32.inc}

// Define PREMULTIPLY to have TKernelResampler handle alpha correctly.
// The downside of the alpha handling is that the performance and
// precision of the resampler suffers slightly.
{$define PREMULTIPLY}


uses
  Classes,
  SysUtils, // Exception
  GR32,
  GR32_Transforms,
  GR32_Containers,
  GR32_OrdinalMaps,
  GR32_Blend;

//------------------------------------------------------------------------------
//
//      BlockTransfer
//
//------------------------------------------------------------------------------
// Unscaled block transfer
//------------------------------------------------------------------------------
procedure BlockTransfer(
  Dst: TCustomBitmap32; DstX: Integer; DstY: Integer; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent = nil);

procedure BlockTransferX(
  Dst: TCustomBitmap32; DstX, DstY: TFixed;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent = nil);


//------------------------------------------------------------------------------
//
//      StretchTransfer
//
//------------------------------------------------------------------------------
// Scaled block transfer using resampler
//------------------------------------------------------------------------------
procedure StretchTransfer(
  Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  Resampler: TCustomResampler;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent = nil);


//------------------------------------------------------------------------------
//
//      BlendTransfer
//
//------------------------------------------------------------------------------
// Unscaled block blend
//------------------------------------------------------------------------------
procedure BlendTransfer(
  Dst: TCustomBitmap32; DstX, DstY: Integer; DstClip: TRect;
  SrcF: TCustomBitmap32; SrcRectF: TRect;
  SrcB: TCustomBitmap32; SrcRectB: TRect;
  BlendCallback: TBlendReg); overload;

procedure BlendTransfer(
  Dst: TCustomBitmap32; DstX, DstY: Integer; DstClip: TRect;
  SrcF: TCustomBitmap32; SrcRectF: TRect;
  SrcB: TCustomBitmap32; SrcRectB: TRect;
  BlendCallback: TBlendRegEx; MasterAlpha: Integer); overload;


//------------------------------------------------------------------------------
//
//      Resampling
//
//------------------------------------------------------------------------------
const
  MAX_KERNEL_WIDTH = 16;

type
  PKernelEntry = ^TKernelEntry;
  TKernelEntry = array [-MAX_KERNEL_WIDTH..MAX_KERNEL_WIDTH] of Integer;

  TArrayOfKernelEntry = array of TArrayOfInteger;
  PKernelEntryArray = ^TKernelEntryArray;
  TKernelEntryArray = array [0..0] of TArrayOfInteger;

  TFilterMethod = function(Value: TFloat): TFloat of object;

  EBitmapException = class(Exception);
  ESrcInvalidException = class(Exception);
  ENestedException = class(Exception);
  ETransformerException = class(Exception);

  TGetSampleInt = function(X, Y: Integer): TColor32 of object;
  TGetSampleFloat = function(X, Y: TFloat): TColor32 of object;
  TGetSampleFixed = function(X, Y: TFixed): TColor32 of object;


//------------------------------------------------------------------------------
//
//      TCustomKernel
//
//------------------------------------------------------------------------------
// Abstract base class for resampler kernels.
//------------------------------------------------------------------------------
type
  TCustomKernel = class(TPersistent)
  protected
    FObserver: TNotifiablePersistent;
  protected
    procedure AssignTo(Dst: TPersistent); override;
    function RangeCheck: Boolean; virtual;
  public
    constructor Create; virtual;
    procedure Changed;
    function Filter(Value: TFloat): TFloat; virtual; abstract;
    function GetWidth: TFloat; virtual; abstract;
    property Observer: TNotifiablePersistent read FObserver;
  end;

  TCustomKernelClass = class of TCustomKernel;


//------------------------------------------------------------------------------
//
//      TBoxKernel
//
//------------------------------------------------------------------------------
// Nearest neighbor interpolation filter.
// Also known as box filter, top-hat function or a Fourier window.
//------------------------------------------------------------------------------
type
  TBoxKernel = class(TCustomKernel)
  public
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TLinearKernel
//
//------------------------------------------------------------------------------
// Linear reconstruction filter.
// Also known as triangle filter, tent filter, roof function, Chateau function
// or a Bartlett window.
//------------------------------------------------------------------------------
type
  TLinearKernel = class(TCustomKernel)
  public
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TCosineKernel
//
//------------------------------------------------------------------------------
// Cosine reconstruction filter.
//------------------------------------------------------------------------------
type
  TCosineKernel = class(TCustomKernel)
  public
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TSplineKernel
//
//------------------------------------------------------------------------------
// B-Spline interpolation filter.
// Not the same as the Spline windowed Sinc kernel.
//------------------------------------------------------------------------------
type
  TSplineKernel = class(TCustomKernel)
  protected
    function RangeCheck: Boolean; override;
  public
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TMitchellKernel
//
//------------------------------------------------------------------------------
// An implementation of a special case of the cubic filter described by Mitchell
// and Netravali using the parameters (B: 1/3, C: 1/3).
//
// References:
//
// - Don P. Mitchell & Arun N. Netravali
//   AT&T Bell Laboratories
//   "Reconstruction Filters in Computer Graphics"
//   Computer Graphics, Volume 22, Number 4, August 1988.
//
// Also known as Mitchell-Netravali.
// Many other variants of this filter, with various other values for B&C, exist.
// Often people come up with some variation of B&C and then put their own name
// on the filter. For example Robidoux (B:0.3782, C:0.3109), etc.
//
//------------------------------------------------------------------------------
type
  TMitchellKernel = class(TCustomKernel)
  protected
    function RangeCheck: Boolean; override;
  public
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TCubicKernel
//
//------------------------------------------------------------------------------
// A reconstruction filter described by a cubic polynomial.
//
// References:
//
// - Robert G. Keys
//   "Cubic convolution interpolation for digital image processing"
//   IEEE Transactions on Acoustics, Speech, and Signal Processing
//   Volume: 29, Issue: 6, December 1981
//
//------------------------------------------------------------------------------
type
  TCubicKernel = class(TCustomKernel)
  private
    FCoeff: TFloat;
    procedure SetCoeff(const Value: TFloat);
  protected
    function RangeCheck: Boolean; override;
  public
    constructor Create; override;
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  published
    property Coeff: TFloat read FCoeff write SetCoeff;
  end;


//------------------------------------------------------------------------------
//
//      THermiteKernel
//
//------------------------------------------------------------------------------
// An implementation of the hermite kernel.
//------------------------------------------------------------------------------
type
  THermiteKernel = class(TCustomKernel)
  private
    FBias: TFloat;
    FTension: TFloat;
    procedure SetBias(const Value: TFloat);
    procedure SetTension(const Value: TFloat);
  protected
    function RangeCheck: Boolean; override;
  public
    constructor Create; override;
    function Filter(Value: TFloat): TFloat; override;
    function GetWidth: TFloat; override;
  published
    property Bias: TFloat read FBias write SetBias;
    property Tension: TFloat read FTension write SetTension;
  end;


//------------------------------------------------------------------------------
//
//      TSinshKernel
//
//------------------------------------------------------------------------------
// A filter described by a hyperbolic sine, something, something.
//------------------------------------------------------------------------------
type
  TSinshKernel = class(TCustomKernel)
  private
    FWidth: TFloat;
    FCoeff: TFloat;
    procedure SetCoeff(const Value: TFloat);
  protected
    function RangeCheck: Boolean; override;
  public
    constructor Create; override;
    procedure SetWidth(Value: TFloat);
    function GetWidth: TFloat; override;
    function Filter(Value: TFloat): TFloat; override;
  published
    property Coeff: TFloat read FCoeff write SetCoeff;
    property Width: TFloat read GetWidth write SetWidth;
  end;


//------------------------------------------------------------------------------
//
//      TWindowedKernel
//
//------------------------------------------------------------------------------
// Abstract base class for windowed kernels.
// Returns the value of the filter function constrained by a window function.
// Descendant classes must override the Window method in order to implement a
// custom window function.
//------------------------------------------------------------------------------
type
  TWindowedKernel = class(TCustomKernel)
  strict protected
    FWidth : TFloat;
    FWidthReciprocal : TFloat;
  protected
    function RangeCheck: Boolean; override;
    function Window(Value: TFloat): TFloat; virtual; abstract;
    procedure DoSetWidth(Value: TFloat);
  public
    function Filter(Value: TFloat): TFloat; override;
    procedure SetWidth(Value: TFloat);
    function GetWidth: TFloat; override;
    property WidthReciprocal : TFloat read FWidthReciprocal;
  published
    property Width: TFloat read FWidth write SetWidth;
  end;


//------------------------------------------------------------------------------
//
//      TGaussianKernel
//
//------------------------------------------------------------------------------
// A kernel constrained by a Gaussian window function.
//------------------------------------------------------------------------------
type
  TGaussianKernel = class(TWindowedKernel)
  private
    FSigma: TFloat;
    FSigmaReciprocal: TFloat;
    FNormalizationFactor: Single;
    procedure DoSetSigma(const Value: TFloat);
    procedure SetSigma(const Value: TFloat);
  protected
    function Window(Value: TFloat): TFloat; override;
  public
    constructor Create; override;
  published
    property Sigma: TFloat read FSigma write SetSigma;
  end;

//------------------------------------------------------------------------------
//
//      TWindowedSincKernel
//
//------------------------------------------------------------------------------
// Abstract base class for windowed Sinc kernels.
// Returns the value of the Sinc function constrained by a window function.
// Descendant classes must override the Window method in order to implement a
// custom window function.
//------------------------------------------------------------------------------
type
  TWindowedSincKernel = class(TWindowedKernel)
  protected
    class function Sinc(Value: TFloat): TFloat; static;
  public
    constructor Create; override;
    function Filter(Value: TFloat): TFloat; override;
  published
    property Width: TFloat read FWidth write SetWidth;
  end;


//------------------------------------------------------------------------------
//
//      TAlbrecht-Kernel
//
//------------------------------------------------------------------------------
// A Sinc kernel constrained by Albrecht window functions.
//
// References:
//
// - Hans-Helge Albrecht
//   Physikalisch-Technische Bundesanstalt, Berlin, Germany
//   "A family of cosine-sum windows for high resolution measurements"
//   IEEE International Conference on Acoustics, Speech, and Signal Processing,
//   Salt Lake City, May 2001.
//
//------------------------------------------------------------------------------
type
  TAlbrechtKernel = class(TWindowedSincKernel)
  private
    FTerms: Integer;
    FCoefPointer : Array [0..11] of Double;
    procedure SetTerms(Value : Integer);
  protected
    function Window(Value: TFloat): TFloat; override;
  public
    constructor Create; override;
  published
    property Terms: Integer read FTerms write SetTerms;
  end;


//------------------------------------------------------------------------------
//
//      TLanczosKernel
//
//------------------------------------------------------------------------------
// A Sinc kernel constrained by a Lanczos window function.
// It uses three lobes of the Sinc filter as a window.
//
// References:
//
// - Claude E. Duchon
//   School of Meteorology, University of Oklahoma, USA
//   "Lanczos Filtering in One and Two Dimensions"
//   Journal of Applied Meteorology and Climatology, volume 18, pp. 1016-1022
//   1 Aug 1979
//
// Also known as Lanczo3.
//------------------------------------------------------------------------------
type
  TLanczosKernel = class(TWindowedSincKernel)
  protected
    function Window(Value: TFloat): TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TBlackmanKernel
//
//------------------------------------------------------------------------------
// A Sinc kernel constrained by a Blackman window function.
//
// References:
//
// - Ralph Beebe Blackman & John Wilder Tukey
//   "Particular Pairs of Windows"
//   The measurement of power spectra from the point of view of communications
//   engineering.
//   New York: Dover, pp. 98-99, 1959.
//
//------------------------------------------------------------------------------
type
  TBlackmanKernel = class(TWindowedSincKernel)
  protected
    function Window(Value: TFloat): TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      THannKernel
//
//------------------------------------------------------------------------------
// A Sinc kernel constrained by a Hann window function.
// Also known as raised cosine.
//
// References:
//
// - Ralph Beebe Blackman & John Wilder Tukey
//   The measurement of power spectra from the point of view of communications
//   engineering — Part I.
//   The Bell System Technical Journal. 37 (1), pp. 273, 1958.
//
// Supposedly based on work done by Julius von Hann, 1839-1921
//
//------------------------------------------------------------------------------
type
  THannKernel = class(TWindowedSincKernel)
  protected
    function Window(Value: TFloat): TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      THammingKernel
//
//------------------------------------------------------------------------------
// A Sinc kernel constrained by a Hamming window function.
//
// References:
//
// - Richard W. Hamming
//   "Digital Filters"
//   Prentice-Hall, 1977 pp. 226; 2nd ed. 1983; 3rd ed. 1989
//
//------------------------------------------------------------------------------
type
  THammingKernel = class(TWindowedSincKernel)
  protected
    function Window(Value: TFloat): TFloat; override;
  end;


//------------------------------------------------------------------------------
//
//      TNearestResampler
//
//------------------------------------------------------------------------------
// A fast resampler based on the nearest-neighbor interpolation algorithm.
//------------------------------------------------------------------------------
type
  TNearestResampler = class(TCustomResampler)
  private
    FGetSampleInt: TGetSampleInt;
  protected
    function GetPixelTransparentEdge(X, Y: Integer): TColor32;
    function GetWidth: TFloat; override;
    procedure Resample(
      Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
      Src: TCustomBitmap32; SrcRect: TRect;
      CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent); override;
  public
    function GetSampleInt(X, Y: Integer): TColor32; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
    function GetSampleFloat(X, Y: TFloat): TColor32; override;
    procedure PrepareSampling; override;
  end;


//------------------------------------------------------------------------------
//
//      TLinearResampler
//
//------------------------------------------------------------------------------
// Performance-optimized linear upsampler.
// Falls back to using TLinearKernel for downsampling.
//------------------------------------------------------------------------------
type
  TLinearResampler = class(TCustomResampler)
  private
    FLinearKernel: TLinearKernel;
    FGetSampleFixed: TGetSampleFixed;
  protected
    function GetWidth: TFloat; override;
    function GetPixelTransparentEdge(X, Y: TFixed): TColor32;
    procedure Resample(
      Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
      Src: TCustomBitmap32; SrcRect: TRect;
      CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
    function GetSampleFloat(X, Y: TFloat): TColor32; override;
    procedure PrepareSampling; override;
  end;


//------------------------------------------------------------------------------
//
//      TDraftResampler
//
//------------------------------------------------------------------------------
// Performance-optimized downsampler.
// Falls back to using TLinearResampler for upsampling.
//------------------------------------------------------------------------------
type
  TDraftResampler = class(TLinearResampler)
  protected
    procedure Resample(
      Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
      Src: TCustomBitmap32; SrcRect: TRect;
      CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent); override;
  end;


//------------------------------------------------------------------------------
//
//      TKernelResampler
//
//------------------------------------------------------------------------------
// This resampler class will perform resampling by using an arbitrary
// reconstruction kernel.
// By using the kmTableNearest and kmTableLinear kernel modes, kernel values are
// precomputed in a look-up table. This allows GetSample to execute faster for
// complex kernels.
//------------------------------------------------------------------------------
type
  TKernelMode = (kmDynamic, kmTableNearest, kmTableLinear);

  TKernelResampler = class(TCustomResampler)
  private
    FKernel: TCustomKernel;
    FKernelMode: TKernelMode;
    FWeightTable: TIntegerMap;
    FTableSize: Integer;
    FOuterColor: TColor32;
    procedure SetKernel(const Value: TCustomKernel);
    function GetKernelClassName: string;
    procedure SetKernelClassName(const Value: string);
    procedure SetKernelMode(const Value: TKernelMode);
    procedure SetTableSize(Value: Integer);
  protected
    function GetWidth: TFloat; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GetSampleFloat(X, Y: TFloat): TColor32; override;
    procedure Resample(
      Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
      Src: TCustomBitmap32; SrcRect: TRect;
      CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent); override;
    procedure PrepareSampling; override;
    procedure FinalizeSampling; override;
  published
    property KernelClassName: string read GetKernelClassName write SetKernelClassName;
    property Kernel: TCustomKernel read FKernel write SetKernel;
    property KernelMode: TKernelMode read FKernelMode write SetKernelMode;
    property TableSize: Integer read FTableSize write SetTableSize;
  end;


//------------------------------------------------------------------------------
//
//      TNestedSampler
//
//------------------------------------------------------------------------------
// TNestedSampler is a base class for chained or nested samplers.
//------------------------------------------------------------------------------
type
  TNestedSampler = class(TCustomSampler)
  private
    FSampler: TCustomSampler;
    FGetSampleInt: TGetSampleInt;
    FGetSampleFixed: TGetSampleFixed;
    FGetSampleFloat: TGetSampleFloat;
    procedure SetSampler(const Value: TCustomSampler);
  protected
    procedure AssignTo(Dst: TPersistent); override;
  public
    constructor Create(ASampler: TCustomSampler); reintroduce; virtual;
    procedure PrepareSampling; override;
    procedure FinalizeSampling; override;
    function HasBounds: Boolean; override;
    function GetSampleBounds: TFloatRect; override;
  published
    property Sampler: TCustomSampler read FSampler write SetSampler;
  end;


//------------------------------------------------------------------------------
//
//      TTransformer
//
//------------------------------------------------------------------------------
// TTransformer is a nested sampler that will transform the sampling coordinates
// using a transformation defined by a TTransformation descendant.
//------------------------------------------------------------------------------
type
  TTransformInt = procedure(DstX, DstY: Integer; out SrcX, SrcY: Integer) of object;
  TTransformFixed = procedure(DstX, DstY: TFixed; out SrcX, SrcY: TFixed) of object;
  TTransformFloat = procedure(DstX, DstY: TFloat; out SrcX, SrcY: TFloat) of object;

  TTransformer = class(TNestedSampler)
  private
    FTransformation: TTransformation;
    FTransformInt: TTransformInt; // Unused
    FTransformFixed: TTransformFixed;
    FTransformFloat: TTransformFloat;
    FReverse: boolean;
  public
    constructor Create(ASampler: TCustomSampler; ATransformation: TTransformation; AReverse: boolean = True); reintroduce;
    procedure PrepareSampling; override;
    function GetSampleInt(X, Y: Integer): TColor32; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
    function GetSampleFloat(X, Y: TFloat): TColor32; override;
    function HasBounds: Boolean; override;
    function GetSampleBounds: TFloatRect; override;
  published
    property Transformation: TTransformation read FTransformation write FTransformation;
    property ReverseTransform: boolean read FReverse write FReverse;
  end;


//------------------------------------------------------------------------------
//
//      TSuperSampler
//
//------------------------------------------------------------------------------
// TSuperSampler is a nested sampler that adds a mechanism for performing super
// sampling.
//------------------------------------------------------------------------------
type
  TSamplingRange = 1..MaxInt;

  TSuperSampler = class(TNestedSampler)
  private
    FSamplingY: TSamplingRange;
    FSamplingX: TSamplingRange;
    FDistanceX: TFixed;
    FDistanceY: TFixed;
    FOffsetX: TFixed;
    FOffsetY: TFixed;
    FScale: TFixed;
    procedure SetSamplingX(const Value: TSamplingRange);
    procedure SetSamplingY(const Value: TSamplingRange);
  public
    constructor Create(Sampler: TCustomSampler); override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
  published
    property SamplingX: TSamplingRange read FSamplingX write SetSamplingX;
    property SamplingY: TSamplingRange read FSamplingY write SetSamplingY;
  end;


//------------------------------------------------------------------------------
//
//      TAdaptiveSuperSampler
//
//------------------------------------------------------------------------------
// Adaptive supersampling is different from ordinary supersampling in the sense
// that samples are choosen adaptively; It is a recursive method that collects
// more samples at areas with rapid transitions.
//------------------------------------------------------------------------------
type
  TRecurseProc = function(X, Y, W: TFixed; const C1, C2: TColor32): TColor32 of object;

  TAdaptiveSuperSampler = class(TNestedSampler)
  private
    FMinOffset: TFixed;
    FLevel: Integer;
    FTolerance: Integer;
    procedure SetLevel(const Value: Integer);
    function DoRecurse(X, Y, Offset: TFixed; const A, B, C, D, E: TColor32): TColor32;
    function QuadrantColor(const C1, C2: TColor32; X, Y, Offset: TFixed;
      Proc: TRecurseProc): TColor32;
    function RecurseAC(X, Y, Offset: TFixed; const A, C: TColor32): TColor32;
    function RecurseBD(X, Y, Offset: TFixed; const B, D: TColor32): TColor32;
  protected
    function CompareColors(C1, C2: TColor32): Boolean; virtual;
  public
    constructor Create(Sampler: TCustomSampler); override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
  published
    property Level: Integer read FLevel write SetLevel;
    property Tolerance: Integer read FTolerance write FTolerance;
  end;


//------------------------------------------------------------------------------
//
//      TPatternSampler
//
//------------------------------------------------------------------------------
// TPatternSampler provides a mechanism for performing sampling according to a
// supplied sample pattern.
//------------------------------------------------------------------------------
type
  TFloatSamplePattern = array of array of TArrayOfFloatPoint;
  TFixedSamplePattern = array of array of TArrayOfFixedPoint;

  TPatternSampler = class(TNestedSampler)
  private
    FPattern: TFixedSamplePattern;
    procedure SetPattern(const Value: TFixedSamplePattern);
  protected
    WrapProcVert: TWrapProc;
  public
    destructor Destroy; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
    property Pattern: TFixedSamplePattern read FPattern write SetPattern;
  end;

  { Auxiliary record used in accumulation routines }
  PBufferEntry = ^TBufferEntry;
  TBufferEntry = record
    B, G, R, A: Integer;
  end;


//------------------------------------------------------------------------------
//
//      TKernelSampler
//
//------------------------------------------------------------------------------
// TKernelSampler is an abstract base class for samplers that compute an output
// sample by collecting a number of samples in a local region of the actual
// sample coordinate.
//------------------------------------------------------------------------------
type
  TKernelSampler = class(TNestedSampler)
  private
    FKernel: TIntegerMap;
    FStartEntry: TBufferEntry;
    FCenterX: Integer;
    FCenterY: Integer;
  protected
    procedure SetKernel(const Value: TIntegerMap);
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); virtual; abstract;
    function ConvertBuffer(var Buffer: TBufferEntry): TColor32; virtual;
  public
    constructor Create(ASampler: TCustomSampler); override;
    destructor Destroy; override;
    function GetSampleInt(X, Y: Integer): TColor32; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
  published
    property Kernel: TIntegerMap read FKernel write SetKernel;
    property CenterX: Integer read FCenterX write FCenterX;
    property CenterY: Integer read FCenterY write FCenterY;
  end;


//------------------------------------------------------------------------------
//
//      TConvolver
//
//------------------------------------------------------------------------------
// The TConvolver kernel sampler provides functionality for performing discrete
// convolution within a chain of nested samplers.
//------------------------------------------------------------------------------
type
  TConvolver = class(TKernelSampler)
  protected
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); override;
  end;


//------------------------------------------------------------------------------
//
//      TSelectiveConvolver
//
//------------------------------------------------------------------------------
// TSelectiveConvolver works similarly to TConvolver, but it will exclude color
// samples from the convolution depending on a the difference from a local
// reference sample value.
//------------------------------------------------------------------------------
type
  TSelectiveConvolver = class(TConvolver)
  private
    FRefColor: TColor32;
    FDelta: Integer;
    FWeightSum: TBufferEntry;
  protected
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); override;
    function ConvertBuffer(var Buffer: TBufferEntry): TColor32; override;
  public
    constructor Create(ASampler: TCustomSampler); override;
    function GetSampleInt(X, Y: Integer): TColor32; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
  published
    property Delta: Integer read FDelta write FDelta;
  end;


//------------------------------------------------------------------------------
//
//      TMorphologicalSampler
//
//------------------------------------------------------------------------------
// Abstract base class for TDilater and TEroder.
//------------------------------------------------------------------------------
type
  TMorphologicalSampler = class(TKernelSampler)
  protected
    function ConvertBuffer(var Buffer: TBufferEntry): TColor32; override;
  end;


//------------------------------------------------------------------------------
//
//      TDilater
//
//------------------------------------------------------------------------------
// TDilater is a nested sampler for performing morphological dilation.
//------------------------------------------------------------------------------
type
  TDilater = class(TMorphologicalSampler)
  protected
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); override;
  end;


//------------------------------------------------------------------------------
//
//      TEroder
//
//------------------------------------------------------------------------------
// TEroder is a nested sampler for performing morphological erosion
//------------------------------------------------------------------------------
type
  TEroder = class(TMorphologicalSampler)
  protected
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); override;
  public
    constructor Create(ASampler: TCustomSampler); override;
  end;


//------------------------------------------------------------------------------
//
//      TExpander
//
//------------------------------------------------------------------------------
// TExpander implements a neighborhood operation similar to morphological
// dilation.
//------------------------------------------------------------------------------
type
  TExpander = class(TKernelSampler)
  protected
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); override;
  end;


//------------------------------------------------------------------------------
//
//      TContracter
//
//------------------------------------------------------------------------------
// Similar to TExpander, but contracts instead of exanding.
//------------------------------------------------------------------------------
type
  TContracter = class(TExpander)
  private
    FMaxWeight: TColor32;
  protected
    procedure UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
      Weight: Integer); override;
  public
    procedure PrepareSampling; override;
    function GetSampleInt(X, Y: Integer): TColor32; override;
    function GetSampleFixed(X, Y: TFixed): TColor32; override;
  end;


//------------------------------------------------------------------------------
//
//      CreateJitteredPattern
//
//------------------------------------------------------------------------------
// Create a random jitter pattern for use with TPatternSampler.
//------------------------------------------------------------------------------
function CreateJitteredPattern(TileWidth, TileHeight, SamplesX, SamplesY: Integer): TFixedSamplePattern;


//------------------------------------------------------------------------------
//
//      Convolution and morphological routines
//
//------------------------------------------------------------------------------
// Kernel sampler wrapper functions.
//------------------------------------------------------------------------------
procedure Convolve(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
procedure Dilate(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
procedure Erode(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
procedure Expand(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
procedure Contract(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);


//------------------------------------------------------------------------------
//
//      Auxiliary routines for accumulating colors in a buffer
//
//------------------------------------------------------------------------------
procedure IncBuffer(var Buffer: TBufferEntry; Color: TColor32); {$IFDEF USEINLINING} inline; {$ENDIF}
procedure MultiplyBuffer(var Buffer: TBufferEntry; W: Integer); {$IFDEF USEINLINING} inline; {$ENDIF}
function BufferToColor32(const Buffer: TBufferEntry; Shift: Integer): TColor32; {$IFDEF USEINLINING} inline; {$ENDIF}
procedure ShrBuffer(var Buffer: TBufferEntry; Shift: Integer); {$IFDEF USEINLINING} inline; {$ENDIF}


//------------------------------------------------------------------------------
//
//      Downsample byte map
//
//------------------------------------------------------------------------------
procedure DownsampleByteMap2x(Source, Dest: TByteMap);
procedure DownsampleByteMap3x(Source, Dest: TByteMap);
procedure DownsampleByteMap4x(Source, Dest: TByteMap);


//------------------------------------------------------------------------------
//
//      Registration routines
//
//------------------------------------------------------------------------------
procedure RegisterResampler(ResamplerClass: TCustomResamplerClass);
procedure RegisterKernel(KernelClass: TCustomKernelClass);

type
{$if defined(NO_GENERIC_METACLASS_LISTS)}
  TKernelList = class(TClassList)
  public
    function Find(const AClassName: string): TCustomKernelClass;
  end;

  TResamplerList = class(TClassList)
  public
    function Find(const AClassName: string): TCustomResamplerClass;
  end;
{$else}
  TKernelList = TCustomClassList<TCustomKernelClass>;
  TResamplerList = TCustomClassList<TCustomResamplerClass>;
{$ifend}

var
  KernelList: TKernelList;
  ResamplerList: TResamplerList;

const
  EMPTY_ENTRY: TBufferEntry = (B: 0; G: 0; R: 0; A: 0) deprecated 'Use Default(TBufferEntry)';


//------------------------------------------------------------------------------
//
//      Bindings
//
//------------------------------------------------------------------------------
var
  BlockAverage: function(Dlx, Dly: Cardinal; RowSrc: PColor32; OffSrc: Cardinal): TColor32;
  Interpolator: function(WX_256, WY_256: Cardinal; C11, C21: PColor32): TColor32;


//------------------------------------------------------------------------------

resourcestring
  SDstNil = 'Destination bitmap is nil';
  SSrcNil = 'Source bitmap is nil';
  SSrcInvalid = 'Source rectangle is invalid';
  SSamplerNil = 'Nested sampler is nil';
  STransformationNil = 'Transformation is nil';

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

implementation

uses
  Math,
  Types,
  GR32_Bindings,
  GR32_LowLevel,
  GR32_Rasterizers,
  GR32_Math,
  GR32_Gamma;

resourcestring
  RCStrInvalidSrcRect = 'Invalid SrcRect';

const
  CAlbrecht2 : array [0..1] of Double = (5.383553946707251E-1,
    4.616446053292749E-1);
  CAlbrecht3 : array [0..2] of Double = (3.46100822018625E-1,
    4.97340635096738E-1, 1.56558542884637E-1);
  CAlbrecht4 : array [0..3] of Double = (2.26982412792069E-1,
    4.57254070828427E-1, 2.73199027957384E-1, 4.25644884221201E-2);
  CAlbrecht5 : array [0..4] of Double = (1.48942606015830E-1,
    3.86001173639176E-1, 3.40977403214053E-1, 1.139879604246E-1,
    1.00908567063414E-2);
  CAlbrecht6 : array [0..5] of Double = (9.71676200107429E-2,
    3.08845222524055E-1, 3.62623371437917E-1, 1.88953325525116E-1,
    4.02095714148751E-2, 2.20088908729420E-3);
  CAlbrecht7 : array [0..6] of Double = (6.39644241143904E-2,
    2.39938645993528E-1, 3.50159563238205E-1, 2.47741118970808E-1,
    8.54382560558580E-2, 1.23202033692932E-2, 4.37788257917735E-4);
  CAlbrecht8 : array [0..7] of Double = (4.21072107042137E-2,
    1.82076226633776E-1, 3.17713781059942E-1, 2.84438001373442E-1,
    1.36762237777383E-1, 3.34038053504025E-2, 3.41677216705768E-3,
    8.19649337831348E-5);
  CAlbrecht9 : array [0..8] of Double = (2.76143731612611E-2,
    1.35382228758844E-1, 2.75287234472237E-1, 2.98843335317801E-1,
    1.85319330279284E-1, 6.48884482549063E-2, 1.17641910285655E-2,
    8.85987580106899E-4, 1.48711469943406E-5);
  CAlbrecht10: array [0..9] of Double = (1.79908225352538E-2,
    9.87959586065210E-2, 2.29883817001211E-1, 2.94113019095183E-1,
    2.24338977814325E-1, 1.03248806248099E-1, 2.75674109448523E-2,
    3.83958622947123E-3, 2.18971708430106E-4, 2.62981665347889E-6);
  CAlbrecht11: array [0..10] of Double = (1.18717127796602E-2,
    7.19533651951142E-2, 1.87887160922585E-1, 2.75808174097291E-1,
    2.48904243244464E-1, 1.41729867200712E-1, 5.02002976228256E-2,
    1.04589649084984E-2, 1.13615112741660E-3, 4.96285981703436E-5,
    4.34303262685720E-7);

type
  TTransformationAccess = class(TTransformation);
  TCustomBitmap32Access = class(TCustomBitmap32);
  TCustomResamplerAccess = class(TCustomResampler);
  TCustomKernelAccess = class(TCustomKernel);

  TPointRec = record
    Pos: Integer;
    Weight: Integer;
  end;

  TCluster = array of TPointRec;
  TMappingTable = array of TCluster;

  TKernelSamplerClass = class of TKernelSampler;

{ Auxiliary rasterization routine for kernel-based samplers }
procedure RasterizeKernelSampler(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap;
  CenterX, CenterY: Integer; SamplerClass: TKernelSamplerClass);
var
  Sampler: TKernelSampler;
  Rasterizer: TRasterizer;
begin
  Rasterizer := DefaultRasterizerClass.Create;
  try
    Dst.SetSizeFrom(Src);
    Sampler := SamplerClass.Create(Src.Resampler);
    try
      Sampler.Kernel := Kernel;
      Sampler.CenterX := CenterX;
      Sampler.CenterY := CenterY;

      Rasterizer.Sampler := Sampler;
      Rasterizer.Rasterize(Dst);
    finally
      Sampler.Free;
    end;
  finally
    Rasterizer.Free;
  end;
end;

procedure Convolve(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
begin
  RasterizeKernelSampler(Src, Dst, Kernel, CenterX, CenterY, TConvolver);
end;

procedure Dilate(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
begin
  RasterizeKernelSampler(Src, Dst, Kernel, CenterX, CenterY, TDilater);
end;

procedure Erode(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
begin
  RasterizeKernelSampler(Src, Dst, Kernel, CenterX, CenterY, TEroder);
end;

procedure Expand(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
begin
  RasterizeKernelSampler(Src, Dst, Kernel, CenterX, CenterY, TExpander);
end;

procedure Contract(Src, Dst: TCustomBitmap32; Kernel: TIntegerMap; CenterX, CenterY: Integer);
begin
  RasterizeKernelSampler(Src, Dst, Kernel, CenterX, CenterY, TContracter);
end;

{ Auxiliary routines }

procedure IncBuffer(var Buffer: TBufferEntry; Color: TColor32);
begin
  with TColor32Entry(Color) do
  begin
    Inc(Buffer.B, B);
    Inc(Buffer.G, G);
    Inc(Buffer.R, R);
    Inc(Buffer.A, A);
  end;
end;

procedure MultiplyBuffer(var Buffer: TBufferEntry; W: Integer);
begin
  Buffer.B := Buffer.B * W;
  Buffer.G := Buffer.G * W;
  Buffer.R := Buffer.R * W;
  Buffer.A := Buffer.A * W;
end;

procedure ShrBuffer(var Buffer: TBufferEntry; Shift: Integer);
begin
  Buffer.B := Buffer.B shr Shift;
  Buffer.G := Buffer.G shr Shift;
  Buffer.R := Buffer.R shr Shift;
  Buffer.A := Buffer.A shr Shift;
end;

function BufferToColor32(const Buffer: TBufferEntry; Shift: Integer): TColor32;
begin
  with TColor32Entry(Result) do
  begin
    B := Buffer.B shr Shift;
    G := Buffer.G shr Shift;
    R := Buffer.R shr Shift;
    A := Buffer.A shr Shift;
  end;
end;

procedure CheckBitmaps(Dst, Src: TCustomBitmap32); {$IFDEF USEINLINING}inline;{$ENDIF}
begin
  if not Assigned(Dst) then raise EBitmapException.Create(SDstNil);
  if not Assigned(Src) then raise EBitmapException.Create(SSrcNil);
end;

procedure BlendBlock(
  Dst: TCustomBitmap32; DstRect: TRect;
  Src: TCustomBitmap32; SrcX, SrcY: Integer;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  SrcP, DstP: PColor32;
  SP, DP: PColor32;
  MC: TColor32;
  W, I, DstY: Integer;
  BlendLine: TBlendLine;
  BlendLineEx: TBlendLineEx;
begin
  { Internal routine }
  W := DstRect.Right - DstRect.Left;
  SrcP := Src.PixelPtr[SrcX, SrcY];
  DstP := Dst.PixelPtr[DstRect.Left, DstRect.Top];

  case CombineOp of
    dmOpaque:
      begin
        for DstY := DstRect.Top to DstRect.Bottom - 1 do
        begin
          //Move(SrcP^, DstP^, W shl 2); // for FastCode
          MoveLongWord(SrcP^, DstP^, W);
          Inc(SrcP, Src.Width);
          Inc(DstP, Dst.Width);
        end;
      end;
    dmBlend:
      if Src.MasterAlpha >= 255 then
      begin
        BlendLine := BLEND_LINE[Src.CombineMode]^;
        for DstY := DstRect.Top to DstRect.Bottom - 1 do
        begin
          BlendLine(SrcP, DstP, W);
          Inc(SrcP, Src.Width);
          Inc(DstP, Dst.Width);
        end
      end
      else
      begin
        BlendLineEx := BLEND_LINE_EX[Src.CombineMode]^;
        for DstY := DstRect.Top to DstRect.Bottom - 1 do
        begin
          BlendLineEx(SrcP, DstP, W, Src.MasterAlpha);
          Inc(SrcP, Src.Width);
          Inc(DstP, Dst.Width);
        end
      end;
    dmTransparent:
      begin
        MC := Src.OuterColor;
        for DstY := DstRect.Top to DstRect.Bottom - 1 do
        begin
          SP := SrcP;
          DP := DstP;
          { TODO: Write an optimized routine for fast masked transfers. }
          for I := 0 to W - 1 do
          begin
            if MC <> SP^ then DP^ := SP^;
            Inc(SP); Inc(DP);
          end;
          Inc(SrcP, Src.Width);
          Inc(DstP, Dst.Width);
        end;
      end;
    else //  dmCustom:
      begin
        for DstY := DstRect.Top to DstRect.Bottom - 1 do
        begin
          SP := SrcP;
          DP := DstP;
          for I := 0 to W - 1 do
          begin
            CombineCallBack(SP^, DP^, Src.MasterAlpha);
            Inc(SP); Inc(DP);
          end;
          Inc(SrcP, Src.Width);
          Inc(DstP, Dst.Width);
        end;
      end;
    end;
end;


//------------------------------------------------------------------------------
//
//      BlockTransfer
//
//------------------------------------------------------------------------------
procedure BlockTransfer(
  Dst: TCustomBitmap32; DstX: Integer; DstY: Integer; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  SrcX, SrcY: Integer;
begin
  CheckBitmaps(Dst, Src);
  if Dst.Empty or Src.Empty or ((CombineOp = dmBlend) and (Src.MasterAlpha = 0)) then Exit;

  SrcX := SrcRect.Left;
  SrcY := SrcRect.Top;

  GR32.IntersectRect(DstClip, DstClip, Dst.BoundsRect);
  GR32.IntersectRect(SrcRect, SrcRect, Src.BoundsRect);

  GR32.OffsetRect(SrcRect, DstX - SrcX, DstY - SrcY);
  GR32.IntersectRect(SrcRect, DstClip, SrcRect);
  if GR32.IsRectEmpty(SrcRect) then
    exit;

  DstClip := SrcRect;
  GR32.OffsetRect(SrcRect, SrcX - DstX, SrcY - DstY);

  if not Dst.MeasuringMode then
  begin
    if (CombineOp = dmCustom) and not Assigned(CombineCallBack) then
      CombineOp := dmOpaque;

    BlendBlock(Dst, DstClip, Src, SrcRect.Left, SrcRect.Top, CombineOp, CombineCallBack);
  end;

  Dst.Changed(DstClip);
end;

//------------------------------------------------------------------------------

{$WARNINGS OFF}
procedure BlockTransferX(
  Dst: TCustomBitmap32; DstX, DstY: TFixed;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent = nil);
type
  TColor32Array = array [0..1] of TColor32;
  PColor32Array = ^TColor32Array;
var
  I, Index, SrcW, SrcRectW, SrcRectH, DstW, DstH: Integer;
  FracX, FracY: Integer;
  Buffer: array [0..1] of TArrayOfColor32;
  SrcP, Buf1, Buf2: PColor32Array;
  DstP: PColor32;
  C1, C2, C3, C4: TColor32;
  LW, RW, TW, BW, MA: Integer;
  DstBounds: TRect;

  BlendLineEx: TBlendLineEx;
  BlendMemEx: TBlendMemEx;
begin
  CheckBitmaps(Dst, Src);
  if Dst.Empty or Src.Empty or ((CombineOp = dmBlend) and (Src.MasterAlpha = 0)) then Exit;

  SrcRectW := SrcRect.Right - SrcRect.Left - 1;
  SrcRectH := SrcRect.Bottom - SrcRect.Top - 1;

  FracX := (DstX and $FFFF) shr 8;
  FracY := (DstY and $FFFF) shr 8;

  DstX := DstX div $10000;
  DstY := DstY div $10000;

  DstW := Dst.Width;
  DstH := Dst.Height;

  MA := Src.MasterAlpha;

  if (DstX >= DstW) or (DstY >= DstH) or (MA = 0) then Exit;

  if (DstX + SrcRectW <= 0) or (Dsty + SrcRectH <= 0) then Exit;

  if DstX < 0 then LW := $FF else LW := FracX xor $FF;
  if DstY < 0 then TW := $FF else TW := FracY xor $FF;
  if DstX + SrcRectW >= DstW then RW := $FF else RW := FracX;
  if DstY + SrcRectH >= DstH then BW := $FF else BW := FracY;

  DstBounds := Dst.BoundsRect;
  Dec(DstBounds.Right);
  Dec(DstBounds.Bottom);
  GR32.OffsetRect(DstBounds, SrcRect.Left - DstX, SrcRect.Top - DstY);
  GR32.IntersectRect(SrcRect, SrcRect, DstBounds);

  if GR32.IsRectEmpty(SrcRect) then Exit;

  SrcW := Src.Width;

  SrcRectW := SrcRect.Right - SrcRect.Left;
  SrcRectH := SrcRect.Bottom - SrcRect.Top;

  if DstX < 0 then DstX := 0;
  if DstY < 0 then DstY := 0;

  if not Dst.MeasuringMode then
  begin
    SetLength(Buffer[0], SrcRectW + 1);
    SetLength(Buffer[1], SrcRectW + 1);

    BlendLineEx := BLEND_LINE_EX[Src.CombineMode]^;
    BlendMemEx := BLEND_MEM_EX[Src.CombineMode]^;

    try
      SrcP := PColor32Array(Src.PixelPtr[SrcRect.Left, SrcRect.Top - 1]);
      DstP := Dst.PixelPtr[DstX, DstY];

      Buf1 := @Buffer[0][0];
      Buf2 := @Buffer[1][0];

      if SrcRect.Top > 0 then
      begin
        MoveLongWord(SrcP[0], Buf1[0], SrcRectW);
        CombineLine(@Buf1[1], @Buf1[0], SrcRectW, FracX);

        if SrcRect.Left > 0 then
          C2 := CombineReg(PColor32(NativeUInt(SrcP) - 4)^, SrcP[0], FracX xor $FF)
        else
          C2 := SrcP[0];

        if SrcRect.Right < SrcW then
          C4 := CombineReg(SrcP[SrcRectW - 1], SrcP[SrcRectW], FracX)
        else
          C4 := SrcP[SrcRectW - 1];
      end;

      Inc(PColor32(SrcP), SrcW);
      MoveLongWord(SrcP^, Buf2^, SrcRectW);
      CombineLine(@Buf2[1], @Buf2[0], SrcRectW, FracX xor $FF);

      if SrcRect.Left > 0 then
        C1 := CombineReg(PColor32(NativeUInt(SrcP) - 4)^, SrcP[0], FracX)
      else
        C1 := SrcP[0];

      if SrcRect.Right < SrcW then
        C3 := CombineReg(SrcP[SrcRectW - 1], SrcP[SrcRectW], FracX)
      else
        C3 := SrcP[SrcRectW - 1];

      if SrcRect.Top > 0 then
      begin
        BlendMemEx(CombineReg(C1, C2, FracY), DstP^, LW * TW * MA shr 16);
        CombineLine(@Buf2[0], @Buf1[0], SrcRectW, FracY xor $FF);
      end
      else
      begin
        BlendMemEx(C1, DstP^, LW * TW * MA shr 16);
        MoveLongWord(Buf2^, Buf1^, SrcRectW);
      end;

      Inc(DstP, 1);
      BlendLineEx(@Buf1[0], DstP, SrcRectW - 1, TW * MA shr 8);

      Inc(DstP, SrcRectW - 1);

      if SrcRect.Top > 0 then
        BlendMemEx(CombineReg(C3, C4, FracY), DstP^, RW * TW * MA shr 16)
      else
        BlendMemEx(C3, DstP^, RW * TW * MA shr 16);

      Inc(DstP, DstW - SrcRectW);

      Index := 1;
      for I := SrcRect.Top to SrcRect.Bottom - 2 do
      begin
        Buf1 := @Buffer[Index][0];
        Buf2 := @Buffer[Index xor 1][0];
        Inc(PColor32(SrcP), SrcW);

        MoveLongWord(SrcP[0], Buf2^, SrcRectW);

        // Horizontal translation
        CombineLine(@Buf2[1], @Buf2[0], SrcRectW, FracX xor $FF);

        if SrcRect.Left > 0 then
          C2 := CombineReg(PColor32(NativeUInt(SrcP) - 4)^, SrcP[0], FracX xor $FF)
        else
          C2 := SrcP[0];

        BlendMemEx(CombineReg(C1, C2, FracY), DstP^, LW * MA shr 8);
        Inc(DstP);
        C1 := C2;

        // Vertical translation
        CombineLine(@Buf2[0], @Buf1[0], SrcRectW, FracY xor $FF);

        // Blend horizontal line to Dst
        BlendLineEx(@Buf1[0], DstP, SrcRectW - 1, MA);
        Inc(DstP, SrcRectW - 1);

        if SrcRect.Right < SrcW then
          C4 := CombineReg(SrcP[SrcRectW - 1], SrcP[SrcRectW], FracX)
        else
          C4 := SrcP[SrcRectW - 1];

        BlendMemEx(CombineReg(C3, C4, FracY), DstP^, RW * MA shr 8);

        Inc(DstP, DstW - SrcRectW);
        C3 := C4;

        Index := Index xor 1;
      end;

      Buf1 := @Buffer[Index][0];
      Buf2 := @Buffer[Index xor 1][0];

      Inc(PColor32(SrcP), SrcW);

      if SrcRect.Bottom < Src.Height then
      begin
        MoveLongWord(SrcP[0], Buf2^, SrcRectW);
        CombineLine(@Buf2[1], @Buf2[0], SrcRectW, FracY xor $FF);
        CombineLine(@Buf2[0], @Buf1[0], SrcRectW, FracY xor $FF);
        if SrcRect.Left > 0 then
          C2 := CombineReg(PColor32(NativeUInt(SrcP) - 4)^, SrcP[0], FracX xor $FF)
        else
          C2 := SrcP[0];
        BlendMemEx(CombineReg(C1, C2, FracY), DstP^, LW * BW * MA shr 16)
      end
      else
        BlendMemEx(C1, DstP^, LW * BW * MA shr 16);

      Inc(DstP);
      BlendLineEx(@Buf1[0], DstP, SrcRectW - 1, BW * MA shr 8);
      Inc(DstP, SrcRectW - 1);

      if SrcRect.Bottom < Src.Height then
      begin
        if SrcRect.Right < SrcW then
          C4 := CombineReg(SrcP[SrcRectW - 1], SrcP[SrcRectW], FracX)
        else
          C4 := SrcP[SrcRectW - 1];
        BlendMemEx(CombineReg(C3, C4, FracY), DstP^, RW * BW * MA shr 16);
      end
      else
        BlendMemEx(C3, DstP^, RW * BW * MA shr 16);

    finally
      Buffer[0] := nil;
      Buffer[1] := nil;
    end;
  end;

  Dst.Changed(MakeRect(DstX, DstY, DstX + SrcRectW + 1, DstY + SrcRectH + 1));
end;
{$WARNINGS ON}


//------------------------------------------------------------------------------
//
//      BlendTransfer
//
//------------------------------------------------------------------------------
procedure BlendTransfer(
  Dst: TCustomBitmap32; DstX, DstY: Integer; DstClip: TRect;
  SrcF: TCustomBitmap32; SrcRectF: TRect;
  SrcB: TCustomBitmap32; SrcRectB: TRect;
  BlendCallback: TBlendReg);
var
  I, J, SrcFX, SrcFY, SrcBX, SrcBY: Integer;
  PSrcF, PSrcB, PDst: PColor32Array;
begin
  if not Assigned(Dst) then raise EBitmapException.Create(SDstNil);
  if not Assigned(SrcF) then raise EBitmapException.Create(SSrcNil);
  if not Assigned(SrcB) then raise EBitmapException.Create(SSrcNil);

  if Dst.Empty or SrcF.Empty or SrcB.Empty or not Assigned(BlendCallback) then Exit;

  if not Dst.MeasuringMode then
  begin
    SrcFX := SrcRectF.Left - DstX;
    SrcFY := SrcRectF.Top - DstY;
    SrcBX := SrcRectB.Left - DstX;
    SrcBY := SrcRectB.Top - DstY;

    GR32.IntersectRect(DstClip, DstClip, Dst.BoundsRect);
    GR32.IntersectRect(SrcRectF, SrcRectF, SrcF.BoundsRect);
    GR32.IntersectRect(SrcRectB, SrcRectB, SrcB.BoundsRect);

    GR32.OffsetRect(SrcRectF, -SrcFX, -SrcFY);
    GR32.OffsetRect(SrcRectB, -SrcBX, -SrcBY);

    GR32.IntersectRect(DstClip, DstClip, SrcRectF);
    GR32.IntersectRect(DstClip, DstClip, SrcRectB);

    if not GR32.IsRectEmpty(DstClip) then
      for I := DstClip.Top to DstClip.Bottom - 1 do
      begin
        PSrcF := PColor32Array(SrcF.PixelPtr[SrcFX, SrcFY + I]);
        PSrcB := PColor32Array(SrcB.PixelPtr[SrcBX, SrcBY + I]);
        PDst := Dst.ScanLine[I];
        for J := DstClip.Left to DstClip.Right - 1 do
          PDst[J] := BlendCallback(PSrcF[J], PSrcB[J]);
      end;
  end;
  Dst.Changed(DstClip);
end;

//------------------------------------------------------------------------------

procedure BlendTransfer(
  Dst: TCustomBitmap32; DstX, DstY: Integer; DstClip: TRect;
  SrcF: TCustomBitmap32; SrcRectF: TRect;
  SrcB: TCustomBitmap32; SrcRectB: TRect;
  BlendCallback: TBlendRegEx; MasterAlpha: Integer);
var
  I, J, SrcFX, SrcFY, SrcBX, SrcBY: Integer;
  PSrcF, PSrcB, PDst: PColor32Array;
begin
  if not Assigned(Dst) then raise EBitmapException.Create(SDstNil);
  if not Assigned(SrcF) then raise EBitmapException.Create(SSrcNil);
  if not Assigned(SrcB) then raise EBitmapException.Create(SSrcNil);

  if Dst.Empty or SrcF.Empty or SrcB.Empty or not Assigned(BlendCallback) then Exit;

  if not Dst.MeasuringMode then
  begin
    SrcFX := SrcRectF.Left - DstX;
    SrcFY := SrcRectF.Top - DstY;
    SrcBX := SrcRectB.Left - DstX;
    SrcBY := SrcRectB.Top - DstY;

    GR32.IntersectRect(DstClip, DstClip, Dst.BoundsRect);
    GR32.IntersectRect(SrcRectF, SrcRectF, SrcF.BoundsRect);
    GR32.IntersectRect(SrcRectB, SrcRectB, SrcB.BoundsRect);

    GR32.OffsetRect(SrcRectF, -SrcFX, -SrcFY);
    GR32.OffsetRect(SrcRectB, -SrcBX, -SrcBY);

    GR32.IntersectRect(DstClip, DstClip, SrcRectF);
    GR32.IntersectRect(DstClip, DstClip, SrcRectB);

    if not GR32.IsRectEmpty(DstClip) then
      for I := DstClip.Top to DstClip.Bottom - 1 do
      begin
        PSrcF := PColor32Array(SrcF.PixelPtr[SrcFX, SrcFY + I]);
        PSrcB := PColor32Array(SrcB.PixelPtr[SrcBX, SrcBY + I]);
        PDst := Dst.ScanLine[I];
        for J := DstClip.Left to DstClip.Right - 1 do
          PDst[J] := BlendCallback(PSrcF[J], PSrcB[J], MasterAlpha);
      end;
  end;
  Dst.Changed(DstClip);
end;


//------------------------------------------------------------------------------
//
//      StretchNearest
//
//------------------------------------------------------------------------------
// Used by TNearestResampler.Resample
//------------------------------------------------------------------------------
procedure StretchNearest(
  Dst: TCustomBitmap32; DstRect, DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  R: TRect;
  SrcW, SrcH, DstW, DstH, DstClipW, DstClipH: Integer;
  SrcY, OldSrcY: Integer;
  I, J: Integer;
  MapHorz: PIntegerArray;
  SrcLine, DstLine: PColor32Array;
  Buffer: TArrayOfColor32;
  Scale: TFloat;
  BlendLine: TBlendLine;
  BlendLineEx: TBlendLineEx;
  DstLinePtr, MapPtr: PColor32;
begin
  GR32.IntersectRect(DstClip, DstClip, MakeRect(0, 0, Dst.Width, Dst.Height));
  GR32.IntersectRect(DstClip, DstClip, DstRect);
  if GR32.IsRectEmpty(DstClip) then Exit;
  GR32.IntersectRect(R, DstClip, DstRect);
  if GR32.IsRectEmpty(R) then Exit;
  if (SrcRect.Left < 0) or (SrcRect.Top < 0) or (SrcRect.Right > Src.Width) or
    (SrcRect.Bottom > Src.Height) then
    raise Exception.Create(RCStrInvalidSrcRect);

  SrcW := SrcRect.Right - SrcRect.Left;
  SrcH := SrcRect.Bottom - SrcRect.Top;
  DstW := DstRect.Right - DstRect.Left;
  DstH := DstRect.Bottom - DstRect.Top;
  DstClipW := DstClip.Right - DstClip.Left;
  DstClipH := DstClip.Bottom - DstClip.Top;

  if (SrcW = DstW) and (SrcH = DstH) then
  begin
    { Copy without resampling }
    BlendBlock(Dst, DstClip, Src, SrcRect.Left + DstClip.Left - DstRect.Left,
      SrcRect.Top + DstClip.Top - DstRect.Top, CombineOp, CombineCallBack);
  end
  else
  begin
    GetMem(MapHorz, DstClipW * SizeOf(Integer));
    try
      if DstW > 1 then
      begin
        if FullEdge then
        begin
          Scale := SrcW / DstW;
          for I := 0 to DstClipW - 1 do
            MapHorz^[I] := Trunc(SrcRect.Left + (I + DstClip.Left - DstRect.Left) * Scale);
        end
        else
        begin
          Scale := (SrcW - 1) / (DstW - 1);
          for I := 0 to DstClipW - 1 do
            MapHorz^[I] := Round(SrcRect.Left + (I + DstClip.Left - DstRect.Left) * Scale);
        end;
        
        Assert(MapHorz^[0] >= SrcRect.Left);
        Assert(MapHorz^[DstClipW - 1] < SrcRect.Right);
      end
      else
        MapHorz^[0] := (SrcRect.Left + SrcRect.Right - 1) div 2;

      if DstH <= 1 then Scale := 0
      else if FullEdge then Scale := SrcH / DstH
      else Scale := (SrcH - 1) / (DstH - 1);

      if CombineOp = dmOpaque then
      begin
        DstLine := PColor32Array(Dst.PixelPtr[DstClip.Left, DstClip.Top]);
        OldSrcY := -1;
        
        for J := 0 to DstClipH - 1 do
        begin
          if DstH <= 1 then
            SrcY := (SrcRect.Top + SrcRect.Bottom - 1) div 2
          else if FullEdge then
            SrcY := Trunc(SrcRect.Top + (J + DstClip.Top - DstRect.Top) * Scale)
          else
            SrcY := Round(SrcRect.Top + (J + DstClip.Top - DstRect.Top) * Scale);
            
          if SrcY <> OldSrcY then
          begin
            SrcLine := Src.ScanLine[SrcY];
            DstLinePtr := @DstLine[0];
            MapPtr := @MapHorz^[0];
            for I := 0 to DstClipW - 1 do
            begin
              DstLinePtr^ := SrcLine[MapPtr^];
              Inc(DstLinePtr);
              Inc(MapPtr);
            end;
            OldSrcY := SrcY;
          end
          else
            MoveLongWord(DstLine[-Dst.Width], DstLine[0], DstClipW);
          Inc(DstLine, Dst.Width);
        end;
      end
      else
      begin
        SetLength(Buffer, DstClipW);
        DstLine := PColor32Array(Dst.PixelPtr[DstClip.Left, DstClip.Top]);
        OldSrcY := -1;

        if Src.MasterAlpha >= 255 then
        begin
          BlendLine := BLEND_LINE[Src.CombineMode]^;
          BlendLineEx := nil; // stop compiler warnings...
        end
        else
        begin
          BlendLineEx := BLEND_LINE_EX[Src.CombineMode]^;
          BlendLine := nil; // stop compiler warnings...
        end;

        for J := 0 to DstClipH - 1 do
        begin
          if DstH > 1 then
          begin
            if FullEdge then
              SrcY := Trunc(SrcRect.Top + (J + DstClip.Top - DstRect.Top) * Scale)
            else
              SrcY := Round(SrcRect.Top + (J + DstClip.Top - DstRect.Top) * Scale);
          end
          else
            SrcY := (SrcRect.Top + SrcRect.Bottom - 1) div 2;
            
          if SrcY <> OldSrcY then
          begin
            SrcLine := Src.ScanLine[SrcY];
            DstLinePtr := @Buffer[0];
            MapPtr := @MapHorz^[0];
            for I := 0 to DstClipW - 1 do
            begin
              DstLinePtr^ := SrcLine[MapPtr^];
              Inc(DstLinePtr);
              Inc(MapPtr);
            end;
            OldSrcY := SrcY;
          end;

          case CombineOp of
            dmBlend:
              if Src.MasterAlpha >= 255 then
                BlendLine(@Buffer[0], @DstLine[0], DstClipW)
              else
                BlendLineEx(@Buffer[0], @DstLine[0], DstClipW, Src.MasterAlpha);
            dmTransparent:
              for I := 0 to DstClipW - 1 do
                if Buffer[I] <> Src.OuterColor then DstLine[I] := Buffer[I];
            dmCustom:
              for I := 0 to DstClipW - 1 do
                CombineCallBack(Buffer[I], DstLine[I], Src.MasterAlpha);
          end;

          Inc(DstLine, Dst.Width);
        end;
      end;
    finally
      FreeMem(MapHorz);
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      StretchNearest
//
//------------------------------------------------------------------------------
// Used by TDraftResampler.Resample (via DraftResample) and TLinearResampler.Resample
//------------------------------------------------------------------------------
procedure StretchHorzStretchVertLinear(
  Dst: TCustomBitmap32; DstRect, DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
//Assure DstRect is >= SrcRect, otherwise quality loss will occur
var
  SrcW, SrcH, DstW, DstH, DstClipW, DstClipH: Integer;
  MapHorz, MapVert: array of TPointRec;
  t2, Scale: TFloat;
  SrcLine, DstLine: PColor32Array;
  SrcIndex: Integer;
  SrcPtr1, SrcPtr2: PColor32;
  I, J: Integer;
  WY: Cardinal;
  C: TColor32;
  BlendMemEx: TBlendMemEx;
begin
  SrcW := SrcRect.Right - SrcRect.Left;
  SrcH := SrcRect.Bottom - SrcRect.Top;
  DstW := DstRect.Right - DstRect.Left;
  DstH := DstRect.Bottom - DstRect.Top;
  DstClipW := DstClip.Right - DstClip.Left;
  DstClipH := DstClip.Bottom - DstClip.Top;

  SetLength(MapHorz, DstClipW);
  if FullEdge then Scale := SrcW / DstW
  else Scale := (SrcW - 1) / (DstW - 1);
  for I := 0 to DstClipW - 1 do
  begin
    if FullEdge then t2 := SrcRect.Left - 0.5 + (I + DstClip.Left - DstRect.Left + 0.5) * Scale
    else t2 := SrcRect.Left + (I + DstClip.Left - DstRect.Left) * Scale;
    if t2 < 0 then t2 := 0
    else if t2 > Src.Width - 1 then t2 := Src.Width - 1;
    MapHorz[I].Pos := Floor(t2);
    MapHorz[I].Weight := 256 - Round(Frac(t2) * 256);
    //Pre-pack weights to reduce MMX Reg. setups per pixel:
    //MapHorz[I].Weight:= MapHorz[I].Weight shl 16 + MapHorz[I].Weight;
  end;
  I := DstClipW - 1;
  while MapHorz[I].Pos = SrcRect.Right - 1 do
  begin
    Dec(MapHorz[I].Pos);
    MapHorz[I].Weight := 0;
    Dec(I);
  end;

  SetLength(MapVert, DstClipH);
  if FullEdge then Scale := SrcH / DstH
  else Scale := (SrcH - 1) / (DstH - 1);
  for I := 0 to DstClipH - 1 do
  begin
    if FullEdge then t2 := SrcRect.Top - 0.5 + (I + DstClip.Top - DstRect.Top + 0.5) * Scale
    else t2 := SrcRect.Top + (I + DstClip.Top - DstRect.Top) * Scale;
    if t2 < 0 then t2 := 0
    else if t2 > Src.Height - 1 then t2 := Src.Height - 1;
    MapVert[I].Pos := Floor(t2);
    MapVert[I].Weight := 256 - Round(Frac(t2) * 256);
    //Pre-pack weights to reduce MMX Reg. setups per pixel:
    //MapVert[I].Weight := MapVert[I].Weight shl 16 + MapVert[I].Weight;
  end;
  I := DstClipH - 1;
  while MapVert[I].Pos = SrcRect.Bottom - 1 do
  begin
    Dec(MapVert[I].Pos);
    MapVert[I].Weight := 0;
    Dec(I);
  end;

  DstLine := PColor32Array(Dst.PixelPtr[DstClip.Left, DstClip.Top]);
  SrcW := Src.Width;
  DstW := Dst.Width;
  case CombineOp of
    dmOpaque:
      for J := 0 to DstClipH - 1 do
      begin
        SrcLine := Src.ScanLine[MapVert[J].Pos];
        WY := MapVert[J].Weight;

        SrcIndex := MapHorz[0].Pos;
        SrcPtr1 := @SrcLine[SrcIndex];
        SrcPtr2 := @SrcLine[SrcIndex + SrcW];
        for I := 0 to DstClipW - 1 do
        begin
          if SrcIndex <> MapHorz[I].Pos then
          begin
            SrcIndex := MapHorz[I].Pos;
            SrcPtr1 := @SrcLine[SrcIndex];
            SrcPtr2 := @SrcLine[SrcIndex + SrcW];
          end;
          DstLine[I] := Interpolator(MapHorz[I].Weight, WY, SrcPtr1, SrcPtr2);
        end;
        Inc(DstLine, DstW);
      end;

    dmBlend:
      begin
        BlendMemEx := BLEND_MEM_EX[Src.CombineMode]^;
        for J := 0 to DstClipH - 1 do
        begin
          SrcLine := Src.ScanLine[MapVert[J].Pos];
          WY := MapVert[J].Weight;
          SrcIndex := MapHorz[0].Pos;
          SrcPtr1 := @SrcLine[SrcIndex];
          SrcPtr2 := @SrcLine[SrcIndex + SrcW];
          for I := 0 to DstClipW - 1 do
          begin
            if SrcIndex <> MapHorz[I].Pos then
            begin
              SrcIndex := MapHorz[I].Pos;
              SrcPtr1 := @SrcLine[SrcIndex];
              SrcPtr2 := @SrcLine[SrcIndex + SrcW];
            end;
            C := Interpolator(MapHorz[I].Weight, WY, SrcPtr1, SrcPtr2);
            BlendMemEx(C, DstLine[I], Src.MasterAlpha)
          end;
          Inc(DstLine, Dst.Width);
        end
      end;

    dmTransparent:
      begin
        for J := 0 to DstClipH - 1 do
        begin
          SrcLine := Src.ScanLine[MapVert[J].Pos];
          WY := MapVert[J].Weight;
          SrcIndex := MapHorz[0].Pos;
          SrcPtr1 := @SrcLine[SrcIndex];
          SrcPtr2 := @SrcLine[SrcIndex + SrcW];
          for I := 0 to DstClipW - 1 do
          begin
            if SrcIndex <> MapHorz[I].Pos then
            begin
              SrcIndex := MapHorz[I].Pos;
              SrcPtr1 := @SrcLine[SrcIndex];
              SrcPtr2 := @SrcLine[SrcIndex + SrcW];
            end;
            C := Interpolator(MapHorz[I].Weight, WY, SrcPtr1, SrcPtr2);
            if C <> Src.OuterColor then DstLine[I] := C;
          end;
          Inc(DstLine, Dst.Width);
        end
      end;
  else // cmCustom
    for J := 0 to DstClipH - 1 do
    begin
      SrcLine := Src.ScanLine[MapVert[J].Pos];
      WY := MapVert[J].Weight;
      SrcIndex := MapHorz[0].Pos;    
      SrcPtr1 := @SrcLine[SrcIndex];    
      SrcPtr2 := @SrcLine[SrcIndex + SrcW];    
      for I := 0 to DstClipW - 1 do    
      begin    
        if SrcIndex <> MapHorz[I].Pos then    
        begin    
          SrcIndex := MapHorz[I].Pos;    
          SrcPtr1 := @SrcLine[SrcIndex];    
          SrcPtr2 := @SrcLine[SrcIndex + SrcW];
        end;
        C := Interpolator(MapHorz[I].Weight, WY, SrcPtr1, SrcPtr2);
        CombineCallBack(C, DstLine[I], Src.MasterAlpha);
      end;
      Inc(DstLine, Dst.Width);
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      Resample
//
//------------------------------------------------------------------------------
// Primarily used by TKernelResampler.Resample
//------------------------------------------------------------------------------
// Precision of TMappingTable[][].Weight.
// Totals Cb,Cg,Cr,Ca in Resample need to be unscaled by (1 shl MappingTablePrecicionShift2).
const
  // Weight precision
{$ifdef PREMULTIPLY}
  MappingTablePrecicionShift = 8; // Fixed precision [24:8]
{$else PREMULTIPLY}
  MappingTablePrecicionShift = 11; // Fixed precision [21:11]
{$endif PREMULTIPLY}
  MappingTablePrecicionShift2 = 2 * MappingTablePrecicionShift;
  MappingTablePrecicion = 1 shl MappingTablePrecicionShift;
  MappingTablePrecicion2 = 1 shl MappingTablePrecicionShift2;
  MappingTablePrecicionRound = (1 shl MappingTablePrecicionShift2) div 2 - 1;
  MappingTablePrecicionMax2 = 255 shl MappingTablePrecicionShift2;

{$ifdef PREMULTIPLY}
const
  // Premultiplication
  // Max error across all value[0..255]/alpha[1..255] combinations:
  //   Shift=1: +/-1
  //   Shift=2: +/-3
  //   Shift=3: +/-7     in other words: error = +/- 2^(shift-1)
  //   Shift=4: +/-15
  //   Shift=5: +/-31
  MappingTablePremultPrecicionShift = 2; // [0..7]
  MappingTablePremultPrecicion = 1 shl MappingTablePremultPrecicionShift;
{$endif PREMULTIPLY}

//------------------------------------------------------------------------------
// BuildMappingTable
//------------------------------------------------------------------------------
function BuildMappingTable(DstLo, DstHi: Integer; ClipLo, ClipHi: Integer;
  SrcLo, SrcHi: Integer; Kernel: TCustomKernel): TMappingTable;
var
  SrcWidth, DstWidth, ClipWidth: Integer;
  Filter: TFilterMethod;
  FilterWidth: TFloat;
  Scale, InvScale: TFloat;
  Center: TFloat;
  Count: Integer;
  Left, Right: Integer;
  I, J, K: Integer;
  Weight: Integer;
  x0, x1, x2, x3: TFloat;
begin
  SrcWidth := SrcHi - SrcLo;
  DstWidth := DstHi - DstLo;
  ClipWidth := ClipHi - ClipLo;

  if SrcWidth = 0 then
  begin
    Result := nil;
    Exit;
  end;

  if SrcWidth = 1 then
  begin
    SetLength(Result, ClipWidth);
    for I := 0 to ClipWidth - 1 do
    begin
      SetLength(Result[I], 1);
      Result[I][0].Pos := SrcLo;
      Result[I][0].Weight := MappingTablePrecicion; // Weight=1
    end;
    Exit;
  end;

  SetLength(Result, ClipWidth);
  if ClipWidth = 0 then
    Exit;

  if FullEdge then
    Scale := DstWidth / SrcWidth
  else
    Scale := (DstWidth - 1) / (SrcWidth - 1);

  Filter := Kernel.Filter;
  FilterWidth := Kernel.GetWidth;
  K := 0;

  if Scale = 0 then
  begin
    Assert(Length(Result) = 1);
    SetLength(Result[0], 1);
    Result[0][0].Pos := (SrcLo + SrcHi) div 2;
    Result[0][0].Weight := MappingTablePrecicion; // Weight=1
  end else
  if Scale < 1 then
  begin
    InvScale := Scale;
    Scale := 1 / Scale;
    FilterWidth := FilterWidth * Scale;
    for I := 0 to ClipWidth - 1 do
    begin
      if FullEdge then
        Center := SrcLo - 0.5 + (I - DstLo + ClipLo + 0.5) * Scale
      else
        Center := SrcLo + (I - DstLo + ClipLo) * Scale;

      Left := Floor(Center - FilterWidth);
      Right := Ceil(Center + FilterWidth);

      Count := -MappingTablePrecicion;
      for J := Left to Right do
      begin
        //
        // Compute the intergral for the convolution with the filter using the midpoint-rule:
        //
        // Assume that f(x) is continuous on [a, b], n is a positive integer and
        //
        //         b - a
        //   ∆x = -------
        //           n
        //
        // If [a,b] is divided into n subintervals, each of length ∆x, and m{i} is the midpoint
        // of the i'th subinterval, set
        //
        //   M{n} = ∑ f(m{i}) ∆x
        //
        // then
        //
        //   M{n} ≈ ∫ f(x)dx
        //
        // In other words, the integral from x1 to x2 of f(x) dx is approximately:
        //
        //   f((x1+x2)/2)*(x2-x1). ﻿
        //
        x0 := J - Center;
        x1 := Max(x0 - 0.5, -FilterWidth);
        x2 := Min(x0 + 0.5, FilterWidth);
        x3 := (x2 + x1) * 0.5; // Center of [x1, x2]

        Weight := Round(MappingTablePrecicion * Filter(x3 * InvScale) * (x2 - x1) * InvScale);

        if Weight <> 0 then
        begin
          Inc(Count, Weight);
          K := Length(Result[I]);
          SetLength(Result[I], K + 1);
          Result[I][K].Pos := Constrain(J, SrcLo, SrcHi - 1);
          Result[I][K].Weight := Weight;
        end;
      end;

      if Length(Result[I]) = 0 then
      begin
        SetLength(Result[I], 1);
        Result[I][0].Pos := Floor(Center);
        Result[I][0].Weight := MappingTablePrecicion;
      end else
      if Count <> 0 then
        Dec(Result[I][K div 2].Weight, Count);
    end;
  end
  else // scale > 1
  begin
    Scale := 1 / Scale;
    for I := 0 to ClipWidth - 1 do
    begin
      if FullEdge then
        Center := SrcLo - 0.5 + (I - DstLo + ClipLo + 0.5) * Scale
      else
        Center := SrcLo + (I - DstLo + ClipLo) * Scale;

      Left := Floor(Center - FilterWidth);
      Right := Ceil(Center + FilterWidth);

      Count := -MappingTablePrecicion;
      for J := Left to Right do
      begin
        x0 := J - Center;
        x1 := Max(x0 - 0.5, -FilterWidth);
        x2 := Min(x0 + 0.5, FilterWidth);
        x3 := (x1 + x2) * 0.5;

        Weight := Round(MappingTablePrecicion * Filter(x3) * (x2 - x1));

        if Weight <> 0 then
        begin
          Inc(Count, Weight);
          K := Length(Result[I]);
          SetLength(Result[I], K + 1);
          Result[I][K].Pos := Constrain(J, SrcLo, SrcHi - 1);
          Result[I][K].Weight := Weight;
        end;
      end;
      if Count <> 0 then
        Dec(Result[I][K div 2].Weight, Count);
    end;
  end;
end;

//------------------------------------------------------------------------------
// Premultiply
//------------------------------------------------------------------------------
{$ifdef PREMULTIPLY}
function Premultiply(Value, Alpha: integer): integer; {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  // Instead of performing a full traditional premultiplication:
  //
  //   RGBp = RGB * Alpha / 255
  //
  // we try to lessen the rounding error, which is normally
  // introduced when this is done in integer precision, by
  // using a smaller divisor. Additionally we use a power of 2
  // divisor so the division can be done with a simple shift:
  //
  //   RGBp = RGB * Alpha >> X
  //
  // We need to use "div" for division instead of a direct "shr" as
  // "shr" performs a logical shift and not an arithmetic shift.
  // The compiler will optimize a "div" with a power of 2 constant
  // divisor to an arithmetic shift, so it's a very cheap operation.
  Result := (Value * Alpha) div MappingTablePremultPrecicion;
end;

//------------------------------------------------------------------------------
// Unpremultiply
//------------------------------------------------------------------------------
function Unpremultiply(Value, Alpha: integer): integer; {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  // It would be best if we could do the multiplication before the division
  // but unfortunately that overflows the fixed precision.
  Result := (Value div Alpha) * MappingTablePremultPrecicion;
end;
{$endif PREMULTIPLY}

//------------------------------------------------------------------------------
// Resample
//------------------------------------------------------------------------------
procedure Resample(
  Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  Kernel: TCustomKernel;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  DstClipW: Integer;
  MapX, MapY: TMappingTable;
  I, J, X, Y: Integer;
  MapXLoPos, MapXHiPos: Integer;
  HorzBuffer: array of TBufferEntry;
  ClusterX, ClusterY: TCluster;
  Cb, Cg, Cr, Ca: Integer;
  C: TColor32Entry;
  ClusterWeight: Integer;
  DstLine: PColor32Array;
  RangeCheck: Boolean;
  BlendMemEx: TBlendMemEx;
  SourceColor: PColor32Entry;
  BufferEntry: PBufferEntry;
{$ifdef PREMULTIPLY}
  Alpha: integer;
  DoPremultiply: boolean;
{$endif PREMULTIPLY}
begin
  if (CombineOp = dmCustom) and not Assigned(CombineCallBack) then
    CombineOp := dmOpaque;

  { check source and destination }
  if (CombineOp = dmBlend) and (Src.MasterAlpha = 0) then
    Exit;

  BlendMemEx := BLEND_MEM_EX[Src.CombineMode]^; // store in local variable

  DstClipW := DstClip.Right - DstClip.Left;

  // Mapping tables
  MapX := BuildMappingTable(DstRect.Left, DstRect.Right, DstClip.Left, DstClip.Right, SrcRect.Left, SrcRect.Right, Kernel);
  MapY := BuildMappingTable(DstRect.Top, DstRect.Bottom, DstClip.Top, DstClip.Bottom, SrcRect.Top, SrcRect.Bottom, Kernel);
  if (MapX = nil) or (MapY = nil) then
    Exit;

{$ifdef PREMULTIPLY}
  // Scan bitmap for alpha
  DoPremultiply := False;
  SourceColor := PColor32Entry(Src.Bits);
  I := Src.Height*Src.Width;
  while (I > 0) do
  begin
    if (SourceColor.A <> 255) and (SourceColor.A <> 0) then
    begin
      // We only need to do alpha-premultiplication if Alpha exist in range [1..254]
      DoPremultiply := True;
      break;
    end;
    Inc(SourceColor);
    Dec(I);
  end;
{$endif PREMULTIPLY}

  ClusterX := nil;
  ClusterY := nil;

{$ifdef PREMULTIPLY}
  // If we're doing premultiplication then we always need to clamp the unpremultiplied
  // values. Why? Well, premult/unpremult normally goes like this:
  //
  //   RGBp = RGB * Alpha / 255
  //   RGB = RGBp * 255 / Alpha
  //
  // or in this particular case:
  //
  //   RGBp = RGB * Alpha / 255
  //   RGB = ∑RGBp * 255 / ∑Alpha
  //
  // Now in case the rounding of the RGB or Alpha values leads to (∑RGBp > RGBp) or
  // (Alpha > ∑Alpha) then we will get RGB values out of bounds (i.e. > 255).

  RangeCheck := DoPremultiply or Kernel.RangeCheck;
{$else PREMULTIPLY}
  RangeCheck := Kernel.RangeCheck;
{$endif PREMULTIPLY}

  MapXLoPos := MapX[0][0].Pos;
  MapXHiPos := MapX[DstClipW - 1][High(MapX[DstClipW - 1])].Pos;
  SetLength(HorzBuffer, MapXHiPos - MapXLoPos + 1);

  { transfer pixels }
  for J := DstClip.Top to DstClip.Bottom - 1 do
  begin
    ClusterY := MapY[J - DstClip.Top];
    ClusterWeight := ClusterY[0].Weight;

    SourceColor := @Src.Bits[ClusterY[0].Pos * Src.Width + MapXLoPos];
    BufferEntry := @HorzBuffer[0];

    X := MapXHiPos - MapXLoPos;
    while (X >= 0) do // for X := MapXLoPos to MapXHiPos do
    begin
{$ifdef PREMULTIPLY}
      // Alpha=0 should not contribute to sample.
      Alpha := SourceColor.A;
      if (Alpha <> 0) then
      begin
        Alpha := Alpha * ClusterWeight;
        if (DoPremultiply) then
        begin
          // Sample premultiplied values
          // RGB is multiplied with Alpha during premultiplication so instead of
          //   BufferEntry.RGB := Premultiply(SourceColor.RGB * ClusterWeight, Alpha);
          // we're doing
          //   Alpha := Alpha * ClusterWeight;
          //   BufferEntry.RGB := Premultiply(SourceColor.RGB, Alpha);
          // and saving 3 multiplications.
          BufferEntry.B := Premultiply(SourceColor.B, Alpha);
          BufferEntry.G := Premultiply(SourceColor.G, Alpha);
          BufferEntry.R := Premultiply(SourceColor.R, Alpha);
        end else
        begin
          BufferEntry.B := SourceColor.B * ClusterWeight;
          BufferEntry.G := SourceColor.G * ClusterWeight;
          BufferEntry.R := SourceColor.R * ClusterWeight;
        end;
        BufferEntry.A := Alpha;
      end else
        BufferEntry^ := Default(TBufferEntry);
{$else PREMULTIPLY}
      // Alpha=0 should not contribute to sample.
      if (SourceColor.A <> 0) then
      begin
        BufferEntry.B := SourceColor.B * ClusterWeight;
        BufferEntry.G := SourceColor.G * ClusterWeight;
        BufferEntry.R := SourceColor.R * ClusterWeight;
        BufferEntry.A := SourceColor.A * ClusterWeight;
      end else
        BufferEntry^ := Default(TBufferEntry);
{$endif PREMULTIPLY}
      Inc(SourceColor);
      Inc(BufferEntry);
      Dec(X);
    end;

    Y := Length(ClusterY) - 1;
    while (Y > 0) do // for Y := 1 to Length(ClusterY) - 1 do
    begin
      ClusterWeight := ClusterY[Y].Weight;

      SourceColor := @Src.Bits[ClusterY[Y].Pos * Src.Width + MapXLoPos];
      BufferEntry := @HorzBuffer[0];

      X := MapXHiPos - MapXLoPos;
      while (X >= 0) do // for X := MapXLoPos to MapXHiPos do
      begin
{$ifdef PREMULTIPLY}
        // Alpha=0 should not contribute to sample.
        Alpha := SourceColor.A;
        if (Alpha <> 0) then
        begin
          Alpha := Alpha * ClusterWeight;
          if (DoPremultiply) then
          begin
            // Sample premultiplied values
            Inc(BufferEntry.B, Premultiply(SourceColor.B, Alpha));
            Inc(BufferEntry.G, Premultiply(SourceColor.G, Alpha));
            Inc(BufferEntry.R, Premultiply(SourceColor.R, Alpha));
          end else
          begin
            Inc(BufferEntry.B, SourceColor.B * ClusterWeight);
            Inc(BufferEntry.G, SourceColor.G * ClusterWeight);
            Inc(BufferEntry.R, SourceColor.R * ClusterWeight);
          end;
          Inc(BufferEntry.A, Alpha);
        end;
{$else PREMULTIPLY}
        // Alpha=0 should not contribute to sample.
        if (SourceColor.A <> 0) then
        begin
          Inc(BufferEntry.B, SourceColor.B * ClusterWeight);
          Inc(BufferEntry.G, SourceColor.G * ClusterWeight);
          Inc(BufferEntry.R, SourceColor.R * ClusterWeight);
          Inc(BufferEntry.A, SourceColor.A * ClusterWeight);
        end;
{$endif PREMULTIPLY}
        Inc(SourceColor);
        Inc(BufferEntry);
        Dec(X);
      end;
      Dec(Y);
    end;

    DstLine := Dst.ScanLine[J];
    for I := DstClip.Left to DstClip.Right - 1 do
    begin
      Cb := 0; Cg := Cb; Cr := Cb; Ca := Cb;

      ClusterX := MapX[I - DstClip.Left];

      X := Length(ClusterX) - 1;
      while (X >= 0) do // for X := 0 to Length(ClusterX) - 1 do
      begin
        with HorzBuffer[ClusterX[X].Pos - MapXLoPos] do
          if (A <> 0) then // If Alpha=0 then RGB=0
          begin
            ClusterWeight := ClusterX[X].Weight;
            Inc(Cb, B * ClusterWeight); // Note: Fixed precision multiplication done here
            Inc(Cg, G * ClusterWeight);
            Inc(Cr, R * ClusterWeight);
            Inc(Ca, A * ClusterWeight);
          end;
        Dec(X);
      end;

      // Unpremultiply, unscale and round
      if RangeCheck then
      begin
{$ifdef PREMULTIPLY}
        Alpha:= (Clamp(Ca, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
        if (Alpha <> 0) then
        begin
          if (DoPremultiply) then
          begin
            C.B := (Clamp(Unpremultiply(Cb, Alpha), 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
            C.G := (Clamp(Unpremultiply(Cg, Alpha), 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
            C.R := (Clamp(Unpremultiply(Cr, Alpha), 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
            C.A := Alpha;
          end else
          begin
            C.B := (Clamp(Cb, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
            C.G := (Clamp(Cg, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
            C.R := (Clamp(Cr, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
            C.A := 255; // We know Alpha=255 because RangeCheck is True otherwise
          end;
        end else
          C.ARGB := 0;
{$else PREMULTIPLY}
        if (Ca <> 0) then
        begin
          C.B := (Clamp(Cb, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.G := (Clamp(Cg, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.R := (Clamp(Cr, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.A := (Clamp(Ca, 0, MappingTablePrecicionMax2) + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
        end else
          C.ARGB := 0;
{$endif PREMULTIPLY}
      end else
      begin
{$ifdef PREMULTIPLY}
        Alpha:= (Ca + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
        if (Alpha <> 0) then
        begin
          C.B := (Cb + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.G := (Cg + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.R := (Cr + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.A := 255; // We know Alpha=255 because RangeCheck is True otherwise
        end else
          C.ARGB := 0;
{$else PREMULTIPLY}
        if (Ca <> 0) then
        begin
          C.B := (Cb + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.G := (Cg + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.R := (Cr + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
          C.A := (Ca + MappingTablePrecicionRound) shr MappingTablePrecicionShift2;
        end else
          C.ARGB := 0;
{$endif PREMULTIPLY}
      end;

      // Combine it with the background
      case CombineOp of
        dmOpaque:
          DstLine[I] := C.ARGB;

        dmBlend:
          BlendMemEx(C.ARGB, DstLine[I], Src.MasterAlpha);

        dmTransparent:
          if C.ARGB <> Src.OuterColor then
            DstLine[I] := C.ARGB;

        dmCustom:
          CombineCallBack(C.ARGB, DstLine[I], Src.MasterAlpha);
      end;
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      DraftResample
//
//------------------------------------------------------------------------------
// Used by TDraftResampler.Resample
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// BlockAverage_Pas
//------------------------------------------------------------------------------
function BlockAverage_Pas(Dlx, Dly: Cardinal; RowSrc: PColor32; OffSrc: Cardinal): TColor32;
var
 C: PColor32Entry;
 ix, iy, iA, iR, iG, iB, Area: Cardinal;
begin
  iR := 0;  iB := iR;  iG := iR;  iA := iR;
  for iy := 1 to Dly do
  begin
    C := PColor32Entry(RowSrc);
    for ix := 1 to Dlx do
    begin
      Inc(iB, C.B);
      Inc(iG, C.G);
      Inc(iR, C.R);
      Inc(iA, C.A);
      Inc(C);
    end;
    Inc(PByte(RowSrc), OffSrc);
  end;

  Area := Dlx * Dly;
  Area := $1000000 div Area;
  Result := iA * Area and $FF000000 or
            iR * Area shr  8 and $FF0000 or
            iG * Area shr 16 and $FF00 or
            iB * Area shr 24 and $FF;
end;


//------------------------------------------------------------------------------
// BlockAverage_SSE2
//------------------------------------------------------------------------------
{$if (not defined(PUREPASCAL)) and (not defined(OMIT_SSE2))}
function BlockAverage_SSE2(Dlx, Dly: Cardinal; RowSrc: PColor32; OffSrc: Cardinal): TColor32;
asm
{$IFDEF TARGET_X64}
        MOV        EAX,ECX
        MOV        R10D,EDX

        SHL        EAX,$02
        SUB        R9D,EAX

        PXOR       XMM1,XMM1
        PXOR       XMM2,XMM2
        PXOR       XMM7,XMM7

@@LoopY:
        MOV        EAX,ECX
        PXOR       XMM0,XMM0
        LEA        R8,[R8+RAX*4]
        NEG        RAX
@@LoopX:
        MOVD       XMM6,[R8+RAX*4]
        PUNPCKLBW  XMM6,XMM7
        PADDW      XMM0,XMM6
        INC        RAX
        JNZ        @@LoopX

        MOVQ       XMM6,XMM0
        PUNPCKLWD  XMM6,XMM7
        PADDD      XMM1,XMM6
        ADD        R8,R9
        DEC        EDX
        JNZ        @@LoopY

        MOV        EAX, ECX
        MUL        R10D
        MOV        ECX,EAX
        MOV        EAX,$01000000
        DIV        ECX
        MOV        ECX,EAX

        MOVD       EAX,XMM1
        MUL        ECX
        SHR        EAX,$18
        MOV        R10D,EAX

        SHUFPS     XMM1,XMM1,$39
        MOVD       EAX,XMM1
        MUL        ECX
        SHR        EAX,$10
        AND        EAX,$0000FF00
        ADD        R10D,EAX

        PSHUFD     XMM1,XMM1,$39
        MOVD       EAX,XMM1
        MUL        ECX
        SHR        EAX,$08
        AND        EAX,$00FF0000
        ADD        R10D,EAX

        PSHUFD     XMM1,XMM1,$39
        MOVD       EAX,XMM1
        MUL        ECX
        AND        EAX,$FF000000
        ADD        EAX,R10D
{$ELSE}
        PUSH       EBX
        PUSH       ESI
        PUSH       EDI

        MOV        EBX,OffSrc
        MOV        ESI,EAX
        MOV        EDI,EDX

        SHL        ESI,$02
        SUB        EBX,ESI

        PXOR       XMM1,XMM1
        PXOR       XMM2,XMM2
        PXOR       XMM7,XMM7

@@LoopY:
        MOV        ESI,EAX
        PXOR       XMM0,XMM0
        LEA        ECX,[ECX+ESI*4]
        NEG        ESI
@@LoopX:
        MOVD       XMM6,[ECX+ESI*4]
        PUNPCKLBW  XMM6,XMM7
        PADDW      XMM0,XMM6
        INC        ESI
        JNZ        @@LoopX

        MOVQ       XMM6,XMM0
        PUNPCKLWD  XMM6,XMM7
        PADDD      XMM1,XMM6
        ADD        ECX,EBX
        DEC        EDX
        JNZ        @@LoopY

        MUL        EDI
        MOV        ECX,EAX
        MOV        EAX,$01000000
        DIV        ECX
        MOV        ECX,EAX

        MOVD       EAX,XMM1
        MUL        ECX
        SHR        EAX,$18
        MOV        EDI,EAX

        SHUFPS     XMM1,XMM1,$39
        MOVD       EAX,XMM1
        MUL        ECX
        SHR        EAX,$10
        AND        EAX,$0000FF00
        ADD        EDI,EAX

        PSHUFD     XMM1,XMM1,$39
        MOVD       EAX,XMM1
        MUL        ECX
        SHR        EAX,$08
        AND        EAX,$00FF0000
        ADD        EDI,EAX

        PSHUFD     XMM1,XMM1,$39
        MOVD       EAX,XMM1
        MUL        ECX
        AND        EAX,$FF000000
        ADD        EAX,EDI

        POP        EDI
        POP        ESI
        POP        EBX
{$ENDIF}
end;
{$ifend}


//------------------------------------------------------------------------------
// DraftResample
//------------------------------------------------------------------------------
procedure DraftResample(Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect; Kernel: TCustomKernel;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  SrcW, SrcH,
  DstW, DstH,
  DstClipW, DstClipH: Cardinal;
  RowSrc: PColor32;
  xsrc: PColor32;
  OffSrc,
  dy, dx,
  c1, c2, r1, r2,
  xs: Cardinal;
  C: TColor32;
  DstLine: PColor32Array;
  ScaleFactor: TFloat;
  I,J, sc, sr, cx, cy: Integer;
  BlendMemEx: TBlendMemEx;
begin
 { rangechecking and rect intersection done by caller }

  SrcW := SrcRect.Right  - SrcRect.Left;
  SrcH := SrcRect.Bottom - SrcRect.Top;

  DstW := DstRect.Right  - DstRect.Left;
  DstH := DstRect.Bottom - DstRect.Top;

  DstClipW := DstClip.Right - DstClip.Left;
  DstClipH := DstClip.Bottom - DstClip.Top;

  BlendMemEx := BLEND_MEM_EX[Src.CombineMode]^;

  if (DstW > SrcW)or(DstH > SrcH) then
  begin
    if (SrcW < 2) or (SrcH < 2) then
      Resample(Dst, DstRect, DstClip, Src, SrcRect, Kernel, CombineOp, CombineCallBack)
    else
      StretchHorzStretchVertLinear(Dst, DstRect, DstClip, Src, SrcRect, CombineOp, CombineCallBack);
  end else
  begin //Full Scaledown, ignores Fulledge - cannot be integrated into this resampling method
    OffSrc := Src.Width * 4;

    ScaleFactor:= SrcW / DstW;
    cx := Trunc( (DstClip.Left - DstRect.Left) * ScaleFactor);
    r2 := Trunc(ScaleFactor);
    sr := Trunc( $10000 * ScaleFactor );

    ScaleFactor:= SrcH / DstH;
    cy := Trunc( (DstClip.Top - DstRect.Top) * ScaleFactor);
    c2 := Trunc(ScaleFactor);
    sc := Trunc( $10000 * ScaleFactor );

    DstLine := PColor32Array(Dst.PixelPtr[0, DstClip.Top]);
    RowSrc := Src.PixelPtr[SrcRect.Left +  cx, SrcRect.Top + cy ];

    xs := r2;
    c1 := 0;
    Dec(DstClip.Left, 2);
    Inc(DstClipW);
    Inc(DstClipH);

    for J := 2  to DstClipH do
    begin
      dy := c2 - c1;
      c1 := c2;
      c2 := FixedMul(J, sc);
      r1 := 0;
      r2 := xs;
      xsrc := RowSrc;

      case CombineOp of
        dmOpaque:
          for I := 2  to DstClipW do
          begin
            dx := r2 - r1;  r1 := r2;
            r2 := FixedMul(I, sr);
            DstLine[DstClip.Left + I] := BlockAverage(dx, dy, xsrc, OffSrc);
            Inc(xsrc, dx);
          end;
        dmBlend:
          for I := 2  to DstClipW do
          begin
            dx := r2 - r1;  r1 := r2;
            r2 := FixedMul(I, sr);
            BlendMemEx(BlockAverage(dx, dy, xsrc, OffSrc),
              DstLine[DstClip.Left + I], Src.MasterAlpha);
            Inc(xsrc, dx);
          end;
        dmTransparent:
          for I := 2  to DstClipW do
          begin
            dx := r2 - r1;  r1 := r2;
            r2 := FixedMul(I, sr);
            C := BlockAverage(dx, dy, xsrc, OffSrc);
            if C <> Src.OuterColor then DstLine[DstClip.Left + I] := C;
            Inc(xsrc, dx);
          end;
        dmCustom:
          for I := 2  to DstClipW do
          begin
            dx := r2 - r1;  r1 := r2;
            r2 := FixedMul(I, sr);
            CombineCallBack(BlockAverage(dx, dy, xsrc, OffSrc),
              DstLine[DstClip.Left + I], Src.MasterAlpha);
            Inc(xsrc, dx);
          end;
      end;

      Inc(DstLine, Dst.Width);
      Inc(PByte(RowSrc), OffSrc * dy);
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      Special interpolators (for sfLinear and sfDraft)
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Interpolator_Pas
//------------------------------------------------------------------------------
function Interpolator_Pas(WX_256, WY_256: Cardinal; C11, C21: PColor32): TColor32;
var
  C1, C3: TColor32;
begin
  if WX_256 > $FF then WX_256:= $FF;
  if WY_256 > $FF then WY_256:= $FF;
  C1 := C11^; Inc(C11);
  C3 := C21^; Inc(C21);
  Result := CombineReg(CombineReg(C1, C11^, WX_256),
                       CombineReg(C3, C21^, WX_256), WY_256);
end;


//------------------------------------------------------------------------------
// Interpolator_SSE2
//------------------------------------------------------------------------------
{$if (not defined(PUREPASCAL)) and (not defined(OMIT_SSE2))}
function Interpolator_SSE2(WX_256, WY_256: Cardinal; C11, C21: PColor32): TColor32;
asm
{$IFDEF TARGET_X64}
        MOV       RAX, RCX
        MOVQ      XMM1,QWORD PTR [R8]
        MOVQ      XMM2,XMM1
        MOVQ      XMM3,QWORD PTR [R9]
{$ELSE}
        MOVQ      XMM1,[ECX]
        MOVQ      XMM2,XMM1
        MOV       ECX,C21
        MOVQ      XMM3,[ECX]
{$ENDIF}
        PSRLQ     XMM1,32
        MOVQ      XMM4,XMM3
        PSRLQ     XMM3,32
        MOVD      XMM5,EAX
        PSHUFLW   XMM5,XMM5,0
        PXOR      XMM0,XMM0
        PUNPCKLBW XMM1,XMM0
        PUNPCKLBW XMM2,XMM0
        PSUBW     XMM2,XMM1
        PMULLW    XMM2,XMM5
        PSLLW     XMM1,8
        PADDW     XMM2,XMM1
        PSRLW     XMM2,8
        PUNPCKLBW XMM3,XMM0
        PUNPCKLBW XMM4,XMM0
        PSUBW     XMM4,XMM3
        PSLLW     XMM3,8
        PMULLW    XMM4,XMM5
        PADDW     XMM4,XMM3
        PSRLW     XMM4,8
        MOVD      XMM5,EDX
        PSHUFLW   XMM5,XMM5,0
        PSUBW     XMM2,XMM4
        PMULLW    XMM2,XMM5
        PSLLW     XMM4,8
        PADDW     XMM2,XMM4
        PSRLW     XMM2,8
        PACKUSWB  XMM2,XMM0
        MOVD      EAX,XMM2
end;
{$ifend}


//------------------------------------------------------------------------------
//
//      StretchTransfer
//
//------------------------------------------------------------------------------
{$WARNINGS OFF}
procedure StretchTransfer(
  Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  Resampler: TCustomResampler;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  SrcW, SrcH: Integer;
  DstW, DstH: Integer;
  R: TRect;
  RatioX, RatioY: Single;
begin
  CheckBitmaps(Dst, Src);

  // transform dest rect when the src rect is out of the src bitmap's bounds
  if (SrcRect.Left < 0) or (SrcRect.Right > Src.Width) or
    (SrcRect.Top < 0) or (SrcRect.Bottom > Src.Height) then
  begin
    RatioX := (DstRect.Right - DstRect.Left) / (SrcRect.Right - SrcRect.Left);
    RatioY := (DstRect.Bottom - DstRect.Top) / (SrcRect.Bottom - SrcRect.Top);

    if SrcRect.Left < 0 then
    begin
      DstRect.Left := DstRect.Left + Ceil(-SrcRect.Left * RatioX);
      SrcRect.Left := 0;
    end;

    if SrcRect.Top < 0 then
    begin
      DstRect.Top := DstRect.Top + Ceil(-SrcRect.Top * RatioY);
      SrcRect.Top := 0;
    end;

    if SrcRect.Right > Src.Width then
    begin
      DstRect.Right := DstRect.Right - Floor((SrcRect.Right - Src.Width) * RatioX);
      SrcRect.Right := Src.Width;
    end;

    if SrcRect.Bottom > Src.Height then
    begin
      DstRect.Bottom := DstRect.Bottom - Floor((SrcRect.Bottom - Src.Height) * RatioY);
      SrcRect.Bottom := Src.Height;
    end;
  end;

  if Src.Empty or Dst.Empty or
    ((CombineOp = dmBlend) and (Src.MasterAlpha = 0)) or
    GR32.IsRectEmpty(SrcRect) then
      Exit;

  if not Dst.MeasuringMode then
  begin
    GR32.IntersectRect(DstClip, DstClip, Dst.BoundsRect);
    GR32.IntersectRect(DstClip, DstClip, DstRect);
    if GR32.IsRectEmpty(DstClip) then Exit;
    GR32.IntersectRect(R, DstClip, DstRect);
    if GR32.IsRectEmpty(R) then Exit;

    if (CombineOp = dmCustom) and not Assigned(CombineCallBack) then
      CombineOp := dmOpaque;

    SrcW := SrcRect.Right - SrcRect.Left;
    SrcH := SrcRect.Bottom - SrcRect.Top;
    DstW := DstRect.Right - DstRect.Left;
    DstH := DstRect.Bottom - DstRect.Top;

    if (SrcW = DstW) and (SrcH = DstH) then
      BlendBlock(Dst, DstClip, Src, SrcRect.Left + DstClip.Left - DstRect.Left, SrcRect.Top + DstClip.Top - DstRect.Top, CombineOp, CombineCallBack)
    else
      TCustomResamplerAccess(Resampler).Resample(Dst, DstRect, DstClip, Src, SrcRect, CombineOp, CombineCallBack);
  end;

  Dst.Changed(DstRect);
end;
{$WARNINGS ON}


//------------------------------------------------------------------------------
//
//      TByteMap downsample functions
//
//------------------------------------------------------------------------------
procedure DownsampleByteMap2x(Source, Dest: TByteMap);
var
  X, Y: Integer;
  ScnLn: array [0 .. 2] of PByteArray;
begin
  for Y := 0 to (Source.Height div 2) - 1 do
  begin
    ScnLn[0] := Dest.ScanLine[Y];
    ScnLn[1] := Source.ScanLine[Y * 2];
    ScnLn[2] := Source.ScanLine[Y * 2 + 1];
    for X := 0 to (Source.Width div 2) - 1 do
      ScnLn[0, X] := (
        ScnLn[1, 2 * X] + ScnLn[1, 2 * X + 1] +
        ScnLn[2, 2 * X] + ScnLn[2, 2 * X + 1]) div 4;
  end;
end;

//------------------------------------------------------------------------------

procedure DownsampleByteMap3x(Source, Dest: TByteMap);
var
  X, Y: Integer;
  x3: Integer;
  ScnLn: array [0 .. 3] of PByteArray;
begin
  for Y := 0 to (Source.Height div 3) - 1 do
  begin
    ScnLn[0] := Dest.ScanLine[Y];
    ScnLn[1] := Source.ScanLine[3 * Y];
    ScnLn[2] := Source.ScanLine[3 * Y + 1];
    ScnLn[3] := Source.ScanLine[3 * Y + 2];
    for X := 0 to (Source.Width div 3) - 1 do
    begin
      x3 := 3 * X;
      ScnLn[0, X] := (
        ScnLn[1, x3] + ScnLn[1, x3 + 1] + ScnLn[1, x3 + 2] +
        ScnLn[2, x3] + ScnLn[2, x3 + 1] + ScnLn[2, x3 + 2] +
        ScnLn[3, x3] + ScnLn[3, x3 + 1] + ScnLn[3, x3 + 2]) div 9;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure DownsampleByteMap4x(Source, Dest: TByteMap);
var
  X, Y: Integer;
  x4: Integer;
  ScnLn: array [0 .. 4] of PByteArray;
begin
  for Y := 0 to (Source.Height div 4) - 1 do
  begin
    ScnLn[0] := Dest.ScanLine[Y];
    ScnLn[1] := Source.ScanLine[Y * 4];
    ScnLn[2] := Source.ScanLine[Y * 4 + 1];
    ScnLn[3] := Source.ScanLine[Y * 4 + 2];
    ScnLn[4] := Source.ScanLine[Y * 4 + 3];
    for X := 0 to (Source.Width div 4) - 1 do
    begin
      x4 := 4 * X;
      ScnLn[0, X] := (
        ScnLn[1, x4] + ScnLn[1, x4 + 1] + ScnLn[1, x4 + 2] + ScnLn[1, x4 + 3] +
        ScnLn[2, x4] + ScnLn[2, x4 + 1] + ScnLn[2, x4 + 2] + ScnLn[2, x4 + 3] +
        ScnLn[3, x4] + ScnLn[3, x4 + 1] + ScnLn[3, x4 + 2] + ScnLn[3, x4 + 3] +
        ScnLn[4, x4] + ScnLn[4, x4 + 1] + ScnLn[4, x4 + 2] + ScnLn[4, x4 + 3]) div 16;
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      TCustomKernel
//
//------------------------------------------------------------------------------
procedure TCustomKernel.AssignTo(Dst: TPersistent);
begin
  if Dst is TCustomKernel then
    SmartAssign(Self, Dst)
  else
    inherited;
end;

procedure TCustomKernel.Changed;
begin
  if Assigned(FObserver) then FObserver.Changed;
end;

constructor TCustomKernel.Create;
begin
end;

function TCustomKernel.RangeCheck: Boolean;
begin
  Result := False;
end;


//------------------------------------------------------------------------------
//
//      TBoxKernel
//
//------------------------------------------------------------------------------
function TBoxKernel.Filter(Value: TFloat): TFloat;
begin
  if (Value >= -0.5) and (Value <= 0.5) then
    Result := 1.0
  else
    Result := 0;
end;

function TBoxKernel.GetWidth: TFloat;
begin
  Result := 1;
end;


//------------------------------------------------------------------------------
//
//      TLinearKernel
//
//------------------------------------------------------------------------------
function TLinearKernel.Filter(Value: TFloat): TFloat;
begin
  if Value < -1 then
    Result := 0
  else
  if Value < 0 then
    Result := 1 + Value
  else
  if Value < 1 then
    Result := 1 - Value
  else
    Result := 0;
end;

function TLinearKernel.GetWidth: TFloat;
begin
  Result := 1;
end;


//------------------------------------------------------------------------------
//
//      TCosineKernel
//
//------------------------------------------------------------------------------
function TCosineKernel.Filter(Value: TFloat): TFloat;
begin
  Result := 0;
  if Abs(Value) < 1 then
    Result := (Cos(Value * Pi) + 1) * 0.5;
end;

function TCosineKernel.GetWidth: TFloat;
begin
  Result := 1;
end;


//------------------------------------------------------------------------------
//
//      TSplineKernel
//
//------------------------------------------------------------------------------
function TSplineKernel.Filter(Value: TFloat): TFloat;
var
  tt: TFloat;
const
  TwoThirds = 2 / 3;
  OneSixth = 1 / 6;
begin
  Value := Abs(Value);
  if Value < 1 then
  begin
    tt := Sqr(Value);
    Result := 0.5 * tt * Value - tt + TwoThirds;
  end
  else if Value < 2 then
  begin
    Value := 2 - Value;
    Result := OneSixth * Sqr(Value) * Value;
  end
  else Result := 0;
end;

function TSplineKernel.RangeCheck: Boolean;
begin
  Result := True;
end;

function TSplineKernel.GetWidth: TFloat;
begin
  Result := 2;
end;


//------------------------------------------------------------------------------
//
//      TMitchellKernel
//
//------------------------------------------------------------------------------
function TMitchellKernel.Filter(Value: TFloat): TFloat;
var
  tt, ttt: TFloat;
const
  OneEighteenth = 1 / 18;
begin
  Value := Abs(Value);
  tt := Sqr(Value);
  ttt := tt * Value;

  // Given B = C = 1/3

  if Value < 1 then
    // ((((12 - 9 * B - 6 * C) * ttt) + ((-18 + 12 * B + 6 * C) * tt) + (6 - 2 * B))) / 6
    Result := (21 * ttt - 36 * tt + 16 ) * OneEighteenth
  else
  if Value < 2 then
    // ((((-1 * B - 6 * C) * ttt) + ((6 * B + 30 * C) * tt) + ((-12 * B - 48 * C) * Value) + (8 * B + 24 * C))) / 6
    Result := (- 7 * ttt + 36 * tt - 60 * Value + 32) * OneEighteenth
  else
    Result := 0;
end;

function TMitchellKernel.RangeCheck: Boolean;
begin
  Result := True;
end;

function TMitchellKernel.GetWidth: TFloat;
begin
  Result := 2;
end;


//------------------------------------------------------------------------------
//
//      TCubicKernel
//
//------------------------------------------------------------------------------
constructor TCubicKernel.Create;
begin
  FCoeff := -0.5;
end;

function TCubicKernel.Filter(Value: TFloat): TFloat;
var
  tt, ttt: TFloat;
begin
  Value := Abs(Value);
  tt := Sqr(Value);
  ttt := tt * Value;
  if Value <= 1 then
    Result := (FCoeff + 2) * ttt - (FCoeff + 3) * tt + 1
  else
  if Value < 2 then
    Result := FCoeff * (ttt - 5 * tt + 8 * Value - 4)
  else
    Result := 0;
end;

function TCubicKernel.RangeCheck: Boolean;
begin
  Result := True;
end;

function TCubicKernel.GetWidth: TFloat;
begin
  Result := 2;
end;

procedure TCubicKernel.SetCoeff(const Value: TFloat);
begin
  if Value <> FCoeff then
  begin
    FCoeff := Value;
    Changed;
  end
end;


//------------------------------------------------------------------------------
//
//      THermiteKernel
//
//------------------------------------------------------------------------------
constructor THermiteKernel.Create;
begin
  FBias := 0;
  FTension := 0;
end;

function THermiteKernel.Filter(Value: TFloat): TFloat;
var
  Z: Integer;
  t, t2, t3, m0, m1, a0, a1, a2, a3: TFloat;
begin
  t := (1 - FTension) * 0.5;
  m0 := (1 + FBias) * t;
  m1 := (1 - FBias) * t;

  Z := Floor(Value);
  t := Abs(Z - Value);
  t2 := t * t;
  t3 := t2 * t;

  a1 := t3 - 2 * t2 + t;
  a2 := t3 - t2;
  a3 := -2 * t3 + 3 * t2;
  a0 := -a3 + 1;

  case Z of
    -2: Result := a2 * m1;
    -1: Result := a3 + a1 * m1 + a2 * (m0 - m1);
     0: Result := a0 + a1 * (m0 - m1) - a2 * m0;
     1: Result := -a1 * m0;
  else
    Result := 0;
  end;
end;

function THermiteKernel.GetWidth: TFloat;
begin
  Result := 2;
end;

function THermiteKernel.RangeCheck: Boolean;
begin
  Result := True;
end;

procedure THermiteKernel.SetBias(const Value: TFloat);
begin
  if FBias <> Value then
  begin
    FBias := Value;
    Changed;
  end;
end;

procedure THermiteKernel.SetTension(const Value: TFloat);
begin
  if FTension <> Value then
  begin
    FTension := Value;
    Changed;
  end;
end;


//------------------------------------------------------------------------------
//
//      TSinshKernel
//
//------------------------------------------------------------------------------
constructor TSinshKernel.Create;
begin
  FWidth := 3;
  FCoeff := 0.5;
end;

function TSinshKernel.Filter(Value: TFloat): TFloat;
begin
  if Value = 0 then
    Result := 1
  else
    Result := FCoeff * Sin(Pi * Value) / Sinh(Pi * FCoeff * Value);
end;

function TSinshKernel.RangeCheck: Boolean;
begin
  Result := True;
end;

procedure TSinshKernel.SetWidth(Value: TFloat);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    Changed;
  end;
end;

function TSinshKernel.GetWidth: TFloat;
begin
  Result := FWidth;
end;

procedure TSinshKernel.SetCoeff(const Value: TFloat);
begin
  if (FCoeff <> Value) and (FCoeff <> 0) then
  begin
    FCoeff := Value;
    Changed;
  end;
end;


//------------------------------------------------------------------------------
//
//      TWindowedKernel
//
//------------------------------------------------------------------------------
procedure TWindowedKernel.DoSetWidth(Value: TFloat);
begin
  FWidth := Value;
  FWidthReciprocal := 1 / FWidth;
end;

function TWindowedKernel.Filter(Value: TFloat): TFloat;
begin
  Value := Abs(Value);
  if Value < FWidth then
    Result := Window(Value)
  else
    Result := 0;
end;

function TWindowedKernel.RangeCheck: Boolean;
begin
  Result := True;
end;

procedure TWindowedKernel.SetWidth(Value: TFloat);
begin
  Value := Min(MAX_KERNEL_WIDTH, Value);
  if Value <> FWidth then
  begin
    DoSetWidth(Value);
    Changed;
  end;
end;

function TWindowedKernel.GetWidth: TFloat;
begin
  Result := FWidth;
end;


//------------------------------------------------------------------------------
//
//      TGaussianKernel
//
//------------------------------------------------------------------------------
const
  // Because the gaussian function has inifinite extent we need to limit the
  // width of the window to something reasonable.
  // Often the limit (width) is set to "Full Width at Half Maximum" (FWHM) by
  // calculing the ratio between Radius and Sigma as
  //
  //   Ratio = 1 / FWHM
  //         = 1 / (2 * Sqrt(2 * Ln(2)))
  //         = 0.424660891294479
  //
  // however, for resampling we need the area of the curve covered by the window
  // to be as close to 1 as possible so instead we calculate the ratio so that
  //
  //   Ceil(Sigma / Ratio)
  //
  // gives us the smallest size of a kernel containing values >= 1/255:
  //
  //   Ratio = 1 / Sqrt(-2 * Ln(1/255))
  //         = 0.300386630413846
  //
  GaussianRadiusToSigma = 0.300386630413846;

  GaussianSigmaToRadius = 1 / GaussianRadiusToSigma;
  GaussianMinSigma = 0.4; // Sigma smaller than this causes overflow; Window(0) > 1

constructor TGaussianKernel.Create;
begin
  inherited;
  DoSetSigma(1 / Sqrt(2 * Pi));
end;

procedure TGaussianKernel.DoSetSigma(const Value: TFloat);
begin
  FSigma := Value;
  FSigmaReciprocal := -0.5 / Sqr(FSigma);
  FNormalizationFactor := 1 / (FSigma * Sqrt(2 * Pi));
  DoSetWidth(FSigma * GaussianSigmaToRadius);
end;

procedure TGaussianKernel.SetSigma(const Value: TFloat);
begin
  if (FSigma <> Value) and (FSigma <> 0) then
  begin
    DoSetSigma(Value);
    Changed;
  end;
end;

function TGaussianKernel.Window(Value: TFloat): TFloat;
begin
  (*
  **    Gauss(x, σ) = 1/(σ √ 2π) * e^( - x^2 / (2 * σ^2))
  **
  **    FNormalizationFactor = 1/(σ √ 2π)
  **
  **    FSigmaReciprocal = - 1 / (2 * σ^2)
  *)
  Result := FNormalizationFactor * Exp(Sqr(Value) * FSigmaReciprocal);
end;


//------------------------------------------------------------------------------
//
//      TWindowedSincKernel
//
//------------------------------------------------------------------------------
class function TWindowedSincKernel.Sinc(Value: TFloat): TFloat;
begin
  if Value <> 0 then
  begin
    Value := Value * Pi;
    Result := Sin(Value) / Value;
  end
  else Result := 1;
end;

constructor TWindowedSincKernel.Create;
begin
  inherited;
  FWidth := 3;
  FWidthReciprocal := 1 / FWidth;
end;

function TWindowedSincKernel.Filter(Value: TFloat): TFloat;
begin
  Value := Abs(Value);
  if Value < FWidth then
    Result := Sinc(Value) * Window(Value)
  else
    Result := 0;
end;


//------------------------------------------------------------------------------
//
//      TAlbrechtKernel
//
//------------------------------------------------------------------------------
constructor TAlbrechtKernel.Create;
begin
  inherited;
  Terms := 7;
end;

procedure TAlbrechtKernel.SetTerms(Value: Integer);
begin
  Value := Constrain(Value, 2, 11);
  if FTerms <> Value then
  begin
    FTerms := Value;

    case Value of
      2 : Move(CAlbrecht2 [0], FCoefPointer[0], Value * SizeOf(Double));
      3 : Move(CAlbrecht3 [0], FCoefPointer[0], Value * SizeOf(Double));
      4 : Move(CAlbrecht4 [0], FCoefPointer[0], Value * SizeOf(Double));
      5 : Move(CAlbrecht5 [0], FCoefPointer[0], Value * SizeOf(Double));
      6 : Move(CAlbrecht6 [0], FCoefPointer[0], Value * SizeOf(Double));
      7 : Move(CAlbrecht7 [0], FCoefPointer[0], Value * SizeOf(Double));
      8 : Move(CAlbrecht8 [0], FCoefPointer[0], Value * SizeOf(Double));
      9 : Move(CAlbrecht9 [0], FCoefPointer[0], Value * SizeOf(Double));
     10 : Move(CAlbrecht10[0], FCoefPointer[0], Value * SizeOf(Double));
     11 : Move(CAlbrecht11[0], FCoefPointer[0], Value * SizeOf(Double));
    end;

    Changed;
  end;
end;

function TAlbrechtKernel.Window(Value: TFloat): TFloat;
var
  cs : Double;
  i  : Integer;
begin
  cs := Cos(Pi * Value * FWidthReciprocal);
  i := FTerms - 1;
  Result := FCoefPointer[i];
  while i > 0 do
  begin
    Dec(i);
    Result := Result * cs + FCoefPointer[i];
  end;
end;


//------------------------------------------------------------------------------
//
//      TLanczosKernel
//
//------------------------------------------------------------------------------
function TLanczosKernel.Window(Value: TFloat): TFloat;
begin
  Result := Sinc(Value * FWidthReciprocal); // Get rid of division
end;


//------------------------------------------------------------------------------
//
//      TBlackmanKernel
//
//------------------------------------------------------------------------------
function TBlackmanKernel.Window(Value: TFloat): TFloat;
begin
  Value := Cos(Pi * Value * FWidthReciprocal);                // get rid of division
  Result := 0.34 + 0.5 * Value + 0.16 * sqr(Value);
end;


//------------------------------------------------------------------------------
//
//      THannKernel
//
//------------------------------------------------------------------------------
function THannKernel.Window(Value: TFloat): TFloat;
begin
  Result := 0.5 + 0.5 * Cos(Pi * Value * FWidthReciprocal);   // get rid of division
end;


//------------------------------------------------------------------------------
//
//      THammingKernel
//
//------------------------------------------------------------------------------
function THammingKernel.Window(Value: TFloat): TFloat;
begin
  Result := 0.54 + 0.46 * Cos(Pi * Value * FWidthReciprocal); // get rid of division
end;


//------------------------------------------------------------------------------
//
//      TKernelResampler
//
//------------------------------------------------------------------------------
constructor TKernelResampler.Create;
begin
  inherited;
  Kernel := TBoxKernel.Create;
  FTableSize := 32;
end;

destructor TKernelResampler.Destroy;
begin
  FKernel.Free;
  inherited;
end;

function TKernelResampler.GetKernelClassName: string;
begin
  Result := FKernel.ClassName;
end;

procedure TKernelResampler.SetKernelClassName(const Value: string);
var
  KernelClass: TCustomKernelClass;
  NewKernel: TCustomKernel;
begin
  if (Value <> '') and (FKernel.ClassName <> Value) and (KernelList <> nil) then
  begin
    KernelClass := KernelList.Find(Value);
    if (KernelClass <> nil) then
    begin
      NewKernel := KernelClass.Create;
      try
        SetKernel(NewKernel);
      except
        if (FKernel <> NewKernel) then
          NewKernel.Free;
        raise;
      end;
    end;
  end;
end;

procedure TKernelResampler.SetKernel(const Value: TCustomKernel);
begin
  if (Value <> nil) and (FKernel <> Value) then
  begin
    FreeAndNil(FKernel);
    FKernel := Value;
    TCustomKernelAccess(FKernel).FObserver := Self;
    Changed;
  end;
end;

procedure TKernelResampler.Resample(Dst: TCustomBitmap32; DstRect,
  DstClip: TRect; Src: TCustomBitmap32; SrcRect: TRect; CombineOp: TDrawMode;
  CombineCallBack: TPixelCombineEvent);
begin
  GR32_Resamplers.Resample(Dst, DstRect, DstClip, Src, SrcRect, FKernel, CombineOp, CombineCallBack);
end;

{$WARNINGS OFF}

function TKernelResampler.GetSampleFloat(X, Y: TFloat): TColor32;
var
  clX, clY: Integer;
  fracX, fracY: Integer;
  fracXS: TFloat absolute fracX;
  fracYS: TFloat absolute fracY;

  Filter: TFilterMethod;
  WrapProcVert: TWrapProcEx absolute Filter;
  WrapProcHorz: TWrapProcEx;
  Colors: PColor32EntryArray;
  KWidth, W, Wv, I, J, Incr, Dev: Integer;
  SrcP: PColor32Entry;
  C: TColor32Entry absolute SrcP;
  LoX, HiX, LoY, HiY, MappingY: Integer;

  HorzKernel, VertKernel: TKernelEntry;
  PHorzKernel, PVertKernel, FloorKernel, CeilKernel: PKernelEntry;

  HorzEntry, VertEntry: TBufferEntry;
  MappingX: TKernelEntry;
  Edge: Boolean;

  Alpha: integer;
  OuterPremultColorR, OuterPremultColorG, OuterPremultColorB: Byte;
begin
  KWidth := Ceil(FKernel.GetWidth);

  clX := Ceil(X);
  clY := Ceil(Y);

  case PixelAccessMode of
    pamUnsafe, pamWrap:
      begin
        LoX := -KWidth; HiX := KWidth;
        LoY := -KWidth; HiY := KWidth;
      end;

    pamSafe, pamTransparentEdge:
      begin
        with ClipRect do
        begin
          if not ((clX < Left) or (clX > Right) or (clY < Top) or (clY > Bottom)) then
          begin
            Edge := False;

            if clX - KWidth < Left then
            begin
              LoX := Left - clX;
              Edge := True;
            end
            else
              LoX := -KWidth;

            if clX + KWidth >= Right then
            begin
              HiX := Right - clX - 1;
              Edge := True;
            end
            else
              HiX := KWidth;

            if clY - KWidth < Top then
            begin
              LoY := Top - clY;
              Edge := True;
            end
            else
              LoY := -KWidth;

            if clY + KWidth >= Bottom then
            begin
              HiY := Bottom - clY - 1;
              Edge := True;
            end
            else
              HiY := KWidth;

          end
          else
          begin
            if PixelAccessMode = pamTransparentEdge then
              Result := 0
            else
              Result := FOuterColor;
            Exit;
          end;

        end;
      end;
  end;

  case FKernelMode of
    kmDynamic:
      begin
        Filter := FKernel.Filter;
        fracXS := clX - X;
        fracYS := clY - Y;

        PHorzKernel := @HorzKernel;
        PVertKernel := @VertKernel;

        Dev := -256;
        for I := -KWidth to KWidth do
        begin
          W := Round(Filter(I + fracXS) * 256);
          HorzKernel[I] := W;
          Inc(Dev, W);
        end;
        Dec(HorzKernel[0], Dev);

        Dev := -256;
        for I := -KWidth to KWidth do
        begin
          W := Round(Filter(I + fracYS) * 256);
          VertKernel[I] := W;
          Inc(Dev, W);
        end;
        Dec(VertKernel[0], Dev);

      end;

    kmTableNearest:
      begin
        W := FWeightTable.Height - 2;
        PHorzKernel := @FWeightTable.ValPtr[KWidth - MAX_KERNEL_WIDTH, Round((clX - X) * W)]^;
        PVertKernel := @FWeightTable.ValPtr[KWidth - MAX_KERNEL_WIDTH, Round((clY - Y) * W)]^;
      end;

    kmTableLinear:
      begin
        W := (FWeightTable.Height - 2) * $10000;
        J := FWeightTable.Width * 4;

        with TFixedRec(FracX) do
        begin
          Fixed := Round((clX - X) * W);
          PHorzKernel := @HorzKernel;
          FloorKernel := @FWeightTable.ValPtr[KWidth - MAX_KERNEL_WIDTH, Int]^;
          CeilKernel := PKernelEntry(NativeUInt(FloorKernel) + J);
          Dev := -256;
          for I := -KWidth to KWidth do
          begin
            Wv :=  FloorKernel[I] + ((CeilKernel[I] - FloorKernel[I]) * Frac + $7FFF) div FixedOne;
            HorzKernel[I] := Wv;
            Inc(Dev, Wv);
          end;
          Dec(HorzKernel[0], Dev);
        end;

        with TFixedRec(FracY) do
        begin
          Fixed := Round((clY - Y) * W);
          PVertKernel := @VertKernel;
          FloorKernel := @FWeightTable.ValPtr[KWidth - MAX_KERNEL_WIDTH, Int]^;
          CeilKernel := PKernelEntry(NativeUInt(FloorKernel) + J);
          Dev := -256;
          for I := -KWidth to KWidth do
          begin
            Wv := FloorKernel[I] + ((CeilKernel[I] - FloorKernel[I]) * Frac + $7FFF) div FixedOne;
            VertKernel[I] := Wv;
            Inc(Dev, Wv);
          end;
          Dec(VertKernel[0], Dev);
        end;
      end;

  end;

  VertEntry := Default(TBufferEntry);
  case PixelAccessMode of
    pamUnsafe, pamSafe, pamTransparentEdge:
      begin
        SrcP := PColor32Entry(Bitmap.PixelPtr[LoX + clX, LoY + clY]);
        Incr := Bitmap.Width - (HiX - LoX) - 1;
        for I := LoY to HiY do
        begin
          Wv := PVertKernel[I];
          if Wv <> 0 then
          begin
            HorzEntry := Default(TBufferEntry);
            for J := LoX to HiX do
            begin
              // Alpha=0 should not contribute to sample.
              Alpha := SrcP.A;
              if (Alpha <> 0) then
              begin
                W := PHorzKernel[J];
                Inc(HorzEntry.A, Alpha * W);
                // Sample premultiplied values
                if (Alpha = 255) then
                begin
                  Inc(HorzEntry.R, SrcP.R * W);
                  Inc(HorzEntry.G, SrcP.G * W);
                  Inc(HorzEntry.B, SrcP.B * W);
                end else
                begin
                  Inc(HorzEntry.R, Integer(Div255(Alpha * SrcP.R)) * W);
                  Inc(HorzEntry.G, Integer(Div255(Alpha * SrcP.G)) * W);
                  Inc(HorzEntry.B, Integer(Div255(Alpha * SrcP.B)) * W);
                end;
              end;
              Inc(SrcP);
            end;
            Inc(VertEntry.A, HorzEntry.A * Wv);
            Inc(VertEntry.R, HorzEntry.R * Wv);
            Inc(VertEntry.G, HorzEntry.G * Wv);
            Inc(VertEntry.B, HorzEntry.B * Wv);
          end else Inc(SrcP, HiX - LoX + 1);
          Inc(SrcP, Incr);
        end;

        if (PixelAccessMode = pamSafe) and Edge then
        begin
          Alpha := TColor32Entry(FOuterColor).A;

          // Alpha=0 should not contribute to sample.
          if (Alpha <> 0) then
          begin
            // Sample premultiplied values
            OuterPremultColorR := Integer(Div255(Alpha * TColor32Entry(FOuterColor).R));
            OuterPremultColorG := Integer(Div255(Alpha * TColor32Entry(FOuterColor).G));
            OuterPremultColorB := Integer(Div255(Alpha * TColor32Entry(FOuterColor).B));

            for I := -KWidth to KWidth do
            begin
              Wv := PVertKernel[I];
              if Wv <> 0 then
              begin
                HorzEntry := Default(TBufferEntry);
                for J := -KWidth to KWidth do
                  if (J < LoX) or (J > HiX) or (I < LoY) or (I > HiY) then
                  begin
                    W := PHorzKernel[J];
                    Inc(HorzEntry.A, Alpha * W);
                    Inc(HorzEntry.R, OuterPremultColorR * W);
                    Inc(HorzEntry.G, OuterPremultColorG * W);
                    Inc(HorzEntry.B, OuterPremultColorB * W);
                  end;
                Inc(VertEntry.A, HorzEntry.A * Wv);
                Inc(VertEntry.R, HorzEntry.R * Wv);
                Inc(VertEntry.G, HorzEntry.G * Wv);
                Inc(VertEntry.B, HorzEntry.B * Wv);
              end;
            end
          end;
        end;
      end;

    pamWrap:
      begin
        WrapProcHorz := GetWrapProcEx(Bitmap.WrapMode, ClipRect.Left, ClipRect.Right - 1);
        WrapProcVert := GetWrapProcEx(Bitmap.WrapMode, ClipRect.Top, ClipRect.Bottom - 1);

        for I := -KWidth to KWidth do
          MappingX[I] := WrapProcHorz(clX + I, ClipRect.Left, ClipRect.Right - 1);

        for I := -KWidth to KWidth do
        begin
          Wv := PVertKernel[I];
          if Wv <> 0 then
          begin
            MappingY := WrapProcVert(clY + I, ClipRect.Top, ClipRect.Bottom - 1);
            Colors := PColor32EntryArray(Bitmap.ScanLine[MappingY]);
            HorzEntry := Default(TBufferEntry);
            for J := -KWidth to KWidth do
            begin
              C := Colors[MappingX[J]];
              Alpha := C.A;
              // Alpha=0 should not contribute to sample.
              if (Alpha <> 0) then
              begin
                W := PHorzKernel[J];
                Inc(HorzEntry.A, Alpha * W);
                // Sample premultiplied values
                if (Alpha = 255) then
                begin
                  Inc(HorzEntry.R, C.R * W);
                  Inc(HorzEntry.G, C.G * W);
                  Inc(HorzEntry.B, C.B * W);
                end else
                begin
                  Inc(HorzEntry.R, Div255(Alpha * C.R) * W);
                  Inc(HorzEntry.G, Div255(Alpha * C.G) * W);
                  Inc(HorzEntry.B, Div255(Alpha * C.B) * W);
                end;
              end;
            end;
            Inc(VertEntry.A, HorzEntry.A * Wv);
            Inc(VertEntry.R, HorzEntry.R * Wv);
            Inc(VertEntry.G, HorzEntry.G * Wv);
            Inc(VertEntry.B, HorzEntry.B * Wv);
          end;
        end;
      end;
  end;

  // Round and unpremultiply result
  with TColor32Entry(Result) do
  begin
    if FKernel.RangeCheck then
    begin
      A := Clamp(TFixedRec(Integer(VertEntry.A + FixedHalf)).Int);
      if (A = 255) then
      begin
        R := Clamp(TFixedRec(Integer(VertEntry.R + FixedHalf)).Int);
        G := Clamp(TFixedRec(Integer(VertEntry.G + FixedHalf)).Int);
        B := Clamp(TFixedRec(Integer(VertEntry.B + FixedHalf)).Int);
      end else
      if (A <> 0) then
      begin
        R := Clamp(TFixedRec(Integer(VertEntry.R + FixedHalf)).Int * 255 div A);
        G := Clamp(TFixedRec(Integer(VertEntry.G + FixedHalf)).Int * 255 div A);
        B := Clamp(TFixedRec(Integer(VertEntry.B + FixedHalf)).Int * 255 div A);
      end else
      begin
        R := 0;
        G := 0;
        B := 0;
      end;
    end
    else
    begin
      A := TFixedRec(Integer(VertEntry.A + FixedHalf)).Int;
      if (A = 255) then
      begin
        R := TFixedRec(Integer(VertEntry.R + FixedHalf)).Int;
        G := TFixedRec(Integer(VertEntry.G + FixedHalf)).Int;
        B := TFixedRec(Integer(VertEntry.B + FixedHalf)).Int;
      end else
      if (A <> 0) then
      begin
        R := TFixedRec(Integer(VertEntry.R + FixedHalf)).Int * 255 div A;
        G := TFixedRec(Integer(VertEntry.G + FixedHalf)).Int * 255 div A;
        B := TFixedRec(Integer(VertEntry.B + FixedHalf)).Int * 255 div A;
      end else
      begin
        R := 0;
        G := 0;
        B := 0;
      end;
    end;
  end;
end;
{$WARNINGS ON}

function TKernelResampler.GetWidth: TFloat;
begin
  Result := Kernel.GetWidth;
end;

procedure TKernelResampler.SetKernelMode(const Value: TKernelMode);
begin
  if FKernelMode <> Value then
  begin
    FKernelMode := Value;
    Changed;
  end;
end;

procedure TKernelResampler.SetTableSize(Value: Integer);
begin
  if Value < 2 then Value := 2;
  if FTableSize <> Value then
  begin
    FTableSize := Value;
    Changed;
  end;
end;

procedure TKernelResampler.FinalizeSampling;
begin
  if FKernelMode in [kmTableNearest, kmTableLinear] then
    FWeightTable.Free;
  inherited;
end;

procedure TKernelResampler.PrepareSampling;
var
  I, J, W, Weight, Dev: Integer;
  Fraction: TFloat;
  KernelPtr: PKernelEntry;
begin
  inherited;
  FOuterColor := Bitmap.OuterColor;
  W := Ceil(FKernel.GetWidth);
  if FKernelMode in [kmTableNearest, kmTableLinear] then
  begin
    FWeightTable := TIntegerMap.Create(W * 2 + 1, FTableSize + 1);
    for I := 0 to FTableSize do
    begin
      Fraction := I / (FTableSize - 1);
      KernelPtr :=  @FWeightTable.ValPtr[W - MAX_KERNEL_WIDTH, I]^;
      Dev := - 256;
      for J := -W to W do
      begin
        Weight := Round(FKernel.Filter(J + Fraction) * 256);
        KernelPtr[J] := Weight;
        Inc(Dev, Weight);
      end;
      Dec(KernelPtr[0], Dev);
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      TNearestResampler
//
//------------------------------------------------------------------------------
function TNearestResampler.GetSampleInt(X, Y: Integer): TColor32;
begin
  Result := FGetSampleInt(X, Y);
end;

function TNearestResampler.GetSampleFixed(X, Y: TFixed): TColor32;
begin
  Result := FGetSampleInt(FixedRound(X), FixedRound(Y));
end;

function TNearestResampler.GetSampleFloat(X, Y: TFloat): TColor32;
begin
  Result := FGetSampleInt(Round(X), Round(Y));
end;

function TNearestResampler.GetWidth: TFloat;
begin
  Result := 1;
end;

function TNearestResampler.GetPixelTransparentEdge(X,Y: Integer): TColor32;
var
  I, J: Integer;
begin
  with Bitmap, Bitmap.ClipRect do
  begin
    I := Clamp(X, Left, Right - 1);
    J := Clamp(Y, Top, Bottom - 1);
    Result := Pixel[I, J];
    if (I <> X) or (J <> Y) then
      Result := Result and $00FFFFFF;
  end;
end;

procedure TNearestResampler.PrepareSampling;
begin
  inherited;
  case PixelAccessMode of
    pamUnsafe: FGetSampleInt := TCustomBitmap32Access(Bitmap).GetPixel;
    pamSafe: FGetSampleInt := TCustomBitmap32Access(Bitmap).GetPixelS;
    pamWrap: FGetSampleInt := TCustomBitmap32Access(Bitmap).GetPixelW;
    pamTransparentEdge: FGetSampleInt := GetPixelTransparentEdge;
  end;
end;

procedure TNearestResampler.Resample(
  Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
begin
  StretchNearest(Dst, DstRect, DstClip, Src, SrcRect, CombineOp, CombineCallBack)
end;


//------------------------------------------------------------------------------
//
//      TLinearResampler
//
//------------------------------------------------------------------------------
constructor TLinearResampler.Create;
begin
  inherited;
  FLinearKernel := TLinearKernel.Create;
end;

destructor TLinearResampler.Destroy;
begin
  FLinearKernel.Free;
  inherited Destroy;
end;

function TLinearResampler.GetSampleFixed(X, Y: TFixed): TColor32;
begin
  Result := FGetSampleFixed(X, Y);
end;

function TLinearResampler.GetSampleFloat(X, Y: TFloat): TColor32;
begin
  Result := FGetSampleFixed(Round(X * FixedOne), Round(Y * FixedOne));
end;

function TLinearResampler.GetPixelTransparentEdge(X, Y: TFixed): TColor32;
var
  PixelX, PixelY, X1, X2, Y1, Y2, WeightX, EdgeX, EdgeY: TFixed;
  C1, C2, C3, C4: TColor32;
  PSrc: PColor32Array;
begin
  EdgeX := Bitmap.ClipRect.Right - 1;
  EdgeY := Bitmap.ClipRect.Bottom - 1;

  PixelX := TFixedRec(X).Int;
  PixelY := TFixedRec(Y).Int;

  if (PixelX >= Bitmap.ClipRect.Left) and (PixelY >= Bitmap.ClipRect.Top) and (PixelX < EdgeX) and (PixelY < EdgeY) then
  begin //Safe
    Result := TCustomBitmap32Access(Bitmap).GET_T256(X shr 8, Y shr 8);
  end
  else
  if (PixelX >= Bitmap.ClipRect.Left - 1) and (PixelY >= Bitmap.ClipRect.Top - 1) and (PixelX <= EdgeX) and (PixelY <= EdgeY) then
  begin //Near edge, on edge or outside

    X1 := Clamp(PixelX, EdgeX);
    X2 := Clamp(PixelX + Sign(X), EdgeX);
    Y1 := Clamp(PixelY, EdgeY) * Bitmap.Width;
    Y2 := Clamp(PixelY + Sign(Y), EdgeY) * Bitmap.Width;

    PSrc := @Bitmap.Bits[0];
    C1 := PSrc[X1 + Y1];
    C2 := PSrc[X2 + Y1];
    C3 := PSrc[X1 + Y2];
    C4 := PSrc[X2 + Y2];

    if X <= Fixed(Bitmap.ClipRect.Left) then
    begin
      C1 := C1 and $00FFFFFF;
      C3 := C3 and $00FFFFFF;
    end else
    if PixelX = EdgeX then
    begin
      C2 := C2 and $00FFFFFF;
      C4 := C4 and $00FFFFFF;
    end;

    if Y <= Fixed(Bitmap.ClipRect.Top) then
    begin
      C1 := C1 and $00FFFFFF;
      C2 := C2 and $00FFFFFF;
    end else
    if PixelY = EdgeY then
    begin
      C3 := C3 and $00FFFFFF;
      C4 := C4 and $00FFFFFF;
    end;

    WeightX := ((X shr 8) and $FF) xor $FF;

    Result := CombineReg(CombineReg(C1, C2, WeightX),
                         CombineReg(C3, C4, WeightX),
                         ((Y shr 8) and $FF) xor $FF);
  end
  else
    Result := 0; //Nothing really makes sense here, return zero
end;

procedure TLinearResampler.PrepareSampling;
begin
  inherited;
  case PixelAccessMode of
    pamUnsafe: FGetSampleFixed := TCustomBitmap32Access(Bitmap).GetPixelX;
    pamSafe: FGetSampleFixed := TCustomBitmap32Access(Bitmap).GetPixelXS;
    pamWrap: FGetSampleFixed := TCustomBitmap32Access(Bitmap).GetPixelXW;
    pamTransparentEdge: FGetSampleFixed := GetPixelTransparentEdge;
  end;
end;

function TLinearResampler.GetWidth: TFloat;
begin
  Result := 1;
end;

procedure TLinearResampler.Resample(
  Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
var
  SrcW, SrcH: TFloat;
  DstW, DstH: Integer;
begin
  SrcW := SrcRect.Right - SrcRect.Left;
  SrcH := SrcRect.Bottom - SrcRect.Top;
  DstW := DstRect.Right - DstRect.Left;
  DstH := DstRect.Bottom - DstRect.Top;
  if (DstW > SrcW) and (DstH > SrcH) and (SrcW > 1) and (SrcH > 1) then
    StretchHorzStretchVertLinear(Dst, DstRect, DstClip, Src, SrcRect, CombineOp,
      CombineCallBack)
  else
    GR32_Resamplers.Resample(Dst, DstRect, DstClip, Src, SrcRect, FLinearKernel,
      CombineOp, CombineCallBack);
end;

procedure TDraftResampler.Resample(
  Dst: TCustomBitmap32; DstRect: TRect; DstClip: TRect;
  Src: TCustomBitmap32; SrcRect: TRect;
  CombineOp: TDrawMode; CombineCallBack: TPixelCombineEvent);
begin
  DraftResample(Dst, DstRect, DstClip, Src, SrcRect, FLinearKernel, CombineOp,
    CombineCallBack)
end;


//------------------------------------------------------------------------------
//
//      TTransformer
//
//------------------------------------------------------------------------------
function TTransformer.GetSampleInt(X, Y: Integer): TColor32;
var
  U, V: TFixed;
begin
  FTransformFixed(X * FixedOne + FixedHalf, Y * FixedOne + FixedHalf, U, V);
  Result := FGetSampleFixed(U - FixedHalf, V - FixedHalf);
end;

function TTransformer.GetSampleFixed(X, Y: TFixed): TColor32;
var
  U, V: TFixed;
begin
  FTransformFixed(X + FixedHalf, Y + FixedHalf, U, V);
  Result := FGetSampleFixed(U - FixedHalf, V - FixedHalf);
end;

function TTransformer.GetSampleFloat(X, Y: TFloat): TColor32;
var
  U, V: TFloat;
begin
  FTransformFloat(X + 0.5, Y + 0.5, U, V);
  Result := FGetSampleFloat(U - 0.5, V - 0.5);
end;

constructor TTransformer.Create(ASampler: TCustomSampler; ATransformation: TTransformation; AReverse: boolean);
begin
  inherited Create(ASampler);
  FTransformation := ATransformation;
  FReverse := AReverse;
end;

procedure TTransformer.PrepareSampling;
begin
  inherited;

  if (FTransformation = nil) then
    raise ETransformerException.Create(STransformationNil);

  if (FReverse) then
  begin
    FTransformInt := TTransformationAccess(FTransformation).ReverseTransformInt;
    FTransformFixed := TTransformationAccess(FTransformation).ReverseTransformFixed;
    FTransformFloat := TTransformationAccess(FTransformation).ReverseTransformFloat;
  end else
  begin
    FTransformInt := TTransformationAccess(FTransformation).TransformInt;
    FTransformFixed := TTransformationAccess(FTransformation).TransformFixed;
    FTransformFloat := TTransformationAccess(FTransformation).TransformFloat;
  end;

  if not TTransformationAccess(FTransformation).TransformValid then
    TTransformationAccess(FTransformation).PrepareTransform;
end;

function TTransformer.GetSampleBounds: TFloatRect;
begin
  GR32.IntersectRect(Result, inherited GetSampleBounds, FTransformation.SrcRect);
  Result := FTransformation.GetTransformedBounds(Result);
end;

function TTransformer.HasBounds: Boolean;
begin
  Result := FTransformation.HasTransformedBounds and inherited HasBounds;
end;


//------------------------------------------------------------------------------
//
//      TSuperSampler
//
//------------------------------------------------------------------------------
constructor TSuperSampler.Create(Sampler: TCustomSampler);
begin
  inherited Create(Sampler);
  FSamplingX := 4;
  FSamplingY := 4;
  SamplingX := 4;
  SamplingY := 4;
end;

function TSuperSampler.GetSampleFixed(X, Y: TFixed): TColor32;
var
  I, J: Integer;
  dX, dY, tX: TFixed;
  Buffer: TBufferEntry;
begin
  Buffer := Default(TBufferEntry);
  tX := X + FOffsetX;
  Inc(Y, FOffsetY);
  dX := FDistanceX;
  dY := FDistanceY;
  for J := 1 to FSamplingY do
  begin
    X := tX;
    for I := 1 to FSamplingX do
    begin
      IncBuffer(Buffer, FGetSampleFixed(X, Y));
      Inc(X, dX);
    end;
    Inc(Y, dY);
  end;
  MultiplyBuffer(Buffer, FScale);
  Result := BufferToColor32(Buffer, 16);
end;

procedure TSuperSampler.SetSamplingX(const Value: TSamplingRange);
begin
  FSamplingX := Value;
  FDistanceX := Fixed(1 / Value);
  FOffsetX := Fixed(((1 / Value) - 1) * 0.5);     // replaced "/2" by "*0.5"
  FScale := Fixed(1 / (FSamplingX * FSamplingY));
end;

procedure TSuperSampler.SetSamplingY(const Value: TSamplingRange);
begin
  FSamplingY := Value;
  FDistanceY := Fixed(1 / Value);
  FOffsetY := Fixed(((1 / Value) - 1) * 0.5);     // replaced "/2" by "*0.5"
  FScale := Fixed(1 / (FSamplingX * FSamplingY));
end;


//------------------------------------------------------------------------------
//
//      TAdaptiveSuperSampler
//
//------------------------------------------------------------------------------
function TAdaptiveSuperSampler.CompareColors(C1, C2: TColor32): Boolean;
var
  Diff: TColor32Entry;
begin
  Diff.ARGB := ColorDifference(C1, C2);
  Result := FTolerance < Diff.R + Diff.G + Diff.B;
end;

constructor TAdaptiveSuperSampler.Create(Sampler: TCustomSampler);
begin
  inherited Create(Sampler);
  Level := 4;
  Tolerance := 256;
end;

function TAdaptiveSuperSampler.DoRecurse(X, Y, Offset: TFixed; const A, B,
  C, D, E: TColor32): TColor32;
var
  C1, C2, C3, C4: TColor32;
begin
  C1 := QuadrantColor(A, E, X - Offset, Y - Offset, Offset, RecurseAC);
  C2 := QuadrantColor(B, E, X + Offset, Y - Offset, Offset, RecurseBD);
  C3 := QuadrantColor(E, C, X + Offset, Y + Offset, Offset, RecurseAC);
  C4 := QuadrantColor(E, D, X - Offset, Y + Offset, Offset, RecurseBD);
  Result := ColorAverage(ColorAverage(C1, C2), ColorAverage(C3, C4));
end;

function TAdaptiveSuperSampler.GetSampleFixed(X, Y: TFixed): TColor32;
var
  A, B, C, D, E: TColor32;
const
  FIXED_HALF = 32768;
begin
  A := FGetSampleFixed(X - FIXED_HALF, Y - FIXED_HALF);
  B := FGetSampleFixed(X + FIXED_HALF, Y - FIXED_HALF);
  C := FGetSampleFixed(X + FIXED_HALF, Y + FIXED_HALF);
  D := FGetSampleFixed(X - FIXED_HALF, Y + FIXED_HALF);
  E := FGetSampleFixed(X, Y);
  Result := Self.DoRecurse(X, Y, 16384, A, B, C, D, E);
end;

function TAdaptiveSuperSampler.QuadrantColor(const C1, C2: TColor32; X, Y,
  Offset: TFixed; Proc: TRecurseProc): TColor32;
begin
  if CompareColors(C1, C2) and (Offset >= FMinOffset) then
    Result := Proc(X, Y, Offset, C1, C2)
  else
    Result := ColorAverage(C1, C2);
end;

function TAdaptiveSuperSampler.RecurseAC(X, Y, Offset: TFixed; const A,
  C: TColor32): TColor32;
var
  B, D, E: TColor32;
begin
  B := FGetSampleFixed(X + Offset, Y - Offset);
  D := FGetSampleFixed(X - Offset, Y + Offset);
  E := FGetSampleFixed(X, Y);
  Result := DoRecurse(X, Y, Offset shr 1, A, B, C, D, E);
end;

function TAdaptiveSuperSampler.RecurseBD(X, Y, Offset: TFixed; const B,
  D: TColor32): TColor32;
var
  A, C, E: TColor32;
begin
  A := FGetSampleFixed(X - Offset, Y - Offset);
  C := FGetSampleFixed(X + Offset, Y + Offset);
  E := FGetSampleFixed(X, Y);
  Result := DoRecurse(X, Y, Offset shr 1, A, B, C, D, E);
end;

procedure TAdaptiveSuperSampler.SetLevel(const Value: Integer);
begin
  FLevel := Value;
  FMinOffset := Fixed(1 / (1 shl Value));
end;


//------------------------------------------------------------------------------
//
//      TPatternSampler
//
//------------------------------------------------------------------------------
destructor TPatternSampler.Destroy;
begin
  FPattern := nil;
  inherited;
end;

function TPatternSampler.GetSampleFixed(X, Y: TFixed): TColor32;
var
  Points: TArrayOfFixedPoint;
  P: PFixedPoint;
  I, PY: Integer;
  Buffer: TBufferEntry;
  GetSample: TGetSampleFixed;
  WrapProcHorz: TWrapProc;
begin
  GetSample := FSampler.GetSampleFixed;
  PY := WrapProcVert(TFixedRec(Y).Int, High(FPattern));
  I := High(FPattern[PY]);
  WrapProcHorz := GetOptimalWrap(I);
  Points := FPattern[PY][WrapProcHorz(TFixedRec(X).Int, I)];
  Buffer := Default(TBufferEntry);
  P := @Points[0];
  for I := 0 to High(Points) do
  begin
    IncBuffer(Buffer, GetSample(P.X + X, P.Y + Y));
    Inc(P);
  end;
  MultiplyBuffer(Buffer, FixedOne div Length(Points));
  Result := BufferToColor32(Buffer, 16);
end;

procedure TPatternSampler.SetPattern(const Value: TFixedSamplePattern);
begin
  if (Value <> nil) then
  begin
    FPattern := Value;
    WrapProcVert := GetOptimalWrap(High(FPattern));
  end;
end;


//------------------------------------------------------------------------------
//
//      CreateJitteredPattern
//
//------------------------------------------------------------------------------
function JitteredPattern(XRes, YRes: Integer): TArrayOfFixedPoint;
var
  I, J: Integer;
begin
  SetLength(Result, XRes * YRes);
  for I := 0 to XRes - 1 do
    for J := 0 to YRes - 1 do
      with Result[I + J * XRes] do
        begin
          X := (Random(65536) + I * 65536) div XRes - 32768;
          Y := (Random(65536) + J * 65536) div YRes - 32768;
        end;
end;

function CreateJitteredPattern(TileWidth, TileHeight, SamplesX, SamplesY: Integer): TFixedSamplePattern;
var
  I, J: Integer;
begin
  SetLength(Result, TileHeight, TileWidth);
  for I := 0 to TileWidth - 1 do
    for J := 0 to TileHeight - 1 do
      Result[J][I] := JitteredPattern(SamplesX, SamplesY);
end;


//------------------------------------------------------------------------------
//
//      TNestedSampler
//
//------------------------------------------------------------------------------
procedure TNestedSampler.AssignTo(Dst: TPersistent);
begin
  if Dst is TNestedSampler then
    SmartAssign(Self, Dst)
  else
    inherited;
end;

constructor TNestedSampler.Create(ASampler: TCustomSampler);
begin
  inherited Create;
  Sampler := ASampler;
end;

procedure TNestedSampler.FinalizeSampling;
begin
  if (FSampler = nil) then
    raise ENestedException.Create(SSamplerNil);
  FSampler.FinalizeSampling;
end;

{$WARNINGS OFF}
function TNestedSampler.GetSampleBounds: TFloatRect;
begin
  if (FSampler = nil) then
    raise ENestedException.Create(SSamplerNil);
  Result := FSampler.GetSampleBounds;
end;

function TNestedSampler.HasBounds: Boolean;
begin
  if (FSampler = nil) then
    raise ENestedException.Create(SSamplerNil);
  Result := FSampler.HasBounds;
end;
{$WARNINGS ON}

procedure TNestedSampler.PrepareSampling;
begin
  if (FSampler = nil) then
    raise ENestedException.Create(SSamplerNil);
  FSampler.PrepareSampling;
end;

procedure TNestedSampler.SetSampler(const Value: TCustomSampler);
begin
  FSampler := Value;
  if (Value <> nil) then
  begin
    FGetSampleInt := FSampler.GetSampleInt;
    FGetSampleFixed := FSampler.GetSampleFixed;
    FGetSampleFloat := FSampler.GetSampleFloat;
  end;
end;


//------------------------------------------------------------------------------
//
//      TKernelSampler
//
//------------------------------------------------------------------------------
function TKernelSampler.ConvertBuffer(var Buffer: TBufferEntry): TColor32;
begin
  Buffer.A := Constrain(Buffer.A, 0, $FFFF);
  Buffer.R := Constrain(Buffer.R, 0, $FFFF);
  Buffer.G := Constrain(Buffer.G, 0, $FFFF);
  Buffer.B := Constrain(Buffer.B, 0, $FFFF);

  Result := BufferToColor32(Buffer, 8);
end;

constructor TKernelSampler.Create(ASampler: TCustomSampler);
begin
  inherited;
  FKernel := TIntegerMap.Create;
  FStartEntry := Default(TBufferEntry);
end;

destructor TKernelSampler.Destroy;
begin
  FKernel.Free;
  inherited;
end;

function TKernelSampler.GetSampleFixed(X, Y: TFixed): TColor32;
var
  I, J: Integer;
  Buffer: TBufferEntry;
begin
  X := X + FCenterX shl 16;
  Y := Y + FCenterY shl 16;
  Buffer := FStartEntry;
  for I := 0 to FKernel.Width - 1 do
    for J := 0 to FKernel.Height - 1 do
      UpdateBuffer(Buffer, FGetSampleFixed(X - I shl 16, Y - J shl 16), FKernel[I, J]);

  Result := ConvertBuffer(Buffer);
end;

function TKernelSampler.GetSampleInt(X, Y: Integer): TColor32;
var
  I, J: Integer;
  Buffer: TBufferEntry;
begin
  X := X + FCenterX;
  Y := Y + FCenterY;
  Buffer := FStartEntry;
  for I := 0 to FKernel.Width - 1 do
    for J := 0 to FKernel.Height - 1 do
      UpdateBuffer(Buffer, FGetSampleInt(X - I, Y - J), FKernel[I, J]);

  Result := ConvertBuffer(Buffer);
end;

procedure TKernelSampler.SetKernel(const Value: TIntegerMap);
begin
  FKernel.Assign(Value);
end;


//------------------------------------------------------------------------------
//
//      TConvolver
//
//------------------------------------------------------------------------------
procedure TConvolver.UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
  Weight: Integer);
begin
  with TColor32Entry(Color) do
  begin
    Inc(Buffer.A, A * Weight);
    Inc(Buffer.R, R * Weight);
    Inc(Buffer.G, G * Weight);
    Inc(Buffer.B, B * Weight);
  end;
end;


//------------------------------------------------------------------------------
//
//      TDilater
//
//------------------------------------------------------------------------------
procedure TDilater.UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
  Weight: Integer);
begin
  with TColor32Entry(Color) do
  begin
    Buffer.A := Max(Buffer.A, A + Weight);
    Buffer.R := Max(Buffer.R, R + Weight);
    Buffer.G := Max(Buffer.G, G + Weight);
    Buffer.B := Max(Buffer.B, B + Weight);
  end;
end;


//------------------------------------------------------------------------------
//
//      TEroder
//
//------------------------------------------------------------------------------
constructor TEroder.Create(ASampler: TCustomSampler);
const
  START_ENTRY: TBufferEntry = (B: $FFFF; G: $FFFF; R: $FFFF; A: $FFFF);
begin
  inherited;
  FStartEntry := START_ENTRY;
end;

procedure TEroder.UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
  Weight: Integer);
begin
  with TColor32Entry(Color) do
  begin
    Buffer.A := Min(Buffer.A, A - Weight);
    Buffer.R := Min(Buffer.R, R - Weight);
    Buffer.G := Min(Buffer.G, G - Weight);
    Buffer.B := Min(Buffer.B, B - Weight);
  end;
end;


//------------------------------------------------------------------------------
//
//      TExpander
//
//------------------------------------------------------------------------------
procedure TExpander.UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
  Weight: Integer);
begin
  with TColor32Entry(Color) do
  begin
    Buffer.A := Max(Buffer.A, A * Weight);
    Buffer.R := Max(Buffer.R, R * Weight);
    Buffer.G := Max(Buffer.G, G * Weight);
    Buffer.B := Max(Buffer.B, B * Weight);
  end;
end;


//------------------------------------------------------------------------------
//
//      TContracter
//
//------------------------------------------------------------------------------
function TContracter.GetSampleFixed(X, Y: TFixed): TColor32;
begin
  Result := ColorSub(FMaxWeight, inherited GetSampleFixed(X, Y));
end;

function TContracter.GetSampleInt(X, Y: Integer): TColor32;
begin
  Result := ColorSub(FMaxWeight, inherited GetSampleInt(X, Y));
end;

procedure TContracter.PrepareSampling;
var
  I, J, W: Integer;
begin
  W := Low(Integer);
  for I := 0 to FKernel.Width - 1 do
    for J := 0 to FKernel.Height - 1 do
      W := Max(W, FKernel[I, J]);
  if W > 255 then
    W := 255;
  FMaxWeight := Gray32(W, W);
end;

procedure TContracter.UpdateBuffer(var Buffer: TBufferEntry; Color: TColor32;
  Weight: Integer);
begin
  inherited UpdateBuffer(Buffer, Color xor $FFFFFFFF, Weight);
end;


//------------------------------------------------------------------------------
//
//      TMorphologicalSampler
//
//------------------------------------------------------------------------------
function TMorphologicalSampler.ConvertBuffer(
  var Buffer: TBufferEntry): TColor32;
begin
  Buffer.A := Constrain(Buffer.A, 0, $FF);
  Buffer.R := Constrain(Buffer.R, 0, $FF);
  Buffer.G := Constrain(Buffer.G, 0, $FF);
  Buffer.B := Constrain(Buffer.B, 0, $FF);

  with TColor32Entry(Result) do
  begin
    A := Buffer.A;
    R := Buffer.R;
    G := Buffer.G;
    B := Buffer.B;
  end;
end;


//------------------------------------------------------------------------------
//
//      TSelectiveConvolver
//
//------------------------------------------------------------------------------
function TSelectiveConvolver.ConvertBuffer(var Buffer: TBufferEntry): TColor32;
begin
  with TColor32Entry(Result) do
  begin
    A := Buffer.A div FWeightSum.A;
    R := Buffer.R div FWeightSum.R;
    G := Buffer.G div FWeightSum.G;
    B := Buffer.B div FWeightSum.B;
  end;
end;

constructor TSelectiveConvolver.Create(ASampler: TCustomSampler);
begin
  inherited;
  FDelta := 30;
end;

function TSelectiveConvolver.GetSampleFixed(X, Y: TFixed): TColor32;
begin
  FRefColor := FGetSampleFixed(X, Y);
  FWeightSum := Default(TBufferEntry);
  Result := inherited GetSampleFixed(X, Y);
end;

function TSelectiveConvolver.GetSampleInt(X, Y: Integer): TColor32;
begin
  FRefColor := FGetSampleInt(X, Y);
  FWeightSum := Default(TBufferEntry);
  Result := inherited GetSampleInt(X, Y);
end;

procedure TSelectiveConvolver.UpdateBuffer(var Buffer: TBufferEntry;
  Color: TColor32; Weight: Integer);
begin
  with TColor32Entry(Color) do
  begin
    if Abs(TColor32Entry(FRefColor).A - A) <= FDelta then
    begin
      Inc(Buffer.A, A * Weight);
      Inc(FWeightSum.A, Weight);
    end;
    if Abs(TColor32Entry(FRefColor).R - R) <= FDelta then
    begin
      Inc(Buffer.R, R * Weight);
      Inc(FWeightSum.R, Weight);
    end;
    if Abs(TColor32Entry(FRefColor).G - G) <= FDelta then
    begin
      Inc(Buffer.G, G * Weight);
      Inc(FWeightSum.G, Weight);
    end;
    if Abs(TColor32Entry(FRefColor).B - B) <= FDelta then
    begin
      Inc(Buffer.B, B * Weight);
      Inc(FWeightSum.B, Weight);
    end;
  end;
end;

//------------------------------------------------------------------------------
//
//      Registration routines
//
//------------------------------------------------------------------------------
procedure RegisterResampler(ResamplerClass: TCustomResamplerClass);
begin
  if (ResamplerList = nil) then
    ResamplerList := TResamplerList.Create;
  ResamplerList.Add(ResamplerClass);
end;

procedure RegisterKernel(KernelClass: TCustomKernelClass);
begin
  if (KernelList = nil) then
    KernelList := TKernelList.Create;
  KernelList.Add(KernelClass);
end;


//------------------------------------------------------------------------------
//
//      NO_GENERIC_METACLASS_LISTS
//
//------------------------------------------------------------------------------
{$if defined(NO_GENERIC_METACLASS_LISTS)}
function TKernelList.Find(const AClassName: string): TCustomKernelClass;
begin
  Result := TCustomKernelClass(inherited Find(AClassName));
end;

function TResamplerList.Find(const AClassName: string): TCustomResamplerClass;
begin
  Result := TCustomResamplerClass(inherited Find(AClassName));
end;
{$ifend}


//------------------------------------------------------------------------------
//
//      Bindings
//
//------------------------------------------------------------------------------
var
  ResamplersRegistry: TFunctionRegistry;

procedure RegisterBindings;
begin
  ResamplersRegistry := NewRegistry('GR32_Resamplers bindings');
  ResamplersRegistry.RegisterBinding(@@BlockAverage, 'BlockAverage');
  ResamplersRegistry.RegisterBinding(@@Interpolator, 'Interpolator');

  ResamplersRegistry[@@BlockAverage].ADD(@BlockAverage_Pas, [isPascal]).Name := 'BlockAverage_Pas';
  ResamplersRegistry[@@Interpolator].ADD(@Interpolator_Pas, [isPascal]).Name := 'Interpolator_Pas';
{$if (not defined(PUREPASCAL)) and (not defined(OMIT_SSE2))}
  ResamplersRegistry[@@BlockAverage].ADD(@BlockAverage_SSE2, [isSSE2]).Name := 'BlockAverage_SSE2';
  ResamplersRegistry[@@Interpolator].ADD(@Interpolator_SSE2, [isSSE2]).Name := 'Interpolator_SSE2';
{$ifend}
  ResamplersRegistry.RebindAll;
end;

//------------------------------------------------------------------------------

initialization
  RegisterBindings;

  { Register resamplers }
  RegisterResampler(TNearestResampler);
  RegisterResampler(TLinearResampler);
  RegisterResampler(TDraftResampler);
  RegisterResampler(TKernelResampler);

  { Register kernels }
  RegisterKernel(TBoxKernel);
  RegisterKernel(TLinearKernel);
  RegisterKernel(TCosineKernel);
  RegisterKernel(TSplineKernel);
  RegisterKernel(TCubicKernel);
  RegisterKernel(TMitchellKernel);
  RegisterKernel(TAlbrechtKernel);
  RegisterKernel(TLanczosKernel);
  RegisterKernel(TGaussianKernel);
  RegisterKernel(TBlackmanKernel);
  RegisterKernel(THannKernel);
  RegisterKernel(THammingKernel);
  RegisterKernel(TSinshKernel);
  RegisterKernel(THermiteKernel);

finalization
  ResamplerList.Free;
  KernelList.Free;

end.
