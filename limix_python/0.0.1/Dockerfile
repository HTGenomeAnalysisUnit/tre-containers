FROM ghcr.io/astral-sh/uv:python3.13-bookworm

LABEL Description="Limix Python environment"
LABEL Author="Jan Engelmann"
LABEL Contact="jan.engelmann@helmholtz-munich.de"
LABEL version="0.0.1"

# 1. Set up the environment variables manually
# This "activates" the venv for all future RUN commands (including bash scripts)
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 2. Create the venv in a specific location
RUN uv venv $VIRTUAL_ENV

WORKDIR /tmp

# 3. System dependencies
RUN chmod 1777 /tmp && apt-get update -y && apt-get install -y \
    cmake \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 4. Now this script will see the VIRTUAL_ENV and install into it correctly
RUN curl -fsSL https://raw.githubusercontent.com/limix/chi2comb/master/install | bash

# 5. UV Install
# Note: We don't need --link-mode=copy if we aren't using mounts, but it's fine to keep.
# We added 'git' to apt-get above so the git+ url works reliably.
RUN uv pip install pandas numpy matplotlib scipy scikit-learn jupyterlab ipywidgets \
    fastcluster chiscore openpyxl ruff pyarrow scanpy anndata tqdm formulaic \
    statsmodels limix_core pgenlib matplotlib_venn seaborn "setuptools<81" \
    git+https://github.com/HTGenomeAnalysisUnit/project_styler_py.git --link-mode=copy

# 6. Jupyter Kernel
# Removed '--user'. Since PATH is set, this installs into /opt/venv/share/jupyter which is correct.
RUN uv run -m ipykernel install --name vardec --display-name "vardec"

# Cleanup
RUN rm -f uv-setuptools-*.lock

ENTRYPOINT ["uv", "run"]
