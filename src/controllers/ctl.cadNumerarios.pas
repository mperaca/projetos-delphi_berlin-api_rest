unit ctl.cadNumerarios;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses prv.dataModuleConexao, dat.cadNumerarios;


procedure ListaTodosNumerarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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
    wlista := dat.cadNumerarios.RetornaListaNumerarios(Req.Query);
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

procedure CriaNumerario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wNumerario,wnewNumerario,wresp,werro: TJSONObject;
    wval: string;
    widempresa: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    wNumerario    := TJSONObject.Create;
    wnewNumerario := TJSONObject.Create;
    wresp         := TJSONObject.Create;
    wNumerario    := Req.Body<TJSONObject>;
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini

    if widempresa=0 then
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','idempresa n�o definido');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end
    else if dat.cadNumerarios.VerificaRequisicao(wNumerario) then
       begin
         wnewNumerario := dat.cadNumerarios.IncluiNumerario(wNumerario);
         if wnewNumerario.TryGetValue('status',wval) then
            Res.Send<TJSONObject>(wnewNumerario).Status(400)
         else
            Res.Send<TJSONObject>(wnewNumerario).Status(201);
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

procedure AlteraNumerario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wNumerario,wnewNumerario,wresp,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wnewNumerario := TJSONObject.Create;
    wNumerario    := TJSONObject.Create;
    wresp         := TJSONObject.Create;
    wid           := Req.Params['id'].ToInteger; // recupera o id do Numer�rio
    wNumerario    := Req.Body<TJSONObject>;
    wnewNumerario := dat.cadNumerarios.AlteraNumerario(wid,wNumerario);
    if wnewNumerario.TryGetValue('descricao',wval) then
       begin
         wnewNumerario.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wnewNumerario).Status(200);
       end
    else
       begin
         wresp.AddPair('status','400');
         wresp.AddPair('description','Numer�rio n�o encontrado');
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

procedure ExcluiNumerario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wid: integer;
    wret,werro: TJSONObject;
begin
  try
    wid := Req.Params['id'].ToInteger; // recupera o id do Numer�rio
    if wid>0 then
       begin
         wret := TJSONObject.Create;
         wret := dat.cadNumerarios.ApagaNumerario(wid);
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

procedure RetornaNumerario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wNumerario,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid      := Req.Params['id'].ToInteger; // recupera o id do numer�rio
    wNumerario := TJSONObject.Create;
    wNumerario := Req.Body<TJSONObject>;
    wNumerario := dat.cadNumerarios.RetornaNumerario(wid);
    if wNumerario.TryGetValue('status',wval) then
       Res.Send<TJSONObject>(wNumerario).Status(400)
    else
       Res.Send<TJSONObject>(wNumerario).Status(200);
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
  THorse.Get('/trabinapi/cadastros/numerarios',ListaTodosNumerarios);
  THorse.Get('/trabinapi/cadastros/numerarios/:id',RetornaNumerario);

// M�todo Post
  THorse.Post('/trabinapi/cadastros/numerarios',CriaNumerario);

  // M�todo Put
  THorse.Put('/trabinapi/cadastros/numerarios/:id',AlteraNumerario);

// M�todo Delete
  THorse.Delete('/trabinapi/cadastros/numerarios/:id',ExcluiNumerario);
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
