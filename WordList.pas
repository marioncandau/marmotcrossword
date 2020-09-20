unit WordList;

interface

uses Word, System.Generics.Collections, System.SysUtils, System.Types,
  System.UITypes, System.Classes, System.Math,
  System.Variants, FMX.Objects, FMX.StdCtrls, FMX.Types, FMX.Layouts;

type
  TWordList = class
  private
    Flist: TList<TWord>;
    FcomputedPos: integer;
    FForbiddenCase: TLetterPosition;
    FCaseLength: integer;
    procedure Sort;
    function WordIntersection(s1: string; s2: string): TLetterPosition;
    function ComputePosFirstWord: TLetterPosition;
    function ComputeWordPosition(interindex: integer; index: integer;
      inter: TPoint): boolean;
    function CheckConsistency(tlp: TLetterPosition; s: string;
      sens: TSens): boolean;

    function GridTopLeft: TPoint;
    function GridBottomRight: TPoint;
  public
    Constructor Create; overload;
    Constructor Create(words: TStrings; defs: TStrings); overload;
    Destructor destroy;

    procedure FromTstringList(words: TStrings; defs: TStrings);
    procedure Execute;
    procedure Display(base: TRectangle);
    procedure DisplayCorrect(base: TRectangle);
    procedure DisplayDef(l1, l2: TLayout);
  published
    property List: TList<TWord> read Flist write Flist;
    property CaseLength: integer read FCaseLength write FCaseLength default 22;
  end;

implementation

Constructor TWordList.Create;
begin
  Flist := TList<TWord>.Create;
end;

Constructor TWordList.Create(words: TStrings; defs: TStrings);
begin
  Flist := TList<TWord>.Create;
  FromTstringList(words, defs);
end;

destructor TWordList.destroy;
begin
  Flist.Free;
end;

procedure TWordList.FromTstringList(words: TStrings; defs: TStrings);
var
  w: TWord;
  I: integer;
begin
  for I := 0 to words.Count - 1 do
  begin
    w := TWord.Create;
    w.str := words.Strings[I];
    if I < defs.Count then
      w.def := defs.Strings[I];
    w.num := I;
    List.Add(w);
  end;
end;

procedure TWordList.Sort;
// tri par longueur
var
  j, I, m: integer;
  copyWordList: TList<TWord>;
  listLengths: array of integer;
begin
  copyWordList := TList<TWord>.Create;

  SetLength(listLengths, List.Count);
  for j := 0 to List.Count - 1 do
  begin
    listLengths[j] := List.Items[j].str.Length;
  end;

  j := List.Count - 1;
  while j <> -1 do
  begin
    m := MaxIntValue(listLengths);
    for I := 0 to List.Count - 1 do
    begin
      if listLengths[I] = m then
      begin
        listLengths[I] := 0;
        copyWordList.Add(List.Items[I]);
        j := j - 1;
        break;
      end;
    end;
  end;

  List.Clear;
  for I := 0 to copyWordList.Count - 1 do
    List.Add(copyWordList.Items[I]);

end;

function TWordList.ComputePosFirstWord: TLetterPosition;
var
  I, l, j, alea: integer;
begin
  l := self.List.Items[0].str.Length;
  SetLength(Result, l);
  alea := random(1000);
  // alea mod 2 = 0 => vertical, alea mod 2 = 1 => horizontal
  if alea mod 2 = 0 then
  begin
    Result[l div 2].P := Point(0, 0);
    Result[l div 2].TC := TNormal;
    j := -1;
    for I := l div 2 + 1 to l - 1 do
    begin
      Result[I].P := Point(0, j);
      j := j - 1;
      if I <> l - 1 then
        Result[I].TC := TNormal
      else
        Result[I].TC := TEnd;
    end;
    j := 1;
    for I := l div 2 - 1 downto 0 do
    begin
      Result[I].P := Point(0, j);
      j := j + 1;
      if I <> 0 then
        Result[I].TC := TNormal
      else
        Result[I].TC := TEnd;
    end;
    self.List[0].sens := TVertical;
  end
  else
  begin
    Result[l div 2].P := Point(0, 0);
    Result[l div 2].TC := TNormal;
    j := 1;
    for I := l div 2 + 1 to l - 1 do
    begin
      Result[I].P := Point(j, 0);
      j := j + 1;
      if I <> l - 1 then
        Result[I].TC := TNormal
      else
        Result[I].TC := TEnd;
    end;
    j := -1;
    for I := l div 2 - 1 downto 0 do
    begin
      Result[I].P := Point(j, 0);
      j := j - 1;
      if I <> 0 then
        Result[I].TC := TNormal
      else
        Result[I].TC := TEnd;
    end;
    self.List[0].sens := THorizontal;
  end;
