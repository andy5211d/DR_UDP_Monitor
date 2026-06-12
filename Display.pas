{ ************************************* }
{ Copyright(c) 2007-2023 Malcolm Taylor }
{ Copyright(c) 2022-2026 Andy Hewat     }
{ Copyright(c) 2022-2026 Andy Hewat     }
{ ************************************* }

{
 A Unit for DR-UDP Monitor programme.
 Original from Malcolm's DR2Video app.

 2026-05-17 V1.1  Modified to 'share' UDP ports with Main unit.

 Needs a complete review and update as most of this code is not used in this app as
 the export function is not used (from original 'TV Video' file export).

}

{
 A Unit for DR-UDP Monitor programme.
 Original from Malcolm's DR2Video app.

 2026-05-17 V1.1  Modified to 'share' UDP ports with Main unit.

 Needs a complete review and update as most of this code is not used in this app as
 the export function is not used (from original 'TV Video' file export).

}

unit Display;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  System.StrUtils,
  Vcl.DBCtrls,
  Vcl.ExtCtrls,
  SiComp,
  SiLangRT,
  Data.DB,
  Edbcomps,
  Vcl.Mask,
  IdUDPServer,
  IdGlobal,
  IdSocketHandle,
  IdBaseComponent,
  IdComponent,
  IdUDPBase,
  IdException,
  IdTCPConnection,
  IdTCPClient;

type
  TfrmDisplay = class(TForm)
    EventTitle: TDBText;
    SN: TDBText;
    Lbl1: TLabel;
    DT: TDBText;
    Lbl2: TLabel;
    RN: TDBText;
    Lbl3: TLabel;
    RT: TDBText;
    Lbl4: TLabel;
    DiverAName: TDBText;
    TeamA: TDBText;
    DiverBName: TDBText;
    TeamB: TDBText;
    DiveNo: TDBText;
    FlightPos: TDBText;
    BHeight: TDBText;
    Label1: TLabel;
    DD: TDBText;
    J1: TDBText;
    J2: TDBText;
    J3: TDBText;
    J4: TDBText;
    J5: TDBText;
    J6: TDBText;
    J7: TDBText;
    J8: TDBText;
    J9: TDBText;
    J10: TDBText;
    J11: TDBText;
    PnlUnOfficial: TPanel;
    PnlOfficial: TPanel;
    UpdateTimer: TTimer;
    LblExec: TLabel;
    LblSynch: TLabel;
    LblJ1: TLabel;
    LblJ2: TLabel;
    LblJ3: TLabel;
    LblJ4: TLabel;
    LblJ5: TLabel;
    LblJ6: TLabel;
    LblJ7: TLabel;
    LblJ8: TLabel;
    LblJ9: TLabel;
    LblJ10: TLabel;
    LblJ11: TLabel;
    SiLang1: TsiLangRT;
    PnlPenalty: TPanel;
    PnlTV: TPanel;
    ReportQuery: TEDBQuery;
    Secs: TDBText;
    IdTCPClientXfer: TIdTCPClient;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure DoUpdate;
    procedure CompleteUpdate;
    procedure DoAward(Msg: string);
    procedure DoEndOfEvent(Msg: string);
    procedure DoTV;
    procedure FormCreate(Sender: TObject);
    procedure UDPServerUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure FormDestroy(Sender: TObject);
    procedure ExportToCSV(Fname: string);
    procedure HorizontalExport(Fname: string);
    procedure ExportToXML(Fname: string);
    procedure GetUpdateFile(Msg: string);
    procedure SiLang1LanguageChanging(Sender: TObject; const NewLanguage: Integer; var AllowChange: Boolean);


  private
    { Private declarations }
    procedure MakeRTL;
    procedure MakeLTR;
  public
    { Public declarations }
    procedure FeedUdpText(const RawMsg: string);
    procedure ProcessUdpText(const RawMsg: string);
    procedure FeedUdpText(const RawMsg: string);
    procedure ProcessUdpText(const RawMsg: string);
  end;

var
  FrmDisplay: TfrmDisplay;
  HostNameList: TStringList;

implementation

{$r *.dfm}

uses
  DiveDM,            // what is being used?   =   UDPServerPort,  FileTransferPort,  Language, DRHost, DataPath, LoadFromFile, DM,  ScoreBTable
  Main,
  XML.VerySimple;    // not actually used in the Monitor app!
  DiveDM,            // what is being used?   =   UDPServerPort,  FileTransferPort,  Language, DRHost, DataPath, LoadFromFile, DM,  ScoreBTable
  Main,
  XML.VerySimple;    // not actually used in the Monitor app!

const
  Sep: string = '|'; // This is for file xfer processing
  NoScore = 4096;    // magic number indicating no total score
  NoRank  = 1000;    // magic number indicating no ranking
  AnEncoding: String = ('TEncoding.ANSI');
  NoScore = 4096;    // magic number indicating no total score
  NoRank  = 1000;    // magic number indicating no ranking
  AnEncoding: String = ('TEncoding.ANSI');

var
  MessageList: TStringList;
  Official, Synchro, AllDone, IsFlipped, TransferringData: Boolean;
  NumberOfJudges, ListInterval: Integer;
  EventB: string;

procedure TfrmDisplay.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  UDPServer.Active := False;
//  UDPServer.Active := False;
end;

procedure TfrmDisplay.FormCreate(Sender: TObject);
var
  R: TRect;
