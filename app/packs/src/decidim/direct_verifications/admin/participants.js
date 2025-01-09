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
    // Create the modal HTML
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

    // Convert the string to a DOM element
    const tempDiv = document.createElement("div");
    tempDiv.innerHTML = modalHtml.trim();
    this.modal = tempDiv.firstChild;

    // Insert the modal after the table
    this.table.parentNode.insertBefore(this.modal, this.table.nextSibling);

    // Find modal components
    this.modalBody = this.modal.querySelector(".modal-body");
    this.closeButton = this.modal.querySelector(".close-button");

    // Add event listeners
    this.closeButton.addEventListener("click", () => this.hideModal());
    this.modal.addEventListener("click", (event) => {
      if (event.target === this.modal) {
        this.hideModal();
      }
    });
  }

  drawButtons() {
    const rows = this.table.querySelectorAll("tbody tr");
    console.log(rows);
    rows.forEach((tr) => {
      const lastTd = tr.querySelector("td:last-child");
      if (lastTd) {
        const buttonHtml = `<span><a class="action-icon show-verifications-modal" title="${this.config.buttonTitle}" href="#open-show-verifications-modal"><span class="has-tip ${this.getTrStatus(tr)}"><svg aria-label="${this.config.buttonTitle}" role="img" class="icon--ban icon"><title>${this.config.buttonTitle}</title><use href="${this.svgPath}#ri-key-2-line"></use></svg></span></a></span>`;
        console.log(buttonHtml);
        lastTd.innerHTML = buttonHtml + lastTd.innerHTML;
      }
    });
  }

  addStatsTitle() {
    // Create a link element for verification stats
    const a = document.createElement("a");
    a.className = "button tiny button--title";
    a.href = this.config.statsPath;
    a.textContent = this.config.statsLabel;

    // Add a click event listener to prevent default navigation and load URL
    a.addEventListener("click", (event) => {
      event.preventDefault();
      this.loadUrl(a.href, true);
    });

    // Append the link to the title element
    if (this.title) {
      this.title.appendChild(a);
    }
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
    // Adjust modal size
    if (large) {
      this.modal.classList.add("large");
    } else {
      this.modal.classList.remove("large");
    }

    // Show loading spinner in the modal body
    this.modalBody.innerHTML = '<span class="loading-spinner"></span>';

    // Fetch and load the content into the modal body
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
  // Draw the icon buttons for checking verification statuses
  ui.drawButtons();
  ui.addStatsTitle();
});
