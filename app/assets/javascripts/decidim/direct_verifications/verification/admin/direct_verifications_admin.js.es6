// = require_self

$(() => {
  $('[type="checkbox"]#register').change(function () {
      $(this).closest('label').find('.callout').toggleClass('hide', !$(this).prop('checked'))
  })
})
