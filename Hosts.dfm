object frmHosts: TfrmHosts
  Left = 0
  Top = 0
  Caption = 'Hosts'
  ClientHeight = 253
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object BtnExit: TButton
    Left = 48
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 0
    OnClick = BtnExitClick
  end
  object BtnHosts: TButton
    Left = 184
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Hosts'
    TabOrder = 1
    OnClick = BtnHostsClick
  end
  object RgpHosts: TRadioGroup
    Left = 48
    Top = 72
    Width = 209
    Height = 138
    Caption = 'Hosts'
    TabOrder = 2
    OnClick = RgpHostsClick
  end
  object ScanTimer: TTimer
    OnTimer = ScanTimerTimer
    Left = 184
    Top = 120
  end
  object UDPClient: TIdUDPClient
    Port = 0
    Left = 96
    Top = 120
  end
end
