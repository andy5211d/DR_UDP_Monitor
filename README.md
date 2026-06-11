A utility to monitor and decode the UDP packets from Diverecorder.   

This utility is written in Delphi using Embarcadero's RAD Studio V13.1 IDE.

1. Has the capability of knowing if there is more than one NIC on the machine running this software and allows the user to select which is used for the monitor function.
2. Will display the reception status of each packet on each of the four ports used by DR.
3. Can show the 'decoded' data from each packet for easy understanding of its contents.
4. For the REFEREE and UPDATE packets (on 58091) can show simple metrics as to what has been received by this machine (could be different on other machines, remember it is UDP!).
5. Can display received data from all hosts on a simple diving type Scoreboard.
6. Additionally the program can scan the network to find all the running instances of Diverecorder (Hosts), and then display the data received from this host only on the simple Scoreboard.
