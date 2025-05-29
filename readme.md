# How to install and build libnfc on iPhone 8

**System Info:** \
iPhone 8 \
iOS 16.7.11 \
Apple A11 Bionic 

## Building libnfc

Install bunch of tools and dependencies that you will need anyways. 
    
    sudo apt install python3 nano nodejs npm wget
    sudo apt install automake
    python3 -m ensurepip --upgrade

First follow tips section to get environment ready.
Run all commans as the `mobile` user. 

Create a working directory. 

    mkdir ~/myCode
    cd ~/myCode

Download and install [Theos](https://theos.dev/) for building. Theos needs the Procursus (`https://apt.procurs.us`) repo to be added into your package mananger as a source. 

    sudo apt install bash curl sudo coreutils xz-utils
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

Download a copy of [libnfc 1.7.0](https://github.com/nfc-tools/libnfc/releases/tag/libnfc-1.7.0). 

    wget https://github.com/nfc-tools/libnfc/releases/download/libnfc-1.7.0/libnfc-1.7.0.tar.bz2
    tar -jxvf libnfc-1.7.0.tar.bz2

Download and install perl (needed for `autoreconf`)\
*Because `autoreconf` runs `aclocal`, which needs perl at this specific path*

    curl -L http://xrl.us/installperlnix | bash
    echo "perl binary is at:" 
    which perl
    sudo mkdir -p /opt/procursus/bin/
    sudo ln -s /usr/bin/perl /opt/procursus/bin/perl

Generate `./configure` script

    autoreconf -vis
    
Patch `./configure` script \
*Note exact line number my differ, because this file is generated with the previous step.* The goal is the make bypass this message "checking whether we are cross compiling...", by tricking the script into thinking we are cross-compiling. The fix needs to be added to around line 4121, where the if statement check if we are cross-compiling

    sed -i '4121i cross_compiling=yes' configure


Build libnfc 

    ./configure --with-drivers=pn532_uart --sysconfdir=/etc --prefix=/usr
    make

Create `entitlements.plist`

    tee -a <<EOF entitlements.plist
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>platform-application</key>
        <true/>
        <key>com.apple.private.security.container-required</key>
        <false/>
        <key>com.apple.private.skip-library-validation</key>
        <true/>
    </dict>
    </plist>
    EOF

(Fake)sign built binaries

    ldid -Sentitlements.plist ./utils/.libs/nfc-list
    ldid -Sentitlements.plist ./utils/.libs/nfc-emulate-forum-tag4
    ldid -Sentitlements.plist ./utils/.libs/nfc-read-forum-tag3
    ldid -Sentitlements.plist ./utils/.libs/nfc-relay-picc
    ldid -Sentitlements.plist ./utils/.libs/nfc-mfclassic
    ldid -Sentitlements.plist ./utils/.libs/nfc-scan-device
    ldid -Sentitlements.plist ./utils/.libs/nfc-mfultralight

Try it out!

    cd utils
    ./nfc-list
    ./nfc-mfclassic

Install libnfc into system directory
      
    sudo make install

## Tips

Make a working directory (e.g. `code`) in `~/code/`.

The default user is `mobile`, the default password is `alpine`. 

Use `ssh-copy-id user@hostname` to copy a SSH public key from your computer. 

To access SSH into iPhone when not on the same network, you can use the free app called `Tailscale`. Download [Tailscale](https://tailscale.com/download/ios) from the App Store, and enable to VPN on the jailbroken iPhone. Tailscale then now can be installed on any device you from which you wish to access the jailbroken iPhone through SSH. 

An SFTP server is already running on the jailbroken iPhone, because SFTP is part of the SSH protocol and is part of OpenSSH. You can access that the server using the following (example) configuration. \
**Host:** iphone-8 / some ip (same as SSH) \
**User:** mobile (same as SSH) \
**Password:** password for mobile, by default `alpine` \
**Port:** 22 (!!) \
**URL:** sftp://iphone-8 

*SFTP is **NOT** the same as FTPS. SFTP builds on SSH and adds on file transfer capabilities. FTPS builds on FTP and adds on a security and encryption layer. We are using **SFTP**.* 

The OS uses various symlinks to make navigation easier (?). Please note that `~` is the same as `/private/var/mobile` and `/var/mobile`. This can come useful when browsing files through SFTP. 

To copy a file from the remote (iphone) into your local machine use scp. e.g.

    scp mobile@iphone-8:/var/mobile/myCode/libnfc-1.7.0/configure .

Copying the entire or parts of the `.zshrc` file located in this repo is recommened for various tools to work correctly. It should be copied to `~/.zshrc`, than zsh should be restarted (or run `source /var/mobile/.zshrc`).

# Notes 
According to neofetch \
Terminal: /dev/ttys000 