end;

procedure TWordList.Execute;
var
  I, j, k: integer;
  bo: boolean;
  tlp: TLetterPosition;
begin
  Sort;
  tlp := ComputePosFirstWord;
  self.List[0].pos := tlp;
  FcomputedPos := 1;

  SetLength(FForbiddenCase, 0);

  I := 1;
  while I < self.List.Count do
  begin
    j := FcomputedPos - 1;
    while j > -1 do
    begin
      SetLength(tlp, 0);
      tlp := WordIntersection(List.Items[j].str, List.Items[I].str);
      RandSort(tlp);
      if Length(tlp) <> 0 then
      begin
        bo := true;
        for k := 0 to Length(tlp) - 1 do
        begin
          if ComputeWordPosition(j, I, tlp[k].P) then
          begin
            I := I + 1;
            j := FcomputedPos - 1;
            if I = self.List.Count then
              exit;
            bo := true;
            break;
          end
          else
            bo := false;
        end;
        if bo = false then
          j := j - 1;
      end
      else
        j := j - 1;
    end;
    if j = -1 then
      break;
  end;

end;

function TWordList.WordIntersection(s1: string; s2: string): TLetterPosition;
var
  I, j: integer;
begin
  SetLength(Result, 0);
  for I := 1 to s1.Length do
  begin
    for j := 2 to s2.Length do
    begin
      if s1[I] = s2[j] then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result) - 1].P := Point(I, j);
      end;
    end;
  end;
end;

function TWordList.ComputeWordPosition(interindex: integer; index: integer;
  inter: TPoint): boolean;
// calcule la position du mot index avec l'intersection interindex et la position de l'intersection inter
var
  b: TSens;
  tlp, fc: TLetterPosition;
  I, j: integer;
