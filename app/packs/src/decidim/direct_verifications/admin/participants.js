class VerificationUI {
	constructor($table, config) {
		this.$table = $table;
		this.svgPath = $table.find("use[href]:first").attr("href").split("#")[0];
		this.icon = "icon-key";
		this.config = config;
		this.$table.on('click', '.show-verifications-modal', (e) => this.toggleModal(e));
		this.addModal();
		console.log(this);
	}

	addModal() {
		this.$table.after(`<div class="reveal" id="show-verifications-modal" data-reveal>
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
		this.$modal = $("#show-verifications-modal");
		this.$modalBody = this.$modal.find(".modal-body");
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

	getTrStatus(tr) {
		return this.getUserVerifications($(tr).data("user-id")).length ? "alert" : "";
	}

	getVerification(id) {
		return this.config.verifications.find(auth => auth.id == id);
	}

	getUserVerifications(userId) {
		return this.config.verifications.filter(auth => auth.userId == userId);
	}

	toggleModal(e) {
		const userId = $(e.target).closest("tr").data("user-id");
		// console.log(this.getUserVerifications(userId))
		// console.log(this.config.userVerificationsPath.replace("-ID-",userId))
		this.$modalBody.html('<span class="loading-spinner"></span>');
		this.$modalBody.load(this.config.userVerificationsPath.replace("-ID-",userId));
		this.$modal.foundation("toggle");
	}
}

$(() => {
  const ui = new VerificationUI($("#user-groups table.table-list"), DirectVerificationsConfig);
  // Draw the icon buttons for checking verification statuses
  ui.drawButtons();
  //TODO: set verifications statuses
});