unit ctl.movOrcamentosCFOPS;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses prv.dataModuleConexao, dat.movOrcamentosCFOPS;


procedure ListaTodosCFOPS(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wlista: TJSONArray;
    wval: string;
    wret,werro: TJSONObject;
    widempresa,widorcamento: integer;
    wconexao: TProviderDataModuleConexao;
begin
  try
    widorcamento  := Req.Params['idorcamento'].ToInteger; // recupera o id da Pessoa
    wconexao      := TProviderDataModuleConexao.Create(nil);
    widempresa    := wconexao.FIdEmpresa; //id empresa do arquivo TrabinApi.ini
    wlista := TJSONArray.Create;
    wlista := dat.movOrcamentosCFOPS.RetornaListaCFOPS(Req.Query,widorcamento);
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


procedure Registry;
begin
// M�todo Get
  THorse.Get('/trabinapi/movimentos/orcamentos/:idorcamento/cfops',ListaTodosCFOPS);

// M�todo Post
//  THorse.Post('/trabinapi/cadastros/pessoas/:idpessoa/contatos',CriaContato);

  // M�todo Put
//  THorse.Put('/trabinapi/cadastros/pessoas/:idpessoa/contatos/:id',AlteraContato);

// M�todo Delete
//  THorse.Delete('/trabinapi/cadastros/pessoas/:idpessoa/contatos/:id',ExcluiContato);
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
