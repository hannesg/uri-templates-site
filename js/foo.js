$(function($){
  var current = null;
  $('#lang').change(function(ev){
    var $this = $(this);
    if( current ) $(document.body).removeClass('show-'+current);
    current = $this.val();
    $(document.body).addClass('show-'+$this.val());
    console.debug($this.val());
  }).trigger('change');
  return ;
  $('h1, h2').each(function(i, el){
    var $foo = $('<div>');
    var $el = $(el);
    console.debug($el.css('backgroundColor'));
    $foo.height($el.height());
    $foo.width(20);
    $foo.css('backgroundColor', $el.css('backgroundColor'));
    $foo.css('marginTop', '16px');
    $foo.css('marginBottom', '-'+($el.height()+16)+'px');
    $foo.css('clear','right');
    $foo.css('float','left');
    $foo.css('MozTransform', 'matrix(1,1,0,1,-10,10)');
    $foo.insertBefore(el);
  });

});
