unit GR32_VectorUtils;

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
 * Portions created by the Initial Developer are Copyright (C) 2008-2012
 * the Initial Developer. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$include GR32.inc}

{$BOOLEVAL OFF}

{-$define GR32_OFFSET_CLIPPER}
{-$define GR32_OFFSET_ANGUS}
{-$define GR32_OFFSET_REF}

{$if (not defined(GR32_OFFSET_REF)) and (not defined(GR32_OFFSET_CLIPPER)) and (not defined(GR32_OFFSET_ANGUS))}
  // We need at least one implementation. Fallback to the reference implementation.
  {$define GR32_OFFSET_REF}
{$ifend}

uses
{$if defined(UseInlining)}
  Types,
{$ifend}
  Math,
  GR32,
  GR32_Transforms,
  GR32_Polygons;

const
  DEFAULT_MITER_LIMIT = 4.0;
  DEFAULT_MITER_LIMIT_FIXED = $40000;
  TWOPI = 2 * Pi;

function InSignedRange(const X, X1, X2: TFloat): Boolean; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function InSignedRange(const X, X1, X2: TFixed): Boolean; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Intersect(const A1, A2, B1, B2: TFloatPoint; out P: TFloatPoint): Boolean; overload;
function Intersect(const A1, A2, B1, B2: TFixedPoint; out P: TFixedPoint): Boolean; overload;

function VertexReduction(const Points: TArrayOfFloatPoint; Epsilon: TFloat = 1): TArrayOfFloatPoint; overload;
function VertexReduction(const Points: TArrayOfFixedPoint; Epsilon: TFixed = FixedOne): TArrayOfFixedPoint; overload;

function ClosePolygon(const Points: TArrayOfFloatPoint): TArrayOfFloatPoint; overload;
function ClosePolygon(const Points: TArrayOfFixedPoint): TArrayOfFixedPoint; overload;

function ClipLine(var X1, Y1, X2, Y2: Integer; MinX, MinY, MaxX, MaxY: Integer): Boolean; overload;
function ClipLine(var X1, Y1, X2, Y2: TFloat; MinX, MinY, MaxX, MaxY: TFloat): Boolean; overload;
function ClipLine(var X1, Y1, X2, Y2: TFixed; MinX, MinY, MaxX, MaxY: TFixed): Boolean; overload;
function ClipLine(var P1, P2: TPoint; const ClipRect: TRect): Boolean; overload;
function ClipLine(var P1, P2: TFloatPoint; const ClipRect: TFloatRect): Boolean; overload;
function ClipLine(var P1, P2: TFixedPoint; const ClipRect: TFixedRect): Boolean; overload;

type
  TTriangleVertexIndices = array [0 .. 2] of Integer;
  TArrayOfTriangleVertexIndices = array of TTriangleVertexIndices;

function DelaunayTriangulation(Points: TArrayOfFloatPoint): TArrayOfTriangleVertexIndices;

function BuildNormals(const Points: TArrayOfFloatPoint): TArrayOfFloatPoint; overload;
function BuildNormals(const Points: TArrayOfFixedPoint): TArrayOfFixedPoint; overload;

