object AcrylicForm: TAcrylicForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'AcrylicForm'
  ClientHeight = 519
  ClientWidth = 617
  Color = clCream
  TransparentColorValue = clPurple
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBackground: TAcrylicGhostPanel
    Left = 1
    Top = 1
    Width = 615
    Height = 517
    BevelOuter = bvNone
    Color = 2039583
    TabOrder = 0
    object pnlTitleBar: TAcrylicGhostPanel
      Left = 0
      Top = 0
      Width = 615
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      Color = 2039583
      TabOrder = 0
      ExplicitWidth = 617
      object imgClose: TImage
        Left = 571
        Top = -1
        Width = 46
        Height = 32
        OnClick = imgCloseClick
        OnMouseEnter = imgCloseMouseEnter
        OnMouseLeave = imgCloseMouseLeave
      end
      object imgMaximize: TImage
        Left = 527
        Top = -1
        Width = 46
        Height = 32
        OnMouseEnter = imgMaximizeMouseEnter
        OnMouseLeave = imgMaximizeMouseLeave
      end
      object imgMinimize: TImage
        Left = 483
        Top = -1
        Width = 46
        Height = 32
        OnMouseEnter = imgMinimizeMouseEnter
        OnMouseLeave = imgMinimizeMouseLeave
      end
    end
    object pnlContent: TPanel
      Left = 0
      Top = 41
      Width = 615
      Height = 476
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitWidth = 617
      ExplicitHeight = 478
    end
  end
end
