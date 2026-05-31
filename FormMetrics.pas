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
  Vcl.StdCtrls, udpMetrics;

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
    function  FormatRunHistCompact(const H: TRunHist): string;
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
  COL_RUNS    = 6;

procedure TMetrics.SetupGrid(Grid: TStringGrid);
begin
  Grid.DefaultDrawing := False;
  Grid.OnDrawCell := GridDrawCell;

  Grid.ColCount := 7;

  Grid.FixedRows := 1;
  Grid.RowCount  := 2;  // MUST be > FixedRows

  Grid.Cells[0, 0] := 'Origin';
  Grid.Cells[1, 0] := 'MovAvg';
  Grid.Cells[2, 0] := 'Incomplete';
  Grid.Cells[3, 0] := 'Extra';
  Grid.Cells[4, 0] := 'Corrupt';
  Grid.Cells[5, 0] := 'Unknown';
  Grid.Cells[6, 0] := 'Runs';

  Grid.ColWidths[0] := 130;
  Grid.ColWidths[1] := 60;
  Grid.ColWidths[6] := 200;
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
  // Reset underlying metrics
  Metrics58091_ResetAll;

  // Rebuild grids from (now empty) metrics
  RefreshForPort58091;

  // Force visual redraw
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
        (M^.UnknownTypeCount > 0)) then
    begin
       AddedAny := True;
       Grid.RowCount := Row + 1;

      OriginLabel := Metrics58091Identity[Origin];
      if OriginLabel <> '' then
        Grid.Cells[0, Row] := OriginLabel
      else
        Grid.Cells[0, Row] := IntToStr(Origin);

      Grid.Cells[1, Row] := FormatFloat('0.0', M^.MovAvgRun);
      Grid.Cells[2, Row] := IntToStr(M^.IncompleteCount);
      Grid.Cells[3, Row] := IntToStr(M^.ExtraFieldCount);
      Grid.Cells[4, Row] := IntToStr(M^.CorruptCount);
      Grid.Cells[5, Row] := IntToStr(M^.UnknownTypeCount);
      Grid.Cells[6, Row] := FormatRunHistCompact(M^.RunHist);

      Inc(Row);
    end;
  end;

 //  Placeholder if no data
  if not AddedAny then
  begin
    Grid.RowCount := Grid.FixedRows + 1;    // exactly one display row
    Grid.Cells[COL_ORIGIN, Grid.FixedRows] := '<No data yet>';
    Grid.Cells[COL_MOVAVG, Grid.FixedRows] := '';
    Grid.Cells[2, Grid.FixedRows] := '';
    Grid.Cells[3, Grid.FixedRows] := '';
    Grid.Cells[4, Grid.FixedRows] := '';
    Grid.Cells[5, Grid.FixedRows] := '';
    Grid.Cells[COL_RUNS, Grid.FixedRows] := '';
  end

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
  IsPlaceholder: Boolean;
begin
  Grid := Sender as TStringGrid;

  // Header row
  if (ARow = 0) then
  begin
    Grid.Canvas.Brush.Color := clBtnFace;
    Grid.Canvas.FillRect(Rect);
    Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, Grid.Cells[ACol, ARow]);
    Exit;
  end;

  IsPlaceholder := SameText(Grid.Cells[COL_ORIGIN, ARow], '<No data yet>');

  // Default background
  Grid.Canvas.Brush.Color := clWindow;

  // Placeholder styling
  if IsPlaceholder then
  begin
    Grid.Canvas.Brush.Color := clBtnFace;     // subtle grey background
    Grid.Canvas.Font.Color := clGrayText;
    Grid.Canvas.Font.Style := [fsItalic];
  end
  else
  begin
    Grid.Canvas.Font.Color := clWindowText;
    Grid.Canvas.Font.Style := [];
  end;

  // MovAvg colouring only for real rows
  if (not IsPlaceholder) and (ACol = COL_MOVAVG) then
  begin
    Avg := StrToFloatDef(Grid.Cells[ACol, ARow], 0.0);

    if Avg >= 2.8 then
      Grid.Canvas.Brush.Color := clMoneyGreen
    else if Avg >= 2.0 then
      Grid.Canvas.Brush.Color := clYellow
    else
      Grid.Canvas.Brush.Color := clRed;
  end;

  Grid.Canvas.FillRect(Rect);

  // If placeholder: draw message across the whole row (looks better)
  if IsPlaceholder and (ACol = COL_ORIGIN) then
    Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, Grid.Cells[ACol, ARow])
  else if not IsPlaceholder then
    Grid.Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, Grid.Cells[ACol, ARow])
  else
  begin
    // For placeholder row, blank other columns (already blank) so do nothing
  end;
end;

end.
``
