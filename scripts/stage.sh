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
    VERSION=${1:-latest}
    REMOTE_BASE="https://github.com/ESA-Heatwise/lstm-wp3-products"
    REPO_BASE="$SOFTWARE_PATH/lstm-wp3-products"
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$REPO_BASE"  products/{hotspots,inertia,ua}/inputs
    PRODUCTS_BASE="$REPO_BASE/products"
    RELEASES_BASE="$REMOTE_BASE/releases/latest"

    # hotspots
    (cd "$CWL_PATH" && fetch "$REMOTE_BASE/releases/${VERSION}/download/heatwise-hotspots.cwl")
    # inertia
    (cd "$CWL_PATH" && fetch "$REMOTE_BASE/releases/${VERSION}/download/heatwise-inertia.cwl")
    # combined urban atlas hotspots materials
    fetch "$REMOTE_BASE/releases/${VERSION}/download/heatwise-ua.cwl" -o "$CWL_PATH/heatwise-combined-hotspots-materials.cwl"


    mkdir -p $INPUTS_PATH/{hotspots,inertia,combined_hotspots_materials}
    cp -r "$PRODUCTS_BASE"/hotspots/inputs/* $INPUTS_PATH/hotspots

    cp -r "$PRODUCTS_BASE"/inertia/inputs/* $INPUTS_PATH/inertia

    cp -r "$PRODUCTS_BASE"/ua/inputs/* $INPUTS_PATH/combined_hotspots_materials
}

stage_hysupp() {
    VERSION=${1:-latest}
    REPO_BASE=$SOFTWARE_PATH/heatwise-hysupp-unmixing
    REMOTE_BASE=https://github.com/ESA-Heatwise/heatwise-hysupp-unmixing

    mkdir -p $INPUTS_PATH/unmixing

    # fetch inputs from repo
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$INPUTS_PATH/unmixing" data/

    # cwl
    (cd $CWL_PATH && fetch "$REMOTE_BASE/releases/${VERSION}/download/heatwise_hysupp_unmixing.cwl")
}

stage_lcz() {
    VERSION=${1:-latest}
    PREP_ROOT="$SOFTWARE_PATH/heatwise-hsi-lst-prep"
    PREP_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-hsi-lst-prep"
    PATCH_ROOT="$SOFTWARE_PATH/heatwise-patch-extraction"
    PATCH_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-patch-extraction"
    CLASSIFICATION_ROOT="$SOFTWARE_PATH/heatwise-lcz-classification"
    CLASSIFICATION_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-lcz-classification"
    PIPELINE_ROOT="$SOFTWARE_PATH/heatwise-lcz-pipeline"
    PIPELINE_REMOTE_ROOT="https://github.com/ESA-Heatwise/heatwise-lcz-pipeline"

    sparse_checkout "$PREP_REMOTE_ROOT.git" "$GIT_REF" "$PREP_ROOT" examples/stac_input data
    sparse_checkout "$PATCH_REMOTE_ROOT.git" "$GIT_REF" "$PATCH_ROOT" data
    sparse_checkout "$CLASSIFICATION_REMOTE_ROOT.git" "$GIT_REF" "$CLASSIFICATION_ROOT" data
    sparse_checkout "$PIPELINE_REMOTE_ROOT.git" "$GIT_REF" "$PIPELINE_ROOT" data

    mkdir -p $INPUTS_PATH/{hsi-lst-prep,patch-extraction,lcz-classification,lcz-pipeline}

    (cd $CWL_PATH && fetch "$PREP_REMOTE_ROOT/releases/$VERSION/download/heatwise_hsi_lst_prep.cwl")
    (cd $CWL_PATH && fetch "$PATCH_REMOTE_ROOT/releases/$VERSION/download/heatwise_patch_extraction.cwl")
    (cd $CWL_PATH && fetch "$CLASSIFICATION_REMOTE_ROOT/releases/$VERSION/download/heatwise_lcz_predict.cwl")
    (cd $CWL_PATH && fetch "$PIPELINE_REMOTE_ROOT/releases/$VERSION/download/heatwise_pipeline_packed.cwl")

    cp -r $PREP_ROOT/examples/stac_input/* "$INPUTS_PATH/hsi-lst-prep/"
    cp -r $PREP_ROOT/data "$INPUTS_PATH/hsi-lst-prep/"
    cp -r $PATCH_ROOT/data/Berlin "$INPUTS_PATH/patch-extraction/"
    cp -r $CLASSIFICATION_ROOT/data/Berlin "$INPUTS_PATH/lcz-classification/"
    cp -r $PIPELINE_ROOT/data/Berlin_prep "$INPUTS_PATH/lcz-pipeline/"
    cp -r $PIPELINE_ROOT/data/Berlin_labels "$INPUTS_PATH/lcz-pipeline/"
}

stage_pftnc() {
    VERSION=${1:-latest}
    REPO_BASE=$SOFTWARE_PATH/heatwise-pftnc
    REMOTE_BASE=https://github.com/ESA-Heatwise/heatwise-pftnc
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$REPO_BASE" input

    (cd "$CWL_PATH" && fetch "$REMOTE_BASE/releases/$VERSION/download/pftnc.cwl")

    mkdir -p $INPUTS_PATH/pftnc
    cp -r "$REPO_BASE/input/berlin_muggelsee" "$INPUTS_PATH/pftnc/"
}

stage_class_guided() {
    VERSION=${1:-latest}
    REPO_BASE="$SOFTWARE_PATH/heatwise-class-guided"
    REMOTE_BASE="https://github.com/ESA-Heatwise/heatwise-class-guided"
    sparse_checkout "$REMOTE_BASE.git" "$GIT_REF" "$REPO_BASE" examples/sepolia

    (cd "$CWL_PATH" && fetch "$REMOTE_BASE/releases/$VERSION/download/heatwise-class-guided.cwl")
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
    stage_lstm_wp3_products
    stage_hysupp
    stage_lcz
    stage_pftnc
    stage_docker_images
fi

