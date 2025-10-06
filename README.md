# Instalação Automática das Dependências MPAS/MONAN

Script automatizado para instalação das dependências do MPAS (Model for Prediction Across Scales) e MONAN (Model for Ocean-laNd-Atmosphere PredictioN) em sistemas Linux.

## Sobre o Projeto

O **MPAS** é um projeto colaborativo para desenvolvimento de componentes de simulação da atmosfera, oceano e outros sistemas terrestres para uso em estudos climáticos, climáticos regionais e meteorológicos. Desenvolvido pelo Los Alamos National Laboratory e National Center for Atmospheric Research.

O **MONAN** é um modelo comunitário do Sistema Terrestre Unificado gerenciado pelo INPE que tem sua estrutura de versão inicial (0.1.0) baseada no núcleo dinâmico do MPAS 8.0.1.

Este repositório fornece um script de instalação automatizada que compila e instala todas as dependências necessárias para as versões MPAS 8.x e MONAN 1.4x, incluindo suporte completo para processamento de dados GRIB2.

## Dependências Instaladas

O script instala automaticamente as seguintes bibliotecas na ordem correta:

### 1. CMake 3.31.6 (via pip)
Versão específica do CMake necessária para compilação correta do PIO. Instalada via Python pip para garantir a versão exata.

### 2. MPICH 4.2.1
Implementação MPI necessária para capacidades de computação paralela no MPAS/MONAN.

### 3. zlib 1.2.11  
Biblioteca de compressão usada pelo HDF5 e NetCDF para armazenamento e transferência eficiente de dados.

### 4. libpng 1.2.50
Biblioteca PNG necessária para suporte a dados GRIB2. Instalada no diretório separado `$LIBBASE/grib2`.

### 5. jasper 1.900.1
Biblioteca JPEG-2000 necessária para processamento de dados GRIB2. Instalada no diretório separado `$LIBBASE/grib2`.

### 6. HDF5 1.10.5
Biblioteca de gerenciamento de dados de alta performance com suporte a operações de I/O paralelo.

### 7. Parallel-netCDF 1.13.0
Biblioteca de I/O paralelo de alta performance para acessar arquivos NetCDF em formatos clássicos (CDF-1, CDF-2 e CDF-5).

### 8. NetCDF-C 4.9.2
Formato de dados autoexplicativo e portável amplamente usado em ciências atmosféricas e oceanográficas.

### 9. NetCDF-Fortran 4.6.1
Interface Fortran para a biblioteca NetCDF, essencial para MPAS/MONAN que são escritos principalmente em Fortran.

### 10. PIO 2.6.2
Biblioteca de I/O Paralelo de alto nível para aplicações de grade estruturada que fornece uma API similar ao netCDF.

## Requisitos do Sistema

### Sistema Operacional
- Linux (testado no Ubuntu, CentOS, RHEL, Fedora)
- Arquitetura 64-bit recomendada

### Pacotes Necessários

**Ubuntu/Debian:**
```bash
sudo apt-get install wget tar gcc gfortran g++ make cmake git python3 python3-pip
```

**CentOS/RHEL:**
```bash
sudo yum install wget tar gcc gfortran gcc-c++ make cmake git python3 python3-pip
```

**Fedora:**
```bash
sudo dnf install wget tar gcc gfortran gcc-c++ make cmake git python3 python3-pip
```

### Requisitos de Hardware
- Mínimo 4GB RAM (8GB+ recomendado)
- Pelo menos 6GB de espaço livre em disco
- Processador multi-core (compilação usará todos os núcleos disponíveis)

## Instalação

### Instalação Rápida

1. Clone este repositório:
```bash
git clone https://github.com/otaviomf123/MONAN_MPAS_auto_install.git
cd MONAN_MPAS_auto_install
```

2. Execute o script de instalação:
```bash
chmod +x install_mpas_monan_dependencies.sh
./install_mpas_monan_dependencies.sh
```

3. Configure o ambiente (adicione ao ~/.bashrc as variáveis mostradas na seção seguinte):
```bash
source ~/.bashrc
```

4. Teste a instalação:
```bash
chmod +x test_dependencies.sh
./test_dependencies.sh
```

### Personalização dos Diretórios

Você pode personalizar os diretórios de instalação definindo variáveis de ambiente:

```bash
export LIBSRC="/caminho/para/diretorio/fontes"      # Onde os arquivos fonte são baixados
export LIBBASE="/caminho/para/diretorio/instalacao" # Onde as bibliotecas são instaladas
export GRIB2DIR="/caminho/para/diretorio/grib2"     # Onde libpng e jasper são instaladas
./install_mpas_monan_dependencies.sh
```

Diretórios padrão:
- Diretório de fontes: `$HOME/lib_repo`
- Diretório de instalação: `$HOME/libs`
- Diretório GRIB2: `$HOME/libs/grib2`

