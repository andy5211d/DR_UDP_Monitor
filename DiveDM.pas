{ ************************************* }
{ Copyright(c) 2007-2023 Malcolm Taylor }
{ ************************************* }
//
//  DiveDM unit taken from DR2Video.  These Units are not the same in every DR app!
//




unit DiveDM;

interface

uses
  Winapi.Windows,
  Winapi.ShlObj,
  Winapi.Winsock2,
  Vcl.Dialogs,
  System.Classes,
  System.SysUtils,
  Data.DB,
  Vcl.Graphics,
  Vcl.Controls,
  Edbcomps,
  SiComp,
  SiLangRT,
  System.IniFiles,
  FileVerInf,
  MadExcept,
  IdStack,
  IdGlobal,
  Vcl.BaseImageCollection,
  IconFontsImageCollection;

type
  TDM = class(TDataModule)
    TempResDS: TDataSource;
    ScoreBDS: TDataSource;
    EDBScript1: TEDBScript;
    SiLangDispatcher1: TsiLangDispatcher;
    SiLangRTDM: TsiLangRT;
    TempResTable: TEDBTable;
    TempResTablePlace: TIntegerField;
    TempResTableStartOrder: TIntegerField;
    TempResTableRound: TIntegerField;
    TempResTableName: TWideStringField;
    TempResTableTCode: TWideStringField;
    EDBEngine1: TEDBEngine;
    DRUSession: TEDBSession;
    DiveDb: TEDBDatabase;
    ConfigurationQuery: TEDBQuery;
    ScoreBTable: TEDBTable;
    BooleanField1: TBooleanField;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    IntegerField3: TIntegerField;
    StringField1: TWideStringField;
    StringField2: TWideStringField;
    StringField3: TWideStringField;
    StringField4: TWideStringField;
    StringField5: TWideStringField;
    StringField6: TWideStringField;
    StringField7: TWideStringField;
    StringField8: TWideStringField;
    StringField9: TWideStringField;
    StringField10: TWideStringField;
    StringField11: TWideStringField;
    StringField12: TWideStringField;
    StringField13: TWideStringField;
    StringField14: TWideStringField;
    StringField15: TWideStringField;
    ScoreBTableJ10: TWideStringField;
    ScoreBTableJ11: TWideStringField;
    StringField16: TWideStringField;
    IntegerField4: TIntegerField;
    StringField17: TWideStringField;
    StringField18: TWideStringField;
    StringField19: TWideStringField;
    IntegerField5: TIntegerField;
    IntegerField6: TIntegerField;
    IntegerField7: TIntegerField;
    IntegerField8: TIntegerField;
    StringField20: TWideStringField;
    StringField21: TWideStringField;
    StringField22: TWideStringField;
    StringField23: TWideStringField;
    StringField24: TWideStringField;
    StringField25: TWideStringField;
    StringField26: TWideStringField;
    StringField27: TWideStringField;
    BooleanField2: TBooleanField;
    BooleanField3: TBooleanField;
    BooleanField4: TBooleanField;
    IntegerField9: TIntegerField;
    IntegerField10: TIntegerField;
    IntegerField11: TIntegerField;
    StringField28: TWideStringField;
    StringField29: TWideStringField;
    StringField30: TWideStringField;
    StringField31: TWideStringField;
    StringField32: TWideStringField;
    StringField33: TWideStringField;
    StringField34: TWideStringField;
    StringField35: TWideStringField;
    StringField36: TWideStringField;
    StringField37: TWideStringField;
    IntegerField12: TIntegerField;
    IntegerField13: TIntegerField;
    ScoreBTableShortDiveName: TWideStringField;
    ScoreBTableShortTitle: TWideStringField;
    TempResTableScore: TWideStringField;
    ScoreBTableTariff: TWideStringField;
    ScoreBTableBoard: TWideStringField;
    ScoreBTablePoints: TWideStringField;
    ScoreBTableCumPoints: TWideStringField;
    ScoreBTableTeamA2: TWideStringField;
    ScoreBTableTeamCodeA2: TWideStringField;
    ScoreBTableTeamB2: TWideStringField;
    ScoreBTableTeamCodeB2: TWideStringField;
    ScoreBTableSecsPerDive: TWideStringField;
    ScoreBTableDoNotRank: TBooleanField;
    ScoreBTableTeamEvent: TIntegerField;
    IconFontsImageCollection1: TIconFontsImageCollection;
    procedure DataModuleCreate(Sender: TObject);
    procedure SiLangRTDMChangeLanguage(Sender: TObject);
    procedure LoadPenalties;
    procedure DataModuleDestroy(Sender: TObject);
    procedure EDBEngine1BeforeStart(Sender: TObject);
    procedure DRUSessionBeforeConnect(Sender: TObject);
    procedure TableCreate(ScriptFile: string);
    procedure ObtainVersionInfo(FName: string);
    procedure InitialiseLanguage;
    procedure SetHostAndIP;
    procedure SiLangDispatcher1LanguageChanged(Sender: TObject);
    procedure GetIPAddressesAndMasks;
    function GetBroadcastIP(const IP, SubnetMask: AnsiString): string;
  private
    { Private declarations }
  public
    { Public declarations }
    FVInfo: TFileVersionInfo;
  end;

