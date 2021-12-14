program AcrylicForm;

uses
  Vcl.Forms,
  AcrylicFormU in 'AcrylicFormU.pas',
  CustomPanel  in 'CustomPanel.pas',
  AuxForm1     in 'AuxForm1.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAcrylicForm, MainAcrylicForm);
  Application.Run;
end.

