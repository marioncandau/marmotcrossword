unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Generics.Collections, MCProject, About,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.Math, WordList,
  FMX.Layouts, FMX.Objects, FMX.TabControl, System.IOUtils, FMX.Ani, FMX.Menus,
  FMX.Edit;

type

  TForm1 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Layout1: TLayout;
    TabControl1: TTabControl;
    TabItemFillList: TTabItem;
    TabItemResults: TTabItem;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Label1: TLabel;
    StyleBook1: TStyleBook;
    Label2: TLabel;
    Image1: TImage;
    Rectangle1: TRectangle;
    Layout2: TLayout;
    Image2: TImage;
    Layout6: TLayout;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Layout7: TLayout;
    Layout8: TLayout;
    Label3: TLabel;
    Label4: TLabel;
    Layout9: TLayout;
    Layout10: TLayout;
    Layout11: TLayout;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Label5: TLabel;
    Rectangle4: TRectangle;
    Rectangle5: TRectangle;
    TabItem1: TTabItem;
    Image5: TImage;
    Rectangle6: TRectangle;
    Label6: TLabel;
    Layout12: TLayout;
    Layout13: TLayout;
    Layout14: TLayout;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Image6: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Image7: TImage;
    OpenDialog1: TOpenDialog;
    MenuBar1: TMenuBar;
    Nouveau: TMenuItem;
    Ouvrir: TMenuItem;
    Enregistrer: TMenuItem;
    Fermer: TMenuItem;
    About: TMenuItem;
    Rectangle10: TRectangle;
    Image11: TImage;
    Label9: TLabel;
    Label11: TLabel;
    MenuBar2: TMenuBar;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    SaveDialog1: TSaveDialog;
    Rectangle11: TRectangle;
    Label12: TLabel;
    Rectangle9: TRectangle;
    Image4: TImage;
    Label10: TLabel;
    Rectangle12: TRectangle;
    Label13: TLabel;
    Switch2: TSwitch;
    Edit1: TEdit;
    Button1: TButton;
    Rectangle13: TRectangle;
    Image3: TImage;
    Label14: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure OuvrirClick(Sender: TObject);
    procedure NouveauClick(Sender: TObject);
    procedure EnregistrerClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure Switch2Switch(Sender: TObject);
    procedure Image3Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    CrossWord: TWordList;
    MCProject: TMCProject;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AboutClick(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Crossword.CaseLength := StrToInt(Edit1.Text);
  if Switch2.IsChecked = false then
    CrossWord.Display(Rectangle1)
  else
    CrossWord.DisplayCorrect(Rectangle1);

end;

procedure TForm1.EnregistrerClick(Sender: TObject);
begin
  SaveDialog1.FileName := MCProject.FilePath;
  if SaveDialog1.Execute then
  begin
    MCProject.Save(SaveDialog1.FileName);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CrossWord := TWordList.Create;
  MCProject := TMCProject.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CrossWord.Free;
  MCProject.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem1;
  Rectangle2.Height := (Form1.Height - Layout2.Height) / 2;
end;

procedure TForm1.Image1Click(Sender: TObject);
var
  i: integer;
begin
  CrossWord.List.Clear;
  MCProject.WordList.Clear;
  MCProject.DefList.Clear;
  for i := 0 to Memo1.Lines.Count - 1 do
    MCProject.WordList.Add(Memo1.Lines.Strings[i]);
  for i := 0 to Memo2.Lines.Count - 1 do
    MCProject.DefList.Add(Memo2.Lines.Strings[i]);
  if MCProject.DefList.Count = 0 then
    MCProject.WithoutDef := true
  else
    MCProject.WithoutDef := false;

  CrossWord.CaseLength := StrToInt(Edit1.Text);
  CrossWord.FromTStringList(MCProject.WordList, MCProject.DefList);
  CrossWord.Execute;
  CrossWord.Display(Rectangle1);
  if MCProject.WithoutDef = false then
  begin
    Layout6.Visible := true;
    CrossWord.DisplayDef(Layout10, Layout9);
  end
  else
    Layout6.Visible := false;
  TabControl1.ActiveTab := TabItemResults;
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItemFillList;
  Rectangle13.Visible := true;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItemResults;
end;

procedure TForm1.Image4Click(Sender: TObject);
var
  bmp: TBitmap;
begin
  SaveDialog1.FileName := TPath.GetDocumentsPath + '\crossword.png';
  if SaveDialog1.Execute then
  begin
    bmp := Rectangle1.MakeScreenshot;
    bmp.SaveToFile(SaveDialog1.FileName);
    ShowMessage('Votre grille a été sauvegardée dans ' + SaveDialog1.FileName);
  end;
end;

procedure TForm1.NouveauClick(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItemFillList;
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
  MCProject.FilePath := '';
  MCProject.WordList.Clear;
  MCProject.DefList.Clear;
end;

procedure TForm1.OuvrirClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    MCProject.FilePath := OpenDialog1.FileName;
    MCProject.OpenFile(MCProject.FilePath);
    Memo1.Lines := MCProject.WordList;
    Memo2.Lines := MCProject.DefList;
    TabControl1.ActiveTab := TabItemFillList;
  end;
end;

procedure TForm1.Switch2Switch(Sender: TObject);
begin
  if Switch2.IsChecked = false then
    CrossWord.Display(Rectangle1)
  else
    CrossWord.DisplayCorrect(Rectangle1);
end;

end.
