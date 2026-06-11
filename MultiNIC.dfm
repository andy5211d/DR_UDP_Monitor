object frmMultiNIC: TfrmMultiNIC
  Left = 0
  Top = 0
  Caption = 'MultiNIC'
  ClientHeight = 432
  ClientWidth = 258
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormShow
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 25
    Top = 32
    Width = 200
    Height = 15
    Caption = 'Multiple network adaptors detected.   '
  end
  object Button1: TButton
    Left = 72
    Top = 225
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
  end
  object RgIPs: TRadioGroup
    Left = 25
    Top = 67
    Width = 185
    Height = 152
    Caption = 'IP Addresses'
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 25
    Top = 256
    Width = 185
    Height = 161
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
end
