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
  Display,
  DiveDM;       // what is being used?       =  DStrings

procedure TfrmMultiNIC.FormShow(Sender: TObject);
var
  I : Integer;
begin

  // display IP addresses and try to pick LAN
  //Memo1.text := inttostr(DStrings.count);           // Fault finding
  Memo1.lines := (DStrings);
  //Memo1.text := inttostr(I);                        // Fault finding
  for I := 0 to DStrings.Count - 1 do
    RgIPs.Items.Add(DStrings[I].Substring(0, DStrings[I].IndexOf(':')));
  for I := 0 to DStrings.Count - 1 do
    if DStrings[I].Contains('192.168.') then
    begin
      RgIPs.ItemIndex := I;
      Exit; // exit after finding first one
    end;
end;

procedure TfrmMultiNIC.Button1Click(Sender: TObject);
begin
  ModalResult := MrOK;
end;


end.