begin
  IsFlipped := False; // design default

  if Application.BiDiMode = BdRightToLeft then
  begin
    // This is startup so we need to flip before changing to RTL ..
    // .. or AutoSize captions will have their alignment switched and
    // .. their left values may change
    FlipChildren(True);
    // or possibly False if some child components' children are not to be flipped
    IsFlipped := True;
    // if some labels do not switch initial alignment or need custom alignment, they can be done here
  end;
  // finally, we can change the form to follow the Application.BiDiMode
  ParentBiDiMode := True;

  R := FrmDisplay.Monitor.WorkareaRect;
  // set default size
  Height := 554;
  Width := 708;
  Top := R.Top;
  Left := R.Left;
  ListInterval := 250;
  // start the UDP Server  *** Now removed as UDP port bindings are in Main ***
  // UDPServer.Bindings.Clear;
  // UDPServer.DefaultPort := UDPServerPort;     // 58091 UDP
  // UDPServer.Active := True;
  // UDPServer.Active := False;
  IdTCPClientXfer.Port := FileTransferPort;   // 58291 TCP
  // start the UDP Server  *** Now removed as UDP port bindings are in Main ***
  // UDPServer.Bindings.Clear;
  // UDPServer.DefaultPort := UDPServerPort;     // 58091 UDP
  // UDPServer.Active := True;
  // UDPServer.Active := False;
  IdTCPClientXfer.Port := FileTransferPort;   // 58291 TCP
  HostNameList := TStringList.Create;
  HostNameList.Sorted := True;
  HostNameList.Duplicates := DupIgnore;
  HostNameList.Sorted := True;
  HostNameList.Duplicates := DupIgnore;
  MessageList := TStringList.Create;
  MessageList.Sorted := True;
  MessageList.Duplicates := DupIgnore;
  MessageList.Sorted := True;
  MessageList.Duplicates := DupIgnore;
  FrmDisplay.ScaleBy(300, 544);
  AllDone := False;
  TransferringData := False;
end;

procedure TfrmDisplay.FormDestroy(Sender: TObject);
begin
//  if UDPServer.Active then
//    UDPServer.Active := False;
//  if UDPServer.Active then
//    UDPServer.Active := False;
  HostNameList.Free;
  MessageList.Free;
end;

procedure TfrmDisplay.FormShow(Sender: TObject);
begin
  SiLang1.OnLanguageChanging := SiLang1LanguageChanging;
  Synchro := False;
  SiLang1.ActiveLanguage := Language;
  UpdateTimer.Interval := ListInterval;
//  if not UDPServer.Active then UDPServer.Active := True;
//  if not UDPServer.Active then UDPServer.Active := True;
  TransferringData := False;
end;

procedure TfrmDisplay.FeedUdpText(const RawMsg: string);
begin
  // Called from Main’s listener thread. Safe because we use TThread.Queue inside.
  ProcessUdpText(RawMsg);
end;

procedure TfrmDisplay.ProcessUdpText(const RawMsg: string);
var
  H, Msg, N: string;
  SArray: TArray<string>;
begin
  Msg := Trim(RawMsg);

  // check for end of message
  if Msg.EndsWith('^') then
  begin
    if Msg.EndsWith('|^') then
      Msg := Msg.Substring(0, Msg.IndexOf('|^'))
    else
      Msg := Msg.Substring(0, Msg.IndexOf('^'));

    SArray := Msg.Split(['|']);
    if Length(SArray) = 0 then Exit;

    if ((SArray[0] = 'UPDATE') or (SArray[0] = 'AVIDEO')) then
    begin
      if Visible then
      begin
        H := SArray[2]; // sending Host
        N := SArray[3]; // event mode

        if ((Length(DRHost) = 0) or (DRHost = H) or (N = '0')) then
          TThread.Queue(nil,
            procedure
            begin
              AllDone := False;
              MessageList.Add(Msg);
              if not UpdateTimer.Enabled then
                UpdateTimer.Enabled := True;
            end);
      end;
    end
    else if (SArray[0] = 'AWARD') then
    begin
      if Visible then
      begin
        H := SArray[1]; // sending Host
        N := SArray[2]; // event mode

        if ((Length(DRHost) = 0) or (DRHost = H) or (N = '0')) then
          TThread.Queue(nil,
            procedure
            begin
              AllDone := False;
              MessageList.Add(Msg);
              if not UpdateTimer.Enabled then
                UpdateTimer.Enabled := True;
            end);
      end;
    end
    else if (SArray[0] = 'DIVERECORDER') then
    begin
      TThread.Queue(nil,
        procedure
        begin
          HostNameList.Add(SArray[1]);
        end);
    end;
  end;
end;


procedure TfrmDisplay.FeedUdpText(const RawMsg: string);
begin
  // Called from Main’s listener thread. Safe because we use TThread.Queue inside.
  ProcessUdpText(RawMsg);
end;

procedure TfrmDisplay.ProcessUdpText(const RawMsg: string);
var
  H, Msg, N: string;
  SArray: TArray<string>;
