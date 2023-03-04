unit ctl.movNotasFiscais;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses prv.dataModuleConexao, dat.movNotasFiscais;


procedure ListaTodasNotas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wlista: TJSONArray;
    wval: string;
    wret,werro: TJSONObject;
    widempresa: integer;
    wconexao: TProviderDataModuleConexao;
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
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini
    wlista := TJSONArray.Create;
    wlista := dat.movNotasFiscais.RetornaListaNotas(Req.Query,widempresa,wlimit,woffset);
    wret   := wlista.Items[0] as TJSONObject;
    if wret.TryGetValue('status',wval) then
       Res.Send<TJSONArray>(wlista).Status(400)
    else
       Res.Send<TJSONArray>(wlista).Status(200);
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


procedure RetornaNota(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnota,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid   := Req.Params['id'].ToInteger; // recupera o id do or�amento
    wnota := TJSONObject.Create;
    wnota := Req.Body<TJSONObject>;
    wnota := dat.movNotasFiscais.RetornaNota(wid);
    if wnota.TryGetValue('status',wval) then
       Res.Send<TJSONObject>(wnota).Status(400)
    else
       Res.Send<TJSONObject>(wnota).Status(200);
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

procedure ExcluiNota(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnota,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid   := Req.Params['id'].ToInteger; // recupera o id do or�amento
    wnota := TJSONObject.Create;
    wnota := dat.movNotasFiscais.ApagaNotaFiscal(wid);
    if wnota.GetValue('status').Value='200' then
       Res.Send<TJSONObject>(wnota).Status(200)
    else
       Res.Send<TJSONObject>(wnota).Status(400);
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

procedure AlteraNota(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnewnota,wnota,werro,wresp: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid      := Req.Params['id'].ToInteger; // recupera o id do or�amento
    wnewnota := TJSONObject.Create;
    wnota    := TJSONObject.Create;
    wresp    := TJSONObject.Create;
    wnota    := Req.Body<TJSONObject>;
    wnewnota := dat.movNotasFiscais.AlteraNotaFiscal(wid,wnota);
    if wnewnota.TryGetValue('pedido',wval) then
       begin
         wnewnota.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wnewnota).Status(200)
       end
    else
       begin
         wresp.AddPair('status','400');
         wresp.AddPair('description','Nota Fiscal n�o encontrada');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(400);
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

procedure CriaNota(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wnota,wnewnota,wresp,werro: TJSONObject;
    wval: string;
    widempresa: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wnota      := TJSONObject.Create;
    wnewnota   := TJSONObject.Create;
    wresp      := TJSONObject.Create;
    wnota      := Req.Body<TJSONObject>;
    wconexao   := TProviderDataModuleConexao.Create(nil);
    widempresa := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini

//    widempresa      := strtointdef(Req.Headers['idempresa'],0);

    if widempresa=0 then
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','idempresa n�o definido');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end
    else if dat.movNotasFiscais.VerificaRequisicao(wnota) then
       begin
         wnewnota := dat.movNotasFiscais.IncluiNotaFiscal(Req.Query,wnota,widempresa);
         if wnewnota.TryGetValue('status',wval) then
            Res.Send<TJSONObject>(wnewnota).Status(400)
         else
            Res.Send<TJSONObject>(wnewnota).Status(201);
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

procedure RetornaTotalNotas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wtotal,werro: TJSONObject;
    wval: string;
begin
  try
    wtotal := TJSONObject.Create;
    wtotal := dat.movNotasFiscais.RetornaTotalNotas(Req.Query);
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
  THorse.Get('/trabinapi/movimentos/notasfiscais',ListaTodasNotas);
  THorse.Get('/trabinapi/movimentos/notasfiscais/:id',RetornaNota);
  THorse.Get('/trabinapi/movimentos/notasfiscais/total',RetornaTotalNotas);

// M�todo Post
  THorse.Post('/trabinapi/movimentos/notasfiscais',CriaNota);


// M�todo Put
  THorse.Put('/trabinapi/movimentos/notasfiscais/:id',AlteraNota);

  // M�todo Delete
  THorse.Delete('/trabinapi/movimentos/notasfiscais/:id',ExcluiNota);
end;

initialization

// defini��o da documenta��o
  Swagger
    .BasePath('trabinapi')
    .Path('movimentos/notasfiscais')
      .Tag('Notas Fiscais')
      .GET('Listar notas')
        .AddParamQuery('id', 'Id').&End
        .AddParamQuery('numero', 'N�mero').&End
        .AddParamQuery('datavalidade', 'Data Validade').&End
        .AddParamQuery('cliente', 'Cliente').&End
        .AddParamQuery('vendedor', 'Vendedor').&End
        .AddParamQuery('total', 'Total').&End
        .AddParamQuery('condicao', 'Condi��o').&End
        .AddParamQuery('cobranca', 'Cobran�a').&End
//        .AddResponse(200, 'Lista de or�amentos').Schema(TOrcamentos).IsArray(True).&End
      .&End
      .POST('Criar um novo or�amento')
//        .AddParamBody('Dados do or�amento').Required(True).Schema(TOrcamentos).&End
//        .AddResponse(201).Schema(TOrcamentos).&End
        .AddResponse(400).&End
      .&End
    .&End
    .Path('movimentos/notasfiscais/{id}')
      .Tag('Or�amentos')
      .GET('Obter os dados de uma nota espec�fica')
        .AddParamPath('id', 'Id').&End
//        .AddResponse(200, 'Dados da or�amento').Schema(TOrcamentos).&End
        .AddResponse(404).&End
      .&End
      .PUT('Alterar os dados de uma nota')
        .AddParamPath('id', 'C�digo').&End
//        .AddParamBody('Dados do Or�amento').Required(True).Schema(TOrcamentosAltera).&End
//        .AddResponse(201).Schema(TOrcamentos).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
      .DELETE('Excluir nota')
        .AddParamPath('id', 'Id').&End
        .AddResponse(204).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
    .&End
  .&End;
end.
