object FormExtract: TFormExtract
  Left = 0
  Top = 0
  Caption = '7-Zip Delphi API test'
  ClientHeight = 565
  ClientWidth = 685
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnResize = FormResize
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 685
    Height = 97
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 0
    object lbSource: TLabel
      Left = 24
      Top = 21
      Width = 85
      Height = 15
      Caption = 'Source filename'
    end
    object lbTarget: TLabel
      Left = 24
      Top = 55
      Width = 74
      Height = 15
      Caption = 'Target root dir'
    end
    object edTargetDir: TEdit
      Left = 150
      Top = 52
      Width = 411
      Height = 23
      TabOrder = 0
    end
    object btSelect: TButton
      Left = 576
      Top = 17
      Width = 75
      Height = 25
      Caption = '&Select'
      TabOrder = 1
      OnClick = btSelectClick
    end
    object edFilename: TEdit
      Left = 150
      Top = 18
      Width = 411
      Height = 23
      TabOrder = 2
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 97
    Width = 685
    Height = 56
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 1
    object btAction: TButton
      Left = 16
      Top = 16
      Width = 137
      Height = 25
      Caption = '&Extract files'
      TabOrder = 0
      OnClick = btActionClick
    end
    object btQuit: TButton
      Left = 170
      Top = 16
      Width = 137
      Height = 25
      Caption = '&Quit'
      TabOrder = 1
      OnClick = btQuitClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 153
    Width = 685
    Height = 412
    Align = alClient
    BevelInner = bvNone
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object OpenDialog1: TOpenDialog
    Options = [ofEnableSizing]
    Left = 600
    Top = 80
  end
end
