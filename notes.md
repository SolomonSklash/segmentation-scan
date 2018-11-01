* realcommand:
    *  masscan --rate 10000 -v -n -Pn -sS -p1-65535 -iL IPAddresses.txt >> TCP.log
* test command: 
    * sudo masscan --rate 10000 -v -n -Pn -sS -p1-65535 -iL IPAddresses.txt -e eth0 >> TCP.log


## local.sh
### TODO
* setup
    * ~~ASCII art~~
        * Segmentation Scanner
            * Big, Doom, Ogre, Slant, Small, Standard, Star Wars, Ivrit, Old Banner, 
            * Ogre fitted
        * FIS PTT
    * ~~check if running as root~~
    * take RBU name as argument
        * do input validation
        * ~~repalce spaces with underscores~~
    * take PPS as argument
        * do input validation
            * ~~check that param is a number~~
            * check valid range, i.e. 1-1000xxx
            * add warning for PPS higher than x
    * ~~take IPLIST as parameter~~
        * ~~check if it exists before continuing~~
    * add option for output type?
        * CSV, key/value pair in brackets, etc
    * ~~account for no/incomplete arguments~~
    * ~~output help options if run with no arguments~~
* ~~output description of what will happen~~
* ~~create local directory for scan~~
    * ~~Segmentation_Scan_RBUName_Year_Month~~
    * ~~check if it exists~~
* kick off scans on remote boxes
    * output confirmation check (Continue? Y/n)
    * start each scan sequentially before sleeping
        * find way to start remote commands without blocking
    * SCP/copy over IP address list name IPAddresses.txt
* sleep until scans are finished
    * sleep until results are SCP'd back?
    * sleep for x, then loop to check for completed results?
    * count # of IPs in IPAddresses.txt and estimate how long to sleep before waking up to check for results?
    * have max length to wait before cancelling scan
* copy results back
    * ParsedTCP_ATTACKBOXNAME_hh:mm:ss.txt
    * ParsedUDP_ATTACKBOXNAME_hh:mm:ss.txt
* how do we know if the scan started successfully??????
    * have remote.sh monitor the status of the masscan scan
    * check return value of masscan
        * if it fails, SCP a failure file back to local machine
        * if success, parse and SCP results back
        * have local.sh sleep, waking up to check for files
    * write to file on remote machine with update?
    * start screen session on remote machine so we can verify manually?
* binary/hex easter egg with message at the end of the scan

## remote.sh
### TODO
* take parameters for packets per second(PPS) and RBU name
* create directory structure
    * check that directory does not currently exist
        * add timestamp to directory name?
    * under engagements directory(?)
        * Segmentation_Scan_RBUName_Year_Month
        * Segmentation_Scan_RBUName_Year_Month
* look into various masscan flags/optimizations
* kick off TCP scan
    * optional check for dangerous subnets
    * optional latency check (via ping?) to select best PPS
    * output results as TCP_hh:mm:ss.log
* kick off UDP scan
    * optional check for dangerous subnets
    * optional latency check (via ping?) to select best PPS
    * output results as UDP_hh:mm:ss.log
* parse TCP results
    * use parser.jar?
    * use awk/cut
    * output filename ParsedTCP_BOXNAME_hh:mm:ss.txt
* parse UDP results
    * use parser.jar?
    * use awk/cut
    * output filename ParsedUDP_BOXNAME_hh:mm:ss.txt




```
 (    (   (      (                   
 )\ ) )\ ))\ )   )\ )  *   )  *   )  
(()/((()/(()/(  (()/(  )  /(  )  /(  
 /(_))/(_))(_))  /(_))( )(_))( )(_)) 
(_))_(_))(_))   (_)) (_(_())(_(_())  
| |_ |_ _/ __|  | _ \|_   _||_   _|  
| __| | |\__ \  |  _/  | |    | |    
|_|  |___|___/  |_|    |_|    |_|    
```           


```
 __                                 _        _   _              
/ _\ ___  __ _ _ __ ___   ___ _ __ | |_ __ _| |_(_) ___  _ __   
\ \ / _ \/ _\` | '_ \` _ \ / _ \ '_ \| __/ _\` | __| |/ _ \| '_ \  
_\ \  __/ (_| | | | | | |  __/ | | | || (_| | |_| | (_) | | | | 
\__/\___|\__, |_| |_| |_|\___|_| |_|\__\__,_|\__|_|\___/|_| |_| 
/ _\ ___ |___/_ __  _ __   ___ _ __                             
\ \ / __/ _\` | '_ \| '_ \ / _ \ '__|                            
_\ \ (_| (_| | | | | | | |  __/ |                               
\__/\___\__,_|_| |_|_| |_|\___|_|                               
```                                                             



```
 __                                 _        _   _               __                                 
/ _\ ___  __ _ _ __ ___   ___ _ __ | |_ __ _| |_(_) ___  _ __   / _\ ___ __ _ _ __  _ __   ___ _ __ 
\ \ / _ \/ _` | '_ ` _ \ / _ \ '_ \| __/ _` | __| |/ _ \| '_ \  \ \ / __/ _` | '_ \| '_ \ / _ \ '__|
_\ \  __/ (_| | | | | | |  __/ | | | || (_| | |_| | (_) | | | | _\ \ (_| (_| | | | | | | |  __/ |   
\__/\___|\__, |_| |_| |_|\___|_| |_|\__\__,_|\__|_|\___/|_| |_| \__/\___\__,_|_| |_|_| |_|\___|_|   
         |___/                                                                                      
```


```
================================================================================
================================================================================
================================================================================
==========7 7====I77+===+77+====7 7====I 7======================================
=========I77 7==?7   === 77 ?==7777I==I7  7=====================================
=========+ 77I=== 777===7777===I  7+==+  7I=====================================
================================================================================
================================================================================
================================================================================
========+7 7 7                  7======777=========I                     77?====
=======7 77                     7====== 7 +=======   7                   77?====
=====+7  77+===========================   +======7777+==========================
===== 777==============================   +=====+  7============================
====?7 7===============================   +====== 77+===========================
====7  I===============================   +======77  I+=========================
====7  ?==7                7===========   +=======7777                    I=====
====7  ?==?                ?===========   +=========I7                   777====
====7  ?===============================   +=============================?   I===
====7  ?===============================   +==============================7   ===
====7  ?===============================   +=============================+   7===
====7  ?===============================   +=======I7777777777777777777777777====
====7 7?===============================  7+======+7                      77=====
=====77================================+ 7========7                    7I=======
================================================================================
================================================================================
================================================================================
================================================================================
================================================================================
```
