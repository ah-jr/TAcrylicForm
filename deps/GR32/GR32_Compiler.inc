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
 * The Initial Developer of the Original Code is
 * Alex A. Denisov
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2009
 * the Initial Developer. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK ***** *)


(*
  Supported compilers:
  --------------------

    Name                   CompilerVersion
    -------------------------------------------
    Delphi 12 Yukon             36.0
    Delphi 11 Alexandria        35.0
    Delphi 10.4 Sydney          34.0
    Delphi 10.3 Rio             33.0
    Delphi 10.2 Tokyo           32.0
    Delphi 10.1 Berlin          31.0
    Delphi 10 Seattle           30.0
    Delphi XE8                  29.0
    Delphi XE7                  28.0
    Delphi XE6                  27.0
    Delphi XE5                  26.0
    Delphi XE4                  25.0
    Delphi XE3                  24.0
    Delphi XE2                  23.0

    FreePascal 3.2.2


  This file previously defined the following symbols:

    COMPILERFPC  - FPC (since version 2.6.0)
    COMPILER6    - Delphi 6
    COMPILER7    - Delphi 7
    COMPILER2005 - Delphi 2005
    COMPILER2006 - Delphi 2006 / BDS 2006
    COMPILER2007 - Delphi / RAD Studio 2007
    COMPILER2009 - Delphi 2009
    COMPILER2010 - Delphi 2010
    COMPILERXE1  - Delphi XE
    COMPILERXE2  - Delphi XE2
    COMPILERXE3  - Delphi XE3
    COMPILERXE4  - Delphi XE4
    COMPILERXE5  - Delphi XE5
    COMPILERXE6  - Delphi XE6
    COMPILERXE7  - Delphi XE7
    COMPILERXE8  - Delphi XE8
    COMPILERRX   - Delphi RX (10 Seattle)
    COMPILERRX1  - Delphi RX1 (10.1 Berlin)
    COMPILERRX2  - Delphi RX2 (10.2 Tokyo)
    COMPILERRX3  - Delphi RX3 (10.3 Rio)
    COMPILERRX4  - Delphi RX4 (10.4 Sydney)
    COMPILERRX5  - Delphi 11 (Alexandria)
    COMPILERRX6  - Delphi 12 (Athens)

  The above symbols have all been deprecated. Instead use the following symbols:

    FPC                 - FreePascal
    DCC                 - Delphi
    BCB                 - C++ Builder
    CompilerVersion     - Delphi version


  Available Targets:
  ------------------

    TARGET_x86     - x86 (32-Bit)
    TARGET_x64     - x86 (64-Bit)
    TARGET_POWERPC - Power PC
    TARGET_ARM     - ARM processor
*)



{$if defined(FPC)}

  {...}

{$elseif (CompilerVersion < 23.0)} // Delphi XE2 and later

  {$Message Fatal 'Graphics32 only supports Delphi/BCB XE2 (or higher) or Free Pascal / Lazarus'}

{$elseif (CompilerVersion > 36.0)} // Newer than this file but we'll take it

  {$Message Hint 'Unknown compiler version. Assuming compatible with last known version.'}

{$else} // Delphi XE3 and later

  {$LEGACYIFEND ON} // Stupid. Required for XE4+ but introduced in XE3.

{$ifend}



(*
  Symbol TARGET_* :
  -----------------

    Defines the processor platform (x86, x64 or PowerPC)
*)

{$ifdef FPC}

  // Set up internal CPU target directives according to FPC directives
  {$if defined(CPU386)}

    {$if defined(CPUI386)}

      // target is an Intel 80386 or later.
      {$define TARGET_x86}
      {$ASMMODE INTEL}

    {$elseif defined(CPUX86_64)}

      // target is a 64-bit processor (AMD or INTEL).
      {$define TARGET_x64}
      {$ASMMODE INTEL}

    {$elseif defined(CPUPOWERPC)}

      // target is a 32-bit PowerPC or compatible.
      // currently only indirect support, added here as example on how to add
      // future specific targets
      {$define TARGET_POWERPC}

    {$ifend}

  {$elseif defined(CPUX86_64)}

    // target is a 64-bit processor (AMD or INTEL).
    {$define TARGET_x64}
    {$ASMMODE INTEL}

  {$elseif defined(CPUARM)}

    // target is an ARM processor.
    {$define TARGET_ARM}

  {$ifend}

