unit dat.movNFePendentesItens;

interface

uses Vcl.Dialogs, System.UITypes, System.JSON, DataSet.Serialize, FireDAC.Stan.Param,
     System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
     FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
     FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
     Data.DB, FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.DApt,
  System.Generics.Collections;


function RetornaNFePendenteItem(XNFe,XId: integer): TJSONObject;
function ApagaNFePendenteItem(XNFe,XId: integer): TJSONObject;
function RetornaNFePendenteItens(XNFe: integer): TJSONArray;
function IncluiNFePendenteItem(XNFeItem: TJSONObject; XIdNFe,XIdEmpresa: integer): TJSONObject;
function RetornaIdItem(XFDConnection: TFDConnection): integer;
function VerificaRequisicao(XNFeItem: TJSONObject): boolean;
procedure RetornaCamposProduto(XFDConnection: TFDConnection; XIdNFe: integer; XNFeItem: TJSONObject);

implementation

uses prv.dataModuleConexao;

var FNumItem,FIdItem,FCodProduto,FCodAliquota,FCodVendedor,FCodFiscal,FCodSitTrib: integer;
    FQtde,FUnitario,FTotal: double;
    FIncideST: boolean;
    FDatMov: tdatetime;


function RetornaNFePendenteItem(XNFe,XId: integer): TJSONObject;
var wquery: TFDQuery;
    wconexao: TProviderDataModuleConexao;
    wret: TJSONObject;
begin
  try
// cria provider de conex?o com BD
    wconexao := TProviderDataModuleConexao.Create(nil);

    wquery   := TFDQuery.Create(nil);
    if wconexao.EstabeleceConexaoDB then
       with wquery do
       begin
         Connection := wconexao.FDConnectionApi;
         DisableControls;
         Close;
         SQL.Clear;
         Params.Clear;
         SQL.Add('select "CodigoInternoItem"       as id,');
         SQL.Add('       "CodigoNotaItem"          as idnfe,');
         SQL.Add('       "NumeroItem"              as numitem,');
         SQL.Add('       ts_retornaprodutocodigo("CodigoProdutoItem") as codproduto,');
         SQL.Add('       ts_retornaprodutodescricao("CodigoProdutoItem") as descproduto,');
         SQL.Add('       "QuantidadeItem"          as qtde,');
         SQL.Add('       "ValorUnitarioItem"       as unitario,');
         SQL.Add('       "ValorTotalItem"          as total ');
         SQL.Add('from "NotaItem" where "CodigoNotaItem"=:xnfe and "CodigoInternoItem"=:xid ');
         ParamByName('xnfe').AsInteger := XNFe;
         ParamByName('xid').AsInteger  := XId;
         Open;
         EnableControls;
       end;

   if wquery.RecordCount>0 then
      wret := wquery.ToJSONObject()
   else
      begin
        wret := TJSONObject.Create;
        wret.AddPair('status','500');
        wret.AddPair('description','Nenhum ?tem encontrado');
        wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
      end;

  except
    On E: Exception do
    begin
      wconexao.EncerraConexaoDB;
      wret := TJSONObject.Create;
      wret.AddPair('status','500');
      wret.AddPair('description',E.Message);
      wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
//      messagedlg('Problema ao retornar localidade'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
end;

function ApagaNFePendenteItem(XNFe,XId: integer): TJSONObject;
var wquery: TFDQuery;
    wconexao: TProviderDataModuleConexao;
    wret: TJSONObject;
begin
  try
