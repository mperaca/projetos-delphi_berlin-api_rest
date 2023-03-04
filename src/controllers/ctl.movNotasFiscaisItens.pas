unit ctl.movNotasFiscaisItens;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses prv.dataModuleConexao, dat.movNotasFiscaisItens;


procedure RetornaNotaFiscalItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaitem,werro: TJSONObject;
    wid,widnota: integer;
    wval: string;
begin
  try
    widnota   := Req.Params['nota'].ToInteger; // recupera o id da nfe
    wid       := Req.Params['id'].ToInteger; // recupera o id do item
    wnotaitem := TJSONObject.Create;
    wnotaitem := dat.movNotasFiscaisItens.RetornaNotaFiscalItem(widnota,wid);
    if wnotaitem.TryGetValue('status',wval) then
       Res.Send<TJSONObject>(wnotaitem).Status(400)
    else
       Res.Send<TJSONObject>(wnotaitem).Status(200);
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;

procedure RetornaIdNotaFiscalItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaitem,werro: TJSONObject;
    widproduto,widnota,widitem: integer;
    wval: string;
begin
  try
    wnotaitem      := TJSONObject.Create;
    widnota        := Req.Params['nota'].ToInteger; // recupera o id do pedido
    widproduto     := Req.Params['idproduto'].ToInteger; // recupera o id do produto
//    wnotaitem      := dat.movNotasFiscaisItens.RetornaIdOrcamentoItem(widorcamento,widproduto);
    Res.Send<TJSONObject>(wnotaitem).Status(200);
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;

