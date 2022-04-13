class VerificationUI {
	constructor($table, config) {
		this.$table = $table;
		console.log($table);
		this.svgPath = $table.find("use[href]:first").attr("href").split("#")[0];
		this.icon = "icon-key";
		this.config = config;
		console.log(this)
	}

	drawButtons() {
	  this.$table.find("tbody tr").each((idx, tr) => {
  		const $lastTd = $(tr).find("td:last");

	  	$lastTd.prepend(`<a class="action-icon action-icon action-icon" title="${this.config.buttonTitle}" href="#open-verifications-modal"><span class="has-tip ${this.getTrStatus(tr)}"><svg aria-label="${this.config.buttonTitle}" role="img" class="icon--ban icon">
	  		<title>${this.config.buttonTitle}</title>
	  		<use href="${this.svgPath}#${this.icon}"></use>
	  		</svg></span></a>`);
	  });
	}

	getTrStatus(tr) {
		return this.getVerification($(tr).data("user-id")) ? "alert" : "";
	}

	getVerification(id) {
		return this.config.verifications.find(auth => auth.id == id);
	}
}

$(() => {
  const ui = new VerificationUI($("#user-groups table.table-list"), DirectVerificationsConfig);
  // Draw the icon buttons for checking verification statuses
  ui.drawButtons();
  //TODO: set verifications statuses
});