// cria provider de conex?o com BD
    wconexao := TProviderDataModuleConexao.Create(nil);

    wquery   := TFDQuery.Create(nil);
    if wconexao.EstabeleceConexaoDB then
       with wquery do
       begin
         Connection := wconexao.FDConnectionApi;
         DisableControls;
         Close;
         SQL.Clear;
         Params.Clear;
         SQL.Add('delete from "NotaItem" where "CodigoNotaItem"=:xnfe and "CodigoInternoItem"=:xid ');
         ParamByName('xnfe').AsInteger := XNFe;
         ParamByName('xid').AsInteger  := XId;
         ExecSQL;
         EnableControls;
       end;

    if wquery.RowsAffected > 0 then
       begin
         wret := TJSONObject.Create;
         wret.AddPair('status','200');
         wret.AddPair('description','?tem exclu?do com sucesso');
         wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
       end
    else
       begin
         wret := TJSONObject.Create;
         wret.AddPair('status','500');
         wret.AddPair('description','Nenhum ?tem exclu?do');
         wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
       end;

  except
    On E: Exception do
    begin
      wconexao.EncerraConexaoDB;
      wret := TJSONObject.Create;
      wret.AddPair('status','500');
      wret.AddPair('description',E.Message);
      wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
//      messagedlg('Problema ao retornar localidade'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
end;

function RetornaNFePendenteItens(XNFe: integer): TJSONArray;
var wquery: TFDQuery;
    wconexao: TProviderDataModuleConexao;
    wobj: TJSONObject;
    wret: TJSONArray;
begin
  try
// cria provider de conex?o com BD
    wconexao := TProviderDataModuleConexao.Create(nil);

    wquery   := TFDQuery.Create(nil);
    if wconexao.EstabeleceConexaoDB then
       with wquery do
       begin
         Connection := wconexao.FDConnectionApi;
         DisableControls;
         Close;
         SQL.Clear;
         Params.Clear;
         SQL.Add('select "CodigoInternoItem"       as id,');
         SQL.Add('       "CodigoNotaItem"          as idnfe,');
         SQL.Add('       "NumeroItem"              as numitem,');
         SQL.Add('       ts_retornaprodutocodigo("CodigoProdutoItem") as codproduto,');
         SQL.Add('       ts_retornaprodutodescricao("CodigoProdutoItem") as descproduto,');
         SQL.Add('       "QuantidadeItem"          as qtde,');
         SQL.Add('       "ValorUnitarioItem"       as unitario,');
         SQL.Add('       "ValorTotalItem"          as total ');
         SQL.Add('from "NotaItem" where "CodigoNotaItem"=:xnfe ');
         ParamByName('xnfe').AsInteger := XNFe;
         Open;
         EnableControls;
       end;

   if wquery.RecordCount>0 then
      wret := wquery.ToJSONArray()
   else
      begin
        wobj := TJSONObject.Create;
        wobj.AddPair('status','404');
        wobj.AddPair('description','Nenhum ?tem encontrado');
        wobj.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
        wret := TJSONArray.Create;
        wret.AddElement(wobj);
      end;

  except
    On E: Exception do
    begin
      wconexao.EncerraConexaoDB;
      wobj := TJSONObject.Create;
      wobj.AddPair('status','500');
      wobj.AddPair('description',E.Message);
      wobj.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
      wret := TJSONArray.Create;
      wret.AddElement(wobj);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
end;


