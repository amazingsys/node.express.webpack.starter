#!/bin/bash

function question(){
	#https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
	Blue='\033[0;35m'
	Green='\033[0;32m'
	Color_Off='\033[0m'
	local context=$1
	echo -e "${Green}${context}${Color_Off}"
}
###################################
# 프로젝트 이름 입력/ 실행 위치 이동
###################################
# 프로젝트 이름 입력
condition="N"
while [ "${condition}" = "N" ] || [ "${condition}" = "n" ]
do
	question "Q. 프로젝트 명을 입력하세요. ex)hdmf"
	read project

	echo ""
	echo "Hello, ${project} developer!"
	echo ""

	question "Q. 'jovt_${project}' 가 맞습니까? Answer: Y/N"
	read condition

	# if 이름이 맞다면, 지정 경로로 이동
	# else 프로젝트 이름 재 입력
	if [ "${condition}" = "Y" ] || [ "${condition}" = "y" ]; then
		condition="N"
		while [ "${condition}" != "Y" ] && [ "${condition}" != "y" ]
		do
			project_path="V:/kepler/workspace/jovt_${project}"
			question "Q. ${project_path} 로 이동할까요? Answer: Y/N"
			read condition

			# if 지정경로가 맞지 않다면, 사용자 직접 경로 설정
			# else 지정 경로가 맞다면, 지정 경로로 이동
			if [ "${condition}" != "Y" ] && [ "${condition}" != "y" ]; then
				question "Q. 이동할 path를 입력해 주세요."
				read -r temp_project_path
				project_path=$(echo ${temp_project_path}| sed -e "s/\\\/\//g")

				question "Q. '${project_path}' 경로가 확실합니까? Answer: Y/N"
				read condition

				# if 직접 경로 설정이 맞지 않다면, 사용자 직접 경로 재 설정
				if [ "${condition}" = "Y" ] || [ "${condition}" = "y" ]; then
					condition="Y"
				fi
			else
				condition="Y"
			fi
		done
	else
		condition="N"
	fi
done
echo ${project_path}
cd ${project_path}

##################################
# today_date: 오늘 날짜
# branch_nm: 현재 브랜치
# previous_tag: 이전 태그/초기 태그
##################################
today_date="$(date +%Y)$(date +%m)$(date +%d)"
branch_nm="$(git symbolic-ref --short HEAD)"
#branch_nm="농협"
previous_tag="$(git describe --match "${branch_nm}*" --abbrev=0 --tags)"
######################
# 디렉터리 생성
######################
echo "디렉터리 생성 중..."
cd V:/
if [ ! -d .patch ]; then
    mkdir .patch
fi

cd V:/.patch
tran_project=$(echo $project | tr '[a-z]' '[A-Z]')
dir="JOVT_${tran_project}_${today_date}"
if [ ! -d ${dir} ]; then
    mkdir ${dir}
fi
cd $project_path

