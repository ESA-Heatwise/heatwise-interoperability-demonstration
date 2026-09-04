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
    git clone --branch "$GIT_REF" git@github.com:ESA-Heatwise/lstm-wp3-products.git $SOFTWARE_PATH/lstm-wp3-products
    products_base=$SOFTWARE_PATH/lstm-wp3-products/products

    # hotspots
    cp "$products_base/hotspots/app/eoap.cwl" "$CWL_PATH/heatwise-hotspots.cwl"
    # inertia
    cp "$products_base/inertia/app/eoap.cwl" "$CWL_PATH/heatwise-inertia.cwl"

    # combined urban atlas hotspots materials
    cp "$products_base/ua/app/eoap.cwl" "$CWL_PATH/heatwise-combined-hotspots-materials.cwl"


    mkdir -p $INPUTS_PATH/{hotspots,inertia,combined_hotspots_materials}
    cp -r "$products_base"/hotspots/inputs/* $INPUTS_PATH/hotspots

    cp -r "$products_base"/inertia/inputs/* $INPUTS_PATH/inertia

    cp -r "$products_base"/ua/inputs/* $INPUTS_PATH/combined_hotspots_materials
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
fi

