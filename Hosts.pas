{ ************************************** }
{ Copyright(c) 2006-2005  Malcolm Taylor }
{ Copyright(c) 2022-2026  Andy Hewat     }
{ ************************************** }

{
  A Unit for the DR-UDP Monitor programme.
  Original from Malcolm's DR2Video.
  Generates the Hosts' window and allows user selection if more than one instance
  of DiveRecorder is connected to the network.

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
    Label1: TLabel;
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
  DiveDM,
  Display,
  System.StrUtils;

procedure TfrmHosts.BtnExitClick(Sender: TObject);
begin
  ScanTimer.Enabled := False;
  Close;
end;

procedure TfrmHosts.BtnHostsClick(Sender: TObject);
var
  I: Integer;
begin
  RgpHosts.Items.Clear;
  RgpHosts.Items.Add('All');

if HostNameList = nil then
begin
  HostNameList := TStringList.Create;
  HostNameList.Sorted := True;
  HostNameList.Duplicates := dupIgnore;
  HostNameList.CaseSensitive := False;
end;
HostNameList.Clear;  // <-- OK here, because you are starting a NEW scan
  HostNameList.Clear;

  Screen.Cursor := CrHourGlass;
  ScanTimer.Enabled := True;

  for I := 1 to 3 do
  begin
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
  ScanTimer.Enabled := False;      // stop timer first
  // Do NOT free HostNameList here – it is owned by DiveDM
end;


procedure TfrmHosts.RgpHostsClick(Sender: TObject);
var
  I: Integer;
begin

  I := RgpHosts.ItemIndex;
  if I < 1 then
    begin
      DRHost := '';
      Form7.Edit16.text := 'All Hosts';
    end
  else
    begin
      DRHost := RgpHosts.Items[I];
      Form7.Edit16.text := 'DR Display ONLY showing data from: ' + DRHost;
    end;
end;


procedure TfrmHosts.ScanTimerTimer(Sender: TObject);
var
  S: string;
  keepHost: string;
  idx: Integer;
begin
  // Stop timer first so it only fires once per scan
  ScanTimer.Enabled := False;

  Screen.Cursor := crDefault;

  // Remember current selection (if any)
  keepHost := DRHost;

  // Nothing discovered yet?
  if (HostNameList = nil) or (HostNameList.Count = 0) then
  begin
    // Still show basic list
    RgpHosts.Items.BeginUpdate;
    try
      RgpHosts.Items.Clear;
      RgpHosts.Items.Add('All');
      RgpHosts.ItemIndex := 0;
    finally
      RgpHosts.Items.EndUpdate;
    end;
    Exit;
  end;

  // Rebuild RadioGroup in one batch (avoids slow "reformatting")
  RgpHosts.Items.BeginUpdate;
  try
    RgpHosts.Items.Clear;
    RgpHosts.Items.Add('All');

  for idx := 0 to HostNameList.Count - 1 do
    RgpHosts.Items.Add(HostNameList[idx]);

    // Restore selection if possible
    if keepHost <> '' then
    begin
      idx := RgpHosts.Items.IndexOf(keepHost);
      if idx >= 1 then
        RgpHosts.ItemIndex := idx
      else
        RgpHosts.ItemIndex := 0;  // fallback to All
    end
    else
      RgpHosts.ItemIndex := 0;

  finally
    RgpHosts.Items.EndUpdate;
  end;
end;

end.
