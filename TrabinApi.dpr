program TrabinApi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Compression,
  Horse.Jhonson,
  Horse.OctetStream,
  Horse.GBSwagger,
  Horse.BasicAuthentication,
  DataSet.Serialize,
  System.SysUtils,
  ctl.cadLocalidades in 'src\controllers\ctl.cadLocalidades.pas',
  ctl.cadAtividades in 'src\controllers\ctl.cadAtividades.pas',
  ctl.srvAutorizaNFe in 'src\controllers\ctl.srvAutorizaNFe.pas',
  dat.cadLocalidades in 'src\data\dat.cadLocalidades.pas',
  prv.dataModuleConexao in 'src\providers\prv.dataModuleConexao.pas' {ProviderDataModuleConexao: TDataModule},
  models.cadLocalidades in 'src\models\models.cadLocalidades.pas',
  models.cadAtividades in 'src\models\models.cadAtividades.pas',
  prv.srvAutorizaNFe in 'src\providers\prv.srvAutorizaNFe.pas' {ProviderServicoAutorizaNFe: TDataModule},
  ctl.movNFePendentes in 'src\controllers\ctl.movNFePendentes.pas',
  dat.movNFePendentes in 'src\data\dat.movNFePendentes.pas',
  ctl.movNFeAutorizadas in 'src\controllers\ctl.movNFeAutorizadas.pas',
  dat.movNFeAutorizadas in 'src\data\dat.movNFeAutorizadas.pas',
  ctl.arqNFeXML in 'src\controllers\ctl.arqNFeXML.pas',
  prv.arqNFeXML in 'src\providers\prv.arqNFeXML.pas' {ProviderArquivoNFeXML: TDataModule},
  ctl.arqNFePDF in 'src\controllers\ctl.arqNFePDF.pas',
  prv.arqNFePDF in 'src\providers\prv.arqNFePDF.pas' {ProviderArquivoNFePDF: TDataModule},
  ctl.seqUltimoPedidoVenda in 'src\controllers\ctl.seqUltimoPedidoVenda.pas',
  models.seqUltimoPedidoVenda in 'src\models\models.seqUltimoPedidoVenda.pas',
  dat.seqUltimoPedidoVenda in 'src\data\dat.seqUltimoPedidoVenda.pas',
  ctl.cadClientes in 'src\controllers\ctl.cadClientes.pas',
  dat.cadClientes in 'src\data\dat.cadClientes.pas',
  models.cadClientes in 'src\models\models.cadClientes.pas',
  ctl.cadCondicoes in 'src\controllers\ctl.cadCondicoes.pas',
  dat.cadCondicoes in 'src\data\dat.cadCondicoes.pas',
  models.cadCondicoes in 'src\models\models.cadCondicoes.pas',
  ctl.cadVendedores in 'src\controllers\ctl.cadVendedores.pas',
  models.cadVendedores in 'src\models\models.cadVendedores.pas',
  dat.cadVendedores in 'src\data\dat.cadVendedores.pas',
  ctl.cadCobrancas in 'src\controllers\ctl.cadCobrancas.pas',
  models.cadCobrancas in 'src\models\models.cadCobrancas.pas',
  dat.cadCobrancas in 'src\data\dat.cadCobrancas.pas',
  ctl.movNFePendentesItens in 'src\controllers\ctl.movNFePendentesItens.pas',
  ctl.cadProdutos in 'src\controllers\ctl.cadProdutos.pas',
  models.cadProdutos in 'src\models\models.cadProdutos.pas',
  dat.cadProdutos in 'src\data\dat.cadProdutos.pas',
  ctl.movNFePendentesParcelas in 'src\controllers\ctl.movNFePendentesParcelas.pas',
  models.movNFePendentesParcelas in 'src\models\models.movNFePendentesParcelas.pas',
  dat.movNFePendentesParcelas in 'src\data\dat.movNFePendentesParcelas.pas',
  ctl.srvCalculaParcelaNFe in 'src\controllers\ctl.srvCalculaParcelaNFe.pas',
  dat.srvCalculaParcelaNFe in 'src\data\dat.srvCalculaParcelaNFe.pas',
  ctl.srvCalculaImpostoNFeItem in 'src\controllers\ctl.srvCalculaImpostoNFeItem.pas',
  dat.srvCalculaImpostoNFeItem in 'src\data\dat.srvCalculaImpostoNFeItem.pas',
  ctl.movOrcamentos in 'src\controllers\ctl.movOrcamentos.pas',
  dat.movOrcamentos in 'src\data\dat.movOrcamentos.pas',
  models.movOrcamentos in 'src\models\models.movOrcamentos.pas',
  dat.movNFePendentesItens in 'src\data\dat.movNFePendentesItens.pas',
  dat.movOrcamentosItens in 'src\data\dat.movOrcamentosItens.pas',
  models.movOrcamentosItens in 'src\models\models.movOrcamentosItens.pas',
  ctl.movOrcamentosParcelas in 'src\controllers\ctl.movOrcamentosParcelas.pas',
  dat.movOrcamentosParcelas in 'src\data\dat.movOrcamentosParcelas.pas',
  models.movOrcamentosParcelas in 'src\models\models.movOrcamentosParcelas.pas',
  ctl.arqPedidoPDF in 'src\controllers\ctl.arqPedidoPDF.pas',
  prv.arqPedidoPDF in 'src\providers\prv.arqPedidoPDF.pas' {ProviderArquivoPedidoPDF},
  prv.fotoProduto in 'src\providers\prv.fotoProduto.pas' {ProviderFotoProduto},
  ctl.cadProdutosGrade in 'src\controllers\ctl.cadProdutosGrade.pas',
  dat.cadProdutosGrade in 'src\data\dat.cadProdutosGrade.pas',
  ctl.cadEmpresa in 'src\controllers\ctl.cadEmpresa.pas',
  dat.cadEmpresa in 'src\data\dat.cadEmpresa.pas',
  ctl.cadAliquotasICM in 'src\controllers\ctl.cadAliquotasICM.pas',
  dat.cadAliquotasICM in 'src\data\dat.cadAliquotasICM.pas',
  models.cadAliquotasICM in 'src\models\models.cadAliquotasICM.pas',
  ctl.cadCategorias in 'src\controllers\ctl.cadCategorias.pas',
  dat.cadCategorias in 'src\data\dat.cadCategorias.pas',
  dat.cadClassificacoes in 'src\data\dat.cadClassificacoes.pas',
  ctl.cadClassificacoes in 'src\controllers\ctl.cadClassificacoes.pas',
  ctl.cadClassificacoesFiscais in 'src\controllers\ctl.cadClassificacoesFiscais.pas',
  dat.cadClassificacoesFiscais in 'src\data\dat.cadClassificacoesFiscais.pas',
  ctl.cadCodigosFiscais in 'src\controllers\ctl.cadCodigosFiscais.pas',
  dat.cadCodigosFiscais in 'src\data\dat.cadCodigosFiscais.pas',
  ctl.cadCondicoesPrazos in 'src\controllers\ctl.cadCondicoesPrazos.pas',
  dat.cadCondicoesPrazos in 'src\data\dat.cadCondicoesPrazos.pas',
  ctl.cadFabricantes in 'src\controllers\ctl.cadFabricantes.pas',
  dat.cadFabricantes in 'src\data\dat.cadFabricantes.pas',
  ctl.cadFamilias in 'src\controllers\ctl.cadFamilias.pas',
  dat.cadFamilias in 'src\data\dat.cadFamilias.pas',
  ctl.cadFormulas in 'src\controllers\ctl.cadFormulas.pas',
  dat.cadFormulas in 'src\data\dat.cadFormulas.pas',
  ctl.cadGrades in 'src\controllers\ctl.cadGrades.pas',
  dat.cadGrades in 'src\data\dat.cadGrades.pas',
  ctl.cadGradesTitulos in 'src\controllers\ctl.cadGradesTitulos.pas',
  dat.cadGradesTitulos in 'src\data\dat.cadGradesTitulos.pas',
  ctl.cadNumerarios in 'src\controllers\ctl.cadNumerarios.pas',
  dat.cadNumerarios in 'src\data\dat.cadNumerarios.pas',
  ctl.cadOperacoes in 'src\controllers\ctl.cadOperacoes.pas',
  dat.cadOperacoes in 'src\data\dat.cadOperacoes.pas',
  ctl.cadOrigens in 'src\controllers\ctl.cadOrigens.pas',
  dat.cadOrigens in 'src\data\dat.cadOrigens.pas',
  ctl.cadPessoas in 'src\controllers\ctl.cadPessoas.pas',
  dat.cadPessoas in 'src\data\dat.cadPessoas.pas',
  ctl.cadPessoasContatos in 'src\controllers\ctl.cadPessoasContatos.pas',
  dat.cadPessoasContatos in 'src\data\dat.cadPessoasContatos.pas',
  ctl.cadPessoasCNAE in 'src\controllers\ctl.cadPessoasCNAE.pas',
  dat.cadPessoasCNAES in 'src\data\dat.cadPessoasCNAES.pas',
  ctl.cadPessoasConsultasMedicas in 'src\controllers\ctl.cadPessoasConsultasMedicas.pas',
  dat.cadPessoasConsultasMedicas in 'src\data\dat.cadPessoasConsultasMedicas.pas',
  ctl.cadPessoasContratosSociais in 'src\controllers\ctl.cadPessoasContratosSociais.pas',
  dat.cadPessoasContratosSociais in 'src\data\dat.cadPessoasContratosSociais.pas',
  ctl.cadPessoasDependentes in 'src\controllers\ctl.cadPessoasDependentes.pas',
  dat.cadPessoasDependentes in 'src\data\dat.cadPessoasDependentes.pas',
  ctl.cadPessoasDescFabricantes in 'src\controllers\ctl.cadPessoasDescFabricantes.pas',
  dat.cadPessoasDescFabricantes in 'src\data\dat.cadPessoasDescFabricantes.pas',
  dat.cadPessoasDevolucoes in 'src\data\dat.cadPessoasDevolucoes.pas',
  ctl.cadPessoasDevolucoes in 'src\controllers\ctl.cadPessoasDevolucoes.pas',
  ctl.cadPessoasEmpresas in 'src\controllers\ctl.cadPessoasEmpresas.pas',
  dat.cadPessoasEmpresas in 'src\data\dat.cadPessoasEmpresas.pas',
  ctl.cadPessoasFiadores in 'src\controllers\ctl.cadPessoasFiadores.pas',
  dat.cadPessoasFiadores in 'src\data\dat.cadPessoasFiadores.pas',
  ctl.cadPessoasFidelidades in 'src\controllers\ctl.cadPessoasFidelidades.pas',
  dat.cadPessoasFidelidades in 'src\data\dat.cadPessoasFidelidades.pas',
  ctl.cadPessoasFrequencias in 'src\controllers\ctl.cadPessoasFrequencias.pas',
  dat.cadPessoasFrequencias in 'src\data\dat.cadPessoasFrequencias.pas',
  ctl.cadPessoasGrupos in 'src\controllers\ctl.cadPessoasGrupos.pas',
  dat.cadPessoasGrupos in 'src\data\dat.cadPessoasGrupos.pas',
  ctl.cadPessoasItens in 'src\controllers\ctl.cadPessoasItens.pas',
  dat.cadPessoasItens in 'src\data\dat.cadPessoasItens.pas',
  ctl.cadPessoasProdutos in 'src\controllers\ctl.cadPessoasProdutos.pas',
  dat.cadPessoasProdutos in 'src\data\dat.cadPessoasProdutos.pas',
  ctl.cadPessoasRevendas in 'src\controllers\ctl.cadPessoasRevendas.pas',
  dat.cadPessoasRevendas in 'src\data\dat.cadPessoasRevendas.pas',
  ctl.cadPessoasSPC in 'src\controllers\ctl.cadPessoasSPC.pas',
  dat.cadPessoasSPC in 'src\data\dat.cadPessoasSPC.pas',
  ctl.cadPessoasSocios in 'src\controllers\ctl.cadPessoasSocios.pas',
  dat.cadPessoasSocios in 'src\data\dat.cadPessoasSocios.pas',
  ctl.cadPlanoContas in 'src\controllers\ctl.cadPlanoContas.pas',
  dat.cadPlanoContas in 'src\data\dat.cadPlanoContas.pas',
  ctl.cadPlanoContasReferencial in 'src\controllers\ctl.cadPlanoContasReferencial.pas',
  dat.cadPlanoContasReferencial in 'src\data\dat.cadPlanoContasReferencial.pas',
  ctl.cadPlanoEstoques in 'src\controllers\ctl.cadPlanoEstoques.pas',
  dat.cadPlanoEstoques in 'src\data\dat.cadPlanoEstoques.pas',
  dat.cadProdutosAlternativos in 'src\data\dat.cadProdutosAlternativos.pas',
  ctl.cadProdutosAlternativos in 'src\controllers\ctl.cadProdutosAlternativos.pas',
  ctl.cadProdutosBeneficios in 'src\controllers\ctl.cadProdutosBeneficios.pas',
  dat.cadProdutosBeneficios in 'src\data\dat.cadProdutosBeneficios.pas',
  ctl.cadProdutosCodigoBarras in 'src\controllers\ctl.cadProdutosCodigoBarras.pas',
  dat.cadProdutosCodigoBarras in 'src\data\dat.cadProdutosCodigoBarras.pas',
  ctl.cadProdutosCombustiveis in 'src\controllers\ctl.cadProdutosCombustiveis.pas',
  dat.cadProdutosCombustiveis in 'src\data\dat.cadProdutosCombustiveis.pas',
  ctl.cadProdutosComplementares in 'src\controllers\ctl.cadProdutosComplementares.pas',
  dat.cadProdutosComplementares in 'src\data\dat.cadProdutosComplementares.pas',
  ctl.cadProdutosComponentes in 'src\controllers\ctl.cadProdutosComponentes.pas',
  dat.cadProdutosComponentes in 'src\data\dat.cadProdutosComponentes.pas',
  ctl.cadProdutosCores in 'src\controllers\ctl.cadProdutosCores.pas',
  dat.cadProdutosCores in 'src\data\dat.cadProdutosCores.pas',
  ctl.cadProdutosDescontos in 'src\controllers\ctl.cadProdutosDescontos.pas',
  dat.cadProdutosDescontos in 'src\data\dat.cadProdutosDescontos.pas',
  ctl.cadProdutosDetalhes in 'src\controllers\ctl.cadProdutosDetalhes.pas',
  dat.cadProdutosDetalhes in 'src\data\dat.cadProdutosDetalhes.pas',
  ctl.cadProdutosElementosControles in 'src\controllers\ctl.cadProdutosElementosControles.pas',
  dat.cadProdutosElementosControles in 'src\data\dat.cadProdutosElementosControles.pas',
  ctl.cadProdutosEnviaSites in 'src\controllers\ctl.cadProdutosEnviaSites.pas',
  dat.cadProdutosEnviaSites in 'src\data\dat.cadProdutosEnviaSites.pas',
  ctl.cadProdutosEstoques in 'src\controllers\ctl.cadProdutosEstoques.pas',
  dat.cadProdutosEstoques in 'src\data\dat.cadProdutosEstoques.pas',
  ctl.cadProdutosExcedentes in 'src\controllers\ctl.cadProdutosExcedentes.pas',
  dat.cadProdutosExcedentes in 'src\data\dat.cadProdutosExcedentes.pas',
  ctl.cadProdutosExpedicoes in 'src\controllers\ctl.cadProdutosExpedicoes.pas',
  dat.cadProdutosExpedicoes in 'src\data\dat.cadProdutosExpedicoes.pas',
  ctl.cadProdutosFornecedores in 'src\controllers\ctl.cadProdutosFornecedores.pas',
  dat.cadProdutosFornecedores in 'src\data\dat.cadProdutosFornecedores.pas',
  ctl.cadProdutosPrecos in 'src\controllers\ctl.cadProdutosPrecos.pas',
  dat.cadProdutosPrecos in 'src\data\dat.cadProdutosPrecos.pas',
  ctl.cadProdutosRegraDescontos in 'src\controllers\ctl.cadProdutosRegraDescontos.pas',
  dat.cadProdutosRegraDescontos in 'src\data\dat.cadProdutosRegraDescontos.pas',
  ctl.cadProdutosRevendas in 'src\controllers\ctl.cadProdutosRevendas.pas',
  dat.cadProdutosRevendas in 'src\data\dat.cadProdutosRevendas.pas',
  ctl.cadSetores in 'src\controllers\ctl.cadSetores.pas',
  dat.cadSetores in 'src\data\dat.cadSetores.pas',
  ctl.cadSituacoesTributarias in 'src\controllers\ctl.cadSituacoesTributarias.pas',
  dat.cadSituacoesTributarias in 'src\data\dat.cadSituacoesTributarias.pas',
  ctl.cadTabelasCNAE in 'src\controllers\ctl.cadTabelasCNAE.pas',
  dat.cadTabelasCNAE in 'src\data\dat.cadTabelasCNAE.pas',
  ctl.cadTabelasCores in 'src\controllers\ctl.cadTabelasCores.pas',
  dat.cadTabelasCores in 'src\data\dat.cadTabelasCores.pas',
  ctl.cadTabelasDescontos in 'src\controllers\ctl.cadTabelasDescontos.pas',
  dat.cadTabelasDescontos in 'src\data\dat.cadTabelasDescontos.pas',
  ctl.cadTabelasDescontosFaixas in 'src\controllers\ctl.cadTabelasDescontosFaixas.pas',
  dat.cadTabelasDescontosFaixas in 'src\data\dat.cadTabelasDescontosFaixas.pas',
  ctl.cadTabelasGrupos in 'src\controllers\ctl.cadTabelasGrupos.pas',
  dat.cadTabelasGrupos in 'src\data\dat.cadTabelasGrupos.pas',
  ctl.cadTabelasPrecos in 'src\controllers\ctl.cadTabelasPrecos.pas',
  dat.cadTabelasPrecos in 'src\data\dat.cadTabelasPrecos.pas',
  ctl.movOrcamentosCFOPS in 'src\controllers\ctl.movOrcamentosCFOPS.pas',
  dat.movOrcamentosCFOPS in 'src\data\dat.movOrcamentosCFOPS.pas',
  ctl.cadPessoasHistoricos in 'src\controllers\ctl.cadPessoasHistoricos.pas',
  ctl.cadPessoasObservacoes in 'src\controllers\ctl.cadPessoasObservacoes.pas',
  ctl.cadPessoasParcelas in 'src\controllers\ctl.cadPessoasParcelas.pas',
  dat.cadPessoasObservacoes in 'src\data\dat.cadPessoasObservacoes.pas',
  dat.cadPessoasParcelas in 'src\data\dat.cadPessoasParcelas.pas',
  dat.cadPessoasHistoricos in 'src\data\dat.cadPessoasHistoricos.pas',
  ctl.movNotasFiscais in 'src\controllers\ctl.movNotasFiscais.pas',
  dat.movNotasFiscais in 'src\data\dat.movNotasFiscais.pas',
  ctl.movNotasFiscaisCFOPS in 'src\controllers\ctl.movNotasFiscaisCFOPS.pas',
  dat.movNotasFiscaisCFOPS in 'src\data\dat.movNotasFiscaisCFOPS.pas',
  ctl.movOrcamentosItens in 'src\controllers\ctl.movOrcamentosItens.pas',
  ctl.movNotasFiscaisItens in 'src\controllers\ctl.movNotasFiscaisItens.pas',
  dat.movNotasFiscaisItens in 'src\data\dat.movNotasFiscaisItens.pas',
  ctl.movNotasFiscaisParcelas in 'src\controllers\ctl.movNotasFiscaisParcelas.pas',
  dat.movNotasFiscaisParcelas in 'src\data\dat.movNotasFiscaisParcelas.pas',
  ctl.cadValidacoes in 'src\controllers\ctl.cadValidacoes.pas',
  dat.cadValidacoes in 'src\data\dat.cadValidacoes.pas',
  ctl.srvDFe in 'src\controllers\ctl.srvDFe.pas',
  ctl.cadAgendas in 'src\controllers\ctl.cadAgendas.pas',
  ctl.srvDFeConsultaStatusWebService in 'src\controllers\ctl.srvDFeConsultaStatusWebService.pas',
  ctl.srvDFeArquivamento in 'src\controllers\ctl.srvDFeArquivamento.pas',
  ctl.movDFeUltNSU in 'src\controllers\ctl.movDFeUltNSU.pas',
  ctl.movDFeConsultados in 'src\controllers\ctl.movDFeConsultados.pas',
  ctl.srvDFeConsultaUltNSU in 'src\controllers\ctl.srvDFeConsultaUltNSU.pas',
  ctl.movDFeArquivados in 'src\controllers\ctl.movDFeArquivados.pas',
  ctl.movDFeCancelados in 'src\controllers\ctl.movDFeCancelados.pas',
  ctl.movDFeConfirmados in 'src\controllers\ctl.movDFeConfirmados.pas',
  ctl.movDFeCiencias in 'src\controllers\ctl.movDFeCiencias.pas',
  ctl.srvDFeNaoRealizada in 'src\controllers\ctl.srvDFeNaoRealizada.pas',
  ctl.srvDFeDesconhecimento in 'src\controllers\ctl.srvDFeDesconhecimento.pas',
  ctl.srvDFeConfirmacao in 'src\controllers\ctl.srvDFeConfirmacao.pas',
  ctl.srvDFeCiencia in 'src\controllers\ctl.srvDFeCiencia.pas',
  dat.cadAgendas in 'src\data\dat.cadAgendas.pas',
  dat.cadAtividades in 'src\data\dat.cadAtividades.pas',
  dat.movDFeConsultados in 'src\data\dat.movDFeConsultados.pas',
  dat.movDFeUltNSU in 'src\data\dat.movDFeUltNSU.pas',
  dat.movDFeArquivados in 'src\data\dat.movDFeArquivados.pas',
  dat.movDFeCancelados in 'src\data\dat.movDFeCancelados.pas',
  dat.movDFeConfirmados in 'src\data\dat.movDFeConfirmados.pas',
  dat.movDFeCiencias in 'src\data\dat.movDFeCiencias.pas',
  ctl.arqDFeArquivosXML in 'src\controllers\ctl.arqDFeArquivosXML.pas',
  dat.arqDFeArquivosXML in 'src\data\dat.arqDFeArquivosXML.pas',
  ctl.arqDFeArquivoIni in 'src\controllers\ctl.arqDFeArquivoIni.pas',
  ctl.srvDFeTransfereXML in 'src\controllers\ctl.srvDFeTransfereXML.pas',
  ctl.movDFeForaPrazo in 'src\controllers\ctl.movDFeForaPrazo.pas',
  dat.movDFeForaPrazo in 'src\data\dat.movDFeForaPrazo.pas';

