import 'i_language.dart';

class LanguagePT extends ILanguage {

  static const name = 'Português';
  static const locale = 'pt_BR';

  //region addAlbum

  @override
  String get adicionar => 'Adicionar';

  @override
  String get bloquear => 'Bloquear';

  @override
  String get incluir => 'Incluir';

  @override
  String get currentBooru => 'Booru atual';

  @override
  String get filtro => 'Filtro';

  @override
  String get nome => 'Nome';

  @override
  String get pesquisarTags => 'Pesquisar Tags';

  @override
  String get salvar => 'Salvar';

  @override
  String get titleAddAlbum => 'Novo Album';
  @override
  String get titleEditAlbum => 'Editar Album';

  @override
  String get usuarioDev => 'Usuário DeviantArt';

  @override
  String get clickParaAlterar => 'Clique para alterar';

  @override
  String get clickParaVerPost => 'Clique na tag para ver post';

  @override
  String get deleteTags => 'Remover Tag';

  @override
  String get dispensar => 'Dispensar';

  @override
  String get editTags => 'Editar Tag';

  @override
  String get fazerDesteAlbum => 'Fazer deste album';

  @override
  String get pai => 'Pai';

  @override
  String get filho => 'Filho';

  @override
  String get verTags => 'Ver Tags';

  @override
  String get erroPesquisaTag => 'Erro ao pesquisar tag';

  @override
  String get erroTitle => 'Erro';

  @override
  String get tagAdicionada => 'Tag adicionada';

  //endregion

  //region addBooru

  @override
  String get titleAddBooru => 'Novo Booru';

  @override
  String get desmarqueHttp => 'Desmarque se o provedor usa http';

  @override
  String get dominio => 'Domínio';

  @override
  String get homePage => 'Home page (opcional)';

  @override
  String get preConfig => 'Pré configurados ';

  @override
  String get tipoBooru => 'Tipo de Booru';

  @override
  String get teste => 'Teste';

  @override
  String get testandoDomain => 'Testando domínio';

  @override
  String get tudoCerto => 'Tudo certo!';

  @override
  String get buscaNoResult => 'A busca não retornou nenhum resultado';

  @override
  String get identificarProvider => 'Identificar tipo de Booru';

  @override
  String get danbooruInfo_1 => 'Normalmente na url desse provedor contém';

  @override
  String get danbooruInfo_2 => 'mas nem sempre';

  @override
  String get gelbooruInfo => 'A url desse provedor sempre contém';

  @override
  String get moebooruInfo_1 => 'Na url desse provedor pode contém';

  @override
  String get moebooruInfo_2 => 'mas nem sempre, veja que é diferente de Danbooru, pois não contém "s" no final.';

  @override
  String get excluir => 'Excluir';

  @override
  String get dadosSalvos => 'Dados Salvos';

  @override
  String get desejaRemoverProvider => 'Deseja remover esse provedor?';

  @override
  String get campoObrigatorio => 'Campo obrigatório';

  @override
  String get dominioTip => 'O formatu correto não deve conter barras /. Ex: exemplo.com';

  @override
  String get homePageTip => 'O formatu correto não deve conter barras /. Ex: exemplo.com';

  @override
  String get provedorTip => 'Já existe um provedor com este nome';

  //endregion

  //region albumPage

  @override
  String get titleAlbumPage => '';

  @override
  String get agruparPosts => 'Agrupar posts';

  @override
  String get album => 'Album';

  @override
  String get atualizado => 'Atalizado';

  @override
  String get atualizar => 'Atualizar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get capaAlbum => 'Capa do album';

  @override
  String get cliqueParaVerMais => 'Clique para ver mais';

  @override
  String get desfazerGrupo => 'Desfazer grupo';

  @override
  String get desselecionarTudo => 'Desmarcar tudo';

  @override
  String get filtroAtivado => 'Filtro ativado';

  @override
  String get noMoreResults => 'Sem mais resultados';

  @override
  String get infoAgrupar => 'Aqui você pode agrupar posts semelhantes';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get infoOnOff => 'Alterne entre seus posts salvos e posts online';

  @override
  String get provedor => 'Provedor';

  @override
  String get remover => 'Remover';

  @override
  String get selecionarTudo => 'Selecionar tudo';

