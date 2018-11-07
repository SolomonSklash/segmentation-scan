#!/bin/bash

# This script is run on the remote attack boxes, i.e. NPTLTCU1, NPTBDOCU1, LTC User LAN

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
 __            __                                 
/ _\ ___  __ _/ _\ ___ __ _ _ __  _ __   ___ _ __ 
\ \ / _ \/ _\` \ \ / __/ _\` | '_ \| '_ \ / _ \ '__|
_\ \  __/ (_| |\ \ (_| (_| | | | | | | |  __/ |   
\__/\___|\__, \__/\___\__,_|_| |_|_| |_|\___|_|   
         |___/                                   
"$NC

echo -e $RED"
 _ __ ___ _ __ ___   ___ | |_ ___       ___| |__  
| '__/ _ \ '_ \` _ \ / _ \| __/ _ \     / __| '_ \ 
| | |  __/ | | | | | (_) | ||  __/  _  \__ \ | | |
|_|  \___|_| |_| |_|\___/ \__\___| (_) |___/_| |_|                                                 
"$NC

# Check if script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo -e $RED"[!] This script must be run as root!"$NC;
    exit 1;
fi

# Print usage information
function usage() {
    echo -e $ORANGE"Usage: $0: RBU_NAME PPS IP_LIST STANDALONE\n$GREEN"
    echo -e "The$ORANGE RBU_NAME$GREEN parameter is the name of the$ORANGE Risk Business Unit$GREEN, and should not contain any spaces."
    echo -e "The$ORANGE PPS$GREEN parameter is the number of$ORANGE packets per second$GREEN masscan will send to the target IPs."
    echo -e "The$ORANGE IP_LIST$GREEN parameter is the$ORANGE list of IP addresses$GREEN to be scanned. The file should contain one IP per line."
    echo -e "The$ORANGE STANDALONE$GREEN parameter determines whether the script is being run locally or by remote.sh The value should be$ORANGE TRUE or YES$GREEN.\n"
    echo -e $BLUE"This script performs a 65535 port scan of a provided list of IPs via masscan. In normal mode, it will SCP the results back to"
    echo -e "the local.sh machine. In standalone mode, it will perform the scan, parse the output, and leave it on this machine."
    echo -e "The outputs and directory structures are as follows:\n"
    echo -e $GREEN"remote attack boxes\n$ORANGE\tengagements/\n\t\tSegmentation_Scan_RBUName_Year_Month/"
    echo -e "\t\t\tParsedTCP_ATTACKBOX_hh:mm:ss.txt\n\t\t\tParsedUDP_ATTACKBOX_hh:mm:ss.txt"
    echo -e "\t\t\tTCP_hh:mm:ss.log\n\t\t\tUDP_hh:mm:ss.log\n"
    echo -e $GREEN"The masscan command used on the remote machines:"
    echo -e $BLUE"masscan --rate 10000 -v -n -Pn -sS -p1-65535 -iL \$IPLIST"
    echo -e $GREEN"\nFor more information on masscan, see$ORANGE https://github.com/robertdavidgraham/masscan\n"
    echo -e $RED"WARNING: MASSCAN CAN SEND A VERY LARGE AMOUNT OF TRAFFIC AND KNOCK BOXES OVER. PLEASE CHOOSE YOUR PPS VALUE WITH CARE!"$NC
}

# Check for correct number of parameters
if [ "$#" -lt 3 ]; then
    echo -e $RED"[!] Wrong number of parameters! See usage below.\n"$NC;
    sleep 1.5;
    usage;
    exit 1;
fi

# Save script parameters
RBU=$1
PPS=$2
IPLIST=$3
STANDALONE=$4

# Change spaces to underscores
RBU=${RBU// /_}

# Use regex to make sure PPS is a whole number
re='^[0-9]+$'
if ! [[ $PPS =~ $re ]] ; then
    echo -e $RED"[!] The packets per second parameter must be a whole number!"$NC;
    sleep 1.5;
    usage;
   exit 1;
fi

# Check that IPLIST file exists
if [ ! -f $3 ]; then
    echo -e $RED"[!] The IP list file provided does not exist!\n"$NC;
    sleep 1.5;
    usage;
    exit 1;
fi

# Create local directory for scan results. Reuse old directory if possible
ENGAGEMENTS="/root/engagements/"
WORKINGDIR="Segmentation_Scan_remote_${RBU}_$(date +%Y)_$(date +%m)"

if [ ! -d "${ENGAGEMENTS}${WORKINGDIR}" ]; then
    echo -e "$GREEN[*] ${ORANGE}The working directory is ${ENGAGEMENTS}${WORKINGDIR}. It does not exist, so it is being created.$NC";
    sleep 0.7;
    mkdir -p ${ENGAGEMENTS}${WORKINGDIR};
else
    echo -e "$GREEN[*] ${ORANGE}The working directory ${WORKINGDIR} already exists and will be reused.$NC";
    sleep 0.7;
fi

# Create output file names for logs
TCPLOG="TCP_$(date +%H:%M:%S).log"
UDPLOG="UDP_$(date +%H:%M:%S).log"

# Create masscan commands
# TODO: Change to FIS commands
MASSCANTCP="masscan --rate $PPS -v -n -Pn -sS -p1-65535 -iL $IPLIST -e eth0 --output-format list --output-filename $TCPLOG"
MASSCANUDP="masscan --rate $PPS -v -n -pU:1-65535 -iL $IPLIST -e eth0 --output-format list --output-filename $UDPLOG"
MASSCANTCPPATH="masscan --rate $PPS -v -n -Pn -sS -p1-65535 -iL $IPLIST -e eth0 --output-format list --output-filename ${ENGAGEMENTS}${WORKINGDIR}/${TCPLOG}"
MASSCANUDPPATH="masscan --rate $PPS -v -n -pU:1-65535 -iL $IPLIST -e eth0 --output-format list --output-filename ${ENGAGEMENTS}${WORKINGDIR}/${UDPLOG}"

# Perform TCP scan
echo -e "$GREEN[*] ${ORANGE}Beginning TCP scan.$NC";
sleep 0.7;
echo -e "$GREEN[*] ${ORANGE}The following masscan command will be used: $BLUE $MASSCANTCP.";
sleep 0.7;
echo -e "$GREEN[*] ${ORANGE}Log file can be found here: ${ENGAGEMENTS}${WORKINGDIR}/${TCPLOG}.$GREEN";
sleep 0.7;
$MASSCANTCPPATH
echo -e "$GREEN[*] ${ORANGE}TCP scan complete!$NC";
sleep 1;

# Perform UDP scan
echo -e "$GREEN[*] ${ORANGE}Beginning UDP scan.$NC";
sleep 0.7;
echo -e "$GREEN[*] ${ORANGE}The following masscan command will be used: $BLUE $MASSCANUDP.";
sleep 0.7;
echo -e "$GREEN[*] ${ORANGE}Log file can be found here: ${ENGAGEMENTS}${WORKINGDIR}/${UDPLOG}.$GREEN";
sleep 0.7;
$MASSCANUDPPATH
echo -e "$GREEN[*] ${ORANGE}UDP scan complete!$NC";
sleep 1;

# Parse TCP results
# # Get unique hosts
# cat TCP_16:25:57.log | grep -v '#' | cut -d " " -f 4 | sort | uniq > hosts

# # Get unique ports for each host in hosts, save as IPaddress.txt
# for host in $(cat hosts); do
#     cat TCP_16:25:57.log | grep $host | cut -d " " -f 3 | sort | uniq >> ${host}.txt
# done

# # Change newlines to ", ", echo final output to results file, remove old .txt files
# for host in $(cat hosts); do
#     tr '\r\n' ',' < ${host}.txt > ${host}-2.txt;
#     sed 's/,/, /g' ${host}-2.txt > ${host}-3.txt;
#     echo "$host [ $(cat ${host}-3.txt)]" >> results
#     rm ${host}.txt ${host}-2.txt ${host}-3.txt
# done