begin
  SetLength(tlp, List.Items[index].str.Length);

  // on calcule la position de la case interceptée
  tlp[inter.Y - 1].P.X := List.Items[interindex].pos[inter.X - 1].P.X;
  tlp[inter.Y - 1].P.Y := List.Items[interindex].pos[inter.X - 1].P.Y;
  tlp[inter.Y - 1].TC := TCommun;

  // fc = ForbiddenCase
  SetLength(fc, 6);
  fc[0].P := Point(tlp[inter.Y - 1].P.X - 1, tlp[inter.Y - 1].P.Y - 1);
  fc[1].P := Point(tlp[inter.Y - 1].P.X + 1, tlp[inter.Y - 1].P.Y - 1);
  fc[2].P := Point(tlp[inter.Y - 1].P.X - 1, tlp[inter.Y - 1].P.Y + 1);
  fc[3].P := Point(tlp[inter.Y - 1].P.X + 1, tlp[inter.Y - 1].P.Y + 1);

  if self.List.Items[interindex].sens = THorizontal then
  begin
    b := TVertical;
    j := tlp[inter.Y - 1].P.Y + 1;
    for I := inter.Y - 2 downto 0 do
    begin
      tlp[I].P := Point(tlp[inter.Y - 1].P.X, j);
      j := j + 1;
      if I = inter.Y - 2 then
        tlp[I].TC := TTypeCase.TTopCommun
      else if I = 0 then
        tlp[I].TC := TEnd
      else
        tlp[I].TC := TNormal;
    end;

    fc[4].P := Point(tlp[inter.Y - 1].P.X, j);

    j := tlp[inter.Y - 1].P.Y - 1;
    for I := inter.Y to Length(tlp) - 1 do
    begin
      tlp[I].P := Point(tlp[inter.Y - 1].P.X, j);
      j := j - 1;
      if I = inter.Y then
        tlp[I].TC := TTypeCase.TBottomCommun
      else if I = Length(tlp) - 1 then
        tlp[I].TC := TEnd
      else
        tlp[I].TC := TNormal;
    end;

    fc[5].P := Point(tlp[inter.Y - 1].P.X, j);

  end
  else
  begin
    b := THorizontal;

    j := tlp[inter.Y - 1].P.X - 1;
    for I := inter.Y - 2 downto 0 do
    begin
      tlp[I].P := Point(j, tlp[inter.Y - 1].P.Y);
      j := j - 1;
      if I = inter.Y - 2 then
        tlp[I].TC := TTypeCase.TLeftCommun
      else if I = 0 then
        tlp[I].TC := TEnd
      else
        tlp[I].TC := TNormal;
    end;

    fc[4].P := Point(j, tlp[inter.Y - 1].P.Y);

    j := tlp[inter.Y - 1].P.X + 1;
    for I := inter.Y to Length(tlp) - 1 do
    begin
      tlp[I].P := Point(j, tlp[inter.Y - 1].P.Y);
      j := j + 1;
      if I = inter.Y then
        tlp[I].TC := TTypeCase.TRightCommun
      else if I = Length(tlp) - 1 then
        tlp[I].TC := TEnd
      else
        tlp[I].TC := TNormal;
    end;

    fc[5].P := Point(j, tlp[inter.Y - 1].P.Y);
  end;

  if CheckConsistency(tlp, List.Items[index].str, b) then
  begin
    List.Items[index].pos := tlp;
    List.Items[index].sens := b;
    List.Items[interindex].pos[inter.X - 1].TC := TCommun;
    if self.List.Items[interindex].sens = THorizontal then
    begin
      if inter.X - 2 >= 0 then
        if List.Items[interindex].pos[inter.X - 2].TC = TRightCommun then
          List.Items[interindex].pos[inter.X - 2].TC := TRightLeftCommun
        else
          List.Items[interindex].pos[inter.X - 2].TC := TLeftCommun;
      if inter.X < Length(List.Items[interindex].pos) then
        if List.Items[interindex].pos[inter.X].TC = TLeftCommun then
          List.Items[interindex].pos[inter.X].TC := TRightLeftCommun
        else
          List.Items[interindex].pos[inter.X].TC := TRightCommun;
    end
    else
    begin
      if inter.X - 2 >= 0 then
        if List.Items[interindex].pos[inter.X - 2].TC = TBottomCommun then
          List.Items[interindex].pos[inter.X - 2].TC := TBottomTopCommun
        else
          List.Items[interindex].pos[inter.X - 2].TC := TTopCommun;
      if inter.X < Length(List.Items[interindex].pos) then
        if List.Items[interindex].pos[inter.X].TC = TTopCommun then
          List.Items[interindex].pos[inter.X].TC := TBottomTopCommun
        else
          List.Items[interindex].pos[inter.X].TC := TBottomCommun;
    end;
    SetLength(FForbiddenCase, Length(FForbiddenCase) + 6);
    FForbiddenCase[Length(FForbiddenCase) - 1] := fc[3];
    FForbiddenCase[Length(FForbiddenCase) - 2] := fc[2];
    FForbiddenCase[Length(FForbiddenCase) - 3] := fc[1];
    FForbiddenCase[Length(FForbiddenCase) - 4] := fc[0];
    FForbiddenCase[Length(FForbiddenCase) - 5] := fc[4];
    FForbiddenCase[Length(FForbiddenCase) - 6] := fc[5];
    FcomputedPos := FcomputedPos + 1;
    Result := true;
  end
  else
    Result := false;

end;

function TWordList.CheckConsistency(tlp: TLetterPosition; s: string;
  sens: TSens): boolean;
var
  I, j, k: integer;
  t1, t2: TPoint;
begin
  Result := true;

  if sens = THorizontal then
  begin
    t1.X := tlp[0].P.X - 1;
    t1.Y := tlp[0].P.Y;
    t2.X := tlp[Length(tlp) - 1].P.X + 1;
    t2.Y := t1.Y;
  end
  else
  begin
    t1.X := tlp[0].P.X;
    t1.Y := tlp[0].P.Y + 1;
    t2.X := t1.X;
    t2.Y := tlp[Length(tlp) - 1].P.Y - 1;
  end;

  for I := 0 to FcomputedPos - 1 do
  begin
    for j := 0 to Length(List.Items[I].pos) - 1 do
    begin
      for k := 0 to Length(tlp) - 1 do
      begin
        if (tlp[k].P = List.Items[I].pos[j].P) and
          (s[k + 1] <> List.Items[I].str[j + 1]) then
        begin
          Result := false;
          exit;
        end;
      end;

      if t1 = List.Items[I].pos[j].P then
      begin
        Result := false;
        exit;
      end;

      if t2 = List.Items[I].pos[j].P then
      begin
        Result := false;
        exit;
      end;

    end;
  end;

  for I := 0 to Length(tlp) - 1 do
  begin
    for j := 0 to Length(FForbiddenCase) - 1 do
    begin
      if tlp[I].P = FForbiddenCase[j].P then
      begin
        Result := false;
        exit;
      end;
    end;
  end;

