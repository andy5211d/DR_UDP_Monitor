{ ********************************** }
{ Copyright(c) 2022-2026  Andy Hewat }
{ ********************************** }

{
  A Unit for DR-UDP Monitor programme.

  Working Solution for DR UDP Message Monitor
  2024-05-27 Version 1.3 ACH
  2024-07-02 V1.4 ACH.   Hosts unit added from DR.  Not working as Hosts code not changed from MDT original
                         Hosts need DiveDM and Display units included so have been added.
  2025-02-04 V1.4.1      Attempt to get the 'Hosts' and MultiNIC units from MDT to work in this utility. Just for learning as not needed for
                         the original UDP Monitor concept.  The port Pie-chart display needs further work.  Intent is to show graphically the
                         number of UDP messages.  Idea was to show if collisions as the number received would change.  Thus green when
                         receiving all Tx by DR and other colour dependent upon number missing.  But the Pie chart does not re-set correctly
                         when a new/different 'packet' is received.  More work needed...  <<<*** Does not run !!! ***>>>
  2026-05-06 V1.5.0      An attempt to use copilot to sort issues with threading and the pie chart!
  2026-06-07             'Display' removed for now so as to not complicate the UDP monitor functionality (challanges with UDP port use).
  2026-06-08 V2.0.0      UI redesign to provide better visulisation of packet loss.  DR Scoreboard (Display) removed.
  2026-05-11 V3.0.0      Metrics added to Referee and Update only (at this time) to visuliase packet loss.
  2026-05-11 V4.0.0      New metrics engine to cater for the way DR works with multiple 'Recording' instances (simultanious or circuit).
                         Hosts and Display (scoreboard) buttons not implemented yet.
                         This compiles but does not do Metrics correctly (as best I can tell)!
  2026-05-12 V4.1.0      Update to correct Metrics for Update and Referee packets.  Only those two packets are 'measured' at this time.
  2026.05.17 V4.2.0      Update to Main form to better show state of each packet type.  Correct elevateDB error on startup.
  2026-05-18 V4.2.1      Display (Scoreboard) now added and changed to share UDP ports with Main.  Host selection now implemented.
  2026-05-18 V4.2.2      UDP message DIVERECORDER moved to port 58091 (from 58092).
  2026-05-30 V4.2.3      Corrected 'Continous Decode' button operation (in Unit2)
  2026-06-10 V4.2.4      Corrected the metrics data and 'clock' display. Packet 'timeout', now set at 100ms.  Packet gap measurement added.
}

unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent, CommCtrl,
  IdComponent, IdUDPBase, IdUDPServer, IdCustomTCPServer, IdSocksServer, IdStackConsts,
  IdUDPClient, IdGlobal, IdSocketHandle, IdStack, Vcl.Samples.Gauges, Vcl.ComCtrls, Unit2,
  Vcl.ExtCtrls, Vcl.ActnMan, Vcl.ActnColorMaps, Vcl.Buttons, UdpMetrics;

type
  TForm7 = class(TForm)
    IdUDPServer1: TIdUDPServer;
    IdUDPServer2: TIdUDPServer;
    IdUDPServer3: TIdUDPServer;
    IdUDPServer4: TIdUDPServer;
    Button1: TButton;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Gauge1: TGauge;
    Gauge2: TGauge;
    Gauge3: TGauge;
    Gauge4: TGauge;
    StandardColorMap1: TStandardColorMap;
    Button2: TButton;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    RadioButton15: TRadioButton;
    Edit16: TEdit;
    Button3: TButton;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Edit17: TEdit;
    RadioButton16: TRadioButton;
    Button4: TButton;
    Button6: TButton;
    Gauge5: TGauge;
    Gauge6: TGauge;
    GroupBox2: TGroupBox;
    Gauge7: TGauge;
    Gauge8: TGauge;
    Gauge9: TGauge;
    Gauge10: TGauge;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Gauge12: TGauge;
    Gauge13: TGauge;
    Gauge14: TGauge;
    Gauge15: TGauge;
    Gauge16: TGauge;
    Button5: TButton;
    Gauge11: TGauge;
    RadioButton11: TRadioButton;
    Edit11: TEdit;
    Memo5: TMemo;
    Button7: TButton;

    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure Button1Click(Sender: TObject);
    procedure IdUDPServer2UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure IdUDPServer3UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure IdUDPServer4UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton12Click(Sender: TObject);
    procedure RadioButton13Click(Sender: TObject);
    procedure RadioButton14Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton15Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RadioButton16Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Memo5Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);

  type
    // Run state record (reused across ports)
    TRunState = record
      Active: Boolean;
      LastPacketTimeMs: UInt64;
      PacketCount: Integer;
      NoiseCount: Integer;     // raw signature changed within run
      LastRawSig: Cardinal;
      GapSum: UInt64;
      GapCount: Integer;
    end;

    // 58091 kinds (for UI run tracking across all message types on that port)
    T58091Kind = (k91Referee, k91Avideo, k91Update, k91DRConfig, k91SBControl, k91Award, k91DiveRecorder, k91Unknown);

    // 58092 kinds
    T58092Kind = (k92Scoreboard, k92Hello, k92FoundServer, k92DBServer, k92DiveRecorder, k92Unknown);

    // 58093 kinds
    T58093Kind = (k93WebUpdate, k93ClearAB, k93StartResult, k93WebMessage, k93Unknown);

    // 58094 kinds
    T58094Kind = (k94Award, k94Unknown);

  private
    // === per-port "lastType/repeat" ===
    lastType1: string;
    repeatType1: Integer;

    lastType2: string;
    repeatType2: Integer;

    lastType3: string;
    repeatType3: Integer;

    lastType4: string;
    repeatType4: Integer;

    // === run state for all ports/kinds/origins ===
    RunState91: array[T58091Kind, 0..255] of TRunState;
    RunState92: array[T58092Kind, 0..255] of TRunState;
    RunState93: array[T58093Kind, 0..255] of TRunState;
    RunState94: array[T58094Kind, 0..255] of TRunState;

    // === Helpers ===
    function  Kind58091FromType(const T: string): T58091Kind;
    function  Kind58092FromType(const T: string): T58092Kind;
    function  Kind58093FromType(const T: string): T58093Kind;
    function  Kind58094FromType(const T: string): T58094Kind;

    function  ExpectedBurstFor58091(K: T58091Kind): Integer;
    function  ExpectedBurstFor58092(K: T58092Kind): Integer;
    function  ExpectedBurstFor58093(K: T58093Kind): Integer;
    function  ExpectedBurstFor58094(K: T58094Kind): Integer;

    procedure SetGaugeInProgress(G: TGauge);
    procedure ApplyGaugeFinal(G: TGauge; RunLen, Expected: Integer);

    procedure Set58091InProgress(K: T58091Kind);
    procedure Apply58091Final(K: T58091Kind; RunLen: Integer);

    procedure Set58092InProgress(K: T58092Kind);
    procedure Apply58092Final(K: T58092Kind; RunLen: Integer);

    procedure Set58093InProgress(K: T58093Kind);
    procedure Apply58093Final(K: T58093Kind; RunLen: Integer);
    procedure DebugLog(const S: string);
    procedure Set58094InProgress(K: T58094Kind);
    procedure Apply58094Final(K: T58094Kind; RunLen: Integer);

    procedure FlushAllRuns58091; // flushes UI run states too
    procedure FlushAllRuns58092;
    procedure FlushAllRuns58093;
    procedure FlushAllRuns58094;

  public
    // public counters/arrays

    // Port 58091
    c1, r1, u1, a1, d1, sb1, aw1, dr91, tot091 : integer;
    s1, s1Old : string;
    refereeArray1, avideoArray1, updateArray1, drconfigArray1, sbcontrolArray1, awardArray1, diverecorderArray1, splitString1 : TArray<string>;

    // Port 58092
    c2, f2, db2, h2, di2, sc2, tot092 : integer;
    s2, s2Old : string;
    scoreboardArray1, helloArray1, foundserverArray1, dbserverArray1, splitString2 : TArray<string>;

    // Port 58093
    c3, wu3, wm3, sr3, cl3, tot093 : integer;
    s3, s3Old : string;
    webupdateArray1, webmessageArray1, startresultArray1, clearABArray1, splitString3 : TArray<string>;

    // Port 58094
    c4, awd4, tot094 : integer;
    s4, s4Old : string;
    award2Array1, splitString4 : TArray<string>;

    value : integer;
    btnPressed : integer;
    arrayUnknown : TArray<string>;
  end;

