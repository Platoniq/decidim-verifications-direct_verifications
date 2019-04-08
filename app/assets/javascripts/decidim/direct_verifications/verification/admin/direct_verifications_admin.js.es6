// = require_self

$(() => {
  $('[type="checkbox"]#register').change(function () {
      console.log('direct verifications', $(this))
      $(this).closest('label').find('.callout').toggleClass('hide', !$(this).prop('checked'))
  })

})
