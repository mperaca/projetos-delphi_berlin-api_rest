unit ctl.movDFeForaPrazo;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses models.movOrcamentos, prv.dataModuleConexao, dat.movDFeForaPrazo;


procedure ListaTodosForaPrazo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    wlista := dat.movDFeForaPrazo.RetornaListaForaPrazo(Req.Query,widempresa,wlimit,woffset);
    wret   := wlista.Items[0] as TJSONObject;
    wret.TryGetValue('status',wval);
    if wval='500' then
//    if wret.TryGetValue('status',wval) then
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


procedure RetornaForaPrazo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var warquivado,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid         := Req.Params['id'].ToInteger; // recupera o id do or�amento
    warquivado  := TJSONObject.Create;
    warquivado  := Req.Body<TJSONObject>;
    warquivado  := dat.movDFeForaPrazo.RetornaForaPrazo(wid);
    warquivado.TryGetValue('status',wval);
    if wval='500' then
       Res.Send<TJSONObject>(warquivado).Status(400)
    else
       Res.Send<TJSONObject>(warquivado).Status(200);
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

procedure RetornaTotalForaPrazo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wtotal,werro: TJSONObject;
    wval: string;
begin
  try
    wtotal := TJSONObject.Create;
    wtotal := dat.movDFeForaPrazo.RetornaTotalForaPrazo(Req.Query);
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
  THorse.Get('/trabinapi/movimentos/dfe/documentosforaprazo',ListaTodosForaPrazo);
  THorse.Get('/trabinapi/movimentos/dfe/documentosforaprazo/total',RetornaTotalForaPrazo);
  THorse.Get('/trabinapi/movimentos/dfe/documentosforaprazo/:id',RetornaForaPrazo);

// M�todo Post
//  THorse.Post('/trabinapi/movimentos/dfe/consultados',CriaConsultado);


// M�todo Put
//  THorse.Put('/trabinapi/movimentos/dfe/consultados/:id',AlteraConsultado);

  // M�todo Delete
//  THorse.Delete('/trabinapi/movimentos/dfe/consultados/:id',ExcluiConsultado);
end;

initialization

// defini��o da documenta��o
  Swagger
    .BasePath('trabinapi')
    .Path('movimentos/orcamentos')
      .Tag('Or�amentos')
      .GET('Listar or�amentos')
        .AddParamQuery('id', 'Id').&End
        .AddParamQuery('numero', 'N�mero').&End
        .AddParamQuery('datavalidade', 'Data Validade').&End
        .AddParamQuery('cliente', 'Cliente').&End
        .AddParamQuery('vendedor', 'Vendedor').&End
        .AddParamQuery('total', 'Total').&End
        .AddParamQuery('condicao', 'Condi��o').&End
        .AddParamQuery('cobranca', 'Cobran�a').&End
        .AddResponse(200, 'Lista de or�amentos').Schema(TOrcamentos).IsArray(True).&End
      .&End
      .POST('Criar um novo or�amento')
        .AddParamBody('Dados do or�amento').Required(True).Schema(TOrcamentos).&End
        .AddResponse(201).Schema(TOrcamentos).&End
        .AddResponse(400).&End
      .&End
    .&End
    .Path('movimentos/orcamentos/{id}')
      .Tag('Or�amentos')
      .GET('Obter os dados de um or�amento espec�fico')
        .AddParamPath('id', 'Id').&End
        .AddResponse(200, 'Dados da or�amento').Schema(TOrcamentos).&End
        .AddResponse(404).&End
      .&End
      .PUT('Alterar os dados de um or�amento')
        .AddParamPath('id', 'C�digo').&End
        .AddParamBody('Dados do Or�amento').Required(True).Schema(TOrcamentosAltera).&End
        .AddResponse(201).Schema(TOrcamentos).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
      .DELETE('Excluir or�amento')
        .AddParamPath('id', 'Id').&End
        .AddResponse(204).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
    .&End
  .&End;
end.
