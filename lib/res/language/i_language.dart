abstract class ILanguage implements _AddAlbum,
    _AddBooru,
    _AlbumPage,
    _ArmazenamentoTape,
    _CollectionPage,
    _ConfigPage,
    _FiltroPage,
    _MoverAlbum,
    _PostPage,
    _StorePage,
    _Menu,
    _SubMenu,
    _Popups,
    _Fragments,
    _Geral,
    _Tutorial,
    _Arrays {}

abstract class _AddAlbum {
  String get titleAddAlbum;
  String get titleEditAlbum;
  String get filtro;
  String get currentBooru;
  String get nome;
  String get pesquisarTags;
  String get adicionar;
  String get bloquear;
  String get incluir;
  String get salvar;
  String get usuarioDev;
  String get clickParaAlterar;
  String get fazerDesteAlbum;
  String get pai;
  String get filho;
  String get clickParaVerPost;
  String get dispensar;
  String get verTags;
  String get editTags;
  String get deleteTags;
  String get erroPesquisaTag;
  String get erroTitle;
  String get tagAdicionada;
}

abstract class _AddBooru {
  String get titleAddBooru;
  String get nome;
  String get dominio;
  String get homePage;
  String get desmarqueHttp;
  String get tipoBooru;
  String get teste;
  String get testandoDomain;
  String get tudoCerto;
  String get buscaNoResult;
  String get identificarProvider;
  String get danbooruInfo_1;
  String get danbooruInfo_2;
  String get gelbooruInfo;
  String get moebooruInfo_1;
  String get moebooruInfo_2;
  String get salvar;
  String get excluir;
  String get preConfig;
  String get dadosSalvos;
  String get desejaRemoverProvider;
  String get campoObrigatorio;
  String get dominioTip;
  String get homePageTip;
  String get provedorTip;
}

abstract class _AlbumPage {
  String get titleAlbumPage;
  String get album;
  String get cliqueParaVerMais;
  String get provedor;
  String get atualizado;
  String get noMoreResults;
  String get cancelar;
  String get voltar;
  String get filtroAtivado;
  String get agruparPosts;
  String get online;
  String get offline;
  String get selecionarTudo;
  String get desselecionarTudo;
  String get salvar;
  String get remover;
  String get curtir;
  String get desfazerGrupo;
  String get unirPosts;
  String get atualizar;
  String get capaAlbum;
  String get aviso;
  String get naoMostrarNovamente;
  String get providerExprireTip1;
  String get providerExprireTip2;
  String get albumSalvo;
  String get capaAlterada;
  String get erroPesquisa;
  String get semPost;
  String get semPostSelecionado;
  String get buscarPostPage;
  String get nPage;
  String get indiceBusca;
  String get erroTenteNovamente;
  String get selecioneUmPost;
  String get erroUnirPost;
  String get postsCarregando;
}

abstract class _ArmazenamentoTape {
  String get titleArmazenamentoTape;
  String get postsSalvos;
  String get previewsQualidade;
  String get previewsQualidadeCache;
  String get imgComprimidas;
  String get imgComprimidasCache;
  String get postsEmCache;
  String get previewsEmCache;
  String get tagsEmCache;
  String get excluirArquivosDe;
  String get arquivos;
  String get limpar;
  String get salvarTagsPesquisa;
  String get salvarTagsPesquisaTip;
  String get salvarImgReduzido;
  String get salvarImgReduzidoTip;
  String get criarPreviewQualidade;
  String get criarPreviewQualidadeTip;
  String get salvarImgDiferentesProvider;
}

abstract class _CollectionPage {
  String get titleCollectionPage;
  String get pesquisar;
  String get menu;
  String get unir;
  String get unirAlbuns;
  String get a;
}

abstract class _ConfigPage {
  String get titleConfigPage;
  String get provedores;
  String get add;
  String get layout;
  String get albuns;
  String get posts;
  String get paginas;
  String get usarPaginas;
  String get armazenamento;
  String get editar;
  String get itemPorPagina;
  String get idioma;
}

