program Calculator;

uses
  Vcl.Forms,
  FCalculator in 'FCalculator.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  omLexer in 'omLexer.pas',
  omToken in 'omToken.pas',
  omParser in 'omParser.pas',
  omExpressions in 'omExpressions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TCalculator, MainForm);
  Application.Run;
end.