begin
  Msg := Trim(RawMsg);

  // check for end of message
  if Msg.EndsWith('^') then
  begin
    if Msg.EndsWith('|^') then
      Msg := Msg.Substring(0, Msg.IndexOf('|^'))
    else
      Msg := Msg.Substring(0, Msg.IndexOf('^'));

    SArray := Msg.Split(['|']);
    if Length(SArray) = 0 then Exit;

    if ((SArray[0] = 'UPDATE') or (SArray[0] = 'AVIDEO')) then
    begin
      if Visible then
      begin
        H := SArray[2]; // sending Host
        N := SArray[3]; // event mode

        if ((Length(DRHost) = 0) or (DRHost = H) or (N = '0')) then
          TThread.Queue(nil,
            procedure
            begin
              AllDone := False;
              MessageList.Add(Msg);
              if not UpdateTimer.Enabled then
                UpdateTimer.Enabled := True;
            end);
      end;
    end
    else if (SArray[0] = 'AWARD') then
    begin
      if Visible then
      begin
        H := SArray[1]; // sending Host
        N := SArray[2]; // event mode

        if ((Length(DRHost) = 0) or (DRHost = H) or (N = '0')) then
          TThread.Queue(nil,
            procedure
            begin
              AllDone := False;
              MessageList.Add(Msg);
              if not UpdateTimer.Enabled then
                UpdateTimer.Enabled := True;
            end);
      end;
    end
    else if (SArray[0] = 'DIVERECORDER') then
    begin
      TThread.Queue(nil,
        procedure
        begin
          HostNameList.Add(SArray[1]);
        end);
    end;
  end;
end;


procedure TfrmDisplay.UDPServerUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  H, Msg, N: string;
  SArray: TArray<string>;
begin


  // read datagram
  Msg := Trim(BytesToString(AData, IndyTextEncoding_UTF8));
  // check for end of message
  if Msg.EndsWith('^') then
  begin
    // but it could end with either '|^' or '^'
    if Msg.EndsWith('|^') then
      Msg := Msg.Substring(0, Msg.IndexOf('|^'))
    else
      Msg := Msg.Substring(0, Msg.IndexOf('^'));
    // now OK to continue

    SArray := Msg.Split(['|']);

    if ((SArray[0] = 'UPDATE') or (SArray[0] = 'AVIDEO')) then
    begin
      if Visible then // IF Form IS VISIBLE
      begin
        // it is a valid message type .. but
        // .. make sure it is relevant

        H := SArray[2]; // sending Host
        N := SArray[3]; // event mode

        // only continue if host matches or does not exist or EventMode = '0'
        if ((Length(DRHost) = 0) or (DRHost = H) or (N = '0')) then
        begin
          TThread.Queue(nil,
            procedure
            begin
              AllDone := False; // set to default
              MessageList.Add(Msg);
              if not UpdateTimer.Enabled then
                UpdateTimer.Enabled := True;
            end);
        end;
      end;
    end

    else if (SArray[0] = 'AWARD') then
    begin
      if Visible then // IF Form IS VISIBLE
      begin
        // it is a valid message type .. but
        // .. make sure it is relevant

        H := SArray[1]; // sending Host
        N := SArray[2]; // event mode

        // only continue if host matches or does not exist or EventMode = '0'
        if ((Length(DRHost) = 0) or (DRHost = H) or (N = '0')) then
        begin
          TThread.Queue(nil,
            procedure
            begin
              AllDone := False; // set to default
              MessageList.Add(Msg);
              if not UpdateTimer.Enabled then
                UpdateTimer.Enabled := True;
            end);
        end;
      end;
    end

    else if SArray[0] = 'DIVERECORDER' then
    begin
      // This will be a reply to a scan for hosts
      TThread.Queue(nil,
        procedure
        begin
          HostNameList.Add(SArray[1]);
        end);
    end;
  end;
end;

procedure TfrmDisplay.UpdateTimerTimer(Sender: TObject);
var
  Msg: string;
begin
  if not TransferringData then
  begin
    if MessageList.Count > 0 then
    begin
      Msg := MessageList.Strings[0];
      MessageList.Delete(0);
      if Msg.StartsWith('UPDATE') then
      begin
        GetUpdateFile(Msg);
      end else if Msg.StartsWith('AWARD') then
      begin
        DoAward(Msg);
      end else if Msg.StartsWith('AVIDEO') then
      begin
        DoEndOfEvent(Msg);
      end;
    end
    else
      UpdateTimer.Enabled := False;
  end;
end;

procedure TfrmDisplay.GetUpdateFile(Msg: string);
var
  Ms: TMemoryStream;
  LocalFileName: string;
  SArray: TArray<string>;
