# binqr [pronounced binker]

<p align="center">
 <img src="https://ik.imagekit.io/jayowiee/github/binqr/text.png" alt="binqr" width="320" style="border-radius: 24px;" />
</p>

<p align="center">
 <a href="https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-arm64-v8a.apk">
  <img src="https://ik.imagekit.io/jayowiee/badges/download-apk.png" alt="download APK" height="48" />
 </a>
 <a href="https://binqr.jayoiwee.com" style="margin-left: 10px;">
  <img src="https://ik.imagekit.io/jayowiee/badges/website.png" alt="Website" height="48" />
 </a>
 <a href="https://github.com/mathdebate09/binqr/releases/latest" style="margin-left: 10px;">
  <img src="https://ik.imagekit.io/jayowiee/badges/latest-release.png" alt="Website" height="48" />
 </a>
 <a href="https://youtu.be/APfcLUemndo" style="margin-left: 10px;">
  <img src="https://ik.imagekit.io/jayowiee/badges/demo.png" alt="youtube demo video" height="48" />
 </a>
</p>

<p align="center">
 Connection-free file transfer for android and desktop using QR devices as a medium, written in flutter & vite
</p>

## How It Works

1. **Send**: Pick any file → it's split into 2000-byte chunks → each chunk becomes a QR code with an MD5 checksum → QR codes flash at 10/sec on screen

1. **Receive**: Open camera → scan metadata QR → progress bar fills as chunks arrive → file is saved to `/binqr/` folder when complete

## Screenshots

### Home

<table>
 <tr>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/home.png" alt="home" width="220" />
   <div align="center">Home</div>
  </td>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/home-info.png" alt="home-info" width="220" />
   <div align="center">Home Info</div>
  </td>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/home-history.png" alt="home-history" width="220" />
   <div align="center">History of Received Files</div>
  </td>
 </tr>
</table>

### Send

<table>
 <tr>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/send.png" alt="send" width="220" />
   <div align="center">Send</div>
  </td>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/send-metadata.png" alt="send-metadata" width="220" />
   <div align="center">Sending Metadata</div>
  </td>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/send-stream.png" alt="send-stream" width="220" />
   <div align="center">Sending Stream</div>
  </td>
 </tr>
</table>

### Receive

<table>
 <tr>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/receive.png" alt="receive" width="220" />
   <div align="center">Receive</div>
  </td>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/receive-scanning.png" alt="receive-scanning" width="220" />
   <div align="center">Receiving QR Stream</div>
  </td>
  <td align="center">
   <img src="https://ik.imagekit.io/jayowiee/github/binqr/mockups/receive-complete.png" alt="receive-complete" width="220" />
   <div align="center">Receive Complete</div>
  </td>
 </tr>
</table>

## Usecase

- When you cannot trust a device but you have to extract a file out of without establishing a connection or any sort of pairing, binqr works perfectly fine and securely.

- **Example**: In college labs you have to get your `.docx` file back into your device for that you can use binqr instead of logging in your whatsapp/drive.

## Running Locally

### Development build

```bash
git clone git@github.com:mathdebate09/binqr.git
flutter pub get
flutter run
```

## Production build

```bash
cd android

# Generate a release keystore (Windows CMD / PowerShell)
keytool -genkeypair -v -keystore %USERPROFILE%\binqr-release.jks -alias binqr -keyalg RSA -keysize 2048 -validity 10000

# Generate a release keystore (macOS / Linux)
# keytool -genkeypair -v -keystore $HOME/binqr-release.jks -alias binqr -keyalg RSA -keysize 2048 -validity 10000

# Create android/keystore.properties (example)
# storeFile=C:/Users/<you>/binqr-release.jks
# storePassword=your_store_password
# keyAlias=binqr
# keyPassword=your_key_password

cd ..
flutter build apk --release --split-per-abi
```

## Dependencies

| Package | Version |
|---|---|
| `cupertino_icons` | ^1.0.8 |
| `qr_flutter` | ^4.1.0 |
| `mobile_scanner` | ^7.2.0 |
| `file_picker` | ^10.1.2 |
| `path_provider` | ^2.1.5 |
| `path` | ^1.9.0 |
| `crypto` | ^3.0.0 |
| `permission_handler` | ^11.0.0 |
| `google_fonts` | ^6.2.1 |
| `open_filex` | ^4.7.0 |
| `url_launcher` | ^6.3.1 |
| `share_plus` | ^10.0.2 |

| Package | Version |
|---|---|
| `flutter_test` | sdk: flutter |
| `flutter_native_splash` | ^2.4.0 |
| `flutter_launcher_icons` | ^0.13.1 |
| `flutter_lints` | ^6.0.0 |
