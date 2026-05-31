{ ************************************* }
{ Copyright(c) 2022-2026  Andy Hewat    }
{ ************************************* }

{
  A Unit for Andy's DR-UDP Monitor programme.
  Used to 'decode' the DR UDP data packets for display in a second window.

    Jan 2025 Comments added.  Original code generated sometime in 2022 or thereabouts!
    May 2026 Refactored to clean up code.
}

unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Math, gdipapi, gdipobj, gdiputil,
  vcl.Direct2D, Winapi.D2D1, Vcl.Samples.Spin, Vcl.ComCtrls, Vcl.DBCtrls,
  Vcl.Grids;

type
  TForm2 = class(TForm)
    Decode: TButton;
    ListView1: TListView;
    Clear: TButton;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    StringGrid1: TStringGrid;
    procedure DecodeClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  const
    x : string = '';
    y : string = '';

    refereeArray : array [0..74] of string = (
      'Header',
      'Event A or B',
      'Hostname',
      'Event Mode',
      'New Event?',
      'Round',
      'Attempt',
      'Start No',
      'Dvr A Name, Team Code',
      'Diver A Family Name',
      'Dvr B Name, Team Code',
      'Diver B Family Name',
      'Dive Number',
      'Flight Postn',
      'Tarrif',
      'Board Height',
      'J1 Award',
      'J2 Award',
      'J3 Award',
      'J4 Award',
      'J5 Award',
      'J6 Award',
      'J7 Award',
      'J8 Award',
      'J9 Award',
      'J10 Award',
      'J11 Award',
      'Total Awards',
      'Score',
      'Total',
      'Scoreboard Display Mode',
      'Running Ranking',
      'Award Needed for Best',
      'Predicted Rank',
      'Background Colour',
      'AText Colour',
      'BText Colour',
      'Caption Colour',
      'Message Line 1',
      'Message Line 2',
      'Message Line 3',
      'Message Line 4',
      'Message Line 5',
      'Message Line 6',
      'Message Line 7',
      'Message Line 8',
      'Synchro?',
      'Show running total?',
      'Show predictions?',
      'No of Judges',
      'Penalty Code',
      'Station No (circuit)',
      'No of Stations',
      'Diver A First Nmae',
      'Diver A Club Name',
      'Diver A Club Code',
      'Diver B First Name',
      'Diver B Club Name',
      'Diver B CLub Code',
      'Event Title',
      'Dive Description',
      'Meet Title',
      'No of Rounds',
      'No of Divers',
      'Short Dive Description',
      'Conversion Factor',
      'Short Event Title',
      'Team A2',
      'Team Code A2',
      'Team B2',
      'Team Code B2',
      'Seconds per Dive',
      'Do Not Ranl',
      'Team Event?',
      'EoM marker'
    );

    awardArray: array[0..14] of string = (   // used for 58091 and 58094
      'Header',
      'Hostname',
      'Event Mode',
      'J1 award',
      'J2 award',
      'J3 award',
      'J4 award',
      'J5 award',
      'J6 award',
      'J7 award',
      'J8 award',
      'J9 award',
      'J10 award',
      'J11 award',
      'EoM marker'
    );

    updateArray: array[0..6] of string = (
      'Header',
      'Event A or B',
      'Sender Hostname',
      'Event Mode',
      'IP Address of DR Host',
      'Full path to Update',
      'EoM marker'
    );

    sbcontrolArray: array[0..1] of string = (
      'Header',
      'EoM marker'
    );

    drconfigArray: array[0..4] of string = (
      'Header',
      'Hostname of Target SB',
      'Hostname of SBs DR Host',
      'Scoreboard Style',
      'EoM marker'
    );

    avideoArray: array[0..5] of string = (
      'Header',
      'Event A or B',
      'Hostname',
      'Event Mode',
      'Event ended?',
      'EoM marker'
    );

    scoreboardArray: array[0..4] of string = (
      'Header',
      'Senders Hostname',
      'DR Hostname',
      'Event Mode',
      'Scoreboard Layout'
    );

    helloArray: array[0..0] of string = (
      'Header'
    );

    foundserverArray: array[0..3] of string = (
      'Header',
      'Servers Hostname',
      'Servers IP Address',
      'DR File Product Version'
    );

    dbserverArray: array[0..0] of string = (
      'Header'
    );

    diverecorderArray: array[0..2] of string = (
      'Header',
      'DiveRecorder Host Name',
      'EoM marker'
    );

    webupdateArray: array[0..6] of string = (
      'Header',
      'Event A or B',
      'Hostname of sender',
      'Event mode',
      'Senders IP address',
      'Full path to data file on sending host',
      'EoM marker'
    );

    webmessageArray: array[0..5] of string = (
      'Header',
      'Destination file on web for scoreboard message',
      'Home folder on web for meet',
      'Event A or B',
      'Upto 8 rows of text',
      'EoM marker'
    );

    startresultArray: array[0..5] of string = (
      'Header',
      'Destination file name. Starts with S_ or R_',
      'Event Title',
      '*** File Structure Variable from here on ***',
      '***             NOT DECODED              ***',
      'EoM marker'
    );

    clearABArray: array[0..1] of string = (
      'Header',
      'EoM marker'
    );

  end;

