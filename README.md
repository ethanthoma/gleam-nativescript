# Gleam NativeScript

This is a POC of using Gleam as the primary language for mobile app dev

## Running

> [!IMPORTANT]
> You will need flakes enabled or have node + android SDK installed

First, build the app via:
```su
nix shell
./bin/build
```

This will build the application. You can run it on an Android device via:
```su
sudo adb devices
ns run android
```

Look at the NativeScript docs for details on running on an emulator or IOS device.
