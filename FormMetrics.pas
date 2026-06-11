{ ************************************* }
{ Copyright(c) 2022-2026  Andy Hewat    }
{ ************************************* }

{
  This is the 'Metrics' display unit.  Intention is that the button to 'Decode Selected' also
  selects the port for the metrics engine to work on.  This is sort of fixed in this version.

}

unit FormMetrics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  Vcl.StdCtrls, UdpMetrics;

type
  TMetrics = class(TForm)
    GridReferee: TStringGrid;
    GridUpdate: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    btnReset: TButton;

    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure SetupGrid(Grid: TStringGrid);
    procedure FillGridForKind(Grid: TStringGrid; Kind: T58091MsgKind);
    function FormatRunHistCompact(const H: TRunHist): string;
  public
    procedure RefreshForPort58091;
  end;

var
  Metrics: TMetrics;

implementation

{$R *.dfm}

const
  COL_ORIGIN  = 0;
  COL_MOVAVG  = 1;
  COL_MAXGAP  = 2;
  COL_INCOMP  = 3;
  COL_EXTRA   = 4;
  COL_CORRUPT = 5;
  COL_UNKNOWN = 6;
  COL_RUNS    = 7;

procedure TMetrics.SetupGrid(Grid: TStringGrid);
begin
  Grid.DefaultDrawing := False;
  Grid.OnDrawCell := GridDrawCell;

  Grid.ColCount := 8;
  Grid.FixedRows := 1;
  Grid.RowCount := 2;

  Grid.Cells[COL_ORIGIN, 0]  := 'Origin';
  Grid.Cells[COL_MOVAVG, 0]  := 'MovAvg';
  Grid.Cells[COL_MAXGAP, 0]  := 'AvgGap ms';
  Grid.Cells[COL_INCOMP, 0]  := 'Incomplete';
  Grid.Cells[COL_EXTRA, 0]   := 'Extra';
  Grid.Cells[COL_CORRUPT, 0] := 'Corrupt';
  Grid.Cells[COL_UNKNOWN, 0] := 'Unknown';
  Grid.Cells[COL_RUNS, 0]    := 'Runs';

  Grid.ColWidths[COL_ORIGIN]  := 130;
  Grid.ColWidths[COL_MOVAVG]  := 60;
  Grid.ColWidths[COL_MAXGAP]  := 80;
  Grid.ColWidths[COL_INCOMP]  := 70;
  Grid.ColWidths[COL_EXTRA]   := 55;
  Grid.ColWidths[COL_CORRUPT] := 55;
  Grid.ColWidths[COL_UNKNOWN] := 60;
  Grid.ColWidths[COL_RUNS]    := 200;
end;

function TMetrics.FormatRunHistCompact(const H: TRunHist): string;
var
  More, i: Integer;
begin
  More := 0;
  for i := 4 to 10 do
    Inc(More, H[i]);

  Result := Format('1:%d  2:%d  3:%d  4+:%d',
    [H[1], H[2], H[3], More]);
end;

procedure TMetrics.FormCreate(Sender: TObject);
begin
  SetupGrid(GridReferee);
  SetupGrid(GridUpdate);
end;

procedure TMetrics.btnResetClick(Sender: TObject);
begin
  Metrics58091_ResetAll;
  RefreshForPort58091;
  GridReferee.Repaint;
  GridUpdate.Repaint;
end;

procedure TMetrics.FillGridForKind(Grid: TStringGrid; Kind: T58091MsgKind);
var
  Origin: Integer;
  M: POriginMetrics;
  Row: Integer;
  OriginLabel: string;
  AddedAny: Boolean;
