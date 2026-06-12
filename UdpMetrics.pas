{ ************************************* }
{ Copyright(c) 2022-2026  Andy Hewat    }
{ ************************************* }

{
  This is the 'Metrics' display unit.  Intention is that the button to 'Decode Selected' also
  selects the port for the metrics engine to work on.  This is sort of fixed in this version as
  only port 58091 and Referee and Update are analysised.

}

unit UdpMetrics;

interface

uses
  System.SysUtils, System.SyncObjs;

type
  // Only REFEREE and UPDATE for now
  T58091MsgKind = (mkReferee, mkUpdate);

  // Run-length histogram
  // Index:
  //   1..9  = exact run length
  //   10    = 10 or more
  TRunHist = array[0..10] of Integer;

  // Per-origin metrics
  POriginMetrics = ^TOriginMetrics;
  TOriginMetrics = record
    // Sliding window of last 5 run lengths
    Window: array[0..4] of Integer;
    WindowIndex: Integer;      // 0..4
    WindowCount: Integer;      // how many entries are valid (0..5)

    MovAvgRun: Double;         // moving average of last 5 runs

    IncompleteCount: Integer;  // missing caret
    ExtraFieldCount: Integer;  // not currently used
    CorruptCount: Integer;     // caret not at end
    UnknownTypeCount: Integer; // unknown header

    RunHist: TRunHist;         //
    AvgGapMs: UInt64;          // average packet gap in ms
  end;

var
  // Metrics for port 58091 only (for now)
  Metrics58091Referee:  array[0..255] of TOriginMetrics;
  Metrics58091Update:   array[0..255] of TOriginMetrics;
  Metrics58091Identity: array[0..255] of string;
  MetricsCS: TCriticalSection;

