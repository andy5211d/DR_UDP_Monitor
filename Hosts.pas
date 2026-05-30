{ ************************************* }
{ Copyright(c) 2007-2026  Andy Hewat    }
{ ************************************* }

{
  A Unit for Andy's DR-UDP Monitor programme.
  >>>Original from Malcolm's DR2Video.
  Generates the Hosts' window and allows user selection if more than one DR instance.

  *** This is not currently used in the App, but maybe in the future. Perhaps
  to monitor a problem DR instance.  ****
}


unit Hosts;

interface

uses

  Winapi.Windows,
  Winapi.Messages,
//  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  IdBaseComponent,
  IdComponent,
  IdUDPBase,
  IdUDPClient;

type
  TfrmHosts = class(TForm)
    BtnExit: TButton;
    BtnHosts: TButton;
    RgpHosts: TRadioGroup;
    ScanTimer: TTimer;
    UDPClient: TIdUDPClient;
    procedure BtnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ScanTimerTimer(Sender: TObject);
    procedure RgpHostsClick(Sender: TObject);
    procedure BtnHostsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHosts: TfrmHosts;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  Main,
  DiveDM,              // What is being used in this unit?     =  DRHost
  Display,             // What is being used in this unit?     =  HostNameList
  System.StrUtils;




procedure TfrmHosts.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHosts.BtnHostsClick(Sender: TObject);
var
  I: Integer;
  s: string;
begin
  RgpHosts.Items.Clear;
  RgpHosts.Items.Add('All');  //  RgpHosts.Items.Add(SiLangRTHosts.GetTextOrDefault('IDS_7' (* 'All' *) ));
  Repaint;
  HostNameList.Clear;
  Screen.Cursor := CrHourGlass;
  ScanTimer.Enabled := True; // reads host list after 2 seconds

  // now scan for any remote utilities     <ACH> but a max of 3
  for I := 1 to 3 do
  begin
    //UDPClient.Broadcast('HELLO', UDPClientPort, BroadcastIP, IndyTextEncoding_UTF8);   // The original code by Malcolm.
    UDPClient.Broadcast('HELLO', UDPClientPort, BroadcastIP);
    Sleep(50);
  end;

end;

procedure TfrmHosts.FormCreate(Sender: TObject);
begin
  // Not used in this unit.  Malcolm calls this on initilisation for the multi-language changes.
end;

procedure TfrmHosts.FormDestroy(Sender: TObject);
begin
  if UDPClient.Active then
    UDPClient.Active := False;
//  HostNameList.Free;
//  MessageList.Free;
end;

procedure TfrmHosts.RgpHostsClick(Sender: TObject);
var
  I: Integer;
begin

  I := RgpHosts.ItemIndex;
  if I < 1 then
    DRHost := ''
  else
    DRHost := RgpHosts.Items[I];

end;

procedure TfrmHosts.ScanTimerTimer(Sender: TObject);
var
  S: string;
begin

  for S in HostNameList do
    RgpHosts.Items.Add(S);
  ScanTimer.Enabled := FALSE;
  if DRHost <> '' then
    RgpHosts.ItemIndex := RgpHosts.Items.IndexOf(DRHost);
    if RgpHosts.ItemIndex < 1 then
      RgpHosts.ItemIndex := 0;      // default = All
    Screen.Cursor := CrDefault;

end;

end.
