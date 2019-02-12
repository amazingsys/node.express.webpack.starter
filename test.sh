#!/bin/bash
###################################
# 프로젝트 이름 입력/ 실행 위치 이동
###################################
# 프로젝트 이름 입력
condition="N"
while [ "${condition}" = "N" ] || [ "${condition}" = "n" ]
do
	echo "Q. What is your project name?"
	read project

	echo "Hello, ${project} developer!"
	echo "Q. 'jovt_${project}' is correct? Answer: Y/N"
	read condition

	# if 이름이 맞다면, 지정 경로로 이동
	# else 프로젝트 이름 재 입력
	if [ "${condition}" = "Y" ] || [ "${condition}" = "y" ]; then
		condition="N"
		while [ "${condition}" = "N" ] || [ "${condition}" = "n" ]
		do
			project_path="V:/kepler/workspace/jovt_${project}"
			echo "Q. ${project_path} 로 이동합니다... Answer: Y/N"
			read condition

			# if 지정경로가 맞지 않다면, 사용자 직접 경로 설정
			# else 지정 경로가 맞다면, 지정 경로로 이동
			if [ "${condition}" != "Y" ] && [ "${condition}" != "y" ]; then
				echo "Q. Please Input project path. ex) V:/"
				read project_path
				echo "Q. '${project_path}' is correct? Answer: Y/N"
				read condition

				# if 직접 경로 설정이 맞지 않다면, 사용자 직접 경로 재 설정
				if [ "${condition}" != "Y" ] && [ "${condition}" != "y" ]; then
					condition="N"
				fi
			else
				condition="N"
			fi
		done
	else
		condition="N"
	fi
done

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

##################################
# today_date: 오늘 날짜
# branch_nm: 현재 브랜치
# previous_tag: 이전 태그/초기 태그
##################################
today_date="$(date +%Y)$(date +%m)$(date +%d)"
branch_nm="$(git symbolic-ref --short HEAD)"
previous_tag="$(git describe --match "${branch_nm}*" --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))"

######################
# 디렉터리 생성
######################
echo "디렉터리 생성 중..."
cd V:/
dir="jovt_${project}_${branch_nm}"
if [ ! -d ${dir} ]; then
    mkdir ${dir}
fi
cd $project_path

recordLog "========================$(date '+%Y-%m-%d %H:%M:%S')========================"
recordLog "!!!!필독!!!!"
recordLog "태그에는 반드시 브랜치명 '${branch_nm}' 이/가 들어가야합니다. ex) ${branch_nm}_${today_date}_패치"
recordLog "--------------------------------------------------------------------------------------------------"

# if 이전 태그가 존재하지 않다면, 로그 기록 후, 로직 종료
# else 이전 태그가 존재한다면, 최종 태그 확인 후, 로직 진행
if [ -z "${previous_tag}" ]; then
	recordLog "!!!!에러!!!!"
	recordLog "이전 태그가 존재하지 않습니다."
	recordLog "'${branch_nm}_초기셋팅' 태그를 생성해 주십시오."
	recordLog " "

	for (( i=0; i<${#log[@]}; i++ ))
	do
	    echo "${log[$i]}" >> V:/"${dir}"/log_${today_date}.txt
	done

	cd V:/"${dir}"/
	start log_${today_date}.txt

	exit
fi

###############################
# current_tag: 최종 태그
# name: 범위를 나타내는 이름 값
###############################
current_tag="$(git describe --tags --abbrev=0 HEAD)"
name="[${previous_tag}]To[${current_tag}]"

#######################
# 패키징 범위 세부 확인
#######################
# if 이전 태그와 최종 태그가 동일한 경우, 최종 태그를 아직 지정하지 않은 상태이므로 공지
# else 이전 태그와 최종 태그가 동일하지 않은 경우, 공지 없이 정상 작동
if [ "${previous_tag}" = "${current_tag}" ]; then
	name="[${previous_tag}]"
	current_tag="$(git describe --tags)"
	echo "범위 : ${previous_tag} ~ 최종 커밋"
	recordLog "!!!!필독!!!!"
	recordLog "패키징이 완료된 후, 반드시 최종 커밋에 '${branch_nm}_${today_date}_패치' 태그를 달아주시기 바랍니다."
else
	echo "범위 : ${previous_tag} ~ ${current_tag}"
	recordLog "* 범위 : ${previous_tag} ~ ${current_tag}"
fi

###########
# 파일 생성
###########
echo "파일 생성 중..."
recordLog "--------------------------------------------------------------------------------------------------"
recordLog "* jovt_${project} 브랜치명: ${branch_nm}"
recordLog "* 태그 범위 : ${previous_tag} ~ 최종 커밋"
recordLog "* 생성 파일"

git archive -o V:/"${dir}"/htdocs_Update_${name}.zip HEAD $(git diff --diff-filter=AMR --name-only ${previous_tag}..${current_tag} -- ':!*etc/*')
recordLog "- htdocs_Update_${name}.zip"
echo "파일 생성 완료..."

######################
# 업데이트 리스트 생성
######################
echo "리스트 생성 중..."
git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' > V:/"${dir}"/update_list_"${name}".txt
recordLog "- update_list_${name}.txt"

##########################
# JAVA 업데이트 리스트 생성
##########################
if [ -n "$(git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' '*.java')" ]; then
	git diff --diff-filter=AMR --name-status ${previous_tag}..${current_tag} -- ':!*etc/*' '*.java' > V:/"${dir}"/update_java_list_"${name}".txt
	recordLog "- update_java_list_${name}.txt (!!!!필독!!!! class 파일 필요)"
fi
recordLog "- log_${today_date}.txt"
recordLog "--------------------------------------------------------------------------------------------------"
recordLog " "
echo "리스트 생성 완료..."

for (( i=0; i<${#log[@]}; i++ ))
do
    echo "${log[$i]}" >> V:/"${dir}"/log_${today_date}.txt
done

##########################
# 파일 생성된 디렉터리 확인
##########################
cd V:/"${dir}"/
start .
start log_${today_date}.txt
#cat log_$(date +%Y)$(date +%m)$(date +%d).txt
#sleep 3s