{$else}

  // check for XE2 64-Bit compiler define
  {$if defined(CPUX64)}

    {$define TARGET_x64}

  {$else}

    // define default (delphi etc) target (32 bit Intel 80386 or later)
    {$define TARGET_x86}

  {$ifend}

{$endif}



(*
  Symbol FRAMEWORK_* :
  -----------------

    Defines the UI framework (VCL, FireMonkey, LCL)
*)
{$ifdef FPC}
  {$define FRAMEWORK_LCL}
{$else}
  {$if declared(FireMonkeyVersion) or defined(FRAMEWORK_FMX)}
    {$define FRAMEWORK_FMX} // Defined as of Delphi 11.1
  {$else}
    {$define FRAMEWORK_VCL} // Defined as of Delphi 11.1
  {$ifend}
{$endif}


(*
  Symbol PUREPASCAL:
  ------------------

     Forces GR32 into pure pascal mode.


   NOTE: Further work needed to make assembly routines FPC compatible.

   NOTE: The DARWIN target of Free Pascal generates PIC code by default
   Which isn't compatible with the current assembler, so force PUREPASCAL
*)

{$ifdef FPC}
  {-$DEFINE PUREPASCAL}
{$endif}

{$ifdef TARGET_ARM}
  {$define PUREPASCAL}
  {$define OMIT_MMX}
  {$define OMIT_SSE2}
{$endif}

{$ifdef DARWIN}
  {$define PUREPASCAL}
{$endif}



(*
  Symbol BITS_GETTER:
  -------------------
*)

{$if defined(FPC) and (not defined(LCLWin32))}
  // Widgetsets other then Windows will want to implement BITS_GETTER
  {$define BITS_GETTER}
{$ifend}



(*
  Symbol NATIVE_SINCOS:
  ---------------------

     Use native FPU function to retrieve SIN/COS values for a given argument

   NOTE: On older systems a native call is typically much faster than calling
   Sin() and Cos() from a higher level library (such as the math/system unit)
   separately. However, on 64-bit systems a call can be slower, due to
   additional conversion between XMM registers and the FPU
*)

{$if defined(PUREPASCAL) or defined(TARGET_x64)}
  {$define NATIVE_SINCOS}
{$ifend}



(*
  Symbol INLININGSUPPORTED:
  -------------------------

    In modern Delphi versions procedures and functions that do not contain
    assembler code can be inlined. This can be extremely useful for calls
    to a small portion of code in a loop. However, depending on the instruction
    cache size, this may or may not result in a performance boost compared to a
    call of assembler optimized code.
*)
// Note: Inlining is supported by all supported compilers; This define will be deprecated.
{$if not defined(MEDIOCRE_COMPILER)}
{$define INLININGSUPPORTED}
{$ifend}



(*
  Symbol: LOADFROMSTREAM
  ----------------------

    TGraphic has the CanLoadFromStream method.

  If this symbol is defined, Graphics32 will use TGraphics.CanLoadFromStream
  when loading an image format from a stream.

  TGraphics.CanLoadFromStream was introducen in Delphi 10.2
*)
{$if defined(FPC) or (CompilerVersion >= 32.0)}
  {$define LOADFROMSTREAM}
{$ifend}



(*
  Symbol: HAS_TPOINTF, HAS_TRECTF
  -------------------------------

    Use the RTL TPointF and TRectF types.

  If this symbol is defined, Graphics32 will alias the TFloatPoint and TFloatRect
  types to the RTL TPointF and TRectF types. Otherwise the types defined in
  GR32 will be used.

  The TPointF and TRectF types exists in Delphi XE2 and later, and in FPC.
  However, the FPC implementation of TRectF is pretty pathetic so we'll use our
  own there.
  Additionally, it seems that the first Delphi implementations of TPointF and
  TRectF lacks the TPoint and TRect conversion operators so we'll use our own
  there too.
*)
{$if defined(FPC) or (CompilerVersion > 25.0)} // XE4
  {$define HAS_TPOINTF}
{$ifend}

{$if (not defined(FPC)) and (CompilerVersion > 25.0)} // XE4
  {$define HAS_TRECTF}
{$ifend}



