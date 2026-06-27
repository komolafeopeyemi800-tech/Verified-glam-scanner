(function () {
  var VALID_PLANS = { annual: true, pro_weekly: true };

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

  function publicCheckoutUrl(plan) {
    if (plan === "annual" && window.VG_POLAR_CHECKOUT_LINK_ANNUAL) {
      return window.VG_POLAR_CHECKOUT_LINK_ANNUAL;
    }
    if (plan === "pro_weekly" && window.VG_POLAR_CHECKOUT_LINK_PRO_WEEKLY) {
      return window.VG_POLAR_CHECKOUT_LINK_PRO_WEEKLY;
    }
    return null;
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

  function delay(ms) {
    return new Promise(function (resolve) {
      setTimeout(resolve, ms);
    });
  }

  function stripCheckoutParam() {
    var params = new URLSearchParams(window.location.search);
    if (!params.has("checkout")) return;
    params.delete("checkout");
    var query = params.toString();
    var next = window.location.pathname + (query ? "?" + query : "");
    window.history.replaceState({}, "", next);
  }

  async function getSession(client) {
    var sessionRes = await client.auth.getSession();
    return sessionRes.data && sessionRes.data.session;
  }

  async function fetchProfile(client) {
    var session = await getSession(client);
    if (!session) return null;
    var res = await client
      .from("profiles")
      .select("is_pro, credits_balance, subscription_plan")
      .eq("id", session.user.id)
      .maybeSingle();
    if (res.error) return null;
    return res.data;
  }

  async function fetchProfileIsPro(client) {
    var profile = await fetchProfile(client);
    return profile && profile.is_pro === true;
  }

  async function pollProfileIsPro(client, maxAttempts, delayMs) {
    for (var i = 0; i < maxAttempts; i++) {
      if (await fetchProfileIsPro(client)) return true;
      await delay(delayMs);
    }
    return false;
  }

  async function startCheckout(plan) {
    var client = getClient();
    var session = client ? await getSession(client) : null;

    if (!session) {
      var guestUrl = publicCheckoutUrl(plan);
      if (guestUrl) {
        window.location.href = guestUrl;
        return;
      }
      showToast("Could not start checkout. Try again.");
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

  async function openCustomerPortal() {
    var client = getClient();
    if (!client) {
      window.location.href = "/login?redirect=" + encodeURIComponent("/pricing");
      return;
    }

    var session = await getSession(client);
    if (!session) {
      window.location.href = "/login?redirect=" + encodeURIComponent("/pricing");
      return;
    }

    var res = await fetch(window.VG_SUPABASE_URL + "/functions/v1/polar-customer-portal", {
      method: "POST",
      headers: {
        Authorization: "Bearer " + session.access_token,
        apikey: window.VG_SUPABASE_ANON_KEY,
        "Content-Type": "application/json",
      },
      body: "{}",
    });

    var payload = await res.json().catch(function () {
      return {};
    });
    if (!res.ok || !payload.portalUrl) {
      showToast("Could not open billing portal. Try again from your profile.");
      return;
    }

    window.open(payload.portalUrl, "_blank", "noopener,noreferrer");
  }

  async function updateManageBillingUi() {
    var section = document.getElementById("vg-pricing-manage");
    if (!section) return;

    var client = getClient();
    if (!client) {
      section.hidden = true;
      return;
    }

    var session = await getSession(client);
    if (!session) {
      section.hidden = true;
      return;
    }

    var profile = await fetchProfile(client);
    var isPro = profile && profile.is_pro === true;
    section.hidden = !isPro;

    var balanceEl = document.getElementById("vg-pricing-credits-balance");
    if (balanceEl && isPro) {
      var balance = profile.credits_balance != null ? profile.credits_balance : 0;
      balanceEl.textContent = String(balance);
      balanceEl.hidden = false;
    } else if (balanceEl) {
      balanceEl.hidden = true;
    }
  }

  async function handleCheckoutSuccess() {
    var client = getClient();
    if (!client) {
      window.location.href = "/app/face-beauty-analysis?checkout=success";
      return;
    }

    showToast("Processing your subscription…");
    var ready = await pollProfileIsPro(client, 15, 2000);
    stripCheckoutParam();

    if (ready) {
      showToast("Welcome to Pro! Redirecting to your dashboard…");
      window.location.href = "/app/face-beauty-analysis";
      return;
    }

    showToast("Payment processing — refresh in a moment.");
  }

  function handleCheckoutQueryParams() {
    var params = new URLSearchParams(window.location.search);
    var checkout = params.get("checkout");
    if (checkout === "cancelled") {
      showToast("Checkout cancelled. Choose a plan when you are ready.");
      stripCheckoutParam();
      return;
    }
    if (checkout === "pending") {
      showToast("Payment processing — refresh in a moment.");
      stripCheckoutParam();
      return;
    }
    if (checkout === "success") {
      handleCheckoutSuccess();
    }
  }

  async function maybeResumeCheckout() {
    var params = new URLSearchParams(window.location.search);
    var plan = params.get("plan");
    if (!VALID_PLANS[plan]) return;
    if (params.get("checkout") === "success") return;
    if (params.get("checkout") === "cancelled") return;
    if (params.get("checkout") === "pending") return;

    var resumePlan = null;
    try {
      resumePlan = sessionStorage.getItem("vg_resume_checkout");
    } catch (_) {}

    if (resumePlan !== plan) return;

    var client = getClient();
    if (!client) return;

    var session = await getSession(client);
    if (!session) return;

    try {
      sessionStorage.removeItem("vg_resume_checkout");
    } catch (_) {}

    await startCheckout(plan);
  }

  document.querySelectorAll(".vg-checkout-btn[data-plan]").forEach(function (btn) {
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      startCheckout(planFromButton(btn));
    });
  });

  var manageBtn = document.getElementById("vg-manage-billing-btn");
  if (manageBtn) {
    manageBtn.addEventListener("click", function (e) {
      e.preventDefault();
      openCustomerPortal();
    });
  }

  handleCheckoutQueryParams();
  updateManageBillingUi();
  maybeResumeCheckout();
})();
