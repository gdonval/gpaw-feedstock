#!/bin/bash
# customize.py example found at: https://gitlab.com/gpaw/gpaw/blob/master/customize.py
cat <<EOF> siteconfig.py
compiler = '${CC}'
has_mpi = '$mpi' != 'nompi'

scalapack = has_mpi
fftw = True
elpa = True
blas = True
xc = True
vdwxc = has_mpi

if has_mpi:
    mpicompiler = 'mpicc'
    mpilinker = 'mpicc'
    define_macros += [("GPAW_ASYNC", '1')]
    define_macros += [("GPAW_MPI2", '1')]

if fftw:
    libraries += ['fftw3_omp', 'fftw3']

if elpa:
    if has_mpi:
        libraries += ['elpa_openmp', 'elpa']
    else:
        libraries += ['elpa_onenode_openmp', 'elpa_onenode']
    include_dirs += ['${PREFIX}/include/elpa_openmp', '${PREFIX}/include/elpa']

if scalapack:
    libraries += ['scalapack']
    define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]
    
if blas:
    libraries += ['blas', 'lapack']
    define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]

if xc:
    libraries += ['xc']
    
if vdwxc:
    libvdwxc = True
    libraries += ['vdwxc']

extra_compile_args += ['-fopenmp', '-fopenmp-simd']
extra_link_args += ['-fopenmp', '-fopenmp-simd']
EOF

unset CC
python setup.py build_ext
python -m pip install . --no-deps

mkdir -p "$PREFIX/etc/conda/activate.d"
mkdir -p "$PREFIX/etc/conda/deactivate.d"
for shext in sh csh fish 
do
   cp "$RECIPE_DIR/activate.${shext}" "$PREFIX/etc/conda/activate.d/gpaw-activate.${shext}"
   cp "$RECIPE_DIR/deactivate.${shext}" "$PREFIX/etc/conda/deactivate.d/gpaw-deactivate.${shext}"
done
