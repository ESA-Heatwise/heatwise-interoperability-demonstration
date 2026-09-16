#!/bin/env bash
set -xe

SOFTWARE_PATH="./software"
CWL_PATH="./application-packages"
INPUTS_PATH="./inputs"
GIT_REF=${1:-main}

mkdir -p $SOFTWARE_PATH
mkdir -p $INPUTS_PATH
mkdir -p $CWL_PATH

stage_lstm_wp3_products() {
    REPO_BASE="$SOFTWARE_PATH/lstm-wp3-products"
    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/lstm-wp3-products.git "$REPO_BASE"
    PRODUCTS_BASE="$REPO_BASE/products"

    # hotspots
    cp "$PRODUCTS_BASE/hotspots/app/eoap.cwl" "$CWL_PATH/heatwise-hotspots.cwl"
    # inertia
    cp "$PRODUCTS_BASE/inertia/app/eoap.cwl" "$CWL_PATH/heatwise-inertia.cwl"

    # combined urban atlas hotspots materials
    cp "$PRODUCTS_BASE/ua/app/eoap.cwl" "$CWL_PATH/heatwise-combined-hotspots-materials.cwl"


    mkdir -p $INPUTS_PATH/{hotspots,inertia,combined_hotspots_materials}
    cp -r "$PRODUCTS_BASE"/hotspots/inputs/* $INPUTS_PATH/hotspots

    cp -r "$PRODUCTS_BASE"/inertia/inputs/* $INPUTS_PATH/inertia

    cp -r "$PRODUCTS_BASE"/ua/inputs/* $INPUTS_PATH/combined_hotspots_materials
}

stage_hysupp() {
    REPO_BASE=$SOFTWARE_PATH/heatwise-hysupp-unmixing

    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/heatwise-hysupp-unmixing.git "$REPO_BASE"

    # cwl
    cp "$REPO_BASE/heatwise_hysupp_unmixing.cwl" "$CWL_PATH/"


    # inputs
    mkdir -p $INPUTS_PATH/unmixing
    cp -r "$REPO_BASE/data" "$INPUTS_PATH/unmixing/"
}

stage_lcz() {
    PREP_ROOT="$SOFTWARE_PATH/heatwise-hsi-lst-prep"
    PATCH_ROOT="$SOFTWARE_PATH/heatwise-patch-extraction"
    CLASSIFICATION_ROOT="$SOFTWARE_PATH/heatwise-lcz-classification"
    PIPELINE_ROOT="$SOFTWARE_PATH/heatwise-lcz-pipeline"

    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/heatwise-hsi-lst-prep.git $PREP_ROOT
    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/heatwise-patch-extraction.git $PATCH_ROOT
    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/heatwise-lcz-classification.git $CLASSIFICATION_ROOT
    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/heatwise-lcz-pipeline.git $PIPELINE_ROOT

    mkdir -p $INPUTS_PATH/{hsi-lst-prep,patch-extraction,lcz-classification,lcz-pipeline}
    cp $PREP_ROOT/heatwise_hsi_lst_prep.cwl "$CWL_PATH/"
    cp $PATCH_ROOT/heatwise_patch_extraction.cwl "$CWL_PATH/"
    cp $CLASSIFICATION_ROOT/heatwise_lcz_predict.cwl "$CWL_PATH/"
    cp $CLASSIFICATION_ROOT/heatwise_lcz_train.cwl "$CWL_PATH/"
    cwltool --pack $PIPELINE_ROOT/heatwise_pipeline.cwl > "$CWL_PATH/heatwise_pipeline_packed.cwl"

    cp -r $PREP_ROOT/examples/stac_input/* "$INPUTS_PATH/hsi-lst-prep/"
    cp -r $PREP_ROOT/data "$INPUTS_PATH/hsi-lst-prep/"
    cp -r $PATCH_ROOT/data/Berlin "$INPUTS_PATH/patch-extraction/"
    cp -r $CLASSIFICATION_ROOT/data/Berlin "$INPUTS_PATH/lcz-classification/"
    cp -r $PIPELINE_ROOT/data/Berlin_prep "$INPUTS_PATH/lcz-pipeline/"
    cp -r $PIPELINE_ROOT/data/Berlin_labels "$INPUTS_PATH/lcz-pipeline/"
    # cp -r $PIPELINE_ROOT/data/Berlin_labels "$INPUTS_PATH/lcz-pipeline/"
}

clean() {
    rm -rfI "$SOFTWARE_PATH"
    rm -rI "$CWL_PATH"
    rm -rI "$INPUTS_PATH"
}

if [[ $1 == "clean" ]]; then
    clean
else
    stage_lstm_wp3_products
    stage_hysupp
    stage_lcz
fi