function IncluiNFePendenteItem(XNFeItem: TJSONObject; XIdNFe,XIdEmpresa: integer): TJSONObject;
var wquery: TFDMemTable;
    wqueryInsert,wquerySelect: TFDQuery;
    wret: TJSONObject;
    wnum: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wconexao     := TProviderDataModuleConexao.Create(nil);
    wqueryInsert := TFDQuery.Create(nil);
    if wconexao.EstabeleceConexaoDB then
       begin
         FIdItem     := RetornaIdItem(wconexao.FDConnectionApi);
         RetornaCamposProduto(wconexao.FDConnectionApi,XIdNFe,XNFeItem);
         with wqueryInsert do
         begin
           Connection := wconexao.FDConnectionApi;
           DisableControls;
           Close;
           SQL.Clear;
           Params.Clear;
           SQL.Add('Insert into "NotaItem" ("CodigoInternoItem","CodigoNotaItem","CodigoEmpresaItem","CodigoProdutoItem","QuantidadeItem","ValorUnitarioItem","ValorTotalItem","TipoOperacaoItem","DataMovimentoItem",');
           SQL.Add('"CodigoAliquotaICMSItem","CodigoVendedorItem","CodigoFiscalItem","CodigoSituacaoTributariaItem","NumeroItem") ');
           SQL.Add('values (:xiditem,:xidnota,:xidempresa,:xcodproduto,:xquantidade,:xunitario,:xtotalitem,:xtipo,:xdatamov,:xaliquota,:xvendedor,:xcodfiscal,:xsittrib,:xnumitem) ');
           ParamByName('xiditem').AsInteger     := FIdItem;
           ParamByName('xidnota').AsInteger     := XIdNFe;
           ParamByName('xidempresa').AsInteger  := XIdEmpresa;
           ParamByName('xcodproduto').AsInteger := FCodProduto;
           ParamByName('xquantidade').AsFloat   := FQtde;
           ParamByName('xunitario').AsFloat     := FUnitario;
           ParamByName('xtotalitem').AsFloat    := FTotal;
           ParamByName('xtipo').AsString        := 'S';
           ParamByName('xdatamov').AsDateTime   := FDatmov;
           ParamByName('xaliquota').AsInteger   := FCodAliquota;
           ParamByName('xvendedor').AsInteger   := FCodVendedor;
           ParamByName('xcodfiscal').AsInteger  := FCodFiscal;
           ParamByName('xsittrib').AsInteger    := FCodSitTrib;
           ParamByName('xnumitem').AsInteger    := FNumItem;
           ExecSQL;
           EnableControls;
           wnum := RowsAffected;
         end;

         if wnum>0 then
            begin
              wquerySelect := TFDQuery.Create(nil);
              with wquerySelect do
              begin
                Connection := wconexao.FDConnectionApi;
                DisableControls;
                Close;
                SQL.Clear;
                Params.Clear;
                SQL.Add('select "CodigoInternoItem" as id, "CodigoNotaItem" as idnfe, "NumeroItem" as numitem, "DataMovimentoItem" as datamovimento,');
                SQL.Add('"CodigoProdutoItem" as idproduto, ts_retornaprodutocodigo("CodigoProdutoItem") as codproduto, ts_retornaprodutodescricao("CodigoProdutoItem") as descproduto,');
                SQL.Add('"QuantidadeItem" as quantidade, "ValorUnitarioItem" as unitario, "ValorTotalItem" as total,');
                SQL.Add('ts_retornafiscalcodigo("CodigoFiscalItem") as cfop,');
                SQL.Add('ts_retornasituacaotributariacodigo("CodigoSituacaoTributariaItem") as csticm ');
                SQL.Add('from "NotaItem" ');
                SQL.Add('where "CodigoInternoItem" =:xiditem ');
                ParamByName('xiditem').AsInteger := FIdItem;
                Open;
                EnableControls;
              end;
              wret := wquerySelect.ToJSONObject();
            end
         else
            begin
              wret := TJSONObject.Create;
              wret.AddPair('status','500');
              wret.AddPair('description','Nenhum ?tem inclu?do');
              wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
            end;
        end;
  except
    On E: Exception do
    begin
      wconexao.EncerraConexaoDB;
      wret := TJSONObject.Create;
      wret.AddPair('status','500');
      wret.AddPair('description',E.Message);
      wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
//      messagedlg('Problema ao incluir nova Atividade'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
//  wquery.Free;
end;

function VerificaRequisicao(XNFeItem: TJSONObject): boolean;
var wret: boolean;
    wval: string;
begin
  try
    wret := true;
    if not XNFeItem.TryGetValue('numitem',wval) then
       wret := false;
    if not XNFeItem.TryGetValue('datamovimento',wval) then
       wret := false;
    if not XNFeItem.TryGetValue('codproduto',wval) then
       wret := false;
    if not XNFeItem.TryGetValue('quantidade',wval) then
       wret := false;
    if not XNFeItem.TryGetValue('unitario',wval) then
       wret := false;
    if not XNFeItem.TryGetValue('total',wval) then
       wret := false;
  except
    On E: Exception do
    begin
      wret := false;
    end;
  end;
  Result := wret;
