#!/bin/bash

FPGA_DEVICE=Agilex7
COMPILE_EMULATOR=FALSE
COMPILE_REPORT=FALSE
COMPILE_HARDWARE=FALSE
USE_CPU=FALSE
USE_FPGA=TRUE
MaCh3_Branch=intel_icpx

case $1 in
    emulator)
        COMPILE_EMULATOR=TRUE
        ;;
    report)
        FPGA_DEVICE=/opt/oneapi-asp/ia840f/:ofs_ia840f_usm
        COMPILE_REPORT=TRUE
        ;;
    hardware)
        FPGA_DEVICE=/opt/oneapi-asp/ia840f/:ofs_ia840f_usm
        COMPILE_HARDWARE=TRUE
        ;;
    cpu)
        USE_CPU=TRUE
        USE_FPGA=FALSE
        ;;
    *)
        echo "Missing/unknown parameter, choose from [cpu/emulator/report/hardware]"
        exit 1
        ;;
esac

echo "Build Flags:"
echo "  FPGA_DEVICE: ${FPGA_DEVICE}"
echo "  COMPILE_EMULATOR: ${COMPILE_EMULATOR}"
echo "  COMPILE_REPORT: ${COMPILE_REPORT}"
echo "  COMPILE_HARDWARE: ${COMPILE_HARDWARE}"
echo "  USE_CPU: ${USE_CPU}"
echo "  USE_FPGA: ${USE_FPGA}"

export QUARTUS_ROOTDIR_OVERRIDE=/opt/intelFPGA_pro/23.1.0/quartus/
export LM_LICENSE_FILE=5280@licsrv00.hep.ph.ic.ac.uk

set -e # exit on first error
cd /home/hep/llaatu/mach3/MaCh3Tutorial
rm -rf /home/hep/llaatu/mach3/MaCh3Tutorial/build
mkdir -p /home/hep/llaatu/mach3/MaCh3Tutorial/build


# YAML will not build unless we source the latter ?!
# source /opt/intel/oneapi/setvars.sh --force
. /opt/intel/oneapi/2025.0/oneapi-vars.sh --force

set -x

/usr/bin/cmake \
    -DCMAKE_BUILD_TYPE:STRING=Debug \
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
    -DCMAKE_C_COMPILER:FILEPATH=/opt/intel/oneapi/compiler/2025.0/bin/icx \
    -DCMAKE_RANLIB:FILEPATH=/usr/bin/gcc-ranlib \
    -DCMAKE_AR:FILEPATH=/usr/bin/gcc-ar \
    -DCMAKE_CC_COMPILER:FILEPATH=/opt/intel/oneapi/compiler/2025.0/bin/icx \
    -DCMAKE_CXX_COMPILER:FILEPATH=/opt/intel/oneapi/compiler/2025.0/bin/icpx \
    -DUSE_CPU:BOOL=${USE_CPU} \
    -DUSE_FPGA:BOOL=${USE_FPGA} \
    -DMaCh3_Branch:STRING=${MaCh3_Branch} \
    -DFPGA_DEVICE=${FPGA_DEVICE} \
    -DCOMPILE_EMULATOR:BOOL=${COMPILE_EMULATOR} \
    -DCOMPILE_REPORT:BOOL=${COMPILE_REPORT} \
    -DCOMPILE_HARDWARE:BOOL=${COMPILE_HARDWARE} \
    -DCMAKE_C_FLAGS_DEBUG:STRING="-w -g -O0 -fno-eliminate-unused-debug-types -fp-model=precise" \
    -DCMAKE_CXX_FLAGS_DEBUG:STRING="-w -g -O0 -fno-eliminate-unused-debug-types -fp-model=precise" \
    -DCMAKE_EXE_LINKER_FLAGS:STRING="-qopenmp -fno-eliminate-unused-debug-types -fp-model=precise" \
    --no-warn-unused-cli \
    -S/home/hep/llaatu/mach3/MaCh3Tutorial \
    -B/home/hep/llaatu/mach3/MaCh3Tutorial/build \
    -G "Unix Makefiles"

# Run from within the build dir as spdlog has some relative path somewhere!
cd /home/hep/llaatu/mach3/MaCh3Tutorial/build

make VERBOSE=1 -j18
make install