  @override
  String get unirPosts => 'Unir posts';

  @override
  String get voltar => 'Voltar';

  @override
  String get aviso => 'Aviso';

  @override
  String get naoMostrarNovamente => 'Não mostrar novamente';

  @override
  String get providerExprireTip1 => 'Esse provedor expira seus links.';

  @override
  String get providerExprireTip2 => 'É possivel que você receba miniaturas de posts com msg de link expirado.';

  @override
  String get albumSalvo => 'Album salvo';

  @override
  String get buscarPostPage => 'Buscar posts de uma página específica';

  @override
  String get capaAlterada => 'Capa alterada';

  @override
  String get erroPesquisa => 'Erro ao pesquisar';

  @override
  String get erroTenteNovamente => 'Erro. Tente novamente';

  @override
  String get erroUnirPost => 'Erro ao unir posts';

  @override
  String get indiceBusca => 'Índice de busca';

  @override
  String get nPage => 'N. da página';

  @override
  String get postsCarregando => 'Os posts estão sendo carregados';

  @override
  String get selecioneUmPost => 'Selecione apenas um post';

  @override
  String get semPost => 'Sem post';

  @override
  String get semPostSelecionado => 'Nenhum post selecionado';

  @override
  String get infoTagTip => 'Este album não contém tags no provedor';

  //endregion

  //region ArmazenamentoTape

  @override
  String get titleArmazenamentoTape => 'Armazenamento';

  @override
  String get arquivos => 'arquivos';

  @override
  String get excluirArquivosDe => 'Excluir arquivos de';

  @override
  String get imgComprimidas => 'Imagens comprimidas';

  @override
  String get imgComprimidasCache => 'Imagens comprimidas em cache';

  @override
  String get postsEmCache => 'Posts em cache';

  @override
  String get postsSalvos => 'Posts salvos';

  @override
  String get limpar => 'Limpar';

  @override
  String get previewsEmCache => 'Previews em cache';

  @override
  String get previewsQualidade => 'Previews de melhor qualidade';

  @override
  String get previewsQualidadeCache => 'Previews de melhor qualidade em cache';

  @override
  String get tagsEmCache => 'Tags em cache';

  @override
  String get criarPreviewQualidade => 'Criar previews em melhor qualidade';

  @override
  String get criarPreviewQualidadeTip => 'O tamanho de cada arquivo será um pouco maior que as previews originais.';

  @override
  String get salvarImgDiferentesProvider => 'Você pode salvar a mesma Imagem em vários albuns. Apenas 1(uma) imagem será criada para todos os albuns afim de economizar seu armazenamento.';

  @override
  String get salvarImgReduzido => 'Salvar imagens em tamanho reduzido';

  @override
  String get salvarImgReduzidoTip => 'Reduz consideravelmente o armazenamento utilizado pelo app e aumenta o desempenho ao renderizar as imagens.\nVocê ainda poderá salvar as imagens na qualiade original separadamente.';

  @override
  String get salvarTagsPesquisa => 'Salvar tags pesquisadas';

  @override
  String get salvarTagsPesquisaTip => 'Agiliza a pesquisa de tags com a intenet lenta';

  //endregion

  //region CollectionPage

  @override
  String get titleCollectionPage => '';

  @override
  String get menu => 'Menu';

  @override
  String get pesquisar => 'Pesquisar';

  @override
  String get infoPesquisar => 'Clique aqui para pesquisar entre seus álbuns';

  @override
  String get unir => 'Unir';

  @override
  String get unirAlbuns => 'Unir albuns';

  @override
  String get a => 'a';

  //endregion

  //region ConfigPage

  @override
  String get titleConfigPage => 'Configurações';

  @override
  String get add => 'Add';

  @override
  String get albuns => 'Albuns';

  @override
  String get armazenamento => 'Armazenamento';

  @override
  String get layout => 'Layout';

  @override
  String get paginas => 'Páginas';

  @override
  String get usarPaginas => 'Usar páginas';

  @override
  String get posts => 'Posts';

  @override
  String get provedores => 'Provedores';

  @override
  String get editar => 'Editar';

  @override
  String get itemPorPagina => 'Itens por página';

  @override
  String get idioma => 'Idioma';

  //endregion

  //region FiltroPage

  @override
  String get permitirTags => 'Permitir tags selecionadas';