const
  Sep: string = '|';
  UDPServerPort: INTEGER    = 58091; // Note:  reverse of utilities (of course)
  UDPClientPort: INTEGER    = 58092; // Note:  reverse of utilities (of course)
  FileTransferPort: INTEGER = 58291; // Port used for transfer of UPDATE files

var
  DM: TDM;

  DRHost, { the DR Host that DR2Video will listen to }
  AppPath, Languages, DataPath, FlagsPath, FlagsExtn, DivePath, SynchroPath, RankPath, TheHelpFile, FileVersion,
    FileProductVersion, IPAddr, BroadcastIP, IPMask, CSVSep, DecSep: string;

  Language, TVOut, EncodeIndex, CSVOut, DSep, DiveLen, IPIndex: INTEGER;

  DRIniFile: TIniFile;
  ClBack, ClTextA, ClLabels: TColor;
  AFormatSettings: TFormatSettings;
  CombineAB, IncludeHeaders, UseHalf, Horizontal: Boolean;
  DStrings: TStringList;   {for the list of NICs }
  HostNameList: TStringList;   {added by Copilot}
  AnEncoding: TEncoding;

implementation

uses
  Vcl.Forms,
  System.StrUtils,
  System.UITypes,
  MultiNIC;

{$r *.dfm}

var
  Penalties: array [0 .. 4] of string;

procedure TDM.ObtainVersionInfo(FName: string);
begin
  FVInfo := TFileVersionInfo.Create(Self);
  try
    FileVersion := FVInfo.StrVerFileVersion;                           // x.x.x.x
    FileProductVersion := LeftStr(FVInfo.StrVerFileProductVersion, 4); // xxxx
  finally
    FVInfo.Free;
  end;
end;

procedure TDM.InitialiseLanguage;
var
  ALanguage: INTEGER;
begin
  // we only come here if the Active Language has not been set.
  // comment-out invalid languages
  ALanguage := SysLocale.PriLangID;
  case ALanguage of
    LANG_CHINESE:
      Language := 13; // 4
    LANG_DANISH:
      Language := 9; // 6
    LANG_GERMAN:
      Language := 4; // 7
    LANG_SPANISH:
      Language := 5; // 10
    LANG_FRENCH:
      Language := 3; // 12
    LANG_ITALIAN:
      Language := 6; // 16
    LANG_DUTCH:
      Language := 2; // 19
    LANG_NORWEGIAN:
      Language := 14; // 20
    LANG_POLISH:
      Language := 12; // 21
    LANG_RUSSIAN:
      Language := 11; // 25
    LANG_CROATIAN:
      Language := 7; // 26
    LANG_SWEDISH:
      Language := 10; // 29
    LANG_TURKISH:
      Language := 8; // 31
    // LANG_FARSI:
    // Language := 18; // 41
    LANG_CZECH:
      Language := 19; // 5
  else
    Language := 1; // English (default)
  end;
end;

function TDM.GetBroadcastIP(const IP, SubnetMask: AnsiString): string;
var
  Ip_addr, Mask_addr: Cardinal;
  Broadcast_addr: In_addr;
