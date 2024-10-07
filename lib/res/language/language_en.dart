import 'i_language.dart';

class LanguageEN extends ILanguage {

  static const name = 'English';
  static const locale = 'en_US';

  //region addAlbum

  @override
  String get adicionar => 'Add';

  @override
  String get bloquear => 'Block';

  @override
  String get incluir => 'Include';

  @override
  String get currentBooru => 'Current Booru';

  @override
  String get filtro => 'Filter';

  @override
  String get nome => 'Name';

  @override
  String get pesquisarTags => 'Search Tags';

  @override
  String get salvar => 'Save';

  @override
  String get titleAddAlbum => 'New Album';
  @override
  String get titleEditAlbum => 'Edit Album';

  @override
  String get usuarioDev => 'User DeviantArt';

  @override
  String get clickParaAlterar => 'Click to change';

  @override
  String get clickParaVerPost => 'Click on the tag to see post';

  @override
  String get deleteTags => 'Remove Tag';

  @override
  String get dispensar => 'Dismiss';

  @override
  String get editTags => 'Edit Tag';

  @override
  String get fazerDesteAlbum => 'Make this album';

  @override
  String get pai => 'Father';

  @override
  String get filho => 'Child';

  @override
  String get verTags => 'View Tags';

  @override
  String get erroPesquisaTag => 'Error searching for tag';

  @override
  String get erroTitle => 'Error';

  @override
  String get tagAdicionada => 'Tag added';

  //endregion

  //region addBooru

  @override
  String get titleAddBooru => 'New Booru';

  @override
  String get desmarqueHttp => 'Uncheck if the provider uses http';

  @override
  String get dominio => 'Domain';

  @override
  String get homePage => 'Home page (optional)';

  @override
  String get preConfig => 'Pre configured ';

  @override
  String get tipoBooru => 'Type of Booru';

  @override
  String get teste => 'Test';

  @override
  String get testandoDomain => 'Testing domain';

  @override
  String get tudoCerto => 'All right!';

  @override
  String get buscaNoResult => 'The search returned no results';

  @override
  String get identificarProvider => 'Identify type of Booru';

  @override
  String get danbooruInfo_1 => 'Typically the provider\'s url contains';

  @override
  String get danbooruInfo_2 => 'but not always';

  @override
  String get gelbooruInfo => 'Provider url always contains';

  @override
  String get moebooruInfo_1 => 'The provider\'s url may contain';

  @override
  String get moebooruInfo_2 => 'but not always, see that it is different from Danbooru, as it does not contain "s" at the end.';

  @override
  String get excluir => 'Delete';

  @override
  String get dadosSalvos => 'Saved Data';

  @override
  String get desejaRemoverProvider => 'Do you want to remove this provider?';

  @override
  String get campoObrigatorio => 'Required field';

  @override
  String get dominioTip => 'The correct format should not contain slashes /. Ex: example.com';

  @override
  String get homePageTip => 'The correct format should not contain slashes /. Ex: example.com';

  @override
  String get provedorTip => 'A provider with this name already exists';

  //endregion

  //region albumPage

  @override
  String get titleAlbumPage => '';

  @override
  String get agruparPosts => 'Group posts';

  @override
  String get album => 'Album';

  @override
  String get atualizado => 'Updated';

  @override
  String get atualizar => 'Update';

  @override
  String get cancelar => 'Cancel';

  @override
  String get capaAlbum => 'Album cover';

  @override
  String get cliqueParaVerMais => 'Click to see more';

  @override
  String get desfazerGrupo => 'Undo group';

  @override
  String get desselecionarTudo => 'Deselect all';

  @override
  String get filtroAtivado => 'Filter activated';

  @override
  String get noMoreResults => 'No more results';

  @override
  String get infoAgrupar => 'Here you can group similar posts';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get infoOnOff => 'Switch between your saved posts and online posts';

  @override
  String get provedor => 'Provider';