  @override
  String get aplicar => 'Aplicar';

  @override
  String get blouearTags => 'Bloquear tags selecionadas';

  @override
  String get opcoes => 'Opções';

  @override
  String get semResult => 'SEM RESULTADO';

  //endregion

  //region MoverAlbum

  @override
  String get titleMoverAlbum => 'Mover Album';

  @override
  String get em => 'em';

  @override
  String get voltarPara => 'Voltar para';

  @override
  String get moverParaEsteAlbum => 'Mover para este album';

  //endregion

  //region Store

  @override
  String get irParaOAlbum => 'Ir para o album';

  //endregion

  //region PostPage

  @override
  String get aTagEm => 'a tag em';

  @override
  String get addTagsAtual => 'Adicionar as Tags do album atual?';

  @override
  String get albumAtual => 'Album atual';

  @override
  String get albumCriado => 'Album criado';

  @override
  String get criarNovoAlbum => 'Criar novo album';

  @override
  String get naPastaRaiz => 'Na pasta raiz';

  @override
  String get nesteAlbum => 'Neste album';

  @override
  String get tipTags => 'Para ver Tags do post\nDeslize para CIMA';

  @override
  String get tipVoltar => 'Para voltar\nDeslize para BAIXO';

  @override
  String get albumNaoSalvo => 'Album não salvo';

  @override
  String get capaNaoAlterada => 'Capa não alterada';

  @override
  String get erroCompartilhar => 'Erro ao compartilhar';

  @override
  String get imgNaoCarregada => 'Aguarde imagem carregar';

  @override
  String get opcoesQualidade => 'Opções de qualidade';

  @override
  String get postNaoAtualizado => 'O post não foi atualizado';

  @override
  String get postNaoCarregado => 'Post não atualizado';

  @override
  String get postSalvo => 'Post salvo';

  @override
  String get curtir => 'Curtir';

  @override
  String get proximo => 'Próximo';

  @override
  String get anterior => 'Anterior';

  @override
  String get favoritos => 'Favorito';

  @override
  String get mais => 'Mais';

  @override
  String get ocorreuUmErro => 'Ocorreu um erro';

  @override
  String get qualidade => 'Qualidade';

  @override
  String get tags => 'Tags';

  //endregion

  //region Fragments

  @override
  String get addPasta => 'Adicionar pasta';

  @override
  String get erroOpenVideo => 'Erro ao reproduzir o vídeo';

  @override
  String get tenteOutroProvedor => 'Tente selecionar outro provedor';

  //endregion

  //region Menu

  @override
  String get novoAlbum => 'Novo Album';

  @override
  String get editarAlbum => 'Editar';

  @override
  String get excluirAlbum => 'Excluir';

  @override
  String get moverAlbum => 'Mover';

  @override
  String get ocultarAlbum => 'Ocultar';

  @override
  String get desocultarAlbum => 'Mostrar';

  @override
  String get tour => 'Tour';

  @override
  String get salvarAlbum => 'Salvar Album';

  @override
  String get rating => 'Rating';

  @override
  String get maturidade => 'Maturidade';

  @override
  String get resetCapa => 'Restaurar capa';

  @override
  String get useAlbumAsCapa => 'Capa da coleção';


  @override
  String get config => 'Configurações';

  @override
  String get info => 'Info';

  @override
  String get goToPage => 'Ir para';

  @override
  String get tagsCount => 'Posts Count';

  @override
  String get updatePosts => 'Atualizar Posts';

  @override
  String get autoUpdateCapa => 'Auto atualizar Capa';


  @override
  String get share => 'Compartilhar';

  @override
  String get openLink => 'Abrir no Navegador';

  @override
  String get fechar => 'Fechar';

  @override
  String get analizarGrupo => 'Analizar grupo';

  @override
  String get removeDoGrupo => 'Remover post do grupo';


  @override
  String get findParents => 'Procurar parents';

  @override
  String get refreshPost => 'Atualizar Post';

  @override
  String get refreshGroup => 'Atualizar Grupo';

  @override
  String get salvarOffline => 'Salvar post offline';


  @override
  String get sobrescrever => 'Sobrescrever dados';

  @override
  String get recriarMiniatura => 'Recriar miniatura';

