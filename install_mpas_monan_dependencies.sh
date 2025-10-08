#!/usr/bin/env bash
#
# Script de Instalação das Dependências MPAS/MONAN
# http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/ 
#
# Compatível com MPAS 8.x e MONAN 1.4x
# Testado com compiladores GNU
#

set -e

# Diretórios de instalação
export LIBSRC=${LIBSRC:-$HOME/lib_repo}
export LIBBASE=${LIBBASE:-$HOME/libs}
export GRIB2DIR=${GRIB2DIR:-$LIBBASE/grib2}

echo "=========================================="
echo " Instalação das Dependências MPAS/MONAN"
echo "=========================================="
echo "Diretório de fontes: $LIBSRC"
echo "Diretório de instalação: $LIBBASE"
echo "Diretório GRIB2: $GRIB2DIR"
echo ""

# Criar diretórios
mkdir -p $LIBSRC
mkdir -p $LIBBASE
mkdir -p $GRIB2DIR

# Verificar dependências do sistema
echo "Verificando dependências do sistema..."
required_tools=("wget" "tar" "gcc" "gfortran" "g++" "make" "git" "python3" "pip3")
missing_tools=()

for tool in "${required_tools[@]}"; do
    if ! command -v $tool &> /dev/null; then
        missing_tools+=($tool)
    fi
done

