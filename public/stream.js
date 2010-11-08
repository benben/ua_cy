document.observe('dom:loaded', function() {
  var pu = new Ajax.PeriodicalUpdater('messages', '/update', {
    frequency: 2,
    method: 'get',
    parameters: { last_id: $('messages').firstDescendant().identify() },
    insertion: 'top'
  });
  
  $('messages').observe('DOMNodeInserted', function(event) {
    pu.options.parameters = { last_id: $('messages').firstDescendant().identify() };
    var message_count = $('messages').childElements().size();
    
    if(message_count > 20) {
      var remove_count = message_count - 20;
      for (var i = 1; i <= remove_count; i++) {
        console.log("removing message #" + $('messages').childElements().last().identify());
        $('messages').childElements().last().remove();
      }
    }
  });
});