var
  Form7: TForm7;

implementation

{$R *.dfm}

uses
  DiveDM,
  Hosts,
  Display,
  FormMetrics,
  MultiNIC;

const
  ORIGIN_UNKNOWN      = 255;
  BURST_TIMEOUT_MS    = 100;  // time gap that closes a run


  function mySplit(const input: string): TArray<string>;
begin
  Result := input.Split(['|'], TStringSplitOptions.None);
end;

function HashOfString(const S: string): Cardinal;
var
  i: Integer;
  h: Cardinal;
begin
  h := $811C9DC5;             // FNV offset basis
  for i := 1 to Length(S) do
  begin
    h := h xor Ord(S[i]);
    h := h * 16777619;        // FNV prime
  end;
  Result := h;
end;

function NowMs: UInt64;
begin
  Result := GetTickCount64;
end;

function CountFields(const S: string): Integer;
var
  i: Integer;
begin
  if S = '' then
    Exit(0);

  Result := 1;
  for i := 1 to Length(S) do
    if S[i] = '|' then
      Inc(Result);
end;

function OriginFromFields(const Fields: TArray<string>; out OriginLabel: string): Integer;
var
  i: Integer;
  SenderId: string;
  o: Integer;
begin
  Result := ORIGIN_UNKNOWN;
  OriginLabel := '';

  if Length(Fields) > 2 then
  begin
    SenderId := Fields[2];
    if SenderId <> '' then
    begin
      o := 0;
      for i := 1 to Length(SenderId) do
        o := (o * 33 + Ord(SenderId[i])) and $FF;
      Result := o;
      OriginLabel := SenderId;
    end;
  end;
end;

procedure TForm7.DebugLog(const S: string);
begin
  TThread.Queue(nil,
    procedure
    begin
      if (Form7 = nil) or (csDestroying in Form7.ComponentState) then Exit;

      Memo5.Lines.Add(S);

      // keep it from growing forever
      while Memo5.Lines.Count > 10000 do
        Memo5.Lines.Delete(0);
    end);
end;

function Clamp12(N: Integer): Integer;
begin
  if N > 12 then Result := 12 else Result := N;
end;

{ ===== Kind mapping ===== }
function TForm7.Kind58091FromType(const T: string): T58091Kind;
begin
  if      SameText(T, 'REFEREE')      then Result := k91Referee
  else if SameText(T, 'AVIDEO')       then Result := k91Avideo
  else if SameText(T, 'UPDATE')       then Result := k91Update
  else if SameText(T, 'DRCONFIG')     then Result := k91DRConfig
  else if SameText(T, 'SBCONTROL')    then Result := k91SBControl
  else if SameText(T, 'AWARD')        then Result := k91Award
  else if Sametext(T, 'DIVERECORDER') then Result := k91DiveRecorder
  else Result := k91Unknown;
end;

function TForm7.Kind58092FromType(const T: string): T58092Kind;
begin
  if      SameText(T, 'SCOREBOARD')   then Result := k92Scoreboard
  else if SameText(T, 'HELLO')        then Result := k92Hello
  else if SameText(T, 'FOUNDSERVER')  then Result := k92FoundServer
  else if SameText(T, 'DBSERVER')     then Result := k92DBServer
  else Result := k92Unknown;
end;

function TForm7.Kind58093FromType(const T: string): T58093Kind;
begin
  if      SameText(T, 'WEBUPDATE')    then Result := k93WebUpdate
  else if SameText(T, 'CLEAR_A') or SameText(T, 'CLEAR_B') then Result := k93ClearAB
  else if SameText(T, 'STARTRESULT')  then Result := k93StartResult
  else if SameText(T, 'WEBMESSAGE')   then Result := k93WebMessage
  else Result := k93Unknown;
end;

function TForm7.Kind58094FromType(const T: string): T58094Kind;
begin
  if    SameText(T, 'AWARD')    then Result := k94Award
  else Result := k94Unknown;
end;

procedure TForm7.Memo5Change(Sender: TObject);
begin

end;

{ ===== Expected burst counts =====
  NOTE: You can refine these later per message type.
  For now we assume "3 is healthy" across types.   }

function TForm7.ExpectedBurstFor58091(K: T58091Kind): Integer;
begin
  Result := 3;
end;

function TForm7.ExpectedBurstFor58092(K: T58092Kind): Integer;
begin
  Result := 3;
