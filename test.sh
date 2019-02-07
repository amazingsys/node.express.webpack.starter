#!/bin/bash

#echo What is your project name?

#read project

#project_path="V:/kepler/workspace/jovt_$project"
#echo $project_path
#cd $project_path

#echo Hello, $project developer!

branch_nm="$(git symbolic-ref --short HEAD)"
previous_tag="$(git describe --match "${branch_nm}*" --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"
if [ -z "${previous_tag}" ]; then
	echo "이전 태그가 존재하지 않습니다."
	echo "${branch_nm}_초기셋팅 태그를 생성해 주십시오."
	echo "--------------------------------------"

	sleep 5s
	exit
fi
current_tag="$(git describe --tags --abbrev=0 HEAD)"
echo "현재 branch 이름은 ${branch_nm} 입니다."
echo "--------------------------------------"
#echo ${previous_tag}
#echo ${current_tag}

name="[${previous_tag}]To[${current_tag}]"
if [ "${previous_tag}" = "${current_tag}" ]; then
	name="[${previous_tag}]"
	current_tag="$(git describe --tags)"
	echo "범위 : ${previous_tag} ~ 최종 커밋"
	echo "!!!!필독!!!!"
	echo "패키징이 완료된 후, 반드시 ${branch_nm}_$(date +%Y)$(date +%m)$(date +%d)_패치 태그를 달아주시기 바랍니다."
	echo ""
	sleep 3s
else
	echo "범위 : ${previous_tag} ~ ${current_tag}"
fi
git archive -o V:/htdocs_Update_${name}.zip HEAD $(git diff --diff-filter=AMR --name-only ${previous_tag}..${current_tag} -- ':!*etc/*')

git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' >> V:/update_list_"${name}".txt

git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' '*.java' >> V:/update_java_list_"${name}".txt

echo "======================================"
echo "생성 파일"
echo "1. htdocs_Update_${name}.zip"
echo "2. update_list_${name}.txt"
echo "3. update_java_list_${name}.txt"
echo "======================================"
echo "생성된 파일은 패치 이후, 삭제 해 주시기 바랍니다."

cd V:/
start .
sleep 3s 