end;

procedure TWordList.Display(base: TRectangle);
var
  I, j: integer;
  t, s: TPoint;
  r: TRectangle;
  t1, t2: integer;
  l: tLabel;
  P: TList<TPoint>;
begin
  t := GridTopLeft;

  for I := base.ChildrenCount - 1 downto 0 do
  begin
    base.Children.Items[I].Free;
  end;

  P := TList<TPoint>.Create;
  try
    for I := 0 to List.Count - 1 do
    begin

      if Length(List.Items[I].pos) > 0 then
      begin
        t1 := abs(t.X - List.Items[I].pos[0].P.X) * self.FCaseLength;
        t2 := abs(t.Y - List.Items[I].pos[0].P.Y) * FCaseLength;
        s.X := t1;
        s.Y := t2;

        r := TRectangle.Create(base);
        r.Parent := base;
        r.Position.X := t1;
        r.Position.Y := t2;
        r.Height := FCaseLength;
        r.Width := FCaseLength;
        r.Fill.Color := TAlphaColorRec.white;
        l := tLabel.Create(r);
        l.Parent := r;
        l.Align := TAlignLayout.top;
        l.Margins.Left := 1;
        l.Text := IntToStr(List.Items[I].num + 1);
        l.StyledSettings := [];
        l.FontColor := TAlphaColor($FF000001);
        l.Font.Size := 8;
        if List.Items[I].sens = THorizontal then
        begin
          if List.Items[I].pos[0].TC <> TCommun then
            r.Sides := r.Sides - [TSide.Right];
        end
        else
        begin
          if List.Items[I].pos[0].TC <> TCommun then
            r.Sides := r.Sides - [TSide.Bottom];
        end;

        P.Add(s);
      end;
      for j := 1 to Length(List.Items[I].pos) - 2 do
      begin
        t1 := abs(t.X - List.Items[I].pos[j].P.X) * self.FCaseLength;
        t2 := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
        s.X := t1;
        s.Y := t2;
        if inList(s, P) = false then
        begin
          r := TRectangle.Create(base);
          r.Parent := base;
          r.Position.X := abs(t.X - List.Items[I].pos[j].P.X) * FCaseLength;
          r.Position.Y := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
          r.Height := FCaseLength;
          r.Width := FCaseLength;
          r.Fill.Color := TAlphaColorRec.white;
          P.Add(s);

          r.Sides := [];
          if List.Items[I].sens = THorizontal then
          begin
            if (List.Items[I].pos[j].TC = TRightCommun) or
              (List.Items[I].pos[j].TC = TRightLeftCommun) then
            begin
              r.Sides := [TSide.top] + [TSide.Bottom];
            end
            else if List.Items[I].pos[j].TC = TCommun then
            begin
              r.Sides := [TSide.top] + [TSide.Bottom] + [TSide.Right] +
                [TSide.Left];
            end
            else
            begin
              r.Sides := [TSide.top] + [TSide.Bottom] + [TSide.Left];
            end;
          end
          else
          begin
            if (List.Items[I].pos[j].TC = TBottomCommun) or
              (List.Items[I].pos[j].TC = TBottomTopCommun) then
            begin
              r.Sides := [TSide.Left] + [TSide.Right];
            end
            else if List.Items[I].pos[j].TC = TCommun then
            begin
              r.Sides := [TSide.top] + [TSide.Bottom] + [TSide.Right] +
                [TSide.Left];
            end
            else
            begin
              r.Sides := [TSide.top] + [TSide.Left] + [TSide.Right];
            end;
          end;
        end;
      end;
      if Length(List.Items[I].pos) > 0 then
      begin
        j := Length(List.Items[I].pos) - 1;
        t1 := abs(t.X - List.Items[I].pos[j].P.X) * self.FCaseLength;
        t2 := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
        s.X := t1;
        s.Y := t2;
        if inList(s, P) = false then
        begin
          r := TRectangle.Create(base);
          r.Parent := base;
          r.Position.X := abs(t.X - List.Items[I].pos[j].P.X) * FCaseLength;
          r.Position.Y := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
          r.Height := FCaseLength;
          r.Width := FCaseLength;
          r.Fill.Color := TAlphaColorRec.white;
          P.Add(s);

          if List.Items[I].sens = THorizontal then
          begin
            if List.Items[I].pos[j].TC = TRightCommun then
              r.Sides := r.Sides - [TSide.Left];
          end
          else
          begin
            if List.Items[I].pos[j].TC = TBottomCommun then
              r.Sides := r.Sides - [TSide.top];
          end;

        end;
      end;
    end;
  finally
    P.Free;
  end;