  @override
  String get excluirImagem => 'Excluir do Dispositivo';

  @override
  String get wallpaper => 'Papel de parede.';

  //endregion

  //region subMenu

  @override
  String get subAlbum => 'Sub album';

  @override
  String get unirPostsSemelhantes => 'Unir posts semelhantes';

  @override
  String get verificarNumeroPosts => 'Verificar número de posts';

  @override
  String get alterarNomeETags => 'Alterar nome e Tags';

  @override
  String get excluirEsteAlbum => 'Excluir este album';

  @override
  String get usarCapaPadrao => 'Usar capa padrão';

  @override
  String get semprePostRecente => 'Sempre o post mais recente';

  @override
  String get usarComoCapaColecao => 'Usar como capa da coleção';

  @override
  String get dadosDesteAlbum => 'Dados deste album';

  @override
  String get paginaBuscaNaWeb => 'Página de busca na web';

  //endregion

  //region Popups

  @override
  String get tipo => 'Tipo';

  @override
  String get detalhes => 'Detalhes';

  @override
  String get dimensao => 'Dimensão';

  @override
  String get postIndisponivel => 'Post Indisponível';

  @override
  String get albumExcluido => 'Album excluido';

  @override
  String get pastaRaiz => 'Pasta raiz';

  @override
  String get arquivoOriginal => 'Arquivo original';

  @override
  String get arquivoSalvo => 'Arquivo salvo';

  @override
  String get arquivoSample => 'Arquivo sample';

  @override
  String get desejaExcluirAlbum => 'Deseja excluir este album?';

  @override
  String get do_ => 'do';

  @override
  String get excluirArquivos => 'Excluir arquivos';

  @override
  String get grupo => 'grupo';

  @override
  String get miniatura => 'Miniatura';

  @override
  String get nao => 'Não';

  @override
  String get selecionar => 'Selecionar';

  @override
  String get nomeDoAlbum => 'Nome do Album';

  @override
  String get ondeSalvarAlbum => 'Onde deseja salvar este album?';

  @override
  String get removerPost => 'Remover Post';

  @override
  String get sim => 'Sim';

  @override
  String get aplicado => 'Aplicado';

  @override
  String get bloquearEssaTag => 'Bloquear essa Tag?';

  @override
  String get bloquearEssaTagTip => 'Esta Tag será bloqueada em todos os seus albuns';

  @override
  String get ondeAplicar => 'Onde deseja aplicar?';

  @override
  String get tagBloqueada => 'Tag bloqueada';

  @override
  String get papelParede => 'Papel de parede';

  @override
  String get telaBloqueio => 'Tela de Bloqueio';

  @override
  String get albumNaoSalvoInfo => 'Para curtir você deve salvar o album\nDeseja salvar agora?';

  @override
  String get popupOverrideAlbumComPostsInfo => 'O álbum selecionado contém posts salvos\nSe prosseguir você não poderá mais vê-los\nDeseja continuar?';

  //endregion

  //region Geral

  @override
  String get languageName => name;

  @override
  String get geral => 'Geral';

  @override
  String get noImage => 'Sem Imagem';

  //endregion

  //region Tutorial

  @override
  String get infoPostLongTap => 'Clique e segure em\num post para visualizar';

  @override
  String get infoPostDoubleTap => 'Clique duas vezes em\num post para selecionar';

  @override
  String get infoTags => 'Clique aqui para ver as tags deste post';

  @override
  String get infoFav => 'Adicione aos favoritos';

  @override
  String get infoSave => 'Salvar imagem offline';

  @override
  String get infoLike => 'Salvar esse post no álbum';

  @override
  String get infoQualit => 'Altere a qualidade da imagem';

  @override
  String get infoAtualizarPost => 'Caso tenha problemas com algum post, você pode tentar utilizá-lo';

  @override
  String get infoSetCapaPost => 'Clique aqui para aplicar o post selecionado como capa do álbum';

  @override
  String get infoUnirPosts => 'Selecionando dois ou mais posts você pode unir-los';

  //endregion

  //region Arrays

  @override
  List<String> parenteOptions(String albumName) => [
    'FILHO de $albumName', 'PAI de $albumName',
  ];

  @override
  List<String> get bloqueioType => [
    'Parcial', 'Total',
  ];

  //endregion

}