begin
  Ip_addr := Inet_addr(PAnsiChar(IP));
  Mask_addr := Inet_addr(PAnsiChar(SubnetMask));
  Broadcast_addr.S_addr := (Ip_addr and Mask_addr) or (not Mask_addr);
  Result := string(Inet_ntoa(Broadcast_addr));
end;

procedure TDM.GetIPAddressesAndMasks;
var
  LList: TIdStackLocalAddressList;
  I: Integer;
  AAddresses: TStrings;
begin
  AAddresses := TStringList.Create;
  try
    TIdStack.IncUsage;
    try
      LList := TIdStackLocalAddressList.Create;
      try
        // for backwards compatibility, return only IPv4 addresses
        GStack.GetLocalAddressList(LList);
        if LList.Count > 0 then
        begin
          AAddresses.BeginUpdate;
          try
            for I := 0 to LList.Count - 1 do
            begin
              if LList[I].IPVersion = Id_IPv4 then
              begin
                AAddresses.Add(LList[I].IPAddress + ':' + TIdStackLocalAddressIPv4(LList[I]).SubNetMask);
              end;
            end;
          finally
            AAddresses.EndUpdate;
          end;
        end;
      finally
        LList.Free;
      end;
    finally
      TIdStack.DecUsage;
    end;
    if AAddresses.Count > 0 then
      DStrings.AddStrings(AAddresses); { Assign any addresses to a global StringList }
  finally
    AAddresses.Free;
  end;
end;

procedure TDM.SetHostAndIP; // (Called from DataModuleCreate)
var
  IPStr: string;
begin
  DStrings := TStringList.Create;
  try

    GetIPAddressesAndMasks; // returned in DStrings; procedure above!

    // next lines for debugging
    DStrings.Add('192.168.10.10:255.255.255.0');
    //DStrings.Add('192.168.100.10:255.255.255.0');

    if DStrings.Count = 1 then
    begin
      IPIndex := 0; // if only one remains, use it
    end
    else
      if DStrings.Count > 1 then
      begin
        // rats! there are multiple NICs so find the valid one (192.168.*.*.)
        if not Assigned(FrmMultiNIC) then
          FrmMultiNIC := TfrmMultiNIC.Create(Application);
        if FrmMultiNIC.ShowModal = MrOk then
          IPIndex := FrmMultiNIC.RgIPs.ItemIndex;
      end;

    // Now read selected IP and Mask
    IPStr := DStrings.Strings[IPIndex];
    IPAddr := IPStr.Substring(0, IPStr.IndexOf(':'));
    IPMask := IPStr.Substring(IPStr.IndexOf(':') + 1, Length(IPStr));
    // Set the Broadcast IP Address
    BroadcastIP := GetBroadcastIP(AnsiString(IPAddr), AnsiString(IPMask));

  finally
    DStrings.Free;
  end;

end;

procedure TDM.SiLangDispatcher1LanguageChanged(Sender: TObject);
begin
  // change BiDiMode for Farsi
  if Language = 18 then
    Application.BiDiMode := BdRightToLeft
  else
    Application.BiDiMode := BdLeftToRight;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
var
  RecPath: array [0 .. MAX_PATH] of CHAR;
