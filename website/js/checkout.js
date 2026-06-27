(function () {
  function getClient() {
    var url = window.VG_SUPABASE_URL;
    var key = window.VG_SUPABASE_ANON_KEY;
    if (!url || !key || url.indexOf("__") >= 0 || !window.supabase) {
      return null;
    }
    return window.supabase.createClient(url, key);
  }

  function planFromButton(btn) {
    return btn.getAttribute("data-plan") || "annual";
  }

  function registerUrl(plan) {
    return "/register?plan=" + encodeURIComponent(plan);
  }

  function showToast(message) {
    var el = document.createElement("div");
    el.className = "vg-checkout-toast";
    el.textContent = message;
    document.body.appendChild(el);
    setTimeout(function () {
      el.classList.add("is-visible");
    }, 10);
    setTimeout(function () {
      el.classList.remove("is-visible");
      setTimeout(function () {
        el.remove();
      }, 300);
    }, 4500);
  }

  async function startCheckout(plan) {
    var client = getClient();
    if (!client) {
      window.location.href = registerUrl(plan);
      return;
    }

    var sessionRes = await client.auth.getSession();
    var session = sessionRes.data && sessionRes.data.session;
    if (!session) {
      window.location.href = registerUrl(plan);
      return;
    }

    var res = await fetch(window.VG_SUPABASE_URL + "/functions/v1/polar-create-checkout", {
      method: "POST",
      headers: {
        Authorization: "Bearer " + session.access_token,
        apikey: window.VG_SUPABASE_ANON_KEY,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ planId: plan }),
    });

    var payload = await res.json().catch(function () {
      return {};
    });
    if (!res.ok || !payload.checkoutUrl) {
      showToast("Could not start checkout. Try again.");
      return;
    }

    window.location.href = payload.checkoutUrl;
  }

  async function handleCheckoutSuccess() {
    var params = new URLSearchParams(window.location.search);
    if (params.get("checkout") !== "success") return;

    var client = getClient();
    if (!client) return;

    await client.auth.getSession();
    showToast("Welcome to Pro! Your credits are ready.");
    if (window.history && window.history.replaceState) {
      window.history.replaceState({}, "", "/pricing");
    }
  }

  document.querySelectorAll(".vg-checkout-btn[data-plan]").forEach(function (btn) {
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      startCheckout(planFromButton(btn));
    });
  });

  handleCheckoutSuccess();
})();
