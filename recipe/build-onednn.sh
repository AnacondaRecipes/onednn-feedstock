#!/bin/bash

set -exuo pipefail

if [[ "${target_platform}" == "linux-64" ]]; then
  export LDFLAGS="-lrt ${LDFLAGS}"
fi

CMAKE_ARGS="${CMAKE_ARGS:-} -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib"
if [[ "${target_platform}" == "osx-64" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
fi

mkdir build-${dnnl_cpu_runtime}
pushd build-${dnnl_cpu_runtime}

if [[ "${dnnl_cpu_runtime}" == "tbb" ]]; then
  export TBBROOT=${PREFIX}
  DNNL_CPU_RUNTIME="TBB"
elif [[ "${dnnl_cpu_runtime}" == "omp" ]]; then
  DNNL_CPU_RUNTIME="OMP"
elif [[ "${dnnl_cpu_runtime}" == "threadpool" ]]; then
  DNNL_CPU_RUNTIME="THREADPOOL"
fi
cmake ${CMAKE_ARGS} -GNinja \
  -DDNNL_CPU_RUNTIME=${DNNL_CPU_RUNTIME} \
  -DDNNL_GPU_RUNTIME=NONE \
  ..
ninja install
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != 1 ]]; then
  ninja test
fi
popd
