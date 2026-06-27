(function () {
  var embedded =
    document.documentElement.classList.contains("vg-embedded") ||
    /[?&]embed=1(?:&|$)/.test(location.search) ||
    window.self !== window.top;
  if (embedded) {
    document.documentElement.classList.add("vg-embedded");
  }

  function navigateTop(href) {
    if (window.VG_INTEGRATED_APP && window.top !== window.self) {
      try {
        window.top.postMessage(
          JSON.stringify({ type: "vg-navigate", path: href }),
          window.location.origin
        );
        return true;
      } catch (err) {
        window.top.location.assign(href);
        return true;
      }
    }
    return false;
  }

  function wireTopNav(link, href) {
    if (!window.VG_INTEGRATED_APP || !href || !href.startsWith("/") || href.startsWith("//")) {
      return;
    }
    link.setAttribute("target", "_top");
    link.addEventListener("click", function (e) {
      if (navigateTop(href)) e.preventDefault();
    });
  }

  document.querySelectorAll(".vg-app-link").forEach(function (link) {
    var href = link.getAttribute("href") || "";
    if (window.VG_INTEGRATED_APP) {
      wireTopNav(link, href);
      return;
    }
    if (!href.startsWith("/") && !href.startsWith("http")) {
      link.setAttribute("href", window.VG_APP_URL || "/login");
    }
  });

  document.querySelectorAll(".vg-tool-link").forEach(function (link) {
    var href = link.getAttribute("href");
    if (!href) return;
    wireTopNav(link, href);
  });

  const menuToggle = document.querySelector(".menu-toggle");
  const mobileNav = document.querySelector(".mobile-nav");

  function closeAllMega() {
    document.querySelectorAll(".nav-mega.is-open").forEach(function (mega) {
      mega.classList.remove("is-open");
      var btn = mega.querySelector(".nav-mega-toggle");
      if (btn) btn.setAttribute("aria-expanded", "false");
    });
    var host = document.getElementById("mega-dropdown-host");
    if (host) host.classList.remove("is-open");
    var panel = document.getElementById("mega-panel");
    if (panel) panel.hidden = true;
  }

  if (menuToggle && mobileNav) {
    menuToggle.addEventListener("click", function () {
      const open = mobileNav.classList.toggle("is-open");
      menuToggle.setAttribute("aria-expanded", open ? "true" : "false");
      closeAllMega();
    });
  }

  (function initMegaMenu() {
    var mega = document.querySelector(".nav-mega");
    var host = document.getElementById("mega-dropdown-host");
    var btn = mega && mega.querySelector(".nav-mega-toggle");
    var panel = document.getElementById("mega-panel");
    if (!mega || !host || !btn || !panel) return;

    var closeTimer = null;

    function isDesktop() {
      return window.matchMedia("(min-width: 768px)").matches;
    }

    function closeMega() {
      mega.classList.remove("is-open");
      host.classList.remove("is-open");
      btn.setAttribute("aria-expanded", "false");
      panel.hidden = true;
    }

    function openMega() {
      mega.classList.add("is-open");
      host.classList.add("is-open");
      btn.setAttribute("aria-expanded", "true");
      panel.hidden = false;
    }

    function cancelClose() {
      if (closeTimer) {
        clearTimeout(closeTimer);
        closeTimer = null;
      }
    }

    function scheduleClose() {
      cancelClose();
      closeTimer = setTimeout(closeMega, 120);
    }

    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      if (mega.classList.contains("is-open")) {
        closeMega();
      } else {
        openMega();
      }
    });

    [mega, host].forEach(function (el) {
      el.addEventListener("mouseenter", function () {
        if (isDesktop()) {
          cancelClose();
          openMega();
        }
      });
      el.addEventListener("mouseleave", function () {
        if (isDesktop()) scheduleClose();
      });
    });
  })();

  document.addEventListener("click", function () {
    closeAllMega();
    document.querySelectorAll(".nav-dropdown.is-open").forEach(function (dropdown) {
      dropdown.classList.remove("is-open");
      var btn = dropdown.querySelector(".nav-dropdown-toggle");
      if (btn) btn.setAttribute("aria-expanded", "false");
    });
  });

  document.querySelectorAll(".nav-dropdown-toggle").forEach(function (btn) {
    var dropdown = btn.closest(".nav-dropdown");
    if (!dropdown) return;
    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = dropdown.classList.toggle("is-open");
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
  });

  document.querySelectorAll(".faq-question").forEach(function (btn) {
    btn.addEventListener("click", function () {
      const item = btn.closest(".faq-item");
      if (!item) return;
      const open = item.classList.toggle("is-open");
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
  });

  document.querySelectorAll('a[href^="#"]').forEach(function (link) {
    link.addEventListener("click", function (e) {
      const id = link.getAttribute("href");
      if (!id || id === "#") return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: "smooth", block: "start" });
      if (mobileNav) mobileNav.classList.remove("is-open");
    });
  });

  (function initPricingPlanCards() {
    var group = document.querySelector(".vg-paywall__cards[data-plan-picker]");
    if (!group) return;
    var cards = group.querySelectorAll(".vg-plan-card[data-plan]");
    if (!cards.length) return;

    function selectCard(card) {
      cards.forEach(function (c) {
        var selected = c === card;
        c.classList.toggle("vg-plan-card--selected", selected);
        c.setAttribute("aria-checked", selected ? "true" : "false");
        c.tabIndex = selected ? 0 : -1;
      });
    }

    function cardForPlan(plan) {
      for (var i = 0; i < cards.length; i++) {
        if (cards[i].getAttribute("data-plan") === plan) return cards[i];
      }
      return null;
    }

    var initialPlan = new URLSearchParams(location.search).get("plan");
    if (initialPlan === "annual" || initialPlan === "pro_weekly") {
      var initialCard = cardForPlan(initialPlan);
      if (initialCard) selectCard(initialCard);
    }

    cards.forEach(function (card) {
      card.addEventListener("click", function (e) {
        if (e.target.closest("a")) return;
        selectCard(card);
      });
      card.addEventListener("keydown", function (e) {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          selectCard(card);
        }
        if (e.key === "ArrowDown" || e.key === "ArrowRight") {
          e.preventDefault();
          var next = card.nextElementSibling;
          if (next && next.matches(".vg-plan-card[data-plan]")) {
            selectCard(next);
            next.focus();
          }
        }
        if (e.key === "ArrowUp" || e.key === "ArrowLeft") {
          e.preventDefault();
          var prev = card.previousElementSibling;
          if (prev && prev.matches(".vg-plan-card[data-plan]")) {
            selectCard(prev);
            prev.focus();
          }
        }
      });
    });
  })();
})();
