program DR_UDP_Monitor_V4_2_4;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form7},
  Unit2 in 'Unit2.pas' {Form2},
  Hosts in 'Hosts.pas' {frmHosts},
  MultiNIC in 'MultiNIC.pas' {frmMultiNIC},
  UdpMetrics in 'UdpMetrics.pas' {DataModule1: TDataModule},
  FormMetrics in 'FormMetrics.pas' {Metrics},
  Display in 'Display.pas' {frmDisplay},
  DiveDM in 'DiveDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TfrmHosts, frmHosts);
  Application.CreateForm(TfrmMultiNIC, frmMultiNIC);
  Application.CreateForm(TMetrics, Metrics);
  Application.CreateForm(TMetrics, Metrics);
  Application.CreateForm(TfrmDisplay, frmDisplay);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
