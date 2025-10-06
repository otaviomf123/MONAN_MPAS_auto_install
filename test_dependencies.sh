#!/usr/bin/env bash
#
# Script de Teste das Dependências MPAS/MONAN
# Verifica se todas as dependências necessárias estão instaladas e funcionando
#

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_test() {
    echo -n "Testando $1: "
}

print_pass() {
    echo -e "${GREEN}PASSOU${NC}"
}

print_fail() {
    echo -e "${RED}FALHOU${NC}"
}

print_warning() {
    echo -e "${YELLOW}AVISO${NC}"
}

print_header "Teste das Dependências MPAS/MONAN"

# Configurar caminhos padrão se não estiverem definidos
LIBBASE=${LIBBASE:-$HOME/libs}
GRIB2DIR=${GRIB2DIR:-$LIBBASE/grib2}

echo "Diretório de bibliotecas: $LIBBASE"
echo "Diretório GRIB2: $GRIB2DIR"
echo ""

# Variável para contar falhas
TOTAL_TESTS=0
FAILED_TESTS=0

# Função para incrementar contadores
run_test() {
    ((TOTAL_TESTS++))
    if ! eval "$2" &>/dev/null; then
        print_fail
        ((FAILED_TESTS++))
        return 1
    else
        print_pass
        return 0
    fi
}

#######################################
# Teste 1: Verificar dependências do sistema
#######################################
echo -e "${YELLOW}1. Verificando Dependências do Sistema${NC}"

print_test "wget"
run_test "wget" "command -v wget"

print_test "tar"
run_test "tar" "command -v tar"

print_test "gcc"
run_test "gcc" "command -v gcc"

print_test "gfortran"
run_test "gfortran" "command -v gfortran"

print_test "g++"
run_test "g++" "command -v g++"

print_test "make"
run_test "make" "command -v make"

print_test "cmake"
run_test "cmake" "command -v cmake"

print_test "git"
run_test "git" "command -v git"

print_test "python3"
run_test "python3" "command -v python3"

print_test "pip3"
run_test "pip3" "command -v pip3"

echo ""

#######################################
# Teste 2: Verificar compiladores MPI
#######################################
echo -e "${YELLOW}2. Verificando Compiladores MPI${NC}"

print_test "mpicc"
run_test "mpicc" "command -v mpicc"

print_test "mpif90"
run_test "mpif90" "command -v mpif90"

print_test "mpic++"
run_test "mpic++" "command -v mpic++"

# Testar versão do MPI
if command -v mpicc &>/dev/null; then
    print_test "versão MPI"
    if mpicc --version &>/dev/null; then
        print_pass
    else
        print_fail
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
fi

echo ""

#######################################
# Teste 3: Verificar bibliotecas instaladas
#######################################
echo -e "${YELLOW}3. Verificando Bibliotecas Instaladas${NC}"

print_test "NetCDF (nc-config)"
run_test "nc-config" "command -v nc-config"

print_test "HDF5 (h5dump)"
run_test "h5dump" "command -v h5dump"

print_test "CMake (versão 3.31.6)"
if command -v cmake &>/dev/null; then
    CMAKE_VER=$(cmake --version | head -n1 | awk '{print $3}')
    if [[ "$CMAKE_VER" == "3.31.6" ]]; then
        print_pass
    else
        print_warning
        echo "  (versão atual: $CMAKE_VER, requerida: 3.31.6)"
        ((FAILED_TESTS++))
    fi
else
    print_fail
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Verificar arquivos de biblioteca principais
libraries=("libnetcdf.a" "libnetcdff.a" "libhdf5.a" "libpnetcdf.a" "libz.a" "libpio.a")
for lib in "${libraries[@]}"; do
    print_test "$lib"
    run_test "$lib" "test -f $LIBBASE/lib/$lib"
done

# Verificar bibliotecas GRIB2
echo ""
echo -e "${BLUE}Bibliotecas GRIB2:${NC}"
grib2_libs=("libpng.a" "libjasper.a")
for lib in "${grib2_libs[@]}"; do
    print_test "$lib"
    run_test "$lib" "test -f $GRIB2DIR/lib/$lib"
done

echo ""

#######################################
# Teste 4: Verificar variáveis de ambiente
#######################################
echo -e "${YELLOW}4. Verificando Variáveis de Ambiente${NC}"

env_vars=("PATH" "LD_LIBRARY_PATH" "NETCDF" "PNETCDF" "PIO")
for var in "${env_vars[@]}"; do
    print_test "variável $var"
    if [[ -n "${!var}" ]]; then
        print_pass
    else
        print_fail
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
done

echo ""
echo -e "${BLUE}Variáveis GRIB2:${NC}"
grib2_vars=("GRIB2DIR" "JASPERLIB" "JASPERINC")
for var in "${grib2_vars[@]}"; do
    print_test "variável $var"
    if [[ -n "${!var}" ]]; then
        print_pass
    else
        print_fail
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
done

echo ""

#######################################
# Teste 5: Teste de compilação simples
#######################################
echo -e "${YELLOW}5. Teste de Compilação Simples${NC}"

# Criar arquivo de teste C
cat > test_mpi_c.c << 'EOF'
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
    
    printf("Hello from rank %d out of %d processors\n", world_rank, world_size);
    
    MPI_Finalize();
    return 0;
}
EOF

print_test "compilação MPI C"
if mpicc -o test_mpi_c test_mpi_c.c &>/dev/null; then
    print_pass
