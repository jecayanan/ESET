#! /bin/sh

# Unisntall script for ESET Endpoint Antivirus
# (C) 2021 ESET, spol. s r. o.

echo "ESET Endpoint Antivirus Version 6.11.1 Uninstall"
echo "This script will uninstall ESET Endpoint Antivirus 6.11.1."

if [ $EUID -ne 0 ]; then
	echo " "
	echo "Warning: Uninstallation of ESET Endpoint Antivirus 6.11.1 could be made only by user with root privileges!"
	echo " "
	exit 2
fi
echo " "

detectErr=0
function check_single() {
    if read LINE;
    then
        if read END;
        then
            detectErr=1
        else
            echo $LINE
        fi
    else
        detectErr=2
    fi
}

PRODUCT=`find /Applications -maxdepth 1 -type d -exec test -f '{}/Contents/MacOS/esets_daemon' \; -exec test -f '{}/Contents/MacOS/esets_gui' \; -exec codesign --verify -R '=certificate leaf[subject.OU]="P8DQRXPVLP"' '{}' \; -print | check_single | sed 's:^/Applications/::'`

if [ $detectErr -eq 1 ];
    then
        echo 'ERROR: More than one bundle found!' >&2
        exit 1
elif [ $detectErr -eq 0 ];
    then
        if [ -n "$PRODUCT" ];
        then
            echo "Detected product: '$PRODUCT'"
        fi
fi

PRODUCT_SCEP=`find /Applications -maxdepth 1 -type d -exec test -f '{}/Contents/MacOS/scep_daemon' \; -exec test -f '{}/Contents/MacOS/scep_gui' \; -exec codesign --verify -R '=certificate leaf[subject.OU]="P8DQRXPVLP"' '{}' \; -print | check_single | sed 's:^/Applications/::'`

if [ $detectErr -eq 1 ];
    then
        echo 'ERROR: More than one bundle found!' >&2
        exit 1
elif [ $detectErr -eq 0 ];
    then
        if [ -n "$PRODUCT_SCEP" ];
        then
            echo "Detected product: '$PRODUCT_SCEP'"
        fi
fi

if [ -n "$PRODUCT" -a -n "$PRODUCT_SCEP" ];
    then
        echo 'ERROR: Broken installations. $PRODUCT and $PRODUCT_SCEP installed simultaneously! Unistall both and do clean installation.' >&2
        exit 1
fi

if [ -d "/Applications/EAV4.app" ]; then
	echo "Please uninstall the previous EAV4 with the correct uninstaller!"
	exit 1
fi
if [ -d "/Applications/ESET Cybersecurity.app" ]; then
	echo "Please uninstall the ESET Cybersecurity with the correct uninstaller!"
	exit 1
fi
if [ -d "/Applications/ESET NOD32 Antivirus 4.app" ]; then
	echo "Please uninstall the ESET NOD32 Antivirus 4 with the correct uninstaller!"
	exit 1
fi
if [ -d "/Applications/ESET Cybersecurity Suite.app" ]; then
	echo "Please uninstall the ESET Cybersecurity Suite with the correct uninstaller!"
	exit 1
fi
if [ -n "$PRODUCT" ]; then
	dr="/Applications/$PRODUCT/Contents/Helpers/Uninstaller.app/Contents/Scripts"
lg=/tmp/esets_uninstall.log
s="Starting uninstallation procedure using '$0'";
echo $s > $lg; echo $s

tasks=(
	"ut1"
	"ut2"
	"ut_sysext_config"
	"ut3"
	"ut4"
	"ut5"
	"ut6"
	"ut7"
)
uninstall=(
	true
	true 					# ut2
	true					# ut_sysext_config
	true					# ut3
	true					# ut4
	true					# ut5
	true					# ut6
	true					# ut7
)
upgrade=(
	true
	true 					# ut2
	false					# ut_sysext_config
	true					# ut3
	true					# ut4
	true					# ut5
	true					# ut6
	true					# ut7
)
count=${#tasks[@]}

if [ "$1" == "--upgrade" ]; then
	execute=(${upgrade[@]})
else
	execute=(${uninstall[@]})
fi

if [ -d "$dr" ]; then

	for (( i=0; i<$count; i++ ))
	do
		task=${tasks[$i]}
		run=${execute[$i]}

		if [[ $run = true ]]; then
			s="Executing uninstaller tool $task..."
			echo "" >> $lg; echo $s >> $lg; echo $s
			"$dr/../Helpers/$task" 2> /dev/null 1>&2
			rc=$?
			pd=$!
			if [ "$rc" -ne 0 ]; then
				s="ERROR: uninstallation step $task failed! Cannot execute tool '$dr/../Helpers/$task'"
				echo $s >> $lg; echo $s
				exit $rc;
			fi
		else
			s="Skipping uninstaller tool $task"
			echo "" >> $lg; echo $s >> $lg; echo $s
		fi
	done
	s="Uninstallation finished successfully!"
else
	s="Product is not installed or installation is corrupted !"
fi
echo "" >> $lg; echo ""
echo $s >> $lg; echo $s



	unlink "$0"
fi