end;

function TForm7.ExpectedBurstFor58093(K: T58093Kind): Integer;
begin
  Result := 3;
end;

function TForm7.ExpectedBurstFor58094(K: T58094Kind): Integer;
begin
  Result := 3;
end;

{ ===== Gauge colouring ===== }

procedure TForm7.SetGaugeInProgress(G: TGauge);
begin
  // "Run has started" visual cue
  G.ForeColor := clAqua;
end;

procedure TForm7.ApplyGaugeFinal(G: TGauge; RunLen, Expected: Integer);
begin
  G.Progress := Clamp12(RunLen);

  if RunLen >= Expected then
    G.ForeColor := clLime
  else if RunLen = Expected - 1 then
    G.ForeColor := clYellow
  else
    G.ForeColor := clRed;

  G.Update;      // repaint now!
end;

{ ===== Port-specific gauge mapping ===== }

procedure TForm7.Set58091InProgress(K: T58091Kind);
begin
  case K of
    k91Referee:       SetGaugeInProgress(Gauge1);
    k91Avideo:        SetGaugeInProgress(Gauge2);
    k91Update:        SetGaugeInProgress(Gauge3);
    k91DRConfig:      SetGaugeInProgress(Gauge4);
    k91SBControl:     SetGaugeInProgress(Gauge5);
    k91Award:         SetGaugeInProgress(Gauge6);
    k91DiveRecorder:  SetGaugeInProgress(Gauge11);
    else
    ;      // unknown so ignored
  end;
end;

procedure TForm7.Apply58091Final(K: T58091Kind; RunLen: Integer);
begin
  case K of
    k91Referee:       ApplyGaugeFinal(Gauge1,  RunLen, ExpectedBurstFor58091(K));
    k91Avideo:        ApplyGaugeFinal(Gauge2,  RunLen, ExpectedBurstFor58091(K));
    k91Update:        ApplyGaugeFinal(Gauge3,  RunLen, ExpectedBurstFor58091(K));
    k91DRConfig:      ApplyGaugeFinal(Gauge4,  RunLen, ExpectedBurstFor58091(K));
    k91SBControl:     ApplyGaugeFinal(Gauge5,  RunLen, ExpectedBurstFor58091(K));
    k91Award:         ApplyGaugeFinal(Gauge6,  RunLen, ExpectedBurstFor58091(K));
    k91DiveRecorder:  ApplyGaugeFinal(Gauge11, RunLen, ExpectedBurstFor58091(K));
  else
  ;
  end;
end;

procedure TForm7.Set58092InProgress(K: T58092Kind);
begin
  case K of
    k92Scoreboard:   SetGaugeInProgress(Gauge7);
    k92Hello:        SetGaugeInProgress(Gauge8);
    k92FoundServer:  SetGaugeInProgress(Gauge9);
    k92DBServer:     SetGaugeInProgress(Gauge10);
  else
    ;
  end;
end;

procedure TForm7.Apply58092Final(K: T58092Kind; RunLen: Integer);
begin
  case K of
    k92Scoreboard:   ApplyGaugeFinal(Gauge7,  RunLen, ExpectedBurstFor58092(K));
    k92Hello:        ApplyGaugeFinal(Gauge8,  RunLen, ExpectedBurstFor58092(K));
    k92FoundServer:  ApplyGaugeFinal(Gauge9,  RunLen, ExpectedBurstFor58092(K));
    k92DBServer:     ApplyGaugeFinal(Gauge10, RunLen, ExpectedBurstFor58092(K));
  else
    ;
  end;
end;

procedure TForm7.Set58093InProgress(K: T58093Kind);
begin
  case K of
    k93WebUpdate:   SetGaugeInProgress(Gauge12);
    k93ClearAB:     SetGaugeInProgress(Gauge13);
    k93StartResult: SetGaugeInProgress(Gauge14);
    k93WebMessage:  SetGaugeInProgress(Gauge15);
  else
    ;
  end;
end;

procedure TForm7.Apply58093Final(K: T58093Kind; RunLen: Integer);
begin
  case K of
    k93WebUpdate:   ApplyGaugeFinal(Gauge12, RunLen, ExpectedBurstFor58093(K));
    k93ClearAB:     ApplyGaugeFinal(Gauge13, RunLen, ExpectedBurstFor58093(K));
    k93StartResult: ApplyGaugeFinal(Gauge14, RunLen, ExpectedBurstFor58093(K));
    k93WebMessage:  ApplyGaugeFinal(Gauge15, RunLen, ExpectedBurstFor58093(K));
  else
    ;
  end;
end;

procedure TForm7.Set58094InProgress(K: T58094Kind);
begin
  case K of
    k94Award: SetGaugeInProgress(Gauge16);
  else
    ;
  end;
end;

procedure TForm7.Apply58094Final(K: T58094Kind; RunLen: Integer);
begin
  case K of
    k94Award: ApplyGaugeFinal(Gauge16, RunLen, ExpectedBurstFor58094(K));
  else
    ;
  end;
end;

{ ===== Flush methods =====
  Called on disconnect/destroy to close active runs and force a final colour. }

procedure TForm7.FlushAllRuns58091;
var
  k: T58091Kind;
  o: Integer;
  S: ^TRunState;
begin
  for k := Low(T58091Kind) to High(T58091Kind) do
    for o := 0 to 255 do
    begin
      S := @RunState91[k, o];
      if S^.Active and (S^.PacketCount > 0) then
      begin
        Apply58091Final(k, S^.PacketCount);
        S^.Active := False;
        S^.PacketCount := 0;
        S^.NoiseCount := 0;
        S^.LastRawSig := 0;
        S^.LastPacketTimeMs := 0;
      end;
    end;
end;

procedure TForm7.FlushAllRuns58092;
var
  k: T58092Kind;
  o: Integer;
  S: ^TRunState;
begin
  for k := Low(T58092Kind) to High(T58092Kind) do
    for o := 0 to 255 do
    begin
      S := @RunState92[k, o];
      if S^.Active and (S^.PacketCount > 0) then
      begin
        Apply58092Final(k, S^.PacketCount);
        S^.Active := False;
        S^.PacketCount := 0;
        S^.NoiseCount := 0;
        S^.LastRawSig := 0;
        S^.LastPacketTimeMs := 0;
      end;
    end;
end;

procedure TForm7.FlushAllRuns58093;
var
  k: T58093Kind;
  o: Integer;
  S: ^TRunState;