begin
  Grid.RowCount := Grid.FixedRows + 1;
  Row := Grid.FixedRows;
  AddedAny := False;

  for Origin := 0 to 255 do
  begin
    case Kind of
      mkReferee: M := @Metrics58091Referee[Origin];
      mkUpdate:  M := @Metrics58091Update[Origin];
    else
      M := nil;
    end;

    if (M <> nil) and
       ((M^.WindowCount > 0) or
        (M^.IncompleteCount > 0) or
        (M^.ExtraFieldCount > 0) or
        (M^.CorruptCount > 0) or
        (M^.UnknownTypeCount > 0) or
        (M^.AvgGapMs > 0)) then
    begin
      AddedAny := True;
      Grid.RowCount := Row + 1;

      OriginLabel := Metrics58091Identity[Origin];
      if OriginLabel <> '' then
        Grid.Cells[COL_ORIGIN, Row] := OriginLabel
      else
        Grid.Cells[COL_ORIGIN, Row] := IntToStr(Origin);

      Grid.Cells[COL_MOVAVG, Row]  := FormatFloat('0.0', M^.MovAvgRun);
      Grid.Cells[COL_MAXGAP, Row]  := IntToStr(M^.AvgGapMs);
      Grid.Cells[COL_INCOMP, Row]  := IntToStr(M^.IncompleteCount);
      Grid.Cells[COL_EXTRA, Row]   := IntToStr(M^.ExtraFieldCount);
      Grid.Cells[COL_CORRUPT, Row] := IntToStr(M^.CorruptCount);
      Grid.Cells[COL_UNKNOWN, Row] := IntToStr(M^.UnknownTypeCount);
      Grid.Cells[COL_RUNS, Row]    := FormatRunHistCompact(M^.RunHist);

      Inc(Row);
    end;
  end;

  if not AddedAny then
  begin
    Grid.RowCount := Grid.FixedRows + 1;
    Grid.Cells[COL_ORIGIN,  Grid.FixedRows] := '<No data yet>';
    Grid.Cells[COL_MOVAVG,  Grid.FixedRows] := '';
    Grid.Cells[COL_MAXGAP,  Grid.FixedRows] := '';
    Grid.Cells[COL_INCOMP,  Grid.FixedRows] := '';
    Grid.Cells[COL_EXTRA,   Grid.FixedRows] := '';
    Grid.Cells[COL_CORRUPT, Grid.FixedRows] := '';
    Grid.Cells[COL_UNKNOWN, Grid.FixedRows] := '';
    Grid.Cells[COL_RUNS,    Grid.FixedRows] := '';
  end;
end;

procedure TMetrics.RefreshForPort58091;
begin
  GridReferee.BeginUpdate;
  GridUpdate.BeginUpdate;
  try
    FillGridForKind(GridReferee, mkReferee);
    FillGridForKind(GridUpdate, mkUpdate);
  finally
    GridReferee.EndUpdate;
    GridUpdate.EndUpdate;
  end;

  GridReferee.Repaint;
  GridUpdate.Repaint;
end;

procedure TMetrics.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Grid: TStringGrid;
  Avg: Double;
  Gap: Integer;
  IsPlaceholder: Boolean;
begin
  Grid := Sender as TStringGrid;

  // Header row
  if ARow = 0 then
  begin
    Grid.Canvas.Brush.Color := clBtnFace;
    Grid.Canvas.Font.Color := clWindowText;
    Grid.Canvas.Font.Style := [];
    Grid.Canvas.FillRect(Rect);
    Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, Grid.Cells[ACol, ARow]);
    Exit;
  end;

  IsPlaceholder := SameText(Grid.Cells[COL_ORIGIN, ARow], '<No data yet>');

  Grid.Canvas.Brush.Color := clWindow;
  Grid.Canvas.Font.Color := clWindowText;
  Grid.Canvas.Font.Style := [];

  if IsPlaceholder then
  begin
    Grid.Canvas.Brush.Color := clBtnFace;
    Grid.Canvas.Font.Color := clGrayText;
    Grid.Canvas.Font.Style := [fsItalic];
  end
  else
  begin
    if ACol = COL_MOVAVG then
    begin
      Avg := StrToFloatDef(Grid.Cells[ACol, ARow], 0.0);

      if Avg >= 2.8 then
        Grid.Canvas.Brush.Color := clMoneyGreen
      else if Avg >= 2.0 then
        Grid.Canvas.Brush.Color := clYellow
      else
        Grid.Canvas.Brush.Color := clRed;
    end
    else if ACol = COL_MAXGAP then
    begin
      Gap := StrToIntDef(Grid.Cells[ACol, ARow], 0);

      if Gap <= 60 then
        Grid.Canvas.Brush.Color := clMoneyGreen
      else if Gap <= 90 then
        Grid.Canvas.Brush.Color := clYellow
      else
        Grid.Canvas.Brush.Color := clRed;
    end;
  end;

  Grid.Canvas.FillRect(Rect);

  if IsPlaceholder then
  begin
    if ACol = COL_ORIGIN then
      Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, Grid.Cells[ACol, ARow]);
  end
  else
    Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, Grid.Cells[ACol, ARow]);
end;

end.
