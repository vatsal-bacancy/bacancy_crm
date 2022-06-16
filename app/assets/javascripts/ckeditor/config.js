CKEDITOR.editorConfig = function (config) {
  // ... other configuration ...
  // config.toolbar_mini = [
  //   ["Bold",  "Italic",  "Underline",  "Strike",  "-",  "Subscript",  "Superscript"],
  // ];
  // config.toolbar = "mini";
  // ... rest of the original config.js  ...
  config.filebrowserBrowseUrl = "/ckeditor/attachment_files";
  config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files";
  config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files";
  config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures";
  // config.filebrowserImageBrowseUrl = "/ckeditor/pictures";
  // config.filebrowserImageUploadUrl = "/ckeditor/pictures";
  config.filebrowserImageBrowseUrl= "/ckeditor/pictures?";
  config.filebrowserImageUploadUrl= "/ckeditor/pictures?";
  config.filebrowserUploadUrl = "/ckeditor/attachment_files";
  config.allowedContent = true;






  //config.extraPlugins = 'uploadfile,uploadwidget,link';

  //config.filebrowserImageUploadUrl = '/app/uploaders/ckeditor_picture_uploader';

  config.toolbar = [
   { name: 'clipboard', items: [ 'Cut','Copy','Paste','-','Undo','Redo' ] },
   { name: 'basicstyles', items: [ 'Bold','Italic','Underline' ] },
   { name: 'paragraph', items: [ 'NumberedList', 'BulletedList','-', 'Blockquote', 'Justifyleft', 'Justifycenter', 'Justifyright', 'Justifyblock' ] },
   { name: 'styles', items: ['Styles','Format'] },
   { name: 'colors', items: [ 'TextColor', 'BGColor' ] },
  { name: 'insert', items: ['Image', 'Table', 'HorizontalRule', 'PageBreak'] },
  {name: 'source', items: ['Source']}
  ];


  CKEDITOR.plugins.addExternal( 'youtube', '/ckeditor/plugins/youtube/' );

  // for automatic height adjustment
  CKEDITOR.plugins.addExternal( 'autogrow', '/ckeditor/plugins/autogrow/' );
  config.autoGrow_minHeight = 250;
  config.autoGrow_maxHeight = 1000;
  config.autoGrow_onStartup = true;

  config.extraPlugins = 'youtube, autogrow';
};