begin
  AppPath := ExtractFilePath(Application.Exename);
  TheHelpFile := AppPath + 'DR2Video_Help.exe';
  FillChar(RecPath, SizeOf(RecPath), 0);
  if SHGetSpecialFolderPath(0, RecPath, $0023, FALSE) then
  begin
    DataPath := RecPath + '\MDT\DRUtils\'
  end
  else
  begin
    DataPath := '';
  end;
  if Length(DataPath) = 0 then
  begin
    MessageDlg(SiLangRTDM.GetTextOrDefault('IDS_2'
      (* 'Unable to locate Common Application Data folder.' *) ) + #13#10 +
      SiLangRTDM.GetTextOrDefault('IDS_3' (* 'This is a Critical Error.' *) ), MtError, [MbOK], 0);
    Exit;
  end;
  AFormatSettings := TFormatSettings.Create(GetUserDefaultLCID);
  MESettings.BugReportFile := DataPath + 'bugreport_DR2Video.txt';
  DRIniFile := TIniFile.Create(DataPath + 'DR2Video.ini');
  Language := DRIniFile.ReadInteger('General', 'Language', 0);
  TVOut := DRIniFile.ReadInteger('General', 'TVOut', 0);
  CSVOut := DRIniFile.ReadInteger('General', 'CSVOut', 0);
  // make sure not greater than 1
  if TVOut = 2 then
    TVOut := 1;
  EncodeIndex := DRIniFile.ReadInteger('General', 'EncodeIndex', 2);

  DSep := DRIniFile.ReadInteger('General', 'DSep', 0);
  // now have to initialise DecSep (decimal seperator) to match in case the user does not do so
  case DSep of
    0:
      DecSep := AFormatSettings.DecimalSeparator;
    1:
      DecSep := '·';
  end;

  Languages := DRIniFile.ReadString('General', 'Languages', '1110111100111100001');
  FlagsPath := DRIniFile.ReadString('General', 'FlagsPath', 'E:\flags\');
  FlagsExtn := DRIniFile.ReadString('General', 'FlagsExtn', 'tga');
  DivePath := DRIniFile.ReadString('General', 'DivePath', DataPath + 'Temp\Dive.txt');
  SynchroPath := DRIniFile.ReadString('General', 'SynchroPath', DataPath + 'Temp\Synchro.txt');
  RankPath := DRIniFile.ReadString('General', 'RankPath', DataPath + 'Temp\Rank.txt');
  DiveLen := DRIniFile.ReadInteger('General', 'DiveLen', 0);
  Horizontal := DRIniFile.ReadBool('General', 'Horizontal', FALSE);

  // Temporary check for old XLS extensions needing to be updated to TXT
  if DivePath.EndsWith('xls') then
    DivePath := DivePath.Substring(0, DivePath.LastDelimiter('.') + 1) + 'txt';
  if SynchroPath.EndsWith('xls') then
    SynchroPath := SynchroPath.Substring(0, SynchroPath.LastDelimiter('.') + 1) + 'txt';
  if RankPath.EndsWith('xls') then
    RankPath := RankPath.Substring(0, RankPath.LastDelimiter('.') + 1) + 'txt';

  IncludeHeaders := DRIniFile.ReadBool('General', 'IncludeHeaders', True);
  UseHalf := DRIniFile.ReadBool('General', 'UseHalf', True);
  while Length(Languages) < 18 do
    Languages := Languages + '0';
  while Length(Languages) < 19 do
    Languages := Languages + '1';
  SiLangDispatcher1.FileName := DataPath + 'DR2Video.sib';
  if FileExists(SiLangDispatcher1.FileName) then
  begin
    SiLangDispatcher1.LoadAllFromFile(SiLangDispatcher1.FileName);
  end;
  if Language = 0 then
    InitialiseLanguage;
  SiLangDispatcher1.ActiveLanguage := Language;
  LoadPenalties;
  ObtainVersionInfo(Application.Exename);

  // Do next 2 lines AFTER setting the Language
  IPIndex := -1;
  SetHostAndIP;

  EDBEngine1.Active := True;
  DRUSession.Open;

  // does DiveDb exist?
  ConfigurationQuery.SQL.Text := 'SELECT * FROM Databases WHERE Name=' + Engine.QuotedSQLStr('DRUDatabase');
  ConfigurationQuery.Open;
  if (ConfigurationQuery.RecordCount = 0) then
  begin
    // database does not exist .. so create it
    ConfigurationQuery.Close;
    ConfigurationQuery.SQL.Text := 'CREATE DATABASE "DRUDatabase" PATH ' + Engine.QuotedSQLStr(DataPath + 'DRUData');
    ConfigurationQuery.ExecSQL;
  end
  else
  begin
    ConfigurationQuery.Close;
    ConfigurationQuery.SQL.Text := 'ALTER DATABASE "DRUDatabase" PATH ' + Engine.QuotedSQLStr(DataPath + 'DRUData') +
      ' DESCRIPTION ''DiveRecorder Utilities database''';
    ConfigurationQuery.ExecSQL;
  end;

  DiveDb.Open;
  TableCreate('NewTabTVTempResult.SQL');
  TableCreate('NewTabTVScoreB.SQL');
  TempResTable.Open;
  ScoreBTable.Open;
end;

procedure TDM.TableCreate(ScriptFile: string);
begin
  EDBScript1.SQL.Clear;
  EDBScript1.SQL.LoadFromFile(AppPath + 'SQL\' + ScriptFile);
  EDBScript1.ExecScript;
end;

procedure TDM.SiLangRTDMChangeLanguage(Sender: TObject);
begin
  LoadPenalties;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  DRIniFile.WriteInteger('General', 'Language', Language);
  DRIniFile.WriteInteger('General', 'TVOut', TVOut);
  DRIniFile.WriteInteger('General', 'CSVOut', CSVOut);
  DRIniFile.WriteInteger('General', 'EncodeIndex', EncodeIndex);
  DRIniFile.WriteInteger('General', 'DSep', DSep);
  DRIniFile.WriteString('General', 'Languages', Languages);
  DRIniFile.WriteString('General', 'FlagsPath', FlagsPath);
  DRIniFile.WriteString('General', 'FlagsExtn', FlagsExtn);
  DRIniFile.WriteString('General', 'SynchroPath', SynchroPath);
  DRIniFile.WriteString('General', 'DivePath', DivePath);
  DRIniFile.WriteString('General', 'RankPath', RankPath);
  DRIniFile.WriteInteger('General', 'DiveLen', DiveLen);
  DRIniFile.WriteBool('General', 'IncludeHeaders', IncludeHeaders);
  DRIniFile.WriteBool('General', 'UseHalf', UseHalf);
  DRIniFile.WriteBool('General', 'Horizontal', Horizontal);

  TempResTable.Close;
  ScoreBTable.Close;

  EDBScript1.SQL.Clear;
  EDBScript1.SQL.Add('SCRIPT ()');
  EDBScript1.SQL.Add('BEGIN');
  EDBScript1.SQL.Add('EXECUTE IMMEDIATE ''DROP TABLE "TempResult"'';');
  EDBScript1.SQL.Add('EXECUTE IMMEDIATE ''DROP TABLE "ScoreB"'';');
  EDBScript1.SQL.Add('END');

  EDBScript1.ExecScript;
  DiveDb.Close;
  DRIniFile.Free;
end;

procedure TDM.DRUSessionBeforeConnect(Sender: TObject);
begin
  // make sure file paths are correct
  if DRUSession.Connected then
  begin
    DRUSession.Connected := FALSE;
  end;
  DRUSession.LocalConfigPath := DataPath;
  DRUSession.LocalTempTablesPath := DataPath + 'DRUData';
end;

procedure TDM.EDBEngine1BeforeStart(Sender: TObject);
begin
  // make sure file paths are correct
  if EDBEngine1.Active then
  begin
    EDBEngine1.Active := FALSE;
  end;
  EDBEngine1.ConfigPath := DataPath;
  EDBEngine1.TempTablesPath := DataPath + 'DRUData';
end;

procedure TDM.LoadPenalties;
begin
  // load penalty descriptions
  Penalties[0] := '';
  Penalties[1] := SiLangRTDM.GetTextOrDefault('IDS_100' (* 'Failed dive' *) );
  Penalties[2] := SiLangRTDM.GetTextOrDefault('IDS_101' (* 'Restarted' *) ) + #13#10 +
    SiLangRTDM.GetTextOrDefault('IDS_102' (* '-2 points' *) );
  Penalties[3] := SiLangRTDM.GetTextOrDefault('IDS_103' (* 'Flight or Danger' *) ) +
    #13#10 + SiLangRTDM.GetTextOrDefault('IDS_104' (* 'Max 2 points' *) );
  Penalties[4] := SiLangRTDM.GetTextOrDefault('IDS_105' (* 'Arm position' *) ) + #13#10 +
    SiLangRTDM.GetTextOrDefault('IDS_106' (* 'Max 4½ points' *) );
end;

initialization

ClBack := ClBlack;
ClTextA := ClLime;
ClLabels := ClSkyBlue;
AnEncoding := TEncoding.Unicode;

end.