begin
  for k := Low(T58093Kind) to High(T58093Kind) do
    for o := 0 to 255 do
    begin
      S := @RunState93[k, o];
      if S^.Active and (S^.PacketCount > 0) then
      begin
        Apply58093Final(k, S^.PacketCount);
        S^.Active := False;
        S^.PacketCount := 0;
        S^.NoiseCount := 0;
        S^.LastRawSig := 0;
        S^.LastPacketTimeMs := 0;
      end;
    end;
end;

procedure TForm7.FlushAllRuns58094;
var
  k: T58094Kind;
  o: Integer;
  S: ^TRunState;
begin
  for k := Low(T58094Kind) to High(T58094Kind) do
    for o := 0 to 255 do
    begin
      S := @RunState94[k, o];
      if S^.Active and (S^.PacketCount > 0) then
      begin
        Apply58094Final(k, S^.PacketCount);
        S^.Active := False;
        S^.PacketCount := 0;
        S^.NoiseCount := 0;
        S^.LastRawSig := 0;
        S^.LastPacketTimeMs := 0;
      end;
    end;
end;

procedure TForm7.Button3Click(Sender: TObject);           // Reset
begin
  // --- Stop any �in-progress� runs cleanly (optional, but keeps colours consistent) ---
  FlushAllRuns58091;
  FlushAllRuns58092;
  FlushAllRuns58093;
  FlushAllRuns58094;

  // --- Reset ALL counters ---
  // Port 58091
  r1 := 0; a1 := 0; u1 := 0; d1 := 0; sb1 := 0; aw1 := 0; dr91 := 0; tot091 := 0;

  // Port 58092
  sc2 := 0; h2 := 0; f2 := 0; db2 := 0; di2 := 0; tot092 := 0;

  // Port 58093
  wu3 := 0; wm3 := 0; sr3 := 0; cl3 := 0; tot093 := 0;

  // Port 58094
  awd4 := 0; tot094 := 0;

  // --- Reset Edit boxes (per mapping in the UDPRead handlers) ---
  // 58091 edits
  Edit1.Text := '0';   // r1 REFEREE
  Edit2.Text := '0';   // a1 AVIDEO
  Edit3.Text := '0';   // u1 UPDATE
  Edit4.Text := '0';   // d1 DRCONFIG
  Edit5.Text := '0';   // sb1 SBCONTROL
  Edit6.Text := '0';   // aw1 AWARD
  Edit11.Text := '0';  // di2 DIVERECORDER    *** was on port 58093

  // 58092 edits
  Edit7.Text := '0';   // sc2 SCOREBOARD
  Edit8.Text := '0';   // h2 HELLO
  Edit9.Text := '0';   // f2 FOUNDSERVER
  Edit10.Text := '0';  // db2 DBSERVER

  // 58093 edits
  Edit12.Text := '0';  // wu3 WEBUPDATE
  Edit13.Text := '0';  // wm3 WEBMESSAGE
  Edit14.Text := '0';  // sr3 STARTRESULT
  Edit17.Text := '0';  // cl3 CLEAR_A/B

  // 58094 edits
  Edit15.Text := '0';  // awd4 AWARD

  // Status
  Edit16.Text := 'Status: All Hosts';

  // --- Reset per-port packet labels ---
  Label7.Caption  := '0 Packets';
  Label8.Caption  := '0 Packets';
  Label9.Caption  := '0 Packets';
  Label10.Caption := '0 Packets';

  // --- Clear memo logs ---
  Memo1.Clear;
  Memo2.Clear;
  Memo3.Clear;
  Memo4.Clear;

  // --- Reset ALL gauges (1..16) ---
  Gauge1.Progress := 0;  Gauge1.ForeColor := clBlue;
  Gauge2.Progress := 0;  Gauge2.ForeColor := clBlue;
  Gauge3.Progress := 0;  Gauge3.ForeColor := clBlue;
  Gauge4.Progress := 0;  Gauge4.ForeColor := clBlue;
  Gauge5.Progress := 0;  Gauge5.ForeColor := clBlue;
  Gauge6.Progress := 0;  Gauge6.ForeColor := clBlue;
  Gauge7.Progress := 0;  Gauge7.ForeColor := clBlue;
  Gauge8.Progress := 0;  Gauge8.ForeColor := clBlue;
  Gauge9.Progress := 0;  Gauge9.ForeColor := clBlue;
  Gauge10.Progress := 0; Gauge10.ForeColor := clBlue;
  Gauge11.Progress := 0; Gauge11.ForeColor := clBlue;
  Gauge12.Progress := 0; Gauge12.ForeColor := clBlue;
  Gauge13.Progress := 0; Gauge13.ForeColor := clBlue;
  Gauge14.Progress := 0; Gauge14.ForeColor := clBlue;
  Gauge15.Progress := 0; Gauge15.ForeColor := clBlue;
  Gauge16.Progress := 0; Gauge16.ForeColor := clBlue;

  // --- Reset run state arrays ---
  FillChar(RunState91, SizeOf(RunState91), 0);
  FillChar(RunState92, SizeOf(RunState92), 0);
  FillChar(RunState93, SizeOf(RunState93), 0);
  FillChar(RunState94, SizeOf(RunState94), 0);

  // --- Reset �last message / repeat� tracking ---
  lastType1 := ''; repeatType1 := 0; s1Old := '';
  lastType2 := ''; repeatType2 := 0; s2Old := '';
  lastType3 := ''; repeatType3 := 0; s3Old := '';
  lastType4 := ''; repeatType4 := 0; s4Old := '';

  // --- Clear discovered host cache ---
  if HostNameList <> nil then HostNameList.Clear;
end;

procedure TForm7.Button4Click(Sender: TObject);        // Hosts
begin
  if not Assigned(frmHosts) then
    frmHosts := TfrmHosts.Create(Self);
  frmHosts.Show;
end;

procedure TForm7.Button5Click(Sender: TObject);       // Metrics
begin
  if Metrics = nil then Metrics := TMetrics.Create(Self);
  Metrics.Show;
end;

procedure TForm7.Button6Click(Sender: TObject);       // DR Display
begin
  if not Assigned(frmDisplay) then
    frmDisplay := TfrmDisplay.Create(Self);
  frmDisplay.Show;
end;

procedure TForm7.Button7Click(Sender: TObject);       // debug
begin
    // add here
end;

