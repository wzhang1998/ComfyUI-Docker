#!/bin/bash

set -euo pipefail

# Note: the "${BASH_REMATCH[2]}" here is REPO_NAME
# from [https://example.com/somebody/REPO_NAME.git] or [git@example.com:somebody/REPO_NAME.git]
function clone_or_pull () {
    if [[ $1 =~ ^(.*[/:])(.*)(\.git)$ ]] || [[ $1 =~ ^(http.*\/)(.*)$ ]]; then
        echo "${BASH_REMATCH[2]}" ;
        set +e ;
            git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$1" \
                || git -C "${BASH_REMATCH[2]}" pull --ff-only ;
        set -e ;
    else
        echo "[ERROR] Invalid URL: $1" ;
        return 1 ;
    fi ;
}


echo "########################################"
echo "[INFO] Downloading ComfyUI & Manager..."
echo "########################################"

set +e
cd /root
git clone https://github.com/comfyanonymous/ComfyUI.git || git -C "ComfyUI" pull --ff-only
cd /root/ComfyUI
# Using stable version (has a release tag)
git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"
set -e

cd /root/ComfyUI/custom_nodes
clone_or_pull https://github.com/ltdrdata/ComfyUI-Manager.git

clone_or_pull https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
clone_or_pull https://github.com/Fannovel16/comfyui_controlnet_aux.git
clone_or_pull https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
clone_or_pull https://github.com/chflame163/ComfyUI_LayerStyle.git
clone_or_pull https://github.com/shadowcz007/comfyui-mixlab-nodes.git
clone_or_pull https://github.com/yolain/ComfyUI-Easy-Use.git
clone_or_pull https://github.com/AlekPet/ComfyUI_Custom_Nodes_AlekPet.git
clone_or_pull https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
clone_or_pull https://github.com/ZHO-ZHO-ZHO/ComfyUI-BRIA_AI-RMBG.git
clone_or_pull https://github.com/kijai/ComfyUI-DepthAnythingV2.git
clone_or_pull https://github.com/giriss/comfy-image-saver.git
clone_or_pull https://github.com/yiwangsimple/florence_dw.git
clone_or_pull https://github.com/Yanick112/ComfyUI-ToSVG.git
clone_or_pull https://github.com/chrisgoringe/cg-image-filter.git
clone_or_pull https://github.com/rgthree/rgthree-comfy
clone_or_pull https://github.com/yuvraj108c/ComfyUI-Whisper



echo "########################################"
echo "[INFO] Downloading Models..."
echo "########################################"

# Models
cd /root/ComfyUI/models
aria2c \
  --input-file=/runner-scripts/download-models.txt \
  --allow-overwrite=false \
  --auto-file-renaming=false \
  --continue=true \
  --max-connection-per-server=5

# Finish
touch /root/.download-complete