begin
  THorse.Use(Compression());
  THorse.Use(Jhonson);
  THorse.Use(HorseSwagger);
  THorse.Use(OctetStream);
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      // Here inside you can access your database and validate if username and password are valid
      Result := AUsername.Equals('user') and APassword.Equals('password');
    end));


  ctl.cadAliquotasICM.Registry;
  ctl.cadAtividades.Registry;
  ctl.cadLocalidades.Registry;
  ctl.cadCategorias.Registry;
  ctl.cadClassificacoes.Registry;
  ctl.cadClassificacoesFiscais.Registry;
  ctl.cadClientes.Registry;
  ctl.cadCodigosFiscais.Registry;
  ctl.cadEmpresa.Registry;
  ctl.cadCondicoes.Registry;
  ctl.cadCondicoesPrazos.Registry;
  ctl.cadFabricantes.Registry;
  ctl.cadFamilias.Registry;
  ctl.cadFormulas.Registry;
  ctl.cadGrades.Registry;
  ctl.cadGradesTitulos.Registry;
  ctl.cadNumerarios.Registry;
  ctl.cadVendedores.Registry;
  ctl.cadCobrancas.Registry;
  ctl.cadOperacoes.Registry;
  ctl.cadOrigens.Registry;
  ctl.cadPessoas.Registry;
  ctl.cadPessoasConsultasMedicas.Registry;
  ctl.cadPessoasContatos.Registry;
  ctl.cadPessoasContratosSociais.Registry;
  ctl.cadPessoasCNAE.Registry;
  ctl.cadPessoasDependentes.Registry;
  ctl.cadPessoasEmpresas.Registry;
  ctl.cadPessoasFiadores.Registry;
  ctl.cadPessoasFidelidades.Registry;
  ctl.cadPessoasObservacoes.Registry;
  ctl.cadPessoasDescFabricantes.Registry;
  ctl.cadPessoasDevolucoes.Registry;
  ctl.cadPessoasFrequencias.Registry;
  ctl.cadPessoasGrupos.Registry;
  ctl.cadPessoasHistoricos.Registry;
  ctl.cadPessoasItens.Registry;
  ctl.cadPessoasObservacoes.Registry;
  ctl.cadPessoasParcelas.Registry;
  ctl.cadPessoasProdutos.Registry;
  ctl.cadPessoasRevendas.Registry;
  ctl.cadPessoasSPC.Registry;
  ctl.cadPessoasSocios.Registry;
  ctl.cadPlanoContas.Registry;
  ctl.cadPlanoContasReferencial.Registry;
  ctl.cadPlanoEstoques.Registry;
  ctl.cadProdutos.Registry;
  ctl.cadProdutosGrade.Registry;
  ctl.cadProdutosAlternativos.Registry;
  ctl.cadProdutosBeneficios.Registry;
  ctl.cadProdutosCodigoBarras.Registry;
  ctl.cadProdutosCombustiveis.Registry;
  ctl.cadProdutosComplementares.Registry;
  ctl.cadProdutosComponentes.Registry;
  ctl.cadProdutosCores.Registry;
  ctl.cadProdutosDescontos.Registry;
  ctl.cadProdutosDetalhes.Registry;
  ctl.cadProdutosElementosControles.Registry;
  ctl.cadProdutosEnviaSites.Registry;
  ctl.cadProdutosEstoques.Registry;
  ctl.cadProdutosExcedentes.Registry;
  ctl.cadProdutosExpedicoes.Registry;
  ctl.cadProdutosFornecedores.Registry;
  ctl.cadProdutosPrecos.Registry;
  ctl.cadProdutosRegraDescontos.Registry;
  ctl.cadProdutosRevendas.Registry;
  ctl.cadSetores.Registry;
  ctl.cadSituacoesTributarias.Registry;
  ctl.cadTabelasCNAE.Registry;
  ctl.cadTabelasCores.Registry;
  ctl.cadTabelasDescontos.Registry;
  ctl.cadTabelasDescontosFaixas.Registry;
  ctl.cadTabelasGrupos.Registry;
  ctl.cadTabelasPrecos.Registry;
  ctl.cadValidacoes.Registry;
  ctl.cadAgendas.Registry;

  ctl.srvAutorizaNFe.Registry;
  ctl.srvCalculaParcelaNFe.Registry;
  ctl.srvCalculaImpostoNFeItem.Registry;
  ctl.srvDFeConsultaStatusWebService.Registry;
  ctl.srvDFeArquivamento.Registry;
  ctl.srvDFeConsultaUltNSU.Registry;
  ctl.srvDFeNaoRealizada.Registry;
  ctl.srvDFeDesconhecimento.Registry;
  ctl.srvDFeConfirmacao.Registry;
  ctl.srvDFeCiencia.Registry;
  ctl.srvDFeTransfereXML.registry;