procedure BindUDPServer(Server: TIdUDPServer; Port: Integer);
var
  AddrList: TIdStackLocalAddressList;
  i: Integer;
  B: TIdSocketHandle;
begin
  Server.Active := False;
  Server.Bindings.Clear;

  AddrList := TIdStackLocalAddressList.Create;
  try
    GStack.GetLocalAddressList(AddrList);

    for i := 0 to AddrList.Count - 1 do
    begin
      // IPv4 only
      if AddrList[i].IPVersion = Id_IPv4 then
      begin
        // Skip loopback if you want
        if AddrList[i].IPAddress <> '127.0.0.1' then
        begin
          B := Server.Bindings.Add;
          B.IP := AddrList[i].IPAddress;
          B.Port := Port;
          B.IPVersion := Id_IPv4;
        end;
      end;
    end;
  finally
    AddrList.Free;
  end;
  for i := 0 to Server.Bindings.Count - 1 do
    Form7.Memo5.Lines.Add('Listening on ' + Server.Bindings[i].IP + ':' + IntToStr(Port));
  Server.BroadcastEnabled := True;
  Server.Active := True;
end;

procedure TForm7.FormCreate(Sender: TObject);
begin
  InitMetrics58091;
  btnPressed := 1;
  Edit16.text := 'Status: All Hosts';
  FillChar(RunState91, SizeOf(RunState91), 0);
  FillChar(RunState92, SizeOf(RunState92), 0);
  FillChar(RunState93, SizeOf(RunState93), 0);
  FillChar(RunState94, SizeOf(RunState94), 0);

  lastType1 := ''; repeatType1 := 0; s1Old := '';
  lastType2 := ''; repeatType2 := 0; s2Old := '';
  lastType3 := ''; repeatType3 := 0; s3Old := '';
  lastType4 := ''; repeatType4 := 0; s4Old := '';
end;

procedure TForm7.FormDestroy(Sender: TObject);
begin
  IdUDPServer1.Active := False;
  FlushAllRuns58091;

  IdUDPServer2.Active := False;
  FlushAllRuns58092;

  IdUDPServer3.Active := False;
  FlushAllRuns58093;

  IdUDPServer4.Active := False;
  FlushAllRuns58094;
end;

procedure TForm7.Button1Click(Sender: TObject);      // Connect to Ports

begin
  if IdUDPServer1.Active or IdUDPServer2.Active or
     IdUDPServer3.Active or IdUDPServer4.Active then
  begin
    IdUDPServer1.Active := False;
    FlushAllRuns58091;
    IdUDPServer1.Bindings.Clear;

    IdUDPServer2.Active := False;
    FlushAllRuns58092;
    IdUDPServer2.Bindings.Clear;

    IdUDPServer3.Active := False;
    FlushAllRuns58093;
    IdUDPServer3.Bindings.Clear;

    IdUDPServer4.Active := False;
    FlushAllRuns58094;
    IdUDPServer4.Bindings.Clear;

    Label2.Caption := 'Not Attached';
    Button1.Caption := 'Connect';
    Exit;
  end;

  BindUDPServer(IdUDPServer1, 58091);
  BindUDPServer(IdUDPServer2, 58092);
  BindUDPServer(IdUDPServer3, 58093);
  BindUDPServer(IdUDPServer4, 58094);

  Label2.Caption := 'Attached to 4 UDP ports!';
  Button1.Caption := 'Disconnect';

end;

procedure TForm7.Button2Click(Sender: TObject);
begin
  Form2.show;
end;

// decode selection
procedure TForm7.RadioButton10Click(Sender: TObject); begin btnPressed := 10; end;
procedure TForm7.RadioButton11Click(Sender: TObject); begin btnPressed := 11; end;
procedure TForm7.RadioButton12Click(Sender: TObject); begin btnPressed := 12; end;
procedure TForm7.RadioButton13Click(Sender: TObject); begin btnPressed := 13; end;
procedure TForm7.RadioButton14Click(Sender: TObject); begin btnPressed := 14; end;
procedure TForm7.RadioButton15Click(Sender: TObject); begin btnPressed := 15; end;
procedure TForm7.RadioButton16Click(Sender: TObject); begin btnPressed := 16; end;
procedure TForm7.RadioButton1Click(Sender: TObject);  begin btnPressed := 1;  end;
procedure TForm7.RadioButton2Click(Sender: TObject);  begin btnPressed := 2;  end;
procedure TForm7.RadioButton3Click(Sender: TObject);  begin btnPressed := 3;  end;
procedure TForm7.RadioButton4Click(Sender: TObject);  begin btnPressed := 4;  end;
procedure TForm7.RadioButton5Click(Sender: TObject);  begin btnPressed := 5;  end;
procedure TForm7.RadioButton6Click(Sender: TObject);  begin btnPressed := 6;  end;
procedure TForm7.RadioButton7Click(Sender: TObject);  begin btnPressed := 7;  end;
procedure TForm7.RadioButton8Click(Sender: TObject);  begin btnPressed := 8;  end;
procedure TForm7.RadioButton9Click(Sender: TObject);  begin btnPressed := 9;  end;


{ ========================= }
{ Port 58091 receive        }
{ ========================= }

procedure TForm7.IdUDPServer1UDPRead(
  AThread: TIdUDPListenerThread;
  const AData: TIdBytes;
  ABinding: TIdSocketHandle);
var
  Raw: string;
  PeerIP: string;
  PeerPort: Integer;
  SameMsg: Boolean;
  thisType: string;

  Fields: TArray<string>;
  KindUI: T58091Kind;

  MetricsKind: T58091MsgKind;
  IsMetricsType: Boolean;

  FieldCount1, CharCount1: Integer;

  Origin: Integer;
  OriginLabel: string;

  caretPos: Integer;
  caretAtEnd: Boolean;
  caretNotAtEnd: Boolean;

  tNow: UInt64;
  rawSig: Cardinal;

  S: ^TRunState;

  StartedNewRun: Boolean;
  CommittedRunLen: Integer;
  CommittedKind: T58091Kind;
begin
  if not HandleAllocated then Exit;
  if (Form7 = nil) or (csDestroying in Form7.ComponentState) then Exit;

  // RAW DATA
  Raw := Trim(BytesToString(AData, IndyTextEncoding_UTF8));

  // Display still fed (intentional � do not restrict)
  if Assigned(frmDisplay) then
    frmDisplay.FeedUdpText(Raw);
