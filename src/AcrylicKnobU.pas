unit AcrylicKnobU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  AcrylicControlU,
  AcrylicTypesU;

type
  TAcrylicKnob = Class(TAcrylicControl)
  private
    m_clKnobColor : TAlphaColor;
    m_dLevel      : Single;
    m_dLastLevel  : Single;
    m_nLastY      : Integer;
    m_nLastX      : Integer;
    m_OnChange    : TNotifyEvent;

    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;

    procedure DoubleClick(Sender: TObject);
    procedure Changed;

  protected
    procedure PaintComponent; override;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

  published
    property KnobColor : TAlphaColor read m_clKnobColor write m_clKnobColor;
    property Level     : Single      read m_dLevel      write m_dLevel;

    property OnChange : TNotifyEvent read m_OnChange write m_OnChange;

  end;

  procedure Register;

const
  c_nInitialAngle = 120;
  c_nMaxAngle     = 300;

implementation

uses
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL,
  Math,
  AcrylicUtilsU;

 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicKnob]);
 end;

 //==============================================================================
procedure TAcrylicKnob.CMMouseWheel(var Message: TCMMouseWheel);
begin
  Inherited;

  if Message.WheelDelta > 0 then
    m_dLevel := Min(m_dLevel + 0.05, 1);

  if Message.WheelDelta < 0 then
    m_dLevel := Max(m_dLevel - 0.05, 0);

  Changed;
end;

//==============================================================================
constructor TAcrylicKnob.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  m_dLevel      := 0.5;
  m_clKnobColor := $FFFF8B64;
  m_bClickable  := True;

  m_dLastLevel  := 0.5;
  m_nLastY      := 0;
  m_nLastX      := 0;

  ControlStyle  := ControlStyle + [csDoubleClicks];

  OnDblClick    := DoubleClick;
end;

//==============================================================================
destructor TAcrylicKnob.Destroy;
begin
  Inherited;
end;

//==============================================================================
procedure TAcrylicKnob.Changed;
begin
  if Assigned(m_OnChange) then
    m_OnChange(Self);

  Refresh(True);;
end;

//==============================================================================
procedure TAcrylicKnob.DoubleClick(Sender: TObject);
begin
  m_dLevel := 0.5;
  Changed;
end;

//==============================================================================
procedure TAcrylicKnob.PaintComponent;
var
  nAngle : Integer;
begin
  PaintBackground;
  PaintText;

  //////////////////////////////////////////////////////////////////////////////
  ///  Draw knob
  m_gdiGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);

  nAngle := Trunc(m_dLevel * c_nMaxAngle);

  m_gdiSolidPen.SetLineJoin(LineJoinBevel);
  m_gdiSolidPen.SetWidth(7);
  m_gdiSolidPen.SetColor(gdiColor(m_clBorderColor));

  m_gdiGraphics.DrawArc(m_gdiSolidPen,
                        5,
                        5,
                        ClientWidth - 10,
                        ClientHeight - 10,
                        c_nInitialAngle,
                        c_nMaxAngle);

  m_gdiSolidPen.SetWidth(5);
  m_gdiSolidPen.SetColor(gdiColor(m_clKnobColor));

  m_gdiGraphics.DrawArc(m_gdiSolidPen,
                        5,
                        5,
                        ClientWidth - 10,
                        ClientHeight - 10,
                        c_nInitialAngle,
                        nAngle);

  m_gdiGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);
end;

//==============================================================================
procedure TAcrylicKnob.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  c_nThreshold = 100;
begin
  if m_msMouseState = msClicked then
  begin
    m_dLevel := Max(0, Min(1, m_dLastLevel - (Y-m_nLastY)/c_nThreshold + (X-m_nLastX)/c_nThreshold));
    Changed;
  end
  else
  begin
    m_dLastLevel := m_dLevel;
    m_nLastY     := Y;
    m_nLastX     := X;
  end;
end;

end.


