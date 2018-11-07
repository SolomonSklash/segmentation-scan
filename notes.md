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
    * SCP/copy over IP address list name IPAddresses.txt
    * start each scan sequentially before sleeping(v2?)
        * find way to start remote commands without blocking
* sleep until scans are finished?
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
            * have file contain error message from masscan, if possible
            * echo out error and quit
        * if success, parse and SCP results back
        * have local.sh sleep, waking up to check for files
    * write to file on remote machine with update?
    * start screen session on remote machine so we can verify manually?

## remote.sh
### TODO
* ~~take parameters for packets per second(PPS), RBU name, and IPLIST~~
    * ~~add standalone parameter~~
* ~~enable script to be run standalone or by local.sh~~
    * ~~include local.sh defensive checks~~
* ~~write usage()~~
* ~~create directory structure~~
    * ~~check that directory does not currently exist~~
        * ~~add timestamp to directory name~~
    * ~~under /root/engagements directory~~
        * ~~Segmentation_Scan_RBUName_Year_Month~~
* ~~look into various masscan flags/optimizations~~
* kick off TCP scan
    * optional check for dangerous subnets (v2)
    * optional latency check (via ping?) to select best PPS (v2)
    * ~~output results as TCP_hh:mm:ss.log~~
    * ~~indicate where logs will be stored~~
* kick off UDP scan
    * optional check for dangerous subnets (v2)
    * optional latency check (via ping?) to select best PPS (v2)
    * ~~output results as UDP_hh:mm:ss.log~~
    * ~~indicate where logs will be stored~~
* parse TCP results
    * account for results being empty
    * use parser.jar
    * use awk/cut
    * output filename ParsedTCP_BOXNAME_hh:mm:ss.txt
    * write function for parsing
* parse UDP results
    * account for results being empty
    * use parser.jar
    * use awk/cut
    * output filename ParsedUDP_BOXNAME_hh:mm:ss.txt
    * write function for parsing
* send results back
    * check for standalone
        * if standalone, don't send results back
    * SCP results back

## Version 2
* Python?
    * Maybe [Fabric](https://www.fabfile.org/)


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
 __            __                                 
/ _\ ___  __ _/ _\ ___ __ _ _ __  _ __   ___ _ __ 
\ \ / _ \/ _\` \ \ / __/ _\` | '_ \| '_ \ / _ \ '__|
_\ \  __/ (_| |\ \ (_| (_| | | | | | | |  __/ |   
\__/\___|\__, \__/\___\__,_|_| |_|_| |_|\___|_|   
         |___/                                   
```