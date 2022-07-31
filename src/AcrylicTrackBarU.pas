unit AcrylicTrackBarU;

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
  TAcrylicTrackBar = Class(TAcrylicControl)
  private
    m_clTrackColor : TAlphaColor;
    m_dLevel       : Single;
    m_dTempLevel   : Single;
    m_bChanging    : Boolean;
    m_OnChange     : TNotifyEvent;

    procedure CMMouseWheel(var Msg : TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure SetLevel     (a_dLevel : Single);
    procedure SetTempLevel (a_dLevel : Single);
    procedure SetTrackColor(a_clTrackColor : TAlphaColor);
    procedure Changed;

  protected
    procedure PaintComponent; override;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

  published
    property TrackColor : TAlphaColor  read m_clTrackColor write SetTrackColor;
    property Level      : Single       read m_dLevel       write SetLevel;
    property OnChange   : TNotifyEvent read m_OnChange     write m_OnChange;

  end;

procedure Register;

const
  c_nWidthBorder  = 10;
  c_nHeightBorder = 6;

implementation

uses
  GDIPOBJ,
  GDIPAPI,
  GDIPUTIL,
  Math,
  AcrylicUtilsU;

 procedure Register;
 begin
   RegisterComponents('AcrylicComponents', [TAcrylicTrackBar]);
 end;

 //==============================================================================
procedure TAcrylicTrackBar.CMMouseWheel(var Msg: TCMMouseWheel);
begin
  Inherited;

  if Msg.WheelDelta > 0 then
    Level := m_dLevel + 0.05;

  if Msg.WheelDelta < 0 then
    Level := m_dLevel - 0.05;

  Changed;
end;

//==============================================================================
constructor TAcrylicTrackBar.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);

  m_dLevel       := 0;
  m_dTempLevel   := 0;
  m_clTrackColor := c_clSeaBlue;
  m_bClickable   := True;
  m_bWithBorder  := False;
  m_bWithBack    := False;
  m_bChanging    := False;
end;

//==============================================================================
destructor TAcrylicTrackBar.Destroy;
begin
  Inherited;
end;

//==============================================================================
procedure TAcrylicTrackBar.Changed;
begin
  if Assigned(m_OnChange) then
    m_OnChange(Self);

  Refresh(True);
end;

//==============================================================================
procedure TAcrylicTrackBar.SetLevel(a_dLevel : Single);
begin
  m_dLevel := Min(Max(a_dLevel, 0), 1);
  Changed;
end;

//==============================================================================
procedure TAcrylicTrackBar.SetTempLevel(a_dLevel : Single);
begin
  m_dTempLevel := Min(Max(a_dLevel, 0), 1);
end;

//==============================================================================
procedure TAcrylicTrackBar.SetTrackColor(a_clTrackColor : TAlphaColor);
begin
  m_clTrackColor := a_clTrackColor;
  Refresh(True);
end;

//==============================================================================
procedure TAcrylicTrackBar.PaintComponent;
var
  pntStart : TGPPointF;
  pntEnd   : TGPPointF;
  dLevel   : Single;
const
  c_nEPS = 0.01;
begin
  PaintBackground;

  m_gdiGraphics.SetSmoothingMode(SmoothingModeHighQuality);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);
  m_gdiSolidPen.SetLineJoin(LineJoinBevel);
  m_gdiSolidPen.SetLineCap(LineCapRound, LineCapRound, DashCapFlat);

  //////////////////////////////////////////////////////////////////////////////
  ///  Draw Track's back

  m_gdiSolidPen.SetWidth(ClientHeight - 2 * c_nHeightBorder + 2);
  m_gdiSolidPen.SetColor(gdiColor(m_clBackColor));
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
  m_gdiSolidPen.SetColor(gdiColor(m_clTrackColor));
  pntEnd.X := Max(c_nWidthBorder + c_nEPS,
                  c_nWidthBorder + dLevel*(ClientWidth - 2*c_nWidthBorder));

  m_gdiGraphics.DrawLine(m_gdiSolidPen, pntStart, pntEnd);

  m_gdiGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
  m_gdiGraphics.SetPixelOffsetMode(PixelOffsetModeNone);
  m_gdiSolidPen.SetLineCap(LineCapFlat, LineCapFlat, DashCapFlat);
end;

//==============================================================================
procedure TAcrylicTrackBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if m_msMouseState = msClicked then
    SetTempLevel(X / ClientWidth);
end;

//==============================================================================
procedure TAcrylicTrackBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SetTempLevel(X / ClientWidth);
  m_bChanging := True;

  Inherited;
end;

//==============================================================================
procedure TAcrylicTrackBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if m_bChanging then
  begin
    Level       := m_dTempLevel;
    m_bChanging := False;
  end;

  Inherited;
end;

end.