procedure RetornaIdNotaFiscalItemGrade(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaitem,werro: TJSONObject;
    widproduto,widnota,widitem,wtamanho,wcor: integer;
    wval: string;
begin
  try
    wnotaitem      := TJSONObject.Create;
    widnota        := Req.Params['nota'].ToInteger; // recupera o id do pedido
    widproduto     := Req.Params['idproduto'].ToInteger; // recupera o id do produto
    wtamanho       := Req.Params['tamanho'].ToInteger; // recupera o id do produto
    wcor           := Req.Params['cor'].ToInteger; // recupera o id do produto
//    wnotaitem      := dat.movOrcamentosItens.RetornaIdOrcamentoItemGrade(widorcamento,widproduto,wtamanho,wcor);
    Res.Send<TJSONObject>(wnotaitem).Status(200);
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;


procedure RetornaNotaFiscalItens(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaitem: TJSONArray;
    werro: TJSONObject;
    widnota: integer;
    wval: string;
    wlimit,woffset: integer;
begin
  try
    if Req.Query.ContainsKey('limit') then // limite de registros retornados
       wlimit := Req.Query.Items['limit'].ToInteger
    else
       wlimit := -1;
    if Req.Query.ContainsKey('offset') then // offset do registro
       woffset := Req.Query.Items['offset'].ToInteger
    else
       woffset := -1;
    widnota   := Req.Params['nota'].ToInteger; // recupera o id da nfe
    wnotaitem := TJSONArray.Create;
    wnotaitem := dat.movNotasFiscaisItens.RetornaNotaFiscalItens(Req.Query,widnota,wlimit,woffset);
    werro    := wnotaitem.Get(0) as TJSONObject;
    if werro.TryGetValue('status',wval) then
       begin
         Res.Send<TJSONArray>(wnotaitem).Status(400);
       end
    else
       begin
         Res.Send<TJSONArray>(wnotaitem).Status(200);
       end;
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;


procedure ExcluiNotaFiscalItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaitem,werro: TJSONObject;
    widnota,wid: integer;
    wval: string;
begin
  try
    widnota   := Req.Params['nota'].ToInteger; // recupera o id do or�amento
    wid       := Req.Params['id'].ToInteger; // recupera o id do item
    wnotaitem := TJSONObject.Create;
    wnotaitem := Req.Body<TJSONObject>;
    wnotaitem := dat.movNotasFiscaisItens.ApagaNotaItem(widnota,wid);
    if wnotaitem.GetValue('status').Value='200' then
       Res.Send<TJSONObject>(wnotaitem).Status(200)
    else
       Res.Send<TJSONObject>(wnotaitem).Status(400);
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;

procedure CriaNotaFiscalItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaItem,wnewnotaItem,wresp,werro: TJSONObject;
    wval: string;
    widempresa,widnota: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wnotaItem     := TJSONObject.Create;
    wnewnotaItem  := TJSONObject.Create;
    wresp         := TJSONObject.Create;
    wnotaItem     := Req.Body<TJSONObject>;
    widnota       := Req.Params['nota'].ToInteger; // recupera o id do or�amento
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini

//    widempresa      := strtointdef(Req.Headers['idempresa'],0);

    if widempresa=0 then
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','idempresa n�o definido');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end
//    else if dat.movOrcamentosItens.VerificaRequisicao(worcamentoitem) then
//       begin
//         wnewnotaItem := dat.movOrcamentosItens.IncluiOrcamentoItem(worcamentoItem,widorcamento,widempresa);
//         if wnewnotaItem.TryGetValue('status',wval) then
//            Res.Send<TJSONObject>(wnewnotaItem).Status(400)
//         else
//            Res.Send<TJSONObject>(wnewnotaItem).Status(201);
//       end
    else
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','JSON preenchido incorretamente');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end;
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;

procedure AlteraNotaFiscalItem(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnotaItem,wnewnotaItem,wresp,werro: TJSONObject;
    wval: string;
    widempresa,widnota,widitem: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wnotaItem     := TJSONObject.Create;
    wnewnotaItem  := TJSONObject.Create;
    wresp         := TJSONObject.Create;
    wnotaItem     := Req.Body<TJSONObject>;
    widnota       := Req.Params['nota'].ToInteger; // recupera o id do or�amento
    widitem       := Req.Params['id'].ToInteger; // recupera o id do item
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini

//    widempresa      := strtointdef(Req.Headers['idempresa'],0);

    if widempresa=0 then
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','idempresa n�o definido');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
         exit;
       end;

    wnewnotaItem := dat.movNotasFiscaisItens.AlteraNotaItem(widitem,wnotaItem);
    if wnewnotaItem.TryGetValue('idproduto',wval) then
       begin
         wnewnotaItem.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wnewnotaItem).Status(200)
       end
    else
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','JSON preenchido incorretamente');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end;
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;

procedure RetornaTotalItens(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wtotal,werro: TJSONObject;
    wval: string;
    widnota: integer;
begin
  try
    widnota := Req.Params['nota'].ToInteger; // recupera o id da Pessoa
    wtotal  := TJSONObject.Create;
    wtotal  := dat.movNotasFiscaisItens.RetornaTotalItens(Req.Query,widnota);
    if wtotal.TryGetValue('status',wval) then
       Res.Send<TJSONObject>(wtotal).Status(400)
    else
       Res.Send<TJSONObject>(wtotal).Status(200);
  except
    On E: Exception do
    begin
      werro := TJSONObject.Create;
      werro.AddPair('status','500');
      werro.AddPair('description',E.Message);
      werro.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
    end;
  end;
end;


procedure Registry;
begin
// M�todo Get
  THorse.Get('/trabinapi/movimentos/notasfiscais/:nota/itens',RetornaNotaFiscalItens);
  THorse.Get('/trabinapi/movimentos/notasfiscais/:nota/itens/:id',RetornaNotaFiscalItem);
  THorse.Get('/trabinapi/movimentos/notasfiscais/:nota/itens/total',RetornaTotalItens);
  THorse.Get('/trabinapi/movimentos/notasfiscais/:nota/itens/produto/:idproduto',RetornaIdNotaFiscalItem);
  THorse.Get('/trabinapi/movimentos/notasfiscais/:nota/itens/produto/:idproduto/tamanho/:tamanho/cor/:cor',RetornaIdNotaFiscalItemGrade);

// M�todo Post
  THorse.Post('/trabinapi/movimentos/notasfiscais/:nota/itens',CriaNotaFiscalItem);

// M�todo Put
  THorse.Put('/trabinapi/movimentos/notasfiscais/:nota/itens/:id',AlteraNotaFiscalItem);


// M�todo Delete
  THorse.Delete('/trabinapi/movimentos/notasfiscais/:nota/itens/:id',ExcluiNotaFiscalItem);
end;

initialization

// defini��o da documenta��o
  Swagger
    .BasePath('trabinapi')
    .Path('movimentos/orcamentos/{orcamento}/itens')
      .Tag('Or�amento �tens')
      .GET('Listar or�amentos �tens')
        .AddParamQuery('id', 'Id').&End
        .AddParamQuery('codproduto', 'C�digo Produto').&End
        .AddParamQuery('descproduto', 'Descri��o Produto').&End
//        .AddResponse(200, 'Lista de �tens de or�amento').Schema(TOrcamentosItens).IsArray(True).&End
      .&End
      .POST('Criar um novo �tem de or�amento')
//        .AddParamBody('Dados do �tem de or�amento').Required(True).Schema(TOrcamentosItensCria).&End
//        .AddResponse(201).Schema(TOrcamentosItens).&End
        .AddResponse(400).&End
      .&End
    .&End
    .Path('movimentos/orcamentos/{orcamento}/itens/{id}')
      .Tag('Or�amento �tens')
      .GET('Obter os dados de um �tem de or�amento espec�fico')
        .AddParamPath('id', 'Id').&End
//        .AddResponse(200, 'Dados da or�amento').Schema(TOrcamentosItens).&End
        .AddResponse(404).&End
      .&End
      .PUT('Alterar os dados de um or�amento �tem')
        .AddParamPath('id', 'C�digo').&End
//        .AddParamBody('Dados do �tem').Required(True).Schema(TOrcamentosItensCria).&End
//        .AddResponse(201).Schema(TOrcamentosItens).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
      .DELETE('Excluir or�amento �tem')
        .AddParamPath('id', 'Id').&End
        .AddResponse(204).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
    .&End
  .&End;

end.
