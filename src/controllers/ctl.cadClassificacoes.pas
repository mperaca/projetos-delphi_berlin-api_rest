unit ctl.cadClassificacoes;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses prv.dataModuleConexao, dat.cadClassificacoes;


procedure ListaTodasClassificacoes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wlista: TJSONArray;
    wval: string;
    wret,werro: TJSONObject;
    widempresa: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini
    wlista := TJSONArray.Create;
    wlista := dat.cadClassificacoes.RetornaListaClassificacoes(Req.Query,widempresa);
    wret   := wlista.Get(0) as TJSONObject;
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

procedure CriaClassificacao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wClassificacao,wnewClassificacao,wresp,werro: TJSONObject;
    wval: string;
    widempresa: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wClassificacao    := TJSONObject.Create;
    wnewClassificacao := TJSONObject.Create;
    wresp             := TJSONObject.Create;
    wClassificacao    := Req.Body<TJSONObject>;
    wconexao          := TProviderDataModuleConexao.Create(nil);
    widempresa        := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini

    if widempresa=0 then
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','idempresa n�o definido');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end
    else if dat.cadClassificacoes.VerificaRequisicao(wClassificacao) then
       begin
         wnewClassificacao := dat.cadClassificacoes.IncluiClassificacao(wClassificacao);
         if wnewClassificacao.TryGetValue('status',wval) then
            Res.Send<TJSONObject>(wnewClassificacao).Status(400)
         else
            Res.Send<TJSONObject>(wnewClassificacao).Status(201);
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

procedure ExcluiClassificacao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wid: integer;
    wret,werro: TJSONObject;
begin
  try
    wid := Req.Params['id'].ToInteger; // recupera o id da Classifica��o
    if wid>0 then
       begin
         wret := TJSONObject.Create;
         wret := dat.cadClassificacoes.ApagaClassificacao(wid);
         if wret.GetValue('status').Value='200' then
            Res.Send<TJSONObject>(wret).Status(200)
         else
            Res.Send<TJSONObject>(wret).Status(400);
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

procedure RetornaClassificacao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wClassificacao,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid            := Req.Params['id'].ToInteger; // recupera o id da Classifica��o
    wClassificacao := TJSONObject.Create;
    wClassificacao := Req.Body<TJSONObject>;
    wClassificacao := dat.cadClassificacoes.RetornaClassificacao(wid);
    if wClassificacao.TryGetValue('status',wval) then
       Res.Send<TJSONObject>(wClassificacao).Status(400)
    else
       Res.Send<TJSONObject>(wClassificacao).Status(200);
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

procedure AlteraClassificacao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wClassificacao,wnewClassificacao,wresp,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wnewClassificacao := TJSONObject.Create;
    wClassificacao    := TJSONObject.Create;
    wresp             := TJSONObject.Create;
    wid               := Req.Params['id'].ToInteger; // recupera o id da Classifica��o
    wClassificacao    := Req.Body<TJSONObject>;
    wnewClassificacao := dat.cadClassificacoes.AlteraClassificacao(wid,wClassificacao);
    if wnewClassificacao.TryGetValue('descricao',wval) then
       begin
         wnewClassificacao.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wnewClassificacao).Status(200);
       end
    else
       begin
         wresp.AddPair('status','400');
         wresp.AddPair('description','Classifica��o n�o encontrada');
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

procedure RetornaTotalClassificacoes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wtotal,werro: TJSONObject;
    wval: string;
begin
  try
    wtotal := TJSONObject.Create;
    wtotal := dat.cadClassificacoes.RetornaTotalClassificacoes(Req.Query);
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
  THorse.Get('/trabinapi/cadastros/classificacoes',ListaTodasClassificacoes);
  THorse.Get('/trabinapi/cadastros/classificacoes/:id',RetornaClassificacao);
  THorse.Get('/trabinapi/cadastros/classificacoes/total',RetornaTotalClassificacoes);

// M�todo Post
  THorse.Post('/trabinapi/cadastros/classificacoes',CriaClassificacao);

  // M�todo Put
  THorse.Put('/trabinapi/cadastros/classificacoes/:id',AlteraClassificacao);

  // M�todo Delete
  THorse.Delete('/trabinapi/cadastros/classificacoes/:id',ExcluiClassificacao);
end;

initialization

// defini��o da documenta��o
  Swagger
    .BasePath('trabinapi')
    .Path('cadastros/categorias')
      .Tag('AliquotasICM')
      .GET('Listar Categorias')
//        .AddResponse(200, 'Lista de Al�quotas').Schema(TAliquotas).IsArray(True).&End
      .&End
      .POST('Criar uma nova Categoria')
//        .AddParamBody('Dados da Al�quota').Required(True).Schema(TAliquotas).&End
        .AddParamQuery('codigo', 'C�digo').&End
        .AddParamQuery('descricao', 'Descri��o').&End
        .AddParamQuery('percentual', 'Percentual').&End
        .AddParamQuery('percentualsc', 'Percentual SC').&End
        .AddParamQuery('percentualsp', 'Percentual SP').&End
        .AddParamQuery('basecalculo', 'Base de C�lculo').&End
        .AddParamQuery('somaoutros', 'Soma Outros').&End
        .AddParamQuery('somaisentos', 'Soma Isentos').&End
//        .AddResponse(201).Schema(TAliquotas).&End
        .AddResponse(400).&End
      .&End
    .&End
    .Path('cadastros/categorias/{id}')
      .Tag('Categorias')
      .GET('Obter os dados de uma Categoria espec�fica')
        .AddParamPath('id', 'Id').&End
//        .AddResponse(200, 'Dados da Al�quota').Schema(TAliquotas).&End
        .AddResponse(404).&End
      .&End
      .PUT('Alterar os dados de uma Categoria espec�fica')
        .AddParamPath('id', 'Id').&End
        .AddParamQuery('codigo', 'C�digo').&End
        .AddParamQuery('descricao', 'Descri��o').&End
        .AddParamQuery('percentual', 'Percentual').&End
        .AddParamQuery('percentualsc', 'Percentual SC').&End
        .AddParamQuery('percentualsp', 'Percentual SP').&End
        .AddParamQuery('basecalculo', 'Base de C�lculo').&End
        .AddParamQuery('somaoutros', 'Soma Outros').&End
        .AddParamQuery('somaisentos', 'Soma Isentos').&End
//        .AddParamBody('Dados da Al�quota').Required(True).Schema(TAliquotas).&End
        .AddResponse(200).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
      .DELETE('Excluir Categoria')
        .AddParamPath('id', 'Id').&End
        .AddResponse(204).&End
        .AddResponse(400).&End
        .AddResponse(404).&End
      .&End
    .&End
  .&End;

end.