//  if debug then Memo5.Lines.Add('Rx on 58091: ' + Raw);

  PeerIP := ABinding.PeerIP;
  PeerPort := ABinding.PeerPort;

  Inc(tot091);

  SameMsg := (Raw = s1Old);
  s1Old := Raw;

  splitString1 := mySplit(Raw);
  if Length(splitString1) = 0 then Exit;

  thisType := splitString1[0];
  Fields := splitString1;

  FieldCount1 := Length(Fields);
  CharCount1 := Length(Raw);

  // HANDLE DIVERECORDER PACKET SEPARATELY (Host Discovery ONLY)
  if SameText(thisType, 'DIVERECORDER') then
  begin
    if Length(splitString1) > 1 then
    begin
      var host := Trim(splitString1[1]);

      // strip EoM if it leaked into field (HP-1040^)
      var p := Pos('^', host);
      if p > 0 then
        host := Copy(host, 1, p-1);

      host := Trim(host);

      if host <> '' then
      begin
        if HostNameList = nil then
          HostNameList := TStringList.Create;

        var baseHost := host;
        var displayName := host + ' (' + PeerIP + ')';
        var i: Integer;
        var found := False;

        // check if host already exists (with IP)
        begin
        baseHost := host;
        displayName := host + ' (' + PeerIP + ')';

        for i := HostNameList.Count - 1 downto 0 do
          if StartsText(baseHost, HostNameList[i]) then
            HostNameList.Delete(i);
        HostNameList.Add(displayName);
        end;

        if not found then
          HostNameList.Add(displayName);
        end;
      end;
   end;

  // Origin handling
  Origin := OriginFromFields(Fields, OriginLabel);
  if OriginLabel <> '' then
    Metrics58091Identity[Origin] := OriginLabel;

  // Determine message type
  KindUI := Kind58091FromType(thisType);

  // Metrics types only
  IsMetricsType := False;
  if SameText(thisType, 'REFEREE') then
  begin
    MetricsKind := mkReferee;
    IsMetricsType := True;
  end
  else if SameText(thisType, 'UPDATE') then
  begin
    MetricsKind := mkUpdate;
    IsMetricsType := True;
  end;

  // Integrity checks ONLY for metrics types
  if IsMetricsType then
  begin
    caretPos := LastDelimiter('^', Raw);
    caretAtEnd := (caretPos > 0) and (caretPos = Length(Raw));
    caretNotAtEnd := (caretPos > 0) and (caretPos <> Length(Raw));

    if not caretAtEnd then
      Metrics58091_IncIncomplete(MetricsKind, Origin);

    if caretNotAtEnd then
      Metrics58091_IncCorrupt(MetricsKind, Origin);
  end;

  // =========================
  // Run tracking
  // =========================

  StartedNewRun := False;
  CommittedRunLen := 0;
  CommittedKind := KindUI;

  tNow := NowMs;
  rawSig := HashOfString(Raw);

  if KindUI <> k91Unknown then
  begin
    S := @RunState91[KindUI, Origin];

    // --- timeout closes run
    if S^.Active and ((tNow - S^.LastPacketTimeMs) > BURST_TIMEOUT_MS) then
    begin
      if S^.PacketCount > 0 then
      begin
        CommittedRunLen := S^.PacketCount;
        CommittedKind := KindUI;

        if IsMetricsType then
        begin
          Metrics58091_AddRun(MetricsKind, Origin, S^.PacketCount);

          if S^.GapCount > 0 then
          begin
            var avgGap := S^.GapSum div S^.GapCount;
            Metrics58091_ObserveGap(MetricsKind, Origin, avgGap);
          end;
        end;

      end;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.GapSum := 0;
      S^.GapCount := 0;
      S^.LastPacketTimeMs := 0;
    end;

    // --- start or continue run
    if not S^.Active then
    begin
      StartedNewRun := True;
      S^.Active := True;
      S^.PacketCount := 1;
      S^.NoiseCount := 0;
      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end
    else
    begin
      Inc(S^.PacketCount);

    // --- accumulate burst gap ONLY within same burst
    if IsMetricsType and (S^.LastPacketTimeMs <> 0) then
    begin
      var gap := tNow - S^.LastPacketTimeMs;

        // ONLY count gaps that are still within THIS burst
        if gap < BURST_TIMEOUT_MS then
        begin
          Inc(S^.GapCount);
          S^.GapSum := S^.GapSum + gap;
        end;
    end;

      if rawSig <> S^.LastRawSig then
        Inc(S^.NoiseCount);

      S^.LastRawSig := rawSig;

      // now update timestamp
      S^.LastPacketTimeMs := tNow;
    end;

    // --- early commit rule
    if (S^.PacketCount >= ExpectedBurstFor58091(KindUI)) then
    begin
      if IsMetricsType then
        begin
          Metrics58091_AddRun(MetricsKind, Origin, S^.PacketCount);

          // --- calculate average gap for this burst
          if S^.GapCount > 0 then
          begin
            var avgGap := S^.GapSum div S^.GapCount;
            Metrics58091_ObserveGap(MetricsKind, Origin, avgGap);
          end;
        end;

      CommittedRunLen := S^.PacketCount;
      CommittedKind := KindUI;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.GapSum := 0;
      S^.GapCount := 0;
    end;
  end;

  // ================================
  // UI UPDATE � STRICTLY 58091 ONLY
  // ================================

  TThread.Queue(nil,
    procedure
    begin
      if (Form7 = nil) or (csDestroying in Form7.ComponentState) then Exit;


      // ? ONLY Memo1 used here
      if not SameMsg then
        Memo1.Lines.Add(
          'From ' + PeerIP + ':' + IntToStr(PeerPort) +
          ', Fields: ' + IntToStr(FieldCount1) +
          ', Chars: ' + IntToStr(CharCount1) +
          sLineBreak + Raw + sLineBreak
        );

      // Counters (58091 ONLY)
      if thisType = 'REFEREE' then
      begin
        Inc(r1);
        Edit1.Text := IntToStr(r1);
        refereeArray1 := splitString1;
        if not samemsg then if btnPressed = 1 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'AVIDEO' then
      begin
        Inc(a1);
        Edit2.Text := IntToStr(a1);
        avideoArray1 := splitString1;
        if not samemsg then if btnPressed = 2 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'UPDATE' then
      begin
        Inc(u1);
        Edit3.Text := IntToStr(u1);
        updateArray1 := splitString1;
        if not samemsg then if btnPressed = 3 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'DRCONFIG' then
      begin
        Inc(d1);
        Edit4.Text := IntToStr(d1);
        drconfigArray1 := splitString1;
        if not samemsg then if btnPressed = 4 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'SBCONTROL' then
      begin
        Inc(sb1);
        Edit5.Text := IntToStr(sb1);
        sbcontrolArray1 := splitString1;
        if not samemsg then if btnPressed = 5 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'AWARD' then
      begin
        Inc(aw1);
        Edit6.Text := IntToStr(aw1);
        awardArray1 := splitString1;
        if not samemsg then if btnPressed = 6 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if SameText(thisType, 'DIVERECORDER') then
      begin
        Inc(dr91);
        Edit11.Text := IntToStr(dr91);
        if not samemsg then if btnPressed = 11 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end;
      Label7.Caption := IntToStr(tot091) + ' Packets';

      if StartedNewRun then
        Set58091InProgress(KindUI);

      if CommittedRunLen > 0 then
        Apply58091Final(CommittedKind, CommittedRunLen);

      if Assigned(Metrics) and (CommittedRunLen > 0) then
        Metrics.RefreshForPort58091;
  end);