  @override
  String get remover => 'Remove';

  @override
  String get selecionarTudo => 'Select all';

  @override
  String get unirPosts => 'Merge posts';

  @override
  String get voltar => 'Back';

  @override
  String get aviso => 'Notice';

  @override
  String get naoMostrarNovamente => 'Don\'t show again';

  @override
  String get providerExprireTip1 => 'This provider expires your links.';

  @override
  String get providerExprireTip2 => 'You may receive post thumbnails with an expired link message.';

  @override
  String get albumSalvo => 'Album saved';

  @override
  String get buscarPostPage => 'Search for posts from a specific page';

  @override
  String get capaAlterada => 'Altered cover';

  @override
  String get erroPesquisa => 'Error when searching';

  @override
  String get erroTenteNovamente => 'Error. Try again';

  @override
  String get erroUnirPost => 'Error when merging posts';

  @override
  String get indiceBusca => 'Search index';

  @override
  String get nPage => 'Page No.';

  @override
  String get postsCarregando => 'Posts are being loaded';

  @override
  String get selecioneUmPost => 'Select just one post';

  @override
  String get semPost => 'No post';

  @override
  String get semPostSelecionado => 'No posts selected';

  @override
  String get infoTagTip => 'This album does not contain tags in the provider';

  //endregion

  //region ArmazenamentoTape

  @override
  String get titleArmazenamentoTape => 'Storage';

  @override
  String get arquivos => 'files';

  @override
  String get excluirArquivosDe => 'Delete files from';

  @override
  String get imgComprimidas => 'Compressed images';

  @override
  String get imgComprimidasCache => 'Cached compressed images';

  @override
  String get postsEmCache => 'Cached Posts';

  @override
  String get postsSalvos => 'Saved Posts';

  @override
  String get limpar => 'Clean';

  @override
  String get previewsEmCache => 'Cached previews';

  @override
  String get previewsQualidade => 'Better quality reviews';

  @override
  String get previewsQualidadeCache => 'Higher quality cached previews';

  @override
  String get tagsEmCache => 'Cached tags';

  @override
  String get criarPreviewQualidade => 'Create better quality previews';

  @override
  String get criarPreviewQualidadeTip => 'The size of each file will be slightly larger than the original previews.';

  @override
  String get salvarImgDiferentesProvider => 'You can save the same Image in multiple albums. Only 1 (one) image will be created for all albums in order to save your storage.';

  @override
  String get salvarImgReduzido => 'Save images in reduced size';

  @override
  String get salvarImgReduzidoTip => 'Considerably reduces the storage used by the app and increases performance when rendering images.\nYou can even save images in their original quality separately.';

  @override
  String get salvarTagsPesquisa => 'Save searched tags';

  @override
  String get salvarTagsPesquisaTip => 'Perform tag search with slow internet.';

  //endregion

  //region CollectionPage

  @override
  String get titleCollectionPage => '';

  @override
  String get menu => 'Menu';

  @override
  String get pesquisar => 'Search';

  @override
  String get infoPesquisar => 'Click here to search through your albums';

  @override
  String get unir => 'Join';

  @override
  String get unirAlbuns => 'Join albuns';

  @override
  String get a => 'to';

  //endregion

  //region ConfigPage

  @override
  String get titleConfigPage => 'Settings';

  @override
  String get add => 'Add';

  @override
  String get albuns => 'Albuns';

  @override
  String get armazenamento => 'Storage';

  @override
  String get layout => 'Layout';

  @override
  String get paginas => 'Pages';

  @override
  String get usarPaginas => 'Use Pages';

  @override
  String get posts => 'Posts';

  @override
  String get provedores => 'Providers';

  @override
  String get editar => 'Edit';

  @override
  String get itemPorPagina => 'Items per page';

  @override
  String get idioma => 'Language';

  //endregion

  //region FiltroPage