## Configuração do Ambiente do Usuário

Após a instalação bem-sucedida, adicione as seguintes linhas ao seu arquivo `~/.bashrc`:

```bash
# Configuração MPAS/MONAN
export PATH=$HOME/libs/bin:$PATH
export PATH=$HOME/.local/bin:$PATH  # Para CMake do pip
export LD_LIBRARY_PATH=$HOME/libs/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HOME/libs/grib2/lib:$LD_LIBRARY_PATH

# Configurações dos compiladores
export SERIAL_FC=gfortran
export SERIAL_F77=gfortran
export SERIAL_CC=gcc
export SERIAL_CXX=g++
export MPI_FC=mpif90
export MPI_F77=mpif77
export MPI_CC=mpicc
export MPI_CXX=mpic++

# Caminhos das bibliotecas
export NETCDF=$HOME/libs
export PNETCDF=$HOME/libs
export PIO=$HOME/libs

# Bibliotecas GRIB2
export GRIB2DIR=$HOME/libs/grib2
export JASPERLIB=$HOME/libs/grib2/lib
export JASPERINC=$HOME/libs/grib2/include

# Variáveis para compilação do MPAS/MONAN
export MPAS_EXTERNAL_LIBS="-L$HOME/libs/lib -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I$HOME/libs/include"
```

Depois execute:
```bash
source ~/.bashrc
```

### Testando a Instalação Automaticamente

Execute o script de teste incluso para verificar todas as dependências:

```bash
chmod +x test_dependencies.sh
./test_dependencies.sh
```

O script de teste agora verifica:
- Todas as ferramentas do sistema
- Compiladores MPI
- Bibliotecas principais (NetCDF, HDF5, PnetCDF, zlib)
- Bibliotecas GRIB2 (libpng, jasper)
- Versão correta do CMake (3.31.6)
- Variáveis de ambiente
- Compilação simples de código MPI

### Testando Manualmente

Para verificar se a instalação foi bem-sucedida, teste os seguintes comandos:

```bash
# Testar MPI
mpicc --version
mpif90 --version

# Testar NetCDF
nc-config --version

# Testar HDF5
h5dump --version

# Testar CMake
cmake --version  # Deve mostrar 3.31.6

# Testar se todas as bibliotecas estão acessíveis
ls $HOME/libs/lib/
ls $HOME/libs/grib2/lib/
```

## Compilando MPAS/MONAN

Após instalação e configuração do ambiente:

### Para MPAS:
```bash
git clone https://github.com/MPAS-Dev/MPAS-Model.git
cd MPAS-Model
make gfortran CORE=atmosphere
```

### Para MONAN:
```bash
git clone https://github.com/monanadmin/MONAN-Model.git
cd MONAN-Model
make gfortran CORE=atmosphere
```

## Estrutura de Diretórios

Após a instalação, a estrutura de diretórios será:

```
$HOME/
├── lib_repo/              # Código fonte baixado
│   ├── mpich-4.2.1/
│   ├── zlib-1.2.11/
│   ├── hdf5-1.10.5/
│   ├── pnetcdf-1.13.0/
│   ├── netcdf-c-4.9.2/
│   ├── netcdf-fortran-4.6.1/
│   ├── ParallelIO/
│   └── pio/
└── libs/                  # Bibliotecas instaladas
    ├── bin/               # Executáveis (mpicc, nc-config, etc)
    ├── include/           # Headers
    ├── lib/               # Bibliotecas principais
    └── grib2/             # Bibliotecas GRIB2 separadas
        ├── bin/
        ├── include/
        └── lib/           # libpng.a, libjasper.a
```

## Solução de Problemas

### Problemas Comuns

1. **Pacotes do sistema ausentes:**
   - O script identificará pacotes ausentes e fornecerá comandos de instalação
   - Certifique-se de ter privilégios administrativos para instalar pacotes do sistema

2. **Versão incorreta do CMake:**
   - O script instalará automaticamente CMake 3.31.6 via pip
   - Se encontrar problemas, instale manualmente: `pip3 install --user cmake==3.31.6`
   - Certifique-se de que `$HOME/.local/bin` está no seu PATH

3. **Falhas de compilação:**
   - Verifique espaço disponível em disco (necessário pelo menos 6GB)
   - Verifique se possui RAM suficiente (4GB mínimo)
   - Certifique-se de que todos os pacotes necessários do sistema estão instalados

4. **Ambiente não carregando:**
   - Certifique-se de executar `source ~/.bashrc` após adicionar as variáveis
   - Verifique se a instalação foi concluída com sucesso
   - Verifique as permissões dos arquivos

5. **Configurações dos compiladores incorretas:**
   - Verifique se as variáveis FC, CC, F77, CXX estão definidas corretamente
   - Certifique-se de que os compiladores MPI estão funcionando (mpicc, mpif90)
   - Execute os testes para verificar a compilação

