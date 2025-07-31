unit GR32_Paths;

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
 * The Original Code is Vectorial Polygon Rasterizer for Graphics32
 *
 * The Initial Developer of the Original Code is
 * Mattias Andersson <mattias@centaurix.com>
 *
 * Portions created by the Initial Developer are Copyright (C) 2012
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$include GR32.inc}

// Define one of the following two *QuadraticBezierCurve symbols to select
// the algorithm used to flatten quadratic Bezier curves.
//
// - RecursiveQuadraticBezierCurve is the classic De Casteljau algorithm.
//
// - RaphLevienQuadraticBezierCurve is a new analytic algorithm which
//   produces far less vertices for the same error tolerance.
//
// If none of the symbols are defined the RaphLevienQuadraticBezierCurve
// implementation is used.
//
{-$define RecursiveQuadraticBezierCurve}
{-$define RaphLevienQuadraticBezierCurve}

uses
  Classes, SysUtils,
  GR32,
  GR32_Math,
  GR32_Polygons,
  GR32_Transforms,
  GR32_Brushes,
  GR32_Geometry,
  GR32.Text.Types;

const
  DefaultCircleSteps = 100;
  DefaultBezierTolerance = 0.25;

type
  TControlPointOrigin = (cpNone, cpCubic, cpConic);

  { TCustomPath }
  TCustomPath = class(TThreadPersistent)
  private
    FCurrentPoint: TFloatPoint;
    FLastControlPoint: TFloatPoint;
    FControlPointOrigin: TControlPointOrigin;
  protected
    procedure AddPoint(const Point: TFloatPoint); virtual;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create; override;

    procedure Clear; virtual;

    procedure BeginPath; deprecated 'No longer necessary. Path is started automatically';
    procedure EndPath(Close: boolean = False); virtual;
    procedure ClosePath; deprecated 'Use EndPath(True) instead';

    // Movement
    procedure MoveTo(const X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure MoveTo(const P: TFloatPoint); overload; virtual;
    procedure MoveToRelative(const X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure MoveToRelative(const P: TFloatPoint); overload; {$IFDEF USEINLINING} inline; {$ENDIF}

    // Lines and Curves
    procedure LineTo(const X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure LineTo(const P: TFloatPoint); overload; virtual;
    procedure LineToRelative(const X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure LineToRelative(const P: TFloatPoint); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure HorizontalLineTo(const X: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure HorizontalLineToRelative(const X: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure VerticalLineTo(const Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure VerticalLineToRelative(const Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    // Cubic beziers
    procedure CurveTo(const X1, Y1, X2, Y2, X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure CurveTo(const X2, Y2, X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure CurveTo(const C1, C2, P: TFloatPoint); overload; virtual;
    procedure CurveTo(const C2, P: TFloatPoint); overload; virtual;
    procedure CurveToRelative(const X1, Y1, X2, Y2, X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure CurveToRelative(const X2, Y2, X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure CurveToRelative(const C1, C2, P: TFloatPoint); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure CurveToRelative(const C2, P: TFloatPoint); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    // Quadratic bezier
    procedure ConicTo(const X1, Y1, X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure ConicTo(const P1, P: TFloatPoint); overload; virtual;
    procedure ConicTo(const X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure ConicTo(const P: TFloatPoint); overload; virtual;
    procedure ConicToRelative(const X1, Y1, X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure ConicToRelative(const P1, P: TFloatPoint); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure ConicToRelative(const X, Y: TFloat); overload; {$IFDEF USEINLINING} inline; {$ENDIF}
    procedure ConicToRelative(const P: TFloatPoint); overload; {$IFDEF USEINLINING} inline; {$ENDIF}

    // Polylines
    procedure Arc(const P: TFloatPoint; StartAngle, EndAngle, Radius: TFloat);
    procedure PolyLine(const APoints: TArrayOfFloatPoint; AOffset: integer = 0); virtual;
    procedure PolyPolyLine(const APoints: TArrayOfArrayOfFloatPoint); virtual;

    // Closed Polygons
    procedure Rectangle(const Rect: TFloatRect); virtual;
    procedure RoundRect(const Rect: TFloatRect; const Radius: TFloat); virtual;
    procedure Ellipse(Rx, Ry: TFloat; Steps: Integer = DefaultCircleSteps); overload; virtual;
    procedure Ellipse(const Cx, Cy, Rx, Ry: TFloat; Steps: Integer = DefaultCircleSteps); overload; virtual;
    procedure Circle(const Cx, Cy, Radius: TFloat; Steps: Integer = DefaultCircleSteps); overload; virtual;
    procedure Circle(const Center: TFloatPoint; Radius: TFloat; Steps: Integer = DefaultCircleSteps); overload; virtual;
    procedure Polygon(const APoints: TArrayOfFloatPoint); virtual;
    procedure PolyPolygon(const APoints: TArrayOfArrayOfFloatPoint); virtual;

    property CurrentPoint: TFloatPoint read FCurrentPoint write FCurrentPoint;
  end;

  { TFlattenedPath }
  TFlattenedPath = class(TCustomPath)
  private
    FPath: TArrayOfArrayOfFloatPoint;
    FClosed: TBooleanArray;
    FClosedCount: integer;
    FPoints: TArrayOfFloatPoint;
    FPointIndex: Integer;
    FOnBeginPath: TNotifyEvent;
    FOnEndPath: TNotifyEvent;
  protected
    function GetPoints: TArrayOfFloatPoint;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure AddPoint(const Point: TFloatPoint); override;
    procedure DoBeginPath; virtual;
    procedure DoEndPath; virtual;
    procedure ClearPoints;

    // Points temporarily holds the vertices used to build a path. Cleared after path has been constructed.
    property Points: TArrayOfFloatPoint read GetPoints;
    property ClosedCount: integer read FClosedCount;
  public
    procedure Clear; override;

    procedure EndPath(Close: boolean = False); override;

    // MoveTo* implicitly ends the current path.
    procedure MoveTo(const P: TFloatPoint); override;

    property Path: TArrayOfArrayOfFloatPoint read FPath;
    property PathClosed: TBooleanArray read FClosed;

    property OnBeginPath: TNotifyEvent read FOnBeginPath write FOnBeginPath;
    property OnEndPath: TNotifyEvent read FOnEndPath write FOnEndPath;
  end;

  { TCustomCanvas }
  TCustomCanvas = class(TFlattenedPath)
  private
    FTransformation: TTransformation;
  protected
    procedure SetTransformation(const Value: TTransformation);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DoChanged; override;
    procedure DrawPath(const Path: TFlattenedPath); virtual; abstract;
  public
    property Transformation: TTransformation read FTransformation write SetTransformation;
  end;

  { TCanvas32 }
  TCanvas32 = class(TCustomCanvas)
  private
    FBitmap: TBitmap32;
    FRenderer: TPolygonRenderer32;
    FBrushes: TBrushCollection;
  protected
    function GetRendererClassName: string;
    procedure SetRendererClassName(const Value: string);
    procedure SetRenderer(ARenderer: TPolygonRenderer32);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DrawPath(const Path: TFlattenedPath); override;
    class function GetPolygonRendererClass: TPolygonRenderer32Class; virtual;
    procedure BrushCollectionChangeHandler(Sender: TObject); virtual;
  public
    constructor Create(ABitmap: TBitmap32); reintroduce; virtual;
    destructor Destroy; override;

    procedure RenderText(X, Y: TFloat; const Text: string; Flags: Cardinal); overload;
    procedure RenderText(const DstRect: TFloatRect; const Text: string; Flags: Cardinal); overload;
    function MeasureText(const DstRect: TFloatRect; const Text: string; Flags: Cardinal): TFloatRect; overload;

    procedure RenderText(X, Y: TFloat; const Text: string); overload;
    procedure RenderText(X, Y: TFloat; const Text: string; const Layout: TTextLayout); overload;
    procedure RenderText(const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout); overload;
    function MeasureText(const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout): TFloatRect; overload;

    property Bitmap: TBitmap32 read FBitmap;
    property Renderer: TPolygonRenderer32 read FRenderer write SetRenderer;
    property RendererClassName: string read GetRendererClassName write SetRendererClassName;
    property Brushes: TBrushCollection read FBrushes;
  end;

var
  CBezierTolerance: TFloat = DefaultBezierTolerance;
  QBezierTolerance: TFloat = DefaultBezierTolerance;

type
  TAddPointEvent = procedure(const Point: TFloatPoint) of object;

implementation

uses
  Math,
  Types,
  GR32_Backends,
  GR32_VectorUtils;

const
  VertexBufferSizeLow = 256;
  VertexBufferSizeGrow = 128;

function CubicBezierFlatness(const P1, P2, P3, P4: TFloatPoint): TFloat; {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  Result :=
    Abs(P1.X + P3.X - 2 * P2.X) +
    Abs(P1.Y + P3.Y - 2 * P2.Y) +
    Abs(P2.X + P4.X - 2 * P3.X) +
    Abs(P2.Y + P4.Y - 2 * P3.Y);
end;

function QuadraticBezierFlatness(const P1, P2, P3: TFloatPoint): TFloat; {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  Result :=
    Abs(P1.x + P3.x - 2 * P2.x) +
    Abs(P1.y + P3.y - 2 * P2.y);
end;

procedure CubicBezierCurve(const P1, P2, P3, P4: TFloatPoint; const AddPoint: TAddPointEvent; const Tolerance: TFloat);

  procedure DoCubicBezierCurve(const P1, P2, P3, P4: TFloatPoint);
  var
    P12, P23, P34, P123, P234, P1234: TFloatPoint;
  begin
    if CubicBezierFlatness(P1, P2, P3, P4) < Tolerance then
      AddPoint(P1)
    else
    begin
      P12.X   := (P1.X + P2.X) * 0.5;
      P12.Y   := (P1.Y + P2.Y) * 0.5;
      P23.X   := (P2.X + P3.X) * 0.5;
      P23.Y   := (P2.Y + P3.Y) * 0.5;
      P34.X   := (P3.X + P4.X) * 0.5;
      P34.Y   := (P3.Y + P4.Y) * 0.5;
      P123.X  := (P12.X + P23.X) * 0.5;
      P123.Y  := (P12.Y + P23.Y) * 0.5;
      P234.X  := (P23.X + P34.X) * 0.5;
      P234.Y  := (P23.Y + P34.Y) * 0.5;
      P1234.X := (P123.X + P234.X) * 0.5;
      P1234.Y := (P123.Y + P234.Y) * 0.5;

      DoCubicBezierCurve(P1, P12, P123, P1234);
      DoCubicBezierCurve(P1234, P234, P34, P4);
    end;
  end;

begin
  DoCubicBezierCurve(P1, P2, P3, P4);
end;

//------------------------------------------------------------------------------
//
//      Quadratic Bezier curve flattening
//
//------------------------------------------------------------------------------
// Glyph cache access point.
//------------------------------------------------------------------------------
type
  TQuadraticBezierCurve = procedure(const P1, P2, P3: TFloatPoint; const AddPoint: TAddPointEvent; const Tolerance: TFloat);


//------------------------------------------------------------------------------
// Recursive subdivision using Paul de Casteljau's algorithm
//------------------------------------------------------------------------------
procedure RecursiveQuadraticBezierCurve(const P1, P2, P3: TFloatPoint; const AddPoint: TAddPointEvent; const Tolerance: TFloat);

  procedure DoQuadraticBezierCurve(const P1, P2, P3: TFloatPoint);
  var
    P12, P23, P123: TFloatPoint;
  begin
    if QuadraticBezierFlatness(P1, P2, P3) < Tolerance then
      AddPoint(P1)
    else
    begin
      P12.X := (P1.X + P2.X) * 0.5;
      P12.Y := (P1.Y + P2.Y) * 0.5;
      P23.X := (P2.X + P3.X) * 0.5;
      P23.Y := (P2.Y + P3.Y) * 0.5;
      P123.X := (P12.X + P23.X) * 0.5;
      P123.Y := (P12.Y + P23.Y) * 0.5;

      DoQuadraticBezierCurve(P1, P12, P123);
      DoQuadraticBezierCurve(P123, P23, P3);
    end;
  end;

begin
  DoQuadraticBezierCurve(P1, P2, P3);
end;


//------------------------------------------------------------------------------
// Analytic subdivision using Raph Levien's algorithm
// License: Apache 2.0
// https://www.apache.org/licenses/LICENSE-2.0
//------------------------------------------------------------------------------
procedure RaphLevienQuadraticBezierCurve(const P1, P2, P3: TFloatPoint; const AddPoint: TAddPointEvent; const Tolerance: TFloat);
var
  x0, x2, Scale: Single;

  // Determine the x values and scaling to map to y=x^2
  procedure MapToBasic;
  var
    ddX: Single;
    ddY: Single;
    u0: Single;
    u2: Single;
    Cross: Single;
    OneOverCross: Single;
  begin
    ddX := 2 * P2.X - P1.X - P3.X;
    ddY := 2 * P2.Y - P1.Y - P3.Y;
    u0 := (P2.X - P1.X) * ddX + (P2.Y - P1.Y) * ddY;
    u2 := (P3.X - P2.X) * ddX + (P3.Y - P2.Y) * ddY;
    Cross := (P3.X - P1.X) * ddY - (P3.Y - P1.Y) * ddX;

    // Fix sporadic error with rasterization of some fonts
    if (Cross = 0) then
    begin
      Scale := 0;
      exit;
    end;

    OneOverCross := 1 / Cross;

    x0 := u0 * OneOverCross;
    x2 := u2 * OneOverCross;
    // There's probably a more elegant formulation of this...
    Scale := Abs(Cross) / (GR32_Math.Hypot(ddX, ddY) * Abs(x2 - x0));
  end;

  // Compute an approximation to int (1 + 4x^2) ^ -0.25 dx
  // This isn't especially good but will do.
  function ApproxMyint(x: Single): Single; {$IFDEF USEINLINING} inline; {$ENDIF}
  const
    d: Single = 0.67;
  begin
    Result := x / (1 - d + Math.Power(Math.IntPower(d, 4) + 0.25 * x * x, 0.25));
  end;

  // Approximate the inverse of the function above.
  // This is better.
  function ApproxInvMyint(x: Single): Single; {$IFDEF USEINLINING} inline; {$ENDIF}
  const
    b: Single = 0.39;
  begin
    Result := x * (1 - b + Sqrt(b * b + 0.25 * x * x));
  end;

  procedure Evaluate(t: Single);
  var
    mt: Single;
    mt_mt: Single;
    t_mt: Single;
    t_t: Single;
    Point: TFloatPoint;
  begin
    mt := 1 - t;
    mt_mt := mt * mt;
    t_mt := t * mt;
    t_t := t * t;

    Point.X := P1.X * mt_mt + 2 * P2.X * t_mt + P3.X * t_t;
    Point.Y := P1.Y * mt_mt + 2 * P2.Y * t_mt + P3.Y * t_t;

    AddPoint(Point);
  end;

var
  a0: Single;
  a2: Single;
  a2_less_a0: Single;
  Count: integer;
  OneOverCount: Single;
  u0: Single;
  u2: Single;
  u2_less_u0: Single;
  OneOver_u2_less_u0: Single;
  i: integer;
  u: Single;
  t: Single;
begin
  MapToBasic;

  a0 := ApproxMyint(x0);
  a2 := ApproxMyint(x2);
  a2_less_a0 := a2 - a0;

  Count := Ceil(0.5 * Abs(a2_less_a0) * Sqrt(Scale / Tolerance));

  if (Count = 0) then
    exit;

  OneOverCount := 1 / Count;

  u0 := ApproxInvMyint(a0);
  u2 := ApproxInvMyint(a2);
  u2_less_u0 := u2 - u0;
  OneOver_u2_less_u0 := 1 / u2_less_u0;

  Evaluate(0);

  for i := 1 to Count-1 do
  begin
    u := ApproxInvMyint(a0 + ((a2_less_a0) * i) * OneOverCount);
    t := (u - u0) * OneOver_u2_less_u0;
    Evaluate(t);
  end;

  Evaluate(1);
end;

{$if (not defined(RecursiveQuadraticBezierCurve)) and (not defined(RaphLevienQuadraticBezierCurve))}
  {$define RaphLevienQuadraticBezierCurve}
{$ifend}

var
  QuadraticBezierCurve: TQuadraticBezierCurve =
{$if defined(RecursiveQuadraticBezierCurve)}
    RecursiveQuadraticBezierCurve;
{$elseif defined(RaphLevienQuadraticBezierCurve)}
    RaphLevienQuadraticBezierCurve;
{$ifend}


//============================================================================//

{ TCustomPath }

constructor TCustomPath.Create;
begin
  inherited;
  FControlPointOrigin := cpNone;
end;

procedure TCustomPath.AddPoint(const Point: TFloatPoint);
begin
end;

procedure TCustomPath.Arc(const P: TFloatPoint; StartAngle, EndAngle, Radius: TFloat);
begin
  PolyLine(BuildArc(P, StartAngle, EndAngle, Radius));
end;

procedure TCustomPath.AssignTo(Dest: TPersistent);
begin
  if (Dest is TCustomPath) then
  begin
    TCustomPath(Dest).Clear;
    TCustomPath(Dest).FCurrentPoint := FCurrentPoint;
    TCustomPath(Dest).FLastControlPoint := FLastControlPoint;
    TCustomPath(Dest).FControlPointOrigin := FControlPointOrigin;
  end else
    inherited;
end;

procedure TCustomPath.BeginPath;
begin
end;

procedure TCustomPath.Circle(const Cx, Cy, Radius: TFloat; Steps: Integer);
begin
  Polygon(GR32_VectorUtils.Circle(Cx, Cy, Radius, Steps));
end;

procedure TCustomPath.Circle(const Center: TFloatPoint; Radius: TFloat; Steps: Integer);
begin
  Polygon(GR32_VectorUtils.Circle(Center.X, Center.Y, Radius, Steps));
end;

procedure TCustomPath.Clear;
begin
  FControlPointOrigin := cpNone;
end;

procedure TCustomPath.ClosePath;
begin
  EndPath(True);
end;

procedure TCustomPath.ConicTo(const P1, P: TFloatPoint);
begin
  QuadraticBezierCurve(FCurrentPoint, P1, P, AddPoint, QBezierTolerance);
  AddPoint(P);
  FCurrentPoint := P;
  FLastControlPoint := P1;
  FControlPointOrigin := cpConic;
end;

procedure TCustomPath.ConicTo(const X1, Y1, X, Y: TFloat);
begin
  ConicTo(FloatPoint(X1, Y1), FloatPoint(X, Y));
end;

procedure TCustomPath.ConicTo(const X, Y: TFloat);
begin
  ConicTo(FloatPoint(X, Y));
end;

procedure TCustomPath.ConicTo(const P: TFloatPoint);
var
  P1: TFloatPoint;
begin
  if FControlPointOrigin = cpConic then
  begin
    P1.X := FCurrentPoint.X + (FCurrentPoint.X - FLastControlPoint.X);
    P1.Y := FCurrentPoint.Y + (FCurrentPoint.Y - FLastControlPoint.Y);
  end
  else
    P1 := FCurrentPoint;
  ConicTo(P1, P);
end;

procedure TCustomPath.ConicToRelative(const X, Y: TFloat);
begin
  ConicTo(FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.ConicToRelative(const P: TFloatPoint);
begin
  ConicTo(OffsetPoint(P, FCurrentPoint));
end;

procedure TCustomPath.ConicToRelative(const X1, Y1, X, Y: TFloat);
begin
  ConicTo(FloatPoint(FCurrentPoint.X + X1, FCurrentPoint.Y + Y1), FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.ConicToRelative(const P1, P: TFloatPoint);
begin
  ConicTo(OffsetPoint(P1, FCurrentPoint), OffsetPoint(P, FCurrentPoint));
end;

procedure TCustomPath.CurveTo(const C1, C2, P: TFloatPoint);
begin
  CubicBezierCurve(FCurrentPoint, C1, C2, P, AddPoint, CBezierTolerance);
  AddPoint(P);
  FCurrentPoint := P;
  FLastControlPoint := C2;
  FControlPointOrigin := cpCubic;
end;

procedure TCustomPath.CurveTo(const X1, Y1, X2, Y2, X, Y: TFloat);
begin
  CurveTo(FloatPoint(X1, Y1), FloatPoint(X2, Y2), FloatPoint(X, Y));
end;

procedure TCustomPath.CurveTo(const X2, Y2, X, Y: TFloat);
begin
  CurveTo(FloatPoint(X2, Y2), FloatPoint(X, Y));
end;

procedure TCustomPath.CurveTo(const C2, P: TFloatPoint);
var
  C1: TFloatPoint;
begin
  if FControlPointOrigin = cpCubic then
  begin
    C1.X := FCurrentPoint.X - (FLastControlPoint.X - FCurrentPoint.X);
    C1.Y := FCurrentPoint.Y - (FLastControlPoint.Y - FCurrentPoint.Y);
  end
  else
    C1 := FCurrentPoint;
  CurveTo(C1, C2, P);
end;

procedure TCustomPath.CurveToRelative(const X1, Y1, X2, Y2, X, Y: TFloat);
begin
  CurveTo(FloatPoint(FCurrentPoint.X + X1, FCurrentPoint.Y + Y1),
    FloatPoint(FCurrentPoint.X + X2, FCurrentPoint.Y + Y2),
    FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.CurveToRelative(const X2, Y2, X, Y: TFloat);
begin
  CurveTo(FloatPoint(FCurrentPoint.X + X2, FCurrentPoint.Y + Y2), FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.CurveToRelative(const C1, C2, P: TFloatPoint);
begin
  CurveTo(OffsetPoint(C1, FCurrentPoint), OffsetPoint(C2, FCurrentPoint), OffsetPoint(P, FCurrentPoint));
end;

procedure TCustomPath.CurveToRelative(const C2, P: TFloatPoint);
begin
  CurveTo(OffsetPoint(C2, FCurrentPoint), OffsetPoint(P, FCurrentPoint));
end;

procedure TCustomPath.Ellipse(const Cx, Cy, Rx, Ry: TFloat; Steps: Integer);
begin
  Polygon(GR32_VectorUtils.Ellipse(Cx, Cy, Rx, Ry, Steps));
end;

procedure TCustomPath.Ellipse(Rx, Ry: TFloat; Steps: Integer);
begin
  with FCurrentPoint do Ellipse(X, Y, Rx, Ry);
end;

procedure TCustomPath.EndPath(Close: boolean = False);
begin
end;

procedure TCustomPath.LineTo(const P: TFloatPoint);
begin
  AddPoint(P);
  FCurrentPoint := P;
  FControlPointOrigin := cpNone;
end;

procedure TCustomPath.HorizontalLineTo(const X: TFloat);
begin
  LineTo(FloatPoint(X, FCurrentPoint.Y));
end;

procedure TCustomPath.HorizontalLineToRelative(const X: TFloat);
begin
  LineTo(FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y));
end;

procedure TCustomPath.LineTo(const X, Y: TFloat);
begin
  LineTo(FloatPoint(X, Y));
end;

procedure TCustomPath.LineToRelative(const X, Y: TFloat);
begin
  LineTo(FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.LineToRelative(const P: TFloatPoint);
begin
  LineTo(FloatPoint(FCurrentPoint.X + P.X, FCurrentPoint.Y + P.Y));
end;

procedure TCustomPath.MoveTo(const X, Y: TFloat);
begin
  MoveTo(FloatPoint(X, Y));
end;

procedure TCustomPath.MoveToRelative(const X, Y: TFloat);
begin
  MoveTo(FloatPoint(FCurrentPoint.X + X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.MoveToRelative(const P: TFloatPoint);
begin
  MoveTo(FloatPoint(FCurrentPoint.X + P.X, FCurrentPoint.Y + P.Y));
end;

procedure TCustomPath.Rectangle(const Rect: TFloatRect);
begin
  Polygon(GR32_VectorUtils.Rectangle(Rect));
end;

procedure TCustomPath.RoundRect(const Rect: TFloatRect; const Radius: TFloat);
begin
  Polygon(GR32_VectorUtils.RoundRect(Rect, Radius));
end;

procedure TCustomPath.VerticalLineTo(const Y: TFloat);
begin
  LineTo(FloatPoint(FCurrentPoint.X, Y));
end;

procedure TCustomPath.VerticalLineToRelative(const Y: TFloat);
begin
  LineTo(FloatPoint(FCurrentPoint.X, FCurrentPoint.Y + Y));
end;

procedure TCustomPath.Polygon(const APoints: TArrayOfFloatPoint);
begin
  if (Length(APoints) = 0) then
    Exit;

  BeginUpdate;

  MoveTo(APoints[0]); // Implicitly ends any current path

  // Offset=1 because we've already added the first vertex
  PolyLine(APoints, 1);
  EndPath(True);

  EndUpdate;
end;

procedure TCustomPath.PolyPolygon(const APoints: TArrayOfArrayOfFloatPoint);
var
  i: Integer;
begin
  if Length(APoints) = 0 then
    Exit;

  BeginUpdate;

  for i := 0 to High(APoints) do
    Polygon(APoints[i]);

  EndUpdate;
end;

procedure TCustomPath.PolyLine(const APoints: TArrayOfFloatPoint; AOffset: integer);
var
  i: Integer;
begin
  if (AOffset > High(APoints)) then
    Exit;

  BeginUpdate;

  for i := AOffset to High(APoints) do
    LineTo(APoints[i]);

  EndUpdate;
end;

procedure TCustomPath.PolyPolyline(const APoints: TArrayOfArrayOfFloatPoint);
var
  i: Integer;
begin
  if Length(APoints) = 0 then
    Exit;

  BeginUpdate;

  for i := 0 to High(APoints) do
  begin
    if (i > 0) then
      EndPath;
    Polyline(APoints[i]);
  end;

  EndUpdate;
end;

procedure TCustomPath.MoveTo(const P: TFloatPoint);
begin
  FCurrentPoint := P;
  FControlPointOrigin := cpNone;
end;

{ TFlattenedPath }

procedure TFlattenedPath.EndPath(Close: boolean = False);
var
  n: Integer;
begin
  if (FPointIndex = 0) then
    exit;

  if (Close) then
  begin
    AddPoint(FPoints[0]);
    Inc(FClosedCount);
    CurrentPoint := FPoints[0];
  end;

  // Grow path list
  n := Length(FPath);
  SetLength(FPath, n + 1);
  SetLength(FClosed, n + 1);

  // Save vertex buffer in path list
  FPath[n] := Copy(FPoints, 0, FPointIndex);
  FClosed[n] := Close;

  ClearPoints;

  DoEndPath;
end;

procedure TFlattenedPath.Clear;
begin
  inherited;

  // Clear path list
  FPath := nil;
  FClosed := nil;
  FClosedCount := 0;
  // ...and vertex buffer
  ClearPoints;
end;

procedure TFlattenedPath.ClearPoints;
begin
  // Reset vertex counter...
  FPointIndex := 0;
  // ...but try to be clever about buffer size to minimize
  // reallocation and memory waste
  if (Length(FPoints) > VertexBufferSizeLow) then
    SetLength(FPoints, VertexBufferSizeLow);
  // FPoints := nil;
end;

procedure TFlattenedPath.DoBeginPath;
begin
  EndPath; //implicitly finish a prior path

  if (Assigned(FOnBeginPath)) then
    FOnBeginPath(Self);
end;

procedure TFlattenedPath.DoEndPath;
begin
  if (Assigned(FOnEndPath)) then
    FOnEndPath(Self);

  Changed;
end;

procedure TFlattenedPath.MoveTo(const P: TFloatPoint);
begin
  EndPath;

  inherited;

  AddPoint(P);
end;

procedure TFlattenedPath.AddPoint(const Point: TFloatPoint);
var
  p: TFloatPoint;
begin
  if (FPointIndex = 0) then
    DoBeginPath;

  // Work around for Delphi compiler bug.
  // We'll get an AV on the assignment below without it.
  p := Point;

  // Grow buffer if required
  if (FPointIndex > High(FPoints)) then
    SetLength(FPoints, Length(FPoints) + VertexBufferSizeGrow);

  // Add vertex to buffer
  FPoints[FPointIndex] := p;
  Inc(FPointIndex);
end;

procedure TFlattenedPath.AssignTo(Dest: TPersistent);
var
  i: Integer;
begin
  if (Dest is TFlattenedPath) then
  begin
    TFlattenedPath(Dest).BeginUpdate;
    try
      inherited;

      TFlattenedPath(Dest).DoBeginPath;
      SetLength(TFlattenedPath(Dest).FPath, Length(FPath));
      for i := 0 to High(FPath) do
      begin
        SetLength(TFlattenedPath(Dest).FPath[i], Length(FPath[i]));
        Move(FPath[i, 0], TFlattenedPath(Dest).FPath[i, 0], Length(FPath[i]) * SizeOf(TFloatPoint));
      end;
      TFlattenedPath(Dest).FClosed := FClosed;
      TFlattenedPath(Dest).FClosedCount := FClosedCount;
      TFlattenedPath(Dest).DoEndPath;

      TFlattenedPath(Dest).Changed;
    finally
      TFlattenedPath(Dest).EndUpdate;
    end;
  end else
    inherited;
end;

function TFlattenedPath.GetPoints: TArrayOfFloatPoint;
begin
  Result := Copy(FPoints, 0, FPointIndex);
end;



{ TCustomCanvas }

procedure TCustomCanvas.AssignTo(Dest: TPersistent);
begin
  if (Dest is TCustomCanvas) then
  begin
    TCustomCanvas(Dest).BeginUpdate;
    inherited;
    TCustomCanvas(Dest).Transformation := FTransformation;
    TCustomCanvas(Dest).EndUpdate;
  end else
    inherited;
end;

procedure TCustomCanvas.DoChanged;
begin
  inherited;

  DrawPath(Self);
  Clear;
end;

procedure TCustomCanvas.SetTransformation(const Value: TTransformation);
begin
  if FTransformation <> Value then
  begin
    FTransformation := Value;
    Changed;
  end;
end;

{ TCanvas32 }

procedure TCanvas32.AssignTo(Dest: TPersistent);
begin
  if (Dest is TCanvas32) then
  begin
    TCanvas32(Dest).BeginUpdate;
    inherited;
    // DONE : Shouldn't this be .FBitmap.Assign(FBitmap)?
    // No, because TCanvas32 doesn't own the bitmap; It just references it.
    TCanvas32(Dest).FBitmap := FBitmap;

    TCanvas32(Dest).FRenderer.Assign(FRenderer);
    TCanvas32(Dest).FBrushes.Assign(FBrushes);
    TCanvas32(Dest).Changed;
    TCanvas32(Dest).EndUpdate;
  end else
    inherited;
end;

procedure TCanvas32.BrushCollectionChangeHandler(Sender: TObject);
begin
  Changed;
end;

constructor TCanvas32.Create(ABitmap: TBitmap32);
begin
  if (ABitmap = nil) then
    raise Exception.Create('Bitmap parameter required');

  inherited Create;

  FBitmap := ABitmap;
  FRenderer := GetPolygonRendererClass.Create;
  // No need to set Bitmap here. It's done in DrawPath()
  // FRenderer.Bitmap := ABitmap;
  FBrushes := TBrushCollection.Create(Self);
  FBrushes.OnChange := BrushCollectionChangeHandler;
end;

destructor TCanvas32.Destroy;
begin
  FBrushes.Free;
  FRenderer.Free;
  inherited;
end;

procedure TCanvas32.DrawPath(const Path: TFlattenedPath);
var
  ClipRect: TFloatRect;
  i: Integer;
  Closed: boolean;
begin
  if (Length(Path.Path) = 0) then
    exit;

  ClipRect := FloatRect(Bitmap.ClipRect);
  Renderer.Bitmap := Bitmap;

  // Simple case: All paths are closed or all paths are open
  if (Path.ClosedCount = 0) or (Path.ClosedCount = Length(Path.Path)) then
  begin
    Closed := (Path.ClosedCount > 0);
    for i := 0 to FBrushes.Count-1 do
      if FBrushes[i].Visible then
        FBrushes[i].PolyPolygonFS(Renderer, Path.Path, ClipRect, Transformation, Closed);
  end else
  // Not so simple case: Some paths are closed, some are open
  begin
    for i := 0 to FBrushes.Count-1 do
      if FBrushes[i].Visible then
        FBrushes[i].PolyPolygonMixedFS(Renderer, Path.Path, ClipRect, Transformation, Path.PathClosed);
  end;
end;


class function TCanvas32.GetPolygonRendererClass: TPolygonRenderer32Class;
begin
  Result := DefaultPolygonRendererClass;
end;

function TCanvas32.GetRendererClassName: string;
begin
  Result := FRenderer.ClassName;
end;

function TCanvas32.MeasureText(const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout): TFloatRect;
var
  TextToPath: ITextToPathSupport;
  TextToPath2: ITextToPathSupport2;
begin
  if (Supports(Bitmap.Backend, ITextToPathSupport2, TextToPath2)) then
    Result := TextToPath2.MeasureText(DstRect, Text, Layout)
  else
  if (Supports(Bitmap.Backend, ITextToPathSupport, TextToPath)) then
    Result := TextToPath.MeasureText(DstRect, Text, LayoutToTextFlags(Layout))
  else
    raise Exception.Create(RCStrInpropriateBackend);
end;

function TCanvas32.MeasureText(const DstRect: TFloatRect; const Text: string; Flags: Cardinal): TFloatRect;
var
  Layout: TTextLayout;
begin
  Layout := DefaultTextLayout;
  TextFlagsToLayout(Flags, Layout);
  Result := MeasureText(DstRect, Text, Layout);
end;

procedure TCanvas32.RenderText(const DstRect: TFloatRect; const Text: string; const Layout: TTextLayout);
var
  TextToPath: ITextToPathSupport;
  TextToPath2: ITextToPathSupport2;
begin
  if (Supports(Bitmap.Backend, ITextToPathSupport2, TextToPath2)) then
    TextToPath2.TextToPath(Self, DstRect, Text, Layout)
  else
  if (Supports(Bitmap.Backend, ITextToPathSupport, TextToPath)) then
    TextToPath.TextToPath(Self, DstRect, Text, LayoutToTextFlags(Layout))
  else
    raise Exception.Create(RCStrInpropriateBackend);
end;

procedure TCanvas32.RenderText(const DstRect: TFloatRect; const Text: string; Flags: Cardinal);
var
  Layout: TTextLayout;
begin
  Layout := DefaultTextLayout;
  TextFlagsToLayout(Flags, Layout);
  RenderText(DstRect, Text, Layout);
end;

procedure TCanvas32.RenderText(X, Y: TFloat; const Text: string);
begin
  RenderText(X, Y, Text, DefaultTextLayout);
end;

procedure TCanvas32.RenderText(X, Y: TFloat; const Text: string; const Layout: TTextLayout);
var
  TextToPath: ITextToPathSupport;
  TextToPath2: ITextToPathSupport2;
begin
  if (Supports(Bitmap.Backend, ITextToPathSupport2, TextToPath2)) then
    TextToPath2.TextToPath(Self, X, Y, Text, Layout)
  else
  if (Supports(Bitmap.Backend, ITextToPathSupport, TextToPath)) then
    TextToPath.TextToPath(Self, X, Y, Text, LayoutToTextFlags(Layout))
  else
    raise Exception.Create(RCStrInpropriateBackend);
end;

procedure TCanvas32.RenderText(X, Y: TFloat; const Text: string; Flags: Cardinal);
var
  Layout: TTextLayout;
begin
  Layout := DefaultTextLayout;
  TextFlagsToLayout(Flags, Layout);
  RenderText(X, Y, Text, Layout);
end;

procedure TCanvas32.SetRenderer(ARenderer: TPolygonRenderer32);
begin
  if (ARenderer <> nil) and (FRenderer <> ARenderer) then
  begin
    if (FRenderer <> nil) then
      FRenderer.Free;
    FRenderer := ARenderer;
    Changed;
  end;
end;

procedure TCanvas32.SetRendererClassName(const Value: string);
var
  RendererClass: TPolygonRenderer32Class;
begin
  if (Value <> '') and (FRenderer.ClassName <> Value) and (PolygonRendererList <> nil) then
  begin
    RendererClass := PolygonRendererList.Find(Value);
    if (RendererClass <> nil) then
      Renderer := RendererClass.Create;
  end;
end;

end.