(*
  Symbol: CLOSURE_CAPTURES_CONST
  -------------------------------

    Can anonymous methods capture const parameters.

  If this symbol is defined, the compiler is assumed to support capturing
  record types passed as const parameters (i.e. by reference) by value.

    procedure Test(const Value: TRect);
    begin
      DoTest(
        procedure(Value) // E2555 Cannot capture symbol 'Value'
        begin
          ...do something...
        end);
    end;

  The symbol is defined for Delphi 10.3 and later and for FPC.
*)
{$if defined(FPC) or (CompilerVersion >= 33.0)}
{$define CLOSURE_CAPTURES_CONST}
{$ifend}



(*
  Symbol: DynArrayOps
  -------------------------------

    Supports dynamic array constructors and operators.

  If this symbol is defined, the compiler is assumed to support dynamic
  array operators such as + and construction with [...].

    procedure Test;
    var
      SomeArray: array of string;
      SomeArrayArray: array of array of string;
    begin
      SomeArray := ['foo', 'bar'];
      SomeArrayArray := [SomeArray];
      SomeArray := ['foo'] + ['bar'];
    end;

  The symbol is defined for Delphi XE7 and later, and for FPC.
*)
{$if defined(FPC) or (CompilerVersion >= 28.0)}
{$define DynArrayOps}
{$ifend}



(*
  Symbol: ClientToScreenRect
  -------------------------------

    The TControl.ClientToScreen(TRect) overload exists.

  If this symbol is defined, TControl implements the ClientToScreen(TRect)
  overload. Otherwise only TControl.ClientToScreen(TPoint) is implemented.

  The symbol is defined for Delphi XE5 and later, and for FPC.
  The exact version of Delphi that introduced the overload is unknown at this
  time.
*)
{$if defined(FPC) or (CompilerVersion > 25.0)}
{$define ClientToScreenRect}
{$ifend}



(*
  Symbol: StaticOperators
  -------------------------------

    class operators must be declared with the 'static' keyword.

  If this symbol is defined, class operators must be declarted as static:

    class operator Equal(const Left, Right: TComplex): boolean; static;


  The symbol is defined for Delphi XE7 and later.
  The exact version of Delphi that introduced the requirement is unknown at
  this time.
*)
{$if (not defined(FPC)) and (CompilerVersion >= 28.0)}
{$define StaticOperators}
{$ifend}



(*
  Symbol: FloatCast
  -------------------------------

    Floating point type casts converts value.

  If this symbol is defined, a floating point type cast performs a value
  conversion. Otherwise it is assumed to do a hard type cast.

    var a: integer;
    var n: Single;
    n := Single(a)

  The symbol is defined for Delphi 10.0 and later.
  The exact version of Delphi that introduced the feature is unknown at
  this time.
*)
{$if (not defined(FPC)) and (CompilerVersion >= 30.0)}
{$define FloatCast}
{$ifend}



(*
  Symbol: GenericMethods
  -------------------------------

    Generic methods are supported.

  If this symbol is defined, the compiler supports declaration of
  generic methods in non-generic classes.

  The symbol is defined for Delphi 10 and later, and for FPC.
*)
{$if defined(FPC) or (CompilerVersion >= 30.0)} // Delphi 10 or later
  {$define GenericMethods}
{$ifend}



(*
  Symbol: NeedImageList
  -------------------------------

    ImageList stuff requires the ImageList unit.

  When (and not because) this symbol is defined, the ImageList unit
  will be included by the IDE when the form contains an TImageList -
  regardless of it being already included or not. Not much we can do
  about it.

  The symbol is defined for Delphi XE8 and later.
*)
{$if defined(FRAMEWORK_VCL) and (CompilerVersion >= 29.0)} // XE8
  {$define NeedImageList}
{$ifend}



(*
  Symbol: NO_GENERIC_METACLASS_LISTS
  -------------------------------

     The C++ Builder linker has problems resolving ambiguities caused by
     metaclass types because they all get mangled as TClass. As a result
     of this the compiled object files end up containing duplicate
     symbols, which in turn causes a LIB266 linker error.
     Specifically we get into problems with TCustomClassList<T> where "T"
     is a metaclass.
     To work around the problem we define the NO_GENERIC_METACLASS_LISTS
     for C++ Builder which causes us to use TClassList for all class types.
*)
{$if defined(BCB)}
{$define NO_GENERIC_METACLASS_LISTS}
{$ifend}