var
  Form2: TForm2;
  btnPressedOld : integer = 0;
  array2display : TArray<string>;
  udpArray1   :  TArray<string>;
  udpArray2   :  TArray<string>;
  udpArray3   :  TArray<string>;
  udpArray4   :  TArray<string>;
  headerArray : array of string;

implementation

{$R *.dfm}

uses Main;

procedure TForm2.CheckBox1Click(Sender: TObject);       // Continous Decode
begin
  // for some data soon!
end;

procedure TForm2.ClearClick(Sender: TObject);          // Clear
begin
  ListView1.Items.Clear;
  SetLength(udpArray1, 0);
  SetLength(udpArray2, 0);
  SetLength(udpArray3, 0);
  SetLength(udpArray4, 0);
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  Column: TListColumn;
begin
  btnPressedOld := 0;
  ListView1.FlatScrollBars := true;

  // Generate the 5 column headings, no data
  Column := ListView1.Columns.Add;
  Column.Caption := 'Function';
  Column.Alignment := taLeftJustify;
  Column.Width := 220;

  Column := ListView1.Columns.Add;
  Column.Caption := 'Data';
  Column.Alignment := taLeftJustify;
  Column.Width := 220;

  Column := ListView1.Columns.Add;
  Column.Caption := 'Data';
  Column.Alignment := taLeftJustify;
  Column.Width := 220;

  Column := ListView1.Columns.Add;
  Column.Caption := 'Data';
  Column.Alignment := taLeftJustify;
  Column.Width := 220;

  Column := ListView1.Columns.Add;
  Column.Caption := 'Data';
  Column.Alignment := taLeftJustify;
  Column.Width := 220;
end;