else
    print_fail
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Criar arquivo de teste Fortran
cat > test_mpi_f90.f90 << 'EOF'
program hello_mpi
    use mpi
    implicit none
    
    integer :: ierr, rank, size
    
    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    
    print *, 'Hello from rank', rank, 'out of', size, 'processors'
    
    call MPI_FINALIZE(ierr)
end program hello_mpi
EOF

print_test "compilação MPI Fortran"
if mpif90 -o test_mpi_f90 test_mpi_f90.f90 &>/dev/null; then
    print_pass
else
    print_fail
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Limpar arquivos de teste
rm -f test_mpi_c test_mpi_c.c test_mpi_f90 test_mpi_f90.f90

echo ""

#######################################
# Teste 6: Verificar links NetCDF
#######################################
echo -e "${YELLOW}6. Verificando Configuração NetCDF${NC}"

if command -v nc-config &>/dev/null; then
    print_test "nc-config --libs"
    if nc-config --libs &>/dev/null; then
        print_pass
    else
        print_fail
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))

    print_test "nc-config --includedir"
    if nc-config --includedir &>/dev/null; then
        print_pass
    else
        print_fail
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
    
    print_test "nc-config --version"
    if nc-config --version &>/dev/null; then
        NETCDF_VER=$(nc-config --version)
        echo -e "${GREEN}PASSOU${NC} ($NETCDF_VER)"
    else
        print_fail
        ((FAILED_TESTS++))
    fi
    ((TOTAL_TESTS++))
else
    print_test "nc-config disponível"
    print_fail
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
fi

echo ""

#######################################
# Teste 7: Verificar estrutura de diretórios
#######################################
echo -e "${YELLOW}7. Verificando Estrutura de Diretórios${NC}"

directories=("$LIBBASE/bin" "$LIBBASE/lib" "$LIBBASE/include" "$GRIB2DIR/lib" "$GRIB2DIR/include")
for dir in "${directories[@]}"; do
    print_test "diretório $(basename $dir)"
    run_test "dir_$dir" "test -d $dir"
done

echo ""

#######################################
# Teste 8: Verificar headers importantes
#######################################
echo -e "${YELLOW}8. Verificando Headers Importantes${NC}"

headers=("netcdf.h" "hdf5.h" "mpi.h" "png.h" "jasper/jasper.h")
header_paths=("$LIBBASE/include/netcdf.h" "$LIBBASE/include/hdf5.h" "$LIBBASE/include/mpi.h" "$GRIB2DIR/include/png.h" "$GRIB2DIR/include/jasper/jasper.h")

for i in "${!headers[@]}"; do
    print_test "${headers[$i]}"
    run_test "header_${headers[$i]}" "test -f ${header_paths[$i]}"
done

echo ""

#######################################
# Teste 9: Verificar versões das bibliotecas
#######################################
echo -e "${YELLOW}9. Verificando Versões das Bibliotecas${NC}"

if command -v mpicc &>/dev/null; then
    print_test "MPICH versão"
    MPI_VER=$(mpicc --version 2>/dev/null | head -n1)
    if [[ -n "$MPI_VER" ]]; then
        echo -e "${GREEN}PASSOU${NC} ($MPI_VER)"
    else
        print_warning
    fi
    ((TOTAL_TESTS++))
fi

if command -v h5dump &>/dev/null; then
    print_test "HDF5 versão"
    HDF5_VER=$(h5dump --version 2>/dev/null | head -n1 | awk '{print $3}')
    if [[ -n "$HDF5_VER" ]]; then
        echo -e "${GREEN}PASSOU${NC} (versão $HDF5_VER)"
    else
        print_warning
    fi
    ((TOTAL_TESTS++))
fi

echo ""

#######################################
# Resumo dos testes
#######################################
print_header "Resumo dos Testes"

echo "Total de testes executados: $TOTAL_TESTS"
echo "Testes que falharam: $FAILED_TESTS"
echo "Testes que passaram: $((TOTAL_TESTS - FAILED_TESTS))"
PASS_PERCENT=$((100 * (TOTAL_TESTS - FAILED_TESTS) / TOTAL_TESTS))
echo "Taxa de sucesso: ${PASS_PERCENT}%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ Todos os testes passaram! As dependências MPAS/MONAN estão prontas.${NC}"
    echo ""
    echo "Bibliotecas instaladas:"
    echo "  - MPICH, zlib, HDF5, Parallel-netCDF"
    echo "  - NetCDF-C, NetCDF-Fortran, PIO"
    echo "  - libpng, jasper (GRIB2)"
    echo ""
    echo "Você pode prosseguir com a compilação do MPAS ou MONAN."
    exit 0
else
    echo -e "${RED}✗ $FAILED_TESTS teste(s) falharam.${NC}"
    echo ""
    echo "Possíveis soluções:"
    echo "1. Verifique se o script de instalação foi executado completamente"
    echo "2. Certifique-se de que as variáveis de ambiente estão configuradas no ~/.bashrc"
    echo "3. Execute 'source ~/.bashrc' para recarregar o ambiente"
    echo "4. Verifique se todos os pacotes do sistema necessários estão instalados"
    echo "5. Para CMake 3.31.6, execute: pip3 install --user cmake==3.31.6"
    echo ""
    echo "Para reinstalar, execute:"
    echo "  ./install_mpas_monan_dependencies.sh"
    exit 1
fi
