program MarmotCrossword;

uses
  System.StartUpCopy,
  FMX.Forms,
  Word in 'Word.pas',
  WordList in 'WordList.pas',
  MCProject in 'MCProject.pas',
  About in 'About.pas' {Form2},
  MainForm in 'MainForm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
