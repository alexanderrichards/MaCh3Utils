#!/bin/bash

export QUARTUS_ROOTDIR_OVERRIDE=/opt/intelFPGA_pro/23.1.0/quartus/
export LM_LICENSE_FILE=5280@licsrv00.hep.ph.ic.ac.uk

CORE_BUILD_DIR="${1:-./build}"
TUTORIAL_BUILD_DIR="${2:-./build}"

. /opt/intel/oneapi/2025.0/oneapi-vars.sh --force
. ${CORE_BUILD_DIR}/bin/setup.MaCh3.sh
. ${TUTORIAL_BUILD_DIR}/bin/setup.MaCh3Tutorial.sh

cd ${TUTORIAL_BUILD_DIR}

# create the Test.root file
#./bin/MCMCTutorial Inputs/ManagerTest.yaml
#./bin/MCMCTutorial TutorialConfigs/FitterConfig.yaml
MCMCTutorial TutorialConfigs/FitterConfig.yaml

# process it ?
#./bin/ProcessMCMC ./bin/TutorialDiagConfig.yaml ./Test.root
#./bin/ProcessMCMC bin/TutorialDiagConfig.yaml Test.root
ProcessMCMC bin/TutorialDiagConfig.yaml Test.root

# validate
#./Apps/SplineValidations
SplineValidations