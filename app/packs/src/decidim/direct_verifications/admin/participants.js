class VerificationUI {
  constructor(table, config) {
    this.table = table;
    this.svgPath = table.querySelector("use[href]").getAttribute("href").split("#")[0];
    this.config = config;

    this.table.addEventListener("click", (event) => {
      if (event.target.closest(".show-verifications-modal")) {
        this.toggleModal(event);
      }
    });

    this.addModal();
  }

  addModal() {
    const modalHtml = `
<div id="show-verifications-modal" data-dialog="show-verifications-modal" role="dialog" tabindex="-1"
     aria-hidden="true" aria-modal="true" aria-labelledby="dialog-title-show-verifications-modal" aria-describedby="dialog-desc-show-verifications-modal">
  <div id="show-verifications-modal-content">
    <button class="close-button" type="button" data-dialog-close="show-verifications-modal" data-dialog-closable aria-label="${this.config.closeModalLabel}">×</button>
    <div data-dialog-container>
      <svg width="1em" height="1em" role="img" aria-hidden="true"><use href="${this.svgPath}#ri-information-line"></use></svg>
      <h3 class="h3" id="dialog-title-show-verifications-modal" tabindex="-1" data-dialog-title="">${this.config.modalTitle}</h3>
      <div id="dialog-desc-show-verifications-modal" class="my-8">
        <div class="modal-body"></div>
      </div>
    </div>
    <div data-dialog-actions></div>
  </div>
</div>`;

    const tempDiv = document.createElement("div");
    tempDiv.innerHTML = modalHtml.trim();
    this.modal = tempDiv.firstChild;

    this.table.parentNode.insertBefore(this.modal, this.table.nextSibling);

    this.modalBody = this.modal.querySelector(".modal-body");
    this.closeButton = this.modal.querySelector(".close-button");

    this.closeButton.addEventListener("click", () => this.hideModal());
    this.modal.addEventListener("click", (event) => {
      if (event.target === this.modal) {
        this.hideModal();
      }
    });
  }

  drawButtons() {
    const rows = this.table.querySelectorAll("tbody tr");
    rows.forEach((tr) => {
      const lastTd = tr.querySelector("td:last-child");
      if (lastTd) {
        const buttonHtml = `<span><a class="action-icon show-verifications-modal" title="${this.config.buttonTitle}" href="#open-show-verifications-modal"><span class="has-tip ${this.getTrStatus(tr)}"><svg aria-label="${this.config.buttonTitle}" role="img" class="icon--ban icon"><title>${this.config.buttonTitle}</title><use href="${this.svgPath}#ri-key-2-line"></use></svg></span></a></span>`;
        lastTd.innerHTML = buttonHtml + lastTd.innerHTML;
      }
    });
  }

  addStatsTitle() {
    const element = document.querySelector(".item_show__header-title");
    const button = `<a class="button button__sm button__secondary" href="/admin/direct_verifications/stats">${this.config.statsLabel}</a>`;
    element.innerHTML += button;
  }

  getTrStatus(tr) {
    const userId = tr.dataset.userId;
    return this.getUserVerifications(userId).length
      ? "alert"
      : "";
  }

  getVerification(id) {
    return this.config.verifications.find((auth) => auth.id === id);
  }

  getUserVerifications(userId) {
    return this.config.verifications.filter((auth) => auth.userId === userId);
  }

  showModal() {
    this.modal.setAttribute("aria-hidden", "false");
    this.modal.style.display = "block";
    document.body.classList.add("modal-open");
  }

  hideModal() {
    this.modal.setAttribute("aria-hidden", "true");
    this.modal.style.display = "none";
    document.body.classList.remove("modal-open");
  }

  toggleModal(event) {
    const tr = event.target.closest("tr");
    if (tr) {
      const userId = tr.dataset.userId;
      const url = this.config.userVerificationsPath.replace("-ID-", userId);
      this.loadUrl(url);
    }
  }

  loadUrl(url, large = false) {
    if (large) {
      this.modal.classList.add("large");
    } else {
      this.modal.classList.remove("large");
    }

    this.modalBody.innerHTML = '<span class="loading-spinner"></span>';
    fetch(url).
      then((response) => response.text()).
      then((html) => {
        this.modalBody.innerHTML = html;
        this.showModal();
      }).
      catch((error) => {
        this.modalBody.innerHTML = `<p>Error loading content: ${error.message}</p>`;
        this.showModal();
      });
  }
}

document.addEventListener("DOMContentLoaded", () => {
  // eslint-disable-next-line no-undef
  const ui = new VerificationUI(document.querySelector("#user-groups table.table-list"), DirectVerificationsConfig);
  ui.drawButtons();
  ui.addStatsTitle();
});