end;


{ ========================= }
{ Port 58092 receive        }
{ ========================= }
procedure TForm7.IdUDPServer2UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  Raw: string;
  PeerIP: string;
  PeerPort: Integer;
  SameMsg: Boolean;
  thisType: string;

  Kind: T58092Kind;
  Fields: TArray<string>;
  Origin: Integer;
  OriginLabel: string;

  tNow: UInt64;
  rawSig: Cardinal;
  S: ^TRunState;

  StartedNewRun: Boolean;
  CommittedRunLen: Integer;
  CommittedKind: T58092Kind;
begin
  if not HandleAllocated then Exit;
  if (Form7 = nil) or (csDestroying in Form7.ComponentState) then Exit;

  Raw := Trim(BytesToString(AData, IndyTextEncoding_UTF8));
  if Assigned(frmDisplay) then frmDisplay.FeedUdpText(Raw);

  PeerIP := ABinding.PeerIP;
  PeerPort := ABinding.PeerPort;

  Inc(tot092);

 // if debug then Memo5.Lines.Add('Rx on 58092: ' + Raw);
  if Memo5.Lines.Count > 10000 then Memo5.Lines.Delete(0);


  SameMsg := (Raw = s2Old);
  s2Old := Raw;

 //if not SameMsg then
    splitString2 := mySplit(Raw);

  if Length(splitString2) = 0 then Exit;
  thisType := splitString2[0];

  Kind := Kind58092FromType(thisType);

  StartedNewRun := False;
  CommittedRunLen := 0;
  CommittedKind := Kind;

  Fields := splitString2;
  Origin := OriginFromFields(Fields, OriginLabel);

  tNow := NowMs;
  rawSig := HashOfString(Raw);

  if Kind <> k92Unknown then
  begin
    S := @RunState92[Kind, Origin];

    if S^.Active and ((tNow - S^.LastPacketTimeMs) > BURST_TIMEOUT_MS) then
    begin
      if S^.PacketCount > 0 then
      begin
        CommittedRunLen := S^.PacketCount;
        CommittedKind := Kind;
      end;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.LastPacketTimeMs := 0;
    end;

    if not S^.Active then
    begin
      StartedNewRun := True;
      S^.Active := True;
      S^.PacketCount := 1;
      S^.NoiseCount := 0;
      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end
    else
    begin
      Inc(S^.PacketCount);
      if rawSig <> S^.LastRawSig then
        Inc(S^.NoiseCount);

      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end;

    // Immediate commit at expected threshold to avoid "stuck aqua"
    if S^.Active and (S^.PacketCount >= ExpectedBurstFor58092(Kind)) then
    begin
      CommittedRunLen := S^.PacketCount;
      CommittedKind := Kind;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.LastPacketTimeMs := 0;
    end;
  end;

  TThread.Queue(nil,
    procedure
    begin
      if StartedNewRun then
        Set58092InProgress(Kind);

      if CommittedRunLen > 0 then
        Apply58092Final(CommittedKind, CommittedRunLen);

      if not SameMsg then
        Memo2.Lines.Add('From ' + PeerIP + ' Port: ' + IntToStr(PeerPort) +
                        sLineBreak + Raw + sLineBreak);

      if thisType = 'SCOREBOARD' then
      begin
        Inc(sc2); Edit7.Text := IntToStr(sc2); scoreboardArray1 := splitString2;
        if not samemsg then if btnPressed = 7 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'HELLO' then
      begin
        Inc(h2); Edit8.Text := IntToStr(h2); helloArray1 := splitString2;
        if not samemsg then if btnPressed = 8 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'FOUNDSERVER' then
      begin
        Inc(f2); Edit9.Text := IntToStr(f2); foundserverArray1 := splitString2;
        if not samemsg then if btnPressed = 9 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'DBSERVER' then
      begin
        Inc(db2); Edit10.Text := IntToStr(db2); dbserverArray1 := splitString2;
        if not samemsg then if btnPressed = 10 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end;

      Label8.Caption := IntToStr(tot092) + ' Packets';
  end);
end;

{ ========================= }
{ Port 58093 receive        }
{ ========================= }
procedure TForm7.IdUDPServer3UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  Raw: string;
  PeerIP: string;
  PeerPort: Integer;
  SameMsg: Boolean;
  thisType: string;

  Kind: T58093Kind;
  Fields: TArray<string>;
  Origin: Integer;
  OriginLabel: string;

  tNow: UInt64;
  rawSig: Cardinal;
  S: ^TRunState;

  StartedNewRun: Boolean;
  CommittedRunLen: Integer;
  CommittedKind: T58093Kind;
begin
  if not HandleAllocated then Exit;
  if (Form7 = nil) or (csDestroying in Form7.ComponentState) then Exit;

  Raw := Trim(BytesToString(AData, IndyTextEncoding_UTF8));
  PeerIP := ABinding.PeerIP;
  PeerPort := ABinding.PeerPort;

  Inc(tot093);