function Grow(const Points: TArrayOfFloatPoint; const Normals: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfFloatPoint; overload; {$ifndef GR32_OFFSET_REF} deprecated; {$ENDIF} {$IFDEF USEINLINING} inline; {$ENDIF}
function Grow(const Points: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Grow(const Points: TArrayOfFixedPoint; const Normals: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfFixedPoint; overload; {$ifndef GR32_OFFSET_REF} deprecated; {$ENDIF} {$IFDEF USEINLINING} inline; {$ENDIF}
function Grow(const Points: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfFixedPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

function ReversePolygon(const Points: TArrayOfFloatPoint): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function ReversePolygon(const Points: TArrayOfFixedPoint): TArrayOfFixedPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

function BuildPolyLine(const Points: TArrayOfFloatPoint; StrokeWidth: TFloat; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function BuildPolyPolyLine(const Points: TArrayOfArrayOfFloatPoint; Closed: Boolean; StrokeWidth: TFloat; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function BuildPolyLine(const Points: TArrayOfFixedPoint; StrokeWidth: TFixed; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfFixedPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function BuildPolyPolyLine(const Points: TArrayOfArrayOfFixedPoint; Closed: Boolean; StrokeWidth: TFixed; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfArrayOfFixedPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

function BuildDashedLine(const Points: TArrayOfFloatPoint;
  const DashArray: TArrayOfFloat; DashOffset: TFloat = 0;
  Closed: Boolean = False): TArrayOfArrayOfFloatPoint; overload;
function BuildDashedLine(const Points: TArrayOfFixedPoint;
  const DashArray: TArrayOfFixed; DashOffset: TFixed = 0;
  Closed: Boolean = False): TArrayOfArrayOfFixedPoint; overload;

function ClipPolygon(const Points: TArrayOfFloatPoint; const ClipRect: TFloatRect): TArrayOfFloatPoint; overload;
function ClipPolygon(const Points: TArrayOfFixedPoint; const ClipRect: TFixedRect): TArrayOfFixedPoint; overload;

function CalculateCircleSteps(Radius: TFloat): Cardinal; {$IFDEF USEINLINING} inline; {$ENDIF}
function BuildArc(const P: TFloatPoint; StartAngle, EndAngle, Radius: TFloat; Steps: Integer): TArrayOfFloatPoint; overload;
function BuildArc(const P: TFloatPoint; StartAngle, EndAngle, Radius: TFloat): TArrayOfFloatPoint; overload;
function BuildArc(const P: TFixedPoint; StartAngle, EndAngle, Radius: TFloat; Steps: Integer): TArrayOfFixedPoint; overload;
function BuildArc(const P: TFixedPoint; StartAngle, EndAngle, Radius: TFloat): TArrayOfFixedPoint; overload;
function Line(const P1, P2: TFloatPoint): TArrayOfFloatPoint; overload;
function Line(const X1, Y1, X2, Y2: TFloat): TArrayOfFloatPoint; overload;
function VertLine(const X, Y1, Y2: TFloat): TArrayOfFloatPoint;
function HorzLine(const X1, Y, X2: TFloat): TArrayOfFloatPoint;
function Circle(const P: TFloatPoint; const Radius: TFloat; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const P: TFloatPoint; const Radius: TFloat): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const X, Y, Radius: TFloat; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const X, Y, Radius: TFloat): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const R: TRect): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const R: TRect; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const R: TFloatRect): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Circle(const R: TFloatRect; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Pie(const P: TFloatPoint; const Radius: TFloat; const Angle, Offset: TFloat; Steps: Integer): TArrayOfFloatPoint; overload;
function Pie(const P: TFloatPoint; const Radius: TFloat; const Angle: TFloat; const Offset: TFloat = 0): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Pie(const P: TFloatPoint; const Radius: TFloat; const Angle: TFloat; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Pie(const X, Y, Radius: TFloat; const Angle, Offset: TFloat; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Pie(const X, Y, Radius: TFloat; const Angle: TFloat; const Offset: TFloat = 0): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Pie(const X, Y, Radius: TFloat; const Angle: TFloat; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Ellipse(const P, R: TFloatPoint; Steps: Integer): TArrayOfFloatPoint; overload;
function Ellipse(const P, R: TFloatPoint): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Ellipse(const X, Y, Rx, Ry: TFloat; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Ellipse(const X, Y, Rx, Ry: TFloat): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Ellipse(const R: TRect): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Ellipse(const R: TFloatRect): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Ellipse(const R: TRect; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}
function Ellipse(const R: TFloatRect; Steps: Integer): TArrayOfFloatPoint; overload; {$IFDEF INLINING_ENHANCED_RECORDS} inline; {$ENDIF}

function Star(const P: TFloatPoint; const InnerRadius, OuterRadius: TFloat; Vertices: Integer = 5; Rotation: TFloat = 0): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Star(const X, Y, InnerRadius, OuterRadius: TFloat; Vertices: Integer = 5; Rotation: TFloat = 0): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Star(const P: TFloatPoint; const Radius: TFloat; Vertices: Integer = 5; Rotation: TFloat = 0): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Star(const X, Y, Radius: TFloat; Vertices: Integer = 5; Rotation: TFloat = 0): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Rectangle(const R: TRect): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Rectangle(const R: TFloatRect): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function RoundRect(const R: TFloatRect; const Radius: TFloat): TArrayOfFloatPoint; {$IFDEF USEINLINING} inline; {$ENDIF}

function PolygonBounds(const Points: TArrayOfFloatPoint): TFloatRect; overload;
function PolygonBounds(const Points: TArrayOfFixedPoint): TFixedRect; overload;
function PolyPolygonBounds(const Points: TArrayOfArrayOfFloatPoint): TFloatRect; overload;
function PolyPolygonBounds(const Points: TArrayOfArrayOfFixedPoint): TFixedRect; overload;

function ScalePolygon(const Points: TArrayOfFloatPoint; ScaleX, ScaleY: TFloat): TArrayOfFloatPoint; overload;
function ScalePolygon(const Points: TArrayOfFixedPoint; ScaleX, ScaleY: TFixed): TArrayOfFixedPoint; overload;
function ScalePolyPolygon(const Points: TArrayOfArrayOfFloatPoint; ScaleX, ScaleY: TFloat): TArrayOfArrayOfFloatPoint; overload;
function ScalePolyPolygon(const Points: TArrayOfArrayOfFixedPoint; ScaleX, ScaleY: TFixed): TArrayOfArrayOfFixedPoint;  overload;

procedure ScalePolygonInplace(const Points: TArrayOfFloatPoint; ScaleX, ScaleY: TFloat); overload;
procedure ScalePolygonInplace(const Points: TArrayOfFixedPoint; ScaleX, ScaleY: TFixed); overload;
procedure ScalePolyPolygonInplace(const Points: TArrayOfArrayOfFloatPoint; ScaleX, ScaleY: TFloat); overload;
procedure ScalePolyPolygonInplace(const Points: TArrayOfArrayOfFixedPoint; ScaleX, ScaleY: TFixed);  overload;

function TranslatePolygon(const Points: TArrayOfFloatPoint; OffsetX, OffsetY: TFloat): TArrayOfFloatPoint; overload;
function TranslatePolygon(const Points: TArrayOfFixedPoint; Offsetx, OffsetY: TFixed): TArrayOfFixedPoint; overload;
function TranslatePolyPolygon(const Points: TArrayOfArrayOfFloatPoint; OffsetX, OffsetY: TFloat): TArrayOfArrayOfFloatPoint; overload;
function TranslatePolyPolygon(const Points: TArrayOfArrayOfFixedPoint; OffsetX, OffsetY: TFixed): TArrayOfArrayOfFixedPoint; overload;

procedure TranslatePolygonInplace(const Points: TArrayOfFloatPoint; OffsetX, OffsetY: TFloat); overload;
procedure TranslatePolygonInplace(const Points: TArrayOfFixedPoint; Offsetx, OffsetY: TFixed); overload;
procedure TranslatePolyPolygonInplace(const Points: TArrayOfArrayOfFloatPoint; OffsetX, OffsetY: TFloat); overload;
procedure TranslatePolyPolygonInplace(const Points: TArrayOfArrayOfFixedPoint; OffsetX, OffsetY: TFixed); overload;

function TransformPolygon(const Points: TArrayOfFloatPoint; Transformation: TTransformation): TArrayOfFloatPoint; overload;
function TransformPolygon(const Points: TArrayOfFixedPoint; Transformation: TTransformation): TArrayOfFixedPoint; overload;
function TransformPolyPolygon(const Points: TArrayOfArrayOfFloatPoint; Transformation: TTransformation): TArrayOfArrayOfFloatPoint; overload;
function TransformPolyPolygon(const Points: TArrayOfArrayOfFixedPoint; Transformation: TTransformation): TArrayOfArrayOfFixedPoint; overload;

function BuildPolygonF(const Data: array of TFloat): TArrayOfFloatPoint; overload;
function BuildPolygonX(const Data: array of TFixed): TArrayOfFixedPoint; overload;

function PolyPolygon(const Points: TArrayOfFloatPoint): TArrayOfArrayOfFloatPoint; overload; {$IFDEF USEINLINING}inline;{$ENDIF}
function PolyPolygon(const Points: TArrayOfFixedPoint): TArrayOfArrayOfFixedPoint; overload; {$IFDEF USEINLINING}inline;{$ENDIF}

function PointToFloatPoint(const Points: TArrayOfPoint): TArrayOfFloatPoint; overload;
function PointToFloatPoint(const Points: TArrayOfArrayOfPoint): TArrayOfArrayOfFloatPoint; overload;
function PointToFixedPoint(const Points: TArrayOfPoint): TArrayOfFixedPoint; overload;
function PointToFixedPoint(const Points: TArrayOfArrayOfPoint): TArrayOfArrayOfFixedPoint; overload;
function FixedPointToFloatPoint(const Points: TArrayOfFixedPoint): TArrayOfFloatPoint; overload; {$IFDEF USEINLINING}inline;{$ENDIF}
function FixedPointToFloatPoint(const Points: TArrayOfArrayOfFixedPoint): TArrayOfArrayOfFloatPoint; overload; {$IFDEF USEINLINING}inline;{$ENDIF}
function FloatPointToFixedPoint(const Points: TArrayOfFloatPoint): TArrayOfFixedPoint; overload; {$IFDEF USEINLINING}inline;{$ENDIF}
function FloatPointToFixedPoint(const Points: TArrayOfArrayOfFloatPoint): TArrayOfArrayOfFixedPoint; overload; {$IFDEF USEINLINING}inline;{$ENDIF}


//------------------------------------------------------------------------------
//
//      TPolyLineBuilder
//
//------------------------------------------------------------------------------
// Abstract base class for polygon offsetter backends.
// Primarily for internal use.
//------------------------------------------------------------------------------
type
  TPolyLineBuilder = class abstract
  protected
    // Float
    class function Grow(const Points: TArrayOfFloatPoint; const Normals: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfFloatPoint; overload; virtual; abstract;
    // Fixed
    class function Grow(const Points: TArrayOfFixedPoint; const Normals: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfFixedPoint; overload; virtual;
  public
    class function SupportedJoinStyles: TJoinStyles; virtual;
    class function SupportedEndStyles: TEndStyles; virtual;

    // Float
    class function Grow(const Points: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfFloatPoint; overload; virtual;
    // Fixed
    class function Grow(const Points: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle = jsMiter; Closed: Boolean = True; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfFixedPoint; overload; virtual;

    // Float
    class function BuildPolyLine(const Points: TArrayOfFloatPoint; StrokeWidth: TFloat; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfFloatPoint; overload; virtual; abstract;
    class function BuildPolyPolyLine(const Points: TArrayOfArrayOfFloatPoint; Closed: Boolean; StrokeWidth: TFloat; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFloat = DEFAULT_MITER_LIMIT): TArrayOfArrayOfFloatPoint; overload; virtual; abstract;
    // Fixed
    class function BuildPolyLine(const Points: TArrayOfFixedPoint; StrokeWidth: TFixed; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfFixedPoint; overload; virtual;
    class function BuildPolyPolyLine(const Points: TArrayOfArrayOfFixedPoint; Closed: Boolean; StrokeWidth: TFixed; JoinStyle: TJoinStyle = jsMiter; EndStyle: TEndStyle = esButt; MiterLimit: TFixed = DEFAULT_MITER_LIMIT_FIXED): TArrayOfArrayOfFixedPoint; overload; virtual;
  end;

  TPolylineBuilderClass = class of TPolyLineBuilder;

var
  PolylineBuilder: TPolylineBuilderClass;


//------------------------------------------------------------------------------

implementation

uses
{$if defined(GR32_OFFSET_CLIPPER)}
  GR32_VectorUtils.Clipper2,
{$elseif defined(GR32_OFFSET_ANGUS)}
  GR32_VectorUtils.Angus,
{$else}
  GR32_VectorUtils.Reference,
{$ifend}
  GR32_Math,
  GR32_Geometry,
  GR32_LowLevel;

type
  TTransformationAccess = class(TTransformation);

// Returns True if Min(X1, X2) <= X < Max(X1, X2)
function InSignedRange(const X, X1, X2: TFloat): Boolean;
begin
  Result := (X < X1) xor (X < X2);
end;

// Returns True if Min(X1, X2) <= X < Max(X1, X2)
function InSignedRange(const X, X1, X2: TFixed): Boolean;
begin
  Result := (X < X1) xor (X < X2);
end;

// Returns True if the line segments (A1, A2) and (B1, B2) intersects
// P is the point of intersection
function Intersect(const A1, A2, B1, B2: TFloatPoint; out P: TFloatPoint): Boolean;
var
  Adx, Ady, Bdx, Bdy, ABy, ABx: TFloat;
  t, ta, tb: TFloat;
begin
  Result := False;
  Adx := A2.X - A1.X;
  Ady := A2.Y - A1.Y;
  Bdx := B2.X - B1.X;
  Bdy := B2.Y - B1.Y;
  t := (Bdy * Adx) - (Bdx * Ady);

  if t = 0 then Exit; // lines are parallell

  ABx := A1.X - B1.X;
  ABy := A1.Y - B1.Y;
  ta := Bdx * ABy - Bdy * ABx;
  tb := Adx * ABy - Ady * ABx;
  if InSignedRange(ta, 0, t) and InSignedRange(tb, 0, t) then
  begin
    Result := True;
    ta := ta / t;
    P.X := A1.X + ta * Adx;
    P.Y := A1.Y + ta * Ady;
  end;
end;

function Intersect(const A1, A2, B1, B2: TFixedPoint; out P: TFixedPoint): Boolean; overload;
var
  Adx, Ady, Bdx, Bdy, ABy, ABx: TFixed;
  t, ta, tb: TFixed;
begin
  Result := False;
  Adx := A2.X - A1.X;
  Ady := A2.Y - A1.Y;
  Bdx := B2.X - B1.X;
  Bdy := B2.Y - B1.Y;
  t := (Bdy * Adx) - (Bdx * Ady);

  if t = 0 then Exit; // lines are parallell

  ABx := A1.X - B1.X;
  ABy := A1.Y - B1.Y;
  ta := Bdx * ABy - Bdy * ABx;
  tb := Adx * ABy - Ady * ABx;
  if InSignedRange(ta, 0, t) and InSignedRange(tb, 0, t) then
  begin
    Result := True;
    ta := FixedDiv(ta, t);
    P.X := A1.X + ta * Adx;
    P.Y := A1.Y + ta * Ady;
  end;
end;


//------------------------------------------------------------------------------
//
//      RamerDouglasPeucker
//
//------------------------------------------------------------------------------
// Ramer-Douglas-Peucker line simplification.
//
// References:
//
// - Urs Ramer
//   "An iterative procedure for the polygonal approximation of plane curves".
//   Computer Graphics and Image Processing.
//   Volume 1, Issue 3, November 1972, Pages 244-256
//
// - David H. Douglas & Thomas K. Peucker
//   "Algorithms for the reduction of the number of points required to represent
//   a digitized line or its caricature".
//   Cartographica: The International Journal for Geographic Information and
//   Geovisualization. Volume 10 Issue 2, December 1973, Pages 112�122.
//
//------------------------------------------------------------------------------
// This implementation performs the following optimizations, compared to common
// reference implementations:
// - The distance calculations avoids use of Sqrt and Abs by comparing squared
//   values.
// - Static expressions are evaluated outside the loop.
//------------------------------------------------------------------------------
function RamerDouglasPeuckerSquared(const Points: TArrayOfFloatPoint; FirstIndex,
  LastIndex: Integer; EpsilonSquared: TFloat): TArrayOfFloatPoint; overload;
var
  DistX, DistY, DistXY: TFloat;
  Numerator, Denominator: TFloat;
  Index, DeltaMaxIndex: Integer;
  DeltaSquared, DeltaSquaredMax: TFloat;
  Parts: array[0..1] of TArrayOfFloatPoint;
  FirstPoint, LastPoint, p: PFloatPoint;
begin
  FirstPoint := @Points[FirstIndex];
  LastPoint := @Points[LastIndex];

  if LastIndex - FirstIndex <= 1 then
  begin
    SetLength(Result, 2);
    Result[0] := FirstPoint^;
    Result[1] := LastPoint^;
    exit;
  end;

  DistX := LastPoint.X - FirstPoint.X;
  DistY := LastPoint.Y - FirstPoint.Y;
  DistXY := FirstPoint.X * LastPoint.Y - LastPoint.X * FirstPoint.Y;
  Denominator := Sqr(DistX) + Sqr(DistY); // Squared distance
  if (Denominator <> 0.0) then
    Denominator := 1 / Denominator;


  // Find the point with the maximum distance
  DeltaSquaredMax := 0;
  DeltaMaxIndex := 0;
  for Index := FirstIndex + 1 to LastIndex - 1 do
  begin
    p := @Points[Index];
    // Perpendicular distance, squared
    Numerator := DistXY + DistX * p.Y - DistY * p.X;
    DeltaSquared := Denominator * Sqr(Numerator);

    if DeltaSquared >= DeltaSquaredMax then
    begin
      DeltaMaxIndex := Index;
      DeltaSquaredMax := DeltaSquared;
    end;
  end;


  // If max distance is greater than Epsilon, recursively simplify
  if (DeltaSquaredMax >= EpsilonSquared) or (Denominator = 0.0) then
  begin
    // Recurse
    Parts[0] := RamerDouglasPeuckerSquared(Points, FirstIndex, DeltaMaxIndex, EpsilonSquared);
    Parts[1] := RamerDouglasPeuckerSquared(Points, DeltaMaxIndex, LastIndex, EpsilonSquared);

    // Build the result list
    SetLength(Result, Length(Parts[0]) + Length(Parts[1]) - 1);
    Move(Parts[0, 0], Result[0], (Length(Parts[0]) - 1) * SizeOf(TFloatPoint));
    Move(Parts[1, 0], Result[Length(Parts[0]) - 1], Length(Parts[1]) * SizeOf(TFloatPoint));
  end else
  begin
    SetLength(Result, 2);
    Result[0] := FirstPoint^;
    Result[1] := LastPoint^;
  end;
end;

//------------------------------------------------------------------------------

function RamerDouglasPeucker(const Points: TArrayOfFloatPoint; FirstIndex,
  LastIndex: Integer; Epsilon: TFloat): TArrayOfFloatPoint; overload;
begin
  Result := RamerDouglasPeuckerSquared(Points, FirstIndex, LastIndex, Sqr(Epsilon));
end;


//------------------------------------------------------------------------------
//
//      VertexReduction
//
//------------------------------------------------------------------------------
// First do a simple and cheap line simplification and then do a regular
// Ramer-Douglas-Peucker simplification. The first step vastly improves the
// performance of the Ramer-Douglas-Peucker simplification for most cases.
//------------------------------------------------------------------------------
function VertexReduction(const Points: TArrayOfFloatPoint; Epsilon: TFloat): TArrayOfFloatPoint;
var
  Index: Integer;
  Count: integer;
  SqrEpsilon: TFloat;
begin
  if (Length(Points) = 0) then
    Exit(nil);

  // Initial line simplification; Ignore points closer than Epsilon to each other
  SqrEpsilon := Sqr(Epsilon);
  SetLength(Result, Length(Points)); // Make room for all points to avoid reallocation
  Result[0] := Points[0];
  Count := 1;
  Index := 1;
  while Index < Length(Points) do
  begin
    if SqrDistance(Result[Count-1], Points[Index]) > SqrEpsilon then
    begin
      Result[Count] := Points[Index];
      Inc(Count);
    end;
    Inc(Index);
  end;

  // Ramer-Douglas-Peucker line simplification
  if Count > 2 then
    Result := RamerDouglasPeuckerSquared(Result, 0, Count-1, SqrEpsilon)
  else
    SetLength(Result, Count); // Trim to actually used size
end;

//------------------------------------------------------------------------------

function VertexReduction(const Points: TArrayOfFixedPoint; Epsilon: TFixed): TArrayOfFixedPoint;
begin
  if (Length(Points) = 0) then
    Exit(nil);

  // Use float points; A fixed points version of RamerDouglasPeucker is unfortunately
  // not possible due to integer overflows.
  Result := FloatPointToFixedPoint(VertexReduction(FixedPointToFloatPoint(Points), Epsilon*FixedToFloat));
end;

//------------------------------------------------------------------------------

function ClosePolygon(const Points: TArrayOfFloatPoint): TArrayOfFloatPoint;
var
  L: Integer;
  P1, P2: TFloatPoint;
begin
  L := Length(Points);
  Result := Points;
  if L <= 1 then
    Exit;

  P1 := Result[0];
  P2 := Result[L - 1];
  if (P1.X = P2.X) and (P1.Y = P2.Y) then
    Exit;

  SetLength(Result, L + 1);
  Move(Result[0], Points[0], L * SizeOf(TFloatPoint));
  Result[L] := P1;
end;

function ClosePolygon(const Points: TArrayOfFixedPoint): TArrayOfFixedPoint;
var
  L: Integer;
  P1, P2: TFixedPoint;
begin
  L := Length(Points);
  Result := Points;
  if L <= 1 then
    Exit;

  P1 := Result[0];
  P2 := Result[L - 1];
  if (P1.X = P2.X) and (P1.Y = P2.Y) then
    Exit;

  SetLength(Result, L + 1);
  Move(Result[0], Points[0], L * SizeOf(TFixedPoint));
  Result[L] := P1;
end;

// Note:
// ClipLine has been copied to GR32 to avoid referencing this unit there since that would
// prevent inlining here of GR32 functions due to
// H2456 Inline function '%s' has not been expanded because contained unit '%s' uses compiling unit '%s'
// Make sure to keep the two functions in sync!
function ClipLine(var X1, Y1, X2, Y2: Integer; MinX, MinY, MaxX, MaxY: Integer): Boolean;
var
  C1, C2: Integer;
  V: Integer;
begin
  { Get edge codes }
  C1 := Ord(X1 < MinX) + Ord(X1 > MaxX) shl 1 + Ord(Y1 < MinY) shl 2 + Ord(Y1 > MaxY) shl 3;
  C2 := Ord(X2 < MinX) + Ord(X2 > MaxX) shl 1 + Ord(Y2 < MinY) shl 2 + Ord(Y2 > MaxY) shl 3;

  if ((C1 and C2) = 0) and ((C1 or C2) <> 0) then
  begin
    if (C1 and 12) <> 0 then
    begin
      if C1 < 8 then V := MinY else V := MaxY;
      Inc(X1, MulDiv(V - Y1, X2 - X1, Y2 - Y1));
      Y1 := V;
      C1 := Ord(X1 < MinX) + Ord(X1 > MaxX) shl 1;
    end;

    if (C2 and 12) <> 0 then
    begin
      if C2 < 8 then V := MinY else V := MaxY;
      Inc(X2, MulDiv(V - Y2, X2 - X1, Y2 - Y1));
      Y2 := V;
      C2 := Ord(X2 < MinX) + Ord(X2 > MaxX) shl 1;
    end;

    if ((C1 and C2) = 0) and ((C1 or C2) <> 0) then
    begin
      if C1 <> 0 then
      begin
        if C1 = 1 then V := MinX else V := MaxX;
        Inc(Y1, MulDiv(V - X1, Y2 - Y1, X2 - X1));
        X1 := V;
        C1 := 0;
      end;

      if C2 <> 0 then
      begin
        if C2 = 1 then V := MinX else V := MaxX;
        Inc(Y2, MulDiv(V - X2, Y2 - Y1, X2 - X1));
        X2 := V;
        C2 := 0;
      end;
    end;
  end;

  Result := (C1 or C2) = 0;
end;

function ClipLine(var X1, Y1, X2, Y2: TFloat; MinX, MinY, MaxX, MaxY: TFloat): Boolean;
var
  C1, C2: Integer;
  V: TFloat;
begin
  { Get edge codes }
  C1 := Ord(X1 < MinX) + Ord(X1 > MaxX) shl 1 + Ord(Y1 < MinY) shl 2 + Ord(Y1 > MaxY) shl 3;
  C2 := Ord(X2 < MinX) + Ord(X2 > MaxX) shl 1 + Ord(Y2 < MinY) shl 2 + Ord(Y2 > MaxY) shl 3;

  if ((C1 and C2) = 0) and ((C1 or C2) <> 0) then
  begin
    if (C1 and 12) <> 0 then
    begin
      if C1 < 8 then V := MinY else V := MaxY;
      X1 := X1 + (V - Y1) * (X2 - X1) / (Y2 - Y1);
      Y1 := V;
      C1 := Ord(X1 < MinX) + Ord(X1 > MaxX) shl 1;
    end;

    if (C2 and 12) <> 0 then
    begin
      if C2 < 8 then V := MinY else V := MaxY;
      X2 := X2 + (V - Y2) * (X2 - X1) / (Y2 - Y1);
      Y2 := V;
      C2 := Ord(X2 < MinX) + Ord(X2 > MaxX) shl 1;
    end;

    if ((C1 and C2) = 0) and ((C1 or C2) <> 0) then
    begin
      if C1 <> 0 then
      begin
        if C1 = 1 then V := MinX else V := MaxX;
        Y1 := Y1 + (V - X1) * (Y2 - Y1) / (X2 - X1);
        X1 := V;
        C1 := 0;
      end;

      if C2 <> 0 then
      begin
        if C2 = 1 then V := MinX else V := MaxX;
        Y2 := Y2 + (V - X2) * (Y2 - Y1) / (X2 - X1);
        X2 := V;
        C2 := 0;
      end;
    end;
  end;

  Result := (C1 or C2) = 0;
end;

function ClipLine(var X1, Y1, X2, Y2: TFixed; MinX, MinY, MaxX, MaxY: TFixed): Boolean;
var
  C1, C2: Integer;
  V: TFixed;
begin
  { Get edge codes }
  C1 := Ord(X1 < MinX) + Ord(X1 > MaxX) shl 1 + Ord(Y1 < MinY) shl 2 + Ord(Y1 > MaxY) shl 3;
  C2 := Ord(X2 < MinX) + Ord(X2 > MaxX) shl 1 + Ord(Y2 < MinY) shl 2 + Ord(Y2 > MaxY) shl 3;

  if ((C1 and C2) = 0) and ((C1 or C2) <> 0) then
  begin
    if (C1 and 12) <> 0 then
    begin
      if C1 < 8 then V := MinY else V := MaxY;
      X1 := X1 + FixedDiv(FixedMul(V - Y1, X2 - X1), Y2 - Y1);
      Y1 := V;
      C1 := Ord(X1 < MinX) + Ord(X1 > MaxX) shl 1;
    end;

    if (C2 and 12) <> 0 then
    begin
      if C2 < 8 then V := MinY else V := MaxY;
      X2 := X2 + FixedDiv(FixedMul(V - Y2, X2 - X1), Y2 - Y1);
      Y2 := V;
      C2 := Ord(X2 < MinX) + Ord(X2 > MaxX) shl 1;
    end;

    if ((C1 and C2) = 0) and ((C1 or C2) <> 0) then
    begin
      if C1 <> 0 then
      begin
        if C1 = 1 then V := MinX else V := MaxX;
        Y1 := Y1 + FixedDiv(FixedMul(V - X1, Y2 - Y1), X2 - X1);
        X1 := V;
        C1 := 0;
      end;

      if C2 <> 0 then
      begin
        if C2 = 1 then V := MinX else V := MaxX;
        Y2 := Y2 + FixedDiv(FixedMul(V - X2, Y2 - Y1), X2 - X1);
        X2 := V;
        C2 := 0;
      end;
    end;
  end;

  Result := (C1 or C2) = 0;
end;

function ClipLine(var P1, P2: TPoint; const ClipRect: TRect): Boolean;
begin
  Result := ClipLine(P1.X, P1.Y, P2.X, P2.Y, ClipRect.Left, ClipRect.Top,
    ClipRect.Right, ClipRect.Bottom);
end;

function ClipLine(var P1, P2: TFloatPoint; const ClipRect: TFloatRect): Boolean;
begin
  Result := ClipLine(P1.X, P1.Y, P2.X, P2.Y, ClipRect.Left, ClipRect.Top,
    ClipRect.Right, ClipRect.Bottom);
end;

function ClipLine(var P1, P2: TFixedPoint; const ClipRect: TFixedRect): Boolean;
begin
  Result := ClipLine(P1.X, P1.Y, P2.X, P2.Y, ClipRect.Left, ClipRect.Top,
    ClipRect.Right, ClipRect.Bottom);
end;

procedure FastMergeSortX(const Values: TArrayOfFloatPoint;
  out Indexes: TArrayOfInteger; out Bounds: TFloatRect);
var
  Temp: TArrayOfInteger;

  procedure Merge(I1, I2, J1, J2: Integer);
  var
    I, J, K: Integer;
  begin
    if Values[Indexes[I2]].X < Values[Indexes[J1]].X then Exit;
    I := I1;
    J := J1;
    K := 0;
    repeat
      if Values[Indexes[I]].X < Values[Indexes[J]].X then
      begin
        Temp[K] := Indexes[I];
        Inc(I);
      end
      else
      begin
        Temp[K] := Indexes[J];
        Inc(J);
      end;
      Inc(K);
    until (I > I2) or (J > J2);

    while I <= I2 do
    begin
      Temp[K] := Indexes[I];
      Inc(I); Inc(K);
    end;
    while J <= J2 do
    begin
      Temp[K] := Indexes[J];
      Inc(J); Inc(K);
    end;
    for I := 0 to K - 1 do
    begin
      Indexes[I + I1] := Temp[I];
    end;
  end;

  procedure Recurse(I1, I2: Integer);
  var
    I, IX: Integer;
  begin
    if I1 = I2 then
      Indexes[I1] := I1
    else if Indexes[I1] = Indexes[I2] then
    begin
      if Values[I1].X <= Values[I2].X then
      begin
        for I := I1 to I2 do Indexes[I] := I;
      end
      else
      begin
        IX := I1 + I2;
        for I := I1 to I2 do Indexes[I] := IX - I;
      end;
    end
    else
    begin
      IX := (I1 + I2) div 2;
      Recurse(I1, IX);
      Recurse(IX + 1, I2);
      Merge(I1, IX, IX + 1, I2);
    end;
  end;

var
  I, Index, S: Integer;
begin
  SetLength(Temp, Length(Values));
  SetLength(Indexes, Length(Values));

  Index := 0;
  S := Math.Sign(Values[1].X - Values[0].X);
  if S = 0 then S := 1;

  Indexes[0] := 0;
  Bounds.Left := Values[0].X;
  Bounds.Top := Values[0].Y;
  Bounds.Right := Bounds.Left;
  Bounds.Bottom := Bounds.Top;
  for I := 1 to High(Values) do
  begin
    if Math.Sign(Values[I].X - Values[I - 1].X) = -S then
    begin
      S := -S;
      Inc(Index);
    end;

    if Values[I].X < Bounds.Left then
      Bounds.Left := Values[I].X;
    if Values[I].Y < Bounds.Top then
      Bounds.Top := Values[I].Y;
    if Values[I].X > Bounds.Right then
      Bounds.Right := Values[I].X;
    if Values[I].Y > Bounds.Bottom then
      Bounds.Bottom := Values[I].Y;

    Indexes[I] := Index;
  end;

  Recurse(0, High(Values));
end;

// Delaunay Triangulation
// Based on Paul Bourke's implementation of the Bowyer-Watson algorithm.
// References:
//   http://paulbourke.net/papers/triangulate/
//   https://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm
// Note: GR32_ColorGradients contains a custom version of this function. Keep both in sync.
function DelaunayTriangulation(Points: TArrayOfFloatPoint): TArrayOfTriangleVertexIndices;
var
  Complete: array of Byte;
  Edges: array of array [0 .. 1] of Integer;
  ByteIndex, Bit: Byte;
  MaxVerticesCount, EdgeCount, MaxEdgeCount, MaxTriangleCount: Integer;

  // For super triangle
  ScaledDeltaMax: TFloat;
  Mid: TFloatPoint;
  Bounds: TFloatRect;

  // General Variables
  SortedVertexIndices: TArrayOfInteger;
  TriangleCount, VertexCount, I, J, K: Integer;
  CenterX, CenterY, RadSqr: TFloat;
  Inside: Boolean;
const
  CSuperTriangleCount = 3; // -> super triangle
  CTolerance = 0.000001;

  function InCircle(Pt, Pt1, Pt2, Pt3: TFloatPoint): Boolean;
  // Return TRUE if the point Pt(x, y) lies inside the circumcircle made up by
  // points Pt1(x, y) Pt2(x, y) Pt3(x, y)
  // The circumcircle centre is returned in (CenterX, CenterY) and the radius r
  // NOTE: A point on the edge is inside the circumcircle
  var
    M1, M2, MX1, MY1, MX2, MY2: Double;
    DeltaX, DeltaY, DeltaRadSqr, AbsY1Y2, AbsY2Y3: Double;
  begin
    AbsY1Y2 := Abs(Pt1.Y - Pt2.Y);
    AbsY2Y3 := Abs(Pt2.Y - Pt3.Y);

    // Check for coincident points
    if (AbsY1Y2 < CTolerance) and (AbsY2Y3 < CTolerance) then
    begin
      Result := False;
      Exit;
    end;

    if AbsY1Y2 < CTolerance then
    begin
      M2 := -(Pt3.X - Pt2.X) / (Pt3.Y - Pt2.Y);
      MX2 := (Pt2.X + Pt3.X) * 0.5;
      MY2 := (Pt2.Y + Pt3.Y) * 0.5;
      CenterX := (Pt2.X + Pt1.X) * 0.5;
      CenterY := M2 * (CenterX - MX2) + MY2;
    end
    else if AbsY2Y3 < CTolerance then
    begin
      M1 := -(Pt2.X - Pt1.X) / (Pt2.Y - Pt1.Y);
      MX1 := (Pt1.X + Pt2.X) * 0.5;
      MY1 := (Pt1.Y + Pt2.Y) * 0.5;
      CenterX := (Pt3.X + Pt2.X) * 0.5;
      CenterY := M1 * (CenterX - MX1) + MY1;
    end
    else
    begin
      M1 := -(Pt2.X - Pt1.X) / (Pt2.Y - Pt1.Y);
      M2 := -(Pt3.X - Pt2.X) / (Pt3.Y - Pt2.Y);
      if Abs(M1 - M2) < CTolerance then
      begin
        Result := False;
        Exit;
      end;
      MX1 := (Pt1.X + Pt2.X) * 0.5;
      MX2 := (Pt2.X + Pt3.X) * 0.5;
      MY1 := (Pt1.Y + Pt2.Y) * 0.5;
      MY2 := (Pt2.Y + Pt3.Y) * 0.5;

      CenterX := (M1 * MX1 - M2 * Mx2 + My2 - MY1) / (M1 - M2);
      if (AbsY1Y2 > AbsY2Y3) then
        CenterY := M1 * (CenterX - MX1) + MY1
      else
        CenterY := M2 * (CenterX - MX2) + MY2;
    end;

    DeltaX := Pt2.X - CenterX;
    DeltaY := Pt2.Y - CenterY;
    RadSqr := DeltaX * DeltaX + DeltaY * DeltaY;
    DeltaX := Pt.X - CenterX;
    DeltaY := Pt.Y - CenterY;
    DeltaRadSqr := Sqr(DeltaX) + Sqr(DeltaY);

    Result := (DeltaRadSqr - RadSqr) <= CTolerance;
  end;

begin
  VertexCount := Length(Points);
  MaxVerticesCount := VertexCount + CSuperTriangleCount;

  // Sort points by x value and find maximum and minimum vertex bounds.
  FastMergeSortX(Points, SortedVertexIndices, Bounds);

  // set dynamic array sizes
  SetLength(Points, MaxVerticesCount);
  MaxTriangleCount := 2 * (MaxVerticesCount - 1);
  SetLength(Result, MaxTriangleCount);
  MaxEdgeCount := 3 * (MaxVerticesCount - 1);
  SetLength(Edges, MaxEdgeCount);
  SetLength(Complete, (MaxTriangleCount + 7) shr 3);

  // This is to allow calculation of the bounding triangle
  with Bounds do
  begin
    ScaledDeltaMax := 30 * Max(Right - Left, Bottom - Top);
    Mid := FloatPoint((Left + Right) * 0.5, (Top + Bottom) * 0.5);
  end;

  // Set up the super triangle
  // This is a triangle which encompasses all the sample points. The super
  // triangle coordinates are added to the end of the vertex list. The super
  // triangle is the first triangle in the triangle list.
  Points[VertexCount] := FloatPoint(Mid.X - ScaledDeltaMax, Mid.Y - ScaledDeltaMax);
  Points[VertexCount + 1] := FloatPoint(Mid.X + ScaledDeltaMax, Mid.Y);
  Points[VertexCount + 2] := FloatPoint(Mid.X, Mid.Y + ScaledDeltaMax);

  Result[0, 0] := VertexCount;
  Result[0, 1] := VertexCount + 1;
  Result[0, 2] := VertexCount + 2;

  Complete[0] := 0;
  TriangleCount := 1;

  // Include each point one at a time into the existing mesh
  for I := 0 to VertexCount - 1 do
  begin
    EdgeCount := 0;

    // Set up the edge buffer.
    // If the point [x, y] lies inside the circumcircle then the hree edges of
    // that triangle are added to the edge buffer.
    J := 0;
    repeat
      if Complete[J shr 3] and (1 shl (J and $7)) = 0 then
      begin
        Inside := InCircle(Points[SortedVertexIndices[I]],
          Points[Result[J, 0]], Points[Result[J, 1]], Points[Result[J, 2]]);

        ByteIndex := J shr 3;
        Bit := 1 shl (J and $7);
        if (CenterX < Points[SortedVertexIndices[I]].X) and
          ((Sqr(Points[SortedVertexIndices[I]].X - CenterX)) > RadSqr) then
          Complete[ByteIndex] := Complete[ByteIndex] or Bit
        else
          if Inside then
          begin
            Edges[EdgeCount + 0, 0] := Result[J, 0];
            Edges[EdgeCount + 0, 1] := Result[J, 1];
            Edges[EdgeCount + 1, 0] := Result[J, 1];
            Edges[EdgeCount + 1, 1] := Result[J, 2];
            Edges[EdgeCount + 2, 0] := Result[J, 2];
            Edges[EdgeCount + 2, 1] := Result[J, 0];
            EdgeCount := EdgeCount + 3;
            Assert(EdgeCount <= MaxEdgeCount);

            TriangleCount := TriangleCount - 1;
            Result[J] := Result[TriangleCount];

            Complete[ByteIndex] := (Complete[ByteIndex] and (not Bit))
              or (Complete[TriangleCount shr 3] and Bit);
            Continue;
          end;
      end;
      J := J + 1;
    until J >= TriangleCount;

    // Tag multiple edges
    // Note: if all triangles are specified anticlockwise then all
    // interior edges are opposite pointing in direction.
    for J := 0 to EdgeCount - 2 do
    begin
      if (Edges[J, 0] <> -1) or (Edges[J, 1] <> -1) then
      begin
        for K := J + 1 to EdgeCount - 1 do
        begin
          if (Edges[K, 0] <> -1) or (Edges[K, 1] <> -1) then
          begin
            if (Edges[J, 0] = Edges[K, 1]) and
              (Edges[J, 1] = Edges[K, 0]) then
            begin
              Edges[J, 0] := -1;
              Edges[J, 1] := -1;
              Edges[K, 1] := -1;
              Edges[K, 0] := -1;
            end;
          end;
        end;
      end;
    end;

    // Form new triangles for the current point.
    // Skipping over any tagged edges. All edges are arranged in clockwise
    // order.
    for J := 0 to EdgeCount - 1 do
    begin
      if (Edges[J, 0] <> -1) or (Edges[J, 1] <> -1) then
      begin
        Result[TriangleCount, 0] := Edges[J, 0];
        Result[TriangleCount, 1] := Edges[J, 1];
        Result[TriangleCount, 2] := SortedVertexIndices[I];
        ByteIndex := TriangleCount shr 3;
        Bit := 1 shl (TriangleCount and $7);
        Complete[ByteIndex] := Complete[ByteIndex] and not Bit;
        Inc(TriangleCount);
        Assert(TriangleCount <= MaxTriangleCount);
      end;
    end;
  end;

  // Remove triangles with supertriangle vertices
  // These are triangles which have a vertex number greater than VertexCount
  I := 0;
  repeat
    if (Result[I, 0] >= VertexCount) or
      (Result[I, 1] >= VertexCount) or
      (Result[I, 2] >= VertexCount) then
    begin
      TriangleCount := TriangleCount - 1;
      Result[I, 0] := Result[TriangleCount, 0];
      Result[I, 1] := Result[TriangleCount, 1];
      Result[I, 2] := Result[TriangleCount, 2];
      I := I - 1;
    end;
    I := I + 1;
  until I >= TriangleCount;

  SetLength(Points, Length(Points) - 3);
  SetLength(Result, TriangleCount);
end;

function BuildArc(const P: TFloatPoint; StartAngle, EndAngle, Radius: TFloat;
  Steps: Integer): TArrayOfFloatPoint;
var
  I: Integer;
  C, D: TFloatPoint;
begin
  SetLength(Result, Steps);
  SinCos(StartAngle, Radius, C.Y, C.X);
  Result[0] := OffsetPoint(P, C);

  GR32_Math.SinCos((EndAngle - StartAngle) / (Steps - 1), D.Y, D.X);
  for I := 1 to Steps - 1 do
  begin
    C := FloatPoint(C.X * D.X - C.Y * D.Y, C.Y * D.X + C.X * D.Y);
    Result[I] := OffsetPoint(P, C);
  end;
end;

function BuildArc(const P: TFloatPoint; StartAngle, EndAngle, Radius: TFloat): TArrayOfFloatPoint;
const
  MINSTEPS = 6;
  SQUAREDMINSTEPS = Sqr(MINSTEPS);
var
  Temp: TFloat;
  Steps: Integer;
begin
  // The code below was previously:
  //
  // Steps := Max(MINSTEPS, System.Round(Sqrt(Abs(Radius)) *
  //   Abs(EndAngle - StartAngle)));
  //
  // However, for small radii, the square root calculation is performed with
  // the result that the output is set to 6 anyway. In this case (only a few
  // drawing operations), the performance spend for this calculation is dominant
  // for large radii (when a lot of CPU intensive drawing takes place), the
  // more expensive float point comparison (Temp < SQUAREDMINSTEPS) is not very
  // significant

  Temp := Abs(Radius) * Sqr(EndAngle - StartAngle);
  if Temp < SQUAREDMINSTEPS then
    Steps := 6
  else
    Steps := Round(Sqrt(Temp));
  Result := BuildArc(P, StartAngle, EndAngle, Radius, Steps);
end;

function BuildArc(const P: TFixedPoint; StartAngle, EndAngle, Radius: TFloat;
  Steps: Integer): TArrayOfFixedPoint;
var
  I: Integer;
  C, D: TFloatPoint;
begin
  SetLength(Result, Steps);
  SinCos(StartAngle, Radius, C.Y, C.X);
  Result[0] := OffsetPoint(P, C);

  GR32_Math.SinCos((EndAngle - StartAngle) / (Steps - 1), D.Y, D.X);
  for I := 1 to Steps - 1 do
  begin
    C := FloatPoint(C.X * D.X - C.Y * D.Y, C.Y * D.X + C.X * D.Y);
    Result[I] := OffsetPoint(P, FixedPoint(C));
  end;
end;

function BuildArc(const P: TFixedPoint; StartAngle, EndAngle, Radius: TFloat): TArrayOfFixedPoint;
const
  MINSTEPS = 6;
  SQUAREDMINSTEPS = Sqr(MINSTEPS);
var
  Temp: TFloat;
  Steps: Integer;
begin
  // The code below was previously:
  //
  // Steps := Clamp(System.Round(Sqrt(Abs(Radius)) *
  //   Abs(EndAngle - StartAngle)), MINSTEPS, $100000);
  //
  // However, for small radii, the square root calculation is performed with
  // the result that the output is set to 6 anyway. In this case (only a few
  // drawing operations), the performance spend for this calculation is dominant
  // for large radii (when a lot of CPU intensive drawing takes place), the
  // more expensive float point comparison (Temp < SQUAREDMINSTEPS) is not very
  // significant

  Temp := Abs(Radius) * Sqr(EndAngle - StartAngle);
  if Temp < SQUAREDMINSTEPS then
    Steps := MINSTEPS
  else
    Steps := Clamp(Round(Sqrt(Temp)), $100000);
  Result := BuildArc(P, StartAngle, EndAngle, Radius, Steps);
end;

function Line(const P1, P2: TFloatPoint): TArrayOfFloatPoint;
begin
  SetLength(Result, 2);
  Result[0] := P1;
  Result[1] := P2;
end;

function Line(const X1, Y1, X2, Y2: TFloat): TArrayOfFloatPoint; overload;
begin
  SetLength(Result, 2);
  Result[0] := FloatPoint(X1, Y1);
  Result[1] := FloatPoint(X2, Y2);
end;

function VertLine(const X, Y1, Y2: TFloat): TArrayOfFloatPoint;
begin
  SetLength(Result, 2);
  Result[0] := FloatPoint(X, Y1);
  Result[1] := FloatPoint(X, Y2);
end;

function HorzLine(const X1, Y, X2: TFloat): TArrayOfFloatPoint;
begin
  SetLength(Result, 2);
  Result[0] := FloatPoint(X1, Y);
  Result[1] := FloatPoint(X2, Y);
end;

function CalculateCircleSteps(Radius: TFloat): Cardinal;
var
  AbsRadius: TFloat;
begin
  AbsRadius := Abs(Radius);
  Result := Max(2, Trunc(Pi / (ArcCos(AbsRadius / (AbsRadius + 0.125)))));
end;

function Circle(const P: TFloatPoint; const Radius: TFloat;
  Steps: Integer): TArrayOfFloatPoint;
var
  I: Integer;
  M: TFloat;
  C, D: TFloatPoint;
begin
  if Steps <= 1 then
    Steps := CalculateCircleSteps(Radius);

  SetLength(Result, Steps);
  M := 2 * System.Pi / Steps;

  // first item
  Result[0].X := Radius + P.X;
  Result[0].Y := P.Y;

  // calculate complex offset
  GR32_Math.SinCos(M, C.Y, C.X);
  D.X := Radius * C.X;
  D.Y := Radius * C.Y;

  // second item
  Result[1].X := D.X + P.X;
  Result[1].Y := D.Y + P.Y;

  // other items
  for I := 2 to Steps - 1 do
  begin
    D := FloatPoint(D.X * C.X - D.Y * C.Y, D.Y * C.X + D.X * C.Y);

    Result[I].X := D.X + P.X;
    Result[I].Y := D.Y + P.Y;
  end;
end;

function Circle(const P: TFloatPoint; const Radius: TFloat): TArrayOfFloatPoint;
begin
  Result := Circle(P, Radius, CalculateCircleSteps(Radius));
end;

function Circle(const X, Y, Radius: TFloat; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Circle(FloatPoint(X, Y), Radius, Steps);
end;

function Circle(const X, Y, Radius: TFloat): TArrayOfFloatPoint;
begin
  Result := Circle(FloatPoint(X, Y), Radius, CalculateCircleSteps(Radius));
end;

function Circle(const R: TRect): TArrayOfFloatPoint;
begin
  Result := Circle(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    Min(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)));
end;

function Circle(const R: TRect; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Circle(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    Min(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)), Steps);
end;

function Circle(const R: TFloatRect): TArrayOfFloatPoint;
begin
  Result := Circle(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    Min(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)));
end;

function Circle(const R: TFloatRect; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Circle(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    Min(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)), Steps);
end;

function Pie(const P: TFloatPoint; const Radius: TFloat;
  const Angle, Offset: TFloat; Steps: Integer): TArrayOfFloatPoint;
var
  I: Integer;
  C, D: TFloatPoint;
begin
  SetLength(Result, Steps + 2);

  Result[0] := P;

  // calculate initial position
  GR32_Math.SinCos(Offset, Radius, D.Y, D.X);
  Result[1].X := D.X + P.X;
  Result[1].Y := D.Y + P.Y;

  // calculate complex offset
  GR32_Math.SinCos(Angle / Steps, C.Y, C.X);

  // other items
  for I := 2 to Steps + 1 do
  begin
    D := FloatPoint(D.X * C.X - D.Y * C.Y, D.Y * C.X + D.X * C.Y);

    Result[I].X := D.X + P.X;
    Result[I].Y := D.Y + P.Y;
  end;
end;

function Pie(const P: TFloatPoint; const Radius: TFloat;
  const Angle: TFloat; const Offset: TFloat = 0): TArrayOfFloatPoint;
begin
  Result := Pie(P, Radius, Angle, Offset, CalculateCircleSteps(Radius));
end;

function Pie(const P: TFloatPoint; const Radius: TFloat;
  const Angle: TFloat; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Pie(P, Radius, Angle, 0, Steps);
end;

function Pie(const X, Y, Radius: TFloat; const Angle: TFloat;
  const Offset: TFloat = 0): TArrayOfFloatPoint;
begin
  Result := Pie(FloatPoint(X, Y), Radius, Angle, Offset, CalculateCircleSteps(Radius));
end;

function Pie(const X, Y, Radius: TFloat; const Angle, Offset: TFloat;
  Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Pie(FloatPoint(X, Y), Radius, Angle, Offset, Steps);
end;

function Pie(const X, Y, Radius: TFloat; const Angle: TFloat;
  Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Pie(FloatPoint(X, Y), Radius, Angle, 0, Steps);
end;

function Ellipse(const P, R: TFloatPoint; Steps: Integer): TArrayOfFloatPoint;
var
  I: Integer;
  M: TFloat;
  C, D: TFloatPoint;
begin
  SetLength(Result, Steps);
  M := 2 * System.Pi / Steps;

  // first item
  Result[0].X := R.X + P.X;
  Result[0].Y := P.Y;

  // calculate complex offset
  GR32_Math.SinCos(M, C.Y, C.X);
  D := C;

  // second item
  Result[1].X := R.X * D.X + P.X;
  Result[1].Y := R.Y * D.Y + P.Y;

  // other items
  for I := 2 to Steps - 1 do
  begin
    D := FloatPoint(D.X * C.X - D.Y * C.Y, D.Y * C.X + D.X * C.Y);

    Result[I].X := R.X * D.X + P.X;
    Result[I].Y := R.Y * D.Y + P.Y;
  end;
end;

function Ellipse(const P, R: TFloatPoint): TArrayOfFloatPoint;
begin
  Result := Ellipse(P, R, CalculateCircleSteps(Min(R.X, R.Y)));
end;

function Ellipse(const X, Y, Rx, Ry: TFloat; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Ellipse(FloatPoint(X, Y), FloatPoint(Rx, Ry), Steps);
end;

function Ellipse(const X, Y, Rx, Ry: TFloat): TArrayOfFloatPoint;
begin
  Result := Ellipse(FloatPoint(X, Y), FloatPoint(Rx, Ry),
    CalculateCircleSteps(Min(Rx, Ry)));
end;

function Ellipse(const R: TRect): TArrayOfFloatPoint;
begin
  Result := Ellipse(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    FloatPoint(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)));
end;

function Ellipse(const R: TFloatRect): TArrayOfFloatPoint;
begin
  Result := Ellipse(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    FloatPoint(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)));
end;

function Ellipse(const R: TRect; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Ellipse(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    FloatPoint(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)), Steps);
end;

function Ellipse(const R: TFloatRect; Steps: Integer): TArrayOfFloatPoint;
begin
  Result := Ellipse(
    FloatPoint(0.5 * (R.Right + R.Left), 0.5 * (R.Bottom + R.Top)),
    FloatPoint(0.5 * (R.Right - R.Left), 0.5 * (R.Bottom - R.Top)), Steps);
end;

function Star(const X, Y, Radius: TFloat; Vertices: Integer = 5;
  Rotation: TFloat = 0): TArrayOfFloatPoint;
var
  Alpha, Ratio: TFloat;
begin
  Alpha := Pi * (Vertices - 2 * ((Vertices - 1) shr 1)) / Vertices;
  Ratio := Sin(Alpha * 0.5) / Sin( Alpha * 0.5 + Pi / Vertices);
  Result := Star(X, Y, Ratio * Radius, Radius, Vertices, Rotation);
end;

function Star(const P: TFloatPoint; const Radius: TFloat; Vertices: Integer = 5;
  Rotation: TFloat = 0): TArrayOfFloatPoint;
var
  Alpha, Ratio: TFloat;
begin
  Alpha := Pi * (Vertices - 2 * ((Vertices - 1) shr 1)) / Vertices;
  Ratio := Sin(Alpha * 0.5) / Sin(Alpha * 0.5 + Pi / Vertices);
  Result := Star(P, Ratio * Radius, Radius, Vertices, Rotation);
end;

function Star(const X, Y, InnerRadius, OuterRadius: TFloat;
  Vertices: Integer = 5; Rotation: TFloat = 0): TArrayOfFloatPoint;
begin
  Result := Star(FloatPoint(X, Y), InnerRadius, OuterRadius, Vertices, Rotation);
end;

function Star(const P: TFloatPoint; const InnerRadius, OuterRadius: TFloat;
  Vertices: Integer = 5; Rotation: TFloat = 0): TArrayOfFloatPoint;
var
  I: Integer;
  M: TFloat;
  C, D: TFloatPoint;
begin
  SetLength(Result, 2 * Vertices);
  M := System.Pi / Vertices;

  // calculate complex offset
  GR32_Math.SinCos(M, C.Y, C.X);

  // first item
  if Rotation = 0 then
  begin
    Result[0].X := OuterRadius + P.X;
    Result[0].Y := P.Y;
    D := C;
  end
  else
  begin
    GR32_Math.SinCos(Rotation, D.Y, D.X);
    Result[0].X := OuterRadius * D.X + P.X;
    Result[0].Y := OuterRadius * D.Y + P.Y;
    D := FloatPoint(D.X * C.X - D.Y * C.Y, D.Y * C.X + D.X * C.Y);
  end;

  // second item
  Result[1].X := InnerRadius * D.X + P.X;
  Result[1].Y := InnerRadius * D.Y + P.Y;

  // other items
  for I := 2 to (2 * Vertices) - 1 do
  begin
    D := FloatPoint(D.X * C.X - D.Y * C.Y, D.Y * C.X + D.X * C.Y);

    if I mod 2 = 0 then
    begin
      Result[I].X := OuterRadius * D.X + P.X;
      Result[I].Y := OuterRadius * D.Y + P.Y;
    end
    else
    begin
      Result[I].X := InnerRadius * D.X + P.X;
      Result[I].Y := InnerRadius * D.Y + P.Y;
    end;
  end;
end;

function Rectangle(const R: TRect): TArrayOfFloatPoint;
begin
  SetLength(Result, 4);
  Result[0] := FloatPoint(R.TopLeft);
  Result[1] := FloatPoint(R.Right, R.Top);
  Result[2] := FloatPoint(R.BottomRight);
  Result[3] := FloatPoint(R.Left, R.Bottom);
end;

function Rectangle(const R: TFloatRect): TArrayOfFloatPoint;
begin
  SetLength(Result, 4);
  Result[0] := R.TopLeft;
  Result[1] := FloatPoint(R.Right, R.Top);
  Result[2] := R.BottomRight;
  Result[3] := FloatPoint(R.Left, R.Bottom);
end;

function RoundRect(const R: TFloatRect; const Radius: TFloat): TArrayOfFloatPoint;
var
  R2: TFloatRect;
  CornerRadius: TFloat;
begin
  // Constrain radius to half width & height
  CornerRadius := Min(Radius, Min(R.Width / 2, R.Height / 2));

  R2 := R;
  // Shrink box and then...
  GR32.InflateRect(R2, -CornerRadius, -CornerRadius);
  // ...Grow it with rounded corners
  Result := Grow(Rectangle(R2), CornerRadius, jsRound, True);
end;

function BuildNormals(const Points: TArrayOfFloatPoint): TArrayOfFloatPoint;
const
  EPSILON = 1E-4;
var
  I, Count, NextI: Integer;
  dx, dy, f: Double;
begin
  Count := Length(Points);
  SetLength(Result, Count);

  I := 0;
  NextI := 1;

  while I < Count do
  begin
    if NextI >= Count then NextI := 0;

    dx := Points[NextI].X - Points[I].X;
    dy := Points[NextI].Y - Points[I].Y;
    f := GR32_Math.Hypot(dx, dy);
    if (f > EPSILON) then
    begin
      f := 1 / f;
      dx := dx * f;
      dy := dy * f;
    end;
    Result[I].X := dy;

    Result[I].Y := -dx;

    Inc(I);
    Inc(NextI);
  end;
end;

function BuildNormals(const Points: TArrayOfFixedPoint): TArrayOfFixedPoint;
var
  I, Count, NextI: Integer;
  dx, dy, f: TFixed;
begin
  Count := Length(Points);
  SetLength(Result, Count);

  I := 0;
  NextI := 1;

  while I < Count do
  begin
    if NextI >= Count then NextI := 0;

    dx := Points[NextI].X - Points[I].X;
    dy := Points[NextI].Y - Points[I].Y;
    f := GR32_Math.Hypot(dx, dy);
    if (f <> 0) then
    begin
      dx := FixedDiv(dx, f);
      dy := FixedDiv(dy, f);
    end;

    Result[I].X := dy;
    Result[I].Y := -dx;

    Inc(I);
    Inc(NextI);
  end;
end;

// Converts an array of points in TFixed format to an array of points in TFloat format
function FixedPointToFloatPoint(const Points: TArrayOfFixedPoint): TArrayOfFloatPoint;
var
  Index: Integer;
begin
  SetLength(Result, Length(Points));
  for Index := 0 to Length(Points) - 1 do
  begin
    Result[Index].X := Points[Index].X * FixedToFloat;
    Result[Index].Y := Points[Index].Y * FixedToFloat;
  end;
end;

// Converts an array of array of points in TFixed format to an array of array of points in TFloat format
function FixedPointToFloatPoint(const Points: TArrayOfArrayOfFixedPoint): TArrayOfArrayOfFloatPoint;
var
  Index, PointIndex: Integer;
begin
  SetLength(Result, Length(Points));
  for Index := 0 to Length(Points) - 1 do
  begin
    SetLength(Result[Index], Length(Points[Index]));
    for PointIndex := 0 to Length(Points[Index]) - 1 do
    begin
      Result[Index, PointIndex].X := Points[Index, PointIndex].X * FixedToFloat;
      Result[Index, PointIndex].Y := Points[Index, PointIndex].Y * FixedToFloat;
    end;
  end;
end;

// Converts an array of points in TFixed format to an array of points in TFloat format
function FloatPointToFixedPoint(const Points: TArrayOfFloatPoint): TArrayOfFixedPoint;
var
  Index: Integer;
begin
  SetLength(Result, Length(Points));
  for Index := 0 to Length(Points) - 1 do
  begin
    Result[Index].X := Fixed(Points[Index].X);
    Result[Index].Y := Fixed(Points[Index].Y);
  end;
end;

// Converts an array of array of points in TFixed format to an array of array of points in TFloat format
function FloatPointToFixedPoint(const Points: TArrayOfArrayOfFloatPoint): TArrayOfArrayOfFixedPoint;
var
  Index, PointIndex: Integer;
begin
  SetLength(Result, Length(Points));
  for Index := 0 to Length(Points) - 1 do
  begin
    SetLength(Result[Index], Length(Points[Index]));
    for PointIndex := 0 to Length(Points[Index]) - 1 do
    begin
      Result[Index, PointIndex].X := Fixed(Points[Index, PointIndex].X);
      Result[Index, PointIndex].Y := Fixed(Points[Index, PointIndex].Y);
    end;
  end;
end;

function ReversePolygon(const Points: TArrayOfFloatPoint): TArrayOfFloatPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  Dec(L);
  for I := 0 to L do
    Result[I] := Points[L - I];
end;

function ReversePolygon(const Points: TArrayOfFixedPoint): TArrayOfFixedPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  Dec(L);
  for I := 0 to L do
    Result[I] := Points[L - I];
end;

function BuildDashedLine(const Points: TArrayOfFloatPoint;
  const DashArray: TArrayOfFloat; DashOffset: TFloat = 0;
  Closed: Boolean = False): TArrayOfArrayOfFloatPoint;
const
  EPSILON = 1E-4;
var
  I, J, DashIndex, len1, len2: Integer;
  Offset, Dist, v: TFloat;
  Delta: TFloatPoint;

  procedure AddPoint(X, Y: TFloat);
  var
    K: Integer;
  begin
    K := Length(Result[J]);
    SetLength(Result[J], K + 1);
    Result[J][K].X := X;
    Result[J][K].Y := Y;
  end;

  procedure AddDash(I: Integer);
  begin
    if i = 0 then
    begin
      Delta.X := Points[0].X - Points[High(Points)].X;
      Delta.Y := Points[0].Y - Points[High(Points)].Y;
    end else
    begin
      Delta.X := Points[I].X - Points[I - 1].X;
      Delta.Y := Points[I].Y - Points[I - 1].Y;
    end;
    Dist := GR32_Math.Hypot(Delta.X, Delta.Y);
    Offset := Offset + Dist;
    if (Dist > EPSILON) then
    begin
      Dist := 1 / Dist;
      Delta.X := Delta.X * Dist;
      Delta.Y := Delta.Y * Dist;
    end;
    while Offset > DashOffset do
    begin
      v := Offset - DashOffset;
      AddPoint(Points[I].X - v * Delta.X, Points[I].Y - v * Delta.Y);
      DashIndex := (DashIndex + 1) mod Length(DashArray);
      DashOffset := DashOffset + DashArray[DashIndex];
      if Odd(DashIndex) then
      begin
        Inc(J);
        SetLength(Result, J + 1);
      end;
    end;
    if not Odd(DashIndex) then
      AddPoint(Points[I].X, Points[I].Y);
  end;

begin
  Result := nil;

  if (Length(Points) = 0) then
    Exit;

  if (Length(DashArray) = 0) then
  begin
    Setlength(Result, 1);
    Result[0] := Points;
    Exit;
  end;

  DashIndex := -1;
  Offset := 0;

  V := 0;
  for I := 0 to High(DashArray) do
    V := V + DashArray[I];
  DashOffset := Wrap(DashOffset, V);

  DashOffset := DashOffset - V;
  while (DashOffset < 0) and (DashIndex < High(DashArray)) do
  begin
    Inc(DashIndex);
    DashOffset := DashOffset + DashArray[DashIndex];
  end;

  J := 0;
  // note to self: second dimension might not be zero by default!
  SetLength(Result, 1, 0);

  if not Odd(DashIndex) then
    AddPoint(Points[0].X, Points[0].Y);
  for I := 1 to High(Points) do
    AddDash(I);

  if Closed then
  begin
    AddDash(0);
    len1 := Length(Result[0]);
    len2 := Length(Result[J]);
    // Only merge if the first and last points are contributing on a dash
    {$IFNDEF FPC}
      if (len1 > 0) and (len2 > 0) and (Result[0][0] = Result[J][len2 - 1]) then
    {$ELSE}
      if (len1 > 0) and (len2 > 0) and (Result[0][0].X = Result[J][len2 - 1].X) and (Result[0][0].Y = Result[J][len2 - 1].Y) then
    {$ENDIF}
    begin
      SetLength(Result[0], len1 + len2 -1);
      Move(Result[0][0], Result[0][len2 - 1], SizeOf(TFloatPoint) * len1);
      Move(Result[J][0], Result[0][0], SizeOf(TFloatPoint) * len2);
      SetLength(Result, J);
      Dec(J);
    end;
  end;

  if (J >= 0) and (Length(Result[J]) = 0) then
    SetLength(Result, J);
end;

function BuildDashedLine(const Points: TArrayOfFixedPoint;
  const DashArray: TArrayOfFixed; DashOffset: TFixed = 0;
  Closed: Boolean = False): TArrayOfArrayOfFixedPoint;
var
  I, J, DashIndex, Len1, Len2: Integer;
  Offset, Dist, v: TFixed;
  Delta: TFixedPoint;

  procedure AddPoint(X, Y: TFixed);
  var
    K: Integer;
  begin
    K := Length(Result[J]);
    SetLength(Result[J], K + 1);
    Result[J][K].X := X;
    Result[J][K].Y := Y;
  end;

  procedure AddDash(I: Integer);
  begin
    if i = 0 then
    begin
      Delta.X := Points[0].X - Points[High(Points)].X;
      Delta.Y := Points[0].Y - Points[High(Points)].Y;
    end else
    begin
      Delta.X := Points[I].X - Points[I - 1].X;
      Delta.Y := Points[I].Y - Points[I - 1].Y;
    end;
    Dist := GR32_Math.Hypot(Delta.X, Delta.Y);
    Offset := Offset + Dist;
    if (Dist > 0) then
    begin
      Delta.X := FixedDiv(Delta.X, Dist);
      Delta.Y := FixedDiv(Delta.Y, Dist);
    end;
    while Offset > DashOffset do
    begin
      v := Offset - DashOffset;
      AddPoint(Points[I].X - FixedMul(v, Delta.X), Points[I].Y - FixedMul(v,
        Delta.Y));
      DashIndex := (DashIndex + 1) mod Length(DashArray);
      DashOffset := DashOffset + DashArray[DashIndex];
      if Odd(DashIndex) then
      begin
        Inc(J);
        SetLength(Result, J + 1);
      end;
    end;
    if not Odd(DashIndex) then
      AddPoint(Points[I].X, Points[I].Y);
  end;

begin
  Result := nil;

  if (Length(Points) = 0) then
    Exit;

  if (Length(DashArray) = 0) then
  begin
    Setlength(Result, 1);
    Result[0] := Points;
    Exit;
  end;

  DashIndex := -1;
  Offset := 0;

  V := 0;
  for I := 0 to High(DashArray) do
    V := V + DashArray[I];
  DashOffset := Wrap(DashOffset, V);

  DashOffset := DashOffset - V;
  while DashOffset < 0 do
  begin
    Inc(DashIndex);
    DashOffset := DashOffset + DashArray[DashIndex];
  end;

  J := 0;
  // note to self: second dimension might not be zero by default!
  SetLength(Result, 1, 0);

  if not Odd(DashIndex) then
    AddPoint(Points[0].X, Points[0].Y);
  for I := 1 to High(Points) do
    AddDash(I);

  if Closed then
  begin
    AddDash(0);
    Len1 := Length(Result[0]);
    Len2 := Length(Result[J]);
    if (Len1 > 0) and (Len2 > 0) then
    begin
      SetLength(Result[0], len1 + len2 -1);
      Move(Result[0][0], Result[0][len2 - 1], SizeOf(TFixedPoint) * Len1);
      Move(Result[J][0], Result[0][0], SizeOf(TFixedPoint) * Len2);
      SetLength(Result, J);
      Dec(J);
    end;
  end;

  if (J >= 0) and (Length(Result[J]) = 0) then SetLength(Result, J);
end;

function InterpolateX(X: TFloat; const P1, P2: TFloatPoint): TFloatPoint; overload;
var
  W: Double;
begin
  W := (X - P1.X) / (P2.X - P1.X);
  Result.X := X;
  Result.Y := P1.Y + W * (P2.Y - P1.Y);
end;

function InterpolateY(Y: TFloat; const P1, P2: TFloatPoint): TFloatPoint; overload;
var
  W: Double;
begin
  W := (Y - P1.Y) / (P2.Y - P1.Y);
  Result.Y := Y;
  Result.X := P1.X + W * (P2.X - P1.X);
end;

function GetCode(const P: TFloatPoint; const R: TFloatRect): Integer; overload; {$IFDEF USEINLINING}inline;{$ENDIF}
begin
  Result := Ord(P.X >= R.Left) or
    (Ord(P.X <= R.Right) shl 1) or
    (Ord(P.Y >= R.Top) shl 2) or
    (Ord(P.Y <= R.Bottom) shl 3);
end;

function ClipPolygon(const Points: TArrayOfFloatPoint; const ClipRect: TFloatRect): TArrayOfFloatPoint;
type
  TInterpolateProc = function(X: TFloat; const P1, P2: TFloatPoint): TFloatPoint;
const
  SAFEOVERSIZE = 5;
  POPCOUNT: array [0..15] of Integer =
    (0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4);
var
  I, J, K, L, N: Integer;
  X, Y, Z, Code, Count: Integer;
  Codes: PByteArray;
  NextIndex: PIntegerArray;
  Temp: PFloatPointArray;
label
  ExitProc;

  procedure AddPoint(Index: Integer; const P: TFloatPoint);
  begin
    Temp[K] := P;
    Codes[K] := GetCode(P, ClipRect);
    Inc(K);
    Inc(Count);
  end;

  function ClipEdges(Mask: Integer; V: TFloat; Interpolate: TInterpolateProc): Boolean;
  var
    I, NextI, StopIndex: Integer;
  begin
    I := 0;
    while (I < K) and (Codes[I] and Mask = 0) do Inc(I);

    Result := I = K;
    if Result then { all points outside }
    begin
      ClipPolygon := nil;
      Result := True;
      Exit;
    end;

    StopIndex := I;
    repeat
      NextI := NextIndex[I];

      if Codes[NextI] and Mask = 0 then  { inside -> outside }
      begin
        NextIndex[I] := K;
        NextIndex[K] := K + 1;
        AddPoint(I, Interpolate(V, Temp[I], Temp[NextI]));

        while Codes[NextI] and Mask = 0 do
        begin
          Dec(Count);
          Codes[NextI] := 0;
          I := NextI;
          NextI := NextIndex[I];
        end;
        { outside -> inside }
        NextIndex[I] := K;
        NextIndex[K] := NextI;
        AddPoint(I, Interpolate(V, Temp[I], Temp[NextI]));
      end;

      I := NextI;
    until I = StopIndex;
  end;

begin
  N := Length(Points);
{$IFDEF USESTACKALLOC}
  Codes := StackAlloc(N * SAFEOVERSIZE * SizeOf(Byte));
{$ELSE}
  GetMem(Codes, N * SAFEOVERSIZE * SizeOf(Byte));
{$ENDIF}
  X := 15;
  Y := 0;
  for I := 0 to N - 1 do
  begin
    Code := GetCode(Points[I], ClipRect);
    Codes[I] := Code;
    X := X and Code;
    Y := Y or Code;
  end;
  if X = 15 then { all points inside }
  begin
    Result := Points;
  end
  else if Y <> 15 then { all points outside }
  begin
    Result := nil;
  end
  else
  begin
    Count := N;
    Z := Codes[N - 1];
    for I := 0 to N - 1 do
    begin
      Code := Codes[I];
      Inc(Count, POPCOUNT[Z xor Code]);
      Z := Code;
    end;
{$IFDEF USESTACKALLOC}
    Temp := StackAlloc(Count * SizeOf(TFloatPoint));
    NextIndex := StackAlloc(Count * SizeOf(TFloatPoint));
{$ELSE}
    GetMem(Temp, Count * SizeOf(TFloatPoint));
    GetMem(NextIndex, Count * SizeOf(TFloatPoint));
{$ENDIF}

    Move(Points[0], Temp[0], N * SizeOf(TFloatPoint));
    for I := 0 to N - 2 do NextIndex[I] := I + 1;
    NextIndex[N - 1] := 0;

    Count := N;
    K := N;
    if X and 1 = 0 then if ClipEdges(1, ClipRect.Left, InterpolateX) then goto ExitProc;
    if X and 2 = 0 then if ClipEdges(2, ClipRect.Right, InterpolateX) then goto ExitProc;
    if X and 4 = 0 then if ClipEdges(4, ClipRect.Top, InterpolateY) then goto ExitProc;
    if X and 8 = 0 then if ClipEdges(8, ClipRect.Bottom, InterpolateY) then goto ExitProc;

    SetLength(Result, Count);

    { start with first point inside the clipping rectangle }
    I := 0;
    while Codes[I] = 0 do
      I := NextIndex[I];

    J := I;
    L := 0;
    repeat
      Result[L] := Temp[I];
      Inc(L);
      I := NextIndex[I];
    until I = J;

ExitProc:
{$IFDEF USESTACKALLOC}
    StackFree(NextIndex);
    StackFree(Temp);
{$ELSE}
    FreeMem(NextIndex);
    FreeMem(Temp);
{$ENDIF}
  end;
{$IFDEF USESTACKALLOC}
  StackFree(Codes);
{$ELSE}
  FreeMem(Codes);
{$ENDIF}
end;

function InterpolateX(X: TFixed; const P1, P2: TFixedPoint): TFixedPoint; overload;
var
  W: TFixed;
begin
  W := FixedDiv(X - P1.X, P2.X - P1.X);
  Result.X := X;
  Result.Y := P1.Y + FixedMul(W, P2.Y - P1.Y);
end;

function InterpolateY(Y: TFixed; const P1, P2: TFixedPoint): TFixedPoint; overload;
var
  W: TFixed;
begin
  W := FixedDiv(Y - P1.Y, P2.Y - P1.Y);
  Result.Y := Y;
  Result.X := P1.X + FixedMul(W, P2.X - P1.X);
end;

function GetCode(const P: TFixedPoint; const R: TFixedRect): Integer; overload; {$IFDEF USEINLINING}inline;{$ENDIF}
begin
  Result := Ord(P.X >= R.Left) or
    (Ord(P.X <= R.Right) shl 1) or
    (Ord(P.Y >= R.Top) shl 2) or
    (Ord(P.Y <= R.Bottom) shl 3);
end;

function ClipPolygon(const Points: TArrayOfFixedPoint; const ClipRect: TFixedRect): TArrayOfFixedPoint;
type
  TInterpolateProc = function(X: TFixed; const P1, P2: TFixedPoint): TFixedPoint;
const
  SAFEOVERSIZE = 5;
  POPCOUNT: array [0..15] of Integer =
    (0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4);
var
  I, J, K, L, N: Integer;
  X, Y, Z, Code, Count: Integer;
  Codes: PByteArray;
  NextIndex: PIntegerArray;
  Temp: PFixedPointArray;
label
  ExitProc;

  procedure AddPoint(Index: Integer; const P: TFixedPoint);
  begin
    Temp[K] := P;
    Codes[K] := GetCode(P, ClipRect);
    Inc(K);
    Inc(Count);
  end;

  function ClipEdges(Mask: Integer; V: TFixed; Interpolate: TInterpolateProc): Boolean;
  var
    I, NextI, StopIndex: Integer;
  begin
    I := 0;
    while (I < K) and (Codes[I] and Mask = 0) do Inc(I);

    Result := I = K;
    if Result then { all points outside }
    begin
      ClipPolygon := nil;
      Result := True;
      Exit;
    end;

    StopIndex := I;
    repeat
      NextI := NextIndex[I];

      if Codes[NextI] and Mask = 0 then  { inside -> outside }
      begin
        NextIndex[I] := K;
        NextIndex[K] := K + 1;
        AddPoint(I, Interpolate(V, Temp[I], Temp[NextI]));

        while Codes[NextI] and Mask = 0 do
        begin
          Dec(Count);
          Codes[NextI] := 0;
          I := NextI;
          NextI := NextIndex[I];
        end;
        { outside -> inside }
        NextIndex[I] := K;
        NextIndex[K] := NextI;
        AddPoint(I, Interpolate(V, Temp[I], Temp[NextI]));
      end;

      I := NextI;
    until I = StopIndex;
  end;

begin
  N := Length(Points);
{$IFDEF USESTACKALLOC}
  Codes := StackAlloc(N * SAFEOVERSIZE * SizeOf(Byte));
{$ELSE}
  GetMem(Codes, N * SAFEOVERSIZE * SizeOf(Byte));
{$ENDIF}
  X := 15;
  Y := 0;
  for I := 0 to N - 1 do
  begin
    Code := GetCode(Points[I], ClipRect);
    Codes[I] := Code;
    X := X and Code;
    Y := Y or Code;
  end;
  if X = 15 then { all points inside }
  begin
    Result := Points;
  end
  else if Y <> 15 then { all points outside }
  begin
    Result := nil;
  end
  else
  begin
    Count := N;
    Z := Codes[N - 1];
    for I := 0 to N - 1 do
    begin
      Code := Codes[I];
      Inc(Count, POPCOUNT[Z xor Code]);
      Z := Code;
    end;
{$IFDEF USESTACKALLOC}
    Temp := StackAlloc(Count * SizeOf(TFixedPoint));
    NextIndex := StackAlloc(Count * SizeOf(TFixedPoint));
{$ELSE}
    GetMem(Temp, Count * SizeOf(TFixedPoint));
    GetMem(NextIndex, Count * SizeOf(TFixedPoint));
{$ENDIF}

    Move(Points[0], Temp[0], N * SizeOf(TFixedPoint));
    for I := 0 to N - 2 do NextIndex[I] := I + 1;
    NextIndex[N - 1] := 0;

    Count := N;
    K := N;
    if X and 1 = 0 then if ClipEdges(1, ClipRect.Left, InterpolateX) then goto ExitProc;
    if X and 2 = 0 then if ClipEdges(2, ClipRect.Right, InterpolateX) then goto ExitProc;
    if X and 4 = 0 then if ClipEdges(4, ClipRect.Top, InterpolateY) then goto ExitProc;
    if X and 8 = 0 then if ClipEdges(8, ClipRect.Bottom, InterpolateY) then goto ExitProc;

    SetLength(Result, Count);

    { start with first point inside the clipping rectangle }
    I := 0;
    while Codes[I] = 0 do
      I := NextIndex[I];

    J := I;
    L := 0;
    repeat
      Result[L] := Temp[I];
      Inc(L);
      I := NextIndex[I];
    until I = J;

ExitProc:
{$IFDEF USESTACKALLOC}
    StackFree(NextIndex);
    StackFree(Temp);
{$ELSE}
    FreeMem(NextIndex);
    FreeMem(Temp);
{$ENDIF}
  end;
{$IFDEF USESTACKALLOC}
  StackFree(Codes);
{$ELSE}
  FreeMem(Codes);
{$ENDIF}
end;

function PolygonBounds(const Points: TArrayOfFloatPoint): TFloatRect;
var
  I: Integer;
begin
  if (Length(Points) = 0) then
    Exit(Default(TFloatRect));

  Result.Left := Points[0].X;
  Result.Top := Points[0].Y;
  Result.Right := Points[0].X;
  Result.Bottom := Points[0].Y;
  for I := 1 to High(Points) do
  begin
    Result.Left := Min(Result.Left, Points[I].X);
    Result.Right := Max(Result.Right, Points[I].X);
    Result.Top := Min(Result.Top, Points[I].Y);
    Result.Bottom := Max(Result.Bottom, Points[I].Y);
  end;
end;

function PolygonBounds(const Points: TArrayOfFixedPoint): TFixedRect;
var
  I: Integer;
begin
  if (Length(Points) = 0) then
    Exit(Default(TFixedRect));

  Result.Left := Points[0].X;
  Result.Top := Points[0].Y;
  Result.Right := Points[0].X;
  Result.Bottom := Points[0].Y;
  for I := 1 to High(Points) do
  begin
    Result.Left := Min(Result.Left, Points[I].X);
    Result.Right := Max(Result.Right, Points[I].X);
    Result.Top := Min(Result.Top, Points[I].Y);
    Result.Bottom := Max(Result.Bottom, Points[I].Y);
  end;
end;

function PolyPolygonBounds(const Points: TArrayOfArrayOfFloatPoint): TFloatRect;
var
  i: Integer;
  R: TFloatRect;
  AnyValid: boolean;
begin
  if (Length(Points) = 0) then
    Exit(Default(TFloatRect));

  AnyValid := False;

  for i := 0 to High(Points) do
  begin
    if (Length(Points[i]) = 0) then
      continue;

    if (not AnyValid) then
    begin
      Result := PolygonBounds(Points[i]);
      AnyValid := True;
    end else
    begin
      R := PolygonBounds(Points[i]);
      if (Result.Left > R.Left) then
        Result.Left := R.Left;
      if (Result.Right < R.Right) then
        Result.Right := R.Right;
      if (Result.Top >  R.Top) then
        Result.Top := R.Top;
      if (Result.Bottom < R.Bottom) then
        Result.Bottom := R.Bottom;
    end;
  end;

  if (not AnyValid) then
    Exit(Default(TFloatRect));
end;

function PolyPolygonBounds(const Points: TArrayOfArrayOfFixedPoint): TFixedRect;
var
  i: Integer;
  R: TFixedRect;
  AnyValid: boolean;
begin
  if (Length(Points) = 0) then
    Exit(Default(TFixedRect));

  AnyValid := False;

  for i := 0 to High(Points) do
  begin
    if (Length(Points[i]) = 0) then
      continue;

    if (not AnyValid) then
    begin
      Result := PolygonBounds(Points[i]);
      AnyValid := True;
    end else
    begin
      R := PolygonBounds(Points[i]);
      if (Result.Left > R.Left) then
        Result.Left := R.Left;
      if (Result.Right < R.Right) then
        Result.Right := R.Right;
      if (Result.Top >  R.Top) then
        Result.Top := R.Top;
      if (Result.Bottom < R.Bottom) then
        Result.Bottom := R.Bottom;
    end;
  end;

  if (not AnyValid) then
    Exit(Default(TFixedRect));
end;


// Scales to a polygon (TArrayOfFloatPoint)
function ScalePolygon(const Points: TArrayOfFloatPoint; ScaleX, ScaleY: TFloat): TArrayOfFloatPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  for I := 0 to L - 1 do
  begin
    Result[I].X := Points[I].X * ScaleX;
    Result[I].Y := Points[I].Y * ScaleY;
  end;
end;

// Scales to a polygon (TArrayOfFixedPoint)
function ScalePolygon(const Points: TArrayOfFixedPoint; ScaleX, ScaleY: TFixed): TArrayOfFixedPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  for I := 0 to L - 1 do
  begin
    Result[I].X := FixedMul(Points[I].X, ScaleX);
    Result[I].Y := FixedMul(Points[I].Y, ScaleY);
  end;
end;

// Scales all sub polygons in a complex polygon (TArrayOfArrayOfFloatPoint)
function ScalePolyPolygon(const Points: TArrayOfArrayOfFloatPoint;
  ScaleX, ScaleY: TFloat): TArrayOfArrayOfFloatPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    Result[I] := ScalePolygon(Points[I], ScaleX, ScaleY);
end;

// Scales all sub polygons in a complex polygon (TArrayOfArrayOfFixedPoint)
function ScalePolyPolygon(const Points: TArrayOfArrayOfFixedPoint;
  ScaleX, ScaleY: TFixed): TArrayOfArrayOfFixedPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    Result[I] := ScalePolygon(Points[I], ScaleX, ScaleY);
end;

// Scales a polygon (TArrayOfFloatPoint)
procedure ScalePolygonInplace(const Points: TArrayOfFloatPoint; ScaleX, ScaleY: TFloat);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
  begin
    Points[I].X := Points[I].X * ScaleX;
    Points[I].Y := Points[I].Y * ScaleY;
  end;
end;

// Scales a polygon (TArrayOfFixedPoint)
procedure ScalePolygonInplace(const Points: TArrayOfFixedPoint; ScaleX, ScaleY: TFixed);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
  begin
    Points[I].X := FixedMul(Points[I].X, ScaleX);
    Points[I].Y := FixedMul(Points[I].Y, ScaleY);
  end;
end;

// Scales all sub polygons in a complex polygon (TArrayOfArrayOfFloatPoint)
procedure ScalePolyPolygonInplace(const Points: TArrayOfArrayOfFloatPoint;
  ScaleX, ScaleY: TFloat);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
    ScalePolygonInplace(Points[I], ScaleX, ScaleY);
end;

// Scales all sub polygons in a complex polygon (TArrayOfArrayOfFixedPoint)
procedure ScalePolyPolygonInplace(const Points: TArrayOfArrayOfFixedPoint;
  ScaleX, ScaleY: TFixed);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
    ScalePolygonInplace(Points[I], ScaleX, ScaleY);
end;

// Translates a polygon (TArrayOfFloatPoint)
function TranslatePolygon(const Points: TArrayOfFloatPoint;
  OffsetX, OffsetY: TFloat): TArrayOfFloatPoint;
var
  I, Len: Integer;
begin
  Len := Length(Points);
  SetLength(Result, Len);
  for I := 0 to Len - 1 do
  begin
    Result[I].X := Points[I].X + OffsetX;
    Result[I].Y := Points[I].Y + OffsetY;
  end;
end;

// Translates a polygon (TArrayOfFixedPoint)
function TranslatePolygon(const Points: TArrayOfFixedPoint;
  OffsetX, OffsetY: TFixed): TArrayOfFixedPoint;
var
  I, Len: Integer;
begin
  Len := Length(Points);
  SetLength(Result, Len);
  for I := 0 to Len - 1 do
  begin
    Result[I].X := Points[I].X + OffsetX;
    Result[I].Y := Points[I].Y + OffsetY;
  end;
end;

// Translates all sub polygons in a complex polygon (TArrayOfArrayOfFloatPoint)
function TranslatePolyPolygon(const Points: TArrayOfArrayOfFloatPoint; OffsetX,
  OffsetY: TFloat): TArrayOfArrayOfFloatPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    Result[I] := TranslatePolygon(Points[I], OffsetX, OffsetY);
end;

// Translates all sub polygons in a complex polygon (TArrayOfArrayOfFixedPoint)
function TranslatePolyPolygon(const Points: TArrayOfArrayOfFixedPoint;
  OffsetX, OffsetY: TFixed): TArrayOfArrayOfFixedPoint;
var
  I, L: Integer;
begin
  L := Length(Points);
  SetLength(Result, L);
  for I := 0 to L - 1 do
    Result[I] := TranslatePolygon(Points[I], OffsetX, OffsetY);
end;

procedure TranslatePolygonInplace(const Points: TArrayOfFloatPoint;
  OffsetX, OffsetY: TFloat);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
  begin
    Points[I].X := Points[I].X + OffsetX;
    Points[I].Y := Points[I].Y + OffsetY;
  end;
end;

procedure TranslatePolygonInplace(const Points: TArrayOfFixedPoint;
  OffsetX, OffsetY: TFixed);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
  begin
    Points[I].X := Points[I].X + OffsetX;
    Points[I].Y := Points[I].Y + OffsetY;
  end;
end;

// Translates all sub polygons in a complex polygon (TArrayOfArrayOfFloatPoint)
procedure TranslatePolyPolygonInplace(const Points: TArrayOfArrayOfFloatPoint; OffsetX,
  OffsetY: TFloat);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
    TranslatePolygonInplace(Points[I], OffsetX, OffsetY);
end;

// Translates all sub polygons in a complex polygon (TArrayOfArrayOfFixedPoint)
procedure TranslatePolyPolygonInplace(const Points: TArrayOfArrayOfFixedPoint;
  OffsetX, OffsetY: TFixed);
var
  I: Integer;
begin
  for I := 0 to Length(Points) - 1 do
    TranslatePolygonInplace(Points[I], OffsetX, OffsetY);
end;

// Applies transformation to a polygon (TArrayOfFloatPoint)
function TransformPolygon(const Points: TArrayOfFloatPoint;
  Transformation: TTransformation): TArrayOfFloatPoint;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  for I := 0 to High(Result) do
    TTransformationAccess(Transformation).TransformFloat(Points[I].X,
      Points[I].Y, Result[I].X, Result[I].Y);
end;

// Applies transformation to a polygon (TArrayOfFixedPoint)
function TransformPolygon(const Points: TArrayOfFixedPoint;
  Transformation: TTransformation): TArrayOfFixedPoint;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  for I := 0 to High(Result) do
    TTransformationAccess(Transformation).TransformFixed(Points[I].X,
      Points[I].Y, Result[I].X, Result[I].Y);
end;

// Applies transformation to all sub polygons in a complex polygon
function TransformPolyPolygon(const Points: TArrayOfArrayOfFloatPoint;
  Transformation: TTransformation): TArrayOfArrayOfFloatPoint;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  TTransformationAccess(Transformation).PrepareTransform;

  for I := 0 to High(Result) do
    Result[I] := TransformPolygon(Points[I], Transformation);
end;

// Applies transformation to all sub polygons in a complex polygon
function TransformPolyPolygon(const Points: TArrayOfArrayOfFixedPoint;
  Transformation: TTransformation): TArrayOfArrayOfFixedPoint;
var
  I: Integer;
begin
  SetLength(Result, Length(Points));
  TTransformationAccess(Transformation).PrepareTransform;

  for I := 0 to High(Result) do
    Result[I] := TransformPolygon(Points[I], Transformation);
end;

function BuildPolygonF(const Data: array of TFloat): TArrayOfFloatPoint;
var
  Index, Count: Integer;
begin
  Count := Length(Data) div 2;
  SetLength(Result, Count);
  if Count = 0 then Exit;
  for Index := 0 to Count - 1 do
  begin
    Result[Index].X := Data[Index * 2];
    Result[Index].Y := Data[Index * 2 + 1];
  end;
end;

function BuildPolygonX(const Data: array of TFixed): TArrayOfFixedPoint;
var
  Index, Count: Integer;
begin
  Count := Length(Data) div 2;
  SetLength(Result, Count);
  if Count = 0 then Exit;
  for Index := 0 to Count - 1 do
  begin
    Result[Index].X := Data[Index * 2];
    Result[Index].Y := Data[Index * 2 + 1];
  end;
end;

// Copy data from Polygon to simple PolyPolygon (using 1 sub polygon only)
function PolyPolygon(const Points: TArrayOfFloatPoint): TArrayOfArrayOfFloatPoint;
begin
  SetLength(Result, 1);
  Result[0] := Points;
end;

function PolyPolygon(const Points: TArrayOfFixedPoint): TArrayOfArrayOfFixedPoint;
begin
  SetLength(Result, 1);
  Result[0] := Points;
end;

function PointToFloatPoint(const Points: TArrayOfPoint): TArrayOfFloatPoint;
var
  Index: Integer;
begin
  if Length(Points) > 0 then
  begin
    SetLength(Result, Length(Points));
    for Index := 0 to Length(Points) - 1 do
    begin
      Result[Index].X := Points[Index].X;
      Result[Index].Y := Points[Index].Y;
    end;
  end;
end;

function PointToFloatPoint(const Points: TArrayOfArrayOfPoint): TArrayOfArrayOfFloatPoint;
var
  Index, PointIndex: Integer;
begin
  if Length(Points) > 0 then
  begin
    SetLength(Result, Length(Points));
    for Index := 0 to Length(Points) - 1 do
    begin
      SetLength(Result[Index], Length(Points[Index]));
      for PointIndex := 0 to Length(Points[Index]) - 1 do
      begin
        Result[Index, PointIndex].X := Points[Index, PointIndex].X;
        Result[Index, PointIndex].Y := Points[Index, PointIndex].Y;
      end;
    end;
  end;
end;

function PointToFixedPoint(const Points: TArrayOfPoint): TArrayOfFixedPoint;
var
  Index: Integer;
begin
  if Length(Points) > 0 then
  begin
    SetLength(Result, Length(Points));
    for Index := 0 to Length(Points) - 1 do
    begin
      Result[Index].X := Fixed(Points[Index].X);
      Result[Index].Y := Fixed(Points[Index].Y);
    end;
  end;
end;

function PointToFixedPoint(const Points: TArrayOfArrayOfPoint): TArrayOfArrayOfFixedPoint;
var
  Index, PointIndex: Integer;
begin
  if Length(Points) > 0 then
  begin
    SetLength(Result, Length(Points));
    for Index := 0 to Length(Points) - 1 do
    begin
      SetLength(Result[Index], Length(Points[Index]));
      for PointIndex := 0 to Length(Points[Index]) - 1 do
      begin
        Result[Index, PointIndex].X := Fixed(Points[Index, PointIndex].X);
        Result[Index, PointIndex].Y := Fixed(Points[Index, PointIndex].Y);
      end;
    end;
  end;
end;


//------------------------------------------------------------------------------
//
//      TPolyLineBuilder
//
//------------------------------------------------------------------------------
// Abstract base class for Grow and BuildPoly*line implementations.
//------------------------------------------------------------------------------
class function TPolyLineBuilder.SupportedEndStyles: TEndStyles;
begin
  Result := [];
end;

class function TPolyLineBuilder.SupportedJoinStyles: TJoinStyles;
begin
  Result := [];
end;

//------------------------------------------------------------------------------

class function TPolyLineBuilder.BuildPolyLine(const Points: TArrayOfFixedPoint; StrokeWidth: TFixed; JoinStyle: TJoinStyle;
  EndStyle: TEndStyle; MiterLimit: TFixed): TArrayOfFixedPoint;
var
  FloatPoints, FloatResult: TArrayOfFloatPoint;
begin
  FloatPoints := FixedPointToFloatPoint(Points);

  // Defer to float implementation
  FloatResult := BuildPolyLine(FloatPoints, StrokeWidth*FixedOne, JoinStyle, EndStyle, MiterLimit*FixedOne);

  if (Length(FloatResult) > 0) then
    Result := FloatPointToFixedPoint(FloatResult)
  else
    SetLength(Result, 0);
end;

//------------------------------------------------------------------------------

class function TPolyLineBuilder.BuildPolyPolyLine(const Points: TArrayOfArrayOfFixedPoint; Closed: Boolean; StrokeWidth: TFixed;
  JoinStyle: TJoinStyle; EndStyle: TEndStyle; MiterLimit: TFixed): TArrayOfArrayOfFixedPoint;
var
  FloatPoints, FloatResult: GR32.TArrayOfArrayOfFloatPoint;
begin
  FloatPoints := FixedPointToFloatPoint(Points);

  // Defer to float implementation
  FloatResult := BuildPolyPolyLine(FloatPoints, Closed, StrokeWidth*FixedOne, JoinStyle, EndStyle, MiterLimit*FixedOne);

  if (Length(FloatResult) > 0) then
    Result := FloatPointToFixedPoint(FloatResult)
  else
    SetLength(Result, 0);
end;

//------------------------------------------------------------------------------

class function TPolyLineBuilder.Grow(const Points: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle; Closed: Boolean;
  MiterLimit: TFloat): TArrayOfFloatPoint;
var
  Normals: TArrayOfFloatPoint;
begin
  Normals := BuildNormals(Points);
  Result := Grow(Points, Normals, Delta, JoinStyle, Closed, MiterLimit);
end;

//------------------------------------------------------------------------------

class function TPolyLineBuilder.Grow(const Points: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle; Closed: Boolean;
  MiterLimit: TFixed): TArrayOfFixedPoint;
var
  Normals: TArrayOfFixedPoint;
begin
  Normals := BuildNormals(Points);
  Result := Grow(Points, Normals, Delta, JoinStyle, Closed, MiterLimit);
end;

//------------------------------------------------------------------------------

class function TPolyLineBuilder.Grow(const Points, Normals: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle;
  Closed: Boolean; MiterLimit: TFixed): TArrayOfFixedPoint;
var
  FloatPoints, FloatNormals, FloatResult: TArrayOfFloatPoint;
begin
  FloatPoints := FixedPointToFloatPoint(Points);
  FloatNormals := FixedPointToFloatPoint(Normals);

  // Defer to float implementation
  FloatResult := Grow(FloatPoints, FloatNormals, Delta * FixedToFloat, JoinStyle, Closed, MiterLimit * FixedToFloat);

  if (Length(FloatResult) > 0) then
    Result := FloatPointToFixedPoint(FloatResult)
  else
    SetLength(Result, 0);
end;



//------------------------------------------------------------------------------

function Grow(const Points: TArrayOfFloatPoint; const Normals: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle; Closed: Boolean; MiterLimit: TFloat): TArrayOfFloatPoint;
begin
  Result := Grow(Points, Delta, JoinStyle, Closed, MiterLimit);
end;

function Grow(const Points: TArrayOfFloatPoint; const Delta: TFloat; JoinStyle: TJoinStyle; Closed: Boolean; MiterLimit: TFloat): TArrayOfFloatPoint;
begin
  Result := PolylineBuilder.Grow(Points, Delta, JoinStyle, Closed, MiterLimit);
end;

function Grow(const Points: TArrayOfFixedPoint; const Normals: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle; Closed: Boolean; MiterLimit: TFixed): TArrayOfFixedPoint;
begin
  Result := Grow(Points, Delta, JoinStyle, Closed, MiterLimit);
end;

function Grow(const Points: TArrayOfFixedPoint; const Delta: TFixed; JoinStyle: TJoinStyle; Closed: Boolean; MiterLimit: TFixed): TArrayOfFixedPoint;
begin
  Result := PolylineBuilder.Grow(Points, Delta, JoinStyle, Closed, MiterLimit);
end;

//------------------------------------------------------------------------------

function BuildPolyLine(const Points: TArrayOfFloatPoint; StrokeWidth: TFloat; JoinStyle: TJoinStyle; EndStyle: TEndStyle; MiterLimit: TFloat): TArrayOfFloatPoint;
begin
  Result := PolylineBuilder.BuildPolyLine(Points, StrokeWidth, JoinStyle, EndStyle, MiterLimit);
end;

function BuildPolyPolyLine(const Points: TArrayOfArrayOfFloatPoint; Closed: Boolean; StrokeWidth: TFloat; JoinStyle: TJoinStyle; EndStyle: TEndStyle; MiterLimit: TFloat): TArrayOfArrayOfFloatPoint;
begin
  Result := PolylineBuilder.BuildPolyPolyLine(Points, Closed, StrokeWidth, JoinStyle, EndStyle, MiterLimit);
end;

function BuildPolyLine(const Points: TArrayOfFixedPoint; StrokeWidth: TFixed; JoinStyle: TJoinStyle; EndStyle: TEndStyle; MiterLimit: TFixed): TArrayOfFixedPoint;
begin
  Result := PolylineBuilder.BuildPolyLine(Points, StrokeWidth, JoinStyle, EndStyle, MiterLimit);
end;

function BuildPolyPolyLine(const Points: TArrayOfArrayOfFixedPoint; Closed: Boolean; StrokeWidth: TFixed; JoinStyle: TJoinStyle; EndStyle: TEndStyle; MiterLimit: TFixed): TArrayOfArrayOfFixedPoint;
begin
  Result := PolylineBuilder.BuildPolyPolyLine(Points, Closed, StrokeWidth, JoinStyle, EndStyle, MiterLimit);
end;

//------------------------------------------------------------------------------

initialization
{$if defined(GR32_OFFSET_CLIPPER)}
  PolylineBuilder := PolyLineBuilderClipper;
{$elseif defined(GR32_OFFSET_ANGUS)}
  PolylineBuilder := PolyLineBuilderAngus;
{$elseif defined(GR32_OFFSET_REF)}
  PolylineBuilder := PolyLineBuilderReference;
{$ifend}
end.