procedure TForm2.DecodeClick(Sender: TObject);          // Decode
var
  i: Integer;
  ListItem: TListItem;
  extra1, extra2, extra3, extra4: Integer;
  totalExtra: Integer;

  procedure CopyHeader(const Src: array of string);
  var
    j: Integer;
  begin
    SetLength(headerArray, Length(Src));
    for j := 0 to High(Src) do
      headerArray[j] := Src[j];
  end;

  begin
  // Select header and data array based on btnPressed
    case Form7.btnPressed of
      1 : begin
            CopyHeader(refereeArray);
            Label1.Caption := 'Port58091 - Referee message selected';
            array2display := Form7.refereeArray1;
          end;
      2 : begin
            CopyHeader(avideoArray);
            Label1.Caption := 'Port58091 - AVideo message selected';
            array2display := Form7.avideoArray1;
          end;
      3 : begin
            CopyHeader(updateArray);
            Label1.Caption := 'Port58091 - Update message selected';
            array2display := Form7.updateArray1;
          end;
      5 : begin
            CopyHeader(sbcontrolArray);
            Label1.Caption := 'Port58091 - SBControl message selected';
            array2display := Form7.sbcontrolArray1;
          end;
      4 : begin
            CopyHeader(drconfigArray);
            Label1.Caption := 'Port58091 - DRConfig message selected';
            array2display := Form7.drconfigArray1;
          end;
      6 : begin
            CopyHeader(awardArray);
            Label1.Caption := 'Port58091 - Award message selected';
            array2display := Form7.awardArray1;
          end;
      7 : begin
            CopyHeader(scoreboardArray);
            Label1.Caption := 'Port58092 - Scoreboard message selected';
            array2display := Form7.splitString2;
          end;
      8 : begin
            CopyHeader(helloArray);
            Label1.Caption := 'Port58092 - Hello message selected';
            array2display := Form7.splitString2;
          end;
      9 : begin
            CopyHeader(foundserverArray);
            Label1.Caption := 'Port58092 - FoundServer message selected';
            array2display := Form7.splitString2;
          end;
      10: begin
            CopyHeader(dbserverArray);
            Label1.Caption := 'Port58092 - DBServer message selected';
            array2display := Form7.splitString2;
          end;
      11: begin
            CopyHeader(diverecorderArray);
            Label1.Caption := 'Port58093 - Diverecoder message selected';
            array2display := Form7.splitString3;
          end;
      12: begin
            CopyHeader(webupdateArray);
            Label1.Caption := 'Port58093 - WebUpdate message selected';
            array2display := Form7.splitString3;
          end;
      13: begin
            CopyHeader(webmessageArray);
            Label1.Caption := 'Port58093 - WebMessage message selected';
            array2display := Form7.splitString3;
          end;
      14: begin
            CopyHeader(startresultArray);
            Label1.Caption := 'Port58093 - StartResult message selected';
            array2display := Form7.splitString3;
          end;
      15: begin
            CopyHeader(awardArray);
            Label1.Caption := 'Port58094 - Award message selected';
            array2display := Form7.splitString4;
          end;
      16: begin
            CopyHeader(clearABArray);
            Label1.Caption := 'Port58093 - Clear_A/B message selected';
            array2display := Form7.splitString3;
          end;
    else
    Exit; // unknown btnPressed
  end;

  // If no data available, do nothing
  if Length(array2display) = 0 then
    Exit;

  // FIFO SCROLL: shift old decodes down, newest goes into column 1
  udpArray4 := udpArray3;
  udpArray3 := udpArray2;
  udpArray2 := udpArray1;
  udpArray1 := array2display;

  // Clear the view and rebuild from udpArray1..4
  ListView1.Items.Clear;

  // Calculate extra fields per column (beyond headerArray length)
  if Length(udpArray1) > Length(headerArray) then
    extra1 := Length(udpArray1) - Length(headerArray)
  else
    extra1 := 0;

  if Length(udpArray2) > Length(headerArray) then
    extra2 := Length(udpArray2) - Length(headerArray)
  else
    extra2 := 0;

  if Length(udpArray3) > Length(headerArray) then
    extra3 := Length(udpArray3) - Length(headerArray)
  else
    extra3 := 0;

  if Length(udpArray4) > Length(headerArray) then
    extra4 := Length(udpArray4) - Length(headerArray)
  else
    extra4 := 0;

  totalExtra := extra1 + extra2 + extra3 + extra4;

  // Build rows: always show all header fields (Option A)
  for i := 0 to Length(headerArray) - 1 do
  begin
    ListItem := ListView1.Items.Add;
    ListItem.Caption := headerArray[i];

    // Column 1
    if Length(udpArray1) > 0 then
    begin
      if i < Length(udpArray1) then
        ListItem.SubItems.Add(udpArray1[i])
      else
        ListItem.SubItems.Add('');
    end;

    // Column 2
    if Length(udpArray2) > 0 then
    begin
      if i < Length(udpArray2) then
        ListItem.SubItems.Add(udpArray2[i])
      else
        ListItem.SubItems.Add('');
    end;

    // Column 3
    if Length(udpArray3) > 0 then
    begin
      if i < Length(udpArray3) then
        ListItem.SubItems.Add(udpArray3[i])
      else
        ListItem.SubItems.Add('');
    end;

    // Column 4
    if Length(udpArray4) > 0 then
    begin
      if i < Length(udpArray4) then
        ListItem.SubItems.Add(udpArray4[i])
      else
        ListItem.SubItems.Add('');
    end;
  end;

  // If any column had extra fields, add a final row indicating that
  if totalExtra > 0 then
  begin
    ListItem := ListView1.Items.Add;
    ListItem.Caption := 'Extra fields present:';

    if Length(udpArray1) > 0 then
    begin
      if extra1 > 0 then
        ListItem.SubItems.Add(IntToStr(extra1))
      else
        ListItem.SubItems.Add('');
    end;

    if Length(udpArray2) > 0 then
    begin
      if extra2 > 0 then
        ListItem.SubItems.Add(IntToStr(extra2))
      else
        ListItem.SubItems.Add('');
    end;

    if Length(udpArray3) > 0 then
    begin
      if extra3 > 0 then
        ListItem.SubItems.Add(IntToStr(extra3))
      else
        ListItem.SubItems.Add('');
    end;

    if Length(udpArray4) > 0 then
    begin
      if extra4 > 0 then
        ListItem.SubItems.Add(IntToStr(extra4))
      else
        ListItem.SubItems.Add('');
    end;
  end;
end;

end.
