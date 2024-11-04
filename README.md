# TRE containers repository

This repository hosts container recipes for analyses in the G&H TRE system.

The repository automatically builds any Dockerfile pushed to the main branch and publish them in DockerHub.

- [TRE containers repository](#tre-containers-repository)
  - [The base containers](#the-base-containers)
    - [R studio](#r-studio)
    - [Python](#python)
  - [How to create a new container](#how-to-create-a-new-container)
  - [Templates](#templates)
    - [For R studio](#for-r-studio)
    - [For Python](#for-python)
  - [Use R and Python from your container](#use-r-and-python-from-your-container)
    - [Python](#python-1)
    - [R](#r)

## The base containers

There are 2 base containers for R studio and Python that are used as a base for all other containers. These containers are built from the `rstudio-desktop` and `python-base` folders in the repository.

<details>

<summary>Expand here to see packages included in the base containers</summary>

### R studio

- broom
- data.table
- devtools
- dplyr
- gghighlight
- ggiraph
- geomtextpath
- ggplot2
- ggraph
- ggrepel
- ggridges
- ggstatsplot
- ggupset
- hexbin
- MASS
- Matrix
- patchwork
- plotly
- scales
- skimr
- stringr
- tidyr
- UpSetR
- ComplexHeatmap

### Python

- git=2.47.0 
- ipykernel>=6.29.5
- jedi-language-server>=0.41.4
- jupyter-resource-usage>=1.1.0
- jupyterlab-git>=0.50.1
- jupyterlab-lsp>=5.1.0
- jupyterlab=4.2.5
- notebook=7.2.2
- pandas>=2.2.3
- leidenalg>=0.10.2
- scanpy=1.10.2
- umap-learn>=0.5.6
- tqdm>=4.66.5
- seaborn

</details>

## How to create a new container

If a package you need is not included in the base container or in other containers already available, you can create a new container with the packages you need. **Please be considerate when creating a new container. Try to reuse existing containers when possible and minimize the number of new containers built.**

For each defined container, the last recipe you push is tagged as `latest` in DockerHub and will be automatically imported in the TRE. Therefore, **it is important to manage your versions correctly and to avoid creating 2 versions of the same container in the same merge request.**

To create a new container, follow the steps below:

1. Clone this repository to your local machine

```
git clone https://github.com/HTGenomeAnalysisUnit/tre-containers.git
```

2. Create a new branch with a distinctive name where you will work on your new containers

```
git checkout -b your-branch-name
```

3. Create a new folder with the main name of your container in the root of the repository
4. Within this folder create a version folder, this can only contain small letters, numbers and dots. You can create more then one version folder if you want to have multiple versions of the same container. In the end you will have a structure like this:

```
tre-containers
├── your-container
    ├── 1.0.0
    │   ├── Dockerfile
    │   `── other files...
    `── myname.1.0
        ├── Dockerfile
        `── other files...
```

5. Within the version folder use one of the templates described below to create your new container. **NB.** When you are ready to push your changes you should rename `template_dockerfile` to `Dockerfile` in your container folder.
6. Push your changes to a new branch in the repository

```
git add .
git commit -m "Add new container"
git push --set-upstream origin your-branch-name
```

7. On the GitHub repository website, create a pull request to merge your branch to the main branch. This will be approved and the container built.

## Templates

### For R studio

Please refer to `template_rstudio` folder. 

- Copy the files in this folder to your container folder.
- Update Author and Contact LABELS in the template_dockerfile file.
- Create a new `requirements.txt` file with the R packages you need to install (the one present in the template folder contains some dummy examples, don't include them in your final requrements file). Packages should be listed one per line, with the version number if needed using standard version syntax (e.g. `dplyr==1.0.0`, `dplyr>=1.0.0`). If no version is specified, the latest version will be installed.

If you need to install packages from **Bioconductor**, you can add the `bioc+` prefix to the package name in the requirements.txt file. Version definition works as usual. For example, to install the `DESeq2` package from Bioconductor, you should add the following line to the requirements.txt file:

```
bioc+DESeq2
```

If you need to install packages from **GitHub**, you can add the `git+` prefix to the package name in the requirements.txt file. Version definition works as usual. For example, to install the `DIALOGUE` package from GitHub, you should add the following line to the requirements.txt file:

```
git+https://github.com/livnatje/DIALOGUE
```

To refer to a specific tag or commit use the following syntax:

```	
git+https://github.com/livnatje/DIALOGUE@v1.0.0
```

### For Python

Please refer to `template_python` folder. 

- Copy the files in this folder to your container folder.
- Update Author and Contact LABELS in the template_dockerfile file.
- Update the `environment.yml` to generate the environment you need. This follows the standard syntax for conda environment definition file. You can use the `conda` or `pip` sections to install packages. **NB.** Do not chance the name of the environment file.
- In most cases, it is suggested to add your packages to the environment.yml file from the template. This file includes support for jupyter-lab and some useful jupyter-lab extensions. 

## Use R and Python from your container

General notes:

- Add `--nv` option after `run` if you need to use GPU.
- Add any relevant path to the `-B` option to mount directories from the host to the container. You read/write only in the mounted directories.

### Python

When you are in the TRE

1. Navigate to a working directory where you have writing permissions
2. Launch jupyter-lab from the container. This will automatically open a browser window with the jupyter-lab interface.

```bash
singularity run --cleanenv \
    -B /my/data/folder -B /another/data/folder \
    /path/to/your_TRE_python_container.sif \
    jupyter-lab --port 9973 --ip 0.0.0.0 \
    --notebook-dir /your/TRE/notebook/path
```

- Use `--notebook-dir` to specify the directory where you want to start jupyter-lab. This should be a directory where you have writing permissions and where you want to create notebooks.
- Pick a random port number for `--port` to avoid conflicts with other users. Generally, any number between 9000 and 9999 should be fine.

### R

When you are in the TRE

1. Navigate to a working directory where you have writing permissions

TODO: Update this section for the new rstudio server container

When you are in the R studio interface, please remove the local source of packages from your home to avoid conflicts with the system packages. You can do this by running the following command in the R console:

```R
.libPaths(.libPaths()[!grepl("/home/", .libPaths())])
```