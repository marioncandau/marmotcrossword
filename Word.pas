unit Word;

interface

uses System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Generics.Collections;

type
  TTypeCase = (TNormal, TLeftCommun, TRightCommun, TTopCommun, TBottomCommun,
    TBottomTopCommun, TRightLeftCommun, TCommun, TEnd);
  TSens = (TVertical, THorizontal);

  TCase = record
    P: TPoint;
    TC: TTypeCase;
  end;

  TLetterPosition = array of TCase;

  TWord = class
  private
    Fstr: String;
    Fpos: TLetterPosition;
    Fsens: TSens;
    Fdef: string;
    Fnum: Integer;
  public
    function PosToString: string;
  published
    property str: String read Fstr write Fstr;
    property pos: TLetterPosition read Fpos write Fpos;
    property sens: TSens read Fsens write Fsens;
    property def: string read Fdef write Fdef;
    property num: Integer read Fnum write Fnum;
  end;

function inList(s: TPoint; P: Tlist<TPoint>): boolean;
procedure RandSort(var tlp: TLetterPosition);

implementation

function TWord.PosToString: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(pos) - 2 do
  begin
    Result := Result + '(' + IntToStr(pos[i].P.X) + ', ' +
      IntToStr(pos[i].P.Y) + '), ';
  end;

  i := Length(pos) - 1;
  if i <> -1 then
    Result := Result + '(' + IntToStr(pos[i].P.X) + ', ' +
      IntToStr(pos[i].P.Y) + ')';
end;

procedure RandSort(var tlp: TLetterPosition);
var
  i, j: Integer;
  temp: TCase;
begin
  for i := Length(tlp) - 1 downto 1 do
  begin
    temp := tlp[i];
    j := Random(i + 1);
    tlp[i] := tlp[j];
    tlp[j] := temp;
  end;
end;

function inList(s: TPoint; P: Tlist<TPoint>): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to P.Count - 1 do
  begin
    if s = P[i] then
    begin
      Result := true;
      exit;
    end;
  end;
end;

end.
