[![Codemagic build status](https://api.codemagic.io/apps/5df31599c3cc4f70a402350d/5e16391de77e70001412d567/status_badge.svg)](https://codemagic.io/apps/5df31599c3cc4f70a402350d/5e16391de77e70001412d567/latest_build)
# Gaming Interface Client (Android)
Android client for the Gaming Interface Client

This is part of a  two app system that allows the use of a remote device (Tablet or Phone) to provide input into a PC game or application.  This software is the Android Client and runs on your Tablet or Phone.  It talks to the GICServer - https://github.com/Terence-D/GameInputCommandServer For example if you play a space simulator, you can add custom buttons for Comms, Warp Drive, Power control, etc and have it accessible at your fingertips without remembering complex keystrokes.

## Features
* Open Source and Free!
* Completely customizable - build the layout YOU want
* Supports multiple devices connecting to the server.  Use one Tablet for your ship Systems, another for Comms!
* Runs on Phones or Tablets
* Supports practically any game
* More features to be worked on!

Check the Wiki here https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki for more information.  Any issues please add to the Issue tracker, or contact me at support [ a]t coffeeshopstudio.ca

## Roadmap
Here's a rough roadmap of where I'm planning on taking this app.  Nothing is written in stone, this is subject to change:
* 4.3:  Rebuild the Main view and Screen Manager View into one, fully Flutter based.  Remove old screens from Java
* 4.4:  New sample screens:
** Trucking
** Mech
** Add support for additional tablet size
* 4.5: Add Theme Support (may push back to 5.x) and Convert Donate view to Flutter
* 4.6: Convert "In Game" screen view to Flutter
* 5.0: Convert Editor to Flutter, remove all legacy code
* 5.1: Rewrite screen editing completely if not already done in 5.0
* 5.2: Support new server features such as allow screen editing on the server
