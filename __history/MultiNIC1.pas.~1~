{ ************************************* }
{ Copyright(c) 2007-2023 Malcolm Taylor }
{ ************************************* }

unit MultiNIC;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  SiComp,
  SiLangRT;

type
  TfrmMultiNIC = class(TForm)
    Label1: TLabel;
    RgIPs: TRadioGroup;
    BtnOK: TButton;
    SiLangRTMultiNIC: TsiLangRT;
    procedure BtnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMultiNIC: TfrmMultiNIC;

implementation

{$r *.dfm}

uses
  DiveDM;

procedure TfrmMultiNIC.FormShow(Sender: TObject);
var
  I: Integer;
begin
  // display IP addresses and try to pick LAN
  for I := 0 to DStrings.Count - 1 do
    RgIPs.Items.Add(DStrings[I].Substring(0, DStrings[I].IndexOf(':')));
  for I := 0 to DStrings.Count - 1 do
    if DStrings[I].Contains('192.168.') then
    begin
      RgIPs.ItemIndex := I;
      Exit; // exit after finding first one
    end;
end;

procedure TfrmMultiNIC.BtnOKClick(Sender: TObject);
begin
  ModalResult := MrOK;
end;

end.