begin
  // This will ask a DR Host to stream an Update.txt file back
  TransferringData := True;
  SArray := Msg.Split(['|']);

  if IdTCPClientXfer.Connected then
    IdTCPClientXfer.Disconnect;
  IdTCPClientXfer.Host := SArray[4]; // IP Address
  { DataPath = '\MDT\DRUtils\' }
  LocalFileName := DataPath + 'Xfer\Update.txt';
  // Need to be sure the Xfer folder exists, (added to installer for v 7.0.6.0)
  if not DirectoryExists(DataPath + 'Xfer') then
    if not CreateDir(DataPath + 'Xfer') then
      raise Exception.Create('Cannot create ' + LocalFileName);
  if FileExists(LocalFileName) then
    DeleteFile(LocalFileName); // delete any previous local file

  Ms := TMemoryStream.Create;
  try

    try
      IdTCPClientXfer.Connect;
    except
      on E: EIdConnClosedGracefully do
      begin
        IdTCPClientXfer.Disconnect;
        if IdTCPClientXfer.IOHandler <> nil then
          IdTCPClientXfer.IOHandler.InputBuffer.Clear;
        Sleep(50);
        try
          // try again
          IdTCPClientXfer.Connect;
        except
          // give up .. we tried
        end;
      end;
    end;

    try
      IdTCPClientXfer.IOHandler.WriteLn('XFER|Update.txt', IndyTextEncoding_UTF8);
      IdTCPClientXfer.IOHandler.ReadStream(Ms, -1, False);
      Ms.SaveToFile(LocalFileName);
    finally
      IdTCPClientXfer.Disconnect;
    end;
    DoUpdate; // DoUpdate checks for existence of file

  finally
    Ms.Free;
    TransferringData := False;
  end;
end;

procedure TfrmDisplay.SiLang1LanguageChanging(Sender: TObject; const NewLanguage: Integer; var AllowChange: Boolean);
begin
  // default is AllowChange := True;
  if NewLanguage = 18 then
    MakeRTL
  else
    MakeLTR;
end;

procedure TfrmDisplay.MakeRTL;
begin
  // change to RTL, if necessary
  if not IsFlipped then
  begin
    // basic
    FlipChildren(True);
    IsFlipped := True;
    // add here any custom (alignments) for Form, if required
  end;
end;

procedure TfrmDisplay.MakeLTR;
begin
  // change to LTR, if necessary
  if IsFlipped then
  begin
    // basic
    FlipChildren(True);
    IsFlipped := False;
    // add here any custom (alignments) for Form, if required
  end;
end;

procedure TfrmDisplay.DoUpdate;
var
  I, P, R, So, Sp: Integer;
  Msg, N, S, T: string;
  StrList: TStringList;
  SArray: TArray<string>;
  DoNotRank: Boolean;
begin
  // this will happen both before each dive and after its score is accepted
  // also for start and result lists

  // This new version reads and processes the downloaded file
  // But make sure the file exists
  if FileExists(DataPath + 'Xfer\Update.txt') then
  begin
    StrList := TStringList.Create;;
    StrList.LoadFromFile(DataPath + 'Xfer\Update.txt');
    Msg := StrList[0];
    StrList.Free;

    // Msg does have a terminating '|^'
    Msg := Msg.Substring(0, Msg.IndexOf('|^'));
{
{
    if not UseHalf then
    begin
      // need to replace '½' with '.5' where '.' should be DecSep (for consistency)
      Msg := StringReplace(Msg, '½', DecSep + '5', [RfReplaceAll]);
    end;
 }
 }
    SArray := Msg.Split(['|']);

    PnlTV.Visible := True;
    PnlTV.Color := ClMaroon;
    if DM.ScoreBTable.FieldByName('SBMode').AsInteger = 2 then
      AllDone := True;
    EventB := SArray[1]; // a or b

    // extract the ScoreBTable data
    if (DM.ScoreBTable.RecordCount = 0) then
    begin
      DM.ScoreBTable.Insert
    end
    else
    begin
      DM.ScoreBTable.Edit;
    end;

    for I := 0 to DM.ScoreBTable.FieldCount - 1 do
    begin
      // but there are NO float fields so there cannot be any decimal separator mismatches!
      // TRY
      DM.ScoreBTable.Fields[I].AsString := SArray[I + 4];
      // EXCEPT
      // // could this be a decimalseparator mismatch?
      // T := SArray[I + 4];
      // T := T.Replace('.', AFormatSettings.DecimalSeparator);
      // // try again
      // DM.ScoreBTable.Fields[I].AsString := T;
      // END;
    end;

    DM.ScoreBTable.Post;
    DM.ScoreBTable.Refresh;

    DoNotRank := DM.ScoreBTable['DoNotRank'];

    // now do some edits
    DM.ScoreBTable.Edit;

    // validate Rank
    if not DM.ScoreBTable.FieldByName('Place').IsNull then
    begin
      T := DM.ScoreBTable['Place'];
      if (T.StartsWith('P') or DoNotRank) then
      begin
        // we need some kind of edit
        if T.StartsWith('P') then
          // remove the leading 'P' from the Rank
          T := T.Remove(0, 1);
        if DoNotRank then
          T := '';
        DM.ScoreBTable['Place'] := T;
      end;
    end;

    // make sure scores and DD are localised
    // IF NOT(AFormatSettings.DecimalSeparator = '.') THEN
    // BEGIN
    // T := DM.ScoreBTable['Tariff'];
    // T := T.Replace('.', AFormatSettings.DecimalSeparator);
    // DM.ScoreBTable['Tariff'] := T;
    // T := DM.ScoreBTable['Points'];
    // T := T.Replace('.', AFormatSettings.DecimalSeparator);
    // DM.ScoreBTable['Points'] := T;
    // T := DM.ScoreBTable['CumPoints'];
    // T := T.Replace('.', AFormatSettings.DecimalSeparator);
    // DM.ScoreBTable['CumPoints'] := T;

    // Experiment to fix vMix shortcomings  (not sure this is now needed???)
{
{
    if not(DecSep = '.') then
    begin
      T := DM.ScoreBTable['Tariff'];
      T := T.Replace('.', DecSep);
      DM.ScoreBTable['Tariff'] := T;
      T := DM.ScoreBTable['Points'];
      T := T.Replace('.', DecSep);
      DM.ScoreBTable['Points'] := T;
      T := DM.ScoreBTable['CumPoints'];
      T := T.Replace('.', DecSep);
      DM.ScoreBTable['CumPoints'] := T;
    end;
 }
 }
    // strip team code from names
    T := DM.ScoreBTable.FieldByName('DiverA').AsString;
    if T.Contains('--') then
    begin
      T := T.Substring(0, T.IndexOf(' --'));
      DM.ScoreBTable.FieldByName('DiverA').AsString := T;
    end;
    T := DM.ScoreBTable.FieldByName('DiverB').AsString;
    if T.Contains('--') then
    begin
      T := T.Substring(0, T.IndexOf(' --'));
      DM.ScoreBTable.FieldByName('DiverB').AsString := T;
    end;

    DM.ScoreBTable.Post;
    DM.ScoreBTable.Refresh;
    Official := not DM.ScoreBTable.FieldByName('J1').IsNull;

    // now do TempResTable data
    DM.TempResTable.Last;
    while not DM.TempResTable.Bof do
      DM.TempResTable.Delete;

    // Initialise array index
    I := DM.ScoreBTable.FieldCount + 4;

    while I < Length(SArray) do
    begin
      N := SArray[I]; // Place
      if ((Length(N) > 0) and (not DoNotRank)) then
      begin
        P := StrToInt(N)
      end
      else
      begin
        P := NoRank;
      end;
      Inc(I);

      N := SArray[I]; // Score
      if Length(N) > 0 then
      begin
//        S := N.Replace('.', DecSep);
//        S := N.Replace('.', DecSep);
        // add padding
        Sp := 7 - Length(N);
        if Sp > 0 then
        begin
          S := StringOfChar(' ', Sp) + S;
        end;
      end
      else
      begin
        S := 'NoScore';
      end;

      Inc(I);
      R := StrToInt(SArray[I]); // Round

      Inc(I);
      N := Trim(SArray[I]); // Name - does it need to be trimmed?  If it came from Results, Yes!

      Inc(I);
      So := StrToInt(SArray[I]); // StartOrder

      Inc(I);
      T := SArray[I]; // TeamCode

      Inc(I);

      if P = NoRank then
      begin
        DM.TempResTable.InsertRecord([nil, S, So, R, N, T])
      end else if S = 'NoScore' then
      begin
        DM.TempResTable.InsertRecord([P, nil, So, R, N, T])
      end
      else
      begin
        DM.TempResTable.InsertRecord([P, S, So, R, N, T]);
      end;
    end;
    CompleteUpdate;
  end;
end;

procedure TfrmDisplay.CompleteUpdate;
begin
  // Display OR hide things
  Label1.Visible := not(DM.ScoreBTable.FieldByName('Board').AsString = '');
  Synchro := DM.ScoreBTable.FieldByName('Synch').AsBoolean;
  NumberOfJudges := DM.ScoreBTable.FieldByName('Jdgs').AsInteger;
  LblExec.Visible := Synchro;
  LblSynch.Visible := Synchro;
  LblJ8.Visible := Synchro;
  LblJ9.Visible := Synchro;
  LblJ10.Visible := Synchro;
  LblJ11.Visible := Synchro;
  PnlUnOfficial.Visible := False;
  PnlOfficial.Visible := Official;
  if Synchro then
  begin
    LblJ5.Visible := (NumberOfJudges = 11);
    LblJ6.Visible := (NumberOfJudges = 11);
    LblJ7.Visible := True;
    LblJ7.Caption := '1';
    LblJ8.Caption := '2';
    LblJ9.Caption := '3';
    LblJ10.Caption := '4';
    LblJ11.Caption := '5';
  end
  else
  begin
    LblJ7.Caption := '7';
    LblJ5.Visible := (NumberOfJudges > 3);
    LblJ6.Visible := (NumberOfJudges > 5);
    LblJ7.Visible := (NumberOfJudges > 5);
  end;

  // update display colours
  ClBack := DM.ScoreBTable.FieldByName('BackGrnd').AsInteger;
  ClTextA := DM.ScoreBTable.FieldByName('AText').AsInteger;
  ClLabels := DM.ScoreBTable.FieldByName('Labels').AsInteger;
  Color := ClBack;
  Lbl1.Font.Color := ClLabels;
  Lbl2.Font.Color := ClLabels;
  Lbl3.Font.Color := ClLabels;
  Lbl4.Font.Color := ClLabels;
  LblExec.Font.Color := ClLabels;
  LblSynch.Font.Color := ClLabels;
  LblJ1.Font.Color := ClLabels;
  LblJ2.Font.Color := ClLabels;
  LblJ3.Font.Color := ClLabels;
  LblJ4.Font.Color := ClLabels;
  LblJ5.Font.Color := ClLabels;
  LblJ6.Font.Color := ClLabels;
  LblJ7.Font.Color := ClLabels;
  LblJ8.Font.Color := ClLabels;
  LblJ9.Font.Color := ClLabels;
  LblJ10.Font.Color := ClLabels;
  LblJ11.Font.Color := ClLabels;
  EventTitle.Font.Color := ClTextA;
  SN.Font.Color := ClTextA;
  DT.Font.Color := ClTextA;
  RN.Font.Color := ClTextA;
  RT.Font.Color := ClTextA;
  DiverAName.Font.Color := ClTextA;
  TeamA.Font.Color := ClTextA;
  DiverBName.Font.Color := ClTextA;
  TeamB.Font.Color := ClTextA;
  DiveNo.Font.Color := ClTextA;
  FlightPos.Font.Color := ClTextA;
  BHeight.Font.Color := ClTextA;
  Label1.Font.Color := ClTextA;
  DD.Font.Color := ClTextA;
  J1.Font.Color := ClTextA;
  J2.Font.Color := ClTextA;
  J3.Font.Color := ClTextA;
  J4.Font.Color := ClTextA;
  J5.Font.Color := ClTextA;
  J6.Font.Color := ClTextA;
  J7.Font.Color := ClTextA;
  J8.Font.Color := ClTextA;
  J9.Font.Color := ClTextA;
  J10.Font.Color := ClTextA;
  J11.Font.Color := ClTextA;

  // do penalty
  case DM.ScoreBTable.FieldByName('Penalty').AsInteger of
    0:
      PnlPenalty.Visible := False;
    1:
      begin
        PnlPenalty.Caption := SiLang1.GetTextOrDefault('IDS_100'
        (* 'Failed dive' *) );
        PnlPenalty.Visible := True;
      end;
    2:
      begin
        PnlPenalty.Caption := SiLang1.GetTextOrDefault('IDS_101'
        (* 'Restarted: -2 points' *) );
        PnlPenalty.Visible := True;
      end;
    3:
      begin
        PnlPenalty.Caption := SiLang1.GetTextOrDefault('IDS_102'
        (* 'Flight position: Max 2 points' *) );
        PnlPenalty.Visible := True;
      end;
    4:
      begin
        PnlPenalty.Caption := SiLang1.GetTextOrDefault('IDS_103'
        (* 'Arm position: Max 4½ points' *) );
        PnlPenalty.Visible := True;
      end;
  end;
  DoTV;
end;

procedure TfrmDisplay.DoAward(Msg: string);
var
  I: Integer;
  T: string;
  SArray: TArray<string>;
begin
{
{
  if not UseHalf then
  begin
    // need to replace '½' with '.5'
    Msg := StringReplace(Msg, '½', '.5', [RfReplaceAll]);
  end;
}
}
  // this will happen after each award is received by DiveRecorder
  SArray := Msg.Split(['|']);

  PnlTV.Color := ClMaroon;

  DM.ScoreBTable.Edit;
  // now pump the 11 award strings into ScoreBTable
  for I := 12 to 22 do
  begin
    try
      DM.ScoreBTable.Fields[I].AsString := SArray[I - 9];
    except
      // could this be a decimalseparator mismatch?
      T := SArray[I - 9];
      T := T.Replace('.', AFormatSettings.DecimalSeparator);
      // try again
      DM.ScoreBTable.Fields[I].AsString := T;
    end;
  end;
  DM.ScoreBTable.Post;
  PnlOfficial.Visible := False;
  PnlUnOfficial.Visible := True;
end;

procedure TfrmDisplay.DoEndOfEvent(Msg: string);
var
  SArray: TArray<string>;
begin
  // this will happen after End Of Event is sent by DiveRecorder
  // but if using mouse or keyboard without the Timer, a final Next Diver is needed
  SArray := Msg.Split(['|']);
  PnlTV.Color := ClMaroon;

  DM.ScoreBTable.Edit;
  // only need to update SBTable["SBMode"];
  DM.ScoreBTable['SBMode'] := 2; // Ranking display used to indicate 'completed'
  DM.ScoreBTable['SBMode'] := 2; // Ranking display used to indicate 'completed'
  DM.ScoreBTable.Post;
  AllDone := True; // Completed
  DoTV;
end;

procedure TfrmDisplay.ExportToXML(Fname: string);
var
  XML: TXmlVerySimple;
  HeaderNode, RowNode, EntityNode: TXMLNode;
  S: string;
  Dvr, Flds: Integer;
begin
  // set up the XML file
  XML := TXmlVerySimple.Create;
{
{
  try
    case EncodeIndex of
      0:
        XML.Encoding := 'windows-' + IntToStr(GetACP);
      1:
        XML.Encoding := 'utf-8';
      2:
        XML.Encoding := 'utf-16';
    end;


    // Add the DocumentElement
    XML.AddChild('diving');

    // set up header info
    HeaderNode := XML.DocumentElement.AddChild('creator');
    HeaderNode.Text := 'DR2Video';
    HeaderNode := XML.DocumentElement.AddChild('website');
    HeaderNode.Text := 'www.diverecorder.co.uk';
    HeaderNode := XML.DocumentElement.AddChild('contact');
    HeaderNode.Text := 'diverecorder@gmail.com';
    HeaderNode := XML.DocumentElement.AddChild('meet');
    S := DM.ScoreBTable['MeetTitle'];
    HeaderNode.Text := S;
    HeaderNode := XML.DocumentElement.AddChild('event');
    S := DM.ScoreBTable['EventTitle'];
    HeaderNode.Text := S;
    HeaderNode := XML.DocumentElement.AddChild('timestamp');
    S := FormatDateTime('yyyy-mm-dd hh:nn', Now);
    HeaderNode.Text := S;
    // end of header

    // start of data - loop through the rows and columns
    ReportQuery.First;
    for Dvr := 0 to ReportQuery.RecordCount - 1 do
    begin
      RowNode := XML.DocumentElement.AddChild('diver');
      for Flds := 0 to ReportQuery.FieldCount - 1 do
      begin
        EntityNode := RowNode.AddChild(ReportQuery.Fields[Flds].FieldName);
        EntityNode.Text := ReportQuery.Fields[Flds].AsString; // why does this trim white space?
      end;
      ReportQuery.Next;
    end;
    // end of data

    // write file
    XML.SaveToFile(Fname);

  finally
    XML.Free;
  end;
}
}
end;

procedure TfrmDisplay.ExportToCSV(Fname: string);
var
  Fld: TField;
  AList: TStringList;
  S: string;
begin
{
{
  // This exports the data to a file
  // Uses AnEncoding as set in TfrmMain
  AList := TStringList.Create;
  try

    if IncludeHeaders then
    begin
      // write field names
      for Fld in ReportQuery.Fields do
      begin
        // insert delimiter if not first field
        if Length(S) > 0 then
          S := S + CSVSep;
        // write field name
        if CSVSep = ',' then // wrap text in double quotes
          S := S + '"' + Fld.FieldName + '"'
        else
          S := S + Fld.FieldName;
      end;
      AList.Add(S);
    end;

    // now write records
    ReportQuery.First;
    while not ReportQuery.Eof do
    begin
      S := '';
      for Fld in ReportQuery.Fields do
      begin
        // insert delimiter if not first field
        if Length(S) > 0 then
          S := S + CSVSep;
        if CSVSep = ',' then // wrap text in double quotes
          S := S + '"' + Fld.Text + '"'
        else
          S := S + Fld.Text;
      end;
      AList.Add(S);
      ReportQuery.Next;
    end;
    // now write to file
    AList.SaveToFile(Fname, AnEncoding);
  finally
    AList.Free;
  end;
}
}
end;

procedure TfrmDisplay.HorizontalExport(Fname: string);
var
  Fld: TField;
  AList: TStringList;
  S: string;
  I, D, L, R, X: Integer;
begin
{
{
  // custom 'hack' for Horizontal - results in lines of 12 divers in CSV format
  // This exports the data to a file
  // Uses AnEncoding as set in TfrmMain
  // But skip all this if the Query is empty or we get a divide by zero
  if ReportQuery.RecordCount > 0 then
  begin
    AList := TStringList.Create;
    try

      R := ReportQuery.RecordCount;
      D := 12;
      if R < 12 then
        D := R;

      if IncludeHeaders then
      begin
        // write all 12 sets of field names!   Even if less than 12 records
        for I := 1 to 12 do
          for Fld in ReportQuery.Fields do
          begin
            // insert delimiter if not first field
            if Length(S) > 0 then
              S := S + CSVSep;
            // write field name
            if CSVSep = ',' then // wrap text in double quotes
              S := S + '"' + Fld.FieldName + IntToStr(I) + '"'
            else
              S := S + Fld.FieldName + IntToStr(I);
          end;
        AList.Add(S);
      end;

      // now write records
      {
        The trick is to write records in chunks of 12 (less if a smaller entry), including the final chunk
        So:
        # Count records
        # Write each complete set of 12 (or less) divers
        # Write remainder
      }
      {
      {
      ReportQuery.First; // make sure
      S := '';
      L := R div D; // number of groups of 12 divers, may be none
      if L > 0 then

        for I := 1 to L do
        begin
          for X := 1 to D do
          begin
            for Fld in ReportQuery.Fields do
            begin

              // insert delimiter if not first field
              if Length(S) > 0 then
                S := S + CSVSep;
              // add field value
              if CSVSep = ',' then // wrap text in double quotes
                S := S + '"' + Fld.Text + '"'
              else
                S := S + Fld.Text;

            end;
            ReportQuery.Next;
          end;
          AList.Add(S);
          // reset S
          S := '';
        end;
      // all complete loops written

      // Make last page show only the remainder, could be the only page!
      // So, calculate the remaing divers - or just repeat until EOF
      S := '';
      while not ReportQuery.Eof do
      begin
        for Fld in ReportQuery.Fields do
        begin


          // insert delimiter if not first field
          if Length(S) > 0 then
            S := S + CSVSep;
          // add field value
          if CSVSep = ',' then // wrap text in double quotes
            S := S + '"' + Fld.Text + '"'
          else
            S := S + Fld.Text;
        end;
        ReportQuery.Next;


      end;


      if Length(S) > 0 then
        AList.Add(S);
      // Finally write everything to file
      AList.SaveToFile(Fname, AnEncoding);
    finally
      AList.Free;
    end;
    finally

    end;
  end;
    finally

    end;
}
    finally

    end;
  end;
    finally

    end;
}
end;

procedure TfrmDisplay.DoTV;
// This is where we prepare the DataSet for export
var
  Rcount: Integer;
  Dpath, RPath, Fname, UName: string;
  Write_err: Boolean;
  AList: TStringList;
begin
{
{
  if ((not CombineAB) and (EventB = 'b')) then
  begin
    // need to insert a 'B' into file name
    Dpath := DivePath.Replace('.', 'B.');
    RPath := RankPath.Replace('.', 'B.');
  end
  else
  begin
    Dpath := DivePath;
    RPath := RankPath;
  end;
  Write_err := False;
}
}
  if ReportQuery.Active then
  begin
    ReportQuery.Close;
  end;

  // Dive data
  ReportQuery.SQL.Clear;
  if Synchro then
  begin
    ReportQuery.SQL.Add('SELECT "DiverA" || '' + '' || "DiverB" AS Name,')
  end
  else
  begin
    ReportQuery.SQL.Add('SELECT "DiverA" AS Name,');
  end;
  ReportQuery.SQL.Add('IFNULL("TeamCodeA" THEN '' '' ELSE "TeamCodeA") AS Team,');
  ReportQuery.SQL.Add('CAST("DiveNo" AS VARCHAR(4)) AS DiveNo, "Position",');
  ReportQuery.SQL.Add('"Board", "Tariff", "DiveDescription",');
  if Synchro then
  begin
    ReportQuery.SQL.Add('IFNULL("J1" THEN '' '' ELSE "J1") AS E1,');
    ReportQuery.SQL.Add('IFNULL("J2" THEN '' '' ELSE "J2") AS E2,');
    ReportQuery.SQL.Add('IFNULL("J3" THEN '' '' ELSE "J3") AS E3,');
    ReportQuery.SQL.Add('IFNULL("J4" THEN '' '' ELSE "J4") AS E4,');
    ReportQuery.SQL.Add('IFNULL("J5" THEN '' '' ELSE "J5") AS E5,');
    ReportQuery.SQL.Add('IFNULL("J6" THEN '' '' ELSE "J6") AS E6,');
    ReportQuery.SQL.Add('IFNULL("J7" THEN '' '' ELSE "J7") AS S1,');
    ReportQuery.SQL.Add('IFNULL("J8" THEN '' '' ELSE "J8") AS S2,');
    ReportQuery.SQL.Add('IFNULL("J9" THEN '' '' ELSE "J9") AS S3,');
    ReportQuery.SQL.Add('IFNULL("J10" THEN '' '' ELSE "J10") AS S4,');
    ReportQuery.SQL.Add('IFNULL("J11" THEN '' '' ELSE "J11") AS S5,');
  end
  else
  begin
    ReportQuery.SQL.Add('IFNULL("J1" THEN '' '' ELSE "J1") AS J1,');
    ReportQuery.SQL.Add('IFNULL("J2" THEN '' '' ELSE "J2") AS J2,');
    ReportQuery.SQL.Add('IFNULL("J3" THEN '' '' ELSE "J3") AS J3,');
    ReportQuery.SQL.Add('IFNULL("J4" THEN '' '' ELSE "J4") AS J4,');
    ReportQuery.SQL.Add('IFNULL("J5" THEN '' '' ELSE "J5") AS J5,');
    ReportQuery.SQL.Add('IFNULL("J6" THEN '' '' ELSE "J6") AS J6,');
    ReportQuery.SQL.Add('IFNULL("J7" THEN '' '' ELSE "J7") AS J7,');
    ReportQuery.SQL.Add('IFNULL("J8" THEN '' '' ELSE "J8") AS J8,');
    ReportQuery.SQL.Add('IFNULL("J9" THEN '' '' ELSE "J9") AS J9,');
    ReportQuery.SQL.Add('IFNULL("J10" THEN '' '' ELSE "J10") AS J10,');
    ReportQuery.SQL.Add('IFNULL("J11" THEN '' '' ELSE "J11") AS J11,');
  end;
  ReportQuery.SQL.Add
    ('CAST("Points" AS VARCHAR(6)) AS Score, CAST("CumPoints" AS VARCHAR(6)) AS Total, "Place" AS Rank,');
//  ReportQuery.SQL.Add(QuotedStr(FlagsPath) + ' || "TeamCodeA" || ' + QuotedStr('.' + FlagsExtn) + ' AS Flag,');
//  ReportQuery.SQL.Add(QuotedStr(FlagsPath) + ' || "TeamCodeA" || ' + QuotedStr('.' + FlagsExtn) + ' AS Flag,');
  ReportQuery.SQL.Add('CAST(EStart AS VARCHAR(4)) AS StartNo,');
  ReportQuery.SQL.Add('CAST(ERound AS VARCHAR(2)) AS Round,');
  ReportQuery.SQL.Add('"EventTitle", "TeamA" AS TeamName,');
  ReportQuery.SQL.Add('"NoOfRounds", "NoOfDivers"');
  ReportQuery.SQL.Add('FROM "ScoreB";');

  ReportQuery.Prepare;
  ReportQuery.Open;
  Rcount := ReportQuery.RecordCount;
{
{
  case TVOut of
    0:
      begin
        // Do CSV export
        if Synchro then
          Fname := SynchroPath
        else
          Fname := Dpath;
        ExportToCSV(Fname);
      end;
    1:
      begin
        // Do XML export
        if Synchro then
          Fname := SynchroPath
        else
          Fname := Dpath;
        ExportToXML(Fname);
      end;

  end;
}
}
  { Set Andy's UName (Update file name) based on FName }
  if Synchro then
    Uname := Fname.Replace('Synchro', 'SUpdate')
  else
    Uname := Fname.Replace('Dive', 'DUpdate');
  { Change extension to .txt }
  Uname := ChangeFileExt(Uname, '.txt');

  ReportQuery.Close;
  ReportQuery.UnPrepare;

  // Now do Ranking
  ReportQuery.SQL.Clear;
  ReportQuery.SQL.Add
    ('SELECT CAST(IF("Place"<0 THEN ''('' || CAST(ABS("Place") AS VARCHAR(2)) || '')'' ELSE CAST("Place" AS VARCHAR(2))) AS VARCHAR(4)) AS Rank, ');
  ReportQuery.SQL.Add('"Name", "TCode" AS Team, "Score",');
//  ReportQuery.SQL.Add(QuotedStr(FlagsPath) + ' || "TCode" || ' + QuotedStr('.' + FlagsExtn) + ' AS Flag,');
//  ReportQuery.SQL.Add(QuotedStr(FlagsPath) + ' || "TCode" || ' + QuotedStr('.' + FlagsExtn) + ' AS Flag,');
  ReportQuery.SQL.Add('"StartOrder" AS StartNo,');
  if AllDone then
    ReportQuery.SQL.Add('1 AS Completed')
  else
    ReportQuery.SQL.Add('0 AS Completed');
  ReportQuery.SQL.Add('FROM "TempResult"');
  ReportQuery.SQL.Add('ORDER BY "Score" DESC;');

  ReportQuery.Prepare;
  ReportQuery.Open;
{
{
  case TVOut of
    0:
      begin
        // Do CSV export, BUT if Horizontal we need custom export
        if Horizontal then
          HorizontalExport(RPath)
        else
          ExportToCSV(RPath);
      end;
    1:
      ExportToXML(RPath);
  end;
}
}
  ReportQuery.Close;
  ReportQuery.UnPrepare;
  if ((Rcount > 0) and (not Write_err)) then
  begin
    PnlTV.Color := ClGreen;
    { Is this the best place to write Andy's 'update' file? }
    AList := TStringList.Create;
    try
      AList.Add('New data available');
//      AList.SaveToFile(Uname, AnEncoding);
//      AList.SaveToFile(Uname, AnEncoding);
    finally
      AList.Free;
    end;
  end;
end;

end.