//  ctl.srvDFe.registry;

  ctl.movNFePendentes.Registry;
  ctl.movNFePendentesItens.Registry;
  ctl.movNFePendentesParcelas.Registry;
  ctl.movNFeAutorizadas.Registry;
  ctl.movNotasFiscais.Registry;
  ctl.movNotasFiscaisCFOPS.Registry;
  ctl.movNotasFiscaisItens.Registry;
  ctl.movNotasFiscaisParcelas.Registry;
  ctl.movOrcamentos.Registry;
  ctl.movOrcamentosItens.Registry;
  ctl.movOrcamentosParcelas.Registry;
  ctl.movOrcamentosCFOPS.Registry;
  ctl.movDFeConsultados.Registry;
  ctl.movDFeCiencias.Registry;
  ctl.movDFeConfirmados.Registry;
  ctl.movDFeCancelados.Registry;
  ctl.movDFeArquivados.Registry;
  ctl.movDFeForaPrazo.Registry;
  ctl.movDFeUltNSU.Registry;


  ctl.arqNFeXML.Registry;
  ctl.arqNFePDF.Registry;
  ctl.arqPedidoPDF.Registry;
  ctl.seqUltimoPedidoVenda.Registry;
  ctl.arqDFeArquivosXML.Registry;
  ctl.arqDFeArquivoIni.Registry;

  Swagger
    .Info
      .Title('Trabin API')
      .Description('Documentação da minha API')
      .Contact
        .Name('Marcelo T Peraça')
        .Email('marcelo@trabin.com.br')
        .URL('http://www.trabin.com.br')
      .&End
    .&End
  .&End;


  THorse.Listen(9000, procedure (Horse: THorse)
   begin
     writeln(format('Servidor rodando na porta %d',[Horse.Port]));
   end
   );
end.
