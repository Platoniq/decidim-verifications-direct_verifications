class VerificationUI {
  constructor($table, config) {
    this.$table = $table;
    this.svgPath = $table.find("use[href]:first").attr("href").split("#")[0];
    this.icon = "icon-key";
    this.config = config;
    this.$table.on("click", ".show-verifications-modal", (event) => this.toggleModal(event));
    this.addModal();
  }

  addModal() {
    this.$modal = $(`<div class="reveal" id="show-verifications-modal" data-reveal>
  <div class="reveal__header">
    <h3 class="reveal__title">${this.config.modalTitle}</h3>
    <button class="close-button" data-close aria-label="${this.config.closeModalLabel}"
      type="button">
      <span aria-hidden="true">&times;</span>
    </button>
  </div>

  <div class="row">
    <div class="columns medium-4 medium-centered modal-body">
    </div>
  </div>
</div>`);
    this.$table.after(this.$modal);
    this.$title = $("#user-groups .card-title:first");
    this.$modalBody = this.$modal.find(".modal-body");
    // eslint-disable-next-line no-undef
    this.reveal = new Foundation.Reveal(this.$modal);
  }

  drawButtons() {
    this.$table.find("tbody tr").each((idx, tr) => {
      const $lastTd = $(tr).find("td:last");

      $lastTd.prepend(`<a class="action-icon action-icon action-icon show-verifications-modal" title="${this.config.buttonTitle}" href="#open-show-verifications-modal"><span class="has-tip ${this.getTrStatus(tr)}"><svg aria-label="${this.config.buttonTitle}" role="img" class="icon--ban icon">
        <title>${this.config.buttonTitle}</title>
        <use href="${this.svgPath}#${this.icon}"></use>
        </svg></span></a>`);
    });
  }

  addStatsTitle() {
    // Add upper link to verification stats
    const $a = $(`<a class="button tiny button--title" href="${this.config.statsPath}">${this.config.statsLabel}</a>`);
    $a.on("click", (event) => {
      event.preventDefault();
      this.loadUrl($a.attr("href"), true);
    });
    this.$title.append($a);
  }

  getTrStatus(tr) {
    return this.getUserVerifications($(tr).data("user-id")).length
      ? "alert"
      : "";
  }

  getVerification(id) {
    return this.config.verifications.find((auth) => auth.id === id);
  }

  getUserVerifications(userId) {
    return this.config.verifications.filter((auth) => auth.userId === userId);
  }

  toggleModal(event) {
    const userId = $(event.target).closest("tr").data("user-id");
    this.loadUrl(this.config.userVerificationsPath.replace("-ID-", userId));
  }

  loadUrl(url, large = false) {
    this.$modal.removeClass("large");
    if (large) {
      this.$modal.addClass("large");
    }
    this.$modalBody.html('<span class="loading-spinner"></span>');
    this.$modalBody.load(url);
    this.$modal.foundation("toggle");
  }
}

$(() => {
  // eslint-disable-next-line no-undef
  const ui = new VerificationUI($("#user-groups table.table-list"), DirectVerificationsConfig);
  // Draw the icon buttons for checking verification statuses
  ui.drawButtons();
  ui.addStatsTitle();
});