(*
  Symbol: GENERIC_POINTERS
  -------------------------------

    Typed pointers to generic types are supported.

  Older Delphi versions cannot resolve a pointer to a generic type correctly
  and therefore must use plan untyped pointers instead.
  Exact Delphi version is unknown but XE4 doesn't work and Delphi 10 does.

  The symbol is defined for XE5 and later, and for FPC.
  The exact version of Delphi that supports the feature is unknown at this
  time.
*)
{$if defined(FPC)}
  {$define GENERIC_POINTERS}
{$elseif (CompilerVersion > 25.0)}
  {$define GENERIC_POINTERS}
{$ifend}


(*
  Miscellaneous Defines:
  ----------------------
*)

{$UNDEF USETHREADRESUME}

{$ifdef LINUX}
  {$define UNIX}
{$endif}



(*
** Delphi
** ---------------------------------------
*)
{$if (not defined(FPC))}

  // Disable use of Doubles as intermediary values when calculating
  // Single precision expressions.
  {$if defined(TARGET_x64)}
    {$EXCESSPRECISION OFF}
  {$ifend}

  {$if defined(LINUX)}
    {$define BITS_GETTER}
  {$ifend}
  {$if defined(MSWINDOWS)}
    {$define Windows} // For backward compatibility; We use the MSWINDOWS define now
  {$ifend}

  {$define EXT_PROP_EDIT}
  {$define HasParentBackground}
  {$define SUPPORT_XPTHEMES} // enable support for windows xp themes

  // Features only supported by Delphi and not by FPC:
  {$define RECORD_CONSTRUCTORS} // Record type constructors
  {$define RECORD_CLASS_VAR}    // Class vars in record types. Use object type instead.
  {$define CAST_INTF_TO_CLASS}  // Casting an interface to a class.

// 16 byte code alignment required for SSE aligned loads from asm db blocks
  {$CODEALIGN 16}

  // FireMonkey
  {$if defined(ANDROID) or defined(IOS)}
    {$define PLATFORM_INDEPENDENT}
    {$define PUREPASCAL}
    {$define NATIVE_SINCOS}
    {$define RGBA_FORMAT}
  {$ifend}

  {$define USE_FONT_QUALITY} // Apparently Font.Quality now also works with VCL. Not sure which version fixed it though...

{$else}
(*
** FPC
** ---------------------------------------
*)

  {$MODE Delphi}
  {$define PLATFORM_INDEPENDENT}
  {$define FPC_HAS_CONSTREF}
  {$define NATIVE_SINCOS}
  // 16 byte code alignment required for SSE aligned loads from asm db blocks
  {$CODEALIGN PROC=16}

  {$ifndef MSWINDOWS}
    {$define RGBA_FORMAT}
  {$endif}

  {$if (not defined(TARGET_x86)) and (not defined(TARGET_x64))}
    // Target processor is neither x86 or x64: Use Pascal versions
    {$define PUREPASCAL}

  {$ifend}

  {$if defined(TARGET_x86)}
    // StackAlloc currently only works with 32-bit FPC
    {$define USESTACKALLOC}
  {$ifend}

  {-$define HasParentBackground} // FPC has ParentBackground but we haven't implemented support for it

  {$define USE_FONT_QUALITY} // Font.Quality works on LCL

{$ifend}



(*
  Miscellaneous compiler switches:
  --------------------------------
*)
{$R-}{$Q-}  // switch off overflow and range checking



(*
  Deprecated defines
  --------------------------------
*)

{$if defined(FPC)}
  {$define COMPILERFPC}
{$else}
  {$define COMPILERXE2}
  {$define COMPILERXE3}
  {$define COMPILERXE4}
  {$define COMPILERXE5}
  {$define COMPILERXE6}
  {$define COMPILERXE7}
  {$define COMPILERXE8}
  {$define COMPILERRX}
  {$define COMPILERRX1}
  {$define COMPILERRX2}
  {$define COMPILERRX3}
  {$define COMPILERRX4}
  {$define COMPILERRX5}
  {$define COMPILERRX6}
{$ifend}
// FireMonkey
{$IF Defined(ANDROID) or Defined(IOS)}
  {$DEFINE PLATFORM_INDEPENDENT}
  {$DEFINE PUREPASCAL}
  {$DEFINE NATIVE_SINCOS}
  {$DEFINE RGBA_FORMAT}
{$IFEND}

