eval "$(conda shell.bash hook)"
conda activate studio

pip install jupyterlab-lsp \
    'python-lsp-server[all]' \
    jupyterlab-spellchecker


# Install sagemaker SDK  & scikit-learn onto jlab server for jump to definition support for sagemaker SDK
pip install sagemaker scikit-learn

# Create the lsp symlink directory so jupyterlab can open source files from user home directory (jlab root)
mkdir .lsp_symlink
ln -s /opt .lsp_symlink/opt

# Enable opening of symlink files under the hidden directory
echo yes | jupyter server --generate-config
sed -i '1i c.ContentsManager.allow_hidden = True' .jupyter/jupyter_server_config.py


# This configuration override is optional, to make LSP "extra-helpful" by default:
CMP_CONFIG_DIR=.jupyter/lab/user-settings/@krassowski/jupyterlab-lsp/
CMP_CONFIG_FILE=completion.jupyterlab-settings
CMP_CONFIG_PATH="$CMP_CONFIG_DIR/$CMP_CONFIG_FILE"
if test -f $CMP_CONFIG_PATH; then
    echo "jupyterlab-lsp config file already exists: Skipping default config setup"
else
    echo "Setting continuous hinting to enabled by default"
    mkdir -p $CMP_CONFIG_DIR
    echo '{ "continuousHinting": true }' > $CMP_CONFIG_PATH
fi


conda deactivate


# Once components are installed and configured, restart Jupyter to make sure everything propagates:
echo "Restarting Jupyter server..."
restart-jupyter-server