abstract class _FiltroPage {
  String get permitirTags;
  String get blouearTags;
  String get opcoes;
  String get aplicar;
  String get semResult;
}

abstract class _MoverAlbum {
  String get titleMoverAlbum;
  String get voltarPara;
  String get moverParaEsteAlbum;
  String get em;
}

abstract class _PostPage {
  String get tags;
  String get favoritos;
  String get qualidade;
  String get mais;
  String get anterior;
  String get proximo;
  String get ocorreuUmErro;
  String get tipVoltar;
  String get tipTags;
  String get addTagsAtual;
  String get aTagEm;
  String get albumAtual;
  String get criarNovoAlbum;
  String get naPastaRaiz;
  String get albumCriado;
  String get nesteAlbum;
  String get postNaoCarregado;
  String get postSalvo;
  String get capaNaoAlterada;
  String get postNaoAtualizado;
  String get erroCompartilhar;
  String get imgNaoCarregada;
  String get opcoesQualidade;
  String get albumNaoSalvo;
}

abstract class _StorePage {
  String get irParaOAlbum;
}

abstract class _Fragments {
  String get addPasta;
  String get erroOpenVideo;
  String get tenteOutroProvedor;
}

abstract class _Menu {
  String get novoAlbum;
  String get editarAlbum;
  String get excluirAlbum;
  String get moverAlbum;
  String get unirAlbuns;
  String get ocultarAlbum;
  String get desocultarAlbum;
  String get salvarAlbum;
  String get rating;
  String get tagsCount;
  String get unirPosts;
  String get maturidade;
  String get filtro;
  String get resetCapa;
  String get useAlbumAsCapa;

  String get config;
  String get info;
  String get tour; // tutorial
  String get goToPage;
  String get updatePosts;
  String get autoUpdateCapa;
  String get favoritos;
  String get postsSalvos;

  String get share;
  String get openLink;
  String get capaAlbum;
  String get fechar;
  String get analizarGrupo;
  String get removeDoGrupo;

  String get findParents;
  String get refreshPost;
  String get refreshGroup;
  String get salvarOffline;

  String get sobrescrever;
  String get recriarMiniatura;
  String get excluirImagem;
  String get wallpaper;
}

abstract class _SubMenu {
    String get subAlbum;
    String get unirPostsSemelhantes;
    String get verificarNumeroPosts;
    String get alterarNomeETags;
    String get excluirEsteAlbum;
    String get usarCapaPadrao;
    String get semprePostRecente;
    String get usarComoCapaColecao;
    String get dadosDesteAlbum;
    String get paginaBuscaNaWeb;
}

abstract class _Popups {
  String get detalhes;
  String get tipo;
  String get dimensao;
  String get postIndisponivel;
  String get excluirArquivos;
  String get miniatura;
  String get arquivoSample;
  String get arquivoSalvo;
  String get arquivoOriginal;
  String get removerPost;
  String get do_;
  String get grupo;
  String get nomeDoAlbum;
  String get ondeSalvarAlbum;
  String get desejaExcluirAlbum;
  String get albumExcluido;
  String get pastaRaiz;
  String get selecionar;
  String get bloquearEssaTag;
  String get bloquearEssaTagTip;
  String get tagBloqueada;
  String get ondeAplicar;
  String get papelParede;
  String get telaBloqueio;
  String get aplicado;
  String get albumNaoSalvoInfo;
  String get popupOverrideAlbumComPostsInfo;

  String get sim;
  String get nao;
}

abstract class _Geral {
  String get languageName;
  String get geral;
  String get noImage;
}

abstract class _Tutorial {
  String get infoPostLongTap;
  String get infoPostDoubleTap;
  String get infoTags;
  String get infoFav;
  String get infoSave;
  String get infoLike;
  String get infoQualit;
  String get infoAgrupar;
  String get infoOnOff;
  String get infoTagTip;
  String get infoPesquisar;
  String get infoUnirPosts;
  String get infoAtualizarPost;
  String get infoSetCapaPost;
}

abstract class _Arrays {
  List<String> parenteOptions(String albumName);

  List<String> get bloqueioType;

}