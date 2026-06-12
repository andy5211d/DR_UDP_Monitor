A utility to monitor and decode the UDP packets from Diverecorder.   

This utility is written in Delphi using Embarcadero's RAD Studio V13 IDE
This utility is written in Delphi using Embarcadero's RAD Studio V13 IDE

The intent of this utility is to understand what is happening on the DR network by receiving and monitoring the DR UDP packets sent by all running instances of DR.

1. Has a graphical and numeric display of all the DR packets received.
2. Has the capability of knowing if there is more than one NIC on the machine running this software and allows the user to select which is used.
3. Can select which Host is being used for the DR-Display function (mini scoreboard).
4. Can decode the DR UDP packets.
5. Shows simple metrics about the UPDATE and REFEREE packets received.

The utility will run 'as is' BUT will show an error on startup.  The error can be ignored and the utility will run but the mini scoreboard will not work.  To run without error this .exe file needs to be in a specific DR folder thus: C:\Program Files (x86)\MDT\DRUtils and then, if required, a shortcut to it on the desktop.  Admin rights will be needed to do all this.
