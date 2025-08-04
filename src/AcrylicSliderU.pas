unit AcrylicSliderU;

interface

uses
  System.Classes,
  System.UITypes,
  Vcl.Controls,
  AcrylicControlU;

type

  TAcrylicSlider = Class(TAcrylicControl)
  private
    m_clSliderColor : TAlphaColor;
    m_dLevel        : Single;
    m_dTempLevel    : Single;
    m_bChanging     : Boolean;
    m_OnChange      : TNotifyEvent;

    procedure CMMouseWheel (var Msg : TCMMouseWheel); message CM_MOUSEWHEEL;

    procedure SetLevel      (a_dLevel : Single);
    procedure SetTempLevel  (a_dLevel : Single);
    procedure SetSliderColor(a_clSliderColor : TAlphaColor);
    procedure Changed;

  protected
    procedure PaintComponent; override;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(a_cOwner: TComponent); override;
    destructor  Destroy; override;

  published
    property SliderColor : TAlphaColor  read m_clSliderColor write SetSliderColor;
    property Level       : Single       read m_dLevel        write SetLevel;
    property OnChange    : TNotifyEvent read m_OnChange      write m_OnChange;

  end;

procedure Register;

const
  c_nWidthBorder  = 10;
  c_nHeightBorder = 6;

implementation

uses
  GDIPAPI,
  Math,
  AcrylicTypesU,
  AcrylicUtilsU;

//==============================================================================
 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicSlider]);
 end;

 //==============================================================================
procedure TAcrylicSlider.CMMouseWheel(var Msg: TCMMouseWheel);
begin
  Inherited;

  if Msg.WheelDelta > 0 then
    Level := m_dLevel + 0.05;

  if Msg.WheelDelta < 0 then
    Level := m_dLevel - 0.05;

  Changed;
end;

//==============================================================================
constructor TAcrylicSlider.Create(a_cOwner: TComponent);
begin
  Inherited Create(a_cOwner);

  m_dLevel        := 0;
  m_dTempLevel    := 0;
  m_clSliderColor := c_clCtrlFont;
  m_bClickable    := True;
  m_bWithBorder   := False;
  m_bChanging     := False;
end;

//==============================================================================
destructor TAcrylicSlider.Destroy;
begin
  Inherited;
end;

//==============================================================================
procedure TAcrylicSlider.Changed;
begin
  if Assigned(m_OnChange) then
    m_OnChange(Self);

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicSlider.SetLevel(a_dLevel : Single);
begin
  m_dLevel := Min(Max(a_dLevel, 0), 1);
  Changed;
end;

//==============================================================================
procedure TAcrylicSlider.SetTempLevel(a_dLevel : Single);
begin
  m_dTempLevel := Min(Max(a_dLevel, 0), 1);
end;

//==============================================================================
procedure TAcrylicSlider.SetSliderColor(a_clSliderColor : TAlphaColor);
begin
  m_clSliderColor := a_clSliderColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicSlider.PaintComponent;
var
  pntStart : TGPPointF;
  pntEnd   : TGPPointF;
  dLevel   : Single;
const
  c_nEPS = 0.01;
begin
  InitializeGDI;

  m_gdiGraphics.SetSmoothingMode(SmoothingModeHighQuality);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
  m_gdiSolidPen.SetLineJoin(LineJoinBevel);
  m_gdiSolidPen.SetLineCap(LineCapRound, LineCapRound, DashCapFlat);

  //////////////////////////////////////////////////////////////////////////////
  ///  Draw Track's back

  m_gdiSolidPen.SetWidth(ClientHeight - 2 * c_nHeightBorder + 2);
  m_gdiSolidPen.SetColor(gdiColor(m_clColor));
  pntStart.X := c_nWidthBorder;
  pntStart.Y := ClientHeight div 2;
  pntEnd.X   := ClientWidth - c_nWidthBorder;
  pntEnd.Y   := ClientHeight div 2;

  m_gdiGraphics.DrawLine(m_gdiSolidPen, pntStart, pntEnd);

  //////////////////////////////////////////////////////////////////////////////
  ///  Draw Track's line
  if m_bChanging
    then dLevel := m_dTempLevel
    else dLevel := m_dLevel;

  m_gdiSolidPen.SetWidth(ClientHeight - 2 * c_nHeightBorder);
  m_gdiSolidPen.SetColor(gdiColor(m_clSliderColor));
  pntEnd.X := Max(c_nWidthBorder + c_nEPS,
                  c_nWidthBorder + dLevel*(ClientWidth - 2*c_nWidthBorder));

  m_gdiGraphics.DrawLine(m_gdiSolidPen, pntStart, pntEnd);

  m_gdiGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);
  m_gdiSolidPen.SetLineCap(LineCapFlat, LineCapFlat, DashCapFlat);

  ShutdownGDI;
end;

//==============================================================================
procedure TAcrylicSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if m_msMouseState = msClicked then
    SetTempLevel(X / ClientWidth);

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SetTempLevel(X / ClientWidth);
  m_bChanging := True;

  Inherited;
end;

//==============================================================================
procedure TAcrylicSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if m_bChanging then
  begin
    Level       := m_dTempLevel;
    m_bChanging := False;
  end;

  Inherited;
end;

end.


