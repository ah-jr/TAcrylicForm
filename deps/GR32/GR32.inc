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

 {$include GR32_Compiler.inc}


(* Symbol PUREPASCAL:
   ------------------

      Forces GR32 into pure pascal mode. Should generally only be used for
      testing and debugging purposes.
      The library makes use of x86 assembler optimizations. While this
      results in a performance boost it also makes the library platform
      dependent.
      By enabling the PUREPASCAL switch, only pascal code is used, avoiding
      any assmbler code. The code is slower, but probably more platform
      independent.

      (Defined by default for some targets in GR32_Compilers.INC.)

*)

  {-$DEFINE PUREPASCAL}



(* Symbol CHANGED_IN_PIXELS :
   --------------------------

      Defines if the OnChange / OnAreaChange event should be fired with
      safe pixel setters (PixelS, PixelTS, PixelFS etc.)

   NOTE: While enabling this feature is generally better for the repaint and
   layer optimization, in "lazy code" it is also much slower. *)

  {-$DEFINE CHANGED_IN_PIXELS}



(* Symbol USEINLINING :
   --------------------

      Defines whether to use function inlining.

   NOTE: Enabling this symbol increases executable size but will probably
   result in better performance in most cases. *)

  {$IFDEF INLININGSUPPORTED}
    {$DEFINE USEINLINING}
  {$ENDIF}

  {$IF DEFINED(INLININGSUPPORTED) AND DEFINED(SUPPORT_ENHANCED_RECORDS) }
    {$DEFINE INLINING_ENHANCED_RECORDS}
  {$IFEND}


(* Symbol USE_GUIDS_IN_MMF :
   -------------------------

    Defines whether to use GUIDs for temporary MMFs filename instead of
    using the GetTempFilename in WinAPI. *)

{-$DEFINE USE_GUIDS_IN_MMF}



(* Symbol USEMOVE :
   ----------------

    Defines whether to use Move instead of MoveLongword. *)

{-$DEFINE USEMOVE}



(* Symbol USEMULTITHREADING :
   --------------------------

    Use multithreading by default if possible. *)

  {-$DEFINE USEMULTITHREADING}



(* FastCode specific symbols:
    Adding these symbols to your project's define list will force use of the
    particular routine over the standard GR32 routine.

   GR32_FASTCODEMOVE - Uses the patched Move routine rather than MoveLongword.

   For more information on the FastCode project take a look at this URL:
     http://fastcode.sourceforge.net/

   For FastMove make sure to download the CPU id based function, ie. runtime
   RTL patching.
*)

  {-$DEFINE GR32_FASTCODEMOVE}
  {$IFDEF GR32_FASTCODEMOVE}
    {$DEFINE USEMOVE}
  {$ENDIF}




(*
  Symbol OMIT_SSE2:
  ----------------

    If defined SSE2 optimizations are not used (omitted)

  For faster pixel/color processing, SSE2 can be used which results in a huge
  performance boost over PUREPASCAL code or native assembler code.

*)

  {-$DEFINE OMIT_SSE2}


(*
  Symbol: CHANGENOTIFICATIONS
  ---------------------------

    If defined the polygon rasterizer will trigger change notifications.

  Undefining this will avoid bounding box computations, which may
  improve performance slightly.
*)

{$DEFINE CHANGENOTIFICATIONS}



(*
  Symbol: USESTACKALLOC
  ---------------------

    If defined stack allocation routines will be used in some functions.

  Allocating memory on the stack is usually more efficient than using the
  memory manager. If a routine uses StackAllock/StackFree then it should
  always be wrapped inside a {$W+}...{$W-} block in order to generate
  a stack frame.

  NOTE: Undefine this symbol if you get stack overflow errors.
*)

{-$DEFINE USESTACKALLOC}

(*
  Symbol: RGBA_FORMAT
  -------------------

     Assume RGBA pixel format instead of BGRA (used by e.g. OpenGL.)
*)

{-$DEFINE RGBA_FORMAT}


(*
  Symbol: IGNORE_HINTING_DEPRECATED
  -------------------

     Hinting is no longer supported and reference to or use of the hinting
     interfaces will produce a compiler warning.
     If this is a problem you can define the IGNORE_HINTING_DEPRECATED
     symbol to supress the warnings.

     Be aware through that the hinting stuff will be deleted sooner or
     later.
*)
{-$define IGNORE_HINTING_DEPRECATED}

{-$DEFINE TEST_BLENDMEMRGB128SSE4}
{$define GR32_WRAPMODE_REFLECT}

// MMX (and EMMX) is no longer supported on any platform.
{$define OMIT_MMX}

