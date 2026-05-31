{ ************************************* }
{ Copyright(c) 2007-2025  Andy Hewat    }
{ ************************************* }

// A Unit for Andy's DR-UDP Monitor programme.
// Original from Malcolm's DR2Video

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
    Button1: TButton;
    RgIPs: TRadioGroup;
    Memo1: TMemo;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMultiNIC: TfrmMultiNIC;

implementation

{$R *.dfm}

uses
//  Display,
  DiveDM;       // what is being used?       =  DStrings

procedure TfrmMultiNIC.FormShow(Sender: TObject);
var
  I: Integer;
  AutoIndex: Integer;
  IP: string;
begin
  // Safety: no NICs available
  if (DStrings = nil) or (DStrings.Count = 0) then
  begin
    Memo1.Lines.Add('No network interfaces found.');
    ModalResult := mrCancel;
    Exit;
  end;

  // Clear UI
  Memo1.Clear;
  RgIPs.Items.Clear;

  // Populate memo and radio group
  for I := 0 to DStrings.Count - 1 do
  begin
    Memo1.Lines.Add(DStrings[I]);  // full line: "192.168.1.10:Ethernet 2"

    // Extract IP before the colon
    IP := DStrings[I].Substring(0, DStrings[I].IndexOf(':'));
    RgIPs.Items.Add(IP);
  end;

  // If only one NIC → auto-select and close
  if DStrings.Count = 1 then
  begin
    RgIPs.ItemIndex := 0;
    ModalResult := mrOK;
    Exit;
  end;

  // More than one NIC → try to auto-select a Class C (192.168.x.x)
  AutoIndex := -1;
  for I := 0 to DStrings.Count - 1 do
    if DStrings[I].StartsWith('192.168.') then
    begin
      AutoIndex := I;
      Break;
    end;

  // If found, pre-select it
  if AutoIndex <> -1 then
    RgIPs.ItemIndex := AutoIndex
  else
    RgIPs.ItemIndex := 0; // fallback

  // Leave form open for user confirmation
end;


procedure TfrmMultiNIC.Button1Click(Sender: TObject);
begin
  ModalResult := MrOK;
end;


end.
