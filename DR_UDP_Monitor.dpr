program DR_UDP_Monitor;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form7},
  Unit2 in 'Unit2.pas' {Form2},
  FileVerInf in 'FileVerInf.pas',
  Hosts in 'Hosts.pas' {frmHosts},
  Display in 'Display.pas' {frmDisplay},
  Xml.VerySimple in 'Xml.VerySimple.pas',
  MultiNIC in 'MultiNIC.pas' {frmMultiNIC},
  DiveDM in 'DiveDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TfrmHosts, frmHosts);
  Application.CreateForm(TfrmDisplay, frmDisplay);
  Application.CreateForm(TfrmMultiNIC, frmMultiNIC);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