procedure InitMetrics58091;
procedure Metrics58091_ResetAll;
procedure Metrics58091_AddRun(Kind: T58091MsgKind; Origin, RunLen: Integer);
procedure Metrics58091_IncIncomplete(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_IncExtra(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_IncCorrupt(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_IncUnknown(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_ObserveGap(Kind: T58091MsgKind; Origin: Integer; GapMs: UInt64);


implementation

// ------------------------------------------------------------
// Internal helpers
// ------------------------------------------------------------

procedure ClearOriginMetrics(var M: TOriginMetrics);
var
  i: Integer;
begin
  for i := 0 to 4 do
    M.Window[i] := 0;

  M.WindowIndex := 0;
  M.WindowCount := 0;
  M.MovAvgRun := 0.0;

  M.IncompleteCount := 0;
  M.ExtraFieldCount := 0;
  M.CorruptCount := 0;
  M.UnknownTypeCount := 0;

  for i := Low(M.RunHist) to High(M.RunHist) do
    M.RunHist[i] := 0;

  M.AvgGapMs := 0;
end;

procedure Metrics58091_ResetAll;
begin
  MetricsCS.Enter;
  try
    InitMetrics58091;
  finally
    MetricsCS.Leave;
  end;
end;

procedure InitMetrics58091;
var
  i: Integer;
begin
  for i := 0 to 255 do
  begin
    ClearOriginMetrics(Metrics58091Referee[i]);
    ClearOriginMetrics(Metrics58091Update[i]);
    Metrics58091Identity[i] := '';
  end;
end;

function GetMetricsRef(Kind: T58091MsgKind; Origin: Integer): POriginMetrics;
begin
  if (Origin < 0) or (Origin > 255) then
    Exit(nil);

  case Kind of
    mkReferee: Result := @Metrics58091Referee[Origin];
    mkUpdate:  Result := @Metrics58091Update[Origin];
  else
    Result := nil;
  end;
end;

procedure Metrics58091_ObserveGap(Kind: T58091MsgKind; Origin: Integer; GapMs: UInt64);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
        P^.AvgGapMs := GapMs;
  finally
    MetricsCS.Leave;
  end;
end;

procedure UpdateSlidingWindow(var M: TOriginMetrics; RunLen: Integer);
var
  i, Sum: Integer;
begin
  // Insert run length into sliding window
  M.Window[M.WindowIndex] := RunLen;

  Inc(M.WindowIndex);
  if M.WindowIndex > 4 then
    M.WindowIndex := 0;

  if M.WindowCount < 5 then
    Inc(M.WindowCount);

  // Recompute moving average
  Sum := 0;
  for i := 0 to M.WindowCount - 1 do
    Sum := Sum + M.Window[i];

  if M.WindowCount > 0 then
    M.MovAvgRun := Sum / M.WindowCount
  else
    M.MovAvgRun := 0.0;
end;

// ------------------------------------------------------------
// Public API used by UDP handlers
// ------------------------------------------------------------

procedure Metrics58091_AddRun(Kind: T58091MsgKind; Origin, RunLen: Integer);
var
  P: POriginMetrics;
  Bucket: Integer;
begin
  if RunLen <= 0 then Exit;

  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P = nil then Exit;

    if RunLen >= 10 then
      Bucket := 10
    else
      Bucket := RunLen;

    Inc(P^.RunHist[Bucket]);
    UpdateSlidingWindow(P^, RunLen);
  finally
    MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncIncomplete(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.IncompleteCount);
  finally
    MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncExtra(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.ExtraFieldCount);
  finally
     MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncCorrupt(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.CorruptCount);
  finally
     MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncUnknown(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.UnknownTypeCount);
  finally
    MetricsCS.Leave;
  end;
end;

initialization
  MetricsCS := TCriticalSection.Create;
finalization
  MetricsCS.Free;

end.

{ ************************************* }
{ Copyright(c) 2022-2026  Andy Hewat    }
{ ************************************* }

{
  This is the 'Metrics' display unit.  Intention is that the button to 'Decode Selected' also
  selects the port for the metrics engine to work on.  This is sort of fixed in this version as
  only port 58091 and Referee and Update are analysised.

}

unit UdpMetrics;

interface

uses
  System.SysUtils, System.SyncObjs;

type
  // Only REFEREE and UPDATE for now
  T58091MsgKind = (mkReferee, mkUpdate);

  // Run-length histogram
  // Index:
  //   1..9  = exact run length
  //   10    = 10 or more
  TRunHist = array[0..10] of Integer;

  // Per-origin metrics
  POriginMetrics = ^TOriginMetrics;
  TOriginMetrics = record
    // Sliding window of last 5 run lengths
    Window: array[0..4] of Integer;
    WindowIndex: Integer;      // 0..4
    WindowCount: Integer;      // how many entries are valid (0..5)

    MovAvgRun: Double;         // moving average of last 5 runs

    IncompleteCount: Integer;  // missing caret
    ExtraFieldCount: Integer;  // not currently used
    CorruptCount: Integer;     // caret not at end
    UnknownTypeCount: Integer; // unknown header

    RunHist: TRunHist;         //
    AvgGapMs: UInt64;          // average packet gap in ms
  end;

var
  // Metrics for port 58091 only (for now)
  Metrics58091Referee:  array[0..255] of TOriginMetrics;
  Metrics58091Update:   array[0..255] of TOriginMetrics;
  Metrics58091Identity: array[0..255] of string;
  MetricsCS: TCriticalSection;

procedure InitMetrics58091;
procedure Metrics58091_ResetAll;
procedure Metrics58091_AddRun(Kind: T58091MsgKind; Origin, RunLen: Integer);
procedure Metrics58091_IncIncomplete(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_IncExtra(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_IncCorrupt(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_IncUnknown(Kind: T58091MsgKind; Origin: Integer);
procedure Metrics58091_ObserveGap(Kind: T58091MsgKind; Origin: Integer; GapMs: UInt64);


implementation

// ------------------------------------------------------------
// Internal helpers
// ------------------------------------------------------------

procedure ClearOriginMetrics(var M: TOriginMetrics);
var
  i: Integer;
begin
  for i := 0 to 4 do
    M.Window[i] := 0;

  M.WindowIndex := 0;
  M.WindowCount := 0;
  M.MovAvgRun := 0.0;

  M.IncompleteCount := 0;
  M.ExtraFieldCount := 0;
  M.CorruptCount := 0;
  M.UnknownTypeCount := 0;

  for i := Low(M.RunHist) to High(M.RunHist) do
    M.RunHist[i] := 0;

  M.AvgGapMs := 0;
end;

procedure Metrics58091_ResetAll;
begin
  MetricsCS.Enter;
  try
    InitMetrics58091;
  finally
    MetricsCS.Leave;
  end;
end;

procedure InitMetrics58091;
var
  i: Integer;
begin
  for i := 0 to 255 do
  begin
    ClearOriginMetrics(Metrics58091Referee[i]);
    ClearOriginMetrics(Metrics58091Update[i]);
    Metrics58091Identity[i] := '';
  end;
end;

function GetMetricsRef(Kind: T58091MsgKind; Origin: Integer): POriginMetrics;
begin
  if (Origin < 0) or (Origin > 255) then
    Exit(nil);

  case Kind of
    mkReferee: Result := @Metrics58091Referee[Origin];
    mkUpdate:  Result := @Metrics58091Update[Origin];
  else
    Result := nil;
  end;
end;

procedure Metrics58091_ObserveGap(Kind: T58091MsgKind; Origin: Integer; GapMs: UInt64);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
        P^.AvgGapMs := GapMs;
  finally
    MetricsCS.Leave;
  end;
end;

procedure UpdateSlidingWindow(var M: TOriginMetrics; RunLen: Integer);
var
  i, Sum: Integer;
begin
  // Insert run length into sliding window
  M.Window[M.WindowIndex] := RunLen;

  Inc(M.WindowIndex);
  if M.WindowIndex > 4 then
    M.WindowIndex := 0;

  if M.WindowCount < 5 then
    Inc(M.WindowCount);

  // Recompute moving average
  Sum := 0;
  for i := 0 to M.WindowCount - 1 do
    Sum := Sum + M.Window[i];

  if M.WindowCount > 0 then
    M.MovAvgRun := Sum / M.WindowCount
  else
    M.MovAvgRun := 0.0;
end;

// ------------------------------------------------------------
// Public API used by UDP handlers
// ------------------------------------------------------------

procedure Metrics58091_AddRun(Kind: T58091MsgKind; Origin, RunLen: Integer);
var
  P: POriginMetrics;
  Bucket: Integer;
begin
  if RunLen <= 0 then Exit;

  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P = nil then Exit;

    if RunLen >= 10 then
      Bucket := 10
    else
      Bucket := RunLen;

    Inc(P^.RunHist[Bucket]);
    UpdateSlidingWindow(P^, RunLen);
  finally
    MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncIncomplete(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.IncompleteCount);
  finally
    MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncExtra(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.ExtraFieldCount);
  finally
     MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncCorrupt(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.CorruptCount);
  finally
     MetricsCS.Leave;
  end;
end;

procedure Metrics58091_IncUnknown(Kind: T58091MsgKind; Origin: Integer);
var
  P: POriginMetrics;
begin
  MetricsCS.Enter;
  try
    P := GetMetricsRef(Kind, Origin);
    if P <> nil then
      Inc(P^.UnknownTypeCount);
  finally
    MetricsCS.Leave;
  end;
end;

initialization
  MetricsCS := TCriticalSection.Create;
finalization
  MetricsCS.Free;

end.
