program AcrylicForm;

{$R 'icons.res' 'icons.rc'}

uses
  Vcl.Forms,
  AcrylicFormU in 'AcrylicFormU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAcrylicForm, MainAcrylicForm);
  Application.Run;
end.

