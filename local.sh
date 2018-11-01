#!/bin/bash

# This script is run locally on BDOC, connects to the remote attack boxes, and run remote.sh

# Set colors for terminal output
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'

# Sweet ASCII art \m/
echo -en $RED"
 (    (   (      (     )   (  )   (     
 )\ ) )\ ))\ )   )\ )  *   )  *   )  
(()/((()/(()/(  (()/(  )  /(  )  /(  
 /(_))/(_))(_))  /(_))( )(_))( )(_)) 
(_))_(_))(_))   (_)) (_(_())(_(_()) "
echo -en $GREEN " 
| |_ |_ _/ __|  | _ \|_   _||_   _|  
| __| | |\__ \  |  _/  | |    | |    
|_|  |___|___/  |_|    |_|    |_|    
"
echo -en $BLUE"
 __                                 _        _   _              
/ _\ ___  __ _ _ __ ___   ___ _ __ | |_ __ _| |_(_) ___  _ __   
\ \ / _ \/ _\` | '_ \` _ \ / _ \ '_ \| __/ _\` | __| |/ _ \| '_ \  
_\ \  __/ (_| | | | | | |  __/ | | | || (_| | |_| | (_) | | | | 
\__/\___|\__, |_| |_| |_|\___|_| |_|\__\__,_|\__|_|\___/|_| |_| 
/ _\ ___ |___/_ __  _ __   ___ _ __                             
\ \ / __/ _\` | '_ \| '_ \ / _ \ '__|                            
_\ \ (_| (_| | | | | | | |  __/ |                               
\__/\___\__,_|_| |_|_| |_|\___|_|  
"$NC
echo -en $RED"
 _                 _           _     
| | ___   ___ __ _| |      ___| |__  
| |/ _ \ / __/ _\` | |     / __| '_ \ 
| | (_) | (_| (_| | |  _  \__ \ | | |
|_|\___/ \___\__,_|_| (_) |___/_| |_|

"$NC

# Check if script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo -e $RED"[!] This script must be run as root!"$NC;
    exit 1;
fi

# Print usage information
function usage() {
    echo -e $ORANGE"Usage: $0: RBU_NAME PPS IP_LIST\n$GREEN"
    echo -e "The$ORANGE RBU_NAME$GREEN parameter is the name of the$ORANGE Risk Business Unit$GREEN, and should not contain any spaces."
    echo -e "The$ORANGE PPS$GREEN parameter is the number of$ORANGE packets per second$GREEN masscan will send to the target IPs."
    echo -e "The$ORANGE IP_LIST$GREEN parameter is the$ORANGE list of IP addresses$GREEN to be scanned. The file should contain one IP per line.\n"
    echo -e $BLUE"This script connects to various NPT attack boxes and performs a 65535 port scan of a provided list"
    echo -e "of IP addresses via masscan. It SCPs the list of IPs to each attack box and kicks off scanning"
    echo -e "by invoking the remote.sh script on each attack box. The results are then parsed on the attack box"
    echo -e "and sent via SCP back to the local machine. The outputs and directory structures are as follows:\n"
    echo -e $GREEN"local machine\n$ORANGE\tSegmentation_Scan_RBUName_Year_Month/\n\t\tParsedTCP_ATTACKBOX_hh:mm:ss.txt\n\t\tParsedUDP_ATTACKBOX_hh:mm:ss.txt"
    echo -e $GREEN"remote attack boxes\n$ORANGE\tengagements/\n\t\tSegmentation_Scan_RBUName_Year_Month/"
    echo -e "\t\t\tParsedTCP_ATTACKBOX_hh:mm:ss.txt\n\t\t\tParsedUDP_ATTACKBOX_hh:mm:ss.txt"
    echo -e "\t\t\tTCP_hh:mm:ss.log\n\t\t\tUDP_hh:mm:ss.log\n"
    echo -e $GREEN"The masscan command used on the remote machines:"
    echo -e $BLUE"masscan --rate 10000 -v -n -Pn -sS -p1-65535 -iL IPAddresses.txt "
    echo -e $GREEN"\nFor more information on masscan, see$ORANGE https://github.com/robertdavidgraham/masscan\n"
    echo -e $RED"WARNING: MASSCAN CAN SEND A VERY LARGE AMOUNT OF TRAFFIC AND KNOCK BOXES OVER. PLEASE CHOOSE YOUR PPS VALUE WITH CARE!"$NC
}

# Check for correct number of parameters
if [ "$#" -ne 3 ]; then
    echo -e $RED"[!] Wrong number of parameters! See usage below.\n"$NC;
    usage;
    exit 1;
fi

# Save script parameters
RBU=$1
PPS=$2
IPLIST=$3

# Change spaces to underscores
RBU=${RBU// /_}

# Use regex to make sure PPS is a whole number
re='^[0-9]+$'
if ! [[ $PPS =~ $re ]] ; then
    echo -e $RED"[!] The packets per second parameter must be a whole number!"$NC;
    usage;
   exit 1;
fi

# Check that IPLIST file exists
if [ ! -f $3 ]; then
    echo -e $RED"[!] The IP list file provided does not exist!\n"$NC;
    usage;
    exit 1;
fi

echo "Risk Business Unit is $RBU"
echo "Packets per second is $PPS"
echo "IP list file is echo $IPLIST"

# Create local directory for scan results. Reuse old directory if possible
WORKINGDIR="Segmentation_Scan_${RBU}_$(date +%Y)_$(date +%m)"

if [ ! -d "$WORKINGDIR" ]; then
    echo -e "$GREEN[*] ${ORANGE}The working directory is ${WORKINGDIR}. It does not exist, so it is being created.$NC";
    sleep 0.5;
    mkdir -p $WORKINGDIR;
else
    echo -e "$GREEN[*] ${ORANGE}The working directory ${WORKINGDIR} already exists and will be reused.$NC";
    sleep 0.5;
fi
