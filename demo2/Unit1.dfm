object Form1: TForm1
  Left = 0
  Top = 0
  Caption = '7-Zip Delphi API test'
  ClientHeight = 565
  ClientWidth = 776
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 776
    Height = 121
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 0
    ExplicitWidth = 685
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
      Width = 106
      Height = 15
      Caption = 'Target root filename'
    end
    object Label1: TLabel
      Left = 24
      Top = 88
      Width = 71
      Height = 15
      Caption = 'Target format'
    end
    object cbZip: TCheckBox
      Left = 152
      Top = 88
      Width = 57
      Height = 17
      Caption = 'Zip'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object cb7z: TCheckBox
      Left = 232
      Top = 88
      Width = 57
      Height = 17
      Caption = '7z'
      TabOrder = 3
    end
    object edNewName: TEdit
      Left = 150
      Top = 52
      Width = 321
      Height = 23
      TabOrder = 1
      Text = 'xx_'
    end
    object edFilename: TEdit
      Left = 152
      Top = 18
      Width = 321
      Height = 23
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 121
    Width = 776
    Height = 88
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 1
    ExplicitWidth = 685
    object Label2: TLabel
      Left = 406
      Top = 48
      Width = 60
      Height = 15
      Caption = '(1) Zip only'
    end
    object cbDeflate: TCheckBox
      Left = 40
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Deflate (1)'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbDeflate64: TCheckBox
      Left = 40
      Top = 47
      Width = 97
      Height = 17
      Caption = 'Deflate64 (1)'
      TabOrder = 1
    end
    object cbLZMA: TCheckBox
      Left = 160
      Top = 24
      Width = 113
      Height = 17
      Caption = 'LZMA (2)'
      TabOrder = 2
    end
    object cbLZMA2: TCheckBox
      Left = 160
      Top = 47
      Width = 113
      Height = 17
      Caption = 'LZMA2 (2)'
      TabOrder = 3
    end
    object cbPPMd: TCheckBox
      Left = 295
      Top = 24
      Width = 97
      Height = 17
      Caption = 'PPMd  (2)'
      TabOrder = 4
    end
    object cbBZip2: TCheckBox
      Left = 295
      Top = 47
      Width = 97
      Height = 17
      Caption = 'BZip2'
      TabOrder = 5
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 209
    Width = 776
    Height = 88
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 2
    ExplicitWidth = 685
    object cbFast: TCheckBox
      Left = 40
      Top = 24
      Width = 97
      Height = 17
      Caption = 'fast (3)'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbMax: TCheckBox
      Left = 160
      Top = 24
      Width = 97
      Height = 17
      Caption = 'max (7)'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object cbNormal: TCheckBox
      Left = 40
      Top = 47
      Width = 97
      Height = 17
      Caption = 'normal (5)'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object cbUltra: TCheckBox
      Left = 160
      Top = 47
      Width = 97
      Height = 17
      Caption = 'ultra (9)'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object cbSolid: TCheckBox
      Left = 295
      Top = 24
      Width = 106
      Height = 17
      Caption = 'Solid (7-zip only)'
      TabOrder = 4
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 297
    Width = 776
    Height = 56
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 3
    ExplicitWidth = 685
    object btAction: TButton
      Left = 16
      Top = 16
      Width = 137
      Height = 25
      Caption = 'Action'
      TabOrder = 0
      OnClick = btActionClick
    end
    object btQuit: TButton
      Left = 170
      Top = 16
      Width = 137
      Height = 25
      Caption = 'Quit'
      TabOrder = 1
      OnClick = btQuitClick
    end
    object btStop: TButton
      Left = 328
      Top = 16
      Width = 121
      Height = 25
      Caption = 'Stop'
      TabOrder = 2
      OnClick = btStopClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 353
    Width = 776
    Height = 212
    Align = alClient
    BevelInner = bvNone
    ScrollBars = ssBoth
    TabOrder = 4
    ExplicitWidth = 685
  end
end
