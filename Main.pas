unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.FMXUI.Wait, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Controls.Presentation,
  FMX.StdCtrls, System.Rtti, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Layouts, FMX.Grid;

type
  Exception_TableTest = class(Exception);
  Exception_QryTest = class(Exception);

  TAddDataVia = (adTable, adQuery);

  TForm1 = class(TForm)
    con1: TFDConnection;
    fdgxwtcrsr1: TFDGUIxWaitCursor;
    tb1: TFDTable;
    strngrd1: TStringGrid;
    tb1test: TStringField;
    bndsrcdb1: TBindSourceDB;
    bndngslst1: TBindingsList;
    lnkgrdtdtsrcBindSourceDB: TLinkGridToDataSource;
    lyt1: TLayout;
    btnTableNonExc: TButton;
    btnTableExcept: TButton;
    btnQryExcpt: TButton;
    btnQueryNonExc: TButton;
    tmr1: TTimer;
    lbl1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnTableNonExcClick(Sender: TObject);
    procedure btnTableExceptClick(Sender: TObject);
    procedure btnQueryNonExcClick(Sender: TObject);
    procedure btnQryExcptClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    { Private declarations }
    procedure AddData(aString : String; addVia : TAddDataVia);
  public
    { Public declarations }
    procedure AppException(Sender: TObject; e: Exception);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AddData(aString: String; addVia : TAddDataVia);
  procedure AddUsingFDTable(aStr : String);
  var tbTest : TFDTable;
  begin
    tbTest := TFDTable.Create(nil);
    try
      tbTest.UpdateOptions.AutoCommitUpdates := true;
      tbTest.UpdateOptions.UpdateMode := upWhereAll;
      tbTest.Connection := con1;
      tbTest.TableName := 'TEST';
      tbTest.Open();
      tbTest.Append;
      tbTest.FieldByName('test').AsString := aStr;
      tbTest.Post;
      tbTest.Close;
    finally
      tbTest.Free;
    end;
  end;

  procedure AddusingFDQuery(aStr : String);
  var qry1 : TFDQuery;
  begin
    qry1 := TFDQuery.Create(nil);
    try
      qry1.Connection := con1;
      qry1.SQL.Clear;
      qry1.SQL.Add('insert into test (test) values ( :Testing )');
      qry1.ParamByName('Testing').AsString := aStr;
      qry1.ExecSQL;
    finally
      qry1.Free;
    end;
  end;

begin
  case addVia of
    adTable: AddUsingFDTable(aString);
    adQuery: AddusingFDQuery(aString);
    else
      AddUsingFDTable(aString);
  end;

  tb1.Close;
  con1.close();
  con1.Open();
  tb1.Open();
end;

procedure TForm1.AppException(Sender: TObject; e: Exception);
begin
  if e.ClassType = Exception_QryTest then
    AddData(e.Message, adQuery)
  else
    AddData(e.Message, adTable);
  Application.ShowException(e);
end;

procedure TForm1.btnTableNonExcClick(Sender: TObject);
begin
  AddData( TButton(Sender).Name + '-Click-Table' , adTable);
end;

procedure TForm1.btnQryExcptClick(Sender: TObject);
begin
  raise Exception_QryTest.Create('QueryTestError ' + FormatDateTime('dd/mmm/yyyy HH:NN:SS', now));
end;

procedure TForm1.btnQueryNonExcClick(Sender: TObject);
begin
  AddData( TButton(Sender).Name + '-Click-Query' , adQuery);
end;

procedure TForm1.btnTableExceptClick(Sender: TObject);
begin
  raise Exception_TableTest.Create('TableTestError ' + FormatDateTime('dd/mmm/yyyy HH:NN:SS', now));
end;

procedure TForm1.FormCreate(Sender: TObject);
var qry1 : TFDQuery;
begin
  con1.Open();
  if con1.Connected then begin
    qry1 := TFDQuery.Create(nil);
    qry1.Connection := con1;
    try
      qry1.SQL.Clear;
      qry1.SQL.Add
     ('Create Table if not Exists TEST(test char(255));');
    finally
      qry1.ExecSQL;
      qry1.Free;
    end;
    tb1.Open();
  end;
  Application.OnException := AppException;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
begin
  tmr1.Enabled := false;
  try
    if not (TFontStyle.fsBold in btnTableExcept.TextSettings.Font.Style) then
      btnTableExcept.TextSettings.Font.Style := btnTableExcept.TextSettings.Font.Style + [ TFontStyle.fsBold]
    else
      btnTableExcept.TextSettings.Font.Style := btnTableExcept.TextSettings.Font.Style - [ TFontStyle.fsBold];
  finally
    tmr1.Enabled := true;
  end;
end;

end.
