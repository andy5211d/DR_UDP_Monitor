object frmHosts: TfrmHosts
  Left = 0
  Top = 0
  Caption = 'Hosts'
  ClientHeight = 223
  ClientWidth = 263
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Label1: TLabel
    Left = 5
    Top = 6
    Width = 247
    Height = 15
    Caption = 'This form selects the Host ONLY for DR Display'
  end
  object BtnExit: TButton
    Left = 21
    Top = 30
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 0
    OnClick = BtnExitClick
  end
  object BtnHosts: TButton
    Left = 157
    Top = 30
    Width = 75
    Height = 25
    Caption = 'Hosts'
    TabOrder = 1
    OnClick = BtnHostsClick
  end
  object RgpHosts: TRadioGroup
    Left = 21
    Top = 69
    Width = 209
    Height = 146
    Caption = 'Hosts'
    TabOrder = 2
    OnClick = RgpHostsClick
  end
  object ScanTimer: TTimer
    OnTimer = ScanTimerTimer
    Left = 143
    Top = 117
  end
  object UDPClient: TIdUDPClient
    Port = 0
    Left = 55
    Top = 117
  end
end
