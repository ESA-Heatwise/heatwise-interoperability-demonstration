#!/bin/env bash
set -xeuo pipefail

SOFTWARE_PATH="./software"
CWL_PATH="./application-packages"
INPUTS_PATH="./inputs"
GIT_REF=${1:-main}

mkdir -p $SOFTWARE_PATH
mkdir -p $INPUTS_PATH
mkdir -p $CWL_PATH

stage_lstm_wp3_products() {
    local VERSION=${1:-latest}
    local REMOTE_BASE="https://github.com/ESA-Heatwise/lstm-wp3-products"
    local REPO_BASE="$SOFTWARE_PATH/lstm-wp3-products"
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$REPO_BASE"  products/{hotspots,inertia,ua}/inputs
    local PRODUCTS_BASE="$REPO_BASE/products"
    if [[ $VERSION = "latest" ]] then
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/latest/download"
    else
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/download/${VERSION}"
    fi

    # hotspots
    (cd "$CWL_PATH" && fetch "$DOWNLOAD_BASE/heatwise-hotspots.cwl")
    # inertia
    (cd "$CWL_PATH" && fetch "$DOWNLOAD_BASE/heatwise-inertia.cwl")
    # combined urban atlas hotspots materials
    (cd "$CWL_PATH" && fetch "$DOWNLOAD_BASE/heatwise-ua.cwl" && mv "heatwise-ua.cwl" "heatwise-combined-hotspots-materials.cwl")


    mkdir -p $INPUTS_PATH/{hotspots,inertia,combined_hotspots_materials}
    cp -r "$PRODUCTS_BASE"/hotspots/inputs/* "$INPUTS_PATH/hotspots"

    cp -r "$PRODUCTS_BASE"/inertia/inputs/* "$INPUTS_PATH/inertia"

    cp -r "$PRODUCTS_BASE"/ua/inputs/* "$INPUTS_PATH/combined_hotspots_materials"
}

stage_hysupp() {
    local VERSION=${1:-latest}
    local REPO_BASE=$SOFTWARE_PATH/heatwise-hysupp-unmixing
    local REMOTE_BASE=https://github.com/ESA-Heatwise/heatwise-hysupp-unmixing
    if [[ $VERSION = "latest" ]] then
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/latest/download"
    else
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/download/${VERSION}"
    fi

    mkdir -p $INPUTS_PATH/unmixing

    # fetch inputs from repo
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$INPUTS_PATH/unmixing" data/

    # cwl
    (cd $CWL_PATH && fetch "$DOWNLOAD_BASE/heatwise_hysupp_unmixing.cwl")
}

stage_lcz() {
    local VERSION=${1:-latest}
    local PREP_ROOT="$SOFTWARE_PATH/heatwise-hsi-lst-prep"
    local PREP_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-hsi-lst-prep"
    local PATCH_ROOT="$SOFTWARE_PATH/heatwise-patch-extraction"
    local PATCH_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-patch-extraction"
    local CLASSIFICATION_ROOT="$SOFTWARE_PATH/heatwise-lcz-classification"
    local CLASSIFICATION_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-lcz-classification"
    local PIPELINE_ROOT="$SOFTWARE_PATH/heatwise-lcz-pipeline"
    local PIPELINE_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-lcz-pipeline"
    if [[ $VERSION = "latest" ]] then
        local PREP_DOWNLOAD_BASE="$PREP_REMOTE_ROOT/releases/latest/download"
        local PATCH_DOWNLOAD_BASE="$PATCH_REMOTE_ROOT/releases/latest/download"
        local CLASSIFICATION_DOWNLOAD_BASE="$CLASSIFICATION_REMOTE_ROOT/releases/latest/download"
        local PIPELINE_DOWNLOAD_BASE="$PIPELINE_REMOTE_ROOT/releases/latest/download"
    else
        local PREP_DOWNLOAD_BASE="$PREP_REMOTE_ROOT/releases/download/${VERSION}"
        local PATCH_DOWNLOAD_BASE="$PATCH_REMOTE_ROOT/releases/download/${VERSION}"
        local CLASSIFICATION_DOWNLOAD_BASE="$CLASSIFICATION_REMOTE_ROOT/releases/download/${VERSION}"
        local PIPELINE_DOWNLOAD_BASE="$PIPELINE_REMOTE_ROOT/releases/download/${VERSION}"
    fi

    sparse_checkout "$PREP_REMOTE_ROOT.git" "$GIT_REF" "$PREP_ROOT" examples/stac_input data
    sparse_checkout "$PATCH_REMOTE_ROOT.git" "$GIT_REF" "$PATCH_ROOT" data examples
    sparse_checkout "$CLASSIFICATION_REMOTE_ROOT.git" "$GIT_REF" "$CLASSIFICATION_ROOT" data examples
    sparse_checkout "$PIPELINE_REMOTE_ROOT.git" "$GIT_REF" "$PIPELINE_ROOT" data examples

    mkdir -p $INPUTS_PATH/{hsi-lst-prep,patch-extraction,lcz-classification,lcz-pipeline}

    (cd $CWL_PATH && fetch "${PREP_DOWNLOAD_BASE}/heatwise_hsi_lst_prep.cwl")
    (cd $CWL_PATH && fetch "${PATCH_DOWNLOAD_BASE}/heatwise_patch_extraction.cwl")
    (cd $CWL_PATH && fetch "${CLASSIFICATION_DOWNLOAD_BASE}/heatwise_lcz_predict.cwl")
    (cd $CWL_PATH && fetch "${PIPELINE_DOWNLOAD_BASE}/heatwise_pipeline.cwl")

    cp -r $PREP_ROOT/examples/stac_input/* "$INPUTS_PATH/hsi-lst-prep/"
    cp -r $PREP_ROOT/data "$INPUTS_PATH/hsi-lst-prep/"
    cp -r $PATCH_ROOT/data/Berlin "$INPUTS_PATH/patch-extraction/"
    cp -r $CLASSIFICATION_ROOT/data/Berlin "$INPUTS_PATH/lcz-classification/"
    cp -r $PIPELINE_ROOT/data/Berlin_prep "$INPUTS_PATH/lcz-pipeline/"
    cp -r $PIPELINE_ROOT/data/Berlin_labels "$INPUTS_PATH/lcz-pipeline/"
}

stage_pftnc() {
    local VERSION=${1:-latest}
    local REPO_BASE=$SOFTWARE_PATH/heatwise-pftnc
    local REMOTE_BASE=https://github.com/ESA-Heatwise/heatwise-pftnc
    if [[ $VERSION = "latest" ]] then
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/latest/download"
    else
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/download/${VERSION}"
    fi
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$REPO_BASE" input eoap

    (cd "$CWL_PATH" && fetch "${DOWNLOAD_BASE}/pftnc.cwl")

    mkdir -p $INPUTS_PATH/pftnc
    cp -r "$REPO_BASE/input/berlin_muggelsee" "$INPUTS_PATH/pftnc/"
}

stage_class_guided() {
    local VERSION=${1:-latest}
    local REPO_BASE="$SOFTWARE_PATH/heatwise-class-guided"
    local REMOTE_BASE="https://github.com/ESA-Heatwise/heatwise-class-guided"
    if [[ $VERSION = "latest" ]] then
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/latest/download"
    else
        local DOWNLOAD_BASE="$REMOTE_BASE/releases/download/${VERSION}"
    fi
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$REPO_BASE" examples/sepolia

    (cd "$CWL_PATH" && fetch "${DOWNLOAD_BASE}/heatwise_class_guided.cwl")
    cp -r "$REPO_BASE/examples/sepolia" "$INPUTS_PATH/class-guided"

}

# Pre-download all docker images referenced in CWL. Must run after the repo/product-specific tasks
stage_docker_images() {
    XCENGINE_GRAPH_ID="#xce_script"
    for f in "$CWL_PATH"/*.cwl; do
        cwl-docker-extract "$f" || cwl-docker-extract "${f}${XCENGINE_GRAPH_ID}"
    done
}

clean() {
    rm -rfI "$SOFTWARE_PATH"
    rm -rI "$CWL_PATH"
    rm -rI "$INPUTS_PATH"
}

# Sparse checkout a git repository ($1) at a specified branch/tag ($2) to target directory ($3)
# Only the specified files/directories (additional args) are downloaded
#
sparse_checkout() {
    local url=$1 ref=$2 dir=$3; shift 3
    git clone -q --depth 1 --filter=blob:none --no-checkout --branch "$ref" "$url" "$dir"
    git -C "$dir" sparse-checkout set "$@"
    git -C "$dir" checkout -q
}

fetch() {
    curl -O -L -f $@
}

if [[ ${1:-" "} == "clean" ]]; then
    clean
else
    stage_lstm_wp3_products v1.0.0
    stage_hysupp v1.0.0
    stage_lcz v1.0.0
    stage_pftnc v1.0.0
    stage_class_guided v0.3.3
    stage_docker_images
fi