if [ ${#missing_tools[@]} -ne 0 ]; then
    echo "ERRO: Ferramentas necessárias não encontradas: ${missing_tools[*]}"
    echo ""
    echo "Para instalar no Ubuntu/Debian:"
    echo "sudo apt-get install wget tar gcc gfortran g++ make cmake git python3 python3-pip"
    echo ""
    echo "Para instalar no CentOS/RHEL:"
    echo "sudo yum install wget tar gcc gfortran gcc-c++ make cmake git python3 python3-pip"
    echo ""
    exit 1
fi

# Verificar e instalar versão correta do CMake via pip
echo "Verificando versão do CMake..."
CMAKE_VERSION=$(cmake --version | head -n1 | awk '{print $3}')
REQUIRED_CMAKE="3.31.6"

if [[ "$CMAKE_VERSION" != "$REQUIRED_CMAKE" ]]; then
    echo "Versão do CMake ($CMAKE_VERSION) diferente da requerida ($REQUIRED_CMAKE)"
    echo "Instalando CMake $REQUIRED_CMAKE via pip..."
    pip3 install --user cmake==$REQUIRED_CMAKE
    export PATH=$HOME/.local/bin:$PATH
    echo "CMake $REQUIRED_CMAKE instalado com sucesso"
else
    echo "CMake $REQUIRED_CMAKE já está instalado"
fi

# Configurações dos compiladores
export SERIAL_FC=gfortran
export SERIAL_F77=gfortran
export SERIAL_CC=gcc
export SERIAL_CXX=g++
export MPI_FC=mpif90
export MPI_F77=mpif77
export MPI_CC=mpicc
export MPI_CXX=mpic++

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
unset F90
unset F90FLAGS

cd $LIBSRC

########################################
# MPICH
########################################
echo "Instalando MPICH..."
if [[ ! -f "$LIBBASE/bin/mpicc" ]]; then
    wget -c https://www.mpich.org/static/downloads/4.2.1/mpich-4.2.1.tar.gz
    tar xzvf mpich-4.2.1.tar.gz
    cd mpich-4.2.1
    ./configure --prefix=$LIBBASE
    make -j 8
    make install
    cd ..
    echo "MPICH instalado com sucesso"
else
    echo "MPICH já está instalado, pulando..."
fi

export PATH=$LIBBASE/bin:$PATH
export LD_LIBRARY_PATH=$LIBBASE/lib:$LD_LIBRARY_PATH

########################################
# zlib
########################################
echo "Instalando zlib..."
if [[ ! -f "$LIBBASE/lib/libz.a" ]]; then
    wget -c https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/zlib-1.2.11.tar.gz
    tar xzvf zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure --prefix=$LIBBASE --static
    make -j 4
    make install
    cd ..
    echo "zlib instalado com sucesso"
else
    echo "zlib já está instalado, pulando..."
fi

########################################
# libpng (para GRIB2)
########################################
echo "Instalando libpng..."
if [[ ! -f "$GRIB2DIR/lib/libpng.a" ]]; then
    wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
    tar xzvf libpng-1.2.50.tar.gz
    cd libpng-1.2.50
    ./configure --prefix=$GRIB2DIR --disable-shared --enable-static
    make -j 4
    make install
    cd ..
    rm -rf libpng*
    echo "libpng instalado com sucesso"
else
    echo "libpng já está instalado, pulando..."
fi

########################################
# jasper (para GRIB2)
########################################
echo "Instalando jasper..."
if [[ ! -f "$GRIB2DIR/lib/libjasper.a" ]]; then
    wget -c https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
    tar xzvf jasper-1.900.1.tar.gz
    cd jasper-1.900.1
    ./configure --prefix=$GRIB2DIR
    make -j 4
    make install
    cd ..
    rm -rf jasper*
    echo "jasper instalado com sucesso"
else
    echo "jasper já está instalado, pulando..."
fi

########################################
# HDF5
########################################
echo "Instalando HDF5..."
if [[ ! -f "$LIBBASE/lib/libhdf5.a" ]]; then
    wget -c https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/hdf5-1.10.5.tar.bz2
    tar xjvf hdf5-1.10.5.tar.bz2
    cd hdf5-1.10.5
    export FC=$MPI_FC
    export CC=$MPI_CC
    export CXX=$MPI_CXX
    ./configure --prefix=$LIBBASE --enable-parallel --with-zlib=$LIBBASE --disable-shared --enable-fortran
    make -j 4
    make install
    cd ..
    echo "HDF5 instalado com sucesso"
else
    echo "HDF5 já está instalado, pulando..."
fi

########################################
# Parallel-netCDF
########################################
echo "Instalando Parallel-netCDF..."
if [[ ! -f "$LIBBASE/lib/libpnetcdf.a" ]]; then
    wget -c https://parallel-netcdf.github.io/Release/pnetcdf-1.13.0.tar.gz
    tar xzvf pnetcdf-1.13.0.tar.gz
    cd pnetcdf-1.13.0
    export CC=$SERIAL_CC
    export CXX=$SERIAL_CXX
    export F77=$SERIAL_F77
    export FC=$SERIAL_FC
    export MPICC=$MPI_CC
    export MPICXX=$MPI_CXX
    export MPIF77=$MPI_F77
    export MPIF90=$MPI_FC
    ./configure --prefix=$LIBBASE 
    make -j 4
    make install
    export PNETCDF=$LIBBASE
    cd ..
    echo "Parallel-netCDF instalado com sucesso"
else
    echo "Parallel-netCDF já está instalado, pulando..."
fi

########################################
# netCDF (biblioteca C)
########################################
echo "Instalando NetCDF-C..."
if [[ ! -f "$LIBBASE/lib/libnetcdf.a" ]]; then
    wget -c https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz
    tar xzvf v4.9.2.tar.gz
    cd netcdf-c-4.9.2
    export CPPFLAGS="-I$LIBBASE/include"
    export LDFLAGS="-L$LIBBASE/lib"
    export LIBS="-lhdf5_hl -lhdf5 -lz -ldl"
    export CC=$MPI_CC
    ./configure --prefix=$LIBBASE --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-cdf5 --enable-parallel-tests --disable-shared --disable-byterange
    make -j 4 
    make install
    export NETCDF=$LIBBASE
    cd ..
    echo "NetCDF-C instalado com sucesso"
else
    echo "NetCDF-C já está instalado, pulando..."
fi

########################################
# netCDF (interface Fortran)
########################################
echo "Instalando NetCDF-Fortran..."
if [[ ! -f "$LIBBASE/lib/libnetcdff.a" ]]; then
    wget -c https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz
    tar xzvf v4.6.1.tar.gz
    cd netcdf-fortran-4.6.1
    export FC=$MPI_FC
    export F77=$MPI_F77
    LIBS=$(nc-config --libs)
    export LIBS
    ./configure --prefix=$LIBBASE --enable-parallel-tests --disable-shared
    make -j 4
    make install
    cd ..
    echo "NetCDF-Fortran instalado com sucesso"
else
    echo "NetCDF-Fortran já está instalado, pulando..."
fi

########################################
# PIO
########################################
echo "Instalando PIO..."
if [[ ! -f "$LIBBASE/lib/libpio.a" ]]; then
    if [[ ! -d "ParallelIO" ]]; then
        git clone https://github.com/NCAR/ParallelIO
    fi
    cd ParallelIO
    git checkout -b pio-2.6.2 pio2_6_2 2>/dev/null || git checkout pio-2.6.2
    export PIOSRC=`pwd`
    cd ..
    
    # Limpar diretório de build anterior se existir
    rm -rf pio
    mkdir -p pio
    cd pio
    
    export CC=$MPI_CC
    export FC=$MPI_FC
    
    # Verificar versão do CMake antes de compilar PIO
    echo "Verificando CMake para compilação do PIO..."
    CMAKE_CMD="cmake"
    
    # Tentar usar cmake do pip primeiro
    if command -v $HOME/.local/bin/cmake &>/dev/null; then
        CMAKE_CMD="$HOME/.local/bin/cmake"
        echo "Usando CMake do pip: $CMAKE_CMD"
    else
        echo "Usando CMake do sistema: $CMAKE_CMD"
    fi
    
    CMAKE_VER=$($CMAKE_CMD --version | head -n1 | awk '{print $3}')
    echo "Versão do CMake: $CMAKE_VER"
    
    # IMPORTANTE: Definir CMAKE_INSTALL_PREFIX explicitamente
    echo "Configurando PIO com prefix: $LIBBASE"
    
    $CMAKE_CMD \
        -DCMAKE_INSTALL_PREFIX=$LIBBASE \
        -DNetCDF_C_PATH=$NETCDF \
        -DNetCDF_Fortran_PATH=$NETCDF \
        -DPnetCDF_PATH=$PNETCDF \
        -DHDF5_PATH=$NETCDF \
        -DPIO_USE_MALLOC=ON \
        -DCMAKE_VERBOSE_MAKEFILE=1 \
        -DPIO_ENABLE_TIMING=OFF \
        ../ParallelIO
    
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha na configuração do CMake para PIO"
        exit 1
    fi
    
    make -j 4
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha na compilação do PIO"
        exit 1
    fi
    
    make install
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha na instalação do PIO"
        exit 1
    fi
    
    cd ..
    export PIO=$LIBBASE
    echo "PIO instalado com sucesso em $LIBBASE"
else
    echo "PIO já está instalado, pulando..."
fi

########################################
# Finalização
########################################
echo ""
echo "=========================================="
echo " Instalação Concluída com Sucesso!"
echo "=========================================="
echo "Bibliotecas instaladas em: $LIBBASE"
echo "Bibliotecas GRIB2 instaladas em: $GRIB2DIR"
echo ""
echo "Para usar as bibliotecas, adicione as seguintes linhas ao seu ~/.bashrc:"
echo ""
echo "# Configuração MPAS/MONAN"
echo "export PATH=$LIBBASE/bin:\$PATH"
echo "export PATH=\$HOME/.local/bin:\$PATH  # Para CMake do pip"
echo "export LD_LIBRARY_PATH=$LIBBASE/lib:\$LD_LIBRARY_PATH"
echo "export LD_LIBRARY_PATH=$GRIB2DIR/lib:\$LD_LIBRARY_PATH"
echo "export NETCDF=$LIBBASE"
echo "export PNETCDF=$LIBBASE"
echo "export PIO=$LIBBASE"
echo "export GRIB2DIR=$GRIB2DIR"
echo "export JASPERLIB=$GRIB2DIR/lib"
echo "export JASPERINC=$GRIB2DIR/include"
echo "export MPAS_EXTERNAL_LIBS=\"-L$LIBBASE/lib -lhdf5_hl -lhdf5 -ldl -lz\""
echo "export MPAS_EXTERNAL_INCLUDES=\"-I$LIBBASE/include\""
echo ""
echo "Depois execute: source ~/.bashrc"
