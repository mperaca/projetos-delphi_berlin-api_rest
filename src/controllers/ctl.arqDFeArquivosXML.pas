unit ctl.arqDFeArquivosXML;

interface

uses Horse, Horse.GBSwagger, System.UITypes,
     System.SysUtils, Vcl.Dialogs, System.JSON, DataSet.Serialize, Data.DB;

procedure Registry;

implementation

uses dat.arqDFeArquivosXML;


procedure ListaTodosArquivosXML(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var wlista: TJSONArray;
    wval: string;
    wret,werro: TJSONObject;
begin
  try
    wlista := TJSONArray.Create;
    wlista := dat.arqDFeArquivosXML.RetornaListaArquivosXML(Req.Query);
    wret   := wlista.Items[0] as TJSONObject;
    if wret.TryGetValue('status',wval) then
       Res.Send<TJSONArray>(wlista).Status(500)
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
  THorse.Get('/trabinapi/arquivos/dfe/arquivosxml',ListaTodosArquivosXML);
end;

initialization

// defini��o da documenta��o
  Swagger
    .BasePath('trabinapi')
    .Path('movimentos/nfe_autorizadas')
      .Tag('NFe autorizadas')
      .GET('Listar nfe autorizdas')
        .AddParamQuery('id', 'C�digo').&End
        .AddParamQuery('nome', 'Nome').&End
        .AddParamQuery('uf', 'UF').&End
        .AddParamQuery('regiao', 'Regi�o').&End
        .AddParamQuery('codibge', 'C�digo IBGE').&End
//        .AddResponse(200, 'Lista de localidades').Schema(TLocalidades).IsArray(True).&End
      .&End
    .&End
    .Path('movimentos/nfe_autorizadas/{id}')
      .Tag('NFe pendentes')
      .GET('Obter os dados de uma nfe espec�fica')
        .AddParamPath('id', 'C�digo').&End
//        .AddResponse(200, 'Dados da localidade').Schema(TLocalidades).&End
        .AddResponse(404).&End
      .&End
    .&End
  .&End;

end.
