checklist=()
branch=''
branchSettingsLine=''
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function readChecklist()
{
    checklist=()
    declare -i index=0
    while IFS= read -r line
    do
        if [[ $line == '#'* ]]; 
        then
            checklist[index]=$(echo $line | sed 's/#//1')
            index=$((index+1))
        fi
    done < "./checklistConfig.txt"
}

function getBranch {
    cd $SCRIPTPATH
    gitPath=$(cat checklistConfig.txt | grep gitPath= | awk 'BEGIN{FS="="} {print $2}')
    cd $gitPath
    branch=$(git rev-parse --abbrev-ref HEAD)
    cd $SCRIPTPATH
    branchSettingsLine="$(cat checklistConfig.txt | grep "${branch}")"
    progress=0
    if [[ $branchSettingsLine == '' ]] 
    then 
        echo "${branch}=0" >> checklistConfig.txt
    else
        progress=$(echo $branchSettingsLine | awk 'BEGIN{FS="="} {print $2}')
    fi

    readChecklist

    declare -i index=${#checklist[@]}
    isChecked=()

    while (( index > 0 ))
    do 
        index=$((index-1))
        itemValue=$(echo "2^${index}" | bc)
        if (( progress >= $itemValue ))
        then
            isChecked[index]=true
            progress=$((progress-itemValue))
        else
            isChecked[index]=false
        fi
    done

    optionString=''

    for i in "${!checklist[@]}"
    do
        onOff='off'
        if [[ ${isChecked[$i]} == true ]]
        then onOff='on'
        fi
        optionString="$optionString $((i+1)) \"${checklist[$i]}\" \"$onOff\""
    done
}

function refresh {
    getBranch
    checklistCommandString="dialog --ok-label \"Save\" --cancel-label \"Refresh\" --checklist --output-fd 1 \"${branch}\" 40 60 ${#checklist[@]} ${optionString}"
    option=$(eval $checklistCommandString)

    exitstatus=$?
    if [ $exitstatus = 0 ]
    then
        newSaveValue=0
        for selectedItem in $option
        do
            newSaveValue=$(($newSaveValue+$(echo "2^(${selectedItem}-1)" | bc)))
        done
        echo $newSaveValue
        cd $SCRIPTPATH
        sed -i .bak "s:${branchSettingsLine}:${branch}=${newSaveValue}:g" checklistConfig.txt
        refresh
    else
        refresh
    fi
}

cd /Users/umutsahin/
refresh