#################
# 로그 관련 소스
#################
declare -a log
index=0
function recordLog(){
	local context=$1
	log[${index}]=${context}
	let "index+=1"
}
#################
# 결과 관련 함수
#################
function outputLog(){
	for (( i=0; i<${#log[@]}; i++ ))
	do
	    echo "${log[$i]}" >> V:/.patch/"${dir}"/readMe.txt
	done

	##########################
	# 파일 생성된 디렉터리 확인
	# 압축된 파일 풀기
	##########################
	cd V:/.patch/"${dir}"/
		if [ -e "2.htdocs_Update_class_list.txt" ]; then
		unzip htdocs_Update_${name}.zip -d htdocs_Update_${name}
		rm -R -f htdocs_Update_${name}.zip
	fi

	start .
	start readMe.txt
}
name="${branch_nm}_${today_date}_패치"
recordLog "========================$(date '+%Y-%m-%d %H:%M:%S')========================"
#recordLog "!!!!필독!!!!"
recordLog "태그에는 브랜치명 '${branch_nm}' 이/가 들어가야합니다. ex) ${name}"
recordLog "--------------------------------------------------------------------------------------------------"

# if 태그가 존재하지 않다면, 로그 기록 후, 로직 종료
# if 이전 태그가 존재하지 않다면, 로그 기록 후, 로직 종료
# if 최종 태그가 최종 커밋내역인 경우, 로그 기록 후, 로직 종료
if [ -z $(git tag -l *${branch_nm}*) ]; then # TODO: 현재 브랜치에서의 tag 존재 유무 판단해야함
	echo "태그가 존재하지 않습니다."
	recordLog "!!!!에러!!!!"
	recordLog "태그가 존재하지 않습니다."
	recordLog " "

	outputLog
	exit
fi
if [ -z "${previous_tag}" ]; then
	recordLog "!!!!에러!!!!"
	recordLog "이전 태그가 존재하지 않습니다."
	recordLog "'${branch_nm}_초기셋팅' 태그를 생성해 주십시오."
	recordLog " "

	outputLog
	exit
fi
###############################지울곳
# last_commit: 최종 커밋
# ex) last commit: 현대해상_20190214_패치-6-g32e9253b7
# ex) previous_tag: 현대해상_20190214_패치
###############################
last_commit="$(git describe --tags HEAD)"

if [ "${previous_tag}" = "${last_commit}" ]; then
	recordLog "!!!!에러!!!!"
	recordLog "마지막 태그 이후 커밋된 이력이 없습니다."
	recordLog "최종 커밋: ${last_commit}"
	recordLog " "

	outputLog
	exit
fi

	echo "범위 : ${previous_tag} ~ 최종 커밋"
	recordLog "* 패치 범위 : ${previous_tag} ~ 최종 커밋"

###########
# 파일 생성
###########
echo "파일 생성 중..."
recordLog "--------------------------------------------------------------------------------------------------"
recordLog "* jovt_${project} 브랜치명: ${branch_nm}"
recordLog "* 생성 파일"
git archive -o V:/.patch/"${dir}"/htdocs_Update_${name}.zip HEAD $(git diff --diff-filter=AMR --name-only ${previous_tag} -- ':!*etc/*' ':!.gitignore')

recordLog "- htdocs_Update_${name}"
echo "파일 생성 완료..."

######################
# 업데이트 리스트 생성
######################
echo "리스트 생성 중..."
(git diff --diff-filter=AMR --name-only ${previous_tag} -- ':!*etc/*' ':!.gitignore') > V:/.patch/"${dir}"/1.htdocs_Update_list.txt
recordLog "1. htdocs_Update_list.txt"
##########################
# JAVA 업데이트 리스트 생성
##########################
if [ -n "$(git diff --diff-filter=AMR --name-only ${previous_tag} -- ':!*etc/*' '*.java')" ]; then
	(git diff --diff-filter=AMR --name-only ${previous_tag} -- ':!*etc/*' '*.java') | sed -e "s,htdocs,${project_path}\/htdocs,g" | sed -e "s/\//\\\/g" | sed -e "s/java/class/g" | sed -e "s/src/classes/g" > V:/.patch/"${dir}"/2.htdocs_Update_class_list.txt
	#(git diff --diff-filter=AMR --name-only ${previous_tag} -- ':!*etc/*' '*.java') | sed -e "s/java/class/g" | sed -e "s/src/classes/g" > V:/.patch/"${dir}"/htdocs_Update_class_list_for_git.txt
	recordLog "2. htdocs_Update_class_list.txt (!!!!필독!!!! class 파일 필요)"
fi

############################
# SCHEMA 업데이트 리스트 생성
############################
if [ -n "$(git diff --diff-filter=AMR --name-only ${previous_tag} -- '*etc/*')" ]; then
	(git diff --diff-filter=AMR --name-only ${previous_tag} -- '*etc/*') > V:/.patch/"${dir}"/3.schema_Update_list.txt
	recordLog "3. schema_Update_list.txt"
fi
recordLog "- readMe.txt"
recordLog "--------------------------------------------------------------------------------------------------"
recordLog " "
echo "리스트 생성 완료..."

outputLog
