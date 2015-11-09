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
  TForm1 = class(TForm)
    con1: TFDConnection;
    btn1: TButton;
    qry1: TFDQuery;
    fdgxwtcrsr1: TFDGUIxWaitCursor;
    tb1: TFDTable;
    btn2: TButton;
    strngrd1: TStringGrid;
    tb1test: TStringField;
    bndsrcdb1: TBindSourceDB;
    bndngslst1: TBindingsList;
    lnkgrdtdtsrcBindSourceDB: TLinkGridToDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
    procedure AddData(aString : String);
  public
    { Public declarations }
    procedure AppException(Sender: TObject; e: Exception);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AddData(aString: String);
begin
  tb1.Append;
  tb1.FieldByName('test').AsString := aString;
  tb1.Post;
  tb1.Close;
  con1.close();
  con1.Open();
  tb1.Open();
end;

procedure TForm1.AppException(Sender: TObject; e: Exception);
begin
  AddData(e.Message);
  Application.ShowException(e);
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  AddData('btn1Click');
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  raise Exception.Create('Error Message');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  con1.Open();
  if con1.Connected then begin
    qry1.SQL.Clear;
    qry1.SQL.Add
   ('Create Table if not Exists TEST(test char(255));');
    qry1.ExecSQL;
    tb1.Open();
  end;
  Application.OnException := AppException;
end;

end.
