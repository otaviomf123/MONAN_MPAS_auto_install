# Instalação Automática das Dependências MPAS/MONAN

Script automatizado para instalação das dependências do MPAS (Model for Prediction Across Scales) e MONAN (Model for Ocean-laNd-Atmosphere PredictioN) em sistemas Linux.

## Sobre o Projeto

O **MPAS** é um projeto colaborativo para desenvolvimento de componentes de simulação da atmosfera, oceano e outros sistemas terrestres para uso em estudos climáticos, climáticos regionais e meteorológicos. Desenvolvido pelo Los Alamos National Laboratory e National Center for Atmospheric Research.

O **MONAN** é um modelo comunitário do Sistema Terrestre Unificado gerenciado pelo INPE que tem sua estrutura de versão inicial (0.1.0) baseada no núcleo dinâmico do MPAS 8.0.1.

Este repositório fornece um script de instalação automatizada que compila e instala todas as dependências necessárias para as versões MPAS 8.x e MONAN 1.4x.

## Dependências Instaladas

O script instala automaticamente as seguintes bibliotecas na ordem correta:

### 1. MPICH 4.2.1
Implementação MPI necessária para capacidades de computação paralela no MPAS/MONAN.

### 2. zlib 1.2.11  
Biblioteca de compressão usada pelo HDF5 e NetCDF para armazenamento e transferência eficiente de dados.

### 3. HDF5 1.10.5
Biblioteca de gerenciamento de dados de alta performance com suporte a operações de I/O paralelo.

### 4. Parallel-netCDF 1.13.0
Biblioteca de I/O paralelo de alta performance para acessar arquivos NetCDF em formatos clássicos (CDF-1, CDF-2 e CDF-5).

### 5. NetCDF-C 4.9.2
Formato de dados autoexplicativo e portável amplamente usado em ciências atmosféricas e oceanográficas.

### 6. NetCDF-Fortran 4.6.1
Interface Fortran para a biblioteca NetCDF, essencial para MPAS/MONAN que são escritos principalmente em Fortran.

### 7. PIO 2.6.2
Biblioteca de I/O Paralelo de alto nível para aplicações de grade estruturada que fornece uma API similar ao netCDF.

## Requisitos do Sistema

### Sistema Operacional
- Linux (testado no Ubuntu, CentOS, RHEL, Fedora)
- Arquitetura 64-bit recomendada

### Pacotes Necessários

**Ubuntu/Debian:**
```bash
sudo apt-get install wget tar gcc gfortran g++ make cmake git
```

**CentOS/RHEL:**
```bash
sudo yum install wget tar gcc gfortran gcc-c++ make cmake git
```

**Fedora:**
```bash
sudo dnf install wget tar gcc gfortran gcc-c++ make cmake git
```

### Requisitos de Hardware
- Mínimo 4GB RAM (8GB+ recomendado)
- Pelo menos 5GB de espaço livre em disco
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

### Personalização dos Diretórios

Você pode personalizar os diretórios de instalação definindo variáveis de ambiente:

```bash
export LIBSRC="/caminho/para/diretorio/fontes"     # Onde os arquivos fonte são baixados
export LIBBASE="/caminho/para/diretorio/instalacao" # Onde as bibliotecas são instaladas
./install_mpas_monan_dependencies.sh
```

Diretórios padrão:
- Diretório de fontes: `$HOME/lib_repo`
- Diretório de instalação: `$HOME/libs`

## Configuração do Ambiente do Usuário

Após a instalação bem-sucedida, adicione as seguintes linhas ao seu arquivo `~/.bashrc`:

```bash
# Configuração MPAS/MONAN
export PATH=$HOME/libs/bin:$PATH
export LD_LIBRARY_PATH=$HOME/libs/lib:$LD_LIBRARY_PATH
export NETCDF=$HOME/libs
export PNETCDF=$HOME/libs
export PIO=$HOME/libs
export MPAS_EXTERNAL_LIBS="-L$HOME/libs/lib -lhdf5_hl -lhdf5 -ldl -lz"
export MPAS_EXTERNAL_INCLUDES="-I$HOME/libs/include"
```

Depois execute:
```bash
source ~/.bashrc
```

## Testando a Instalação

Para verificar se a instalação foi bem-sucedida, teste os seguintes comandos:

```bash
# Testar MPI
mpicc --version
mpif90 --version

# Testar NetCDF
nc-config --version

# Testar HDF5
h5dump --version

# Testar se todas as bibliotecas estão acessíveis
ls $HOME/libs/lib/
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

## Solução de Problemas

### Problemas Comuns

1. **Pacotes do sistema ausentes:**
   - O script identificará pacotes ausentes e fornecerá comandos de instalação
   - Certifique-se de ter privilégios administrativos para instalar pacotes do sistema

2. **Falhas de compilação:**
   - Verifique espaço disponível em disco (necessário pelo menos 5GB)
   - Verifique se possui RAM suficiente (4GB mínimo)
   - Certifique-se de que todos os pacotes necessários do sistema estão instalados

3. **Ambiente não carregando:**
   - Certifique-se de executar `source ~/.bashrc` após adicionar as variáveis
   - Verifique se a instalação foi concluída com sucesso
   - Verifique as permissões dos arquivos

4. **MPI não encontrado:**
   - Certifique-se de que o diretório bin da instalação está no seu PATH
   - Tente recarregar seu shell ou executar `source ~/.bashrc`

### Versões das Bibliotecas

O script instala estas versões específicas (testadas e compatíveis):

- MPICH: 4.2.1
- zlib: 1.2.11
- HDF5: 1.10.5
- Parallel-netCDF: 1.13.0
- NetCDF-C: 4.9.2
- NetCDF-Fortran: 4.6.1
- PIO: 2.6.2

## Variáveis de Ambiente Importantes

Após a instalação, as seguintes variáveis de ambiente são configuradas:

| Variável | Descrição |
|----------|-----------|
| `NETCDF` | Caminho para instalação do NetCDF |
| `PNETCDF` | Caminho para instalação do Parallel-netCDF |
| `PIO` | Caminho para instalação do PIO |
| `MPAS_EXTERNAL_LIBS` | Flags de linkagem das bibliotecas para compilação do MPAS |
| `MPAS_EXTERNAL_INCLUDES` | Caminhos de include para compilação do MPAS |

## URLs das Fontes

O script baixa as bibliotecas dos seguintes locais:

- **MPICH:** https://www.mpich.org/static/downloads/4.2.1/mpich-4.2.1.tar.gz
- **zlib:** https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/zlib-1.2.11.tar.gz
- **HDF5:** https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/hdf5-1.10.5.tar.bz2
- **Parallel-netCDF:** https://parallel-netcdf.github.io/Release/pnetcdf-1.13.0.tar.gz
- **NetCDF-C:** https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz
- **NetCDF-Fortran:** https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz
- **PIO:** https://github.com/NCAR/ParallelIO (branch pio2_6_2)

## Referências

- [Site Oficial do MPAS](https://mpas-dev.github.io/)
- [Repositório GitHub do MONAN](https://github.com/monanadmin/MONAN-Model)
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
