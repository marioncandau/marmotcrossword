unit MCProject;

interface

uses Word, System.Generics.Collections, System.SysUtils, System.Types,
  System.UITypes, System.Classes, System.Math,
  System.Variants, FMX.Objects, FMX.StdCtrls, FMX.Types, FMX.Layouts;

type
  TMCProject = class
  private
    FFilePath: string;
    FWordList: TStringList;
    FDefList: TStringList;
    FWithoutDef: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure OpenFile(FilePath: string);
    procedure Save(FilePath: String);
    property FilePath: string read FFilePath write FFilePath;
    property WordList: TStringList read FWordList write FWordList;
    property DefList: TStringList read FDefList write FDefList;
    property WithoutDef: boolean read FWithoutDef write FWithoutDef default false;
  end;

implementation

constructor TMCProject.Create;
begin
  FWordList := TStringList.Create;
  FDefList := TStringList.Create;
  FFilePath := '';
end;

destructor TMCProject.Destroy;
begin
  FWordList.Free;
  FDefList.Free;
  FFilePath := '';
end;

procedure TMCProject.OpenFile(FilePath: string);
var
  ts: TStringList;
  i: integer;
begin
  ts := TStringList.Create;
  try
    ts.LoadFromFile(FilePath);
    if ts.Strings[0] <> '//WordList' then
      raise Exception.Create('Ceci n''est pas un fichier MarmotCrossword!');

    i := 1;
    while ts.Strings[i] <> '//DefList' do
    begin
      FWordList.Add(ts.Strings[i]);
      i := i + 1;
    end;

    i := i + 1;
    while i < ts.Count do
    begin
      FDefList.Add(ts.Strings[i]);
      i := i + 1;
    end;

    if FWordList.Count <> FDefList.Count then
      raise Exception.Create
        ('Le nombre de mots ne correspond pas au nombre de définitions...');

  finally
    ts.Free;
  end;

end;

procedure TMCProject.Save(FilePath: String);
var
  ts: TStringList;
  i: Integer;
begin
  ts := TStringList.Create;
  ts.Add('//WordList');
  try
    for i := 0 to FWordList.Count - 1 do
      ts.Add(FWordList.Strings[i]);

    ts.Add('//DefList');

    for i := 0 to FDefList.Count - 1 do
      ts.Add(FDefList.Strings[i]);

    ts.SaveToFile(FilePath);
  finally
    ts.Free;
  end;
end;

end.
