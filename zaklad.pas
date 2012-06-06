unit zaklad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LCLType, Grids, ExtCtrls, Menus, databaza, zaznamy, pref, about, statistik;

type

  { TEvidence }

  TEvidence = class(TForm)
    Add: TButton;
    EraseSearch: TCheckBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    About: TMenuItem;
    country: TMenuItem;
    statmenu: TMenuItem;
    topky: TMenuItem;
    map: TMenuItem;
    SaveAs: TMenuItem;
    Open: TMenuItem;
    Save: TMenuItem;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Zatvor: TMenuItem;
    Preference: TMenuItem;
    SearchCol: TComboBox;
    Search: TButton;
    SearchText: TLabeledEdit;
    Zoradenie: TListBox;
    TabulkaP: TStringGrid;
    Tabulka: TStringGrid;
    procedure AboutClick(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure EraseSearchChange(Sender: TObject);
    procedure mapClick(Sender: TObject);
    procedure countryClick(Sender: TObject);
    procedure PreferenceClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure TabulkaPickListSelect(Sender: TObject);
    procedure topkyClick(Sender: TObject);
    procedure ZatvorClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SearchClick(Sender: TObject);
    procedure TabulkaDblClick(Sender: TObject);
    procedure TabulkaDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure TabulkaEditingDone(Sender: TObject);
    procedure TabulkaPPickListSelect(Sender: TObject);
    procedure ZoradenieSelectionChange(Sender: TObject; User: Boolean);
    procedure Sortenie;
    procedure Hladanie(vyhladanie: string);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Evidence: TEvidence;
  DB: TDatabaza;
  Q: TZoznam;
  Pracuje, otvorene: Boolean;
  Vyhladane: string;
  IndexHladania: Integer;

implementation

{$R *.lfm}

{ TEvidence }

procedure TEvidence.FormCreate(Sender: TObject);
begin
  DB := TDatabaza.Create;
  Q := TZoznam.Create;
  Zoradenie.ItemIndex := 0;
  SearchCol.SelStart := 0;
  IndexHladania := 0;
  Pracuje := False;
  Otvorene := False;
end;

procedure TEvidence.AddClick(Sender: TObject);
var
  j, i, skod, police: Integer;
  slovo: string;
begin
  if not (Pracuje) then
  begin
    Pracuje := True;
    if (TabulkaP.Cells[6, 1] = '') then  //pokial nezadal hodnotu priradi autmaticky 0
      TabulkaP.Cells[6, 1] := '0';
    if (TabulkaP.Cells[7, 1] = '') then
      TabulkaP.Cells[7, 1] := '0';
    if (TabulkaP.Cells[0, 1] = '') then
    begin
      ShowMessage('Nevyplnili ste Meno!'); //overovacky
      Pracuje := False;
      exit;
    end;
    if (TabulkaP.Cells[1, 1] = '') then
    begin
      ShowMessage('Nevyplnili ste Priezvisko!');
      Pracuje := False;
      exit;
    end;
    if (TabulkaP.Cells[2, 1] = '') then
    begin
      ShowMessage('Nevyplnili ste Nick!');
      Pracuje := False;
      exit;
    end;
    if (TabulkaP.Cells[3, 1] = '') then
    begin
      ShowMessage('Nevyplnili ste Krajinu!');
      Pracuje := False;
      exit;
    end;
    if (TabulkaP.Cells[4, 1] = '') then
    begin
      ShowMessage('Nevyplnili ste úroveň!');
      Pracuje := False;
      exit;
    end;
    for j := 0 to 1 do  //overovanie platnych znakov Meno a Priezvisko
    begin
      case j of
        0: slovo := TabulkaP.Cells[0, 1];
        1: slovo := TabulkaP.Cells[1, 1];
      end;
      for i := 1 to length(slovo) do
      begin
        if not ((Slovo[i] in ['a'..'z']) or (Slovo[i] in ['A'..'Z'])) then
          //ak je neplatny znak
        begin
          ShowMessage('Neplatné "' + slovo + '"!');
          Pracuje := False;
          exit;
        end;
      end;
    end;
    slovo := TabulkaP.Cells[2, 1];
    for i := 1 to length(slovo) do
    begin
      if not (Ord(Slovo[i]) in [32..126]) then
      begin
        ShowMessage('Neplatný nick "' + slovo + '"!');
        Pracuje := False;
        exit;
      end;
    end;
    slovo := TabulkaP.Cells[5, 1];
    for i := 1 to length(slovo) do
    begin
      if not (Ord(Slovo[i]) in [32..126]) then
      begin
        ShowMessage('Neplatná Skupina "' + slovo + '"!');
        Pracuje := False;
        exit;
      end;
    end;
    if not (TryStrToInt(TabulkaP.Cells[6, 1], skod)) then
      //TryStrToInt overuje prevedenie na integer
    begin
      ShowMessage('Neplatné čislo škody!');
      Pracuje := False;
      exit;
    end;
    if not (TryStrToInt(TabulkaP.Cells[7, 1], police)) then
    begin
      ShowMessage('Neplatné čislo chytený!');
      Pracuje := False;
      exit;
    end;
    SetLength(Q.zaznamy, length(Q.zaznamy) + 1); //pridanie hackera
    if length(Q.Zaznamy) > 1 then
     Q.zaznamy[high(Q.zaznamy)].Id := Q.zaznamy[high(Q.zaznamy) - 1].Id + 1
    else
     Q.zaznamy[high(Q.zaznamy)].Id := 1;
    Q.zaznamy[high(Q.zaznamy)].Meno := TabulkaP.Cells[0, 1];
    Q.zaznamy[high(Q.zaznamy)].Priezvisko := TabulkaP.Cells[1, 1];
    Q.zaznamy[high(Q.zaznamy)].Nick := TabulkaP.Cells[2, 1];
    Q.zaznamy[high(Q.zaznamy)].Krajina := TabulkaP.Cells[3, 1];
    Q.zaznamy[high(Q.zaznamy)].Uroven := TabulkaP.Cells[4, 1];
    Q.zaznamy[high(Q.zaznamy)].Skupina := TabulkaP.Cells[5, 1];
    Q.zaznamy[high(Q.zaznamy)].Skoda := skod;
    Q.zaznamy[high(Q.zaznamy)].Chyteny := police;
    Sortenie;
    Q.Ukaz(Tabulka, Q.Pomocne);
    TabulkaP.Clear; //zmaze pridaneho hackera v tabulke pridania
    TabulkaP.RowCount := 2;
    ShowMessage('Pridaný');
    Pracuje := False;
  end;
end;

procedure TEvidence.AboutClick(Sender: TObject);
begin
  OProg.Show;
end;

procedure TEvidence.EraseSearchChange(Sender: TObject);
begin
  if EraseSearch.Checked and (not Pracuje) then
  begin
    Vyhladane := '';  //zmaze vyhladavanie a ukaze vsetkych hackerov
    SearchText.Text := '';
    EraseSearch.Checked := False;
    Sortenie;
    Q.Ukaz(Tabulka, Q.Pomocne);
  end
  else if EraseSearch.Checked then
    EraseSearch.Checked := False;
end;

procedure TEvidence.mapClick(Sender: TObject);
begin
  if length(Q.Zaznamy) > 0 then
   Stat.Mapka(Q);
  Stat.Show;
end;

procedure TEvidence.countryClick(Sender: TObject);
begin
  if length(Q.Zaznamy) > 0 then
   Stat.Kraj(Q);
  Stat.Show;
end;

procedure TEvidence.PreferenceClick(Sender: TObject);
begin
  tabulator := Tabulka; //kvoli chcekboxom, overenie ze ktore stlpce su zobrazene
  Nastavenie.Show;  //ukaze nastavenie
end;

procedure TEvidence.SaveAsClick(Sender: TObject);
var
  dialog: string;
  Subor: TStream;
begin
  if not (pracuje) then
  begin
    Pracuje := True;
    dialog := InputBox('Uložiť evidenciu',
      'Napíšte do akého súboru chcete uložiť evidenciu', '');
    //dialogbox kaM chcete ulozit evidenciu
    if dialog <> '' then  //overenie ,ktore treba kvoli problemu s default inputbox
    begin
      if not (fileexists(dialog + '.dat')) then
      begin
        Subor := TFileStream.Create(dialog + '.dat', fmCreate);
        //ak nenaslo subor tak ho vytvori
        Subor.Destroy;
      end
      else
      begin
       if MessageDlg('Uložiť', 'Skutočne to chcete uložiť do existujúceho súboru?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then //ak chcete ulozit
       exit;
      end;
      DB.S := dialog;
      DB.Uloz(Q.Zaznamy); //ulozi hackerov do suboru ,ktory ste otvorili
    end;
    Pracuje := False;
  end;
end;

procedure TEvidence.TabulkaPickListSelect(Sender: TObject);
begin
  Tabulka.Cells[Tabulka.Col, Tabulka.Row] :=
    Tabulka.Cells[Tabulka.Col, Tabulka.Row];
end;

procedure TEvidence.topkyClick(Sender: TObject);
begin
  if length(Q.Zaznamy) > 0 then
   Stat.top10(Q);
  Stat.Show;
end;

procedure TEvidence.ZatvorClick(Sender: TObject);
begin
  if not (Pracuje) then  //zatvorenie evidencie
  begin
    Pracuje := True;
    Otvorene := False;
    Add.Enabled := False;
    Save.Enabled := False;
    SaveAs.Enabled := False;
    Topky.Enabled := False;
    Map.Enabled := False;
    Country.Enabled := False;
    Zoradenie.Enabled := False;
    Search.Enabled := False;
    Zatvor.Enabled := False;
    Tabulka.Clear;
    Tabulka.RowCount := 1;
    Tabulka.Options := Tabulka.Options - [goEditing]; //zakazanie editovania tabuliek
    TabulkaP.Options := TabulkaP.Options - [goEditing];
    Pracuje := False;
  end;
end;

procedure TEvidence.OpenClick(Sender: TObject);
var
  dialog: string;
begin
  if not (pracuje) then
  begin
    Otvorene := True;
    Pracuje := True;
    dialog := InputBox('Otvoriť/Vytvoriť evidenciu',
      'Napíšte meno evidencie ,ktorú chcete otvoriť/vytvoriť:', '');
    //dialogbox ktoru evidenciu chcete otvorit
    if dialog <> '' then  //overenie ,ktore treba kvoli problemu s default inputbox
    begin
      Add.Enabled := True;
      Save.Enabled := True;
      SaveAs.Enabled := True;
      Zoradenie.Enabled := True;
      Search.Enabled := True;
      Zatvor.Enabled := True;
      Topky.Enabled := True;
    Map.Enabled := True;
    Country.Enabled := True;
      Q.zaznamy := DB.otvor(dialog); //otvori subor a nacita do Q.Zaznamy hackerov
      Tabulka.Options := Tabulka.Options + [goEditing]; //povolenie editovania tabuliek
      TabulkaP.Options := TabulkaP.Options + [goEditing];
      Sortenie;
      Q.Ukaz(Tabulka, Q.pomocne); //ukaze hackerov v tabulke
    end;
    Pracuje := False;
  end;
end;

procedure TEvidence.SaveClick(Sender: TObject);
begin
  if not (pracuje) then
  begin
    Pracuje := True;
    if MessageDlg('Uložiť', 'Skutočne to chcete uložiť?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then //ak chcete ulozit
      DB.Uloz(Q.Zaznamy); //ulozi hackerov do suboru ,ktory ste otvorili
    Pracuje := False;
  end;
end;

procedure TEvidence.SearchClick(Sender: TObject);
begin
  if not (Pracuje) then
  begin
    if length(SearchText.Text) > 2 then //pokial je dlzka vacsia ako 2
    begin
      Pracuje := True;
      Vyhladane := SearchText.Text; //globalna, potrebna kvoli zoradeniu
      IndexHladania := SearchCol.ItemIndex; //v akom stlpci hladas
      Sortenie;
      Q.Ukaz(Tabulka, Q.Pomocne);
      Pracuje := False;
    end
    else
      ShowMessage('Hľadané slovo je príliš krátke (3+)');
  end;
end;

procedure TEvidence.TabulkaDblClick(Sender: TObject);
begin
  if not (pracuje) then
  begin
    Pracuje := True;
    if (Tabulka.Col = 10) and (Tabulka.Row > 0) and (Tabulka.Row < Tabulka.RowCount) then
    begin
      Q.Zmaz(Q.NajdiID(StrToInt(Tabulka.Cells[1, Tabulka.Row])) + 1);
      //zmaze riadok tj hackera
      Sortenie;
      Q.Ukaz(Tabulka, Q.Pomocne);
    end;
    Pracuje := False;
  end;
end;

procedure TEvidence.TabulkaDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  Obr: TBitmap;
begin
  if fileexists('x.bmp') and (aCol = 10) and (aRow > 0) then //pridanie obrazku X
  begin
    Obr := TBitmap.Create;
    Obr.LoadFromFile('x.bmp');
    Tabulka.Canvas.Draw(aRect.left + 15, aRect.top + 5, Obr);
    Obr.Free;
  end;
end;

procedure TEvidence.TabulkaEditingDone(Sender: TObject);
var
  slovo, stary: string;
  i, skod, police: Integer;
begin
  if not (pracuje) and otvorene and (length(Q.Zaznamy) > 0) then
  begin
    Pracuje := True;
    slovo := Tabulka.Cells[Tabulka.Col, Tabulka.Row];
    case Tabulka.Col of
      2:
      begin
        stary := Q.Zaznamy[Q.NajdiID(StrToInt(Tabulka.Cells[1, Tabulka.Row]))].Meno;
        if (Tabulka.Cells[2, Tabulka.Row] = '') then
        begin
          Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
          ShowMessage('Nevyplnili ste Meno!'); //overovacky
          Pracuje := False;
          exit;
        end;
        for i := 1 to length(slovo) do
        begin
          if not ((Slovo[i] in ['a'..'z']) or (Slovo[i] in ['A'..'Z'])) then
            //ak je neplatny znak
          begin
            Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
            ShowMessage('Neplatné "' + slovo + '"!');
            Pracuje := False;
            exit;
          end;
        end;
      end;
      3:
      begin
        stary := Q.Zaznamy[Q.NajdiID(StrToInt(Tabulka.Cells[1, Tabulka.Row]))].Priezvisko;
        if (Tabulka.Cells[3, Tabulka.Row] = '') then
        begin
          Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
          ShowMessage('Nevyplnili ste Priezvisko!');
          Pracuje := False;
          exit;
        end;
        for i := 1 to length(slovo) do
        begin
          if not ((Slovo[i] in ['a'..'z']) or (Slovo[i] in ['A'..'Z'])) then
            //ak je neplatny znak
          begin
            Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
            ShowMessage('Neplatné "' + slovo + '"!');
            Pracuje := False;
            exit;
          end;
        end;
      end;
      4:
      begin
        stary := Q.Zaznamy[Q.NajdiID(StrToInt(Tabulka.Cells[1, Tabulka.Row]))].Nick;
        if (Tabulka.Cells[4, Tabulka.Row] = '') then
        begin
          Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
          ShowMessage('Nevyplnili ste Nick!');
          Pracuje := False;
          exit;
        end;
        for i := 1 to length(slovo) do
        begin
          if not (Ord(Slovo[i]) in [32..126]) then
          begin
            Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
            ShowMessage('Neplatný nick "' + slovo + '"!');
            Pracuje := False;
            exit;
          end;
        end;
      end;
     7:
      begin
        stary := Q.Zaznamy[Q.NajdiID(StrToInt(Tabulka.Cells[1, Tabulka.Row]))].Skupina;
       for i := 1 to length(slovo) do
        begin
          if not (Ord(Slovo[i]) in [32..126]) then
          begin
            Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
            ShowMessage('Neplatná skupina "' + slovo + '"!');
            Pracuje := False;
            exit;
          end;
        end;
      end;
     8:
      begin
        stary := IntToStr(Q.Zaznamy[Q.NajdiID(
          StrToInt(Tabulka.Cells[1, Tabulka.Row]))].Skoda);
        if (Tabulka.Cells[8, Tabulka.Row] = '') then
          //pokial nezadal hodnotu priradi autmaticky 0
          Tabulka.Cells[8, Tabulka.Row] := '0';
        if not (TryStrToInt(Tabulka.Cells[8, Tabulka.Row], skod)) then
        begin
          Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
          ShowMessage('Neplatné čislo škody!');
          Pracuje := False;
          exit;
        end;
      end;
      9:
      begin
        stary := IntToStr(Q.Zaznamy[Q.NajdiID(StrToInt(Tabulka.Cells[1, Tabulka.Row]))].Chyteny);
        if (Tabulka.Cells[9, Tabulka.Row] = '') then
          Tabulka.Cells[9, Tabulka.Row] := '0';
        if not (TryStrToInt(Tabulka.Cells[9, Tabulka.Row], police)) then
        begin
          Tabulka.Cells[Tabulka.Col, Tabulka.Row] := stary;
          ShowMessage('Neplatné čislo chytený!');
          Pracuje := False;
          exit;
        end;
      end;
    end;
    Q.Zmen(Tabulka.Row, Tabulka.Col, Tabulka); //zmena udajov hackera
    Pracuje := False;
  end;
end;

procedure TEvidence.TabulkaPPickListSelect(Sender: TObject);
begin
  TabulkaP.Cells[TabulkaP.Col, TabulkaP.Row] :=
    TabulkaP.Cells[TabulkaP.Col, TabulkaP.Row]; //osetrenie kvoli overovaniu pri pridani
end;

procedure TEvidence.ZoradenieSelectionChange(Sender: TObject; User: Boolean);
begin
  if not (pracuje) then //pri vybere zoradenia
  begin
    Pracuje := True;
    Sortenie;
    Q.Ukaz(Tabulka, Q.Pomocne);
    Pracuje := False;
  end;
end;

procedure TEvidence.Sortenie;
var
  i: Integer;
begin
  if length(DB.S) > 0 then //ak je otvoreny subor
  begin
    case Zoradenie.ItemIndex of //moznosti zoradenia
      1: Q.Pamat := Q.RadixNum(Q.Zaznamy, -1);
      2: Q.Pamat := Q.Radix(Q.Zaznamy, 1);
      3: Q.Pamat := Q.Radix(Q.Zaznamy, -1);
      4: Q.Pamat := Q.Radix(Q.Zaznamy, 2);
      5: Q.Pamat := Q.Radix(Q.Zaznamy, -2);
      6: Q.Pamat := Q.Radix(Q.Zaznamy, 3);
      7: Q.Pamat := Q.Radix(Q.Zaznamy, -3);
      8: Q.Pamat := Q.RadixNum(Q.Zaznamy, 2);
      9: Q.Pamat := Q.RadixNum(Q.Zaznamy, -2);
      10: Q.Pamat := Q.RadixNum(Q.Zaznamy, 3);
      11: Q.Pamat := Q.RadixNum(Q.Zaznamy, -3);
      12: Q.Pamat := Q.Radix(Q.Zaznamy, 4);
      13: Q.Pamat := Q.Radix(Q.Zaznamy, -4);
      14: Q.Pamat := Q.Radix(Q.Zaznamy, 5);
      15: Q.Pamat := Q.Radix(Q.Zaznamy, -5);
    end;
    if Zoradenie.ItemIndex <> 0 then //v pripade ak nie je vybrane defaultne zoradenie
    begin
      setlength(Q.pomocne, length(Q.Pamat));
      for i := 0 to high(Q.Pamat) do
        Q.pomocne[i] := Q.Pamat[i]^; //priradenie zoradenych hackerov
    end
    else
      Q.Pomocne := Q.Zaznamy; // default
    Hladanie(Vyhladane); //ak sa nieco vyhladava
  end;
end;

procedure TEvidence.Hladanie(vyhladanie: string);
begin
  if (length(vyhladanie) > 2) and (Vyhladane <> '') then  //overenie
  begin
    setlength(Q.Pomocne, 0);
    Q.Pomocne := Q.Hladaj(AnsiLowerCase(vyhladanie), Q.Zaznamy, IndexHladania); //adresy najdenych hladanych
  end;
end;

end.

