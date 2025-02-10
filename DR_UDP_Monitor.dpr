program DR_UDP_Monitor;

uses
  Vcl.Forms,
  Unit7 in 'Unit7.pas' {Form7},
  Unit2 in 'Unit2.pas' {Form2},
  DiveDM in 'DiveDM.pas',
  FileVerInf in 'FileVerInf.pas',
  MultiNIC in 'MultiNIC.pas',
  Hosts in 'Hosts.pas' {frmHosts},
  Hosts1 in 'Hosts1.pas' {frmHosts1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TfrmHosts, frmHosts);
  Application.CreateForm(TfrmHosts1, frmHosts1);
  Application.Run;
end.
