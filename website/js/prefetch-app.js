(function () {
  function vgPrefetchFlutterApp() {
    ["/flutter_bootstrap.js", "/main.dart.js"].forEach(function (url) {
      if (document.querySelector('link[rel="prefetch"][href="' + url + '"]')) return;
      var link = document.createElement("link");
      link.rel = "prefetch";
      link.href = url;
      link.as = "script";
      document.head.appendChild(link);
    });
  }

  window.addEventListener("load", function () {
    if ("requestIdleCallback" in window) {
      requestIdleCallback(vgPrefetchFlutterApp, { timeout: 4000 });
    } else {
      setTimeout(vgPrefetchFlutterApp, 2000);
    }
  });
})();
