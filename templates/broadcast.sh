vCPU=$(cat /proc/cpuinfo | grep processor | wc -l)
CPU=$(cat /proc/cpuinfo | grep cpu\ cores | uniq | awk '{print $4}')
CPU_LOAD=$(cat /proc/stat |grep cpu |tail -1|awk '{print ($5*100)/($2+$3+$4+$5+$6+$7+$8+$9+$10)}'| awk '{print 100-$1}' | awk '{printf("%d\n",$1 + 0.5)}')

OS_KERNEL_RELASE=$(uname -r)
OS_KERNEL_NAME=$(uname -s)
OS_KERNEL_VERSION=$(uname -v)
OS_RELEASE=$(lsb_release -d | cut -f 2-)
OS_NAME=$(uname -o)
MACHINE=$(uname -m)

HOSTNAME=$(uname -n)

UPTIME=$(uptime -p)
UPTIME_SINCE=$(uptime -s)

IP_ADDRESS=$(/sbin/ifconfig enp0s6 | grep 'inet ' | awk '{print $2}')
MAC_ADDRESS=$(/sbin/ifconfig enp0s6 | grep 'ether' | awk '{print $2}')

MEM_TOTAL=$(($(free | grep 'Mem:' | awk '{print $2}')/1024))
MEM_USED=$(($(free | grep 'Mem:' | awk '{print $3}')/1024))
MEM_FREE=$(($(free | grep 'Mem:' | awk '{print $4}')/1024))
MEM_PERC=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | awk '{printf("%d\n",$1 + 0.5)}')

DISK_TOTAL=$(lsblk | grep "^sda"  | awk '{print $4}' | rev | cut -c2- | rev)
DISK_TOTAL_MB=$(echo "scale=2;$DISK_TOTAL*1024" | bc | awk '{printf("%d\n",$1 + 0.5)}')
DISK_USED_MB=$(df -Bm | awk '{ sum += $3 } END { print sum }')
DISK_USED_PERC=$(echo "scale=10;( 100 / $DISK_TOTAL_MB) * $DISK_USED_MB" | bc | awk '{printf("%d\n",$1 + 0.5)}')

NET_EST=$(netstat -s | grep 'connections established' | awk '{print $1}')
NET_ACTIVE=$(netstat -s | grep 'active connection openings' | awk '{print $1}')
UFW_OPEN=$(ufw status | grep -o -i ALLOW | wc -l)
ACTIVE_USERS=$(who | cut -d " " -f 1 | sort -u | wc -l)

SUDO_ACTIONS=$(grep sudo /var/log/auth.log | grep 'sudo:' | wc -l)

if $(cat /etc/fstab | grep -q /dev/mapper/)
then
	LVM="IN USE"
else
  LVM="N/A"
fi

TIME=$(date +"%T")
HOUR=$(date +"%H")

if [ $HOUR -eq 01 ] || [ $HOUR -eq 13 ]
then
  TIME_WORD="Uno"
fi
if [ $HOUR -eq 02 ] || [ $HOUR -eq 14 ]
then
  TIME_WORD="Dos"
fi
if [ $HOUR -eq 03 ] || [ $HOUR -eq 15 ]
then
  TIME_WORD="Tres"
fi
if [ $HOUR -eq 04 ] || [ $HOUR -eq 16 ]
then
  TIME_WORD="Cuatro"
fi
if [ $HOUR -eq 05 ] || [ $HOUR -eq 17 ]
then
  TIME_WORD="Cinco"
fi
if [ $HOUR -eq 06 ] || [ $HOUR -eq 18 ]
then
  TIME_WORD="Seis"
fi
if [ $HOUR -eq 07 ] || [ $HOUR -eq 19 ] 
then
  TIME_WORD="Siete"
fi
if [ $HOUR -eq 08 ] || [ $HOUR -eq 20 ]
then
  TIME_WORD="Ocho"
fi
if [ $HOUR -eq 09 ] || [ $HOUR -eq 21 ]
then
  TIME_WORD='Nueve'
fi
if [ $HOUR -eq 10 ] || [ $HOUR -eq 22 ]
then
  TIME_WORD="Diez"
fi
if [ $HOUR -eq 11 ] || [ $HOUR -eq 23 ]
then
  TIME_WORD="Once"
fi
if [ $HOUR -eq 12 ] || [ $HOUR -eq 00 ]
then
  TIME_WORD="Doce"
fi

if [ $HOUR -gt 12 ]
then
  BROADCAST_TEXT='"Radio reloj '$TIME_WORD' de la mañana No todo lo que es oro brilla." - Manu Chao'
else
  BROADCAST_TEXT='"Radio reloj '$TIME_WORD' de la madrugada No todo lo que es oro brilla." - Manu Chao'
fi

wall -n "
BROADCAST MESSAGE
-----------------

    $BROADCAST_TEXT

TIME            $TIME UTC
HOSTNAME        $HOSTNAME

IP ADDRESS      $IP_ADDRESS
MAC ADDRESS     $MAC_ADDRESS

USERS ACTIVE    $ACTIVE_USERS
SUDO COMMANDS   $SUDO_ACTIONS

OPEN PORTS      $UFW_OPEN
CONNECTIONS     $NET_ACTIVE
ESTABLISHED     $NET_EST

OS              $OS_RELEASE 
BUILD FOR       $MACHINE
KERNEL          $OS_KERNEL_NAME
  VERSION       $OS_KERNEL_VERSION 
  RELASE        $OS_KERNEL_RELASE

UPTIME          $UPTIME
  LAST START    $UPTIME_SINCE

CPU CORES       $CPU
vCPU(S)         $vCPU
LOAD            $CPU_LOAD %

MEMORY          $MEM_TOTAL MB
  FREE          $MEM_FREE MB
  USED          $MEM_USED MB ($MEM_PERC%)

LVM             $LVM
DISK TOTAL      $DISK_TOTAL_MB MB
  IN USE        $DISK_USED_MB MB ($DISK_USED_PERC%)

--------------
END OF MESSAGE
"