# To learn more on https://docs.gitlab.com/ee/api/protected_branches.html

# ENGLISH:
#
# This script runs through the GitLab repositories listed below and puts in each of them, where the protected branch is the master branch,
# the value that developers and maintainers can merge into the master branch, and only maintainers can push to the master
#
# The work of the script was tested on the GitLab version of GitLab Enterprise Edition 15.7.5-ee
# If it’s not clear why it doesn’t work, I suggest temporarily removing the --silent key from curl requests and adding the -v (verbose) key


# RUSSIAN:
#
# Данный скрипт пробегается по нижеперечисленным GitLab репозиториям и проставляет в каждом из них,
# где protected branch указана ветка master, значение что мерджить в мастер ветку могут разработчики и ментейнеры, а пушить в мастер могут только мейнтенеры
#
# Работа скрипта была проверна на гитлабе версии GitLab Enterprise Edition 15.7.5-ee
# Если не понятно почему не работает, предлагаю на время убрать из curl запросов ключ --silent, и добавить ключ -v (verbose)

#----------------

gitlab_domain="gitlab.example.com"
gitlab_group="some-group"
gitlab_token="XXXXXXXXXXXXXXXXX"
gitlab_protected_branch="master"

#----------------

export git_r_1=git@$gitlab_domain:$gitlab_group/repository-1.git
export git_r_2=git@$gitlab_domain:$gitlab_group/repository-2.git
export git_r_3=git@$gitlab_domain:$gitlab_group/repository-3.git
export git_r_4=git@$gitlab_domain:$gitlab_group/repository-4.git
export git_r_5=git@$gitlab_domain:$gitlab_group/repository-5.git
export git_r_6=git@$gitlab_domain:$gitlab_group/repository-6.git
export git_r_7=git@$gitlab_domain:$gitlab_group/repository-7.git
export git_r_8=git@$gitlab_domain:$gitlab_group/repository-8.git
export git_r_9=git@$gitlab_domain:$gitlab_group/repository-9.git
export git_r_10=git@$gitlab_domain:$gitlab_group/repository-10.git
export git_r_11=git@$gitlab_domain:$gitlab_group/repository-11.git
export git_r_12=git@$gitlab_domain:$gitlab_group/repository-12.git
export git_r_13=git@$gitlab_domain:$gitlab_group/repository-13.git
export git_r_14=git@$gitlab_domain:$gitlab_group/repository-14.git
export git_r_15=git@$gitlab_domain:$gitlab_group/repository-15.git
export git_r_16=git@$gitlab_domain:$gitlab_group/repository-16.git
export git_r_17=git@$gitlab_domain:$gitlab_group/repository-17.git
export git_r_18=git@$gitlab_domain:$gitlab_group/repository-18.git
export git_r_19=git@$gitlab_domain:$gitlab_group/repository-19.git
export git_r_20=git@$gitlab_domain:$gitlab_group/repository-20.git
export git_r_21=git@$gitlab_domain:$gitlab_group/repository-21.git
export git_r_22=git@$gitlab_domain:$gitlab_group/repository-22.git
export git_r_23=git@$gitlab_domain:$gitlab_group/repository-23.git
export git_r_24=git@$gitlab_domain:$gitlab_group/repository-24.git

git_spisok=($(env | grep "git_r" | tr '=' ' ' | awk '{print $2}'))

#----------------

for i in "${git_spisok[@]}"
do
repo=$(echo $i | tr '/' ' ' | awk '{print $2}' | tr '.' ' ' | awk '{print $1}')

# получаем id проекта в gitlab
project_id=$(curl --silent -H "Private-Token: ${gitlab_token}" -X GET https://$gitlab_domain/api/v4/projects?search=$repo | jq '.[] | select(.path_with_namespace=="'$gitlab_group'/'$repo'")' | jq '.id')

echo "Project_ID: $project_id --- Repository: $repo"

# находим номера текущих правил, установленных для доступа к мерджу в мастер и для пуша в мастер
id_a1=$(curl --silent -H 'Content-Type: application/json' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch | jq '.merge_access_levels[0].id')
echo id_a1=$id_a1

id_a2=$(curl --silent -H 'Content-Type: application/json' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch | jq '.merge_access_levels[1].id')
echo id_a2=$id_a2

id_a3=$(curl --silent -H 'Content-Type: application/json' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch | jq '.merge_access_levels[2].id')
echo id_a3=$id_a3

id_b1=$(curl --silent -H 'Content-Type: application/json' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch | jq '.push_access_levels[0].id')
echo id_b1=$id_b1

id_b2=$(curl --silent -H 'Content-Type: application/json' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch | jq '.push_access_levels[1].id')
echo id_b2=$id_b2

id_b3=$(curl --silent -H 'Content-Type: application/json' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch | jq '.push_access_levels[2].id')
echo id_b3=$id_b3

# удаляем текущие правила
curl -H 'Content-Type: application/json' --request PATCH \
     --data "{\"allowed_to_merge\": [{\"id\":\"$id_a1\", \"_destroy\": true}]}" \
     -H "Private-Token: ${gitlab_token}" https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

curl -H 'Content-Type: application/json' --request PATCH \
     --data "{\"allowed_to_merge\": [{\"id\":\"$id_a2\", \"_destroy\": true}]}" \
     -H "Private-Token: ${gitlab_token}" https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

curl -H 'Content-Type: application/json' --request PATCH \
     --data "{\"allowed_to_merge\": [{\"id\":\"$id_a3\", \"_destroy\": true}]}" \
     -H "Private-Token: ${gitlab_token}" https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

curl -H 'Content-Type: application/json' --request PATCH \
     --data "{\"allowed_to_push\": [{\"id\":\"$id_b1\", \"_destroy\": true}]}" \
     -H "Private-Token: ${gitlab_token}" https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

curl -H 'Content-Type: application/json' --request PATCH \
     --data "{\"allowed_to_push\": [{\"id\":\"$id_b2\", \"_destroy\": true}]}" \
     -H "Private-Token: ${gitlab_token}" https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

curl -H 'Content-Type: application/json' --request PATCH \
     --data "{\"allowed_to_push\": [{\"id\":\"$id_b3\", \"_destroy\": true}]}" \
     -H "Private-Token: ${gitlab_token}" https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

# создаем новые правила
curl -H 'Content-Type: application/json' --request PATCH \
     --data '{"allowed_to_merge": [{"access_level": 30}]}' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

curl -H 'Content-Type: application/json' --request PATCH \
     --data '{"allowed_to_push": [{"access_level": 40}]}' \
     -H "Private-Token: ${gitlab_token}" \
     https://$gitlab_domain/api/v4/projects/$project_id/protected_branches/$gitlab_protected_branch

done
