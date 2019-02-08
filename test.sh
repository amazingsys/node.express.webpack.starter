#!/bin/bash

#echo What is your project name?

#read project

#project_path="V:/kepler/workspace/jovt_$project"
#echo $project_path
#cd $project_path

#echo Hello, $project developer!
declare -a log
index=0
today_date="$(date +%Y)$(date +%m)$(date +%d)"
log[${index}]="=======================${today_date}======================="
let "index+=1"

branch_nm="$(git symbolic-ref --short HEAD)"
previous_tag="$(git describe --match "${branch_nm}*" --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"
if [ -z "${previous_tag}" ]; then
	log[${index}]="이전 태그가 존재하지 않습니다."
	let "index+=1"
	log[${index}]="${branch_nm}_초기셋팅 태그를 생성해 주십시오."
	let "index+=1"
	log[${index}]="----------------------------------------------------------------------------------"
	let "index+=1"
	#sleep 5s
	exit
fi

current_tag="$(git describe --tags --abbrev=0 HEAD)"
log[${index}]="현재 branch 이름은 ${branch_nm} 입니다."
let "index+=1"
log[${index}]="----------------------------------------------------------------------------------"
let "index+=1"
#echo ${previous_tag}
#echo ${current_tag}

name="[${previous_tag}]To[${current_tag}]"
if [ "${previous_tag}" = "${current_tag}" ]; then
	name="[${previous_tag}]"
	current_tag="$(git describe --tags)"
	log[${index}]="범위 : ${previous_tag} ~ 최종 커밋"
	let "index+=1"
	log[${index}]="!!!!필독!!!!"
	let "index+=1"
	log[${index}]="패키징이 완료된 후, 반드시 ${branch_nm}_$(date +%Y)$(date +%m)$(date +%d)_패치 태그를 달아주시기 바랍니다."
	let "index+=1"
	log[${index}]=""
	let "index+=1"
	#sleep 3s
else
	log[${index}]="범위 : ${previous_tag} ~ ${current_tag}"
	let "index+=1"
fi

log[${index}]="----------------------------------------------------------------------------------"
let "index+=1"
log[${index}]="생성 파일"
let "index+=1"

git archive -o V:/htdocs_Update_${name}.zip HEAD $(git diff --diff-filter=AMR --name-only ${previous_tag}..${current_tag} -- ':!*etc/*')
log[${index}]="- htdocs_Update_${name}.zip"
let "index+=1"

git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' > V:/update_list_"${name}".txt
log[${index}]="- update_list_${name}.txt"
let "index+=1"

if [ -n "$(git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' '*.java')" ]; then
	git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' '*.java' > V:/update_java_list_"${name}".txt
	log[${index}]="- update_java_list_${name}.txt"
	let "index+=1"
fi

log[${index}]="- log_${name}.txt"
let "index+=1"
log[${index}]="----------------------------------------------------------------------------------"
let "index+=1"
log[${index}]=" "

for (( i=0; i<${#log[@]}; i++ ))
do
    echo "${log[$i]}" >> V:/log_${today_date}.txt
done

cd V:/
start .
start log_${today_date}.txt
#cat log_$(date +%Y)$(date +%m)$(date +%d).txt
#sleep 3s 