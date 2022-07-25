object AcrylicFrame: TAcrylicFrame
  Left = 0
  Top = 0
  Width = 200
  Height = 200
  DoubleBuffered = False
  ParentDoubleBuffered = False
  TabOrder = 0
  object pnlTitle: TAcrylicGhostPanel
    Left = 1
    Top = 1
    Width = 198
    Height = 25
    Color = x001F1F1F
    TabOrder = 0
    Ghost = True
    Colored = False
    Backcolor = 2039583
    object imgClose: TImage
      Left = 174
      Top = 0
      Width = 24
      Height = 24
      OnClick = imgCloseClick
      OnMouseEnter = imgCloseMouseEnter
      OnMouseLeave = imgCloseMouseLeave
    end
  end
end
