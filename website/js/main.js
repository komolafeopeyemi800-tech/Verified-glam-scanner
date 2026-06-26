(function () {
  const appUrl = window.VG_APP_URL || "/login";

  document.querySelectorAll(".vg-app-link").forEach(function (link) {
    var href = link.getAttribute("href") || "";
    var label = (link.textContent || "").toLowerCase();
    var isSignup =
      link.classList.contains("nav-signup") ||
      /sign up|register|create free|create an account/.test(label);

    if (!href.startsWith("/") || /localhost|127\.0\.0\.1/.test(href)) {
      href = isSignup
        ? window.VG_REGISTER_URL || "/register"
        : window.VG_APP_URL || "/login";
      link.setAttribute("href", href);
    }
  });

  const devBanner = document.getElementById("dev-banner");
  if (devBanner && /localhost|127\.0\.0\.1/.test(window.location.hostname)) {
    devBanner.hidden = false;
  }

  const menuToggle = document.querySelector(".menu-toggle");
  const mobileNav = document.querySelector(".mobile-nav");

  if (menuToggle && mobileNav) {
    menuToggle.addEventListener("click", function () {
      const open = mobileNav.classList.toggle("is-open");
      menuToggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  document.querySelectorAll(".nav-dropdown-toggle").forEach(function (btn) {
    var dropdown = btn.closest(".nav-dropdown");
    if (!dropdown) return;
    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = dropdown.classList.toggle("is-open");
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
  });

  document.addEventListener("click", function () {
    document.querySelectorAll(".nav-dropdown.is-open").forEach(function (dropdown) {
      dropdown.classList.remove("is-open");
      var btn = dropdown.querySelector(".nav-dropdown-toggle");
      if (btn) btn.setAttribute("aria-expanded", "false");
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
})();
