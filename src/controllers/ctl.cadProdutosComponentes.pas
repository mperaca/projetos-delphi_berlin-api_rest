unit ctl.cadProdutosComponentes;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses prv.dataModuleConexao, dat.cadProdutosComponentes;


procedure ListaTodosComponentes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wlista: TJSONArray;
    wval: string;
    wret,werro: TJSONObject;
    widempresa,widproduto: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    widproduto    := Req.Params['idproduto'].ToInteger; // recupera o id da Pessoa
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini
    wlista := TJSONArray.Create;
    wlista := dat.cadProdutosComponentes.RetornaListaComponentes(Req.Query,widproduto);
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

procedure CriaComponente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wComponente,wnewComponente,wresp,werro: TJSONObject;
    wval: string;
    widempresa,widproduto: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    widproduto     := Req.Params['idproduto'].ToInteger; // recupera o id da Pessoa
    wComponente    := TJSONObject.Create;
    wnewComponente := TJSONObject.Create;
    wresp          := TJSONObject.Create;
    wComponente    := Req.Body<TJSONObject>;
    wconexao       := TProviderDataModuleConexao.Create(nil);
    widempresa     := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini

    if widempresa=0 then
       begin
         wresp.AddPair('status','405');
         wresp.AddPair('description','idempresa n?o definido');
         wresp.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wresp).Status(405);
       end
    else if dat.cadProdutosComponentes.VerificaRequisicao(wComponente) then
       begin
         wnewComponente := dat.cadProdutosComponentes.IncluiComponente(wComponente,widproduto);
         if wnewComponente.TryGetValue('status',wval) then
            Res.Send<TJSONObject>(wnewComponente).Status(400)
         else
            Res.Send<TJSONObject>(wnewComponente).Status(201);
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

procedure AlteraComponente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wComponente,wnewComponente,wresp,werro: TJSONObject;
    wid,widproduto: integer;
    wval: string;
begin
  try
    wnewComponente    := TJSONObject.Create;
    wComponente       := TJSONObject.Create;
    wresp             := TJSONObject.Create;
    widproduto        := Req.Params['idproduto'].ToInteger; // recupera o id da Pessoa
    wid               := Req.Params['id'].ToInteger; // recupera o id do Contato
    wComponente       := Req.Body<TJSONObject>;
    wnewComponente    := dat.cadProdutosComponentes.AlteraComponente(wid,wComponente);
    if wnewComponente.TryGetValue('idprodutomestre',wval) then
       begin
         wnewComponente.AddPair('datetime',formatdatetime('yyyy-mm-dd hh:nn:ss',now));
         Res.Send<TJSONObject>(wnewComponente).Status(200);
       end
    else
       begin
         wresp.AddPair('status','400');
         wresp.AddPair('description','Produto Componente n?o encontrado');
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

procedure ExcluiComponente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wid,widproduto: integer;
    wret,werro: TJSONObject;
begin
  try
    wid        := Req.Params['id'].ToInteger; // recupera o id do Contato
    widproduto := Req.Params['idproduto'].ToInteger; // recupera o id da Pessoa
    if wid>0 then
       begin
         wret := TJSONObject.Create;
         wret := dat.cadProdutosComponentes.ApagaComponente(wid);
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

procedure RetornaComponente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wComponente,werro: TJSONObject;
    wid: integer;
    wval: string;
begin
  try
    wid          := Req.Params['id'].ToInteger; // recupera o id do Contato
    wComponente  := TJSONObject.Create;
    wComponente  := Req.Body<TJSONObject>;
    wComponente  := dat.cadProdutosComponentes.RetornaComponente(wid);
    if wComponente.TryGetValue('status',wval) then
       Res.Send<TJSONObject>(wComponente).Status(400)
    else
       Res.Send<TJSONObject>(wComponente).Status(200);
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
// M?todo Get
  THorse.Get('/trabinapi/cadastros/produtos/:idproduto/componentes',ListaTodosComponentes);
  THorse.Get('/trabinapi/cadastros/produtos/:idproduto/componentes/:id',RetornaComponente);

// M?todo Post
  THorse.Post('/trabinapi/cadastros/produtos/:idproduto/componentes',CriaComponente);

  // M?todo Put
  THorse.Put('/trabinapi/cadastros/produtos/:idproduto/componentes/:id',AlteraComponente);

// M?todo Delete
  THorse.Delete('/trabinapi/cadastros/produtos/:idproduto/componentes/:id',ExcluiComponente);
end;

initialization

// defini??o da documenta??o
  Swagger
    .BasePath('trabinapi')
    .Path('cadastros/categorias')
      .Tag('AliquotasICM')
      .GET('Listar Categorias')
//        .AddResponse(200, 'Lista de Al?quotas').Schema(TAliquotas).IsArray(True).&End
      .&End
      .POST('Criar uma nova Categoria')
//        .AddParamBody('Dados da Al?quota').Required(True).Schema(TAliquotas).&End
        .AddParamQuery('codigo', 'C?digo').&End
        .AddParamQuery('descricao', 'Descri??o').&End
        .AddParamQuery('percentual', 'Percentual').&End
        .AddParamQuery('percentualsc', 'Percentual SC').&End
        .AddParamQuery('percentualsp', 'Percentual SP').&End
        .AddParamQuery('basecalculo', 'Base de C?lculo').&End
        .AddParamQuery('somaoutros', 'Soma Outros').&End
        .AddParamQuery('somaisentos', 'Soma Isentos').&End
//        .AddResponse(201).Schema(TAliquotas).&End
        .AddResponse(400).&End
      .&End
    .&End
    .Path('cadastros/categorias/{id}')
      .Tag('Categorias')
      .GET('Obter os dados de uma Categoria espec?fica')
        .AddParamPath('id', 'Id').&End
//        .AddResponse(200, 'Dados da Al?quota').Schema(TAliquotas).&End
        .AddResponse(404).&End
      .&End
      .PUT('Alterar os dados de uma Categoria espec?fica')
        .AddParamPath('id', 'Id').&End
        .AddParamQuery('codigo', 'C?digo').&End
        .AddParamQuery('descricao', 'Descri??o').&End
        .AddParamQuery('percentual', 'Percentual').&End
        .AddParamQuery('percentualsc', 'Percentual SC').&End
        .AddParamQuery('percentualsp', 'Percentual SP').&End
        .AddParamQuery('basecalculo', 'Base de C?lculo').&End
        .AddParamQuery('somaoutros', 'Soma Outros').&End
        .AddParamQuery('somaisentos', 'Soma Isentos').&End
//        .AddParamBody('Dados da Al?quota').Required(True).Schema(TAliquotas).&End
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
