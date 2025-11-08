# Clean caches & corrupted build outputs (Windows PowerShell)

This README explains how to use `scripts/clean-android-caches.ps1` to safely inspect and optionally remove Android/Flutter caches and corrupted build outputs on Windows.

Important: the script defaults to a DRY-RUN. Nothing is deleted unless you pass the `-Perform` flag.

Quick examples

- Dry-run (shows what *would* be removed and reports sizes):

```powershell
cd F:\20251025\GitHub\spotseeker_app\scripts
.\clean-android-caches.ps1
```

- Remove build outputs only (actual deletion):

```powershell
.\clean-android-caches.ps1 -Perform -DeleteBuildOutputs -StopGradleDaemon
```

- Remove Gradle and Pub caches (use carefully — will re-download dependencies):

```powershell
.\clean-android-caches.ps1 -Perform -DeleteGradleCaches -DeletePubCache -RunFlutterClean
```

When to run this

- You see errors complaining about an invalid APK or missing AndroidManifest.xml (see the section below).
- Your disk ran out of space during a build and you suspect cache corruption.

Immediate steps to fix "Invalid file / AndroidManifest.xml not found" errors

1. Verify the Android manifest exists

```powershell
Test-Path .\android\app\src\main\AndroidManifest.xml
```

If this returns `False`, run `flutter create .` from project root to re-create Android project files (careful: commit any custom changes first).

2. Delete any corrupted APK and build outputs (dry-run first):

```powershell
.\clean-android-caches.ps1 -DeleteBuildOutputs
```

If output looks correct, run the actual deletion:

```powershell
.\clean-android-caches.ps1 -Perform -DeleteBuildOutputs -StopGradleDaemon
```

3. Rebuild dependencies and the app

```powershell
cd F:\20251025\GitHub\spotseeker_app
flutter pub get
flutter clean
flutter build apk
```

Notes & safety

- Deleting the Gradle and Pub caches will free space but will cause re-download of dependencies. Use these flags only when caches are corrupted or disk space is required.
- The script is conservative by default (dry-run). Always inspect output before using `-Perform`.
- If you're unsure, copy the log output and ask for help before deletion.

Known causes for the error you reported

- Disk full during prior build produced a truncated/corrupted APK — deleting the APK/build folder and re-running `flutter build` usually fixes it.
- Corrupted Gradle metadata (metadata.bin) — deleting Gradle caches forces Gradle to re-download artifacts.

If problems persist, consider these manual commands (more aggressive):

```powershell
# Stop Gradle daemons
cd F:\20251025\GitHub\spotseeker_app
.\android\gradlew.bat --stop

# Delete full Gradle caches and wrapper (aggressive)
Remove-Item -Path "$env:USERPROFILE\.gradle\caches" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\.gradle\wrapper" -Recurse -Force -ErrorAction SilentlyContinue

# Then rebuild
flutter pub get
flutter clean
flutter build apk
```

If you need help interpreting the script output, paste the relevant lines here and I'll help decide the next step.
