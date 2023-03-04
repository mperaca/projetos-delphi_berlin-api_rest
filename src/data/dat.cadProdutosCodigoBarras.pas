unit dat.cadProdutosCodigoBarras;

interface

uses Vcl.Dialogs, System.UITypes, System.JSON, DataSet.Serialize, FireDAC.Stan.Param,
     System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
     FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
     FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
     Data.DB, FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.DApt,
  System.Generics.Collections;


function RetornaCodigoBarra(XId: integer): TJSONObject;
function RetornaListaCodigoBarras(const XQuery: TDictionary<string, string>; XIdProduto: integer): TJSONArray;
function IncluiCodigoBarra(XCodBarra: TJSONObject; XIdProduto: integer): TJSONObject;
function AlteraCodigoBarra(XIdCodBarra: integer; XCodBarra: TJSONObject): TJSONObject;
function ApagaCodigoBarra(XIdCodBarra: integer): TJSONObject;
function VerificaRequisicao(XCodBarra: TJSONObject): boolean;

implementation

uses prv.dataModuleConexao;

function RetornaCodigoBarra(XId: integer): TJSONObject;
var wquery: TFDQuery;
    wconexao: TProviderDataModuleConexao;
    wret: TJSONObject;
begin
  try
// cria provider de conex�o com BD
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
         SQL.Add('select "CodigoInternoProdutoCodigoBarra" as id,');
         SQL.Add('       "CodigoProdutoProdutoCodigoBarra" as idproduto,');
         SQL.Add('       "CodigoBarraProdutoCodigoBarra"   as codbarra ');
         SQL.Add('from "ProdutoCodigoBarra" ');
         SQL.Add('where "CodigoInternoProdutoCodigoBarra"=:xid ');
         ParamByName('xid').AsInteger := XId;
         Open;
         EnableControls;
       end;

   if wquery.RecordCount>0 then
      wret := wquery.ToJSONObject()
   else
      begin
        wret := TJSONObject.Create;
        wret.AddPair('status','500');
        wret.AddPair('description','Nenhum C�digo de Barra encontrado');
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
//      messagedlg('Problema ao retornar Atividade'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
end;

function RetornaListaCodigoBarras(const XQuery: TDictionary<string, string>; XIdProduto: integer): TJSONArray;
var wqueryLista: TFDQuery;
    wconexao: TProviderDataModuleConexao;
    wobj: TJSONObject;
    wret: TJSONArray;
begin
  try
// cria provider de conex�o com BD
    wconexao    := TProviderDataModuleConexao.Create(nil);
    wqueryLista := TFDQuery.Create(nil);

    if wconexao.EstabeleceConexaoDB then
       with wqueryLista do
       begin
         Connection := wconexao.FDConnectionApi;
         DisableControls;
         Close;
         SQL.Clear;
         Params.Clear;
         SQL.Add('select "CodigoInternoProdutoCodigoBarra" as id,');
         SQL.Add('       "CodigoProdutoProdutoCodigoBarra" as idproduto,');
         SQL.Add('       "CodigoBarraProdutoCodigoBarra"   as codbarra ');
         SQL.Add('from "ProdutoCodigoBarra" where "CodigoProdutoProdutoCodigoBarra"=:xidproduto ');
         ParamByName('xidproduto').AsInteger := XIdProduto;
         Open;
         EnableControls;
       end;
    if wqueryLista.RecordCount>0 then
       wret := wqueryLista.ToJSONArray()
    else
       begin
         wobj := TJSONObject.Create;
         wobj.AddPair('status','500');
         wobj.AddPair('description','Nenhum C�digo Barra encontrado');
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
//      messagedlg('Problema ao retorna listas de Atividades'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
//  wquery.Free;
end;

function IncluiCodigoBarra(XCodBarra: TJSONObject; XIdProduto: integer): TJSONObject;
var wquery: TFDMemTable;
    wqueryInsert,wquerySelect: TFDQuery;
    wret: TJSONObject;
    wnum: integer;
    wconexao: TProviderDataModuleConexao;
    wval: string;
begin
  try
    wconexao     := TProviderDataModuleConexao.Create(nil);
    wqueryInsert := TFDQuery.Create(nil);
    if wconexao.EstabeleceConexaoDB then
       begin
         with wqueryInsert do
         begin
           Connection := wconexao.FDConnectionApi;
           DisableControls;
           Close;
           SQL.Clear;
           Params.Clear;
           SQL.Add('Insert into "ProdutoCodigoBarra" ("CodigoProdutoProdutoCodigoBarra","CodigoBarraProdutoCodigoBarra") ');
           SQL.Add('values (:xidproduto,:xcodbarra) ');
           ParamByName('xidproduto').AsInteger   := XIdProduto;
           if XCodBarra.TryGetValue('codbarra',wval) then
              ParamByName('xcodbarra').AsString := XCodBarra.GetValue('codbarra').Value
           else
              ParamByName('xcodbarra').AsString := '';
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
                SQL.Add('select "CodigoInternoProdutoCodigoBarra" as id,');
                SQL.Add('       "CodigoProdutoProdutoCodigoBarra" as idproduto,');
                SQL.Add('       "CodigoBarraProdutoCodigoBarra"   as codbarra ');
                SQL.Add('from "ProdutoCodigoBarra" where "CodigoProdutoProdutoCodigoBarra"=:xidproduto and "CodigoBarraProdutoCodigoBarra"=:xcodbarra ');
                ParamByName('xidproduto').AsInteger  := XIdProduto;
                if XCodBarra.TryGetValue('codbarra',wval) then
                   ParamByName('xcodbarra').AsString := XCodBarra.GetValue('codbarra').Value
                else
                   ParamByName('xcodbarra').AsString := '';
                Open;
                EnableControls;
              end;
              wret := wquerySelect.ToJSONObject();
            end
         else
            begin
              wret := TJSONObject.Create;
              wret.AddPair('status','500');
              wret.AddPair('description','Nenhum C�digo Barra inclu�do');
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