6. **Bibliotecas GRIB2 não encontradas:**
   - Verifique se `GRIB2DIR`, `JASPERLIB` e `JASPERINC` estão definidos
   - Confirme que `$GRIB2DIR/lib` contém libpng.a e libjasper.a
   - Verifique se `LD_LIBRARY_PATH` inclui `$GRIB2DIR/lib`

### Versões das Bibliotecas

O script instala estas versões específicas (testadas e compatíveis):

- CMake: 3.31.6 (via pip)
- MPICH: 4.2.1
- zlib: 1.2.11
- libpng: 1.2.50
- jasper: 1.900.1
- HDF5: 1.10.5
- Parallel-netCDF: 1.13.0
- NetCDF-C: 4.9.2
- NetCDF-Fortran: 4.6.1
- PIO: 2.6.2

## Variáveis de Ambiente Importantes

Após a instalação, as seguintes variáveis de ambiente são configuradas:

### Caminhos das Bibliotecas
| Variável | Descrição |
|----------|-----------|
| `NETCDF` | Caminho para instalação do NetCDF |
| `PNETCDF` | Caminho para instalação do Parallel-netCDF |
| `PIO` | Caminho para instalação do PIO |
| `GRIB2DIR` | Caminho para bibliotecas GRIB2 (libpng, jasper) |
| `JASPERLIB` | Caminho para biblioteca jasper |
| `JASPERINC` | Caminho para headers jasper |

### Configurações dos Compiladores
| Variável | Descrição |
|----------|-----------|
| `SERIAL_FC` | Compilador Fortran serial (gfortran) |
| `SERIAL_F77` | Compilador Fortran 77 serial (gfortran) |
| `SERIAL_CC` | Compilador C serial (gcc) |
| `SERIAL_CXX` | Compilador C++ serial (g++) |
| `MPI_FC` | Compilador Fortran MPI (mpif90) |
| `MPI_F77` | Compilador Fortran 77 MPI (mpif77) |
| `MPI_CC` | Compilador C MPI (mpicc) |
| `MPI_CXX` | Compilador C++ MPI (mpic++) |

### Configurações para Compilação MPAS/MONAN
| Variável | Descrição |
|----------|-----------|
| `MPAS_EXTERNAL_LIBS` | Flags de linkagem das bibliotecas para compilação do MPAS |
| `MPAS_EXTERNAL_INCLUDES` | Caminhos de include para compilação do MPAS |

## URLs das Fontes

O script baixa as bibliotecas dos seguintes locais:

- **MPICH:** https://www.mpich.org/static/downloads/4.2.1/mpich-4.2.1.tar.gz
- **zlib:** https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/zlib-1.2.11.tar.gz
- **libpng:** https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
- **jasper:** https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
- **HDF5:** https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/hdf5-1.10.5.tar.bz2
- **Parallel-netCDF:** https://parallel-netcdf.github.io/Release/pnetcdf-1.13.0.tar.gz
- **NetCDF-C:** https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz
- **NetCDF-Fortran:** https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz
- **PIO:** https://github.com/NCAR/ParallelIO (branch pio2_6_2)

## Novidades nesta Versão

### Suporte Completo para GRIB2
- Adicionado libpng 1.2.50 para manipulação de imagens PNG
- Adicionado jasper 1.900.1 para compressão JPEG-2000
- Bibliotecas GRIB2 instaladas em diretório separado (`$GRIB2DIR`)

### Gerenciamento de Versão do CMake
- Instalação automática do CMake 3.31.6 via pip
- Verificação da versão antes da compilação do PIO
- Garantia de compatibilidade com PIO 2.6.2

### Melhorias no Script de Teste
- Verificação da versão correta do CMake
- Teste das bibliotecas GRIB2 (libpng e jasper)
- Validação de variáveis de ambiente adicionais

## Referências

- [Site Oficial do MPAS](https://mpas-dev.github.io/)
- [Repositório GitHub do MONAN](https://github.com/monanadmin/MONAN-Model)
- [Tutorial WRF/WPS](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/)
- [Documentação NetCDF](https://www.unidata.ucar.edu/software/netcdf/)
- [Documentação HDF5](https://www.hdfgroup.org/solutions/hdf5/)
- [Documentação PIO](https://ncar.github.io/ParallelIO/)
- [Fontes MPAS NCAR](http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/)

## Licença

Este projeto está licenciado sob a Licença MIT.

## Autor

- Otavio M. Feitosa
- Baseado nas diretrizes de compilação MPAS/MONAN do NCAR e INPE

## Agradecimentos

- NCAR (National Center for Atmospheric Research) pelo desenvolvimento do MPAS
- INPE (Instituto Nacional de Pesquisas Espaciais) pelo desenvolvimento do MONAN
- Contribuidores das comunidades MPAS e MONAN
- Comunidade WRF pelo tutorial de compilação das bibliotecas GRIB2
