object Metrics: TMetrics
  Left = 0
  Top = 0
  Caption = 'Metrics'
  ClientHeight = 387
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 56
    Top = 51
    Width = 46
    Height = 15
    Caption = 'REFEREE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 57
    Top = 216
    Width = 45
    Height = 15
    Caption = 'UPDATE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object GridReferee: TStringGrid
    Left = 56
    Top = 72
    Width = 545
    Height = 129
    TabOrder = 0
  end
  object GridUpdate: TStringGrid
    Left = 56
    Top = 237
    Width = 545
    Height = 129
    TabOrder = 1
  end
  object btnReset: TButton
    Left = 240
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Reset'
    TabOrder = 2
    OnClick = btnResetClick
  end
end
