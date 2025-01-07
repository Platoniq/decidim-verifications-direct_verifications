$(() => {
  $('[type="checkbox"]#register').change(function () {
    // eslint-disable-next-line no-invalid-this
    $(this).closest("label").find(".callout").toggleClass("hide", !$(this).prop("checked"))
  })
})
