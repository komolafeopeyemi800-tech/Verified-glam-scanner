# E2E fixtures

`test-face.jpg` is required for `tools/e2e-test-supabase.ps1`.

If missing, download a sample portrait:

```powershell
Invoke-WebRequest -Uri "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80" `
  -OutFile "tools\fixtures\test-face.jpg" -UseBasicParsing
```
