object frmHosts: TfrmHosts
  Left = 0
  Top = 0
  Margins.Left = 5
  Margins.Top = 5
  Margins.Right = 5
  Margins.Bottom = 5
  Caption = 'Hosts'
  ClientHeight = 335
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 144
  TextHeight = 25
  object Label1: TLabel
    Left = 7
    Top = 9
    Width = 374
    Height = 25
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'This form selects the Host ONLY for DR Display'
  end
  object BtnExit: TButton
    Left = 31
    Top = 45
    Width = 113
    Height = 38
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Exit'
    TabOrder = 0
    OnClick = BtnExitClick
  end
  object BtnHosts: TButton
    Left = 235
    Top = 45
    Width = 113
    Height = 38
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Hosts'
    TabOrder = 1
    OnClick = BtnHostsClick
  end
  object RgpHosts: TRadioGroup
    Left = 31
    Top = 103
    Width = 314
    Height = 220
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
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
