(function () {
  var form = document.getElementById("vg-auth-form");
  if (!form) return;

  var errorEl = document.getElementById("vg-auth-error");
  var googleBtn = document.getElementById("vg-google-btn");
  var mode = form.getAttribute("data-mode") || "login";
  var params = new URLSearchParams(window.location.search);
  var redirect = params.get("redirect") || "/app/face-beauty-analysis";

  function showError(msg) {
    if (!errorEl) return;
    errorEl.textContent = msg;
    errorEl.hidden = !msg;
  }

  function getClient() {
    var url = window.VG_SUPABASE_URL;
    var key = window.VG_SUPABASE_ANON_KEY;
    if (!url || !key || url.indexOf("__") >= 0) {
      throw new Error("Auth is not configured on this build.");
    }
    return window.supabase.createClient(url, key);
  }

  function goAfterAuth() {
    window.location.href = redirect;
  }

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    showError("");
    var email = form.email.value.trim();
    var password = form.password.value;
    var client = getClient();
    var submit = form.querySelector(".auth-submit");
    if (submit) submit.disabled = true;

    var promise =
      mode === "login"
        ? client.auth.signInWithPassword({ email: email, password: password })
        : client.auth.signUp({ email: email, password: password });

    promise
      .then(function (res) {
        if (res.error) throw res.error;
        if (mode === "register" && !res.data.session) {
          showError("Check your email to confirm your account, then sign in.");
          return;
        }
        goAfterAuth();
      })
      .catch(function (err) {
        showError(err.message || "Sign in failed.");
      })
      .finally(function () {
        if (submit) submit.disabled = false;
      });
  });

  if (googleBtn) {
    googleBtn.addEventListener("click", function () {
      showError("");
      var clientId = window.VG_GOOGLE_WEB_CLIENT_ID;
      if (!clientId || clientId.indexOf("__") >= 0) {
        showError("Google sign-in is not configured.");
        return;
      }
      var client = getClient();
      client.auth
        .signInWithOAuth({
          provider: "google",
          options: {
            redirectTo: window.location.origin + redirect,
          },
        })
        .then(function (res) {
          if (res.error) throw res.error;
        })
        .catch(function (err) {
          showError(err.message || "Google sign-in failed.");
        });
    });
  }
})();
