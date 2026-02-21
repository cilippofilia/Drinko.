# Release Checklist

## Branch
1. Create release branch from main: `release/x.y`
2. Only cherry-pick or fix on the release branch

## Versioning
1. Bump marketing version to `x.y` on the release branch
2. Increment build number for every release build

## Xcode Cloud
1. Workflow start condition: Branch changes on `release/*`
2. Build + Unit Tests + Archive
3. (Optional) Upload to TestFlight

## Release
1. Validate build in TestFlight (if enabled)
2. Tag release: `vX.Y` or `vX.Y.Z`
3. Merge `release/x.y` back into `main`
4. Delete `release/x.y` after the build is live
