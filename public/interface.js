document.observe('dom:loaded', function() {

$('submit').observe('click', function(event) {
	new Ajax.Updater('notice', '/send', {
		method: 'get',
		parameters: $('sender').serialize(true)
		});
	$('message').clear();
})

new Form.Element.Observer(
  'message',
  0.2,  // 200 milliseconds
  function(el, value){
    if (value.length > 0) {
			$('submit').writeAttribute('href', '#');
			$('submit').setStyle({
				backgroundColor: '#FF9900'
			});

		} else {
			$('submit').removeAttribute('href');
			$('submit').setStyle({
				backgroundColor: '#999'
			});
		}
  }
)

});