  @override
  String get permitirTags => 'Allow selected tags';

  @override
  String get aplicar => 'Apply';

  @override
  String get blouearTags => 'Block selected tags';

  @override
  String get opcoes => 'Options';

  @override
  String get semResult => 'NO RESULTS';

  //endregion

  //region MoverAlbum

  @override
  String get titleMoverAlbum => 'Move Album';

  @override
  String get em => 'in';

  @override
  String get voltarPara => 'Go back to';

  @override
  String get moverParaEsteAlbum => 'Move to this album';

  //endregion

  //region Store

  @override
  String get irParaOAlbum => 'Go to album';

  //endregion

  //region PostPage

  @override
  String get aTagEm => 'the tag in';

  @override
  String get addTagsAtual => 'Add current album tags?';

  @override
  String get albumAtual => 'Current Album';

  @override
  String get albumCriado => 'Album created';

  @override
  String get criarNovoAlbum => 'Create new album';

  @override
  String get naPastaRaiz => 'In the root folder';

  @override
  String get nesteAlbum => 'In this album';

  @override
  String get tipTags => 'To see post tags\nSwipe UP';

  @override
  String get tipVoltar => 'To go back\nSwipe DOWN';

  @override
  String get albumNaoSalvo => 'Album not saved';

  @override
  String get capaNaoAlterada => 'Unaltered cover';

  @override
  String get erroCompartilhar => 'Error when sharing';

  @override
  String get imgNaoCarregada => 'Wait for image to load';

  @override
  String get opcoesQualidade => 'Quality options';

  @override
  String get postNaoAtualizado => 'The post has not been updated';

  @override
  String get postNaoCarregado => 'Post not updated';

  @override
  String get postSalvo => 'Post saved';

  @override
  String get curtir => 'Like';

  @override
  String get proximo => 'Next';

  @override
  String get anterior => 'Previous';

  @override
  String get favoritos => 'Favorite';

  @override
  String get mais => 'More';

  @override
  String get ocorreuUmErro => 'An error has occurred';

  @override
  String get qualidade => 'Quality';

  @override
  String get tags => 'Tags';

  //endregion

  //region Fragments

  @override
  String get addPasta => 'Add folder';

  @override
  String get erroOpenVideo => 'Error playing video';

  @override
  String get tenteOutroProvedor => 'Try selecting another provider';

  //endregion

  //region Menu

  @override
  String get novoAlbum => 'New Album';

  @override
  String get editarAlbum => 'Edit';

  @override
  String get excluirAlbum => 'Delete';

  @override
  String get moverAlbum => 'Move';

  @override
  String get ocultarAlbum => 'Hide';

  @override
  String get tour => 'Tour';

  @override
  String get desocultarAlbum => 'Show';

  @override
  String get salvarAlbum => 'Save Album';

  @override
  String get rating => 'Rating';

  @override
  String get maturidade => 'Maturity';

  @override
  String get resetCapa => 'Restore cover';

  @override
  String get useAlbumAsCapa => 'Collection cover';


  @override
  String get config => 'Settings';

  @override
  String get info => 'Info';

  @override
  String get goToPage => 'Go to';

  @override
  String get tagsCount => 'Posts Count';

  @override
  String get updatePosts => 'Update Posts';

  @override
  String get autoUpdateCapa => 'Auto update Cover';


  @override
  String get share => 'Share';

  @override
  String get openLink => 'Open in Browser';

  @override
  String get fechar => 'Close';

  @override
  String get analizarGrupo => 'Analyze group';

  @override
  String get removeDoGrupo => 'Remove post from group';


  @override
  String get findParents => 'Search parents';

  @override
  String get refreshPost => 'Update Post';

  @override
  String get refreshGroup => 'Update Group';

  @override
  String get salvarOffline => 'Save post offline';


  @override
  String get sobrescrever => 'Overwrite data';

  @override
  String get recriarMiniatura => 'Recreate thumbnail';

