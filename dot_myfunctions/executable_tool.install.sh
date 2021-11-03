#!/bin/sh

# $1 owner 
# $2 repository
# $3 asset name
get_browser_download_url(){  
  download_url=$(curl -sL https://api.github.com/repos/$1/$2/releases/latest | jq -r --arg ASSETNAME "$3" '.assets[] | select(.name==$ASSETNAME) | .browser_download_url')
}

# same as former, but with contains, it is used for dive
get_browser_download_url_like(){
	download_url=$(curl -sL https://api.github.com/repos/$1/$2/releases/latest | jq -r --arg ASSETNAME "$3" '.assets[] | select(.name|contains($ASSETNAME)) | .browser_download_url')
}

# $1 url
# $2 binary name
# $3 dest
download_and_copy(){
  curl -sLo /tmp/$2 $1
  install /tmp/$2 $3
  rm /tmp/$2
}

# $1 url
# $2 binary
# $3 dest
download_and_uncompress_and_copy(){
  wget -P /tmp/ $1
  mkdir -p /tmp/$(echo $1 | md5sum | head -c 10)
  tar -zvxf /tmp/$(basename $1) -C /tmp/$(echo $1 | md5sum | head -c 10)

  install /tmp/$(echo $1 | md5sum | head -c 10)/$2 $3

  rm /tmp/$(basename $1)
  rm -rf /tmp/$(echo $1 | md5sum | head -c 10)
}

dest_folder=~/.local/bin

download_dive(){
  get_browser_download_url_like "wagoodman" "dive" "linux_amd64.tar.gz"
  download_and_uncompress_and_copy $download_url "dive" $dest_folder 
}

download_kind(){
  get_browser_download_url "kubernetes-sigs" "kind" "kind-linux-amd64"
  download_and_copy $download_url kind $dest_folder 
}

download_skaffold(){
  get_browser_download_url "GoogleContainerTools" "skaffold" "skaffold-linux-amd64" 
  download_and_copy $download_url skaffold $dest_folder 
}

download_kubectl(){
  stable_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  download_url=https://dl.k8s.io/release/$stable_version/bin/linux/amd64/kubectl
  download_and_copy $download_url kubectl $dest_folder
}

