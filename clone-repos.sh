#!/bin/bash

# Ghi đè cấu hình để Git nhận diện Token cá nhân của bạn thay vì token mặc định của Codespace
sudo sed -i -E 's/helper =.*//' /etc/gitconfig
git config --global credential.helper '!f() { sleep 1; echo "username=${GITHUB_USER}"; echo "password=${GH_TOKEN}"; }; f'

# Di chuyển ra thư mục không gian làm việc chung và tiến hành clone
cd /workspaces
while IFS= read -r repo || [ -n "$repo" ]; do
    if [ ! -z "$repo" ]; then
        echo "Đang tải repository: $repo"
        git clone https://github.com/$repo.git
    fi
done < /workspaces/autovsf/repos-to-clone.list