  @override
  String get excluirImagem => 'Delete from Device';

  @override
  String get wallpaper => 'Wallpaper.';

  //endregion

  //region sunMenu

  @override
  String get subAlbum => 'Sub album';

  @override
  String get unirPostsSemelhantes => 'Merge similar posts';

  @override
  String get verificarNumeroPosts => 'Check number of posts';

  @override
  String get alterarNomeETags => 'Change name and tags';

  @override
  String get excluirEsteAlbum => 'Delete this album';

  @override
  String get usarCapaPadrao => 'Use default cover';

  @override
  String get semprePostRecente => 'Always the most recent post';

  @override
  String get usarComoCapaColecao => 'Use as a collection cover';

  @override
  String get dadosDesteAlbum => 'Data from this album';

  @override
  String get paginaBuscaNaWeb => 'Web search page';

  //endregion

  //region Popups

  @override
  String get tipo => 'Type';

  @override
  String get detalhes => 'Details';

  @override
  String get dimensao => 'Dimension';

  @override
  String get postIndisponivel => 'Post Unavailable';

  @override
  String get albumExcluido => 'Deleted album';

  @override
  String get pastaRaiz => 'Root folder';

  @override
  String get arquivoOriginal => 'Original file';

  @override
  String get arquivoSalvo => 'Saved file';

  @override
  String get arquivoSample => 'Sample file';

  @override
  String get desejaExcluirAlbum => 'Do you want to delete this album?';

  @override
  String get do_ => 'from';

  @override
  String get excluirArquivos => 'Delete files';

  @override
  String get grupo => 'group';

  @override
  String get miniatura => 'Thumbnail';

  @override
  String get nao => 'No';

  @override
  String get selecionar => 'Select';

  @override
  String get nomeDoAlbum => 'Album Name';

  @override
  String get ondeSalvarAlbum => 'Where do you want to save this album?';

  @override
  String get removerPost => 'Remove Post';

  @override
  String get sim => 'Yes';

  @override
  String get aplicado => 'Applied';

  @override
  String get bloquearEssaTag => 'Block this Tag?';

  @override
  String get bloquearEssaTagTip => 'This Tag will be blocked on all your albums';

  @override
  String get ondeAplicar => 'Where do you want to apply?';

  @override
  String get tagBloqueada => 'Tag blocked';

  @override
  String get papelParede => 'Wallpaper';

  @override
  String get telaBloqueio => 'Lockscreen';

  @override
  String get albumNaoSalvoInfo => 'To enjoy you must save the album\nDo you want to save now?';

  @override
  String get popupOverrideAlbumComPostsInfo => 'The selected album contains saved posts\nIf you continue you will no longer be able to see them\nDo you wish to continue?';

  //endregion

  //region Geral

  @override
  String get languageName => name;

  @override
  String get geral => 'General';

  @override
  String get noImage => 'No Image';

  //endregion

  //region Tutorial

  @override
  String get infoPostLongTap => 'Click and hold\non a post to view';

  @override
  String get infoPostDoubleTap => 'Double click on\na post to select';

  @override
  String get infoTags => 'Click here to see the tags for this post';

  @override
  String get infoFav => 'Add to favorites';

  @override
  String get infoSave => 'Save image offline';

  @override
  String get infoLike => 'Save this post to album';

  @override
  String get infoQualit => 'Change the image quality';

  @override
  String get infoAtualizarPost => 'If you have problems with a post, you can try using it';

  @override
  String get infoSetCapaPost => 'Click here to apply the selected post as album cover';

  @override
  String get infoUnirPosts => 'By selecting two or more posts you can merge them';

  //endregion

  //region Arrays

  @override
  List<String> parenteOptions(String albumName) => [
    'Child of $albumName',
    'Father of $albumName',
  ];

  @override
  List<String> get bloqueioType => [
    'Partial', 'Total',
  ];

  //endregion

}