function AlteraCodigoBarra(XIdCodBarra: integer; XCodBarra: TJSONObject): TJSONObject;
var wquery: TFDMemTable;
    wqueryUpdate,wquerySelect: TFDQuery;
    wret: TJSONObject;
    wconexao: TProviderDataModuleConexao;
    wcampos,wval: string;
    wnum: integer;
begin
  try
    wcampos      := '';
    wconexao     := TProviderDataModuleConexao.Create(nil);
    wqueryUpdate := TFDQuery.Create(nil);
    //define quais campos ser�o alterados
    if XCodBarra.TryGetValue('codbarra',wval) then
       begin
         if wcampos='' then
            wcampos := '"CodigoBarraProdutoCodigoBarra"=:xcodbarra'
         else
            wcampos := wcampos+',"CodigoBarraProdutoCodigoBarra"=:xcodbarra';
       end;
    if wconexao.EstabeleceConexaoDB then
       begin
         with wqueryUpdate do
         begin
           Connection := wconexao.FDConnectionApi;
           DisableControls;
           Close;
           SQL.Clear;
           Params.Clear;
           SQL.Add('Update "ProdutoCodigoBarra" set '+wcampos+' ');
           SQL.Add('where "CodigoInternoProdutoCodigoBarra"=:xid ');
           ParamByName('xid').AsInteger            := XIdCodBarra;
           if XCodBarra.TryGetValue('codbarra',wval) then
              ParamByName('xcodbarra').AsString    := XCodBarra.GetValue('codbarra').Value;
           ExecSQL;
           EnableControls;
           wnum := RowsAffected;
         end;
         wquerySelect := TFDQuery.Create(nil);
         if wnum>0 then
            with wquerySelect do
            begin
              Connection := wconexao.FDConnectionApi;
              DisableControls;
              Close;
              SQL.Clear;
              Params.Clear;
              SQL.Add('select "CodigoInternoProdutoCodigoBarra" as id,');
              SQL.Add('       "CodigoProdutoProdutoCodigoBarra" as idproduto,');
              SQL.Add('       "CodigoBarraProdutoCodigoBarra"   as codbarra ');
              SQL.Add('from "ProdutoCodigoBarra" ');
              SQL.Add('where "CodigoInternoProdutoCodigoBarra" =:xid ');
              ParamByName('xid').AsInteger := XIdCodBarra;
              Open;
              EnableControls;
            end
         else
           begin
              wret := TJSONObject.Create;
              wret.AddPair('status','500');
              wret.AddPair('description','Nenhum C�digo Barra alterado');
              wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
            end;
       end;

    wret   := wquerySelect.ToJSONObject();
  except
    On E: Exception do
    begin
      wconexao.EncerraConexaoDB;
      wret := TJSONObject.Create;
      wret.AddPair('status','500');
      wret.AddPair('description',E.Message);
      wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
//      messagedlg('Problema ao alterar Atividade'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
//  wquery.Free;
end;

function VerificaRequisicao(XCodBarra: TJSONObject): boolean;
var wret: boolean;
    wval: string;
begin
  try
    wret := true;
    if not XCodBarra.TryGetValue('codbarra',wval) then
       wret := false;
  finally
  end;
  Result := wret;
end;

function ApagaCodigoBarra(XIdCodBarra: integer): TJSONObject;
var wret: TJSONObject;
    wconexao: TProviderDataModuleConexao;
    wqueryDelete: TFDQuery;
    wnum: integer;
begin
  try
    wret         := TJSONObject.Create;
    wconexao     := TProviderDataModuleConexao.Create(nil);
    wqueryDelete := TFDQuery.Create(nil);

    if wconexao.EstabeleceConexaoDB then
       with wqueryDelete do
       begin
         Connection := wconexao.FDConnectionApi;
         DisableControls;
         Close;
         SQL.Clear;
         Params.Clear;
         SQL.Add('delete from "ProdutoCodigoBarra" where "CodigoInternoProdutoCodigoBarra"=:xid ');
         ParamByName('xid').AsInteger := XIdCodBarra;
         ExecSQL;
         EnableControls;
         wnum := RowsAffected;
       end
    else
       wnum := 0;

    if wnum>0 then
       begin
         wret.AddPair('status','200');
         wret.AddPair('description','C�digo Barra exclu�do com sucesso');
       end
    else
       begin
         wret.AddPair('status','500');
         wret.AddPair('description','Nenhum C�digo Barra exclu�do');
       end;
    wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
  except
    On E: Exception do
    begin
      wconexao.EncerraConexaoDB;
      wret.AddPair('status','500');
      wret.AddPair('description',E.Message);
      wret.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
//      messagedlg('Problema ao excluir Atividade'+slinebreak+E.Message,mterror,[mbok],0);
    end;
  end;
  wconexao.EncerraConexaoDB;
  Result := wret;
end;
end.
