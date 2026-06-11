object Form2: TForm2
  Left = 0
  Top = 0
  Width = 926
  Height = 1149
  AutoScroll = True
  Caption = 'Message Decode'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object Label1: TLabel
    Left = 278
    Top = 14
    Width = 79
    Height = 13
    Caption = 'Message header'
  end
  object Decode: TButton
    Left = 21
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Decode'
    TabOrder = 0
    OnClick = DecodeClick
  end
  object ListView1: TListView
    Left = 21
    Top = 39
    Width = 868
    Height = 905
    Columns = <>
    TabOrder = 1
    ViewStyle = vsReport
  end
  object Clear: TButton
    Left = 639
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 2
    OnClick = ClearClick
  end
  object CheckBox1: TCheckBox
    Left = 123
    Top = 8
    Width = 126
    Height = 25
    Caption = 'Continuous Decode of Selected Message'
    TabOrder = 3
    WordWrap = True
    OnClick = CheckBox1Click
  end
  object StringGrid1: TStringGrid
    Left = 569
    Top = 950
    Width = 320
    Height = 120
    TabOrder = 4
  end
end