end;

procedure TWordList.DisplayCorrect(base: TRectangle);
var
  I, j: integer;
  t, s: TPoint;
  r: TRectangle;
  t1, t2, fontsize: integer;
  l: tLabel;
  P: TList<TPoint>;
begin
  t := GridTopLeft;
  fontsize := 8 + self.FCaseLength - 22;

  for I := base.ChildrenCount - 1 downto 0 do
  begin
    base.Children.Items[I].Free;
  end;

  P := TList<TPoint>.Create;
  try
    for I := 0 to List.Count - 1 do
    begin

      if Length(List.Items[I].pos) > 0 then
      begin
        t1 := abs(t.X - List.Items[I].pos[0].P.X) * self.FCaseLength;
        t2 := abs(t.Y - List.Items[I].pos[0].P.Y) * FCaseLength;
        s.X := t1;
        s.Y := t2;

        r := TRectangle.Create(base);
        r.Parent := base;
        r.Position.X := t1;
        r.Position.Y := t2;
        r.Height := FCaseLength;
        r.Width := FCaseLength;
        r.Fill.Color := TAlphaColorRec.white;
        l := tLabel.Create(r);
        l.Parent := r;
        l.Align := TAlignLayout.Client;
        // l.Margins.Left := self.FCaseLength div 3;
        l.Text := self.List.Items[I].str[1];
        l.StyledSettings := [];
        l.FontColor := TAlphaColor($FF000001);
        l.Font.Size := fontsize;
        l.TextSettings.HorzAlign := TTextAlign.Center;
        l.TextSettings.VertAlign := TTextAlign.Center;
        if List.Items[I].sens = THorizontal then
        begin
          if List.Items[I].pos[0].TC <> TCommun then
            r.Sides := r.Sides - [TSide.Right];
        end
        else
        begin
          if List.Items[I].pos[0].TC <> TCommun then
            r.Sides := r.Sides - [TSide.Bottom];
        end;

        P.Add(s);
      end;
      for j := 1 to Length(List.Items[I].pos) - 2 do
      begin
        t1 := abs(t.X - List.Items[I].pos[j].P.X) * self.FCaseLength;
        t2 := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
        s.X := t1;
        s.Y := t2;
        if inList(s, P) = false then
        begin
          r := TRectangle.Create(base);
          r.Parent := base;
          r.Position.X := abs(t.X - List.Items[I].pos[j].P.X) * FCaseLength;
          r.Position.Y := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
          r.Height := FCaseLength;
          r.Width := FCaseLength;
          r.Fill.Color := TAlphaColorRec.white;

          l := tLabel.Create(r);
          l.Parent := r;
          l.Align := TAlignLayout.Client;
          l.Text := self.List.Items[I].str[j + 1];
          l.StyledSettings := [];
          l.FontColor := TAlphaColor($FF000001);
          l.Font.Size := fontsize;
          l.TextSettings.HorzAlign := TTextAlign.Center;
          l.TextSettings.VertAlign := TTextAlign.Center;

          P.Add(s);

          r.Sides := [];
          if List.Items[I].sens = THorizontal then
          begin
            if (List.Items[I].pos[j].TC = TRightCommun) or
              (List.Items[I].pos[j].TC = TRightLeftCommun) then
            begin
              r.Sides := [TSide.top] + [TSide.Bottom];
            end
            else if List.Items[I].pos[j].TC = TCommun then
            begin
              r.Sides := [TSide.top] + [TSide.Bottom] + [TSide.Right] +
                [TSide.Left];
            end
            else
            begin
              r.Sides := [TSide.top] + [TSide.Bottom] + [TSide.Left];
            end;
          end
          else
          begin
            if (List.Items[I].pos[j].TC = TBottomCommun) or
              (List.Items[I].pos[j].TC = TBottomTopCommun) then
            begin
              r.Sides := [TSide.Left] + [TSide.Right];
            end
            else if List.Items[I].pos[j].TC = TCommun then
            begin
              r.Sides := [TSide.top] + [TSide.Bottom] + [TSide.Right] +
                [TSide.Left];
            end
            else
            begin
              r.Sides := [TSide.top] + [TSide.Left] + [TSide.Right];
            end;
          end;
        end;
      end;
      if Length(List.Items[I].pos) > 0 then
      begin
        j := Length(List.Items[I].pos) - 1;
        t1 := abs(t.X - List.Items[I].pos[j].P.X) * self.FCaseLength;
        t2 := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
        s.X := t1;
        s.Y := t2;
        if inList(s, P) = false then
        begin
          r := TRectangle.Create(base);
          r.Parent := base;
          r.Position.X := abs(t.X - List.Items[I].pos[j].P.X) * FCaseLength;
          r.Position.Y := abs(t.Y - List.Items[I].pos[j].P.Y) * FCaseLength;
          r.Height := FCaseLength;
          r.Width := FCaseLength;
          r.Fill.Color := TAlphaColorRec.white;

          l := tLabel.Create(r);
          l.Parent := r;
          l.Align := TAlignLayout.Client;
          // l.Margins.Left := self.FCaseLength div 3;
          l.Text := self.List.Items[I].str[j + 1];
          l.StyledSettings := [];
          l.FontColor := TAlphaColor($FF000001);
          l.TextSettings.HorzAlign := TTextAlign.Center;
          l.TextSettings.VertAlign := TTextAlign.Center;
          l.Font.Size := fontsize;

          if List.Items[I].sens = THorizontal then
          begin
            if List.Items[I].pos[j].TC = TRightCommun then
              r.Sides := r.Sides - [TSide.Left];
          end
          else
          begin
            if List.Items[I].pos[j].TC = TBottomCommun then
              r.Sides := r.Sides - [TSide.top];
          end;
          P.Add(s);
        end;
      end;
    end;
  finally
    P.Free;
  end;

