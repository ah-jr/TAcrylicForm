object AcrylicForm: TAcrylicForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Form1'
  ClientHeight = 519
  ClientWidth = 617
  Color = clCream
  CustomTitleBar.Height = -1
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Left = -1
  GlassFrame.Top = -1
  GlassFrame.Right = -1
  GlassFrame.Bottom = -1
  GlassFrame.SheetOfGlass = True
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBackground: THitTransparentPanel
    Left = 0
    Top = 0
    Width = 617
    Height = 519
    Align = alClient
    TabOrder = 0
    object pnlTitleBar: THitTransparentPanel
      Left = 1
      Top = 1
      Width = 615
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object imgClose: TImage
        Left = 569
        Top = -1
        Width = 46
        Height = 32
        OnClick = imgCloseClick
        OnMouseEnter = imgCloseMouseEnter
        OnMouseLeave = imgCloseMouseLeave
      end
      object imgMaximize: TImage
        Left = 525
        Top = -1
        Width = 46
        Height = 32
        OnMouseEnter = imgMaximizeMouseEnter
        OnMouseLeave = imgMaximizeMouseLeave
      end
      object imgMinimize: TImage
        Left = 481
        Top = -1
        Width = 46
        Height = 32
        OnMouseEnter = imgMinimizeMouseEnter
        OnMouseLeave = imgMinimizeMouseLeave
      end
    end
    object pnlContent: TPanel
      Left = 1
      Top = 42
      Width = 615
      Height = 476
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
    end
  end
end