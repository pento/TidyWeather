# Release Procedures

## Android

Releasing a new version of the Android app requires the `config.json`, `~/key.jks`, and `android/key.properties` files.

### Building

In `android/app/build.gradle`
* Increment `flutterVersionCode`.
* Increase `flutterVersionName`, if necessary.

Run `flutter build appbundle` from the root directory of the repository.

When the build finishes, the release bundle will be in `build/app/outputs/bundle/release/app-release.aab`.

### Testing

Generate an APK set:

```
cd build/app/outputs/bundle/release
bundletool build-apks --bundle=./app-release.aab --output=./app-release.apks --ks=~/key.jks "--ks-pass=pass:<key-store-password>" --ks-key-alias=key
```

Find the device ID for the device you want to install it to:

`adb devices -l`

Install the APK on that device:

`bundletool install-apks --apks=./app-release.apks --device-id=<device-id>`

### Releasing

In the Google Play Console, navigate to _Release management_ -> _App releases_, and open the release track that this build will be released under.

* Click the _Create release_ button.
* Upload the `app-release.aab` file.
* Add a _Release name_, which should match `flutterVersionName`.
* Add release _Release notes_, based off the [latest changes](https://github.com/pento/TidyWeather/commits/master).