end;

function TWordList.GridTopLeft: TPoint;
var
  minX, maxY, I: integer;
begin
  minX := 0;
  maxY := 0;
  for I := 0 to List.Count - 1 do
  begin
    if Length(List.Items[I].pos) > 0 then
    begin
      if List.Items[I].pos[0].P.X < minX then
        minX := List.Items[I].pos[0].P.X;
      if List.Items[I].pos[0].P.Y > maxY then
        maxY := List.Items[I].pos[0].P.Y;

      if List.Items[I].pos[Length(List.Items[I].pos) - 1].P.X < minX then
        minX := List.Items[I].pos[Length(List.Items[I].pos) - 1].P.X;
      if List.Items[I].pos[Length(List.Items[I].pos) - 1].P.Y > maxY then
        maxY := List.Items[I].pos[Length(List.Items[I].pos) - 1].P.Y;
    end;
  end;

  Result := Point(minX - 1, maxY + 1);

end;

function TWordList.GridBottomRight: TPoint;
var
  maxX, minY, I, j: integer;
begin
  minY := 0;
  maxX := 0;
  for I := 0 to List.Count - 1 do
  begin
    for j := 0 to Length(List.Items[I].pos) - 1 do
    begin
      if List.Items[I].pos[j].P.Y < minY then
        minY := List.Items[I].pos[j].P.Y;
      if List.Items[I].pos[j].P.X > maxX then
        maxX := List.Items[I].pos[j].P.X;
    end;
  end;

  Result := Point(maxX + 1, minY - 1);

end;

procedure TWordList.DisplayDef(l1, l2: TLayout);
var
  I: integer;
  lab: tLabel;
begin
  for I := l1.ChildrenCount - 1 downto 0 do
  begin
    l1.Children.Items[I].Free;
  end;

  for I := l2.ChildrenCount - 1 downto 0 do
  begin
    l2.Children.Items[I].Free;
  end;

  for I := 0 to List.Count - 1 do
  begin
    if List.Items[I].sens = TVertical then
    begin
      lab := tLabel.Create(l1);
      lab.Parent := l1;
      lab.Text := IntToStr(List.Items[I].num + 1) + ' - ' + List.Items[I].def;
      lab.Align := TAlignLayout.top;
      lab.StyledSettings := [];
      lab.FontColor := TAlphaColor($FF000001);
      lab.Margins.Left := 2;
    end
    else
    begin
      lab := tLabel.Create(l2);
      lab.Parent := l2;
      lab.Text := IntToStr(List.Items[I].num + 1) + ' - ' + List.Items[I].def;
      lab.Align := TAlignLayout.top;
      lab.StyledSettings := [];
      lab.FontColor := TAlphaColor($FF000001);
      lab.Margins.Left := 2;
    end;
  end;

end;

end.