//  if debug then Memo5.Lines.Add('Rx on 58093: ' + Raw);

  SameMsg := (Raw = s3Old);
  s3Old := Raw;

  //if not SameMsg then
    splitString3 := mySplit(Raw);

  if Length(splitString3) = 0 then Exit;
  thisType := splitString3[0];

  Kind := Kind58093FromType(thisType);

  StartedNewRun := False;
  CommittedRunLen := 0;
  CommittedKind := Kind;

  Fields := splitString3;
  Origin := OriginFromFields(Fields, OriginLabel);

  tNow := NowMs;
  rawSig := HashOfString(Raw);

  if Kind <> k93Unknown then
  begin
    S := @RunState93[Kind, Origin];

    if S^.Active and ((tNow - S^.LastPacketTimeMs) > BURST_TIMEOUT_MS) then
    begin
      if S^.PacketCount > 0 then
      begin
        CommittedRunLen := S^.PacketCount;
        CommittedKind := Kind;
      end;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.LastPacketTimeMs := 0;
    end;

    if not S^.Active then
    begin
      StartedNewRun := True;
      S^.Active := True;
      S^.PacketCount := 1;
      S^.NoiseCount := 0;
      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end
    else
    begin
      Inc(S^.PacketCount);
      if rawSig <> S^.LastRawSig then
        Inc(S^.NoiseCount);

      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end;

    if S^.Active and (S^.PacketCount >= ExpectedBurstFor58093(Kind)) then
    begin
      CommittedRunLen := S^.PacketCount;
      CommittedKind := Kind;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.LastPacketTimeMs := 0;
    end;
  end;

  TThread.Queue(nil,
    procedure
    begin
      if StartedNewRun then
        Set58093InProgress(Kind);

      if CommittedRunLen > 0 then
        Apply58093Final(CommittedKind, CommittedRunLen);

      if not SameMsg then
        Memo3.Lines.Add('From ' + PeerIP + ' Port: ' + IntToStr(PeerPort) +
                        sLineBreak + Raw + sLineBreak);

      if thisType = 'WEBUPDATE' then
      begin
        Inc(wu3); Edit12.Text := IntToStr(wu3); webupdateArray1 := splitString3;
        if not samemsg then if btnPressed = 12 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if string(thisType) = 'CLEAR_A' then
      begin
        Inc(cl3); Edit17.Text := IntToStr(cl3); clearABArray1 := splitString3;
        if not samemsg then if btnPressed = 13 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if string(thisType) = 'CLEAR_B' then
      begin
        Inc(cl3); Edit17.Text := IntToStr(cl3); clearABArray1 := splitString3;
        if not samemsg then if btnPressed = 13 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'STARTRESULT' then
      begin
        Inc(sr3); Edit14.Text := IntToStr(sr3); startresultArray1 := splitString3;
        if not samemsg then if btnPressed = 14 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end
      else if thisType = 'WEBMESSAGE' then
      begin
        Inc(wm3); Edit13.Text := IntToStr(wm3); webmessageArray1 := splitString3;
        if not samemsg then if btnPressed = 15 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end;

      Label9.Caption := IntToStr(tot093) + ' Packets';

      if Form2.CheckBox1.Checked and (not SameMsg) then
        Form2.DecodeClick(nil);
    end);
end;

{ ========================= }
{ Port 58094 receive        }
{ ========================= }
procedure TForm7.IdUDPServer4UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  Raw: string;
  PeerIP: string;
  PeerPort: Integer;
  SameMsg: Boolean;
  thisType: string;

  Kind: T58094Kind;
  Fields: TArray<string>;
  Origin: Integer;
  OriginLabel: string;

  tNow: UInt64;
  rawSig: Cardinal;
  S: ^TRunState;

  StartedNewRun: Boolean;
  CommittedRunLen: Integer;
  CommittedKind: T58094Kind;
begin
  if not HandleAllocated then Exit;
  if (Form7 = nil) or (csDestroying in Form7.ComponentState) then Exit;

  Raw := Trim(BytesToString(AData, IndyTextEncoding_UTF8));
  PeerIP := ABinding.PeerIP;
  PeerPort := ABinding.PeerPort;

  Inc(tot094);

// if debug then Memo5.Lines.Add('Rx on 58094: ' + Raw);

  SameMsg := (Raw = s4Old);
  s4Old := Raw;

  // if not SameMsg then
    splitString4 := mySplit(Raw);

  if Length(splitString4) = 0 then Exit;
  thisType := splitString4[0];

  Kind := Kind58094FromType(thisType);

  StartedNewRun := False;
  CommittedRunLen := 0;
  CommittedKind := Kind;

  Fields := splitString4;
  Origin := OriginFromFields(Fields, OriginLabel);

  tNow := NowMs;
  rawSig := HashOfString(Raw);

  if Kind <> k94Unknown then
  begin
    S := @RunState94[Kind, Origin];

    if S^.Active and ((tNow - S^.LastPacketTimeMs) > BURST_TIMEOUT_MS) then
    begin
      if S^.PacketCount > 0 then
      begin
        CommittedRunLen := S^.PacketCount;
        CommittedKind := Kind;
      end;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.LastPacketTimeMs := 0;
    end;

    if not S^.Active then
    begin
      StartedNewRun := True;
      S^.Active := True;
      S^.PacketCount := 1;
      S^.NoiseCount := 0;
      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end
    else
    begin
      Inc(S^.PacketCount);
      if rawSig <> S^.LastRawSig then
        Inc(S^.NoiseCount);

      S^.LastRawSig := rawSig;
      S^.LastPacketTimeMs := tNow;
    end;

    if S^.Active and (S^.PacketCount >= ExpectedBurstFor58094(Kind)) then
    begin
      CommittedRunLen := S^.PacketCount;
      CommittedKind := Kind;

      S^.Active := False;
      S^.PacketCount := 0;
      S^.NoiseCount := 0;
      S^.LastRawSig := 0;
      S^.LastPacketTimeMs := 0;
    end;
  end;

  TThread.Queue(nil,
    procedure
    begin
      if StartedNewRun then
        Set58094InProgress(Kind);

      if CommittedRunLen > 0 then
        Apply58094Final(CommittedKind, CommittedRunLen);

      if not SameMsg then
        Memo4.Lines.Add('From ' + PeerIP + ':' + IntToStr(PeerPort) +
                        sLineBreak + Raw + sLineBreak);

      if thisType = 'AWARD' then
      begin
        Inc(awd4);
        Edit15.Text := IntToStr(awd4);
        award2Array1 := splitString4;
        if not samemsg then if btnPressed = 16 then if Form2.CheckBox1.checked then Form2.Decode.Click;
      end;

      Label10.Caption := IntToStr(tot094) + ' Packets';

      if Form2.CheckBox1.Checked and (not SameMsg) then
        Form2.DecodeClick(nil);
    end);
end;

end.