end;

function RetornaIdItem(XFDConnection: TFDConnection): integer;
var wret: integer;
    wsequence: string;
    wquery: TFDQuery;
begin
  wsequence := '"NotaItem_CodigoInternoItem_seq"';
  wquery    := TFDQuery.Create(nil);
  with wquery do
  begin
    Connection := XFDConnection;
    DisableControls;
    Close;
    SQL.Clear;
    Params.Clear;
    SQL.Add('select nextval('+QuotedStr(wsequence)+') as ult ');
    Open;
    EnableControls;
    if RecordCount > 0 then
       wret := wquery.FieldByName('ult').asInteger
    else
       wret := 0;
  end;
  Result := wret;
end;

procedure RetornaCamposProduto(XFDConnection: TFDConnection; XIdNFe: integer; XNFeItem: TJSONObject);
var wret: integer;
    wqueryProduto,wqueryNota: TFDQuery;
    wcodproduto: string;
begin
  wcodproduto   := XNFeItem.GetValue('codproduto').Value;
  FQtde         := strtofloat(XNFeItem.GetValue('quantidade').Value);
  FUnitario     := strtofloat(XNFeItem.GetValue('unitario').Value);
  FTotal        := strtofloat(XNFeItem.GetValue('total').Value);
  FNumItem      := strtoint(XNFeItem.GetValue('numitem').Value);

  wqueryProduto := TFDQuery.Create(nil);
  wqueryNota    := TFDQuery.Create(nil);

  with wqueryProduto do
  begin
    Connection := XFDConnection;
    DisableControls;
    Close;
    SQL.Clear;
    Params.Clear;
    SQL.Add('select "CodigoInternoProduto" as id, ');
    SQL.Add('       "IncideSubstituicaoProduto" as incidest,');
    SQL.Add('       "SituacaoTributariaProduto" as sittrib,');
    SQL.Add('       "CodigoAliquotaProduto"     as aliquota ');
    SQL.Add('from "Produto" where "CodigoProduto"=:xproduto and "AtivoProduto"=''true'' ');
    ParamByName('xproduto').AsString := wcodproduto;
    Open;
    EnableControls;
    if RecordCount > 0 then
       begin
         FCodProduto := FieldByName('id').AsInteger;
         FIncideST   := FieldByName('incidest').AsBoolean;
         FCodSitTrib := FieldByName('sittrib').AsInteger;
         FCodAliquota:= FieldByName('aliquota').AsInteger;
       end
    else
       begin
         FCodProduto := 0;
         FIncideST   := false;
         FCodSitTrib := 0;
         FCodAliquota:= 0;
       end;
  end;


  with wqueryNota do
  begin
    Connection := XFDConnection;
    DisableControls;
    Close;
    SQL.Clear;
    Params.Clear;
    SQL.Add('select "NotaFiscal"."CodigoRepresentanteNota" as vendedor,');
    if FIncideST then
       SQL.Add('"CondicaoPagamento"."CodigoFiscalSTCondicao" as codfiscal from "NotaFiscal" inner join "CondicaoPagamento" ')
    else
       SQL.Add('"CondicaoPagamento"."CodigoFiscalCondicao" as codfiscal from "NotaFiscal" inner join "CondicaoPagamento" ');
    SQL.Add('on "NotaFiscal"."CodigoCondicaoNota" = "CondicaoPagamento"."CodigoInternoCondicao" ');
    SQL.Add('where "CodigoInternoNota"=:xid ');
    ParamByName('xid').AsInteger := XIdNFe;
    Open;
    EnableControls;
    if RecordCount > 0 then
       begin
         FCodVendedor := wqueryNota.FieldByName('vendedor').asInteger;
         FCodFiscal   := wqueryNota.FieldByName('codfiscal').asInteger;
       end
    else
       begin
         FCodVendedor := 0;
         FCodFiscal   := 0;
       end;
  end;
end;


end.
